using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Volume settings for radial vignette.
    /// </summary>
    [Serializable]
    [VolumeComponentMenu("RenderLib/Vignette")]
    public sealed class RenderLibVignetteVolume : VolumeComponent
    {
        [Tooltip("0 = off, 1 = full vignette.")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        [Tooltip("How soft the falloff is (larger = softer edge).")]
        public ClampedFloatParameter smoothness = new ClampedFloatParameter(0.4f, 0.01f, 1f);

        [Tooltip("Tint multiplied into darkened edges.")]
        public ColorParameter vignetteColor = new ColorParameter(Color.black, true, false, true);

        public bool IsActive() => active && intensity.value > 0f;
    }
}