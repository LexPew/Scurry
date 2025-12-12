// Stencil Injection by ShaderGraphStencilInjector

Shader "Stencil Shader Graph/Prototype_Glass_Global_URP"
{
Properties
{
[NoScaleOffset]_Grid("Grid", 2D) = "white" {}
Color_1308AD31("BaseColor", Color) = (0, 1, 0.8982549, 0)
_OverlayAmount("OverlayAmount", Range(0, 1)) = 0.5
_GridScale("GridScale", Float) = 1
_Falloff("Falloff", Float) = 50
_Specular("Specular", Range(0, 1)) = 0.1
_Smoothness("Smoothness", Float) = 1
_Opacity("Opacity", Color) = (0, 0, 0, 0.5529412)
[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
[HideInInspector]_QueueControl("_QueueControl", Float) = -1

        // Stencil Properties
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0, 255)) = 0
        [IntRange] _StencilReadMask ("Stencil ReadMask Value", Range(0, 255)) = 255
        [IntRange] _StencilWriteMask ("Stencil WriteMask Value", Range(0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass Op", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail Op", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail Op", Float) = 0
        [Enum(Off,0,On,1)] _StencilEnabled ("Stencil Enabled", Float) = 0
}
SubShader
{
Tags
{
"RenderPipeline"="UniversalPipeline"
"RenderType"="Transparent"
"UniversalMaterialType" = "Lit"
"Queue"="Transparent"
"DisableBatching"="False"
"ShaderGraphShader"="true"
"ShaderGraphTargetId"="UniversalLitSubTarget"
}
Pass
{
    Name "Universal Forward"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

// Render State
Cull Back
Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite Off

        // Stencil Buffer Setup
        Stencil
        {
            Ref [_StencilRef]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
            Comp [_StencilComp]
            Pass [_StencilPass]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
        }

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _LIGHT_LAYERS
#pragma multi_compile_fragment _ DEBUG_DISPLAY
#pragma multi_compile_fragment _ _LIGHT_COOKIES
#pragma multi_compile _ _FORWARD_PLUS
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
#define _FOG_FRAGMENT 1
#define _SURFACE_TYPE_TRANSPARENT 1
#define _ALPHAPREMULTIPLY_ON 1
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
#endif
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP3;
#endif
 float4 tangentWS : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float3 positionWS : INTERP6;
 float3 normalWS : INTERP7;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float4(float4 In, out float4 Out)
{
    Out = 1 - In;
}

void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
{
    Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    Out = lerp(Base, Out, Opacity);
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
float4 _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4;
Unity_OneMinus_float4(_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4);
float4 _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4;
Unity_Blend_Screen_float4(_OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4, float4(0, 0, 0, 0), _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, 1);
float4 _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4 = Color_1308AD31;
float4 _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4;
Unity_Add_float4(_Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4, _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4);
float _Property_a1f95ff7fe70408fa7f9fa6e8afa60fa_Out_0_Float = _Specular;
float _Property_912400140382888b910ab0e8d508f579_Out_0_Float = _Smoothness;
surface.BaseColor = (_Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4.xyz);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Emission = float3(0, 0, 0);
surface.Metallic = _Property_a1f95ff7fe70408fa7f9fa6e8afa60fa_Out_0_Float;
surface.Smoothness = _Property_912400140382888b910ab0e8d508f579_Out_0_Float;
surface.Occlusion = 1;
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "GBuffer"
    Tags
    {
        "LightMode" = "UniversalGBuffer"
    }

// Render State
Cull Back
Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma instancing_options renderinglayer
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DYNAMICLIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
#pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
#pragma multi_compile_fragment _ DEBUG_DISPLAY
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define VARYINGS_NEED_SHADOW_COORD
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
#define _FOG_FRAGMENT 1
#define _SURFACE_TYPE_TRANSPARENT 1
#define _ALPHAPREMULTIPLY_ON 1
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh;
#endif
 float4 fogFactorAndVertexLight;
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord;
#endif
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
#if defined(LIGHTMAP_ON)
 float2 staticLightmapUV : INTERP0;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
 float2 dynamicLightmapUV : INTERP1;
#endif
#if !defined(LIGHTMAP_ON)
 float3 sh : INTERP2;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
 float4 shadowCoord : INTERP3;
#endif
 float4 tangentWS : INTERP4;
 float4 fogFactorAndVertexLight : INTERP5;
 float3 positionWS : INTERP6;
 float3 normalWS : INTERP7;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS.xyzw = input.tangentWS;
output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
#if defined(LIGHTMAP_ON)
output.staticLightmapUV = input.staticLightmapUV;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
output.dynamicLightmapUV = input.dynamicLightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.sh;
#endif
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
output.shadowCoord = input.shadowCoord;
#endif
output.tangentWS = input.tangentWS.xyzw;
output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float4(float4 In, out float4 Out)
{
    Out = 1 - In;
}

void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
{
    Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    Out = lerp(Base, Out, Opacity);
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
float4 _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4;
Unity_OneMinus_float4(_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4);
float4 _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4;
Unity_Blend_Screen_float4(_OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4, float4(0, 0, 0, 0), _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, 1);
float4 _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4 = Color_1308AD31;
float4 _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4;
Unity_Add_float4(_Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4, _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4);
float _Property_a1f95ff7fe70408fa7f9fa6e8afa60fa_Out_0_Float = _Specular;
float _Property_912400140382888b910ab0e8d508f579_Out_0_Float = _Smoothness;
surface.BaseColor = (_Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4.xyz);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Emission = float3(0, 0, 0);
surface.Metallic = _Property_a1f95ff7fe70408fa7f9fa6e8afa60fa_Out_0_Float;
surface.Smoothness = _Property_912400140382888b910ab0e8d508f579_Out_0_Float;
surface.Occlusion = 1;
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ShadowCaster"
    Tags
    {
        "LightMode" = "ShadowCaster"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
 float3 normalWS : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "DepthNormals"
    Tags
    {
        "LightMode" = "DepthNormals"
    }

// Render State
Cull Back
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma multi_compile_instancing
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD1
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALS
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 tangentWS;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 TangentSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 tangentWS : INTERP0;
 float3 positionWS : INTERP1;
 float3 normalWS : INTERP2;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.tangentWS.xyzw = input.tangentWS;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.tangentWS = input.tangentWS.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 NormalTS;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
surface.NormalTS = IN.TangentSpaceNormal;
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "Meta"
    Tags
    {
        "LightMode" = "Meta"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
#pragma shader_feature _ EDITOR_VISUALIZATION
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_META
#define _FOG_FRAGMENT 1
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
 float4 uv0 : TEXCOORD0;
 float4 uv1 : TEXCOORD1;
 float4 uv2 : TEXCOORD2;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
 float4 texCoord0;
 float4 texCoord1;
 float4 texCoord2;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float4 texCoord0 : INTERP0;
 float4 texCoord1 : INTERP1;
 float4 texCoord2 : INTERP2;
 float3 positionWS : INTERP3;
 float3 normalWS : INTERP4;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.texCoord0.xyzw = input.texCoord0;
output.texCoord1.xyzw = input.texCoord1;
output.texCoord2.xyzw = input.texCoord2;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.texCoord0 = input.texCoord0.xyzw;
output.texCoord1 = input.texCoord1.xyzw;
output.texCoord2 = input.texCoord2.xyzw;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float4(float4 In, out float4 Out)
{
    Out = 1 - In;
}

void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
{
    Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    Out = lerp(Base, Out, Opacity);
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 Emission;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
float4 _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4;
Unity_OneMinus_float4(_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4);
float4 _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4;
Unity_Blend_Screen_float4(_OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4, float4(0, 0, 0, 0), _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, 1);
float4 _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4 = Color_1308AD31;
float4 _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4;
Unity_Add_float4(_Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4, _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4);
surface.BaseColor = (_Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4.xyz);
surface.Emission = float3(0, 0, 0);
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENESELECTIONPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
 float3 normalWS : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

// Render State
Cull Back

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
#define SCENEPICKINGPASS 1
#define ALPHA_CLIP_THRESHOLD 1
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
 float3 normalWS : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
Pass
{
    // Name: <None>
    Tags
    {
        "LightMode" = "Universal2D"
    }

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 2.0
#pragma vertex vert
#pragma fragment frag

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines

#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_2D
#define _ALPHATEST_ON 1
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */


// custom interpolator pre-include
/* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

// --------------------------------------------------
// Structs and Packing

// custom interpolators pre packing
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

struct Attributes
{
 float3 positionOS : POSITION;
 float3 normalOS : NORMAL;
 float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS;
 float3 normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
 float3 WorldSpaceNormal;
 float3 AbsoluteWorldSpacePosition;
};
struct VertexDescriptionInputs
{
 float3 ObjectSpaceNormal;
 float3 ObjectSpaceTangent;
 float3 ObjectSpacePosition;
};
struct PackedVaryings
{
 float4 positionCS : SV_POSITION;
 float3 positionWS : INTERP0;
 float3 normalWS : INTERP1;
#if UNITY_ANY_INSTANCING_ENABLED
 uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings (Varyings input)
{
PackedVaryings output;
ZERO_INITIALIZE(PackedVaryings, output);
output.positionCS = input.positionCS;
output.positionWS.xyz = input.positionWS;
output.normalWS.xyz = input.normalWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

Varyings UnpackVaryings (PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.positionWS.xyz;
output.normalWS = input.normalWS.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}


// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 _Grid_TexelSize;
float4 Color_1308AD31;
float _OverlayAmount;
float _GridScale;
float _Falloff;
float _Specular;
float _Smoothness;
float4 _Opacity;
CBUFFER_END


// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_Grid);
SAMPLER(sampler_Grid);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
{
    Out = lerp(A, B, T);
}

void Unity_OneMinus_float4(float4 In, out float4 Out)
{
    Out = 1 - In;
}

void Unity_Blend_Screen_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
{
    Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
    Out = lerp(Base, Out, Opacity);
}

void Unity_Add_float4(float4 A, float4 B, out float4 Out)
{
    Out = A + B;
}

// Custom interpolators pre vertex
/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Custom interpolators, pre surface
#ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float Alpha;
float AlphaClipThreshold;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4 = _Opacity;
UnityTexture2D _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Grid);
float _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float = _GridScale;
float _Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float = _Falloff;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_UV = IN.AbsoluteWorldSpacePosition * _Property_6f3c3982ba971388b6946b532b8ff73b_Out_0_Float;
float3 Triplanar_c1699351edff078e9f052737bbebcedb_Blend = SafePositivePow_float(IN.WorldSpaceNormal, min(_Property_6424e4ce95aee380ad1734678307ab82_Out_0_Float, floor(log2(Min_float())/log2(1/sqrt(3)))) );
Triplanar_c1699351edff078e9f052737bbebcedb_Blend /= dot(Triplanar_c1699351edff078e9f052737bbebcedb_Blend, 1.0);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_X = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.zy);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Y = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xz);
float4 Triplanar_c1699351edff078e9f052737bbebcedb_Z = SAMPLE_TEXTURE2D(_Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.tex, _Property_2d025d62a0fc2a86bd04d00182d56fda_Out_0_Texture2D.samplerstate, Triplanar_c1699351edff078e9f052737bbebcedb_UV.xy);
float4 _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4 = Triplanar_c1699351edff078e9f052737bbebcedb_X * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.x + Triplanar_c1699351edff078e9f052737bbebcedb_Y * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.y + Triplanar_c1699351edff078e9f052737bbebcedb_Z * Triplanar_c1699351edff078e9f052737bbebcedb_Blend.z;
float _Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float = _OverlayAmount;
float _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float;
Unity_OneMinus_float(_Property_9376a8acf520478f8a6e7e85468d3f43_Out_0_Float, _OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float);
float4 _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4;
Unity_Lerp_float4(_Property_5f99d83afbe659829b990466ad073107_Out_0_Vector4, _Triplanar_c1699351edff078e9f052737bbebcedb_Out_0_Vector4, (_OneMinus_afe8ca583165a88c9e7aeb61c95a454d_Out_1_Float.xxxx), _Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4);
float4 _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4;
Unity_OneMinus_float4(_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4, _OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4);
float4 _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4;
Unity_Blend_Screen_float4(_OneMinus_ed4bc5f42e89458ebba181bb3f35a4ee_Out_1_Vector4, float4(0, 0, 0, 0), _Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, 1);
float4 _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4 = Color_1308AD31;
float4 _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4;
Unity_Add_float4(_Blend_bf16d68c97f35b88983e3a9ace43781c_Out_2_Vector4, _Property_49df3ab8df2aeb83b10bf1e1b9dd55e0_Out_0_Vector4, _Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4);
surface.BaseColor = (_Add_42017eb56423bc8da629500d6f01169f_Out_2_Vector4.xyz);
surface.Alpha = (_Lerp_04d2c40cdde0b28cba5c66ed31ff3867_Out_3_Vector4).x;
surface.AlphaClipThreshold = 0.5;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs
#ifdef HAVE_VFX_MODIFICATION
#define VFX_SRP_ATTRIBUTES Attributes
#define VFX_SRP_VARYINGS Varyings
#define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
#endif
VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
    {
        VertexDescriptionInputs output;
        ZERO_INITIALIZE(VertexDescriptionInputs, output);
    
        output.ObjectSpaceNormal =                          input.normalOS;
        output.ObjectSpaceTangent =                         input.tangentOS.xyz;
        output.ObjectSpacePosition =                        input.positionOS;
    
        return output;
    }
    
SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
    {
        SurfaceDescriptionInputs output;
        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
    
    #ifdef HAVE_VFX_MODIFICATION
    #if VFX_USE_GRAPH_VALUES
        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
    #endif
        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
    
    #endif
    
        
    
        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        float3 unnormalizedNormalWS = input.normalWS;
        const float renormFactor = 1.0 / length(unnormalizedNormalWS);
    
    
        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
    
    
        output.AbsoluteWorldSpacePosition = GetAbsolutePositionWS(input.positionWS);
    
        #if UNITY_UV_STARTS_AT_TOP
        #else
        #endif
    
    
    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
    #else
    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    #endif
    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
    
            return output;
    }
    

// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

// --------------------------------------------------
// Visual Effect Vertex Invocations
#ifdef HAVE_VFX_MODIFICATION
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
#endif

ENDHLSL
}
}
CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
FallBack "Hidden/Shader Graph/FallbackError"
}