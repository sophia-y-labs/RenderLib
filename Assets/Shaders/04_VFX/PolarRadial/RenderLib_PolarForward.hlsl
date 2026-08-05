#ifndef RENDERLIB_POLAR_FORWARD_INCLUDED
#define RENDERLIB_POLAR_FORWARD_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/_Core/Includes/RenderLibCore.hlsl"
#include "RenderLib_PolarInput.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv         : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;
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

    output.positionCS = positionInputs.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);

    return output;
}

half4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Cartesian UV -> polar (normalizedAngle, radius)
    float2 polar = RenderLib_PolarUV(input.uv, _Center.xy);

    // Angle axis: spin + angular tiling (N lobes around the circle)
    polar.x = polar.x * (float)_AngleRepeat + _Time.y * (float)_SpinSpeed;

    // Radius axis: scale + radial scroll (expanding / contracting rings)
    polar.y = polar.y * (float)_RadialScale + _Time.y * (float)_RadialSpeed;

    // LOD 0: atan2 branch cut makes polar.x discontinuous; hardware mips
    // from ddx/ddy would pick a tiny level and draw a radial seam line.
    half4 albedo = SAMPLE_TEXTURE2D_LOD(_BaseMap, sampler_BaseMap, polar, 0) * _BaseColor;
    return albedo;
}

#endif // RENDERLIB_POLAR_FORWARD_INCLUDED
