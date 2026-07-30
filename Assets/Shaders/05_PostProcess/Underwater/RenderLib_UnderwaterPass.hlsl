#ifndef RENDERLIB_UNDERWATER_PASS_INCLUDED
#define RENDERLIB_UNDERWATER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
#include "Assets/_Core/HLSL/Depth.hlsl"
#include "RenderLib_UnderwaterPassInput.hlsl"

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord;

    // 1) Current frame color (URP Blitter binds this as _BlitTexture)
    half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);

    // 2) Eye-space depth in meters (requires Depth Texture + Feature ConfigureInput)
    float eyeDepth = RenderLib_SampleSceneEyeDepth(uv);

    // 3) Exponential fog: near ~0, far → 1
    //    fog = 1 - e^(-density * distance)
    float density = max((float)_FogDensity, 0.0);
    float fog = 1.0 - exp(-density * eyeDepth);
    fog = saturate(fog);

    half w = saturate(_Intensity) * half(fog);

    // 4) Spectral absorption: distant pixels lose red first (looks "colder")
    half3 absorbed = color.rgb * lerp(half3(1, 1, 1), _Absorption.rgb, w);

    // 5) Mix toward underwater fog color
    color.rgb = lerp(absorbed, _UnderwaterColor.rgb, w);

    return color;
}

#endif // RENDERLIB_UNDERWATER_PASS_INCLUDED