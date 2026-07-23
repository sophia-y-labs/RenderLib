Shader "RenderLib/PostProcess/Vignette"
{
    Properties
    {
        _Intensity("Intensity", Range(0.0, 1.0)) = 1.0
        _Smoothness("Smoothness", Range(0.01, 1.0)) = 0.4
        _VignetteColor("Vignette Color", Color) = (0, 0, 0, 1)
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
            Name "Vignette"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment frag

            #include "RenderLib_VignettePass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}