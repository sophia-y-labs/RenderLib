#ifndef RENDERLIB_TEMPLATE_POSTPASS_INPUT_INCLUDED
#define RENDERLIB_TEMPLATE_POSTPASS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// Full-screen post parameters. Keep in sync with RenderLibPostProcessBase property IDs.

CBUFFER_START(UnityPerMaterial)
    half _Intensity;
CBUFFER_END

#endif // RENDERLIB_TEMPLATE_POSTPASS_INPUT_INCLUDED
