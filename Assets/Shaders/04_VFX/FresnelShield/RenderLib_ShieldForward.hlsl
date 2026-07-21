#ifndef RENDERLIB_SHIELD_FORWARD_INCLUDED
#define RENDERLIB_SHIELD_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_ShieldInput.hlsl"

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

    // Fresnel rim — bright at grazing angles (same helper as Hologram / RimLight)
    half3 viewDirWS = GetWorldSpaceViewDir(input.positionWS);
    half fresnel = RenderLib_RimLight(
        input.normalWS,
        viewDirWS,
        _FresnelPower,
        _FresnelIntensity);

    // Optional pulse: subtle breathing on intensity (not required for acceptance)
    half pulse = half(1.0) + sin(_Time.y * _PulseSpeed) * _PulseStrength;
    fresnel *= pulse;

    // Modulate alpha only — avoid fresnel² darkening under SrcAlpha blending
    half3 color = _ShieldColor.rgb * albedo.rgb;
    half alpha = saturate(fresnel) * _Alpha * albedo.a;

    return half4(color, alpha);
}

#endif // RENDERLIB_SHIELD_FORWARD_INCLUDED