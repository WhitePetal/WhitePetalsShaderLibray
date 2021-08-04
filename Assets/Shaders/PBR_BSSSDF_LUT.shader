Shader "Unlit/PBR_BSSSDF_LUT"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex("tex", 2D) = "white" {}
        _Color("Color", Color) = (1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half3 pos_world : TEXCOORD1;
                half3 normal_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _Tex;
            float4 _MainTex_ST;
            fixed3 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityWorldToClipPos(o.pos_world);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 n = normalize(i.normal_world);
                float dn = length(fwidth(n));
                float dp = length(fwidth(i.pos_world));
                float curve = dp / dn;
                half3 l = normalize(UnityWorldSpaceLightDir(i.pos_world));
                half3 v = normalize(UnityWorldSpaceViewDir(i.pos_world));
                float ndotl = saturate(dot(n, l));
                float ndotv = saturate(dot(n, v));
                fixed3 col = saturate(tex2D(_MainTex, half2(ndotl, ndotl)).rgb * 0.5 + 0.5) * _LightColor0.rgb * tex2D(_Tex, i.uv).rgb * _Color;
                // col += tex2D(_Tex, i.uv).rgb * saturate(ndotl + 0.5) * _LightColor0.rgb * _Color / 3.1415926;
                // col.rgb *=r;
                return fixed4(col, 1.0);
            }
            ENDCG
        }
    }
}
