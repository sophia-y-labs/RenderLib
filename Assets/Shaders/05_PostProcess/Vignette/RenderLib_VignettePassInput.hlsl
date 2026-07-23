#ifndef RENDERLIB_VIGNETTE_PASS_INPUT_INCLUDED
#define RENDERLIB_VIGNETTE_PASS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half _Intensity;
    float _Smoothness;
    half4 _VignetteColor;
CBUFFER_END

#endif // RENDERLIB_VIGNETTE_PASS_INPUT_INCLUDED