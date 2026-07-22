#ifndef RENDERLIB_PIXELATION_PASS_INCLUDED
#define RENDERLIB_PIXELATION_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
#include "RenderLib_PixelationPassInput.hlsl"

// Uses Blit.hlsl Vert + _BlitTexture (URP Blitter API).
// Pixelation = quantize UV into a screen-space grid, then point-sample.

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord;

    // _ScreenParams.xy = camera pixel width/height (stable with URP Blitter).
    float2 screenSize = max(_ScreenParams.xy, float2(1.0, 1.0));
    float pixelSize = max(_PixelSize, 1.0);
    float2 grid = max(screenSize / pixelSize, float2(1.0, 1.0));

    // Snap UV to the lower-left of each block (whole block shares one sample).
    float2 uvQuantized = floor(uv * grid) / grid;

    half4 pixelated = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_PointClamp, uvQuantized);
    half4 original = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);

    return lerp(original, pixelated, saturate(_Intensity));
}

#endif // RENDERLIB_PIXELATION_PASS_INCLUDED
