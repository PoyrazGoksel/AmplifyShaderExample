using UnityEngine.Events;

namespace Extensions.System
{
    public class RPCEvent
    {
        private event UnityAction On_Event;
        private bool _isTriggered;

        public RPCEvent()
        {
            On_Event += OnEvent;
        }

        public void Register(UnityAction unityAction)
        {
            On_Event += unityAction;
            if(_isTriggered) { unityAction?.Invoke(); }
        }

        public void UnRegister(UnityAction unityAction)
        {
            On_Event -= unityAction;
        }

        private void OnEvent()
        {
            _isTriggered = true;
        }

        public virtual void Invoke() {On_Event?.Invoke();}
    }
    public class RPCEvent<T>
    {
        private event UnityAction<T> On_Event;
        private bool _isTriggered;
        private T _typeCache;

        public RPCEvent()
        {
            On_Event += OnEvent;
        }

        public void Register(UnityAction<T> unityAction)
        {
            On_Event += unityAction;
            if(_isTriggered) { unityAction?.Invoke(_typeCache); }
        }

        public void UnRegister(UnityAction<T> unityAction)
        {
            On_Event -= unityAction;
        }

        private void OnEvent(T type)
        {
            _typeCache = type;
            _isTriggered = true;
        }

        public void Invoke(T type) {On_Event?.Invoke(type);}
    }
}