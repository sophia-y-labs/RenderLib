#ifndef RENDERLIB_SOFTPARTICLE_INPUT_INCLUDED
#define RENDERLIB_SOFTPARTICLE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    float4 _BaseMap_ST;
    float _SoftFadeDistance;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_SOFTPARTICLE_INPUT_INCLUDED