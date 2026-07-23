#ifndef RENDERLIB_OUTLINE_POST_PASS_INCLUDED
#define RENDERLIB_OUTLINE_POST_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"
#include "Assets/_Core/HLSL/Depth.hlsl"
#include "RenderLib_OutlinePostPassInput.hlsl"

// Sobel weights:
// Gx: -1 0 1    Gy: -1 -2 -1
//     -2 0 2         0  0  0
//     -1 0 1         1  2  1

float SampleEyeDepth(float2 uv)
{
    return RenderLib_SampleSceneEyeDepth(uv);
}

float3 SampleNormalWS(float2 uv)
{
    return SampleSceneNormals(uv);
}

float SobelDepth(float2 uv, float2 texel)
{
    float d00 = SampleEyeDepth(uv + texel * float2(-1, -1));
    float d10 = SampleEyeDepth(uv + texel * float2( 0, -1));
    float d20 = SampleEyeDepth(uv + texel * float2( 1, -1));
    float d01 = SampleEyeDepth(uv + texel * float2(-1,  0));
    float d21 = SampleEyeDepth(uv + texel * float2( 1,  0));
    float d02 = SampleEyeDepth(uv + texel * float2(-1,  1));
    float d12 = SampleEyeDepth(uv + texel * float2( 0,  1));
    float d22 = SampleEyeDepth(uv + texel * float2( 1,  1));

    float gx = -d00 + d20 - 2.0 * d01 + 2.0 * d21 - d02 + d22;
    float gy = -d00 - 2.0 * d10 - d20 + d02 + 2.0 * d12 + d22;
    return sqrt(gx * gx + gy * gy);
}

float SobelNormal(float2 uv, float2 texel)
{
    float3 n00 = SampleNormalWS(uv + texel * float2(-1, -1));
    float3 n10 = SampleNormalWS(uv + texel * float2( 0, -1));
    float3 n20 = SampleNormalWS(uv + texel * float2( 1, -1));
    float3 n01 = SampleNormalWS(uv + texel * float2(-1,  0));
    float3 n21 = SampleNormalWS(uv + texel * float2( 1,  0));
    float3 n02 = SampleNormalWS(uv + texel * float2(-1,  1));
    float3 n12 = SampleNormalWS(uv + texel * float2( 0,  1));
    float3 n22 = SampleNormalWS(uv + texel * float2( 1,  1));

    float3 gx = -n00 + n20 - 2.0 * n01 + 2.0 * n21 - n02 + n22;
    float3 gy = -n00 - 2.0 * n10 - n20 + n02 + 2.0 * n12 + n22;
    return sqrt(dot(gx, gx) + dot(gy, gy));
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord;
    float2 texel = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);

    float depthEdge = SobelDepth(uv, texel);
    float normalEdge = SobelNormal(uv, texel);

    // Depth is in meters → scale down so thickness stays artist-friendly.
    float edge = max(depthEdge * 0.25, normalEdge);
    edge = saturate(edge * _Thickness);

    half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
    color.rgb = lerp(color.rgb, _OutlineColor.rgb, edge * saturate(_Intensity));
    return color;
}

#endif // RENDERLIB_OUTLINE_POST_PASS_INCLUDED