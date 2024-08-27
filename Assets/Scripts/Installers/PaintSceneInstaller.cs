using Events;
using Zenject;

namespace Installers
{
    public class PaintSceneInstaller : MonoInstaller<PaintSceneInstaller>
    {
        public override void Start()
        {
            
        }

        public override void InstallBindings()
        {
            Container.Bind<PaintSceneEvents>().AsSingle();
        }
    }
}