Shader "RenderLib/PostProcess/OutlinePost"
{
    Properties
    {
        _Intensity("Intensity", Range(0.0, 1.0)) = 1.0
        _Thickness("Thickness", Range(0.1, 5.0)) = 1.0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
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
            Name "OutlinePost"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment frag

            #include "RenderLib_OutlinePostPass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}