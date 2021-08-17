Shader "PostProcess/Mosaicer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _MosaicerFlagTex;
            float4 _MainTex_ST;
            half _MosaicerDensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv0 = floor(i.uv.xy * _MosaicerDensity) + 0.5;
                float2 uv1 = uv0 + fixed2(-1.0, 0.0);
                float2 uv2 = uv0 + fixed2(1.0, 0.0);
                float2 uv3 = uv0 + fixed2(0.0, -1.0);
                float2 uv4 = uv0 + fixed2(0.0, 1.0);
                half _MosaicerDensity_Inv = 1.0 / _MosaicerDensity;
                uv0 = uv0 * _MosaicerDensity_Inv;
                uv1 = uv1 * _MosaicerDensity_Inv;
                uv2 = uv2 * _MosaicerDensity_Inv;
                uv3 = uv3 * _MosaicerDensity_Inv;
                uv4 = uv4 * _MosaicerDensity_Inv;
                half flag = tex2D(_MosaicerFlagTex, uv0).g;
                flag += tex2D(_MosaicerFlagTex, uv1).g;
                flag += tex2D(_MosaicerFlagTex, uv2).g;
                flag += tex2D(_MosaicerFlagTex, uv3).g;
                flag += tex2D(_MosaicerFlagTex, uv4).g;
                flag += tex2D(_MosaicerFlagTex, i.uv.xy).g;
                // float2 uv0 = floor(i.uv.xy * _MosaicerDensity + 0.5) / _MosaicerDensity;
                fixed4 mosic = tex2D(_MainTex, uv0);
                flag = step(0.1, flag);
                // flag = step(0.5, flag);
                return fixed4(mosic.rgb, flag);
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _MosaicerFlagTex;
            float4 _MainTex_ST;
            half _MosaicerDensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv0 = floor(i.uv.xy * _MosaicerDensity) + 0.5;
                float2 uv1 = uv0 + fixed2(-1.0, 0.0);
                float2 uv2 = uv0 + fixed2(1.0, 0.0);
                float2 uv3 = uv0 + fixed2(0.0, -1.0);
                float2 uv4 = uv0 + fixed2(0.0, 1.0);
                half _MosaicerDensity_Inv = 1.0 / _MosaicerDensity;
                uv0 = uv0 * _MosaicerDensity_Inv;
                uv1 = uv1 * _MosaicerDensity_Inv;
                uv2 = uv2 * _MosaicerDensity_Inv;
                uv3 = uv3 * _MosaicerDensity_Inv;
                uv4 = uv4 * _MosaicerDensity_Inv;
                half flag = tex2D(_MainTex, uv0).a;
                flag += tex2D(_MainTex, uv1).a;
                flag += tex2D(_MainTex, uv2).a;
                flag += tex2D(_MainTex, uv3).a;
                flag += tex2D(_MainTex, uv4).a;
                flag += tex2D(_MainTex, i.uv.xy).a;
                // float2 uv0 = floor(i.uv.xy * _MosaicerDensity + 0.5) / _MosaicerDensity;
                fixed4 mosic = tex2D(_MainTex, uv0);
                flag = saturate(flag);
                // flag = step(0.5, flag);
                return fixed4(mosic.rgb, flag);
            }
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _MosaicerFlagTex, _MoisicTex;
            float4 _MainTex_ST;
            half _MosaicerDensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 mosic = tex2D(_MoisicTex, i.uv.xy);
                fixed flag = mosic.a;
                return fixed4(col.rgb * (1.0 - flag) + mosic.rgb * flag, col.a);
            }
            ENDCG
        }
    }
}
