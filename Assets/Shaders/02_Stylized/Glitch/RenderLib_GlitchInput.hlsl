#ifndef RENDERLIB_GLITCH_INPUT_INCLUDED
#define RENDERLIB_GLITCH_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// Glitch — material constants
// Property names must match RenderLib_Glitch.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    half   _GlitchStrength;
    half   _BandCount;
    half   _BandThreshold;
    half   _MaxOffset;
    half   _ChromaSpread;
    half   _NoiseScale;
    half   _Speed;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_GLITCH_INPUT_INCLUDED
