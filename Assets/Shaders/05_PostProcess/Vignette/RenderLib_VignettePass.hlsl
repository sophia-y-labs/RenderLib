#ifndef RENDERLIB_VIGNETTE_PASS_INCLUDED
#define RENDERLIB_VIGNETTE_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
#include "RenderLib_VignettePassInput.hlsl"

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord;
    half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);

    // Map UV to [-1, 1] so screen center is (0, 0).
    float2 uvCentered = uv * 2.0 - 1.0;
    // Slight aspect correction so the vignette is closer to a circle on widescreen.
    uvCentered.x *= _ScreenParams.x / max(_ScreenParams.y, 1.0);

    float dist = length(uvCentered);
    float smoothness = max(_Smoothness, 0.01);
    float inner = max(1.0 - smoothness, 0.0);
    float outer = 1.0;
    float mask = smoothstep(inner, outer, dist);

    half3 darkened = color.rgb * _VignetteColor.rgb;
    color.rgb = lerp(color.rgb, darkened, mask * saturate(_Intensity));
    return color;
}

#endif // RENDERLIB_VIGNETTE_PASS_INCLUDED