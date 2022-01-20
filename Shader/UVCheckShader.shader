//================================================================================================
// UVCheckShader        Var 1.0.0
// 
// Copyright (C) 2022 ayaha401
// Twitter : @ayaha__401
// 
// This software is released under the MIT License.
// see https://github.com/ayaha401/UVCheckShader/blob/main/LICENSE
//================================================================================================
Shader "Unlit/UVCheckShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Num ("Num", int) = 1
        [Toggle]_ShowGrid("Show Grid", int) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" 
        }
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform int _Num;
            uniform bool _ShowGrid;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float sdBox(float2 p, float2 s)
            {
                p = abs(p) - s;
                return max(p.x, p.y);
            }

            float sdTriangle(float2 p, float r)
            {
                const float k = sqrt(3.0);
                p.x = abs(p.x) - r;
                p.y = p.y + r/k;
                if( p.x+k*p.y>0.0 ) p=float2(p.x-k*p.y,-k*p.x-p.y)/2.0;
                p.x -= clamp( p.x, -2.0*r, 0.0 );
                return -length(p)*sign(p.y);
            }

            float map(float2 p)
            {
                float d;
                float d1 = sdBox(float2(p.x, p.y+.3), float2(.1, .55));
                float d2 = sdTriangle(float2(p.x, p.y-.3), .5);
                d = min(d1, d2);
                return step(0.02, d);
            }

            // float2x2 rot(float2 a)
            // {
            //     return float2x2(cos(a), sin(a), -sin(a), cos(a));
            // }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float2 uv = frac(i.uv * abs(_Num))*2-1;
                float c = map(uv);
                col *= c;

                if(_ShowGrid == true)
                {
                    if(uv.x > 0.95 || uv.y > 0.95)
                    {
                        col = float4(1., 0., 0., 1.);
                    }
                }
                
                return col;
            }
            ENDCG
        }
    }
}
