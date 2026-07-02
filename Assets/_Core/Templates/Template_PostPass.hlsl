#ifndef RENDERLIB_TEMPLATE_POSTPASS_INCLUDED
#define RENDERLIB_TEMPLATE_POSTPASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
#include "Template_PostPassInput.hlsl"

// Uses Blit.hlsl Vert + _BlitTexture (compatible with URP Blitter API).

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, input.texcoord);

    // Template effect: simple intensity tint for compile/runtime smoke test.
    color.rgb = lerp(color.rgb, half3(0.0, 1.0, 0.0), _Intensity * 0.25h);

    return color;
}

#endif // RENDERLIB_TEMPLATE_POSTPASS_INCLUDED
