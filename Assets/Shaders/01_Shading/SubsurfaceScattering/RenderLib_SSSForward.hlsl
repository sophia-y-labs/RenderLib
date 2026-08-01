#ifndef RENDERLIB_SSS_FORWARD_INCLUDED
#define RENDERLIB_SSS_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_SSSInput.hlsl"

// ---------------------------------------------------------------------------
// E006 SSS — Wrap diffuse + backlight translucency (optional thickness map)
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

    Light mainLight = GetMainLight();
    half3 nWS = half3(RenderLib_SafeNormalize(input.normalWS));
    half3 lDir = half3(mainLight.direction);

    // Soft wrap diffuse (front / side lit areas)
    half wrap = RenderLib_WrapNdotL(nWS, lDir, _WrapAmount);
    half3 diffuse = albedo.rgb * mainLight.color * wrap;

    // Thickness: white map / high _Thickness = more light through
    half thicknessSample = SAMPLE_TEXTURE2D(_ThicknessMap, sampler_ThicknessMap, input.uv).r;
    half thickness = saturate(thicknessSample * _Thickness);

    // Backlight term: strongest when light is behind the surface
    half translucency = RenderLib_SSSTranslucency(nWS, lDir, _SSSPower);
    half3 sss = _SSSColor.rgb * mainLight.color * translucency * _SSSIntensity * thickness;

    half3 ambient = albedo.rgb * half3(0.12h, 0.12h, 0.12h);

    return half4(diffuse + sss + ambient, albedo.a);
}

#endif // RENDERLIB_SSS_FORWARD_INCLUDED
