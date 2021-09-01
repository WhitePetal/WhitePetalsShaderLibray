Shader "PostProcess/VolumeLightScatter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // _ShadowMapTexture("ShadowMap", 2D) = "white" {}
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
            #include "UnityShaderVariables.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"
            // #include "../Librays/ShaderUtil.cginc"

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

            uniform float4x4 _MWorldToShadowClipMat;
            uniform sampler2D  _MShadowMap;

            sampler2D _MainTex, _MDepthTex;
            float4 _MainTex_ST;
            sampler3D _DecilTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 GetWorldPositionFromDepthValue( float2 uv, float linearDepth )
            {
                float camPosZ = _ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * linearDepth;
                // unity_CameraProjection._m11 = near / t，其中t是视锥体near平面的高度的一半。
                // 投影矩阵的推导见：http://www.songho.ca/opengl/gl_projectionmatrix.html。
                // 这里求的height和width是坐标点所在的视锥体截面（与摄像机方向垂直）的高和宽，并且
                // 假设相机投影区域的宽高比和屏幕一致。
                float height = 2 * camPosZ / unity_CameraProjection._m11;
                float width = _ScreenParams.x / _ScreenParams.y * height;
                float camPosX = width * uv.x - width / 2;
                float camPosY = height * uv.y - height / 2;
                float4 camPos = float4(camPosX, camPosY, camPosZ, 1.0);
                return mul(unity_CameraToWorld, camPos);
            }

            float random (float2 st) {
                return frac(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
            }

            half4 frag (v2f i) : SV_Target
            {
                float depth = clamp(tex2D(_MDepthTex, i.uv).a, 0.001, 1.0);
                // depth = Linear01Depth(depth);
                float3 worldPos = GetWorldPositionFromDepthValue(i.uv, depth).xyz;
                float3 pos_cam_world = _WorldSpaceCameraPos;
                float s = distance(worldPos, pos_cam_world) * 0.01;
                float3 dir = normalize(worldPos.xyz - pos_cam_world.xyz) * s;
                float3 pos = pos_cam_world.xyz;
                // half4 source = tex2D(_MainTex, i.uv);
                half3 col;
                for(int m = 0; m < 100; ++m)
                {
                    float4 shadowCoord = mul(_MWorldToShadowClipMat, float4(pos, 1.0));
                    shadowCoord.xyz = (shadowCoord.xyz / shadowCoord.w) * 0.5 + 0.5;
                    float depth_shadow = shadowCoord.z;
                    float depth_sample_shadow = DecodeFloatRG(tex2D(_MShadowMap, shadowCoord.xy).rg);
                    // float dist = saturate(abs(depth_shadow - depth_sample_shadow));
                    float flag = step(depth_shadow, depth_sample_shadow);
                    col += 0.01 * flag + (flag + 0.1) * 0.001 * random(i.uv * 1000 + _Time.x * 0.004);
                    pos += dir;
                }
                // return source;
                return half4(col, 1.0);
                // return flag;
            }
            ENDCG
        }

                Pass
        {
            ZWrite Off
            ZTest Always
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityShaderVariables.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"
            // #include "../Librays/ShaderUtil.cginc"

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

            uniform float4x4 _MWorldToShadowClipMat;
            uniform sampler2D  _MShadowMap;

            sampler2D _MainTex, _MDepthTex, _VolumeLightTex;
            float4 _MainTex_ST;
            sampler3D _DecilTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 source = tex2D(_MainTex, i.uv);
                half4 volumeLight = tex2D(_VolumeLightTex, i.uv);

                return half4(source.rgb * volumeLight.rgb, source.a);
                // return flag;
            }
            ENDCG
        }
    }
}
