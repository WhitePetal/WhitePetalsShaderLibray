Shader "PostProcess/DepthOfField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            ZWrite Off
            ZTest Always
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
                half4 uv0 : TEXCOORD1;
                half4 uv1 : TEXCOORD2;
                half4 uv2 : TEXCOORD3;
            };

            sampler2D _MainTex, _MDepthTex;
            float4 _MainTex_ST;
            half2 _GaussBlurOffset;
            half _z_cam, _ms, _N, _s, _Imr, _z_focus;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv0 = o.uv.xyxy + _GaussBlurOffset.xyxy * float4(1, 1, -1, -1);
                o.uv1 = o.uv.xyxy + _GaussBlurOffset.xyxy * float4(2, 2, -2, -2);
                o.uv2 = o.uv.xyxy + _GaussBlurOffset.xyxy * float4(3, 3, -3, -3);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 source = tex2D(_MainTex,  i.uv);
                half depth = tex2D(_MDepthTex, i.uv).a;
                half b = step(depth, _z_focus);
                half3 col = source.rgb * 0.4;
                col += 0.15 * tex2D(_MainTex, i.uv0.xy).rgb;
                col += 0.15 * tex2D(_MainTex, i.uv0.zw).rgb;
                col += 0.10 * tex2D(_MainTex,  i.uv1.xy).rgb;
                col += 0.10 * tex2D(_MainTex, i.uv1.zw).rgb;
                col += 0.05 * tex2D(_MainTex,  i.uv2.xy).rgb;
                col += 0.05 * tex2D(_MainTex, i.uv2.zw).rgb;

                return half4(b * source.rgb + (1.0 - b) * col, source.a);
            }
            ENDCG
        }
    }
}
