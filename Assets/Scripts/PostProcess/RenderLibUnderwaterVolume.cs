using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Volume settings for underwater fog + color absorption.
    /// </summary>
    [Serializable]
    [VolumeComponentMenu("RenderLib/Underwater")]
    public sealed class RenderLibUnderwaterVolume : VolumeComponent
    {
        [Tooltip("0 = off, 1 = full underwater look.")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        [Tooltip("How quickly fog thickens with eye-space distance.")]
        public ClampedFloatParameter fogDensity = new ClampedFloatParameter(0.08f, 0f, 1f);

        [Tooltip("Fog / ambient tint when fully fogged.")]
        public ColorParameter underwaterColor = new ColorParameter(
            new Color(0.05f, 0.25f, 0.35f, 1f), true, false, true);

        [Tooltip("Per-channel light survival underwater (R usually lowest).")]
        public ColorParameter absorption = new ColorParameter(
            new Color(0.55f, 0.85f, 1f, 1f), false, false, true);

        public bool IsActive() => active && intensity.value > 0f;
    }
}