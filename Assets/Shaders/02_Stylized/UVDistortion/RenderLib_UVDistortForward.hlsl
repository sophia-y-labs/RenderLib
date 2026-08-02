#ifndef RENDERLIB_UVDISTORT_FORWARD_INCLUDED
#define RENDERLIB_UVDISTORT_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_UVDistortInput.hlsl"

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

    // Scroll noise domain over time (heat-haze / underwater feel)
    float2 noiseUV = uv * (float)_NoiseScale
                   + _Time.y * (float)_Speed * _ScrollDirection.xy;

    // Two decorrelated Simplex samples → independent X/Y push
    // (same seed on both axes would only shear along a diagonal)
    float nx = RenderLib_SimplexNoise2D(noiseUV);
    float ny = RenderLib_SimplexNoise2D(noiseUV + float2(17.13, 9.37));

    float2 uvD = uv + float2(nx, ny) * (float)_DistortStrength;

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvD) * _BaseColor;
    return albedo;
}

#endif // RENDERLIB_UVDISTORT_FORWARD_INCLUDED
