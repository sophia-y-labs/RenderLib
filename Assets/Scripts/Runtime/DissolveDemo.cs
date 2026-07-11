using UnityEngine;

namespace RenderLib.Runtime
{
    /// <summary>
    /// Drives _DissolveAmount on a single renderer for Play Mode dissolve demo.
    /// Uses MaterialPropertyBlock so shared Dissolve.mat assets are not modified.
    /// </summary>
    [DisallowMultipleComponent]
    public class DissolveDemo : MonoBehaviour
    {
        [SerializeField] Renderer _targetRenderer;
        [SerializeField] float _speed = 0.35f;
        [SerializeField] float _minAmount = 0f;
        [SerializeField] float _maxAmount = 1f;

        static readonly int DissolveAmountId = Shader.PropertyToID("_DissolveAmount");

        MaterialPropertyBlock _propertyBlock;

        void Awake()
        {
            if (_targetRenderer == null)
                _targetRenderer = GetComponentInChildren<Renderer>();
            _propertyBlock = new MaterialPropertyBlock();
        }

        void Update()
        {
            if (_targetRenderer == null)
                return;

            float t = Mathf.PingPong(Time.time * _speed, 1f);
            float amount = Mathf.Lerp(_minAmount, _maxAmount, t);

            _targetRenderer.GetPropertyBlock(_propertyBlock);
            _propertyBlock.SetFloat(DissolveAmountId, amount);
            _targetRenderer.SetPropertyBlock(_propertyBlock);
        }
    }
}