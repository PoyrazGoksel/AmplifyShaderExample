using Events;
using UnityEngine;
using Zenject;

namespace Components
{
    public class InputListener : MonoBehaviour
    {
        [Inject] private PaintSceneEvents PaintSceneEvents{get;set;}
        private Camera _mainCam;

        private void Awake()
        {
            _mainCam = Camera.main;
        }

        private void Update()
        {
            Vector3 mousePosition = Input.mousePosition;

            if(Input.GetMouseButton(0))
            {
                Ray inputRay = _mainCam.ScreenPointToRay(mousePosition);
                
                PaintSceneEvents.InputRay?.Invoke(inputRay);
            }
        }
    }
}