﻿Shader "PBR/PBR_BRDF_LUT"
{
    Properties
    {
        [NoScaleOffset]_LUT("LUT", 2D) = "wihte" {}
        _Albedo ("Albedo", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [NoScaleOffset]_NormalTex("Normal Map", 2d) = "bump" {}
        [NoScaleOffset] _ParallxTex("ParallxTex", 2D) = "black" {}
        [VectorRange(0.31830989, 8, 0.25, 8, 0.0, 1.0, 0.0, 0.08)]_KdKsExpoureParalxScale("漫反射强度_镜面反射强度_曝光强度_视差强度", Vector) = (0.31830989, 0.25, 0.0, 0.04)
        [NoScaleOffset]_MRATex("Metallic(R) Roughness(G) AO(B)", 2D) = "white" {}
        [VectorRange(0.0, 1.0, 0.01, 1.0, 0.0, 1.0)]_MetallicRoughnessAO("Metallic_Roughness_AO", Vector) = (0.0, 0.8, 1.0)
        _Fresnel("Fresnel0", Color) = (0.04, 0.04, 0.04, 1)
        _DetilTex("Detil", 2D) = "black" {}
        _DetilColor("Detil Color", Color) = (1.0, 1.0, 1.0, 1.0) 
        [NoScaleOffset]_DetilNormalTex("Detil Normal Map", 2D) = "bump" {}
        [VectorRange(0.0, 2.0, 0.0, 2.0)]_NormalScales("MainNormalScale_DetilNormalScale", Vector) = (1.0, 1.0, 0.0, 0.0)
        [NoScaleOffset]_AmbientTex("Ambient Tex", Cube) = "white" {}
        _AmbientColor("Ambient Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGINCLUDE
        #pragma target 3.5
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
            half4 tangent : TANGENT;
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
            half3 view_tangent : TEXCOORD5;
        };

        #include "../Shaders/Librays/TransformLibrary.cginc"

        sampler2D _LUT, _Albedo, _NormalTex, _DetilTex, _DetilNormalTex, _MRATex, _ParallxTex;
        float4 _Albedo_ST, _DetilTex_ST;
        samplerCUBE _AmbientTex;

        fixed3 _DiffuseColor, _DetilColor, _Fresnel, _AmbientColor, _SpecularColor;
        fixed3 _MetallicRoughnessAO;
        fixed2 _NormalScales;
        half4 _KdKsExpoureParalxScale;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv.xy = TRANSFORM_TEX(v.uv, _Albedo); // main map
            o.uv.zw = TRANSFORM_TEX(v.uv, _DetilTex); // detil map
            o.normal_world = UnityObjectToWorldNormal(v.normal);
            o.tangent_world = UnityObjectToWorldDir(v.tangent);
            o.binormal_world = cross(o.normal_world, o.tangent_world) * v.tangent.w;
            o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
            o.view_tangent = GetTangentSpaceViewDir(v.tangent, v.normal, v.vertex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            half2 parallxOffset = GetParallxOffset(tex2D(_ParallxTex, i.uv.xy).r, normalize(i.view_tangent), _KdKsExpoureParalxScale.w);
            i.uv += half4(parallxOffset, parallxOffset);
            fixed4 detil = tex2D(_DetilTex, i.uv.zw);
            fixed detilMask = detil.a;
            half3 n = GetBlendNormalWorldFromMap(i, tex2D(_NormalTex, i.uv.xy), tex2D(_DetilNormalTex, i.uv.zw), _NormalScales.x, _NormalScales.y, detilMask);

            half3 v = normalize(UnityWorldSpaceViewDir(i.pos_world));
            half3 l = normalize(UnityWorldSpaceLightDir(i.pos_world));
            half3 h = normalize(l + v);
            fixed ndotl = saturate(DotClamped(l, n) + _KdKsExpoureParalxScale.z);
            fixed ndotv = max(0.001, dot(v, n));
            fixed ndoth = DotClamped(h, n);
            fixed ldoth = DotClamped(l, h);

            half3 MRA = tex2D(_MRATex, i.uv.xy).rgb;
            half roughness = _MetallicRoughnessAO.y * MRA.g;
            half oneMinusMetallic = 1.0 - MRA.r * _MetallicRoughnessAO.x;
            half oneMinusRoughness = 1.0 - roughness;
            half ao = saturate(1.0 - (1.0 - MRA.b) * _MetallicRoughnessAO.z);

            half3 f = _Fresnel + (1.0 - _Fresnel) * tex2D(_LUT, half2(ndotl, 1)).r;
            half g = 1.0 / tex2D(_LUT, half2(ndoth, ldoth)).g - 1.0;
            g = saturate(min(ndotv * g, ndotl * g));
            half d = 1.0 / tex2D(_LUT, half2(roughness, ndoth)).b - 1.0;
            
            half3 albedo = lerp(_DiffuseColor * tex2D(_Albedo, i.uv.xy).rgb, _DetilColor * tex2D(_DetilTex, i.uv.zw).rgb, detilMask) * _KdKsExpoureParalxScale.x;
            half3 specular = _SpecularColor * _KdKsExpoureParalxScale.y;

            fixed3 brdfCol = ((1 - f) * oneMinusMetallic * albedo * ndotl + specular * f * g * d / ndotv) * _LightColor0.rgb;

            f = _Fresnel + (1.0 - _Fresnel) * tex2D(_LUT, half2(ndotv, 1)).r;
            fixed3 ambient = _AmbientColor * texCUBE(_AmbientTex, reflect(v, n)).rgb;
            fixed3 amibientCol = (albedo * (1.0 - f) + saturate(specular * f * 0.25 / (ndotv * roughness * roughness))) * ambient;

            fixed4 col = fixed4((brdfCol + amibientCol) * ao, 1.0);
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

        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert_shadow
            #pragma fragment frag_shadow

            struct a2v_shadow
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            struct v2f_shadow
            {
                float4 pos : SV_POSITION;
            };


            v2f_shadow vert_shadow(a2v_shadow v)
            {
                v2f_shadow o;
                o.pos = UnityClipSpaceShadowCasterPos(v.vertex, v.normal);
                o.pos = UnityApplyLinearShadowBias(o.pos); // 应用 ShadowMap 偏移
                return o;
            }

            fixed4 frag_shadow(v2f_shadow i) : SV_TARGET
            {
                // 前向渲染 自动写入深度信息
                return fixed4(0, 0, 0, 0);
            }
            ENDCG
        }
    }
    CustomEditor "BRDF_LUT_Inspector"
}