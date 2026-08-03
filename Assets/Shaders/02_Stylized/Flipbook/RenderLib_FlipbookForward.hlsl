#ifndef RENDERLIB_FLIPBOOK_FORWARD_INCLUDED
#define RENDERLIB_FLIPBOOK_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_FlipbookInput.hlsl"

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

    // Auto-play from time, or lock a single atlas cell for debugging
    float frame = ((float)_Frame >= 0.0)
        ? (float)_Frame
        : floor(_Time.y * (float)_FPS);

    float2 uvF = RenderLib_FlipbookUV(
        input.uv,
        (float)_Columns,
        (float)_Rows,
        frame);

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvF) * _BaseColor;
    return albedo;
}

#endif // RENDERLIB_FLIPBOOK_FORWARD_INCLUDED
