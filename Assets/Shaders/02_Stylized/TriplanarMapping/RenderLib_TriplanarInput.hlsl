#ifndef RENDERLIB_TRIPLANAR_INPUT_INCLUDED
#define RENDERLIB_TRIPLANAR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// ---------------------------------------------------------------------------
// E017 TriplanarMapping — material constants
// Property names must match RenderLib_Triplanar.shader Properties block.
// ---------------------------------------------------------------------------

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST; // kept for material UI consistency; sampling uses world scale
    half   _TriplanarScale;
    half   _BlendSharpness;
    half   _Ambient;
CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

#endif // RENDERLIB_TRIPLANAR_INPUT_INCLUDED
