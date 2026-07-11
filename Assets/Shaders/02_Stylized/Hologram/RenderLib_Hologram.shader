Shader "RenderLib/Stylized/Hologram"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        _HologramColor("Hologram Color", Color) = (0.2, 0.9, 1, 1)
        _Alpha("Alpha", Range(0, 1)) = 0.85

        _ScanlineCount("Scanline Count", Range(1, 128)) = 32
        _ScanlineSpeed("Scanline Speed", Range(0, 10)) = 2
        _ScanlineWidth("Scanline Width", Range(0.01, 0.5)) = 0.08
        _ScanlineIntensity("Scanline Intensity", Range(0, 2)) = 0.6

        _FresnelPower("Fresnel Power", Range(0.1, 8)) = 2
        _FresnelIntensity("Fresnel Intensity", Range(0, 3)) = 1.2

        _NoiseScale("Noise Scale", Range(1, 32)) = 12
        _FlickerStrength("Flicker Strength", Range(0, 1)) = 0.25
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
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

            #include "RenderLib_HologramForward.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}