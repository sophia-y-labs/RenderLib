#ifndef RENDERLIB_UVDISTORT_INPUT_INCLUDED
#define RENDERLIB_UVDISTORT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E016 UVDistortion — material constants
// Property names must match RenderLib_UVDistort.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float4 _ScrollDirection; // xy used; zw unused (Vector property packing)
    half   _DistortStrength;
    half   _NoiseScale;
    half   _Speed;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_UVDISTORT_INPUT_INCLUDED
