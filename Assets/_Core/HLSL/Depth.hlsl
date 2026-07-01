#ifndef RENDERLIB_DEPTH_INCLUDED
#define RENDERLIB_DEPTH_INCLUDED

// ---------------------------------------------------------------------------
// RenderLib Depth Utilities
// Eye-space depth conversion, soft particles, and depth-based fading.
//
// DEPENDENCY: URP Core.hlsl must be available (pulled in via DeclareDepthTexture).
// Call site in effect shaders should include:
//   #include "Packages/.../Core.hlsl"
//   #include "Assets/_Core/Includes/RenderLibCore.hlsl"
//
// Requires "Depth Texture" enabled on URP Renderer Asset.
// ---------------------------------------------------------------------------

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

#ifndef RENDERLIB_COMMON_INCLUDED
static const float RENDERLIB_EPSILON = 1e-5;
#endif

// ---------------------------------------------------------------------------
// LinearEyeDepth: convert raw depth buffer value to eye-space depth (meters)
// rawDepth: .r from _CameraDepthTexture or clip-space Z/W
// Handles perspective vs orthographic (matches URP Particles.hlsl)
// ---------------------------------------------------------------------------

float RenderLib_LinearEyeDepth(float rawDepth)
{
    return (unity_OrthoParams.w == 0.0)
        ? LinearEyeDepth(rawDepth, _ZBufferParams)
        : LinearDepthToEyeDepth(rawDepth);
}

// ---------------------------------------------------------------------------
// Linear01Depth: map raw depth to normalized [0, 1] linear range
// Useful for post effects (Underwater E042, DOF E038)
// ---------------------------------------------------------------------------

float RenderLib_Linear01Depth(float rawDepth)
{
    return Linear01Depth(rawDepth, _ZBufferParams);
}

// ---------------------------------------------------------------------------
// SampleSceneEyeDepth: read scene depth at screen UV -> eye-space meters
// screenUV: normalized 0-1 (from positionCS.xy / positionCS.w)
// ---------------------------------------------------------------------------

float RenderLib_SampleSceneEyeDepth(float2 screenUV)
{
    float rawDepth = SampleSceneDepth(screenUV);
    return RenderLib_LinearEyeDepth(rawDepth);
}

// Eye depth from clip-space homogeneous coordinates (z/w after projection)
float RenderLib_LinearEyeDepthFromClip(float clipDepth)
{
    return LinearEyeDepth(clipDepth, _ZBufferParams);
}

// Eye depth from world position (alternative path for soft particles)
float RenderLib_LinearEyeDepthFromWorld(float3 positionWS)
{
    return LinearEyeDepth(positionWS, GetWorldToViewMatrix());
}

// ---------------------------------------------------------------------------
// SoftParticleFade (pure math)
// sceneEyeDepth   = background geometry depth (meters from camera)
// particleEyeDepth = current pixel/particle depth (meters)
// fadeDistance    = fade width in meters when particle intersects scene
// Returns alpha multiplier in [0, 1]
// ---------------------------------------------------------------------------

float RenderLib_SoftParticleFade(float sceneEyeDepth, float particleEyeDepth, float fadeDistance)
{
    // Positive gap = particle is in front of scene (visible intersection band)
    float depthGap = sceneEyeDepth - particleEyeDepth;
    return saturate(depthGap / max(fadeDistance, RENDERLIB_EPSILON));
}

half RenderLib_SoftParticleFade(half sceneEyeDepth, half particleEyeDepth, half fadeDistance)
{
    return half(RenderLib_SoftParticleFade(float(sceneEyeDepth), float(particleEyeDepth), float(fadeDistance)));
}

// ---------------------------------------------------------------------------
// SoftParticleFade (URP Particle System compatible parameters)
// nearFade     = depth offset (usually 0)
// invFadeRange = 1 / fadeDistance (Unity uses inverse range on materials)
// Same formula as URP ShaderLibrary/Particles.hlsl -> SoftParticles()
// ---------------------------------------------------------------------------

float RenderLib_SoftParticleFadeURP(
    float sceneEyeDepth,
    float particleEyeDepth,
    float nearFade,
    float invFadeRange)
{
    return saturate(invFadeRange * ((sceneEyeDepth - nearFade) - particleEyeDepth));
}

// ---------------------------------------------------------------------------
// SoftParticleFade (screen-space, from projected clip position)
// projectedPositionCS = output of TransformWorldToHClip (float4, before divide)
// Pass from vertex shader via TEXCOORD; fragment uses xy/w for UV, z/w for depth
// ---------------------------------------------------------------------------

float RenderLib_SoftParticleFade(
    float4 projectedPositionCS,
    float    nearFade,
    float    invFadeRange)
{
    float2 screenUV = projectedPositionCS.xy / projectedPositionCS.w;
    screenUV = UnityStereoTransformScreenSpaceTex(screenUV);

    float sceneZ    = RenderLib_SampleSceneEyeDepth(screenUV);
    float particleZ = RenderLib_LinearEyeDepthFromClip(projectedPositionCS.z / projectedPositionCS.w);

    return RenderLib_SoftParticleFadeURP(sceneZ, particleZ, nearFade, invFadeRange);
}

// Overload: intuitive fadeDistance instead of inverse range
float RenderLib_SoftParticleFade(
    float4 projectedPositionCS,
    float  fadeDistance)
{
    float invFadeRange = (fadeDistance > RENDERLIB_EPSILON) ? (1.0 / fadeDistance) : 0.0;
    return RenderLib_SoftParticleFade(projectedPositionCS, 0.0, invFadeRange);
}

// ---------------------------------------------------------------------------
// DepthFade: fade a surface when it approaches scene geometry
// Typical use: water shoreline foam, decal blending, fog at contact
//
// sceneEyeDepth   = depth of background (from depth texture)
// surfaceEyeDepth = depth of current surface being shaded
// fadeStart       = begin fading when gap (scene - surface) <= this (meters)
// fadeEnd         = fully opaque when gap >= this (meters)
// Returns alpha [0, 1] — 1 = fully visible, 0 = fully faded
// ---------------------------------------------------------------------------

float RenderLib_DepthFade(
    float sceneEyeDepth,
    float surfaceEyeDepth,
    float fadeStart,
    float fadeEnd)
{
    float depthGap = sceneEyeDepth - surfaceEyeDepth;
    float range    = fadeEnd - fadeStart;
    float t        = (range != 0.0) ? (depthGap - fadeStart) / range : 0.0;
    return saturate(t);
}

half RenderLib_DepthFade(
    half sceneEyeDepth,
    half surfaceEyeDepth,
    half fadeStart,
    half fadeEnd)
{
    return half(RenderLib_DepthFade(
        float(sceneEyeDepth), float(surfaceEyeDepth),
        float(fadeStart), float(fadeEnd)));
}

// Screen-space variant: sample scene depth at UV, fade current surface
float RenderLib_DepthFadeScreen(
    float2 screenUV,
    float  surfaceEyeDepth,
    float  fadeStart,
    float  fadeEnd)
{
    float sceneZ = RenderLib_SampleSceneEyeDepth(screenUV);
    return RenderLib_DepthFade(sceneZ, surfaceEyeDepth, fadeStart, fadeEnd);
}

// ---------------------------------------------------------------------------
// DepthDifference: raw gap in meters (positive = surface in front of scene)
// Building block for custom fade curves
// ---------------------------------------------------------------------------

float RenderLib_DepthDifference(float sceneEyeDepth, float surfaceEyeDepth)
{
    return sceneEyeDepth - surfaceEyeDepth;
}

#endif // RENDERLIB_DEPTH_INCLUDED