#ifndef RENDERLIB_COLOR_INCLUDED
#define RENDERLIB_COLOR_INCLUDED

// ---------------------------------------------------------------------------
// RenderLib Color Utilities
// HSV conversion, Photoshop-style blend modes, and 2D strip LUT lookup.
// No URP dependency except ApplyLUT2D (needs TEXTURE2D_* from Core.hlsl).
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// HSV <-> RGB
// Convention: H in [0, 1) = full hue circle (0=Red, 1/3=Green, 2/3=Blue)
//             S in [0, 1] = saturation (0=gray, 1=pure color)
//             V in [0, 1] = value / brightness
// ---------------------------------------------------------------------------

float3 RenderLib_HSVtoRGB(float3 hsv)
{
    // Extract components for readability
    float h = hsv.x;
    float s = hsv.y;
    float v = hsv.z;

    // "Chroma" = colorfulness at full saturation for this brightness
    float c = v * s;

    // Map hue [0,1) to sector [0,6): which sextant of the color wheel
    float h6 = frac(h) * 6.0;

    // Intermediate color component within the current sextant
    float x = c * (1.0 - abs(fmod(h6, 2.0) - 1.0));

    // Amount to add to all channels to reach target brightness V
    float m = v - c;

    float3 rgb;

    // Each branch picks (R,G,B) for one 60-degree slice of the hue wheel
    if (h6 < 1.0)      rgb = float3(c, x, 0.0);
    else if (h6 < 2.0) rgb = float3(x, c, 0.0);
    else if (h6 < 3.0) rgb = float3(0.0, c, x);
    else if (h6 < 4.0) rgb = float3(0.0, x, c);
    else if (h6 < 5.0) rgb = float3(x, 0.0, c);
    else               rgb = float3(c, 0.0, x);

    // Add m to shift from "pure hue" to final brightness V
    return rgb + m;
}

half3 RenderLib_HSVtoRGB(half3 hsv)
{
    return half3(RenderLib_HSVtoRGB(float3(hsv)));
}

float3 RenderLib_RGBtoHSV(float3 rgb)
{
    // Find min/max among R,G,B — defines the "hex cone" geometry
    float cmax = max(rgb.r, max(rgb.g, rgb.b));
    float cmin = min(rgb.r, min(rgb.g, rgb.b));
    float delta = cmax - cmin;

    float h = 0.0;
    float s = 0.0;
    float v = cmax;

    // Saturation: how far from gray (avoid divide-by-zero when v=0)
    if (cmax > 0.0)
        s = delta / cmax;

    // Hue: which segment between min/max channels
    if (delta > 0.0)
    {
        if (cmax == rgb.r)
            h = (rgb.g - rgb.b) / delta + (rgb.g < rgb.b ? 6.0 : 0.0);
        else if (cmax == rgb.g)
            h = (rgb.b - rgb.r) / delta + 2.0;
        else
            h = (rgb.r - rgb.g) / delta + 4.0;

        h /= 6.0; // Normalize to [0, 1)
    }

    return float3(h, s, v);
}

half3 RenderLib_RGBtoHSV(half3 rgb)
{
    return half3(RenderLib_RGBtoHSV(float3(rgb)));
}

// ---------------------------------------------------------------------------
// Blend modes (Photoshop-style)
// base  = bottom layer (e.g. scene color, UI background)
// blend = top layer    (e.g. overlay texture, effect tint)
// All inputs expected in linear or same color space — stay consistent.
// ---------------------------------------------------------------------------

half3 RenderLib_BlendMultiply(half3 base, half3 blend)
{
    // Darkens: white(1) preserves base, black(0) kills it
    return base * blend;
}

half3 RenderLib_BlendAdd(half3 base, half3 blend)
{
    // Brightens additively; saturate prevents HDR blowout in LDR output
    return saturate(base + blend);
}

half3 RenderLib_BlendScreen(half3 base, half3 blend)
{
    // Inverse of Multiply: black preserves, white pushes toward white
    return 1.0 - (1.0 - base) * (1.0 - blend);
}

half3 RenderLib_BlendOverlay(half3 base, half3 blend)
{
    // Per-channel: dark base → Multiply-like, bright base → Screen-like
    half3 low  = 2.0 * base * blend;
    half3 high = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
    return lerp(low, high, step(0.5, base));
}

half3 RenderLib_BlendSoftLight(half3 base, half3 blend)
{
    // Softer contrast than Overlay; common in UI / photo effects
    half3 low  = base - (1.0 - 2.0 * blend) * base * (1.0 - base);
    half3 high = base + (2.0 * blend - 1.0) * (sqrt(base) - base);
    return lerp(low, high, step(0.5, blend));
}

// Alpha-over compositing: blend over base with opacity
half3 RenderLib_BlendAlphaOver(half3 base, half3 blend, half opacity)
{
    return lerp(base, blend, saturate(opacity));
}

// ---------------------------------------------------------------------------
// ApplyLUT2D: sample a 2D strip LUT (standard game-industry layout)
//
// LUT layout (lutSize = 32 example):
//   Texture size = (lutSize * lutSize) x lutSize  →  1024 x 32
//   Blue axis  → horizontal "slices" (32 slices side by side)
//   Red/Green  → within each slice (32 x 32 grid per slice)
//
// Requires URP Core.hlsl before use (TEXTURE2D_* macros).
// lutSize must match your LUT asset (typically 16, 32, or 64).
// ---------------------------------------------------------------------------

float3 RenderLib_ApplyLUT2D(
    TEXTURE2D_PARAM(lutTex, samplerLut),
    float3 color,
    float  lutSize)
{
    float3 c = saturate(color);
    float sizeMinusOne = lutSize - 1.0;

    // Which two blue "slices" to interpolate between
    float b      = c.b * sizeMinusOne;
    float bFloor = floor(b);
    float bFrac  = b - bFloor;

    // Pixel-center UV for slice bFloor
    float2 uv0;
    uv0.x = (c.r * sizeMinusOne + bFloor * lutSize + 0.5) / (lutSize * lutSize);
    uv0.y = (c.g * sizeMinusOne + 0.5) / lutSize;

    // Same R/G row, next blue slice
    float2 uv1;
    uv1.x = (c.r * sizeMinusOne + (bFloor + 1.0) * lutSize + 0.5) / (lutSize * lutSize);
    uv1.y = uv0.y;

    float3 col0 = SAMPLE_TEXTURE2D(lutTex, samplerLut, uv0).rgb;
    float3 col1 = SAMPLE_TEXTURE2D(lutTex, samplerLut, uv1).rgb;

    // Trilinear: bilinear within each slice + lerp along blue axis
    return lerp(col0, col1, bFrac);
}

half3 RenderLib_ApplyLUT2D(
    TEXTURE2D_PARAM(lutTex, samplerLut),
    half3  color,
    float  lutSize)
{
    return half3(RenderLib_ApplyLUT2D(TEXTURE2D_ARGS(lutTex, samplerLut), float3(color), lutSize));
}

#endif // RENDERLIB_COLOR_INCLUDED