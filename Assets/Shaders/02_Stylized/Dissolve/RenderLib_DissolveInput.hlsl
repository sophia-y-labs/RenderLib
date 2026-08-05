#ifndef RENDERLIB_DISSOLVE_INPUT_INCLUDED
#define RENDERLIB_DISSOLVE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// Dissolve / DissolveDirectional — shared material constants
// Dissolve Properties block omits direction fields; DissolveDirectional exposes them.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half4  _EdgeColor;
    float4 _BaseMap_ST;
    half   _DissolveAmount;
    half   _EdgeWidth;
    half   _NoiseScale;
    float2 _NoiseOffset;
    float4 _DissolveDirection;  // xyz = object-space sweep direction
    half   _DirectionScale;     // remap dot(position, dir) to ~[0,1]
    half   _NoiseStrength;      // noise perturbation on the sweep front
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_DISSOLVE_INPUT_INCLUDED
