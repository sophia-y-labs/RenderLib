using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Full-screen pass for underwater fog + tint.
    /// </summary>
    public sealed class RenderLibUnderwaterPass : RenderLibPostProcessPass
    {
        static readonly int FogDensityId = Shader.PropertyToID("_FogDensity");
        static readonly int UnderwaterColorId = Shader.PropertyToID("_UnderwaterColor");
        static readonly int AbsorptionId = Shader.PropertyToID("_Absorption");

        public RenderLibUnderwaterPass(Material material)
            : base("RenderLib Underwater", material, RenderPassEvent.BeforeRenderingPostProcessing)
        {
        }

        public override bool IsActive(ref RenderingData renderingData)
        {
            if (!base.IsActive(ref renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibUnderwaterVolume volume)
                   && volume.IsActive();
        }

        protected override void SetupMaterial(ref RenderingData renderingData)
        {
            if (!RenderLibVolumeUtil.TryGetVolume(out RenderLibUnderwaterVolume volume))
                return;

            SetIntensity(Material, volume.intensity.value);
            Material.SetFloat(FogDensityId, volume.fogDensity.value);
            Material.SetColor(UnderwaterColorId, volume.underwaterColor.value);
            Material.SetColor(AbsorptionId, volume.absorption.value);
        }
    }

    /// <summary>
    /// Renderer Feature for Underwater. File name must match this class.
    /// </summary>
    public sealed class RenderLibUnderwaterFeature : RenderLibPostProcessFeature
    {
        protected override RenderLibPostProcessPass CreatePass(Material material)
        {
            return new RenderLibUnderwaterPass(material);
        }

        protected override ScriptableRenderPassInput GetRequiredInput()
        {
            // Same idea as OutlinePost: ask URP to provide _CameraDepthTexture.
            return ScriptableRenderPassInput.Depth;
        }

        protected override bool ShouldEnqueue(in RenderingData renderingData)
        {
            if (!base.ShouldEnqueue(renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibUnderwaterVolume v)
                   && v.IsActive();
        }
    }
}