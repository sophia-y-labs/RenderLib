#ifndef RENDERLIB_PROCEDURAL_SKY_PASS_INCLUDED
#define RENDERLIB_PROCEDURAL_SKY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "RenderLib_ProceduralSkyInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float3 viewDirWS  : TEXCOORD0; // direction from camera into the sky
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // Skybox mesh vertices are directions on a unit cube/sphere.
    // Rotate by object matrix (Unity sets this so the sky follows the camera).
    float3 viewDirWS = mul((float3x3)UNITY_MATRIX_M, input.positionOS.xyz);
    output.viewDirWS = viewDirWS;

    // w = 0 places the sky at infinity (no parallax as camera translates).
    float4 clipPos = mul(UNITY_MATRIX_VP, float4(viewDirWS, 0.0));

    // Keep sky behind all geometry on both normal-Z and reversed-Z APIs.
#if UNITY_REVERSED_Z
    clipPos.z = clipPos.w * 0.0000001;
#else
    clipPos.z = clipPos.w * 0.999999;
#endif

    output.positionCS = clipPos;
    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 dir = normalize(input.viewDirWS);
    float  h   = dir.y; // -1 (nadir) .. +1 (zenith)

    // Two blends: ground↔horizon (below), horizon↔zenith (above).
    // _HorizonExponent > 1 pushes more color toward the horizon band.
    half expCtrl = max(_HorizonExponent, half(0.01));
    half tUp   = saturate(half(pow(max(h, 0.0), expCtrl)));
    half tDown = saturate(half(pow(max(-h, 0.0), expCtrl)));

    half3 sky = lerp(_HorizonColor.rgb, _ZenithColor.rgb, tUp);
    sky = lerp(sky, _GroundColor.rgb, tDown);

    // Optional sun disk: brighter where view aligns with main light.
    Light mainLight = GetMainLight();
    float  sunDot   = saturate(dot(dir, mainLight.direction));
    // Smaller _SunSize => tighter disk (higher power).
    float  sunPow   = pow(sunDot, max(1.0 / max((float)_SunSize, 1e-4), 1.0));
    sky += mainLight.color.rgb * (half)sunPow * _SunIntensity;

    sky *= _Exposure;
    return half4(sky, 1.0);
}

#endif // RENDERLIB_PROCEDURAL_SKY_PASS_INCLUDED