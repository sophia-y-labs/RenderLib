using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Full-screen pass for Pixelation.
    /// </summary>
    public sealed class RenderLibPixelationPass : RenderLibPostProcessPass
    {
        static readonly int PixelSizeId = Shader.PropertyToID("_PixelSize");

        public RenderLibPixelationPass(Material material)
            : base("RenderLib Pixelation", material, RenderPassEvent.BeforeRenderingPostProcessing)
        {
        }

        public override bool IsActive(ref RenderingData renderingData)
        {
            if (!base.IsActive(ref renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibPixelationVolume volume) && volume.IsActive();
        }

        protected override void SetupMaterial(ref RenderingData renderingData)
        {
            if (!RenderLibVolumeUtil.TryGetVolume(out RenderLibPixelationVolume volume))
                return;

            SetIntensity(Material, volume.intensity.value);
            Material.SetFloat(PixelSizeId, volume.pixelSize.value);
        }
    }

    /// <summary>
    /// Renderer Feature for Pixelation. File name must match this class for Unity creation.
    /// </summary>
    public sealed class RenderLibPixelationFeature : RenderLibPostProcessFeature
    {
        protected override RenderLibPostProcessPass CreatePass(Material material)
        {
            return new RenderLibPixelationPass(material);
        }

        protected override bool ShouldEnqueue(in RenderingData renderingData)
        {
            if (!base.ShouldEnqueue(renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibPixelationVolume v) && v.IsActive();
        }
    }
}
