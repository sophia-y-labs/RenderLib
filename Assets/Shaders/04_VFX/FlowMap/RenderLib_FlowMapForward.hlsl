#ifndef RENDERLIB_FLOWMAP_FORWARD_INCLUDED
#define RENDERLIB_FLOWMAP_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_FlowMapInput.hlsl"

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
    float2 uvFlow     : TEXCOORD1;
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
    output.uv     = TRANSFORM_TEX(input.uv, _BaseMap);
    output.uvFlow = TRANSFORM_TEX(input.uv, _FlowMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Sample flow field once; RG encodes direction (0.5 = rest)
    half2 flowRG = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, input.uvFlow).rg;
    float2 flow  = RenderLib_DecodeFlow(flowRG);

    float time01 = _Time.y * (float)_FlowSpeed;

    float2 uv0, uv1;
    float  blend;
    RenderLib_FlowMapUVs(input.uv, flow, time01, (float)_FlowStrength, uv0, uv1, blend);

    // Dual-phase albedo samples hide frac wrap discontinuity
    half4 sample0 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv0);
    half4 sample1 = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv1);
    half4 albedo  = lerp(sample1, sample0, blend) * _BaseColor;

    return albedo;
}

#endif // RENDERLIB_FLOWMAP_FORWARD_INCLUDED
