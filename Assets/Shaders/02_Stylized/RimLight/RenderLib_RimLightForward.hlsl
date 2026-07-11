#ifndef RENDERLIB_RIMLIGHT_FORWARD_INCLUDED
#define RENDERLIB_RIMLIGHT_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_RimLightInput.hlsl"

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
    float3 positionWS : TEXCOORD2;
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
    output.positionWS = positionInputs.positionWS;
    output.normalWS = normalInputs.normalWS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;

    // Base: simple Lambert diffuse + flat ambient (so rim is visible in shadow)
    Light mainLight = GetMainLight();
    half ndotl = half(RenderLib_NdotL(input.normalWS, mainLight.direction));
    half3 diffuse = albedo.rgb * mainLight.color * ndotl;
    half3 ambient = albedo.rgb * _AmbientStrength;

    // Rim: view-dependent edge highlight (additive)
    half3 viewDirWS = GetWorldSpaceViewDir(input.positionWS);
    half3 rim = RenderLib_RimLightColor(
        input.normalWS,
        viewDirWS,
        _RimPower,
        _RimColor.rgb,
        _RimIntensity);

    return half4(diffuse + ambient + rim, albedo.a);
}

#endif // RENDERLIB_RIMLIGHT_FORWARD_INCLUDED