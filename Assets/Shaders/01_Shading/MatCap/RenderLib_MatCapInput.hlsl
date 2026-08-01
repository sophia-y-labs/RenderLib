#ifndef RENDERLIB_MATCAP_INPUT_INCLUDED
#define RENDERLIB_MATCAP_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E005 MatCap — material constants
// Property names must match RenderLib_MatCap.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    float4 _BaseMap_ST;
    half _MatCapIntensity;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_MatCapMap);
SAMPLER(sampler_MatCapMap);

#endif // RENDERLIB_MATCAP_INPUT_INCLUDED
