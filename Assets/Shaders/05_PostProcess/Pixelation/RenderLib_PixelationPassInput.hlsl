#ifndef RENDERLIB_PIXELATION_PASS_INPUT_INCLUDED
#define RENDERLIB_PIXELATION_PASS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Keep in sync with RenderLibPixelationFeature property IDs.

CBUFFER_START(UnityPerMaterial)
    half _Intensity;
    float _PixelSize;
CBUFFER_END

#endif // RENDERLIB_PIXELATION_PASS_INPUT_INCLUDED
