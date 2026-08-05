#ifndef RENDERLIB_FLIPBOOK_INPUT_INCLUDED
#define RENDERLIB_FLIPBOOK_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// Flipbook — material constants
// Property names must match RenderLib_Flipbook.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    half   _Columns;
    half   _Rows;
    half   _FPS;
    half   _Frame; // < 0 = play from time; >= 0 = lock frame index
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_FLIPBOOK_INPUT_INCLUDED
