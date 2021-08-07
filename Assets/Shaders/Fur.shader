Shader "WhitePetal/Fur"
{
    Properties
    {
        _ShapeTex("BaseShape(R) FurShape(G)", 2D) = "black" {}
        _Albedo("Albedo Tex", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _NormalMap("Normal Map", 2D) = "bump" {}
        _ShiftTex("ShiftTex", 2D) = "white" {}
        [VectorRange(0.0, 8.0, 0.01, 4.0, 1.0, 5.0)] _NormalScale_FurOffset_FurLength("NormalScale_FurOffset_FurLength", Vector) = (1.0, 1.0, 1.0, 0.0)
        _AO("AO", Range(0, 1)) = 0.8
        _Noise("Noise", Range(0, 20)) = 1

        [VectorRange(0, 10.0, 1, 10.0, 0, 10.0, 1, 10.0, 0, 1.0, 0, 0.001, 0, 1.0, 0, 0.001)] _Shifts_SpecularWidths("Shift1_Shift2_SpecularWidth1_SpecularWidth2", Vector) = (0.1, 0.1, -0.5, -0.5)
        [VectorRange(0, 1, 0, 1, 0, 8, 0, 8)]_Exponents_SpecStrengths("Exponent1_Exponent2_SpecStrength1_SpecStrength2", Vector) = (0.3, 0.3, 1.0, 1.0)
        _SpecColor1("SpecColor1", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecColor2("SpecColor2", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        CGINCLUDE
            #pragma target 4.0
            #include "UnityCG.cginc"
            #include "UnityStandardUtils.cginc"
            #include "../Shaders/Librays/ShaderUtil.cginc"

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
            };

            sampler2D _Albedo, _ShapeTex, _NormalMap;
            half4 _Albedo_ST;
            half4 _ShapeTex_ST;
            fixed3 _DiffuseColor, _SpecColor1, _SpecColor2;
            half4 _Shifts_SpecularWidths;
            half4 _Exponents_SpecStrengths;
            half3 _NormalScale_FurOffset_FurLength;
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
                o.vertex = UnityWorldToClipPos(pos_world);

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
                return fixed4(albedo * pow(layer, _AO), shape);
            }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert0
            #pragma fragment frag0

            v2f vert0(appdata v)
            {
                return vert(v, 0.0);
            }

            fixed4 frag0(v2f i) : SV_TARGET
            {
                return frag(i, 0.05);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert0
            #pragma fragment frag0

            v2f vert0(appdata v)
            {
                return vert(v, 0.1);
            }

            fixed4 frag0(v2f i) : SV_TARGET
            {
                return frag(i, 0.1);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert1
            #pragma fragment frag1

            v2f vert1(appdata v)
            {
                return vert(v, 0.2);
            }

            fixed4 frag1(v2f i) : SV_TARGET
            {
                return frag(i, 0.2);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert2
            #pragma fragment frag2

            v2f vert2(appdata v)
            {
                return vert(v, 0.3);
            }

            fixed4 frag2(v2f i) : SV_TARGET
            {
                return frag(i, 0.3);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert3
            #pragma fragment frag3

            v2f vert3(appdata v)
            {
                return vert(v, 0.4);
            }

            fixed4 frag3(v2f i) : SV_TARGET
            {
                return frag(i, 0.4);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert4
            #pragma fragment frag4

            v2f vert4(appdata v)
            {
                return vert(v, 0.5);
            }

            fixed4 frag4(v2f i) : SV_TARGET
            {
                return frag(i, 0.5);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert5
            #pragma fragment frag5

            v2f vert5(appdata v)
            {
                return vert(v, 0.6);
            }

            fixed4 frag5(v2f i) : SV_TARGET
            {
                return frag(i, 0.6);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert6
            #pragma fragment frag6

            v2f vert6(appdata v)
            {
                return vert(v, 0.7);
            }

            fixed4 frag6(v2f i) : SV_TARGET
            {
                return frag(i, 0.7);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert7
            #pragma fragment frag7

            v2f vert7(appdata v)
            {
                return vert(v, 0.8);
            }

            fixed4 frag7(v2f i) : SV_TARGET
            {
                return frag(i, 0.8);
            }
            ENDCG
        }

                Pass
        {
            CGPROGRAM
            #pragma vertex vert8
            #pragma fragment frag8

            v2f vert8(appdata v)
            {
                return vert(v, 0.9);
            }

            fixed4 frag8(v2f i) : SV_TARGET
            {
                return frag(i, 0.9);
            }
            ENDCG
        }
    }
}
