#ifndef RENDERLIB_LAMBERT_INPUT_INCLUDED
#define RENDERLIB_LAMBERT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// Lambert — material constants
// Property names must match RenderLib_Lambert.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    float4 _BaseMap_ST;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_LAMBERT_INPUT_INCLUDED