#ifndef RENDERLIB_DISSOLVE_INPUT_INCLUDED
#define RENDERLIB_DISSOLVE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E010 Dissolve — material constants
// Property names must match RenderLib_Dissolve.shader Properties block.
// Shared with E011 DissolveDirectional (same Input file).
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half4  _EdgeColor;
    float4 _BaseMap_ST;
    half   _DissolveAmount;
    half   _EdgeWidth;
    half   _NoiseScale;
    float2 _NoiseOffset;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_DISSOLVE_INPUT_INCLUDED
