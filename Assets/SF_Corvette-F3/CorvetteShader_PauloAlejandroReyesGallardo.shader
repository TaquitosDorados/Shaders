// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CorvetteShader"
{
	Properties
	{
		_NormalIntensity("Normal Intensity", Range( 1 , 2)) = 1
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_SpecularPower("SpecularPower", Range( 0 , 10)) = 3.16361
		_Intensity("Intensity", Range( 0 , 1)) = 1
		_Color1("Color 1", Color) = (1,1,1,1)
		_MainTexture("MainTexture", 2D) = "white" {}
		_Scale("Scale", Vector) = (1,1,1,0)
		_OffSet("OffSet", Vector) = (0,0,0,0)
		_Trisampleo("Trisampleo", 2D) = "white" {}
		_Fade("Fade", Range( 0 , 7)) = 1.356167
		_Vector0("Vector 0", Vector) = (1,1,1,0)
		_TriplanarIntensity("TriplanarIntensity", Float) = 0
		[Toggle]_AlignNormalsToView("AlignNormalsToView", Float) = 1
		[Toggle]_ToggleSwitch0("Toggle Switch0", Float) = 0
		_Noise("Noise", 2D) = "white" {}
		[Toggle]_Use2DNoise("Use 2D Noise", Float) = 0
		_Tint("Tint", Color) = (0,1,0.8209276,1)
		_RefractionIntensity("RefractionIntensity", Range( -0.5 , 0.5)) = 0.1121788
		_BlurIntensity("Blur Intensity", Range( 0 , 0.1)) = 0
		_BlurDivide("BlurDivide", Float) = 9
		_BlurTint("BlurTint", Color) = (1,1,1,1)
		_NoiseSize("Noise Size", Float) = 20
		_NoiseIntensity("Noise Intensity", Range( 0 , 0.5)) = 0.15
		_Progress("Progress", Range( 0 , 1.06)) = 0.5
		_Width("Width", Range( 0 , 1)) = 0.06
		_InvisibilityTransition("InvisibilityTransition", 2D) = "white" {}
		_TransitionEmission("TransitionEmission", Float) = 10
		_DefaultEmission("DefaultEmission", 2D) = "white" {}
		_EmissionGlow("EmissionGlow", 2D) = "white" {}
		_DefaultEmissionValue("DefaultEmissionValue", Float) = 10
		_TransitionColor("TransitionColor", Color) = (0,1,0.9619756,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float4 screenPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
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

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _RefractionIntensity;
		uniform float _Use2DNoise;
		uniform float _AlignNormalsToView;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _NormalIntensity;
		uniform sampler2D _Noise;
		uniform float _ToggleSwitch0;
		uniform float4 _Tint;
		uniform float _BlurIntensity;
		uniform float _BlurDivide;
		uniform float4 _BlurTint;
		uniform sampler2D _InvisibilityTransition;
		uniform float4 _InvisibilityTransition_ST;
		uniform float _TransitionEmission;
		uniform float4 _TransitionColor;
		uniform float _NoiseSize;
		uniform float _NoiseIntensity;
		uniform float _Progress;
		uniform float _Width;
		uniform sampler2D _DefaultEmission;
		uniform float4 _DefaultEmission_ST;
		uniform float _DefaultEmissionValue;
		uniform sampler2D _EmissionGlow;
		uniform float4 _EmissionGlow_ST;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float _SpecularPower;
		uniform float _Intensity;
		uniform float4 _Color1;
		uniform float _TriplanarIntensity;
		uniform sampler2D _Trisampleo;
		uniform float4 _Scale;
		uniform float4 _OffSet;
		uniform float _Fade;
		uniform float3 _Vector0;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }

		inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }

		inline float valueNoise (float2 uv)
		{
			float2 i = floor(uv);
			float2 f = frac( uv );
			f = f* f * (3.0 - 2.0 * f);
			uv = abs( frac(uv) - 0.5);
			float2 c0 = i + float2( 0.0, 0.0 );
			float2 c1 = i + float2( 1.0, 0.0 );
			float2 c2 = i + float2( 0.0, 1.0 );
			float2 c3 = i + float2( 1.0, 1.0 );
			float r0 = noise_randomValue( c0 );
			float r1 = noise_randomValue( c1 );
			float r2 = noise_randomValue( c2 );
			float r3 = noise_randomValue( c3 );
			float bottomOfGrid = noise_interpolate( r0, r1, f.x );
			float topOfGrid = noise_interpolate( r2, r3, f.x );
			float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
			return t;
		}


		float SimpleNoise(float2 UV)
		{
			float t = 0.0;
			float freq = pow( 2.0, float( 0 ) );
			float amp = pow( 0.5, float( 3 - 0 ) );
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(1));
			amp = pow(0.5, float(3-1));
			t += valueNoise( UV/freq )*amp;
			freq = pow(2.0, float(2));
			amp = pow(0.5, float(3-2));
			t += valueNoise( UV/freq )*amp;
			return t;
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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float3 WorldNormalPerturbed9 = (WorldNormalVector( i , UnpackScaleNormal( tex2D( _TextureSample0, uv_TextureSample0 ), _NormalIntensity ) ));
			float3 objToWorldDir124 = mul( unity_ObjectToWorld, float4( WorldNormalPerturbed9, 0 ) ).xyz;
			float4 temp_output_128_0 = (ase_grabScreenPosNorm).xyzw;
			float temp_output_132_0 = (0.0 + (tex2D( _Noise, (( _ToggleSwitch0 )?( temp_output_128_0 ):( float4( i.uv_texcoord, 0.0 , 0.0 ) )).xy ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
			float4 appendResult133 = (float4(temp_output_132_0 , temp_output_132_0 , 0.0 , 0.0));
			float4 screenColor140 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xyzw + ( _RefractionIntensity * (( _Use2DNoise )?( appendResult133 ):( float4( ((( _AlignNormalsToView )?( objToWorldDir124 ):( WorldNormalPerturbed9 ))).xyz , 0.0 ) )) ) ).xy);
			float4 Transparency144 = ( screenColor140 * _Tint );
			float4 ScreenPosition149 = temp_output_128_0;
			float4 screenColor162 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ScreenPosition149.xy);
			float BlurIntensity148 = _BlurIntensity;
			float temp_output_2_0_g4 = BlurIntensity148;
			float2 temp_output_1_0_g4 = ScreenPosition149.xy;
			float4 screenColor163 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 1,0 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float4 screenColor164 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( -1,0 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float4 screenColor165 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 0,1 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float4 screenColor166 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 0,-1 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float temp_output_2_0_g5 = BlurIntensity148;
			float2 temp_output_1_0_g5 = ScreenPosition149.xy;
			float4 screenColor172 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 1,1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 screenColor173 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( -1,-1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 screenColor174 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 1,-1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 screenColor175 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( -1,1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 Blur181 = ( ( ( screenColor162 + ( screenColor163 + screenColor164 + screenColor165 + screenColor166 ) + ( screenColor172 + screenColor173 + screenColor174 + screenColor175 ) ) / _BlurDivide ) * _BlurTint );
			float4 Invisible222 = ( Transparency144 + Blur181 );
			float4 color55 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 DifusseColor59 = ( color55 * tex2D( _MainTexture, uv_MainTexture ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult28 = dot( WorldNormalPerturbed9 , ase_worldlightDir );
			float DirectLight31 = ( saturate( dotResult28 ) * ase_lightAtten );
			float4 LightColor64 = ( ase_lightColor * DirectLight31 );
			float4 LambertLighting70 = ( DifusseColor59 * LightColor64 );
			float4 IndirectLight74 = ( DifusseColor59 * UNITY_LIGHTMODEL_AMBIENT );
			float3 normalizeResult17 = normalize( WorldNormalPerturbed9 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult14 = normalize( ( ase_worldlightDir + ase_worldViewDir ) );
			float dotResult19 = dot( normalizeResult17 , normalizeResult14 );
			float4 SpecularLight53 = ( DirectLight31 * pow( saturate( dotResult19 ) , exp2( _SpecularPower ) ) * _Intensity * ase_lightColor * _Color1 );
			float4 temp_cast_19 = (_TriplanarIntensity).xxxx;
			float4 temp_output_90_0 = ( ( float4( ase_worldPos , 0.0 ) * (_Scale).xyzw ) + (_OffSet).xyzw );
			float4 SampleX101 = tex2D( _Trisampleo, (temp_output_90_0).zy );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_cast_21 = (exp2( _Fade )).xxx;
			float3 temp_output_107_0 = pow( abs( ase_worldNormal ) , temp_cast_21 );
			float dotResult111 = dot( _Vector0 , temp_output_107_0 );
			float3 break114 = saturate( ( temp_output_107_0 / dotResult111 ) );
			float4 lerpResult116 = lerp( temp_cast_19 , SampleX101 , break114.x);
			float4 SampleY102 = tex2D( _Trisampleo, (temp_output_90_0).xz );
			float4 lerpResult117 = lerp( lerpResult116 , SampleY102 , break114.y);
			float4 SampleZ103 = tex2D( _Trisampleo, (temp_output_90_0).xy );
			float4 lerpResult118 = lerp( lerpResult117 , SampleZ103 , break114.z);
			float4 Triplanar119 = lerpResult118;
			float4 Visible221 = ( LambertLighting70 + IndirectLight74 + SpecularLight53 + Triplanar119 );
			float simpleNoise186 = SimpleNoise( i.uv_texcoord*_NoiseSize );
			float gradient193 = ( ( (0.0 + (simpleNoise186 - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) * _NoiseIntensity ) + i.uv_texcoord.x );
			float Progress198 = _Progress;
			float NoiseIntensity191 = _NoiseIntensity;
			float Width199 = _Width;
			float temp_output_207_0 = ( Width199 * 0.5 );
			float temp_output_205_0 = ( ( NoiseIntensity191 * 0.5 ) + temp_output_207_0 );
			float temp_output_211_0 = (( 0.0 - temp_output_205_0 ) + (Progress198 - 0.0) * (( 1.0 + temp_output_205_0 ) - ( 0.0 - temp_output_205_0 )) / (1.0 - 0.0));
			float temp_output_1_0_g6 = ( temp_output_211_0 - temp_output_207_0 );
			float temp_output_215_0 = ( ( gradient193 - temp_output_1_0_g6 ) / ( ( temp_output_211_0 + temp_output_207_0 ) - temp_output_1_0_g6 ) );
			float4 lerpResult224 = lerp( Invisible222 , Visible221 , saturate( temp_output_215_0 ));
			float2 uv_InvisibilityTransition = i.uv_texcoord * _InvisibilityTransition_ST.xy + _InvisibilityTransition_ST.zw;
			float4 tex2DNode227 = tex2D( _InvisibilityTransition, uv_InvisibilityTransition );
			float4 lerpResult247 = lerp( Invisible222 , ( tex2DNode227 * _TransitionEmission * _TransitionColor ) , saturate( tex2DNode227 ));
			float temp_output_220_0 = saturate( ( 1.0 - abs( (0.0 + (temp_output_215_0 - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float4 temp_output_231_0 = ( lerpResult247 * temp_output_220_0 );
			float4 lerpResult230 = lerp( lerpResult224 , temp_output_231_0 , temp_output_220_0);
			c.rgb = lerpResult230.rgb;
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
			o.Normal = float3(0,0,1);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float3 WorldNormalPerturbed9 = (WorldNormalVector( i , UnpackScaleNormal( tex2D( _TextureSample0, uv_TextureSample0 ), _NormalIntensity ) ));
			float3 objToWorldDir124 = mul( unity_ObjectToWorld, float4( WorldNormalPerturbed9, 0 ) ).xyz;
			float4 temp_output_128_0 = (ase_grabScreenPosNorm).xyzw;
			float temp_output_132_0 = (0.0 + (tex2D( _Noise, (( _ToggleSwitch0 )?( temp_output_128_0 ):( float4( i.uv_texcoord, 0.0 , 0.0 ) )).xy ).r - 0.0) * (1.0 - 0.0) / (1.0 - 0.0));
			float4 appendResult133 = (float4(temp_output_132_0 , temp_output_132_0 , 0.0 , 0.0));
			float4 screenColor140 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xyzw + ( _RefractionIntensity * (( _Use2DNoise )?( appendResult133 ):( float4( ((( _AlignNormalsToView )?( objToWorldDir124 ):( WorldNormalPerturbed9 ))).xyz , 0.0 ) )) ) ).xy);
			float4 Transparency144 = ( screenColor140 * _Tint );
			float4 ScreenPosition149 = temp_output_128_0;
			float4 screenColor162 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,ScreenPosition149.xy);
			float BlurIntensity148 = _BlurIntensity;
			float temp_output_2_0_g4 = BlurIntensity148;
			float2 temp_output_1_0_g4 = ScreenPosition149.xy;
			float4 screenColor163 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 1,0 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float4 screenColor164 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( -1,0 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float4 screenColor165 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 0,1 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float4 screenColor166 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 0,-1 ) * temp_output_2_0_g4 ) + temp_output_1_0_g4 ));
			float temp_output_2_0_g5 = BlurIntensity148;
			float2 temp_output_1_0_g5 = ScreenPosition149.xy;
			float4 screenColor172 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 1,1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 screenColor173 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( -1,-1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 screenColor174 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( 1,-1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 screenColor175 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ( float2( -1,1 ) * temp_output_2_0_g5 ) + temp_output_1_0_g5 ));
			float4 Blur181 = ( ( ( screenColor162 + ( screenColor163 + screenColor164 + screenColor165 + screenColor166 ) + ( screenColor172 + screenColor173 + screenColor174 + screenColor175 ) ) / _BlurDivide ) * _BlurTint );
			float4 Invisible222 = ( Transparency144 + Blur181 );
			float2 uv_InvisibilityTransition = i.uv_texcoord * _InvisibilityTransition_ST.xy + _InvisibilityTransition_ST.zw;
			float4 tex2DNode227 = tex2D( _InvisibilityTransition, uv_InvisibilityTransition );
			float4 lerpResult247 = lerp( Invisible222 , ( tex2DNode227 * _TransitionEmission * _TransitionColor ) , saturate( tex2DNode227 ));
			float simpleNoise186 = SimpleNoise( i.uv_texcoord*_NoiseSize );
			float gradient193 = ( ( (0.0 + (simpleNoise186 - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) * _NoiseIntensity ) + i.uv_texcoord.x );
			float Progress198 = _Progress;
			float NoiseIntensity191 = _NoiseIntensity;
			float Width199 = _Width;
			float temp_output_207_0 = ( Width199 * 0.5 );
			float temp_output_205_0 = ( ( NoiseIntensity191 * 0.5 ) + temp_output_207_0 );
			float temp_output_211_0 = (( 0.0 - temp_output_205_0 ) + (Progress198 - 0.0) * (( 1.0 + temp_output_205_0 ) - ( 0.0 - temp_output_205_0 )) / (1.0 - 0.0));
			float temp_output_1_0_g6 = ( temp_output_211_0 - temp_output_207_0 );
			float temp_output_215_0 = ( ( gradient193 - temp_output_1_0_g6 ) / ( ( temp_output_211_0 + temp_output_207_0 ) - temp_output_1_0_g6 ) );
			float temp_output_220_0 = saturate( ( 1.0 - abs( (0.0 + (temp_output_215_0 - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) ) );
			float4 temp_output_231_0 = ( lerpResult247 * temp_output_220_0 );
			float2 uv_DefaultEmission = i.uv_texcoord * _DefaultEmission_ST.xy + _DefaultEmission_ST.zw;
			float2 uv_EmissionGlow = i.uv_texcoord * _EmissionGlow_ST.xy + _EmissionGlow_ST.zw;
			float4 tex2DNode236 = tex2D( _EmissionGlow, uv_EmissionGlow );
			o.Emission = ( temp_output_231_0 + ( tex2D( _DefaultEmission, uv_DefaultEmission ) * _DefaultEmissionValue * tex2DNode236 ) ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
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
Version=18934
0;0;1117.4;803;-1528.076;-608.1006;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;80;-3428.177,-2084.354;Inherit;False;2354.024;2342.739;Custom Light;19;10;32;54;61;60;63;64;72;71;73;74;55;56;58;59;67;65;69;70;;0.9150943,0.2797081,0.2797081,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-3378.177,-1894.714;Inherit;False;1199.95;280;Normal Perturbed;4;1;2;8;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-3328.177,-1813.56;Inherit;False;Property;_NormalIntensity;Normal Intensity;0;0;Create;True;0;0;0;False;0;False;1;1;1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-3015.728,-1844.714;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;8fc276bac0dd42d45b56f9de5cf70f0b;8fc276bac0dd42d45b56f9de5cf70f0b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;8;-2671.228,-1808.313;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;146;-780.0713,-2214.227;Inherit;False;2917.561;1087.746;Transparency;22;127;129;128;123;130;124;131;125;132;133;126;137;136;134;135;138;139;141;140;143;144;149;;0.3027768,0.990566,0.9835327,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-2450.227,-1760.213;Inherit;False;WorldNormalPerturbed;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;121;-4230.631,829.2947;Inherit;False;3720.499;1351.026;Triplanar;34;85;81;86;92;96;93;115;119;97;84;108;105;87;109;106;107;110;88;111;90;112;98;113;99;94;114;101;102;116;100;117;103;118;104;;0.3451762,0.9528302,0.377651,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;32;-2147.715,-2034.354;Inherit;False;1023.561;422.3661;Direct Light;7;25;26;27;28;29;30;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;127;-730.0713,-1335.481;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;25;-2097.715,-1984.354;Inherit;False;9;WorldNormalPerturbed;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-2155.406,1891.788;Inherit;False;Property;_Fade;Fade;9;0;Create;True;0;0;0;False;0;False;1.356167;0;0;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;84;-4180.631,1045.423;Inherit;False;Property;_Scale;Scale;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;105;-2133.936,1696.511;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;26;-2083.047,-1868.647;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComponentMaskNode;128;-489.11,-1328.288;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;129;-564.6352,-1499.119;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;184;528.4719,-1083.536;Inherit;False;2161.632;1797.9;Blur;26;147;148;151;169;150;170;160;171;173;175;161;163;166;174;172;164;165;162;168;167;178;176;180;177;179;181;;0.9468148,1,0.2679245,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;81;-3986.335,915.2017;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ToggleSwitchNode;130;-253.5433,-1416.401;Inherit;False;Property;_ToggleSwitch0;Toggle Switch0;13;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;87;-3981.897,1208.339;Inherit;False;Property;_OffSet;OffSet;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;147;578.4719,-1033.536;Inherit;False;Property;_BlurIntensity;Blur Intensity;18;0;Create;True;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-1846.004,-1932.204;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;85;-3992.534,1055.758;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Exp2OpNode;109;-1866.807,1886.588;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;106;-1925.257,1709.78;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;239;499.9578,879.2719;Inherit;False;2796.971;1843.084;Final Gradiente;30;200;194;206;203;207;204;205;210;208;209;211;214;212;213;215;217;218;228;219;227;225;220;226;229;216;224;230;248;247;249;;1,0,0.804287,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-3326.062,-1541.758;Inherit;False;2002.418;859.4609;Specular;18;11;12;13;14;15;16;17;19;23;21;22;24;34;35;37;52;33;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-248.0637,-1835.383;Inherit;False;9;WorldNormalPerturbed;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;11;-3276.062,-1454.658;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;12;-3233.161,-1290.858;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;107;-1769.761,1654.584;Inherit;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;88;-3798.269,1205.673;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;29;-1717.26,-1928.945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;110;-1757.995,1994.72;Inherit;False;Property;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;885.8212,-1025.126;Inherit;False;BlurIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-3783.039,1051.624;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;200;2004.722,937.7614;Inherit;False;574.3347;262.8884;Inputs;4;196;197;198;199;;0.5188679,0.5188679,0.5188679,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;194;549.9578,929.2719;Inherit;False;1402.253;557.5576;Gradiente;9;187;186;185;188;189;191;192;190;193;;0.4716981,0.4716981,0.4716981,1;0;0
Node;AmplifyShaderEditor.TransformDirectionNode;124;36.44395,-1776.277;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;149;-260.5807,-1234.257;Inherit;False;ScreenPosition;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LightAttenuation;27;-2070.01,-1723.606;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;131;-5.38938,-1430.787;Inherit;True;Property;_Noise;Noise;14;0;Create;True;0;0;0;False;0;False;-1;fb3261c1aa9d27a4aafa30b5474b81d5;fabcac68c2a20d24d857567be1ad0b26;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-3595.634,1096.05;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;190;988.0302,1208.031;Inherit;False;Property;_NoiseIntensity;Noise Intensity;22;0;Create;True;0;0;0;False;0;False;0.15;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;2054.723,1085.25;Inherit;False;Property;_Width;Width;24;0;Create;True;0;0;0;False;0;False;0.06;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-3034.262,-1370.158;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;132;343.4651,-1475.742;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;111;-1579.572,1926.5;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;641.8504,-37.92565;Inherit;False;149;ScreenPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1583.627,-1865.388;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;642.253,-761.9153;Inherit;False;149;ScreenPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;655.6006,66.18006;Inherit;False;148;BlurIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;125;261.2624,-1838.588;Inherit;False;Property;_AlignNormalsToView;AlignNormalsToView;12;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;656.0032,-657.8096;Inherit;False;148;BlurIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;96;-3161.389,887.386;Inherit;True;Property;_Trisampleo;Trisampleo;8;0;Create;True;0;0;0;False;0;False;e0848cf6275681240ad36e12e50971e5;e0848cf6275681240ad36e12e50971e5;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;2344.625,1072.479;Inherit;False;Width;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;112;-1526.646,1733.935;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-2970.562,-1491.758;Inherit;False;9;WorldNormalPerturbed;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;191;1239.937,1371.429;Inherit;False;NoiseIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;187;599.9578,1212.116;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;92;-3409.932,996.1877;Inherit;False;FLOAT2;2;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;185;610.851,1009.229;Inherit;False;Property;_NoiseSize;Noise Size;21;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;171;884.4008,27.36385;Inherit;False;BlurFunction;-1;;5;2d8394b865ffbe841965e9e7f928a889;0;6;1;FLOAT2;0,0;False;2;FLOAT;0;False;6;FLOAT2;1,1;False;7;FLOAT2;-1,-1;False;8;FLOAT2;1,-1;False;9;FLOAT2;-1,1;False;4;FLOAT2;0;FLOAT2;3;FLOAT2;4;FLOAT2;5
Node;AmplifyShaderEditor.DynamicAppendNode;133;570.0407,-1513.505;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;160;884.8034,-696.6258;Inherit;False;BlurFunction;-1;;4;2d8394b865ffbe841965e9e7f928a889;0;6;1;FLOAT2;0,0;False;2;FLOAT;0;False;6;FLOAT2;1,0;False;7;FLOAT2;-1,0;False;8;FLOAT2;0,1;False;9;FLOAT2;0,-1;False;4;FLOAT2;0;FLOAT2;3;FLOAT2;4;FLOAT2;5
Node;AmplifyShaderEditor.NormalizeNode;14;-2906.861,-1361.758;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1348.954,-1853.98;Inherit;False;DirectLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;126;505.8201,-1838.589;Inherit;False;True;True;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;56;-3287.938,-396.9185;Inherit;True;Property;_MainTexture;MainTexture;5;0;Create;True;0;0;0;False;0;False;-1;cc8e67f05b81d374f9639b4ace3d78b1;cc8e67f05b81d374f9639b4ace3d78b1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;17;-2710.562,-1443.658;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;93;-3412.176,1086.813;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;567.6388,1666.119;Inherit;False;191;NoiseIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;60;-3233.063,-85.60548;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;98;-2833.926,1098.687;Inherit;True;Property;_TextureSample2;Texture Sample 2;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;55;-3237.314,-588.818;Inherit;False;Constant;_Color2;Color 2;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;15;-2723.561,-1357.858;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-3249.629,59.3465;Inherit;False;31;DirectLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;702.9927,-1951.591;Inherit;False;Property;_RefractionIntensity;RefractionIntensity;17;0;Create;True;0;0;0;False;0;False;0.1121788;0.1121788;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;113;-1302.109,1748.818;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;137;724.2371,-2164.227;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;174;1273.401,332.3639;Inherit;False;Global;_GrabScreen8;Grab Screen 8;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;206;711.6388,2058.119;Inherit;False;199;Width;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;186;832.8013,979.2719;Inherit;True;Simple;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;134;780.0652,-1656.4;Inherit;False;Property;_Use2DNoise;Use 2D Noise;15;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;166;1272.803,-218.6257;Inherit;False;Global;_GrabScreen5;Grab Screen 5;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;173;1269.401,163.3638;Inherit;False;Global;_GrabScreen7;Grab Screen 7;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;164;1269.803,-560.6258;Inherit;False;Global;_GrabScreen3;Grab Screen 3;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;175;1272.401,505.3639;Inherit;False;Global;_GrabScreen9;Grab Screen 9;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;165;1273.803,-391.6258;Inherit;False;Global;_GrabScreen4;Grab Screen 4;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;172;1270.401,-10.63616;Inherit;False;Global;_GrabScreen6;Grab Screen 6;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;161;1020.803,-921.6258;Inherit;False;149;ScreenPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;163;1270.803,-734.6258;Inherit;False;Global;_GrabScreen2;Grab Screen 2;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;99;-2836.318,1297.775;Inherit;True;Property;_TextureSample3;Texture Sample 3;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;188;1091.516,996.9739;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-3038.412,-15.20039;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;114;-1130.284,1586.007;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;21;-2636.461,-1222.658;Inherit;False;Property;_SpecularPower;SpecularPower;2;0;Create;True;0;0;0;False;0;False;3.16361;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1434.14,1031.773;Inherit;False;Property;_TriplanarIntensity;TriplanarIntensity;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;168;1550.149,182.4503;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;19;-2550.661,-1378.658;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;162;1264.803,-922.6258;Inherit;False;Global;_GrabScreen1;Grab Screen 1;19;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;167;1550.551,-541.5393;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2937.637,-483.1891;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;94;-3410.176,1179.813;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2480.664,1130.052;Inherit;False;SampleX;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;1029.138,-1861.983;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;196;2054.723,1001.547;Inherit;False;Property;_Progress;Progress;23;0;Create;True;0;0;0;False;0;False;0.5;0;0;1.06;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;138;973.9564,-2162.111;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;778.6388,1702.119;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;896.0667,2068.096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-2363.46,-1373.458;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;-2836.317,1494.228;Inherit;True;Property;_TextureSample4;Texture Sample 4;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;176;1795.639,-521.6727;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-2491.471,1321.875;Inherit;False;SampleY;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-2854.24,-0.01484537;Inherit;True;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Exp2OpNode;22;-2336.16,-1256.458;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-2783.021,-483.189;Inherit;True;DifusseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;1181.351,-2077.46;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;178;1891.723,-276.1669;Inherit;False;Property;_BlurDivide;BlurDivide;19;0;Create;True;0;0;0;False;0;False;9;9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;1291.68,1148.118;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;2354.257,987.7614;Inherit;False;Progress;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;205;1014.639,1787.119;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;116;-1272.117,1103.577;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;117;-1096.224,1178.096;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;72;-2476.67,-95.34474;Inherit;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;35;-2003.182,-1023.486;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;34;-2185.947,-1111.994;Inherit;False;Property;_Intensity;Intensity;3;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-2439.787,-524.5456;Inherit;False;59;DifusseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;177;2075.679,-486.6677;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-2434.442,-442.5856;Inherit;False;64;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;180;2071.597,-237.8004;Inherit;False;Property;_BlurTint;BlurTint;20;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;33;-2113.376,-1449.398;Inherit;False;31;DirectLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;140;1354.884,-2081.692;Inherit;False;Global;_GrabScreen0;Grab Screen 0;16;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;-2475.261,1529.909;Inherit;False;SampleZ;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-2437.67,-193.3448;Inherit;False;59;DifusseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;37;-2035.368,-891.2975;Inherit;False;Property;_Color1;Color 1;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;1178.067,1693.096;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;209;1180.067,1827.096;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-2163.261,-1369.558;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;1148.067,1593.096;Inherit;False;198;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;141;1361.233,-1886.996;Inherit;False;Property;_Tint;Tint;16;0;Create;True;0;0;0;False;0;False;0,1,0.8209276,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;192;1495.929,1221.648;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-2198.67,-161.3449;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;2299.548,-391.2011;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;1727.411,1221.648;Inherit;False;gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;118;-927.7838,1251.332;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1785.309,-1289.397;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2211.725,-485.3474;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;211;1363.067,1647.096;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;1644.813,-2052.064;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;1912.69,-2009.662;Inherit;False;Transparency;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;1659.067,1831.096;Inherit;False;193;gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-734.9326,1297.714;Inherit;False;Triplanar;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;181;2465.304,-380.3503;Inherit;False;Blur;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1548.444,-1236.76;Inherit;False;SpecularLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;213;1676.067,1941.096;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;214;1680.067,2054.096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-2044.241,-483.5656;Inherit;True;LambertLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-2029.67,-214.3448;Inherit;True;IndirectLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-793.2175,-421.2641;Inherit;False;74;IndirectLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-791.3743,44.3717;Inherit;False;181;Blur;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;215;1873.067,1951.096;Inherit;True;Inverse Lerp;-1;;6;09cbe79402f023141a4dc1fddd4c9511;0;3;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-825.5384,-44.42408;Inherit;False;144;Transparency;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-789.3175,-526.5641;Inherit;False;70;LambertLighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;-800.6828,-227.2415;Inherit;False;119;Triplanar;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;77;-796.1176,-323.4641;Inherit;False;53;SpecularLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;-484.391,-32.66589;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-538.6162,-432.7545;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;217;1793.283,2265.179;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;227;2526.515,2255.342;Inherit;True;Property;_InvisibilityTransition;InvisibilityTransition;25;0;Create;True;0;0;0;False;0;False;-1;669f6736c0596e74b857707a30db511e;669f6736c0596e74b857707a30db511e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;218;1980.828,2273.782;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;222;-340.4877,-65.51222;Inherit;False;Invisible;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;241;2580.038,2582.844;Inherit;False;Property;_TransitionColor;TransitionColor;31;0;Create;True;0;0;0;False;0;False;0,1,0.9619756,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;79;-415.6163,-469.7545;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;228;2574.438,2478.132;Inherit;False;Property;_TransitionEmission;TransitionEmission;26;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;250;2992.021,2777.18;Inherit;False;581.0574;663.0039;Comment;6;232;235;236;234;237;238;Emission;0.9528302,0.4260769,0.4260769,1;0;0
Node;AmplifyShaderEditor.SaturateNode;249;2857.23,2291.299;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;2859.674,2627.164;Inherit;False;222;Invisible;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;219;2097.829,2266.899;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;221;-202.112,-467.1088;Inherit;False;Visible;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;2830.173,2377.555;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;236;3066.899,3114.133;Inherit;True;Property;_EmissionGlow;EmissionGlow;28;0;Create;True;0;0;0;False;0;False;-1;14db9ce3ea6396949a791f7f696fe35d;14db9ce3ea6396949a791f7f696fe35d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;235;3081.26,3019.865;Inherit;False;Property;_DefaultEmissionValue;DefaultEmissionValue;29;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;232;3042.021,2827.18;Inherit;True;Property;_DefaultEmission;DefaultEmission;27;0;Create;True;0;0;0;False;0;False;-1;b30d9c999b067d040b70e1f848c7f691;b30d9c999b067d040b70e1f848c7f691;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;247;3070.264,2382.618;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;2393.906,1655.605;Inherit;False;222;Invisible;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;220;2247.522,2266.899;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;2393.906,1744.605;Inherit;False;221;Visible;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;216;2133.961,1952.03;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;224;2665.906,1942.605;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;3391.809,2456.311;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;3395.908,2855.518;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;230;3031.929,2083.612;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TriplanarNode;104;-2112.152,879.2947;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;97;-2848.55,880.672;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;238;3119.14,3324.784;Inherit;False;Property;_EmissionGlowValue;EmissionGlowValue;30;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;233;3654.723,2586.514;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;3410.679,2972.578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3500.085,1799.739;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;CorvetteShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;5;1;0
WireConnection;8;0;2;0
WireConnection;9;0;8;0
WireConnection;128;0;127;0
WireConnection;130;0;129;0
WireConnection;130;1;128;0
WireConnection;28;0;25;0
WireConnection;28;1;26;0
WireConnection;85;0;84;0
WireConnection;109;0;108;0
WireConnection;106;0;105;0
WireConnection;107;0;106;0
WireConnection;107;1;109;0
WireConnection;88;0;87;0
WireConnection;29;0;28;0
WireConnection;148;0;147;0
WireConnection;86;0;81;0
WireConnection;86;1;85;0
WireConnection;124;0;123;0
WireConnection;149;0;128;0
WireConnection;131;1;130;0
WireConnection;90;0;86;0
WireConnection;90;1;88;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;132;0;131;1
WireConnection;111;0;110;0
WireConnection;111;1;107;0
WireConnection;30;0;29;0
WireConnection;30;1;27;0
WireConnection;125;0;123;0
WireConnection;125;1;124;0
WireConnection;199;0;197;0
WireConnection;112;0;107;0
WireConnection;112;1;111;0
WireConnection;191;0;190;0
WireConnection;92;0;90;0
WireConnection;171;1;169;0
WireConnection;171;2;170;0
WireConnection;133;0;132;0
WireConnection;133;1;132;0
WireConnection;160;1;150;0
WireConnection;160;2;151;0
WireConnection;14;0;13;0
WireConnection;31;0;30;0
WireConnection;126;0;125;0
WireConnection;17;0;16;0
WireConnection;93;0;90;0
WireConnection;98;0;96;0
WireConnection;98;1;92;0
WireConnection;15;0;14;0
WireConnection;113;0;112;0
WireConnection;174;0;171;4
WireConnection;186;0;187;0
WireConnection;186;1;185;0
WireConnection;134;0;126;0
WireConnection;134;1;133;0
WireConnection;166;0;160;5
WireConnection;173;0;171;3
WireConnection;164;0;160;3
WireConnection;175;0;171;5
WireConnection;165;0;160;4
WireConnection;172;0;171;0
WireConnection;163;0;160;0
WireConnection;99;0;96;0
WireConnection;99;1;93;0
WireConnection;188;0;186;0
WireConnection;63;0;60;0
WireConnection;63;1;61;0
WireConnection;114;0;113;0
WireConnection;168;0;172;0
WireConnection;168;1;173;0
WireConnection;168;2;174;0
WireConnection;168;3;175;0
WireConnection;19;0;17;0
WireConnection;19;1;15;0
WireConnection;162;0;161;0
WireConnection;167;0;163;0
WireConnection;167;1;164;0
WireConnection;167;2;165;0
WireConnection;167;3;166;0
WireConnection;58;0;55;0
WireConnection;58;1;56;0
WireConnection;94;0;90;0
WireConnection;101;0;98;0
WireConnection;135;0;136;0
WireConnection;135;1;134;0
WireConnection;138;0;137;0
WireConnection;204;0;203;0
WireConnection;207;0;206;0
WireConnection;23;0;19;0
WireConnection;100;0;96;0
WireConnection;100;1;94;0
WireConnection;176;0;162;0
WireConnection;176;1;167;0
WireConnection;176;2;168;0
WireConnection;102;0;99;0
WireConnection;64;0;63;0
WireConnection;22;0;21;0
WireConnection;59;0;58;0
WireConnection;139;0;138;0
WireConnection;139;1;135;0
WireConnection;189;0;188;0
WireConnection;189;1;190;0
WireConnection;198;0;196;0
WireConnection;205;0;204;0
WireConnection;205;1;207;0
WireConnection;116;0;115;0
WireConnection;116;1;101;0
WireConnection;116;2;114;0
WireConnection;117;0;116;0
WireConnection;117;1;102;0
WireConnection;117;2;114;1
WireConnection;177;0;176;0
WireConnection;177;1;178;0
WireConnection;140;0;139;0
WireConnection;103;0;100;0
WireConnection;208;1;205;0
WireConnection;209;1;205;0
WireConnection;24;0;23;0
WireConnection;24;1;22;0
WireConnection;192;0;189;0
WireConnection;192;1;187;1
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;179;0;177;0
WireConnection;179;1;180;0
WireConnection;193;0;192;0
WireConnection;118;0;117;0
WireConnection;118;1;103;0
WireConnection;118;2;114;2
WireConnection;52;0;33;0
WireConnection;52;1;24;0
WireConnection;52;2;34;0
WireConnection;52;3;35;0
WireConnection;52;4;37;0
WireConnection;69;0;65;0
WireConnection;69;1;67;0
WireConnection;211;0;210;0
WireConnection;211;3;208;0
WireConnection;211;4;209;0
WireConnection;143;0;140;0
WireConnection;143;1;141;0
WireConnection;144;0;143;0
WireConnection;119;0;118;0
WireConnection;181;0;179;0
WireConnection;53;0;52;0
WireConnection;213;0;211;0
WireConnection;213;1;207;0
WireConnection;214;0;211;0
WireConnection;214;1;207;0
WireConnection;70;0;69;0
WireConnection;74;0;73;0
WireConnection;215;1;213;0
WireConnection;215;2;214;0
WireConnection;215;3;212;0
WireConnection;183;0;145;0
WireConnection;183;1;182;0
WireConnection;78;0;75;0
WireConnection;78;1;76;0
WireConnection;78;2;77;0
WireConnection;78;3;120;0
WireConnection;217;0;215;0
WireConnection;218;0;217;0
WireConnection;222;0;183;0
WireConnection;79;0;78;0
WireConnection;249;0;227;0
WireConnection;219;0;218;0
WireConnection;221;0;79;0
WireConnection;229;0;227;0
WireConnection;229;1;228;0
WireConnection;229;2;241;0
WireConnection;247;0;248;0
WireConnection;247;1;229;0
WireConnection;247;2;249;0
WireConnection;220;0;219;0
WireConnection;216;0;215;0
WireConnection;224;0;225;0
WireConnection;224;1;226;0
WireConnection;224;2;216;0
WireConnection;231;0;247;0
WireConnection;231;1;220;0
WireConnection;234;0;232;0
WireConnection;234;1;235;0
WireConnection;234;2;236;0
WireConnection;230;0;224;0
WireConnection;230;1;231;0
WireConnection;230;2;220;0
WireConnection;104;0;96;0
WireConnection;104;4;108;0
WireConnection;97;0;96;0
WireConnection;233;0;231;0
WireConnection;233;1;234;0
WireConnection;237;0;236;0
WireConnection;237;1;238;0
WireConnection;0;2;233;0
WireConnection;0;13;230;0
ASEEND*/
//CHKSM=FF23E11A7E5951A97CBBA3286685C86174A8C577