#ifndef RENDERLIB_MATCAP_FORWARD_INCLUDED
#define RENDERLIB_MATCAP_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_MatCapInput.hlsl"

// ---------------------------------------------------------------------------
// E005 MatCap — view-space normal lookup (no main light required)
// matcapUV = encode(mul(V, N).xy) into [0,1]
// ---------------------------------------------------------------------------

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
    float3 normalWS   : TEXCOORD1;
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
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);

    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.normalWS = normalInputs.normalWS;

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;

    // World normal -> view space (rotation only; ignore translation).
    half3 nWS = half3(RenderLib_SafeNormalize(input.normalWS));
    half3 nVS = mul((half3x3)UNITY_MATRIX_V, nWS);
    float2 matcapUV = float2(nVS.xy) * 0.5 + 0.5;

    half3 matcap = SAMPLE_TEXTURE2D(_MatCapMap, sampler_MatCapMap, matcapUV).rgb;
    half3 color = albedo.rgb * lerp(half3(1.0h, 1.0h, 1.0h), matcap, _MatCapIntensity);

    return half4(color, albedo.a);
}

#endif // RENDERLIB_MATCAP_FORWARD_INCLUDED
