#ifndef RENDERLIB_WATER_INPUT_INCLUDED
#define RENDERLIB_WATER_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E041 Water — material constants
// Property names must match RenderLib_Water.shader Properties.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _ShallowColor;       // color when water is thin (small depth gap)
    half4  _DeepColor;          // color when water is deep (large depth gap)
    float4 _NormalMap_ST;       // tiling / offset for normal map
    half   _NormalScale;        // bump strength
    float4 _NormalSpeed;        // xy = layer0 scroll, zw = layer1 scroll (UV / sec)
    half   _DepthDistance;      // meters: depthGap at which color reaches Deep
    half   _ShoreFadeDistance;  // meters: soft edge width at shoreline
    half   _Smoothness;         // specular sharpness (higher = tighter highlight)
    half   _SpecularIntensity;  // specular brightness
    half   _FresnelPower;       // edge fresnel power (higher = tighter rim)
    half   _AmbientStrength;    // flat ambient so water is visible in shadow
CBUFFER_END

TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);

#endif // RENDERLIB_WATER_INPUT_INCLUDED