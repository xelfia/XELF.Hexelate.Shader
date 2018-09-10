// ©2018 XELF
// https://github.com/xelfia/XELF.Hexelate.Shader
// MIT License

Shader "Voxel/Hexelate" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Width("Width", Range(2, 32)) = 10
		_Height("Height", Range(2, 32)) = 20
		_StepMin("Step Min", Range(0, 32)) = 1
		_StepMax("Step Max", Range(0, 32)) = 2
	}
	SubShader {
		Cull Off ZWrite Off ZTest Always

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _Width, _Height;
			float _StepMin, _StepMax;

			inline float3 TexToHex(float2 tex) {
				float s = _Width / _ScreenParams.x;
				return float3(
					dot(float2(+sqrt(3) / 3, -1 / 3.0), tex),
					dot(float2(-sqrt(3) / 3, -1 / 3.0), tex),
					(2 / 3.0) * tex.y) / s;
			}
			inline float2 HexToTex(float3 hex) {
				float s = _Width / _ScreenParams.x;
				return float2(
					dot(float2(sqrt(3) / 2, sqrt(3)), hex.br),
					(3 / 2.0) * hex.b) * s;
			}
			inline float3 HexRound(float3 h) {
				float3 r = round(h);
				float3 d = abs(r - h);
				if (d.x > d.y && d.x > d.z)
					r.x = -r.y - r.z;
				else if (d.y > d.z)
					r.y = -r.x - r.z;
				else
					r.z = -r.x - r.y;
				return r;
			}
			inline float HexDistance(float3 a, float3 b) {
				float3 d = abs(a - b);
				return max(max(d.x, d.y), d.z);
			}

			fixed4 frag(v2f i) : SV_Target {
				float4 color = float4(0, 0, 0, 0);
				float3 center = HexRound(TexToHex(i.uv));
				
				int2 size = int2(_Width + 0.5, _Height + 0.5);
				float weight = 0;
				int2 ij;
				[loop]
				for (ij.y = -size.y; ij.y < size.y; ij.y++) {
					[loop]
					for (ij.x = -size.x; ij.x < size.x; ij.x++) {
						float2 t = i.uv + float2(ij) / _ScreenParams;
						float d = HexDistance(center, TexToHex(t));
						float w = 1 - smoothstep(d, _StepMin, _StepMax);
						weight += w;
						color += w * tex2Dlod(_MainTex, float4(t, 0, 0));
					}
				}
				return color / weight;
			}
			ENDCG
		}
	}
}
