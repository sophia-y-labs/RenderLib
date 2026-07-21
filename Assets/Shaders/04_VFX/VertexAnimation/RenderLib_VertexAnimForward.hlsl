#ifndef RENDERLIB_VERTEXANIM_FORWARD_INCLUDED
#define RENDERLIB_VERTEXANIM_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "RenderLib_VertexAnimInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
    float3 normalOS   : NORMAL;
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

    float3 positionOS = input.positionOS.xyz;

    // Phase from object-space X so neighboring verts offset differently
    float wave = sin(_Time.y * _Speed + positionOS.x * _Frequency);
    positionOS += input.normalOS * (wave * _Amplitude);

    // Transform AFTER displacement (important)
    VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);

    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
    return albedo;
}

#endif // RENDERLIB_VERTEXANIM_FORWARD_INCLUDED