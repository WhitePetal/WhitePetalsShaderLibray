Shader "PostProcess/AdjustmentHSV"
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half3 _Brightness_Saturation_Contrast; // 亮度、饱和度、对比度

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, i.uv);
                half3 c = col.rgb;
                half3 finalColor = c * _Brightness_Saturation_Contrast.x;
                half3 gray = 0.2125 * c.r + 0.7154 * c.g + 0.0721 * c.b;
                finalColor = lerp(gray, finalColor, _Brightness_Saturation_Contrast.y);
                half3 avgColor = half3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Brightness_Saturation_Contrast.z);
                return half4(finalColor, col.a);
            }
            ENDCG
        }
    }
}
