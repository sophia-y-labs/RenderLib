Shader "RenderLib/Stylized/DissolveDirectional"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        _EdgeColor("Edge Color", Color) = (0.2, 0.8, 1, 1)
        _DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
        _EdgeWidth("Edge Width", Range(0.001, 0.2)) = 0.05

        _DissolveDirection("Dissolve Direction", Vector) = (1, 0, 0, 0)
        _DirectionScale("Direction Scale", Range(0.1, 10)) = 2
        _NoiseScale("Noise Scale", Range(1, 32)) = 8
        _NoiseOffset("Noise Offset", Vector) = (0, 0, 0, 0)
        _NoiseStrength("Noise Strength", Range(0, 0.5)) = 0.15
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

            #include "RenderLib_DissolveDirForward.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}