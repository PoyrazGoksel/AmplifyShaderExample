// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Guru/Garlic_Toon_v5.1"
{
	Properties
	{
		[Header(SHADING)]_ShadingOffset("Shading Offset", Range( -1 , 1)) = 0
		_ShadingSmoothness("Shading Smoothness", Range( 0 , 1)) = 0
		_ShadowColor("Shadow Color", Color) = (0.8,0.8,0.8,0)
		_ReceiveShadows("Receive Shadows", Range( 0 , 1)) = 0.25
		[Header(COLOR)]_Color("Albedo Color", Color) = (1,1,1,0)
		[SingleLineTexture]_MainTex("Albedo Texture", 2D) = "white" {}
		_UseSpecColororAlbedo("Use Spec Color or Albedo", Range( 0 , 1)) = 1
		_SpecularColor("Specular Color", Color) = (1,1,1,0)
		[Header(SPECULAR_HIGHLIGHT)]_HighlightContribution("Highlight Contribution", Range( 0 , 1)) = 0.25
		_HightlightSmoothness("Hightlight Smoothness", Range( 0 , 1)) = 0.25
		[Header(COLOR CORRECTION)]_Brightness("Brightness", Range( -1 , 1)) = 0
		_Saturation("Saturation", Range( -1 , 1)) = 0
		_Contrast("Contrast", Range( -1 , 1)) = 0
		_RedOffset("Red Offset", Range( -1 , 1)) = 0
		_GreenOffset("Green Offset", Range( -1 , 1)) = 0
		_BlueOffset("Blue Offset", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			half3 worldNormal;
			float3 worldPos;
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform half _Brightness;
		uniform half4 _ShadowColor;
		uniform half _ReceiveShadows;
		uniform half _ShadingSmoothness;
		uniform half _ShadingOffset;
		uniform half4 _Color;
		uniform sampler2D _MainTex;
		uniform half4 _MainTex_ST;
		uniform half4 _SpecularColor;
		uniform half _UseSpecColororAlbedo;
		uniform float _HightlightSmoothness;
		uniform float _HighlightContribution;
		uniform half _Contrast;
		uniform half _Saturation;
		uniform half _RedOffset;
		uniform half _GreenOffset;
		uniform half _BlueOffset;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			half4 lerpResult734 = lerp( _ShadowColor , float4( 1,1,1,0 ) , ase_lightAtten);
			half4 lerpResult719 = lerp( float4( 1,0,0,0 ) , lerpResult734 , _ReceiveShadows);
			half3 ase_worldNormal = i.worldNormal;
			half3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			half3 ase_worldlightDir = 0;
			#else //aseld
			half3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			half dotResult3 = dot( ase_normWorldNormal , ase_worldlightDir );
			half NxL553 = dotResult3;
			half smoothstepResult559 = smoothstep( 0.0 , _ShadingSmoothness , ( NxL553 + _ShadingOffset ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			half4 ase_lightColor = 0;
			#else //aselc
			half4 ase_lightColor = _LightColor0;
			#endif //aselc
			half4 Lighting557 = ( max( _ShadowColor , ( lerpResult719 * smoothstepResult559 ) ) * ase_lightColor );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 Color561 = ( _Color * tex2D( _MainTex, uv_MainTex ) );
			half4 lerpResult888 = lerp( _SpecularColor , Color561 , _UseSpecColororAlbedo);
			half smoothstepResult617 = smoothstep( 0.0 , _HightlightSmoothness , saturate( ( NxL553 - ( 1.0 - _HighlightContribution ) ) ));
			half Highlight570 = smoothstepResult617;
			half4 blendOpSrc618 = Color561;
			half4 blendOpDest618 = saturate( ( lerpResult888 * ( Highlight570 + (0) ) ) );
			half4 FinalColor670 = ( Lighting557 * ( saturate( ( 1.0 - ( 1.0 - blendOpSrc618 ) * ( 1.0 - blendOpDest618 ) ) )) );
			half4 temp_cast_1 = (0.5).xxxx;
			half3 desaturateInitialColor668 = ( ( ( ( FinalColor670 * half4( half3(1.1,1.1,1.1) , 0.0 ) ) - temp_cast_1 ) * ( _Contrast + 1.0 ) ) + 0.5 ).rgb;
			half desaturateDot668 = dot( desaturateInitialColor668, float3( 0.299, 0.587, 0.114 ));
			half3 desaturateVar668 = lerp( desaturateInitialColor668, desaturateDot668.xxx, ( _Saturation * -1.0 ) );
			half3 break861 = desaturateVar668;
			half3 appendResult862 = (half3(( break861.x + _RedOffset ) , ( break861.y + _GreenOffset ) , ( break861.z + _BlueOffset )));
			half4 ColorCorrected623 = CalculateContrast(( _Brightness + 1.0 ),half4( saturate( appendResult862 ) , 0.0 ));
			c.rgb = ColorCorrected623.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
7;174;1920;855;112.4103;-143.029;1.745688;True;False
Node;AmplifyShaderEditor.CommentaryNode;48;-1272.459,-991.988;Inherit;False;1054.052;319.1289;;4;553;3;324;77;N x L;0.7971698,0.9217122,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;324;-1000.459,-847.9879;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;77;-1240.459,-943.9879;Inherit;True;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;452;781.9012,-256.6172;Inherit;False;1912.478;443.9514;;8;570;617;469;464;473;622;590;462;HIGHLIGHT;1,0.8,0.8460335,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-744.4592,-943.9879;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;553;-584.4592,-943.9879;Inherit;False;NxL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;462;828.4984,22.21445;Float;False;Property;_HighlightContribution;Highlight Contribution;8;1;[Header];Create;True;1;SPECULAR_HIGHLIGHT;0;0;False;0;False;0.25;0.324;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;590;1117.888,-33.79831;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;622;1114.038,-188.0674;Inherit;False;553;NxL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;482;997.2663,-1048.376;Inherit;False;923;509;;4;487;490;489;561;MAIN COLOR;0,0,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;230;-1280,-512;Inherit;False;1845.873;785.5002;;16;224;225;557;695;734;719;698;697;720;694;883;82;552;560;580;559;LIGHTING;1,0.8950585,0.8,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;473;1312.106,-124.0732;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;464;1669.386,-112.3835;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;489;1120.093,-972.4888;Inherit;False;Property;_Color;Albedo Color;4;1;[Header];Create;False;1;COLOR;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-1265.329,8.708403;Inherit;False;Property;_ShadingOffset;Shading Offset;0;1;[Header];Create;True;1;SHADING;0;0;False;0;False;0;-0.063;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;694;-1216.278,-463.7413;Inherit;False;Property;_ShadowColor;Shadow Color;2;0;Create;True;0;0;0;False;0;False;0.8,0.8,0.8,0;0.8,0.8,0.8,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;469;1629.979,38.39489;Float;False;Property;_HightlightSmoothness;Hightlight Smoothness;9;0;Create;True;0;0;0;False;0;False;0.25;0.726;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;552;-1265.329,-103.2919;Inherit;False;553;NxL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;698;-1208.814,-267.1178;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;490;1055.414,-793.5508;Inherit;True;Property;_MainTex;Albedo Texture;5;1;[SingleLineTexture];Create;False;1;Main;0;0;False;0;False;-1;a15b17bd83eaa2146b252d5e7ada5342;a15b17bd83eaa2146b252d5e7ada5342;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;487;1409.83,-870.4037;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;580;-961.3306,-87.29194;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;617;1968.583,-110.7174;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;720;-1101.988,-192.0324;Inherit;False;Property;_ReceiveShadows;Receive Shadows;3;0;Create;True;0;0;0;False;0;False;0.25;0.134;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;734;-985.674,-315.0502;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;560;-1105.329,184.7088;Inherit;False;Property;_ShadingSmoothness;Shading Smoothness;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;561;1690.186,-859.9775;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;570;2486.74,-116.1967;Inherit;False;Highlight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;559;-657.3306,40.70852;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;719;-665.6996,-339.5912;Inherit;False;3;0;COLOR;1,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;692;2890.34,-1003.884;Inherit;False;2114.435;766.511;;13;670;704;558;618;857;886;888;855;563;856;887;874;571;FINAL IMAGE;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;856;3155.48,-394.7678;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;883;-319.9989,-417.872;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;874;2915.415,-853.8318;Inherit;False;Property;_SpecularColor;Specular Color;7;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;563;2921.08,-960.0741;Inherit;False;561;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;3156.377,-514.1848;Inherit;False;570;Highlight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;887;2937.671,-645.4626;Inherit;False;Property;_UseSpecColororAlbedo;Use Spec Color or Albedo;6;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;697;-435.9635,-340.5009;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;695;-179.568,-419.2908;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;855;3359.48,-459.768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;888;3442.312,-800.767;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;225;-57.15674,-317.9338;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;886;3641.958,-657.278;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;153.5228,-422.6262;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;857;3857.293,-655.8511;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;557;370.1866,-429.8032;Inherit;False;Lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;558;4177.287,-936.251;Inherit;False;557;Lighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;618;4118.429,-823.9387;Inherit;False;Screen;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;704;4386.067,-885.4399;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;670;4766.229,-896.9646;Inherit;False;FinalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;693;2834.487,-140.0098;Inherit;False;2192.393;904.1413;;25;623;689;691;869;862;690;867;868;864;861;865;866;863;668;672;877;628;687;882;686;684;688;633;685;671;COLOR CORRECTION;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;882;2879.873,37.01271;Inherit;False;Constant;_Magic;Magic;27;0;Create;True;0;0;0;False;0;False;1.1,1.1,1.1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;671;2848.216,-94.84689;Inherit;False;670;FinalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;633;3114.001,109.9729;Inherit;False;Property;_Contrast;Contrast;15;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;685;3156.125,25.40331;Inherit;False;Constant;_zeropointfive;zeropointfive;19;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;877;3074.8,-87.20052;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;688;3382.438,113.9438;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;684;3362.25,-88.48591;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;686;3510.756,-85.26021;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;628;3252.601,213.0779;Inherit;False;Property;_Saturation;Saturation;14;0;Create;True;1;COLOR CORRECTION;0;0;False;0;False;0;-0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;672;3619.259,117.4875;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;687;3647.161,-85.86874;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DesaturateOpNode;668;3915.602,-80.73379;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;866;3730.451,402.1963;Inherit;False;Property;_BlueOffset;Blue Offset;18;0;Create;True;0;0;0;False;0;False;0;0.094;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;863;3778.341,201.5522;Inherit;False;Property;_RedOffset;Red Offset;16;0;Create;True;0;0;0;False;0;False;0;0.03;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;861;4099.073,-73.21344;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;865;3771.451,287.1963;Inherit;False;Property;_GreenOffset;Green Offset;17;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;867;4231.027,107.2441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;864;4248.033,-20.92705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;868;4223.451,244.1963;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;690;4342.123,365.9953;Inherit;False;Property;_Brightness;Brightness;13;1;[Header];Create;True;1;COLOR CORRECTION;0;0;False;0;False;0;0.1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;862;4428.073,-41.21344;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;869;4533.451,-165.8037;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;691;4616.256,127.0235;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;689;4649.633,-85.15006;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;623;4826.813,-96.52425;Inherit;False;ColorCorrected;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;831;788.8301,440.6371;Inherit;False;1966.261;871.5305;;14;848;847;845;841;840;838;837;850;851;852;833;854;858;889;RIM;1,0.8,0.8460335,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;850;2565.801,580.1297;Inherit;False;Rim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;858;2433.489,586.5215;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;847;2221.832,578.5422;Inherit;True;2;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;854;2012.748,510.7956;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;840;1833.055,767.7189;Float;False;Property;_RimContribution;Rim Contribution;10;1;[Header];Create;True;1;SPECULAR_RIM;0;0;False;0;False;0;0.233;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;889;1802.868,516.3117;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;833;1574.199,765.743;Inherit;False;Property;_RimOffset;Rim Offset;11;0;Create;True;0;0;0;False;0;False;2.5;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;845;1514.862,509.9388;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;852;1240.698,502.0045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;841;1303.059,709.7414;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;838;1018.056,707.9905;Float;False;Property;_RimSmoothness;Rim Smoothness;12;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;837;1018.866,500.6089;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;851;815.3879,704.4729;Inherit;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;848;815.9183,497.0589;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;624;5179.466,-139.0073;Inherit;True;623;ColorCorrected;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5480.042,-368.8359;Half;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Guru/Garlic_Toon_v5.1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;3;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0.02;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;77;0
WireConnection;3;1;324;0
WireConnection;553;0;3;0
WireConnection;590;0;462;0
WireConnection;473;0;622;0
WireConnection;473;1;590;0
WireConnection;464;0;473;0
WireConnection;487;0;489;0
WireConnection;487;1;490;0
WireConnection;580;0;552;0
WireConnection;580;1;82;0
WireConnection;617;0;464;0
WireConnection;617;2;469;0
WireConnection;734;0;694;0
WireConnection;734;2;698;0
WireConnection;561;0;487;0
WireConnection;570;0;617;0
WireConnection;559;0;580;0
WireConnection;559;2;560;0
WireConnection;719;1;734;0
WireConnection;719;2;720;0
WireConnection;883;0;694;0
WireConnection;697;0;719;0
WireConnection;697;1;559;0
WireConnection;695;0;883;0
WireConnection;695;1;697;0
WireConnection;855;0;571;0
WireConnection;855;1;856;0
WireConnection;888;0;874;0
WireConnection;888;1;563;0
WireConnection;888;2;887;0
WireConnection;886;0;888;0
WireConnection;886;1;855;0
WireConnection;224;0;695;0
WireConnection;224;1;225;0
WireConnection;857;0;886;0
WireConnection;557;0;224;0
WireConnection;618;0;563;0
WireConnection;618;1;857;0
WireConnection;704;0;558;0
WireConnection;704;1;618;0
WireConnection;670;0;704;0
WireConnection;877;0;671;0
WireConnection;877;1;882;0
WireConnection;688;0;633;0
WireConnection;684;0;877;0
WireConnection;684;1;685;0
WireConnection;686;0;684;0
WireConnection;686;1;688;0
WireConnection;672;0;628;0
WireConnection;687;0;686;0
WireConnection;687;1;685;0
WireConnection;668;0;687;0
WireConnection;668;1;672;0
WireConnection;861;0;668;0
WireConnection;867;0;861;1
WireConnection;867;1;865;0
WireConnection;864;0;861;0
WireConnection;864;1;863;0
WireConnection;868;0;861;2
WireConnection;868;1;866;0
WireConnection;862;0;864;0
WireConnection;862;1;867;0
WireConnection;862;2;868;0
WireConnection;869;0;862;0
WireConnection;691;0;690;0
WireConnection;689;1;869;0
WireConnection;689;0;691;0
WireConnection;623;0;689;0
WireConnection;850;0;858;0
WireConnection;858;0;847;0
WireConnection;847;0;854;0
WireConnection;847;1;840;0
WireConnection;854;0;889;0
WireConnection;889;0;845;0
WireConnection;889;1;833;0
WireConnection;845;0;852;0
WireConnection;845;1;841;0
WireConnection;852;0;837;0
WireConnection;841;0;838;0
WireConnection;837;0;848;0
WireConnection;837;1;851;0
WireConnection;0;13;624;0
ASEEND*/
//CHKSM=14C43571E54838FB327625D5046F67EDC5CE95B6