#ifndef RENDERLIB_DISSOLVE_FORWARD_INCLUDED
#define RENDERLIB_DISSOLVE_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_DissolveInput.hlsl"

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

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;

    float2 noiseUV = input.uv * _NoiseScale + _NoiseOffset;
    float noise = RenderLib_ValueNoise2D(noiseUV);

    // Discard fragments below the dissolve threshold.
    clip(noise - _DissolveAmount);

    // Edge band: brighten near the threshold boundary.
    float edgeFactor = 1.0 - smoothstep(0.0, _EdgeWidth, abs(noise - _DissolveAmount));
    half3 color = lerp(albedo.rgb, _EdgeColor.rgb, half(edgeFactor * _EdgeColor.a));

    return half4(color, albedo.a);
}

#endif // RENDERLIB_DISSOLVE_FORWARD_INCLUDED
