#ifndef RENDERLIB_UV_INCLUDED
#define RENDERLIB_UV_INCLUDED

// ---------------------------------------------------------------------------
// RenderLib UV Utilities
// Coordinate transforms for texture sampling.
// TriplanarSample requires URP Core.hlsl (TEXTURE2D_*) included before use.
// ---------------------------------------------------------------------------

static const float  RENDERLIB_PI     = 3.14159265359;
static const float  RENDERLIB_TWO_PI = 6.28318530718;

// Default triplanar blend sharpness (higher = sharper plane transitions)
static const float RENDERLIB_TRIPLANAR_SHARPNESS = 4.0;

// ---------------------------------------------------------------------------
// RotateUV: rotate uv around pivot by angleRad (radians, counter-clockwise)
// ---------------------------------------------------------------------------

float2 RenderLib_RotateUV(float2 uv, float2 pivot, float angleRad)
{
    float2 offset = uv - pivot;
    float s = sin(angleRad);
    float c = cos(angleRad);
    float2 rotated = float2(
        offset.x * c - offset.y * s,
        offset.x * s + offset.y * c
    );
    return rotated + pivot;
}

// ---------------------------------------------------------------------------
// FlipbookUV: map per-quad uv (0-1) into one cell of a cols x rows atlas
// frameIndex is 0-based, wraps with fmod; row 0 = top of atlas
// ---------------------------------------------------------------------------

float2 RenderLib_FlipbookUV(float2 uv, float cols, float rows, float frameIndex)
{
    cols  = max(cols, 1.0);
    rows  = max(rows, 1.0);
    float totalFrames = cols * rows;

    frameIndex = fmod(frameIndex, totalFrames);
    if (frameIndex < 0.0)
        frameIndex += totalFrames;

    float col = fmod(frameIndex, cols);
    float row = floor(frameIndex / cols);

    float2 cellSize   = float2(1.0 / cols, 1.0 / rows);
    float2 cellOffset = float2(col * cellSize.x, (rows - 1.0 - row) * cellSize.y);

    return uv * cellSize + cellOffset;
}

// Overload: integer-like atlas size passed as float2(cols, rows)
float2 RenderLib_FlipbookUV(float2 uv, float2 atlasSize, float frameIndex)
{
    return RenderLib_FlipbookUV(uv, atlasSize.x, atlasSize.y, frameIndex);
}

// ---------------------------------------------------------------------------
// PolarUV: convert Cartesian uv to polar (angle, radius)
// Returns float2(normalizedAngle, radius)
//   normalizedAngle in [0, 1) mapping atan2 range [-PI, PI]
//   radius = distance from center (same units as uv space)
// ---------------------------------------------------------------------------

float2 RenderLib_PolarUV(float2 uv, float2 center)
{
    float2 delta  = uv - center;
    float  radius = length(delta);
    float  angle  = atan2(delta.y, delta.x);
    float  normalizedAngle = angle * (0.5 / RENDERLIB_PI) + 0.5;
    return float2(normalizedAngle, radius);
}

// Optional inverse: polar (angle01, radius) -> Cartesian uv
float2 RenderLib_PolarToCartesianUV(float2 polar, float2 center)
{
    float angle = (polar.x - 0.5) * RENDERLIB_TWO_PI;
    float2 offset = float2(cos(angle), sin(angle)) * polar.y;
    return center + offset;
}

// ---------------------------------------------------------------------------
// TriplanarSample: world-space projection without explicit UVs
// Requires TEXTURE2D_* macros from URP Core.hlsl
// scale = world units per texture repeat (e.g. 0.25 = 4 repeats per meter)
// ---------------------------------------------------------------------------

float3 RenderLib_TriplanarBlendWeights(float3 normalWS, float sharpness)
{
    float3 weights = abs(normalWS);
    weights = pow(weights, sharpness);
    return weights / max(dot(weights, float3(1.0, 1.0, 1.0)), RENDERLIB_EPSILON);
}

// Note: uses RENDERLIB_EPSILON from Common.hlsl when included via RenderLibCore.
// If UV.hlsl is included alone, define a local fallback:
#ifndef RENDERLIB_COMMON_INCLUDED
static const float RENDERLIB_EPSILON = 1e-5;
#endif

half4 RenderLib_TriplanarSample(
    TEXTURE2D_PARAM(tex, samplerTex),
    float3 positionWS,
    float3 normalWS,
    float  scale,
    float  sharpness)
{
    float3 blendWeights = RenderLib_TriplanarBlendWeights(normalWS, sharpness);
    float3 scaledPos = positionWS * scale;

    // X-facing plane samples YZ, Y-facing samples XZ, Z-facing samples XY
    half4 sampleX = SAMPLE_TEXTURE2D(tex, samplerTex, scaledPos.yz);
    half4 sampleY = SAMPLE_TEXTURE2D(tex, samplerTex, scaledPos.xz);
    half4 sampleZ = SAMPLE_TEXTURE2D(tex, samplerTex, scaledPos.xy);

    return sampleX * blendWeights.x
         + sampleY * blendWeights.y
         + sampleZ * blendWeights.z;
}

half4 RenderLib_TriplanarSample(
    TEXTURE2D_PARAM(tex, samplerTex),
    float3 positionWS,
    float3 normalWS,
    float  scale)
{
    return RenderLib_TriplanarSample(TEXTURE2D_ARGS(tex, samplerTex), positionWS, normalWS, scale, RENDERLIB_TRIPLANAR_SHARPNESS);
}

// RGB-only variant (common for albedo; skips alpha blending artifacts)
half3 RenderLib_TriplanarSampleRGB(
    TEXTURE2D_PARAM(tex, samplerTex),
    float3 positionWS,
    float3 normalWS,
    float  scale,
    float  sharpness)
{
    return RenderLib_TriplanarSample(TEXTURE2D_ARGS(tex, samplerTex), positionWS, normalWS, scale, sharpness).rgb;
}

half3 RenderLib_TriplanarSampleRGB(
    TEXTURE2D_PARAM(tex, samplerTex),
    float3 positionWS,
    float3 normalWS,
    float  scale)
{
    return RenderLib_TriplanarSample(TEXTURE2D_ARGS(tex, samplerTex), positionWS, normalWS, scale).rgb;
}

#endif // RENDERLIB_UV_INCLUDED