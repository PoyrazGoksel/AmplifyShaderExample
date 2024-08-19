using UnityEngine;
using UnityEngine.Events;

namespace Extensions.Unity.Utils
{
    public class ProjectUpdateProvider : MonoBehaviour
    {
        public static event UnityAction On_Update;
        public static event UnityAction On_FixedUpdate;
        public static event UnityAction On_LateUpdate;
        
        private static ProjectUpdateProvider ins;

        public static ProjectUpdateProvider Instantiate(out GameObject go)
        {
            go = new GameObject(nameof(ProjectUpdateProvider));
            return go.AddComponent<ProjectUpdateProvider>();
        }
        
        public static ProjectUpdateProvider Instantiate()
        {
            GameObject go = new(nameof(ProjectUpdateProvider));
            return go.AddComponent<ProjectUpdateProvider>();
        }
        
        private void Awake()
        {
            if(ins == null)
            {
                ins = this;
            }
            else
            {
                Debug.LogWarning("There was 2 ProjectUpdateProvider on scene removed first one.");
                ins.gameObject.Destroy();
                ins = this;
            }
            
            DontDestroyOnLoad(ins);
        }
        
        private void Update()
        {
            On_Update?.Invoke();
        }   

        private void FixedUpdate()
        {
            On_FixedUpdate?.Invoke();
        }

        private void LateUpdate()
        {
            On_LateUpdate?.Invoke();
        }
    }
}