#ifndef RENDERLIB_HOLOGRAM_FORWARD_INCLUDED
#define RENDERLIB_HOLOGRAM_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_HologramInput.hlsl"

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

    // --- Scanline: repeating bands scrolling along V ---
    float scanPhase = frac(input.uv.y * _ScanlineCount + _Time.y * _ScanlineSpeed);
    float scanBand = 1.0 - smoothstep(0.0, _ScanlineWidth, scanPhase);
    half scanline = half(scanBand * _ScanlineIntensity);

    // --- Fresnel rim: bright at grazing angles ---
    half3 viewDirWS = GetWorldSpaceViewDir(input.positionWS);
    half rim = RenderLib_RimLight(
        input.normalWS,
        viewDirWS,
        _FresnelPower,
        _FresnelIntensity);

    // --- Noise flicker: subtle alpha/color instability ---
    float2 noiseUV = input.uv * _NoiseScale + float2(_Time.y * 0.37, _Time.y * 0.19);
    float noise = RenderLib_ValueNoise2D(noiseUV);
    half flicker = lerp(half(1.0), half(noise * 2.0), _FlickerStrength);

    // Combine: hologram tint modulated by rim + scanlines; base map tints the result
    half3 glow = _HologramColor.rgb * (rim + scanline);
    half3 color = albedo.rgb * glow;

    // Alpha: mostly visible at edges and scan peaks; center more transparent
    half alpha = saturate(rim + scanline * 0.5) * _Alpha * flicker * albedo.a;

    return half4(color, alpha);
}

#endif // RENDERLIB_HOLOGRAM_FORWARD_INCLUDED