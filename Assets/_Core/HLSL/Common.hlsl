#ifndef RENDERLIB_COMMON_INCLUDED
#define RENDERLIB_COMMON_INCLUDED

// ---------------------------------------------------------------------------
// RenderLib Common Utilities
// Pure math helpers with no URP or texture dependencies.
// ---------------------------------------------------------------------------

// sRGB standard constants (IEC 61966-2-1)
static const float RENDERLIB_SRGB_LINEAR_CUTOFF = 0.0031308;
static const float RENDERLIB_SRGB_LINEAR_SCALE  = 12.92;
static const float RENDERLIB_SRGB_GAMMA          = 2.4;
static const float RENDERLIB_SRGB_GAMMA_OFFSET   = 0.055;
static const float RENDERLIB_SRGB_GAMMA_SCALE    = 1.055;

// Default fallback normal when input length is near zero
static const float3 RENDERLIB_DEFAULT_NORMAL = float3(0.0, 0.0, 1.0);

// Epsilon for safe division / normalization
static const float RENDERLIB_EPSILON = 1e-5;

// ---------------------------------------------------------------------------
// Remap: linearly map value from [inMin, inMax] to [outMin, outMax]
// ---------------------------------------------------------------------------

float RenderLib_Remap(float value, float inMin, float inMax, float outMin, float outMax)
{
    // Guard against zero-length input range
    float range = inMax - inMin;
    float t = (range != 0.0) ? (value - inMin) / range : 0.0;
    return lerp(outMin, outMax, t);
}

float2 RenderLib_Remap(float2 value, float inMin, float inMax, float outMin, float outMax)
{
    return float2(
        RenderLib_Remap(value.x, inMin, inMax, outMin, outMax),
        RenderLib_Remap(value.y, inMin, inMax, outMin, outMax)
    );
}

float3 RenderLib_Remap(float3 value, float inMin, float inMax, float outMin, float outMax)
{
    return float3(
        RenderLib_Remap(value.x, inMin, inMax, outMin, outMax),
        RenderLib_Remap(value.y, inMin, inMax, outMin, outMax),
        RenderLib_Remap(value.z, inMin, inMax, outMin, outMax)
    );
}

float4 RenderLib_Remap(float4 value, float inMin, float inMax, float outMin, float outMax)
{
    return float4(
        RenderLib_Remap(value.x, inMin, inMax, outMin, outMax),
        RenderLib_Remap(value.y, inMin, inMax, outMin, outMax),
        RenderLib_Remap(value.z, inMin, inMax, outMin, outMax),
        RenderLib_Remap(value.w, inMin, inMax, outMin, outMax)
    );
}

// ---------------------------------------------------------------------------
// SafeNormalize: normalize with epsilon guard against zero-length vectors
// ---------------------------------------------------------------------------

float3 RenderLib_SafeNormalize(float3 v)
{
    float lenSq = dot(v, v);
    return (lenSq > RENDERLIB_EPSILON * RENDERLIB_EPSILON)
        ? v * rsqrt(lenSq)
        : RENDERLIB_DEFAULT_NORMAL;
}

float2 RenderLib_SafeNormalize(float2 v)
{
    float lenSq = dot(v, v);
    return (lenSq > RENDERLIB_EPSILON * RENDERLIB_EPSILON)
        ? v * rsqrt(lenSq)
        : float2(0.0, 1.0);
}

half3 RenderLib_SafeNormalize(half3 v)
{
    return RenderLib_SafeNormalize(float3(v));
}

// ---------------------------------------------------------------------------
// Color space: Linear (scene) <-> sRGB (display / 8-bit textures)
// Piecewise exact sRGB transfer functions (not the fast approximations).
// ---------------------------------------------------------------------------

float RenderLib_LinearToSRGB(float linearValue)
{
    return (linearValue <= RENDERLIB_SRGB_LINEAR_CUTOFF)
        ? linearValue * RENDERLIB_SRGB_LINEAR_SCALE
        : RENDERLIB_SRGB_GAMMA_SCALE * pow(abs(linearValue), 1.0 / RENDERLIB_SRGB_GAMMA) - RENDERLIB_SRGB_GAMMA_OFFSET;
}

float3 RenderLib_LinearToSRGB(float3 linearRgb)
{
    return float3(
        RenderLib_LinearToSRGB(linearRgb.r),
        RenderLib_LinearToSRGB(linearRgb.g),
        RenderLib_LinearToSRGB(linearRgb.b)
    );
}

half3 RenderLib_LinearToSRGB(half3 linearRgb)
{
    return half3(RenderLib_LinearToSRGB(float3(linearRgb)));
}

float RenderLib_SRGBToLinear(float srgb)
{
    return (srgb <= RENDERLIB_SRGB_LINEAR_CUTOFF * RENDERLIB_SRGB_LINEAR_SCALE)
        ? srgb / RENDERLIB_SRGB_LINEAR_SCALE
        : pow(abs(srgb + RENDERLIB_SRGB_GAMMA_OFFSET) / RENDERLIB_SRGB_GAMMA_SCALE, RENDERLIB_SRGB_GAMMA);
}

float3 RenderLib_SRGBToLinear(float3 srgb)
{
    return float3(
        RenderLib_SRGBToLinear(srgb.r),
        RenderLib_SRGBToLinear(srgb.g),
        RenderLib_SRGBToLinear(srgb.b)
    );
}

half3 RenderLib_SRGBToLinear(half3 srgb)
{
    return half3(RenderLib_SRGBToLinear(float3(srgb)));
}

#endif // RENDERLIB_COMMON_INCLUDED