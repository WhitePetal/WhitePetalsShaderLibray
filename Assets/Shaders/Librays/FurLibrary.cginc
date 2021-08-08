#ifndef FUR_INCLUDE
#define FUR_INCLUDE
#pragma target 3.5
#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "../Librays/ShaderUtil.cginc"

struct appdata
{
    float4 vertex : POSITION;
    half2 uv : TEXCOORD0;
    half3 normal : NORMAL;
    half4 tangent : TANGENT;
};

struct v2f
{
    half4 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 pos_world : TEXCOORD1;
    half3 specular : TEXCOORD2;
    half3 diffuse : TEXCOORD3;
    fixed3 irrlight : TEXCOORD4;
    fixed3 ambientDiffuse : TEXCOORD5;
    fixed3 ambientSpecular : TEXCOORD6;
    half3 v_reflect : TEXCOORD7;

    SHADOW_COORDS(8)
};

samplerCUBE _AmbientTex;
sampler2D _Albedo, _ShapeTex, _NormalMap, _ShiftTex;
half4 _Albedo_ST;
half4 _ShapeTex_ST;
fixed3 _DiffuseColor, _SpecularColor, _SpecColor1, _SpecColor2, _AmbientColor;
half4 _Shifts_SpecularWidths;
half4 _Exponents_SpecStrengths;
half3 _NormalScale_FurOffset_FurLength, _KdKsExpoure;
fixed _AO;
half _Noise;

v2f vert (appdata v, fixed layer)
{
    v2f o;
    o.uv.xy = TRANSFORM_TEX(v.uv, _Albedo);
    o.uv.zw = TRANSFORM_TEX(v.uv, _ShapeTex) + (random(o.uv.xy) * 2.0 - 1.0) * _Noise;
    half3 normal_world = UnityObjectToWorldNormal(v.normal);
    half3 tangent_world = UnityObjectToWorldDir(v.tangent.xyz);
    half3 binormal_world = cross(normal_world, tangent_world) * v.tangent.w * unity_WorldTransformParams.w;
    half3 normal_tangent = UnpackScaleNormal(tex2Dlod(_NormalMap, half4(o.uv.xy, 0.0, 0.0)), _NormalScale_FurOffset_FurLength.x);
    half3 n = normalize(
        normal_tangent.x * tangent_world +
        normal_tangent.y * binormal_world +
        normal_tangent.z * normal_world
    );
    float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
    pos_world += n * layer * _NormalScale_FurOffset_FurLength.y;
    o.pos_world = pos_world;
    o.vertex = UnityWorldToClipPos(pos_world);

    half3 view_dir = normalize(UnityWorldSpaceViewDir(pos_world));
    half3 light_dir = normalize(UnityWorldSpaceLightDir(pos_world));
    half3 h_dir = normalize(light_dir + view_dir);
    half3 shiftN = tex2Dlod(_ShiftTex, half4(o.uv.xy, 0.0, 0.0)).r * n;
    binormal_world = -binormal_world;
    half3 t1 = normalize(binormal_world + _Shifts_SpecularWidths.x * shiftN);
    half3 t2 = normalize(binormal_world + _Shifts_SpecularWidths.y * shiftN);
    fixed2 ndotl = saturate(fixed2(DotClamped(light_dir, n), DotClamped(binormal_world, light_dir)) + _KdKsExpoure.zz);
    fixed ndotv = clamp(dot(binormal_world, view_dir), 0.001, 1.0);
    fixed ndoth = DotClamped(binormal_world, h_dir);
    fixed ldoth = clamp(dot(light_dir, h_dir), 0.001, 1.0);
    fixed t1doth = dot(t1, h_dir);
    fixed t2doth = dot(t2, h_dir);
    half fresnel = Pow5(1.0 - ndotl.y);
    half g = min(1.0, min(2.0 * ndotv * ndoth / ldoth, 2.0 * ndoth * ndotl.x / ldoth));
    half dirAtten1 = smoothstep(_Shifts_SpecularWidths.z, 0, t1doth);
    half dirAtten2 = smoothstep(_Shifts_SpecularWidths.w, 0, t2doth);
    half3 d1 = pow(t1doth * t1doth, _Exponents_SpecStrengths.x * 200) * dirAtten1 * _SpecColor1 * _Exponents_SpecStrengths.z;
    half3 d2 = pow(t2doth * t2doth, _Exponents_SpecStrengths.y * 200) * dirAtten2 * _SpecColor2 * _Exponents_SpecStrengths.w;
    half3 df = (d1 + d2) * _SpecularColor;
    o.specular = fresnel * g * df * _KdKsExpoure.y / ndotv;
    o.diffuse = (1.0 - fresnel) * _DiffuseColor * _KdKsExpoure.x * ndotl.x;
    o.irrlight = saturate(ShadeSH9(float4(n, 1.0))) + Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2], unity_LightColor[3], unity_4LightAtten0, pos_world, normal_world);
    half fresnel_ambeint = Pow5(ndotv);
    o.ambientDiffuse = 1.0 - fresnel_ambeint;
    o.ambientSpecular = fresnel_ambeint * df * 0.25 / (ndotv * 0.6 * 0.6);
    o.v_reflect = reflect(view_dir, n);
    TRANSFER_SHADOW(o);

    return o;
}

fixed4 frag (v2f i, fixed layer)
{
    fixed baseShape = tex2D(_ShapeTex, i.uv.xy).r;
    fixed furShape = tex2D(_ShapeTex, i.uv.zw).g * _NormalScale_FurOffset_FurLength.z * (1.0 - baseShape);
    fixed shape = furShape - baseShape;
    // shape *= e;
    fixed layer2 = layer * layer;
    shape = step(layer2, shape);
    shape *= 1 - layer2; 
    fixed3 albedo = tex2D(_Albedo, i.uv.xy);
    UNITY_LIGHT_ATTENUATION(atten, i, i.pos_world);
    fixed3 col = (i.diffuse * albedo + i.specular) * _LightColor0.rgb * atten;
    fixed3 ambient = _AmbientColor * texCUBE(_AmbientTex, normalize(i.v_reflect)).rgb;
    col += (albedo * i.ambientDiffuse + i.ambientSpecular) * ambient;
    col += albedo * i.irrlight;
    return fixed4(col * pow(layer, _AO), shape);
}
#endif