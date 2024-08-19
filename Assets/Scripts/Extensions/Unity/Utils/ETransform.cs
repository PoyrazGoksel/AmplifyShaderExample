using UnityEngine;

namespace Extensions.Unity.Utils
{
    public class ETransform
    {
        public Vector3 position => _transform.position;
        public Quaternion rotation => _transform.rotation;
        public Vector3 eulerAngles => _transform.eulerAngles;
        public Vector3 localPosition => _transform.localPosition;
        public Quaternion localRotation => _transform.localRotation;
        public Vector3 localEulerAngles => _transform.localEulerAngles;
        
        private readonly Transform _transform;
        
        /// <summary>
        /// Use transform.ETransform extension method.
        /// </summary>
        /// <param name="transform"></param>
        public ETransform(Transform transform)
        {
            _transform = transform;
        }

        public Transform GetTransIns()
        {
            return _transform;
        }

        public void Sync(Transform transform)
        {
            transform.position = position;
            transform.rotation = rotation;
        }

        public bool Equals(Transform transform)
        {
            return transform == _transform;
        }
    }

    public static class TransExt
    {
        public static ETransform ETransform(this Transform transform)
        {
            return new ETransform(transform);
        }
    }
}