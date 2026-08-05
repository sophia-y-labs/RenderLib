using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Volume settings for screen-space outline (Depth + Normal Sobel).
    /// </summary>
    [Serializable]
    [VolumeComponentMenu("RenderLib/Outline Post")]
    public sealed class RenderLibOutlinePostVolume : VolumeComponent
    {
        [Tooltip("0 = off, 1 = full outline.")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        [Tooltip("Edge sensitivity / line weight.")]
        public ClampedFloatParameter thickness = new ClampedFloatParameter(1f, 0.1f, 5f);

        [Tooltip("Outline tint.")]
        public ColorParameter outlineColor = new ColorParameter(Color.black, true, false, true);

        public bool IsActive() => active && intensity.value > 0f;
    }
}