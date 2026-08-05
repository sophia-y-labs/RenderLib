#ifndef RENDERLIB_TOONLIT_INPUT_INCLUDED
#define RENDERLIB_TOONLIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// ToonLit — material constants
// Property names must match RenderLib_ToonLit.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float4 _RampMap_ST;
    half   _RampSteps;
    half4  _RimColor;
    half   _RimPower;
    half   _RimIntensity;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_RampMap);
SAMPLER(sampler_RampMap);

#endif // RENDERLIB_TOONLIT_INPUT_INCLUDED