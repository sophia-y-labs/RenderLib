Shader "RenderLib/Templates/PostPass"
{
    Properties
    {
        _Intensity("Intensity", Range(0.0, 1.0)) = 0.0
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
            Name "PostPass"
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment frag

            #include "Template_PostPass.hlsl"
            ENDHLSL
        }
    }

    Fallback Off
}
