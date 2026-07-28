#ifndef RENDERLIB_PROCEDURAL_SKY_INPUT_INCLUDED
#define RENDERLIB_PROCEDURAL_SKY_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E040 ProceduralSky — material constants
// Property names must match RenderLib_ProceduralSky.shader Properties.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4 _ZenithColor;     // color at sky top (viewDir.y -> +1)
    half4 _HorizonColor;    // color at horizon (viewDir.y -> 0)
    half4 _GroundColor;     // color below horizon (viewDir.y -> -1)
    half  _Exposure;        // overall brightness multiplier
    half  _SunSize;         // angular size of sun disk (larger = softer)
    half  _SunIntensity;    // sun disk brightness
    half  _HorizonExponent; // how sharp the zenith/horizon transition is
CBUFFER_END

#endif // RENDERLIB_PROCEDURAL_SKY_INPUT_INCLUDED