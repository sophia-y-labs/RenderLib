#ifndef RENDERLIB_FLOWMAP_INPUT_INCLUDED
#define RENDERLIB_FLOWMAP_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// FlowMap — material constants
// Property names must match RenderLib_FlowMap.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float4 _FlowMap_ST;
    half   _FlowStrength;
    half   _FlowSpeed;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_FlowMap);
SAMPLER(sampler_FlowMap);

#endif // RENDERLIB_FLOWMAP_INPUT_INCLUDED
