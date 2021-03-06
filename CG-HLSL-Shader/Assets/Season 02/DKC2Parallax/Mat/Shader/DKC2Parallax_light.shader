Shader "Custom/DKC2Parallax_light"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _Distance ("Distance", Range(0, 1)) = 0.5
        _Speed ("Speed", Range(0.1, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue"="Transparent"}
        Blend SrcAlpha One
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            float _Distance;
            float _Speed;

            half4 matrixPos(half4 vertexPos, half vertexWorld, half cam, half v)
            {
                half4x4 _matrix = half4x4
                (
                    1, 0, 0, (vertexWorld - cam) * v,
                    0, 1, 0, 0, 
                    0, 0, 1, 0, 
                    0, 0, 0, 0
                );

                return mul(_matrix, vertexPos);
            }

            v2f vert (appdata v)
            {
                v2f o;
                half4 _vertexWorld = mul(unity_ObjectToWorld, v.vertex);
                half4 _vertex = matrixPos(v.vertex, _vertexWorld.x * _Distance, _WorldSpaceCameraPos.x, 1 - v.uv.y);

                o.vertex = TransformObjectToHClip(_vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {                
                //half4 col = tex2D(_MainTex, i.uv) * sin(_WorldSpaceCameraPos.x * _Speed);
                half4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
