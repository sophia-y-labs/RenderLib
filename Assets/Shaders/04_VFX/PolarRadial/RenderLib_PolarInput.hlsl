#ifndef RENDERLIB_POLAR_INPUT_INCLUDED
#define RENDERLIB_POLAR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E026 PolarRadial — material constants
// Property names must match RenderLib_Polar.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float4 _Center;       // xy = polar origin in UV space (default 0.5, 0.5)
    half   _RadialScale;
    half   _AngleRepeat;
    half   _SpinSpeed;
    half   _RadialSpeed;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_POLAR_INPUT_INCLUDED
