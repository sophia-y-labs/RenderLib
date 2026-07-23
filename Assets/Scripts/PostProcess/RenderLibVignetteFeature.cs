using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Full-screen pass for E032 radial vignette.
    /// </summary>
    public sealed class RenderLibVignettePass : RenderLibPostProcessPass
    {
        static readonly int SmoothnessId = Shader.PropertyToID("_Smoothness");
        static readonly int VignetteColorId = Shader.PropertyToID("_VignetteColor");

        public RenderLibVignettePass(Material material)
            : base("RenderLib Vignette", material, RenderPassEvent.BeforeRenderingPostProcessing)
        {
        }

        public override bool IsActive(ref RenderingData renderingData)
        {
            if (!base.IsActive(ref renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibVignetteVolume volume) && volume.IsActive();
        }

        protected override void SetupMaterial(ref RenderingData renderingData)
        {
            if (!RenderLibVolumeUtil.TryGetVolume(out RenderLibVignetteVolume volume))
                return;

            SetIntensity(Material, volume.intensity.value);
            Material.SetFloat(SmoothnessId, volume.smoothness.value);
            Material.SetColor(VignetteColorId, volume.vignetteColor.value);
        }
    }

    /// <summary>
    /// Renderer Feature for E032 Vignette. File name must match this class.
    /// </summary>
    public sealed class RenderLibVignetteFeature : RenderLibPostProcessFeature
    {
        protected override RenderLibPostProcessPass CreatePass(Material material)
        {
            return new RenderLibVignettePass(material);
        }

        protected override bool ShouldEnqueue(in RenderingData renderingData)
        {
            if (!base.ShouldEnqueue(renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibVignetteVolume v) && v.IsActive();
        }
    }
}