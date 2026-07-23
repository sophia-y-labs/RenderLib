using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace RenderLib.PostProcess
{
    /// <summary>
    /// Volume settings for Pixelation (screen-space UV quantization).
    /// </summary>
    [Serializable]
    [VolumeComponentMenu("RenderLib/Pixelation")]
    public sealed class RenderLibPixelationVolume : VolumeComponent
    {
        [Tooltip("Blend between original and pixelated image.")]
        public ClampedFloatParameter intensity = new ClampedFloatParameter(0f, 0f, 1f);

        [Tooltip("Size of each color block in screen pixels.")]
        public ClampedFloatParameter pixelSize = new ClampedFloatParameter(8f, 1f, 64f);

        public bool IsActive() => active && intensity.value > 0f && pixelSize.value > 1f;
    }
}
