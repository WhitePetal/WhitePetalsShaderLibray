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
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                // float2 uv0 = floor(i.uv.xy * _MosaicerDensity + 0.5 + fixed2(1.0, 0.0)) / _MosaicerDensity;
                // float2 uv1 = floor(i.uv.xy * _MosaicerDensity + fixed2(-1.0, 0.0)) / _MosaicerDensity;
                // float2 uv2 = floor(i.uv.xy * _MosaicerDensity + fixed2(0.0, 1.0)) / _MosaicerDensity;
                // float2 uv3 = floor(i.uv.xy * _MosaicerDensity + fixed2(0.0, -1.0)) / _MosaicerDensity;
                // fixed4 mosic = tex2D(_MainTex, uv0) * 0.25;
                // mosic += tex2D(_MainTex, uv1) * 0.25;
                // mosic += tex2D(_MainTex, uv2) * 0.25;
                // mosic += tex2D(_MainTex, uv3) * 0.25;
                float2 uv0 = floor(i.uv.xy * _MosaicerDensity + 0.5) / _MosaicerDensity;
                fixed4 mosic = tex2D(_MainTex, uv0);
                fixed flag = step(0.5, tex2D(_MosaicerFlagTex, i.uv.xy).g);
                return col * (1.0 - flag) + mosic * flag;
            }
            ENDCG
        }
    }
}
