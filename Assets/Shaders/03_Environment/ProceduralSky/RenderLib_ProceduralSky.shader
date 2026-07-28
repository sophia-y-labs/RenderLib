Shader "RenderLib/Environment/ProceduralSky"
{
    Properties
    {
        [Header(Sky Colors)]
        _ZenithColor ("Zenith", Color) = (0.15, 0.35, 0.85, 1)
        _HorizonColor("Horizon", Color) = (0.70, 0.80, 0.95, 1)
        _GroundColor ("Ground", Color) = (0.25, 0.22, 0.18, 1)

        [Header(Shape)]
        _Exposure("Exposure", Range(0.1, 4)) = 1.0
        _HorizonExponent("Horizon Exponent", Range(0.2, 8)) = 1.5

        [Header(Sun)]
        _SunSize("Sun Size", Range(0.01, 0.5)) = 0.08
        _SunIntensity("Sun Intensity", Range(0, 20)) = 8
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Background"
            "RenderType" = "Background"
            "PreviewType" = "Skybox"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "Skybox"
            // No LightMode tag: Unity draws this as the environment skybox.

            Cull Off
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #include "RenderLib_ProceduralSkyPass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}