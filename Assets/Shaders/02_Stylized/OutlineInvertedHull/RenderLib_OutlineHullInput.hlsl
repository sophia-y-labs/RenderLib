#ifndef RENDERLIB_OUTLINEHULL_INPUT_INCLUDED
#define RENDERLIB_OUTLINEHULL_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E012 OutlineHull — shared constants for Forward + Hull passes
// Property names must match RenderLib_OutlineHull.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half4  _OutlineColor;
    float4 _BaseMap_ST;
    half   _OutlineWidth;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_OUTLINEHULL_INPUT_INCLUDED