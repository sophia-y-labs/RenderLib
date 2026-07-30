Shader "RenderLib/PostProcess/Underwater"
{
    Properties
    {
        _Intensity("Intensity", Range(0.0, 1.0)) = 1.0
        _FogDensity("Fog Density", Range(0.0, 1.0)) = 0.08
        _UnderwaterColor("Underwater Color", Color) = (0.05, 0.25, 0.35, 1)
        _Absorption("Absorption (RGB survive)", Color) = (0.55, 0.85, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "Underwater"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment frag

            #include "RenderLib_UnderwaterPass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}