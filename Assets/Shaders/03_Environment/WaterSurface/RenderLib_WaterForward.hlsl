#ifndef RENDERLIB_WATER_FORWARD_INCLUDED
#define RENDERLIB_WATER_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_WaterInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT; // needed to build TBN for normal maps
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS   : TEXCOORD2;
    float3 tangentWS  : TEXCOORD3;
    float3 bitangentWS: TEXCOORD4;
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
    // Pass tangent so URP builds a correct TBN (handles tangent.w / mirroring)
    VertexNormalInputs  nrmInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.positionCS  = posInputs.positionCS;
    output.positionWS  = posInputs.positionWS;
    output.normalWS    = nrmInputs.normalWS;
    output.tangentWS   = nrmInputs.tangentWS;
    output.bitangentWS = nrmInputs.bitangentWS;
    output.uv          = TRANSFORM_TEX(input.uv, _NormalMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // ----------------------------------------------------------------
    // 1) Animated normals — sample the same map twice with different scroll
    // ----------------------------------------------------------------
    float2 uv0 = input.uv + _Time.y * _NormalSpeed.xy;
    float2 uv1 = input.uv + _Time.y * _NormalSpeed.zw;

    half3 n0 = UnpackNormalScale(
        SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv0), _NormalScale);
    half3 n1 = UnpackNormalScale(
        SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv1), _NormalScale);
    // Average in tangent space, then re-normalize
    half3 normalTS = normalize(n0 + n1);

    // TBN: tangent-space normal → world-space normal
    float3x3 tbn = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);
    half3 normalWS = normalize(half3(mul(normalTS, tbn)));

    // ----------------------------------------------------------------
    // 2) Depth color — how much water is between surface and scene geometry
    // Use URP screen UV + world-space eye depth (more reliable than screenPos.z/w).
    // ----------------------------------------------------------------
    float2 screenUV = GetNormalizedScreenSpaceUV(input.positionCS);
    float sceneZ    = RenderLib_SampleSceneEyeDepth(screenUV);
    float surfaceZ  = RenderLib_LinearEyeDepthFromWorld(input.positionWS);
    float depthGap  = max(sceneZ - surfaceZ, 0.0); // meters of water "thickness"

    half depthT = saturate(half(depthGap / max((float)_DepthDistance, 1e-4)));
    half4 waterCol = lerp(_ShallowColor, _DeepColor, depthT);

    // ----------------------------------------------------------------
    // 3) Shore soft edge — fade alpha when depthGap is tiny (near rocks/bank)
    // ----------------------------------------------------------------
    half shore = half(RenderLib_DepthFade(
        sceneZ, surfaceZ,
        0.0,                                    // start fading immediately at contact
        max((float)_ShoreFadeDistance, 1e-4))); // fully opaque beyond this gap
    waterCol.a *= shore;

    // ----------------------------------------------------------------
    // 4) Lighting — Lambert + specular + Fresnel rim
    // ----------------------------------------------------------------
    Light mainLight = GetMainLight();
    half ndotl = half(RenderLib_NdotL(normalWS, mainLight.direction));

    half3 viewDirWS = SafeNormalize(GetWorldSpaceNormalizeViewDir(input.positionWS));
    half3 halfDir   = SafeNormalize(mainLight.direction + viewDirWS);
    half  specMask  = pow(saturate(dot(normalWS, halfDir)), max(_Smoothness * half(64.0), half(1.0)));
    half3 specular  = mainLight.color * specMask * _SpecularIntensity;

    // Fresnel: glancing angles look more reflective / brighter
    half fresnel = pow(saturate(1.0 - saturate(dot(normalWS, viewDirWS))), _FresnelPower);

    half3 diffuse = waterCol.rgb * mainLight.color * ndotl;
    half3 ambient = waterCol.rgb * _AmbientStrength;
    half3 lit     = ambient + diffuse + specular + waterCol.rgb * fresnel * half(0.35);

    return half4(lit, waterCol.a);
}

#endif // RENDERLIB_WATER_FORWARD_INCLUDED