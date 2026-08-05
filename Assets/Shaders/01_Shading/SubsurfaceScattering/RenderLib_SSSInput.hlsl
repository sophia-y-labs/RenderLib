#ifndef RENDERLIB_SSS_INPUT_INCLUDED
#define RENDERLIB_SSS_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// SubsurfaceScattering — material constants
// Property names must match RenderLib_SSS.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    float4 _BaseMap_ST;
    half _WrapAmount;
    half4 _SSSColor;
    half _SSSPower;
    half _SSSIntensity;
    half _Thickness;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_ThicknessMap);
SAMPLER(sampler_ThicknessMap);

#endif // RENDERLIB_SSS_INPUT_INCLUDED
