Shader "WhitePetal/Lambert"
{
    Properties
    {
        _Albedo ("Albedo", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 4)) = 1.0
        [VectorRange(0.31830989, 8, 0.25, 8, 0.0, 1.0, 0.001, 1.0)]_KdKsExpoureSmoothness("漫反射强度_镜面反射强度_曝光强度_光滑度", Vector) = (0.31830989, 0.25, 0.0, 0.6)
        _AmbientColor("Ambient Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags{ "RenderMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"
            #include "../Shaders/Librays/ShaderUtil.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 normal_world : TEXCOORD1;
                half3 tangent_world : TEXCOORD2;
                half3 binormal_world : TEXCOORD3;
                half3 pos_world : TEXCOORD4;
                fixed3 vertexLight : TEXCOORD5;
                SHADOW_COORDS(6)
            };

            #include "../Shaders/Librays/TransformLibrary.cginc"

            sampler2D _Albedo, _NormalMap;
            float4 _Albedo_ST;
            fixed3 _DiffuseColor, _SpecularColor, _AmbientColor;
            half _NormalScale;
            half4 _KdKsExpoureSmoothness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _Albedo);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.tangent_world = UnityObjectToWorldDir(v.tangent);
                o.binormal_world = cross(o.normal_world, o.tangent_world) * v.tangent.w * unity_WorldTransformParams.w;
                o.vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2], unity_LightColor[3], unity_4LightAtten0, o.pos_world, o.normal_world);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 albedo = tex2D(_Albedo, i.uv) * _KdKsExpoureSmoothness.x * _DiffuseColor;
                fixed3 specular = _SpecularColor * _KdKsExpoureSmoothness.y;
                half3 n = GetNormalWorldFromMap(i, tex2D(_NormalMap, i.uv), _NormalScale);
                half3 v = normalize(UnityWorldSpaceViewDir(i.pos_world));
                half3 l = normalize(UnityWorldSpaceLightDir(i.pos_world));
                half3 h = normalize(l + v);
                fixed ndotl = saturate(DotClamped(n, l) + _KdKsExpoureSmoothness.z);
                fixed ndoth = DotClamped(n, h);
                fixed ndotv = clamp(dot(n, v), 0.001, 1.0);
                fixed fresnel = Pow5(1 - ndotl);
                half ss = _KdKsExpoureSmoothness.w * _KdKsExpoureSmoothness;
                fixed3 brdf = ((1.0 - fresnel) * albedo * ndotl + specular * fresnel * pow(ndoth, ss * 300) * ss / ndotv) * _LightColor0.rgb;
                fresnel = Pow5(1 - ndotv);
                fixed3 ambient = _AmbientColor * albedo;
                ambient += albedo * (i.vertexLight + saturate(ShadeSH9(float4(n, 1.0))));
                return fixed4(brdf + ambient, 1.0);
            }
            ENDCG
        }
    }
}
