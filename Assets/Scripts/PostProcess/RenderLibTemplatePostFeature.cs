using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Minimal concrete pass used by Template_PostPass for compile/runtime smoke tests.
    /// </summary>
    public sealed class RenderLibTemplatePostPass : RenderLibPostProcessPass
    {
        public RenderLibTemplatePostPass(Material material)
            : base("RenderLib Template Post", material, RenderPassEvent.BeforeRenderingPostProcessing)
        {
        }

        public override bool IsActive(ref RenderingData renderingData)
        {
            if (!base.IsActive(ref renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibTemplatePostVolume volume) && volume.IsActive();
        }

        protected override void SetupMaterial(ref RenderingData renderingData)
        {
            // IsActive already ensured volume exists; read again for the value.
            if (!RenderLibVolumeUtil.TryGetVolume(out RenderLibTemplatePostVolume volume))
                return;

            SetIntensity(Material, volume.intensity.value);
        }
    }

    /// <summary>
    /// Renderer Feature that runs Template_PostPass. Assign in URP Renderer (Step 0.4 / 4.1).
    /// Must live in a file named after this class so Unity can create the ScriptableObject.
    /// </summary>
    public sealed class RenderLibTemplatePostFeature : RenderLibPostProcessFeature
    {
        protected override RenderLibPostProcessPass CreatePass(Material material)
        {
            return new RenderLibTemplatePostPass(material);
        }

        protected override bool ShouldEnqueue(in RenderingData renderingData)
        {
            if (!base.ShouldEnqueue(renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibTemplatePostVolume v)
                && v.IsActive();
        }
    }
}
