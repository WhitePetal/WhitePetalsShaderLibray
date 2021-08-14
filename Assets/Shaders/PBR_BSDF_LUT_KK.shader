Shader "PBR/PBR_BSDF_LUT_KK"
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
        _AmbientColor("Ambient Color", Color) = (0.3, 0.3, 0.3, 1.0)
        _AmbientSpecStrength("Ambient Specular Strength", Range(0, 1.0)) = 0.5
        _ShiftTex("ShiftTex", 2D) = "white" {}
        [VectorRange(0, 10.0, 1, 10.0, 0, 10.0, 1, 10.0, 0, 1.0, 0, 0.001, 0, 1.0, 0, 0.001)] _Shifts_SpecularWidths("Shift1_Shift2_SpecularWidth1_SpecularWidth2", Vector) = (0.1, 0.1, -0.5, -0.5)
        [VectorRange(0.01, 1, 0.01, 1, 0, 8, 0, 8)]_Exponents_SpecStrengths("Exponent1_Exponent2_SpecStrength1_SpecStrength2", Vector) = (0.3, 0.3, 1.0, 1.0)
        _SpecColor1("SpecColor1", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecColor2("SpecColor2", Color) = (1.0, 1.0, 1.0, 1.0)
        _PointLightColor("Point Light Color", Color) = (0.5492168, 0.6934489, 0.9622642, 1.0)
        [ObjPositionVector]_PointLightPos("Point Light Pos", Vector) = (1.0, .0, .0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

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
                float2 texcoord : TEXCOORD0;
                #ifdef LIGHTMAP_ON
                float2 texcoord1 : TEXCOORD1;
                #endif
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
                half4 point_light_params : TEXCOORD6;
                #ifdef VERTEXLIGHT_ON
                fixed3 vertexLight : TEXCOORD7;
                #endif
                #ifdef LIGHTMAP_ON
                float2 lightMapUV : TEXCOORD7;
                #endif
                SHADOW_COORDS(8)
            };

            #include "../Shaders/Librays/TransformLibrary.cginc"

            sampler2D _LUT, _Albedo, _NormalTex, _DetilTex, _DetilNormalTex, _MRATex, _ParallxTex, _ShiftTex;
            float4 _Albedo_ST, _DetilTex_ST;
            samplerCUBE _AmbientTex;

            fixed3 _DiffuseColor, _DetilColor, _Fresnel, _AmbientColor, _SpecularColor, _SpecColor1, _SpecColor2, _PointLightColor;
            fixed3 _MetallicRoughnessAO;
            fixed2 _NormalScales;
            half4 _KdKsExpoureParalxScale;
            half4 _Shifts_SpecularWidths;
            half4 _Exponents_SpecStrengths;
            half3 _PointLightPos;
            fixed _AmbientSpecStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _Albedo); // main map
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetilTex); // detil map
                o.normal_world = UnityObjectToWorldDir(v.normal);
                o.tangent_world = UnityObjectToWorldDir(v.tangent);
                o.binormal_world = cross(o.normal_world, o.tangent_world) * v.tangent.w * unity_WorldTransformParams.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view_tangent = GetTangentSpaceViewDir(v.tangent, v.normal, v.vertex);
                o.point_light_params.xyz = _PointLightPos - v.vertex.xyz;
                o.point_light_params.w = 1.0 / max(dot(o.point_light_params.xyz, o.point_light_params.xyz), 0.001);
                o.point_light_params.xyz = mul(unity_ObjectToWorld, float4(_PointLightPos, 1.0)) - o.pos_world;
                #ifdef VERTEXLIGHT_ON
                o.vertexLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2], unity_LightColor[3], unity_4LightAtten0, o.pos_world, o.normal_world);
                #endif
                #ifdef LIGHTMAP_ON
                o.lightMapUV = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 parallxOffset = GetParallxOffset(tex2D(_ParallxTex, i.uv.xy).r, normalize(i.view_tangent), _KdKsExpoureParalxScale.w);
                i.uv += half4(parallxOffset, parallxOffset);
                fixed4 detil = tex2D(_DetilTex, i.uv.zw);
                fixed detilMask = detil.a;
                half3 n = GetBlendNormalWorldFromMap(i, tex2D(_NormalTex, i.uv.xy), tex2D(_DetilNormalTex, i.uv.zw), _NormalScales.x, _NormalScales.y, detilMask);
                half3 shiftN = tex2D(_ShiftTex, i.uv.xy).r * n;
                half3 binormal = -i.binormal_world;
                half3 t1 = normalize(binormal + _Shifts_SpecularWidths.x * shiftN);
                half3 t2 = normalize(binormal + _Shifts_SpecularWidths.y * shiftN);
                half3 v = normalize(UnityWorldSpaceViewDir(i.pos_world));
                half3 l = normalize(UnityWorldSpaceLightDir(i.pos_world));
                half3 h = normalize(l + v);
                fixed2 ndotl = saturate(fixed2(DotClamped(l, n), DotClamped(l, binormal)) + _KdKsExpoureParalxScale.zz);
                fixed ndotv = clamp(dot(v, binormal), 0.001, 1.0);
                fixed ndoth = DotClamped(h, n);
                fixed ldoth = DotClamped(l, h);
                fixed t1doth = dot(t1, h);
                fixed t2doth = dot(t2, h);

                half3 MRA = tex2D(_MRATex, i.uv.xy).rgb;
                half roughness = _MetallicRoughnessAO.y * MRA.g;
                half oneMinusMetallic = 1.0 - MRA.r * _MetallicRoughnessAO.x;
                half oneMinusRoughness = 1.0 - roughness;
                half ao = saturate(1.0 - (1.0 - MRA.b) * _MetallicRoughnessAO.z);

                half3 f = _Fresnel + (1.0 - _Fresnel) * tex2D(_LUT, half2(ndotl.y, 1)).r;
                half g = 1.0 / tex2D(_LUT, half2(ndoth, ldoth)).g - 1.0;
                g = min(1.0, (min(ndotv * g, ndotl.x * g)));
                half d = 1.0 / tex2D(_LUT, half2(roughness, ndoth)).b + 1.0;
                half dirAtten1 = smoothstep(_Shifts_SpecularWidths.z, 0.0, t1doth);
                half dirAtten2 = smoothstep(_Shifts_SpecularWidths.w, 0.0, t2doth);
                
                half3 albedo = lerp(_DiffuseColor * tex2D(_Albedo, i.uv.xy).rgb, _DetilColor * tex2D(_DetilTex, i.uv.zw).rgb, detilMask) * _KdKsExpoureParalxScale.x;
                half3 specular = lerp(_SpecularColor * _KdKsExpoureParalxScale.y, albedo, 1.0 - oneMinusMetallic);
                albedo *= oneMinusMetallic;

                half3 d1 = tex2D(_LUT, half2(t1doth * t1doth, _Exponents_SpecStrengths.x)).a * dirAtten1 * _SpecColor1 * _Exponents_SpecStrengths.z;
                half3 d2 = tex2D(_LUT, half2(t2doth * t2doth, _Exponents_SpecStrengths.y)).a * dirAtten2 * _SpecColor2 * _Exponents_SpecStrengths.w;
                half3 df = d1 + d2;

                UNITY_LIGHT_ATTENUATION(atten, i, i.pos_world);
                fixed3 brdfCol = ((1 - f) * albedo * ndotl.x + specular * f * g * d * df / ndotv) * _LightColor0.rgb * atten;
                brdfCol += _PointLightColor * i.point_light_params.w * saturate(dot(normalize(i.point_light_params.xyz), n)) * albedo;

                fixed3 amibientCol;
                fixed3 ambientDiff;
                fixed3 ambientSpec = texCUBE(_AmbientTex, reflect(-v, n) + i.pos_world).rgb * _KdKsExpoureParalxScale.y * _AmbientSpecStrength;
                f = _Fresnel + (1.0 - _Fresnel) * tex2D(_LUT, half2(ndotv, 1)).r;
                #ifndef LIGHTMAP_ON
                ambientDiff = _AmbientColor;
                    #ifdef VERTEXLIGHT_ON
                    ambientDiff += (i.vertexLight + saturate(ShadeSH9(float4(n, 1.0))));
                    #else
                    ambientDiff += (saturate(ShadeSH9(float4(n, 1.0))));
                    #endif
                #endif
                #ifdef LIGHTMAP_ON
                ambientDiff = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightMapUV));
                    #ifdef DIRLIGHTMAP_COMBINED
                    float4 lightmapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, i.lightMapUV);
                    ambientDiff = DecodeDirectionalLightmap(ambientDiff, lightmapDirection, n);
                    #endif
                #endif
                amibientCol = (albedo * ambientDiff + specular * ambientSpec * f * 0.25 / (roughness * roughness));

                fixed4 col = fixed4((brdfCol + amibientCol) * ao, 1.0);
                return col;
            }

            ENDCG
        }

        Pass
        {
            Tags{"LightMode"="ForwardAdd"}
            Blend One One, Zero One
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert_add
            #pragma fragment frag_add
            #pragma multi_compile_fwdadd

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
                SHADOW_COORDS(6)
            };

            #include "../Shaders/Librays/TransformLibrary.cginc"

            sampler2D _LUT, _Albedo, _NormalTex, _DetilTex, _DetilNormalTex, _MRATex, _ParallxTex, _ShiftTex;
            float4 _Albedo_ST, _DetilTex_ST;
            samplerCUBE _AmbientTex;

            fixed3 _DiffuseColor, _DetilColor, _Fresnel, _AmbientColor, _SpecularColor, _SpecColor1, _SpecColor2;
            fixed3 _MetallicRoughnessAO;
            fixed2 _NormalScales;
            half4 _KdKsExpoureParalxScale;
            half4 _Shifts_SpecularWidths;
            half4 _Exponents_SpecStrengths;

            v2f vert_add (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _Albedo); // main map
                o.uv.zw = TRANSFORM_TEX(v.uv, _DetilTex); // detil map
                o.normal_world = UnityObjectToWorldDir(v.normal);
                o.tangent_world = UnityObjectToWorldDir(v.tangent);
                o.binormal_world = -cross(o.normal_world, o.tangent_world) * v.tangent.w * unity_WorldTransformParams.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view_tangent = GetTangentSpaceViewDir(v.tangent, v.normal, v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag_add (v2f i) : SV_Target
            {
                half2 parallxOffset = GetParallxOffset(tex2D(_ParallxTex, i.uv.xy).r, normalize(i.view_tangent), _KdKsExpoureParalxScale.w);
                i.uv += half4(parallxOffset, parallxOffset);
                fixed4 detil = tex2D(_DetilTex, i.uv.zw);
                fixed detilMask = detil.a;
                half3 n = GetBlendNormalWorldFromMap(i, tex2D(_NormalTex, i.uv.xy), tex2D(_DetilNormalTex, i.uv.zw), _NormalScales.x, _NormalScales.y, detilMask);
                half3 shiftN = tex2D(_ShiftTex, i.uv.xy).r * n;
                half3 t1 = normalize(-i.binormal_world + _Shifts_SpecularWidths.x * shiftN);
                half3 t2 = normalize(-i.binormal_world + _Shifts_SpecularWidths.y * shiftN);
                half3 v = normalize(UnityWorldSpaceViewDir(i.pos_world));
                half3 l = normalize(UnityWorldSpaceLightDir(i.pos_world));
                half3 h = normalize(l + v);
                fixed ndotl = saturate(DotClamped(l, n) + _KdKsExpoureParalxScale.z);
                fixed ndotv = max(0.001, dot(v, n));
                fixed ndoth = DotClamped(h, n);
                fixed ldoth = DotClamped(l, h);
                fixed t1doth = dot(t1, h);
                fixed t2doth = dot(t2, h);

                half3 MRA = tex2D(_MRATex, i.uv.xy).rgb;
                half roughness = _MetallicRoughnessAO.y * MRA.g;
                half oneMinusMetallic = 1.0 - MRA.r * _MetallicRoughnessAO.x;
                half oneMinusRoughness = 1.0 - roughness;
                half ao = saturate(1.0 - (1.0 - MRA.b) * _MetallicRoughnessAO.z);

                half3 f = _Fresnel + (1.0 - _Fresnel) * tex2D(_LUT, half2(ndotl, 1)).r;
                half g = 1.0 / tex2D(_LUT, half2(ndoth, ldoth)).g - 1.0;
                g = saturate(min(ndotv * g, ndotl * g));
                half d = 1.0 / tex2D(_LUT, half2(roughness, ndoth)).b + 1.0;
                half dirAtten1 = smoothstep(_Shifts_SpecularWidths.z, 0, t1doth);
                half dirAtten2 = smoothstep(_Shifts_SpecularWidths.w, 0, t2doth);

                half3 d1 = tex2D(_LUT, half2(t1doth * t1doth, _Exponents_SpecStrengths.x)).a * dirAtten1 * _SpecColor1 * _Exponents_SpecStrengths.z;
                half3 d2 = tex2D(_LUT, half2(t2doth * t2doth, _Exponents_SpecStrengths.y)).a * dirAtten2 * _SpecColor2 * _Exponents_SpecStrengths.w;
                
                half3 albedo = lerp(_DiffuseColor * tex2D(_Albedo, i.uv.xy).rgb, _DetilColor * tex2D(_DetilTex, i.uv.zw).rgb, detilMask) * _KdKsExpoureParalxScale.x;
                half3 specular = lerp(_SpecularColor * _KdKsExpoureParalxScale.y, albedo, 1.0 - oneMinusMetallic);
                albedo *= oneMinusMetallic;

                UNITY_LIGHT_ATTENUATION(atten, i, i.pos_world);
                fixed3 brdfCol = ((1 - f) * albedo * ndotl + specular * f * g * d * (d1 + d2) / ndotv) * _LightColor0.rgb * atten;
                // fwdadd 不需要计算间接光

                fixed4 col = fixed4(brdfCol * ao, 1);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert_shadow
            #pragma fragment frag_shadow
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

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

        Pass
        {
            Tags{"LightMode"="Meta"}
            Cull Off
            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta
            #include "UnityCG.cginc"
            #include "UnityMetaPass.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                // half3 normal_world : TEXCOORD1;
                // half3 tangent_world : TEXCOORD2;
                // half3 binormal_world : TEXCOORD3;
                // float3 pos_world : TEXCOORD4;
            };

            // #include "../Shaders/Librays/TransformLibrary.cginc"

            sampler2D _Albedo, _NormalTex, _DetilTex, _DetilNormalTex, _MRATex;
            float4 _Albedo_ST, _DetilTex_ST;
            samplerCUBE _AmbientTex;

            fixed3 _DiffuseColor, _DetilColor, _Fresnel, _AmbientColor, _SpecularColor, _PointLightColor;
            fixed3 _MetallicRoughnessAO;
            fixed2 _NormalScales;
            half4 _KdKsExpoureParalxScale;

            v2f vert_meta(appdata v)
            {
                v2f o;
                v.vertex.xy = v.texcoord1 * unity_LightmapST.xy + unity_LightmapST.zw;
                v.vertex.z = v.vertex.z > 0 ? 0.0001 : 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _Albedo); // main map
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetilTex); // detil map
                return o;
            }

            fixed4 frag_meta(v2f i) : SV_TARGET0
            {
                UnityMetaInput IN;
                half3 MRA = tex2D(_MRATex, i.uv.xy).rgb;
                half roughness = _MetallicRoughnessAO.y * MRA.g;
                half oneMinusMetallic = 1.0 - MRA.r * _MetallicRoughnessAO.x;
                fixed4 detil = tex2D(_DetilTex, i.uv.zw);
                fixed detilMask = detil.a;
                half3 albedo = lerp(_DiffuseColor * tex2D(_Albedo, i.uv.xy).rgb, _DetilColor * tex2D(_DetilTex, i.uv.zw).rgb, detilMask) * _KdKsExpoureParalxScale.x;
                half3 specular = lerp(_SpecularColor * _KdKsExpoureParalxScale.y, albedo, 1.0 - oneMinusMetallic);
                albedo *= oneMinusMetallic;
                IN.Albedo = albedo;
                IN.SpecularColor = specular;
                IN.Albedo += IN.SpecularColor * roughness * roughness * 0.5;
                IN.Emission = 0.0;
                return UnityMetaFragment(IN);
            }

            ENDCG
        }
    }
    CustomEditor "BSDF_LUT_KK_Inspector"
}
