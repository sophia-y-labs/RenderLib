#ifndef RENDERLIB_LIGHTING_INCLUDED
#define RENDERLIB_LIGHTING_INCLUDED

// ---------------------------------------------------------------------------
// RenderLib Lighting Utilities
// Stylized / simplified lighting helpers for Forward Pass fragment shaders.
// No URP Lighting.hlsl dependency — pure math except ToonRamp (needs TEXTURE2D_*).
// SafeNormalize comes from Common.hlsl when included via RenderLibCore.
// ---------------------------------------------------------------------------

#ifndef RENDERLIB_COMMON_INCLUDED
// Fallback when Lighting.hlsl is included without Common.hlsl
static const float RENDERLIB_EPSILON = 1e-5;

float3 RenderLib_SafeNormalize(float3 v)
{
    float lenSq = dot(v, v);
    return (lenSq > RENDERLIB_EPSILON * RENDERLIB_EPSILON)
        ? v * rsqrt(lenSq)
        : float3(0.0, 0.0, 1.0);
}
#endif

// ---------------------------------------------------------------------------
// NdotL: classic Lambert diffuse term, clamped to [0, 1]
// N = surface normal (world or tangent space, must match L)
// L = direction TOWARD the light source
// ---------------------------------------------------------------------------

float RenderLib_NdotL(float3 normal, float3 lightDir)
{
    float3 n = RenderLib_SafeNormalize(normal);
    float3 l = RenderLib_SafeNormalize(lightDir);
    return saturate(dot(n, l));
}

half RenderLib_NdotL(half3 normal, half3 lightDir)
{
    return half(RenderLib_NdotL(float3(normal), float3(lightDir)));
}

// ---------------------------------------------------------------------------
// HalfLambert: Valve-style soft diffuse (used in Half-Life 2 / stylized games)
// Maps dot [-1, 1] -> [0, 1] with a softer falloff in shadowed areas
// ---------------------------------------------------------------------------

float RenderLib_HalfLambert(float3 normal, float3 lightDir)
{
    float3 n = RenderLib_SafeNormalize(normal);
    float3 l = RenderLib_SafeNormalize(lightDir);
    float ndotl = dot(n, l);
    return saturate(ndotl * 0.5 + 0.5);
}

half RenderLib_HalfLambert(half3 normal, half3 lightDir)
{
    return half(RenderLib_HalfLambert(float3(normal), float3(lightDir)));
}

// ---------------------------------------------------------------------------
// ToonRampSteps: banded shading without a ramp texture (good for prototyping)
// steps = number of discrete brightness levels (e.g. 3 = 3-tone toon)
// ---------------------------------------------------------------------------

float RenderLib_ToonRampSteps(float ndotl, float steps)
{
    steps = max(steps, 2.0);
    float band = floor(saturate(ndotl) * steps);
    return band / (steps - 1.0);
}

half RenderLib_ToonRampSteps(half ndotl, half steps)
{
    return half(RenderLib_ToonRampSteps(float(ndotl), float(steps)));
}

// ---------------------------------------------------------------------------
// ToonRamp: sample a 1D ramp texture (stored as 2D: u = NdotL, v = 0.5)
// Requires URP Core.hlsl (TEXTURE2D_*) included before this call site.
// rampTex is typically a horizontal gradient: dark (left) -> bright (right)
// ---------------------------------------------------------------------------

half3 RenderLib_ToonRamp(
    TEXTURE2D_PARAM(rampTex, samplerRamp),
    float ndotl,
    float vCoord)
{
    float2 rampUV = float2(saturate(ndotl), vCoord);
    return SAMPLE_TEXTURE2D(rampTex, samplerRamp, rampUV).rgb;
}

half3 RenderLib_ToonRamp(
    TEXTURE2D_PARAM(rampTex, samplerRamp),
    float ndotl)
{
    return RenderLib_ToonRamp(TEXTURE2D_ARGS(rampTex, samplerRamp), ndotl, 0.5);
}

// ---------------------------------------------------------------------------
// RimLight: view-dependent edge highlight (Fresnel-like)
// N = surface normal (world space)
// V = view direction (from surface point toward camera, world space)
// power = falloff sharpness (higher = thinner rim)
// intensity = brightness multiplier
// ---------------------------------------------------------------------------

float RenderLib_RimLight(float3 normalWS, float3 viewDirWS, float power, float intensity)
{
    float3 n = RenderLib_SafeNormalize(normalWS);
    float3 v = RenderLib_SafeNormalize(viewDirWS);
    float fresnel = 1.0 - saturate(dot(n, v));
    return pow(fresnel, max(power, 0.001)) * intensity;
}

half RenderLib_RimLight(half3 normalWS, half3 viewDirWS, half power, half intensity)
{
    return half(RenderLib_RimLight(float3(normalWS), float3(viewDirWS), float(power), float(intensity)));
}

// Rim color variant: returns RGB rim tint (common in toon shaders)
half3 RenderLib_RimLightColor(
    float3 normalWS,
    float3 viewDirWS,
    float  power,
    half3  rimColor,
    float  intensity)
{
    float rim = RenderLib_RimLight(normalWS, viewDirWS, power, intensity);
    return rimColor * half(rim);
}

#endif // RENDERLIB_LIGHTING_INCLUDED