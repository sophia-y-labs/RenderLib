#ifndef RENDERLIB_OUTLINE_POST_PASS_INPUT_INCLUDED
#define RENDERLIB_OUTLINE_POST_PASS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Keep in sync with RenderLibOutlinePostFeature property IDs.

CBUFFER_START(UnityPerMaterial)
    half _Intensity;
    float _Thickness;
    half4 _OutlineColor;
CBUFFER_END

#endif // RENDERLIB_OUTLINE_POST_PASS_INPUT_INCLUDED