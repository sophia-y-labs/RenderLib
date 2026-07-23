using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Smoke-test Volume for Template_PostPass.
    /// </summary>
    [Serializable]
    [VolumeComponentMenu("RenderLib/Template Post")]
    public sealed class RenderLibTemplatePostVolume : VolumeComponent
    {
        [Tooltip("0 = off, 1 = full green tint (template effect).")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        public bool IsActive() => active && intensity.value > 0f;
    }
}