#ifndef RENDERLIB_PARALLAX_FORWARD_INCLUDED
#define RENDERLIB_PARALLAX_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_ParallaxInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS  : SV_POSITION;
    float2 uv          : TEXCOORD0;
    float3 positionWS  : TEXCOORD1;
    float3 normalWS    : TEXCOORD2;
    float3 tangentWS   : TEXCOORD3;
    float3 bitangentWS : TEXCOORD4;
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
    // Pass tangent so URP builds a correct TBN (handles tangent.w / mirroring)
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.positionCS = positionInputs.positionCS;
    output.positionWS = positionInputs.positionWS;
    output.normalWS = normalInputs.normalWS;
    output.tangentWS = normalInputs.tangentWS;
    output.bitangentWS = normalInputs.bitangentWS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv;

    // TBN rows = T, B, N → mul(tbn, v) transforms world → tangent
    float3x3 tbn = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    float3 viewDirTS = normalize(mul(tbn, viewDirWS));

    // Simple parallax offset (not steep/POM): shift UV along view in tangent space
    float height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uv).r;
    float2 offset = (viewDirTS.xy / max(viewDirTS.z, 0.01)) * height * (float)_HeightScale;
    float2 uvP = uv + offset;

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvP) * _BaseColor;

    Light mainLight = GetMainLight();
    half ndotl = half(RenderLib_NdotL(input.normalWS, mainLight.direction));
    half3 diffuse = albedo.rgb * mainLight.color * ndotl;
    half3 ambient = albedo.rgb * _Ambient;

    return half4(diffuse + ambient, albedo.a);
}

#endif // RENDERLIB_PARALLAX_FORWARD_INCLUDED
