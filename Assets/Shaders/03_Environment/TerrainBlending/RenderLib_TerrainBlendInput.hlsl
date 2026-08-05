#ifndef RENDERLIB_TERRAIN_BLEND_INPUT_INCLUDED
#define RENDERLIB_TERRAIN_BLEND_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// TerrainBlend — material constants
// Control.RGBA weights Layer0..3. Layer alpha is used as height for blending.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    float4 _ControlMap_ST;
    float4 _Layer0Map_ST;
    float4 _Layer1Map_ST;
    float4 _Layer2Map_ST;
    float4 _Layer3Map_ST;

    // Larger = sharper transitions between layers (height blend).
    half _HeightBlend;
    half _AmbientStrength;
CBUFFER_END

TEXTURE2D(_ControlMap);
SAMPLER(sampler_ControlMap);

TEXTURE2D(_Layer0Map);
SAMPLER(sampler_Layer0Map);
TEXTURE2D(_Layer1Map);
SAMPLER(sampler_Layer1Map);
TEXTURE2D(_Layer2Map);
SAMPLER(sampler_Layer2Map);
TEXTURE2D(_Layer3Map);
SAMPLER(sampler_Layer3Map);

#endif // RENDERLIB_TERRAIN_BLEND_INPUT_INCLUDED