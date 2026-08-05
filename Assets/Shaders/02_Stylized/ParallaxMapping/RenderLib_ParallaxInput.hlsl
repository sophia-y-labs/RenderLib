#ifndef RENDERLIB_PARALLAX_INPUT_INCLUDED
#define RENDERLIB_PARALLAX_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// ParallaxMapping — material constants
// Property names must match RenderLib_Parallax.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float4 _HeightMap_ST;
    half   _HeightScale;
    half   _Ambient;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
TEXTURE2D(_HeightMap);
SAMPLER(sampler_HeightMap);

#endif // RENDERLIB_PARALLAX_INPUT_INCLUDED
