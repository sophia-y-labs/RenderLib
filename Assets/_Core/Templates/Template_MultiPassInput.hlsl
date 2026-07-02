#ifndef RENDERLIB_TEMPLATE_MULTIPASS_INPUT_INCLUDED
#define RENDERLIB_TEMPLATE_MULTIPASS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Shared material constants for Forward + Outline passes.

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    half4 _OutlineColor;
    float _OutlineWidth;
    float4 _BaseMap_ST;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_TEMPLATE_MULTIPASS_INPUT_INCLUDED
