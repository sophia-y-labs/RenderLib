Shader "RenderLib/Environment/TerrainBlend"
{
    Properties
    {
        [Header(Control)]
        _ControlMap("Control Map (RGBA)", 2D) = "red" {}

        [Header(Layer0_R)]
        _Layer0Map("Layer 0 Albedo", 2D) = "white" {}

        [Header(Layer1_G)]
        _Layer1Map("Layer 1 Albedo", 2D) = "white" {}

        [Header(Layer2_B)]
        _Layer2Map("Layer 2 Albedo", 2D) = "white" {}

        [Header(Layer3_A)]
        _Layer3Map("Layer 3 Albedo", 2D) = "white" {}

        [Header(Blend)]
        _HeightBlend("Height Blend Sharpness", Range(0.5, 16)) = 4

        [Header(Lighting)]
        _AmbientStrength("Ambient Strength", Range(0, 1)) = 0.25
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fog

            #include "RenderLib_TerrainBlendForward.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "Assets/_Core/Templates/Template_ForwardShadowPass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}