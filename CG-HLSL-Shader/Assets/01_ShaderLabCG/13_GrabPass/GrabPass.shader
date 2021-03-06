Shader "Custom/GrabPass"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Blur ("Blur", Range(0.0, 0.02)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        GrabPass {"_BackgroundTexture"}
        LOD 100

        Pass
        {
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
                float4 uvgrab : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _BackgroundTexture;
            float4 _Color;
            float _Blur;

            void Unity_RandomRange_float(float2 Seed, float Min, float Max, out float Out)
            {
                float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
                Out = lerp(Min, Max, randomno);
            }

            // float Unity_RandomRange(float2 Seed, float Min, float Max)
            // {
            //     float randomno =  frac(sin(dot(Seed, float2(12.9898, 78.233)))*43758.5453);
            //     return lerp(Min, Max, randomno);
            // }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvgrab = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {        
                float2 projuv = i.uvgrab.xy / i.uvgrab.w;        
                fixed4 col = 0;

                float noise = 0;
                Unity_RandomRange_float(i.uvgrab, 0, 1, noise);

                const float grabSamples = 32;
                for(float s = 0; s < grabSamples; s++)
                {
                    float2 offset = float2(cos(noise), sin(noise)) * _Blur;
                    col += tex2D(_BackgroundTexture, projuv + offset);
                    noise++;
                }

                return (col /= grabSamples) * _Color;
            }
            ENDCG
        }
    }
}
