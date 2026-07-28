Shader "RenderLib/Environment/Water"
{
    Properties
    {
        [Header(Colors)]
        _ShallowColor("Shallow Color", Color) = (0.30, 0.65, 0.70, 0.75)
        _DeepColor("Deep Color", Color) = (0.02, 0.15, 0.35, 0.92)

        [Header(Normals)]
        [Normal] _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0, 2)) = 1.0
        _NormalSpeed("Normal Speed (xy / zw)", Vector) = (0.03, 0.02, -0.02, 0.04)

        [Header(Depth)]
        _DepthDistance("Depth Distance", Range(0.1, 20)) = 4.0
        _ShoreFadeDistance("Shore Fade Distance", Range(0.01, 5)) = 0.6

        [Header(Lighting)]
        _Smoothness("Smoothness", Range(0.01, 1)) = 0.85
        _SpecularIntensity("Specular Intensity", Range(0, 5)) = 1.5
        _FresnelPower("Fresnel Power", Range(0.5, 8)) = 3.0
        _AmbientStrength("Ambient Strength", Range(0, 1)) = 0.25
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fog

            #include "RenderLib_WaterForward.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}