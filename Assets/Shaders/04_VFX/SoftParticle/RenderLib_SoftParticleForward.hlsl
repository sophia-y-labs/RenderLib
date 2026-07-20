#ifndef RENDERLIB_SOFTPARTICLE_FORWARD_INCLUDED
#define RENDERLIB_SOFTPARTICLE_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_SoftParticleInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
    half4 color       : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
    half4 color         : COLOR;
    float4 projectedPos : TEXCOORD1; // ComputeScreenPos result for soft fade
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
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.color = input.color;

    // Screen-space pos: xy/w = UV, zw keep clip depth for eye-depth convert
    output.projectedPos = ComputeScreenPos(output.positionCS);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 col = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    col *= _BaseColor * input.color;

    // Soft fade when particle approaches scene geometry
    float fade = RenderLib_SoftParticleFade(input.projectedPos, _SoftFadeDistance);
    col.a *= half(fade);

    return col;
}

#endif // RENDERLIB_SOFTPARTICLE_FORWARD_INCLUDED