#ifndef RENDERLIB_TEMPLATE_UI_INPUT_INCLUDED
#define RENDERLIB_TEMPLATE_UI_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _Color;
    half4 _TextureSampleAdd;
    float4 _ClipRect;
CBUFFER_END

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

#endif // RENDERLIB_TEMPLATE_UI_INPUT_INCLUDED
