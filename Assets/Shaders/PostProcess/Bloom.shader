Shader "PostProcess/Bloom"
{
    Properties {
		_MainTex ("Texture", 2D) = "white" {}
        _BloomTex("BloomTex", 2D) = "white" {}
        _BloomFlagTex("BloomFlagTex", 2D) = "white" {}
	}
    SubShader
    {
        Pass
        {
            ZWrite Off
            ZTest Always
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright

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

            sampler2D _MainTex, _BloomFlagTex;
            float4 _MainTex_ST;
            float4 _BloomFlagTex_ST;

            half luminance(half bloom) {
                half l = bloom;
                l = 1.0 / ((1.0 / l) - 1.0);
                // l *= l;
                return l;
		    }

            v2f vertExtractBright (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 fragExtractBright (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                half val = luminance(tex2D(_BloomFlagTex, i.uv).r);
                col.rgb *= val;
                
                return col;
            }
            ENDCG
        }

        UsePass "PostProcess/GaussianBlur/GaussianBlurPass"

        Pass
        {
            ZWrite Off
            ZTest Always
            CGPROGRAM
            #pragma vertex vert_bloom
            #pragma fragment frag_bloom

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BloomTex;
            float4 _BloomTex_ST;
            fixed4 _BloomColor;


            half luminance(fixed4 color) {
                half l = saturate(1.0 - color.a);
                l = 1.0 / ((1.0 / l) - 1.0);
                return l;
		    }

            v2f vert_bloom (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BloomTex);
                return o;
            }

            half4 frag_bloom (v2f i) : SV_Target
            {
                half3 bloom = tex2D(_BloomTex, i.uv.zw).rgb;
                bloom *= _BloomColor;
                half4 col = tex2D(_MainTex, i.uv.xy);
                col.rgb += bloom;
                return col;
            }
            ENDCG
        }
    }
}
