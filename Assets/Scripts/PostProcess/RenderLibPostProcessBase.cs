using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Base ScriptableRenderPass for full-screen post effects using the URP Blitter API.
    /// Derive and override <see cref="SetupMaterial"/> to push Volume or feature parameters.
    /// </summary>
    public abstract class RenderLibPostProcessPass : ScriptableRenderPass
    {
        static readonly int IntensityId = Shader.PropertyToID("_Intensity");

        readonly Material m_Material;
        RTHandle m_CameraColorTarget;
        RTHandle m_TempColor;

        protected Material Material => m_Material;

        protected RenderLibPostProcessPass(string passName, Material material, RenderPassEvent injectionPoint)
        {
            profilingSampler = new ProfilingSampler(passName);
            m_Material = material;
            renderPassEvent = injectionPoint;
        }

        /// <summary>
        /// Called before blit. Return false to skip this frame.
        /// </summary>
        public virtual bool IsActive(ref RenderingData renderingData) => m_Material != null;

        public void SetTarget(RTHandle cameraColorTarget)
        {
            m_CameraColorTarget = cameraColorTarget;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // Temp RT required: Blitter cannot safely sample and write the same camera color target.
            var desc = renderingData.cameraData.cameraTargetDescriptor;
            desc.depthBufferBits = 0;
            desc.msaaSamples = 1;
            RenderingUtils.ReAllocateIfNeeded(
                ref m_TempColor,
                desc,
                FilterMode.Bilinear,
                TextureWrapMode.Clamp,
                name: "_RenderLibPostTemp");

            ConfigureTarget(m_CameraColorTarget);
        }

        protected abstract void SetupMaterial(ref RenderingData renderingData);

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (!IsActive(ref renderingData) || m_CameraColorTarget == null || m_TempColor == null)
                return;

            CommandBuffer cmd = CommandBufferPool.Get();

            using (new ProfilingScope(cmd, profilingSampler))
            {
                SetupMaterial(ref renderingData);
                // camera -> temp (apply effect), then temp -> camera (copy back)
                Blitter.BlitCameraTexture(cmd, m_CameraColorTarget, m_TempColor, m_Material, 0);
                Blitter.BlitCameraTexture(cmd, m_TempColor, m_CameraColorTarget);
            }

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }

        public void Dispose()
        {
            m_TempColor?.Release();
            m_TempColor = null;
        }

        protected static void SetIntensity(Material material, float intensity)
        {
            material.SetFloat(IntensityId, intensity);
        }
    }

    /// <summary>
    /// Base ScriptableRendererFeature that owns a <see cref="RenderLibPostProcessPass"/>.
    /// Step 4 effects inherit this pair (Pass + Feature) and wire Volume parameters.
    /// </summary>
    public abstract class RenderLibPostProcessFeature : ScriptableRendererFeature
    {
        [SerializeField]
        protected Shader m_Shader;

        [SerializeField]
        [Range(0f, 1f)]
        protected float m_Intensity = 0f;

        Material m_Material;
        RenderLibPostProcessPass m_RenderPass;

        protected Material Material => m_Material;
        protected float Intensity => m_Intensity;

        protected abstract RenderLibPostProcessPass CreatePass(Material material);

        public override void Create()
        {
            if (m_Shader == null)
                return;

            m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
            m_RenderPass = CreatePass(m_Material);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            if (m_RenderPass == null || m_Material == null)
                return;

            if (!ShouldEnqueue(renderingData))
                return;

            renderer.EnqueuePass(m_RenderPass);
        }

        public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
        {
            if (m_RenderPass == null || m_Material == null)
                return;

            if (!ShouldEnqueue(renderingData))
                return;

            m_RenderPass.ConfigureInput(GetRequiredInput());
            m_RenderPass.SetTarget(renderer.cameraColorTargetHandle);
        }

        protected virtual bool ShouldEnqueue(in RenderingData renderingData)
        {
            return renderingData.cameraData.cameraType == CameraType.Game
                || renderingData.cameraData.cameraType == CameraType.SceneView;
        }

        protected virtual ScriptableRenderPassInput GetRequiredInput()
        {
            return ScriptableRenderPassInput.None;
        }

        protected override void Dispose(bool disposing)
        {
            m_RenderPass?.Dispose();
            m_RenderPass = null;
            CoreUtils.Destroy(m_Material);
            m_Material = null;
        }
    }

    /// <summary>
    /// Shared Volume stack lookup for post Features / Passes.
    /// </summary>
    internal static class RenderLibVolumeUtil
    {
        public static bool TryGetVolume<T>(out T component) where T : VolumeComponent
        {
            component = null;
            var stack = VolumeManager.instance?.stack;
            if (stack == null)
                return false;
            component = stack.GetComponent<T>();
            return component != null && component.active;
        }
    }
}
