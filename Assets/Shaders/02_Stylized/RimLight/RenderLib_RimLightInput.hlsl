#ifndef RENDERLIB_RIMLIGHT_INPUT_INCLUDED
#define RENDERLIB_RIMLIGHT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// RimLight — material constants
// Property names must match RenderLib_RimLight.shader Properties block.
// Rim property names align with ToonLit for consistency.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half4  _RimColor;
    float4 _BaseMap_ST;
    half   _RimPower;
    half   _RimIntensity;
    half   _AmbientStrength;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_RIMLIGHT_INPUT_INCLUDED