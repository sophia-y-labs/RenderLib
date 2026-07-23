using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Full-screen pass for Depth/Normal Sobel outline.
    /// </summary>
    public sealed class RenderLibOutlinePostPass : RenderLibPostProcessPass
    {
        static readonly int ThicknessId = Shader.PropertyToID("_Thickness");
        static readonly int OutlineColorId = Shader.PropertyToID("_OutlineColor");

        public RenderLibOutlinePostPass(Material material)
            : base("RenderLib Outline Post", material, RenderPassEvent.BeforeRenderingPostProcessing)
        {
        }

        public override bool IsActive(ref RenderingData renderingData)
        {
            if (!base.IsActive(ref renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibOutlinePostVolume volume) && volume.IsActive();
        }

        protected override void SetupMaterial(ref RenderingData renderingData)
        {
            if (!RenderLibVolumeUtil.TryGetVolume(out RenderLibOutlinePostVolume volume))
                return;

            SetIntensity(Material, volume.intensity.value);
            Material.SetFloat(ThicknessId, volume.thickness.value);
            Material.SetColor(OutlineColorId, volume.outlineColor.value);
        }
    }

    /// <summary>
    /// Renderer Feature for E031 Outline Post. File name must match this class.
    /// </summary>
    public sealed class RenderLibOutlinePostFeature : RenderLibPostProcessFeature
    {
        protected override RenderLibPostProcessPass CreatePass(Material material)
        {
            return new RenderLibOutlinePostPass(material);
        }

        protected override ScriptableRenderPassInput GetRequiredInput()
        {
            // Requests Depth Texture + DepthNormals (fills _CameraNormalsTexture).
            return ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal;
        }

        protected override bool ShouldEnqueue(in RenderingData renderingData)
        {
            if (!base.ShouldEnqueue(renderingData))
                return false;

            return RenderLibVolumeUtil.TryGetVolume(out RenderLibOutlinePostVolume v) && v.IsActive();
        }
    }
}