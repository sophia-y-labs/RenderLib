#ifndef RENDERLIB_UNDERWATER_PASS_INPUT_INCLUDED
#define RENDERLIB_UNDERWATER_PASS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// Underwater — blit material constants
// Keep names in sync with Volume → Feature SetFloat/SetColor IDs.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half  _Intensity;        // 0 = off, 1 = full effect
    half  _FogDensity;       // higher = fog thickens faster with distance
    half4 _UnderwaterColor;  // fog / ambient water tint
    half4 _Absorption;       // per-channel survival (rgb); r usually lowest underwater
CBUFFER_END

#endif // RENDERLIB_UNDERWATER_PASS_INPUT_INCLUDED