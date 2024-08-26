﻿Shader "Hidden/Paint in 3D/Decal"
{
	Properties
	{
		_ReplaceTexture("Replace Texture", 2D) = "white" {}
		_Texture("Texture", 2D) = "white" {}
		_Shape("Shape", 2D) = "white" {}
		_TileTexture("Tile Texture", 2D) = "white" {}
		_MaskTexture("Mask Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Blend One Zero, One Zero
			Cull Off
			Lighting Off
			ZWrite Off

			CGPROGRAM
				#pragma vertex Vert
				#pragma fragment Frag
				#pragma multi_compile __ P3D_LINE P3D_QUAD
				#pragma multi_compile __ P3D_A // 0-1
				#pragma multi_compile __ P3D_B // 0-2
				#pragma multi_compile __ P3D_C // 0-4
				#pragma multi_compile __ P3D_D // 0-8
				#define BLEND_MODE_INDEX (P3D_A * 1 + P3D_B * 2 + P3D_C * 4 + P3D_D * 8)

				float4    _Coord;
				float4    _Channels;
				float4x4  _Matrix;
				float3    _Direction;
				sampler2D _Texture;
				sampler2D _Shape;
				float4    _ShapeChannel;
				float4    _Color;
				float     _Opacity;
				float     _Hardness;
				float     _Wrapping;
				float     _In3D;
				float2    _NormalFront;
				float2    _NormalBack;

				sampler2D _TileTexture;
				float4x4  _TileMatrix;
				float     _TileOpacity;
				float     _TileTransition;

				#include "BlendModes.cginc"
				#include "Extrusions.cginc"
				#include "Masking.cginc"

				struct a2v
				{
					float4 vertex    : POSITION;
					float3 normal    : NORMAL;
					float3 tangent   : TANGENT;
					float2 texcoord0 : TEXCOORD0;
					float2 texcoord1 : TEXCOORD1;
					float2 texcoord2 : TEXCOORD2;
					float2 texcoord3 : TEXCOORD3;
				};

				struct v2f
				{
					float4 vertex   : SV_POSITION;
					float2 texcoord : TEXCOORD0;
					float3 position : TEXCOORD1;
					float  normal   : TEXCOORD2;
					float3 tile     : TEXCOORD3;
					float3 weights  : TEXCOORD4;
					float3 mask     : TEXCOORD5;

					float rot : TEXCOORD6;
				};

				struct f2g
				{
					float4 color : SV_TARGET;
				};

				void Vert(a2v i, out v2f o)
				{
					float2 texcoord     = i.texcoord0 * _Coord.x + i.texcoord1 * _Coord.y + i.texcoord2 * _Coord.z + i.texcoord3 * _Coord.w;
					float4 worldPos     = mul(unity_ObjectToWorld, i.vertex);
					float3 worldNormal  = normalize(mul((float3x3)unity_ObjectToWorld, i.normal));
					float3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, i.tangent));

					o.vertex   = float4(texcoord.xy * 2.0f - 1.0f, 0.5f, 1.0f);
					o.texcoord = texcoord;
					o.position = lerp(float3(texcoord, 0.0f), worldPos.xyz, _In3D);

					o.position = mul((float3x3)_Matrix, o.position);

					float3 loc_tan = mul((float3x3)_Matrix, worldTangent);
					o.rot = -atan2(loc_tan.y, loc_tan.x);

					o.normal   = dot(worldNormal, _Direction);
					o.tile     = mul(_TileMatrix, worldPos).xyz;
					o.mask     = mul(_MaskMatrix, worldPos).xyz;
					o.weights  = pow(abs(worldNormal), _TileTransition);
					o.weights /= o.weights.x + o.weights.y + o.weights.z;
#if UNITY_UV_STARTS_AT_TOP
					o.vertex.y = -o.vertex.y;
#endif
				}

				void Frag(v2f i, out f2g o)
				{
					float3 position = i.position - GetClosestPosition(i.position);
					float  depth    = position.z * _Wrapping; position.xy /= 1.0f - depth * depth;
					float3 absPos   = abs(position);

					// You can remove this to improve performance if you don't care about overlapping UV support
					if (max(max(absPos.x, absPos.y), absPos.z) > 1.0f)
					{
						discard;
					}

					
					float2 coord    = position.xy * 0.5f + 0.5f;
					float  strength = 1.0f;
					float4 color    = tex2D(_Texture, coord) * _Color;

					// Fade OOB
					float3 box = saturate(absPos);
					box.xy = pow(box.xy,   1000.0f);
					box.z  = pow(box.z , _Hardness);
					strength -= max(box.x, max(box.y, box.z));

					// Fade slopes
					float front = (_NormalFront.x - i.normal) * _NormalFront.y;
					float back  = (_NormalBack .x - i.normal) * _NormalBack .y;
					float fade  = saturate(max(front, back));
					strength *= smoothstep(0.0f, 1.0f, fade);

					// Fade mask
					strength *= GetMask(i.mask);

					// Mix in shape
					strength *= dot(tex2D(_Shape, coord), _ShapeChannel);

					// Mix in tiling
					float4 textureX = tex2D(_TileTexture, i.tile.yz) * i.weights.x;
					float4 textureY = tex2D(_TileTexture, i.tile.xz) * i.weights.y;
					float4 textureZ = tex2D(_TileTexture, i.tile.xy) * i.weights.z;
					color *= lerp(float4(1.0f, 1.0f, 1.0f, 1.0f), textureX + textureY + textureZ, _TileOpacity);

					o.color = Blend(color, strength * _Opacity, i.texcoord, i.rot, _Channels);
				}
			ENDCG
		} // Pass
	} // SubShader
} // Shader