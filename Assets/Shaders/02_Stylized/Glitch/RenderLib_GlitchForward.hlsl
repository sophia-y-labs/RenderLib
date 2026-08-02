#ifndef RENDERLIB_GLITCH_FORWARD_INCLUDED
#define RENDERLIB_GLITCH_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_GlitchInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs positionInputs = GetVertexPositionInputs(input.positionOS.xyz);

    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv;

    // --- Band ID: quantize V into discrete rows ---
    float bandCount = max((float)_BandCount, 1.0);
    float band = floor(uv.y * bandCount);

    // --- Per-band noise: jumps over time (digital glitch feel) ---
    float n = RenderLib_ValueNoise2D(float2(band * (float)_NoiseScale, _Time.y * (float)_Speed));

    // --- Conditional UV.x slice: only bands above threshold displace ---
    float glitch = step((float)_BandThreshold, n) * (float)_GlitchStrength;
    float offsetX = (n - 0.5) * 2.0 * (float)_MaxOffset * glitch;
    float2 uvG = uv + float2(offsetX, 0.0);

    // --- Chromatic aberration: R/G/B sample slightly different UVs ---
    float2 chroma = float2((float)_ChromaSpread * glitch, 0.0);
    half4 sampleR = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvG + chroma);
    half4 sampleG = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvG);
    half4 sampleB = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvG - chroma);

    half3 color = half3(sampleR.r, sampleG.g, sampleB.b) * _BaseColor.rgb;
    half  alpha = sampleG.a * _BaseColor.a;

    return half4(color, alpha);
}

#endif // RENDERLIB_GLITCH_FORWARD_INCLUDED
