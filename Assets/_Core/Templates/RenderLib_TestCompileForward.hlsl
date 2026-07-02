#ifndef RENDERLIB_TEST_COMPILE_FORWARD_INCLUDED
#define RENDERLIB_TEST_COMPILE_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_TestCompileInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 normalWS   : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Core linkage smoke test — uses world-space normal + fixed up vector.
    // Kept separate from albedo so _BaseColor responds 1:1 to the Material picker.
    float coreLink = RenderLib_NdotL(input.normalWS, float3(0.0, 1.0, 0.0));

    // Inspector Color is sRGB; output directly (no LinearToSRGB on material albedo).
    half3 albedo = _BaseColor.rgb;

    // Subtle shading proves Core ran; scale is small so Base Color remains dominant.
    albedo *= half(lerp(0.35, 1.0, coreLink));

    return half4(albedo, _BaseColor.a);
}

#endif // RENDERLIB_TEST_COMPILE_FORWARD_INCLUDED
