Shader "WhitePetal/Fur"
{
    Properties
    {
        _ShapeTex("BaseShape(R) FurShape(G)", 2D) = "black" {}
        _Albedo("Albedo Tex", 2D) = "white" {}
        _DiffuseColor("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        [VectorRange(0.31830989, 8, 0.25, 8, 0.0, 1.0)]_KdKsExpoure("漫反射强度_镜面反射强度_曝光强度_视差强度", Vector) = (0.31830989, 0.25, 0.0, 1.0)
        _NormalMap("Normal Map", 2D) = "bump" {}
        _ShiftTex("ShiftTex", 2D) = "white" {}
        [VectorRange(0.0, 8.0, 0.01, 4.0, 1.0, 5.0)] _NormalScale_FurOffset_FurLength("NormalScale_FurOffset_FurLength", Vector) = (1.0, 1.0, 1.0, 0.0)
        _AO("AO", Range(0, 1)) = 0.8
        _Noise("Noise", Range(0, 20)) = 1

        [VectorRange(0, 10.0, 1, 10.0, 0, 10.0, 1, 10.0, 0, 1.0, 0, 0.001, 0, 1.0, 0, 0.001)] _Shifts_SpecularWidths("Shift1_Shift2_SpecularWidth1_SpecularWidth2", Vector) = (0.1, 0.1, -0.5, -0.5)
        [VectorRange(0.01, 1, 0.01, 1, 0, 8, 0, 8)]_Exponents_SpecStrengths("Exponent1_Exponent2_SpecStrength1_SpecStrength2", Vector) = (0.3, 0.3, 1.0, 1.0)
        _SpecColor1("SpecColor1", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecColor2("SpecColor2", Color) = (1.0, 1.0, 1.0, 1.0)

        [NoScaleOffset]_AmbientTex("Ambient Tex", Cube) = "white" {}
        _AmbientColor("Ambient Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" "RenderType"="Opaque" "Queue"="Geometry+100"}
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert0
            #pragma fragment frag0
            #include "../Shaders/Librays/FurLibrary.cginc"

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
            #pragma multi_compile_fwdbase
            #pragma vertex vert1
            #pragma fragment frag1
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert1(appdata v)
            {
                return vert(v, 0.1);
            }

            fixed4 frag1(v2f i) : SV_TARGET
            {
                return frag(i, 0.1);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert2
            #pragma fragment frag2
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert2(appdata v)
            {
                return vert(v, 0.2);
            }

            fixed4 frag2(v2f i) : SV_TARGET
            {
                return frag(i, 0.2);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert3
            #pragma fragment frag3
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert3(appdata v)
            {
                return vert(v, 0.3);
            }

            fixed4 frag3(v2f i) : SV_TARGET
            {
                return frag(i, 0.3);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert4
            #pragma fragment frag4
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert4(appdata v)
            {
                return vert(v, 0.4);
            }

            fixed4 frag4(v2f i) : SV_TARGET
            {
                return frag(i, 0.4);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert5
            #pragma fragment frag5
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert5(appdata v)
            {
                return vert(v, 0.5);
            }

            fixed4 frag5(v2f i) : SV_TARGET
            {
                return frag(i, 0.5);
            }
            ENDCG
        }

        
        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert6
            #pragma fragment frag6
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert6(appdata v)
            {
                return vert(v, 0.6);
            }

            fixed4 frag6(v2f i) : SV_TARGET
            {
                return frag(i, 0.6);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert7
            #pragma fragment frag7
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert7(appdata v)
            {
                return vert(v, 0.7);
            }

            fixed4 frag7(v2f i) : SV_TARGET
            {
                return frag(i, 0.7);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert8
            #pragma fragment frag8
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert8(appdata v)
            {
                return vert(v, 0.8);
            }

            fixed4 frag8(v2f i) : SV_TARGET
            {
                return frag(i, 0.8);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert9
            #pragma fragment frag9
            #include "../Shaders/Librays/FurLibrary.cginc"

            v2f vert9(appdata v)
            {
                return vert(v, 0.9);
            }

            fixed4 frag9(v2f i) : SV_TARGET
            {
                return frag(i, 0.9);
            }
            ENDCG
        }

        Pass 
        {
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            Blend Off
            CGPROGRAM
            #pragma vertex vert_shadow
            #pragma fragment frag_shadow
            #pragma target 3.5
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"

            #include "UnityCG.cginc"

            struct a2v_shadow
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
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
    CustomEditor "Fur_Inspector"
}
