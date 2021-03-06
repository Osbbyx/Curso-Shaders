Shader "Custom/Matrices"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Value ("Value", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Value;

            fixed4 matrixPos(fixed4 vertexPos)
            {
                fixed4x4 _matrix = fixed4x4
                (
                    1, 0, 0, _Value,
                    0, 1, 0, 0, 
                    0, 0, 1, 0, 
                    0, 0, 0, 0
                );

                return mul(_matrix, vertexPos);
            }

            v2f vert (appdata v)
            {
                v2f o;
                fixed4 _newVertexPos = matrixPos(v.vertex);
                o.vertex = UnityObjectToClipPos(_newVertexPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
