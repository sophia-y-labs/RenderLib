#ifndef RENDERLIB_VERTEXANIM_INPUT_INCLUDED
#define RENDERLIB_VERTEXANIM_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float  _Amplitude;
    float  _Speed;
    float  _Frequency;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_VERTEXANIM_INPUT_INCLUDED