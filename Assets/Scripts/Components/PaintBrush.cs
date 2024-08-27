using Events;
using Extensions.Unity.MonoHelper;
using Extensions.Unity.Utils;
using Sirenix.OdinInspector;
using UnityEngine;
using Zenject;

namespace Components
{
    public class PaintBrush : EventListenerMono
    {
        [Inject] private PaintSceneEvents PaintSceneEvents{get;set;}
        [SerializeField] private float _speed = 1f;
        [SerializeField] private AnimationCurve _animationCurve;
        private Transform _transform;
        private Quaternion _lastRot;

        private void Awake()
        {
            _transform = transform;
            _lastRot = _transform.rotation;
        }

        [Button]
        private void GetPoint(float val)
        {
            EDebug.Method(_animationCurve.Evaluate(val));
        }
        
        protected override void RegisterEvents()
        {
            PaintSceneEvents.InputRay += OnInputRay;
        }

        private void OnInputRay(Ray arg0)
        {
            if(Physics.Raycast
            (
                arg0,
                out RaycastHit hit,
                Mathf.Infinity,
                LayerMask.GetMask("Paintable")
            ))
            {
                Vector3 hitNorm = hit.normal;

                _transform.position = hit.point + hitNorm;

                Quaternion newRot = Quaternion.LookRotation(-1f * hitNorm);

                Quaternion lerpRot = Quaternion.Slerp(_lastRot, newRot, Time.deltaTime * _speed);
                
                _transform.rotation = lerpRot;

                _lastRot = lerpRot;
            }
        }

        protected override void UnRegisterEvents()
        {
            PaintSceneEvents.InputRay -= OnInputRay;
        }
    }
}