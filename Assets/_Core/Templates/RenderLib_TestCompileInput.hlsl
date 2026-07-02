#ifndef RENDERLIB_TEST_COMPILE_INPUT_INCLUDED
#define RENDERLIB_TEST_COMPILE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
CBUFFER_END

#endif // RENDERLIB_TEST_COMPILE_INPUT_INCLUDED
