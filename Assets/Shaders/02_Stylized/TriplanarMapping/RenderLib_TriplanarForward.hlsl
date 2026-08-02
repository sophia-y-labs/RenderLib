#ifndef RENDERLIB_TRIPLANAR_FORWARD_INCLUDED
#define RENDERLIB_TRIPLANAR_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_TriplanarInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 positionWS : TEXCOORD0;
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
    output.positionWS = positionInputs.positionWS;
    output.normalWS = normalInputs.normalWS;

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // World-space triplanar: no mesh UVs — X/Y/Z planes blended by normal
    half4 albedo = RenderLib_TriplanarSample(
        TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap),
        input.positionWS,
        input.normalWS,
        (float)_TriplanarScale,
        (float)_BlendSharpness) * _BaseColor;

    Light mainLight = GetMainLight();
    half ndotl = half(RenderLib_NdotL(input.normalWS, mainLight.direction));
    half3 diffuse = albedo.rgb * mainLight.color * ndotl;
    half3 ambient = albedo.rgb * _Ambient;

    return half4(diffuse + ambient, albedo.a);
}

#endif // RENDERLIB_TRIPLANAR_FORWARD_INCLUDED
