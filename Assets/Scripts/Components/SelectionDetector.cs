using System.Collections.Generic;
using DG.Tweening;
using Sirenix.OdinInspector;
using UnityEngine;

namespace Components
{
    public class SelectionDetector : MonoBehaviour
    {
        private MeshRenderer _myMeshRenderer;
        [SerializeField] private float _outlineWidth = 1f;
        [SerializeField] private float _animDur = 1f;
        private List<Material> _materialInstances;

        private void Awake()
        {
            _myMeshRenderer = GetComponent<MeshRenderer>();
            _materialInstances = new List<Material>();
            _myMeshRenderer.GetMaterials(_materialInstances);
        }

        [Button]
        private void TestBut()
        {
        }

        private void OnMouseEnter()
        {
            _materialInstances[0].DOFloat(_outlineWidth, "_OutlineWidth", _animDur);
        }

        private void OnMouseExit()
        {
            _materialInstances[0].DOFloat(0f, "_OutlineWidth", _animDur);
        }
    }
}