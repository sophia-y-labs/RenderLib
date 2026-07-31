#ifndef RENDERLIB_TERRAIN_BLEND_FORWARD_INCLUDED
#define RENDERLIB_TERRAIN_BLEND_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_TerrainBlendInput.hlsl"

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

    VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs  nrmInputs = GetVertexNormalInputs(input.normalOS);

    output.positionCS = posInputs.positionCS;
    output.positionWS = posInputs.positionWS;
    output.normalWS   = nrmInputs.normalWS;
    // Control UV is the "paint mask" space; layers apply their own tiling in frag.
    output.uv         = TRANSFORM_TEX(input.uv, _ControlMap);

    return output;
}

// Height-aware splat weights.
// splat  = painted amounts (Control RGBA)
// height = per-layer alpha (or 1 if texture has no useful alpha)
// Returns weights that sum to 1.
half4 HeightBlendWeights(half4 splat, half4 height, half blendSharpness)
{
    // Boost layers that are both painted AND locally "taller".
    half4 m = splat * max(height, half(0.001));

    half ma = max(max(m.r, m.g), max(m.b, m.a));
    // blendSharpness acts as transition width inverted: larger → thinner blend band
    half t = max(half(1.0) / max(blendSharpness, half(0.01)), half(0.001));

    half4 w = saturate((m - (ma - t)) / t);

    half sum = max(dot(w, half4(1, 1, 1, 1)), half(1e-4));
    return w / sum;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // ----------------------------------------------------------------
    // 1) Control weights (RGBA → four layers)
    // ----------------------------------------------------------------
    half4 splat = SAMPLE_TEXTURE2D(_ControlMap, sampler_ControlMap, input.uv);

    // ----------------------------------------------------------------
    // 2) Sample each layer (own tiling) + tint
    // ----------------------------------------------------------------
    float2 uv0 = input.uv * _Layer0Map_ST.xy + _Layer0Map_ST.zw;
    float2 uv1 = input.uv * _Layer1Map_ST.xy + _Layer1Map_ST.zw;
    float2 uv2 = input.uv * _Layer2Map_ST.xy + _Layer2Map_ST.zw;
    float2 uv3 = input.uv * _Layer3Map_ST.xy + _Layer3Map_ST.zw;

    half4 l0 = SAMPLE_TEXTURE2D(_Layer0Map, sampler_Layer0Map, uv0);
    half4 l1 = SAMPLE_TEXTURE2D(_Layer1Map, sampler_Layer1Map, uv1);
    half4 l2 = SAMPLE_TEXTURE2D(_Layer2Map, sampler_Layer2Map, uv2);
    half4 l3 = SAMPLE_TEXTURE2D(_Layer3Map, sampler_Layer3Map, uv3);

    // ----------------------------------------------------------------
    // 3) Height blend (layer.a = height). Flat alpha → nearly linear splat.
    // ----------------------------------------------------------------
    half4 height = half4(l0.a, l1.a, l2.a, l3.a);
    half4 w = HeightBlendWeights(splat, height, _HeightBlend);

    half3 albedo = l0.rgb * w.r
                 + l1.rgb * w.g
                 + l2.rgb * w.b
                 + l3.rgb * w.a;

    // ----------------------------------------------------------------
    // 4) Simple Lambert (same idea as E002)
    // ----------------------------------------------------------------
    Light mainLight = GetMainLight();
    half ndotl = half(RenderLib_NdotL(input.normalWS, mainLight.direction));

    half3 lit = albedo * mainLight.color * ndotl;
    half3 ambient = albedo * _AmbientStrength;

    return half4(ambient + lit, 1.0);
}

#endif // RENDERLIB_TERRAIN_BLEND_FORWARD_INCLUDED