Shader "Unlit/PBR_BRDF"
{
    Properties
    {
        [NoScaleOffset]_LUT("LUT", 2D) = "wihte" {}
        _Albedo ("Albedo", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [NoScaleOffset]_NormalTex("Normal Map", 2d) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 2)) = 1
        _DetilTex("Detil", 2D) = "black" {}
        [NoScaleOffset]_DetilMask("Detil", 2D) = "black" {}
        _DetilColor("Detil Color", Color) = (1.0, 1.0, 1.0, 1.0) 
        [NoScaleOffset]_DetilNormalTex("Detil Normal Map", 2D) = "bump" {}
        _DetilNormalScale("Detil Normal Scale", Range(0, 2)) = 1
        _MRATex("Metallic(R) Roughness(G) AO(B)", 2D) = "white" {}
        _Metallic("Metallic", Range(0, 1)) = 1
        _Roughness("Roughness", Range(0, 1)) = 1
        _Fresnel("Fresnel0", Color) = (0.04, 0.04, 0.04, 1)
        [NoScaleOffset]_AmbientTex("Ambient Tex", Cube) = "white" {}
        _AmbientColor("Ambient Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _AO("AO", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGINCLUDE
        #include "UnityCG.cginc"
        #include "UnityShaderVariables.cginc"
        #include "UnityPBSLighting.cginc"
        #include "AutoLight.cginc"

        #define PI 3.1415926
        #define PI_INVERSE 0.31830989

        struct appdata
        {
            float4 vertex : POSITION;
            half3 normal : NORMAL;
            half3 tangent : TANGENT;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float4 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            half3 normal_world : TEXCOORD1;
            half3 tangent_world : TEXCOORD2;
            half3 binormal_world : TEXCOORD3;
            float3 pos_world : TEXCOORD4;
        };

        sampler2D _LUT, _Albedo, _NormalTex, _DetilTex, _DetilMask, _DetilNormalTex, _MRATex;
        float4 _Albedo_ST, _DetilTex_ST;
        samplerCUBE _AmbientTex;

        fixed3 _DiffuseColor, _DetilColor, _Fresnel, _AmbientColor, _SpecularColor;
        fixed _NormalScale, _DetilNormalScale, _Metallic, _Roughness, _AO;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv.xy = TRANSFORM_TEX(v.uv, _Albedo); // main map
            o.uv.zw = TRANSFORM_TEX(v.uv, _DetilTex); // detil map
            o.normal_world = UnityObjectToWorldDir(v.normal);
            o.tangent_world = UnityObjectToWorldDir(v.tangent);
            o.binormal_world = cross(o.normal_world, o.tangent_world);
            o.pos_world = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            fixed detilMask = tex2D(_DetilMask, i.uv.zw).r;
            half3 normal_tangent = BlendNormals(UnpackScaleNormal(tex2D(_NormalTex, i.uv.xy), _NormalScale),
            lerp(half3(0.0, 0.0, 1.0), UnpackScaleNormal(tex2D(_DetilNormalTex, i.uv.zw), _DetilNormalScale), detilMask));
            half3 n = normalize(
                normal_tangent.x * i.tangent_world +
                normal_tangent.y * i.binormal_world +
                normal_tangent.z * i.normal_world
            );
            half3 v = normalize(UnityWorldSpaceViewDir(i.pos_world));
            half3 l = normalize(UnityWorldSpaceLightDir(i.pos_world));
            half3 h = normalize(l + v);
            fixed ci = max(saturate(dot(l, n)), 0.0001);
            fixed co = max(saturate(dot(v, n)), 0.0001);
            fixed ch = saturate(dot(h, n));

            fixed3 MRA = tex2D(_MRATex, i.uv.xy).rgb;
            fixed roughness =max(_Roughness * MRA.g, 0.0001);
            fixed metallic = _Metallic;
            fixed ao = _AO * MRA.b;

            float d = 1.0 / tex2D(_LUT, float2(roughness, ch)).g - 1.0; 
            float3 f = _Fresnel + (1.0 - _Fresnel) * tex2D(_LUT, float2(ci, 1)).r;
            float g = tex2D(_LUT, float2(roughness, ci)).a * tex2D(_LUT, float2(roughness, co)).a;
            
            fixed3 albedo = lerp(_DiffuseColor * tex2D(_Albedo, i.uv.xy), _DetilColor * tex2D(_DetilTex, i.uv.zw).rgb, detilMask);
            fixed3 specular = _SpecularColor;

            fixed3 brdfCol = ((1 - f) * (1 - metallic) * albedo * PI_INVERSE + specular * d * f * g / (4 * ci * co)) * _LightColor0.rgb * ci;

            fixed4 col = fixed4(brdfCol, 1.0);
            return col;
        }
        ENDCG

        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            ENDCG
        }
    }
}
