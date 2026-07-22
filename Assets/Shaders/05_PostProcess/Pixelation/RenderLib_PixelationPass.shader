Shader "RenderLib/PostProcess/Pixelation"
{
    Properties
    {
        _Intensity("Intensity", Range(0.0, 1.0)) = 1.0
        _PixelSize("Pixel Size", Range(1.0, 64.0)) = 8.0
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
            Name "Pixelation"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment frag

            #include "RenderLib_PixelationPass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}
