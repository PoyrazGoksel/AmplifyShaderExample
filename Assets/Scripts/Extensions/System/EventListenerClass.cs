using System;
using Zenject;

namespace Extensions.System
{
    public abstract class EventListenerClass : IInitializable, IDisposable
    {
        public virtual void Initialize()
        {
            RegisterEvents();
        }

        public virtual void Dispose()
        {
            UnRegisterEvents();
        }

        protected abstract void RegisterEvents();
        protected abstract void UnRegisterEvents();
    }
}