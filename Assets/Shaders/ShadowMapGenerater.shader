Shader "Hidden/ShadowMapGenerater"
{
    SubShader
    {
        Tags{"RenderWithShader"="MShadow"}
        Pass
        {
            Cull Off
            ZTest LEqual
            ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            uniform float4x4 _MWorldToLightMat; 
            uniform float4x4 _MWorldToShadowClipMat;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = mul(_MWorldToShadowClipMat, mul(unity_ObjectToWorld, v.vertex));
                o.vertex.y = -o.vertex.y;
                o.vertex.z += 0.001;
                o.vertex.z = 1.0 - (o.vertex.z * 0.5 + 0.5);
                // o.vertex.z += 0.001;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float depth = 1.0 - i.vertex.z / i.vertex.w;
                return float4(EncodeFloatRG(depth), 0.0, 0.0);
                // return depth;
            }
            ENDCG
        }
    }
}
