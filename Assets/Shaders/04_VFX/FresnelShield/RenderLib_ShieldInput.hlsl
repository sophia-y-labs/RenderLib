#ifndef RENDERLIB_SHIELD_INPUT_INCLUDED
#define RENDERLIB_SHIELD_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half4  _ShieldColor;
    float4 _BaseMap_ST;
    half   _FresnelPower;
    half   _FresnelIntensity;
    half   _Alpha;
    half   _PulseSpeed;
    half   _PulseStrength;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_SHIELD_INPUT_INCLUDED