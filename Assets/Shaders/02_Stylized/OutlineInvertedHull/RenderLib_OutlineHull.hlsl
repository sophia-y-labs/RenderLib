#ifndef RENDERLIB_OUTLINEHULL_INCLUDED
#define RENDERLIB_OUTLINEHULL_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "RenderLib_OutlineHullInput.hlsl"

struct HullAttributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct HullVaryings
{
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

HullVaryings HullVert(HullAttributes input)
{
    HullVaryings output = (HullVaryings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // Inverted hull: expand along object-space normal in the vertex stage.
    float3 positionOS = input.positionOS.xyz + input.normalOS * _OutlineWidth;
    output.positionCS = TransformObjectToHClip(positionOS);

    return output;
}

half4 HullFrag(HullVaryings input) : SV_Target
{
    return _OutlineColor;
}

#endif // RENDERLIB_OUTLINEHULL_INCLUDED