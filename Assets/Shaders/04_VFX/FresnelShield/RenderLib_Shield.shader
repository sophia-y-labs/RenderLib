Shader "RenderLib/VFX/Shield"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        _ShieldColor("Shield Color", Color) = (0.2, 0.85, 1, 1)
        _FresnelPower("Fresnel Power", Range(0.1, 8)) = 3
        _FresnelIntensity("Fresnel Intensity", Range(0, 4)) = 1.5
        _Alpha("Alpha", Range(0, 1)) = 0.85

        _PulseSpeed("Pulse Speed", Range(0, 10)) = 2
        _PulseStrength("Pulse Strength", Range(0, 0.5)) = 0.1
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

            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "RenderLib_ShieldForward.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}