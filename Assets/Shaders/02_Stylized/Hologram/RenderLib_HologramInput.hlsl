#ifndef RENDERLIB_HOLOGRAM_INPUT_INCLUDED
#define RENDERLIB_HOLOGRAM_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E013 Hologram — material constants
// Property names must match RenderLib_Hologram.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half4  _HologramColor;
    float4 _BaseMap_ST;
    half   _Alpha;
    half   _ScanlineCount;
    half   _ScanlineSpeed;
    half   _ScanlineWidth;
    half   _ScanlineIntensity;
    half   _FresnelPower;
    half   _FresnelIntensity;
    half   _NoiseScale;
    half   _FlickerStrength;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_HOLOGRAM_INPUT_INCLUDED