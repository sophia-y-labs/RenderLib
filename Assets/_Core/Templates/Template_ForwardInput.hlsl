#ifndef RENDERLIB_TEMPLATE_FORWARD_INPUT_INCLUDED
#define RENDERLIB_TEMPLATE_FORWARD_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// Template Forward — material constants
// Copy and rename when creating a new Forward effect.
// Keep property names in sync with the matching .shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    float4 _BaseMap_ST;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_TEMPLATE_FORWARD_INPUT_INCLUDED
