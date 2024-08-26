using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace PaintIn3D
{
	/// <summary>This allows you to spawn a prefab at a hit point. Hit points will automatically be sent by any <b>P3dHit___</b> component on this GameObject, or its ancestors.</summary>
	[HelpURL(P3dHelper.HelpUrlPrefix + "P3dSpawner")]
	[AddComponentMenu(P3dHelper.ComponentMenuPrefix + "Examples/Spawner")]
	public class P3dSpawner : MonoBehaviour, IHit, IHitPoint
	{
		/// <summary>The prefab that will be spawned.</summary>
		public GameObject Prefab { set { prefab = value; } get { return prefab; } } [SerializeField] private GameObject prefab;

		/// <summary>The offset from the hit point based on the normal in world space.</summary>
		public float Offset { set { offset = value; } get { return offset; } } [SerializeField] private float offset;

		/// <summary>If the prefab contains a <b>Rigidbody</b>, it will be given this velocity in local space.</summary>
		public Vector3 Velocity { set { velocity = value; } get { return velocity; } } [SerializeField] private Vector3 velocity;

		/// <summary>Call this if you want to manually spawn the specified prefab.</summary>
		public void Spawn()
		{
			Spawn(transform.position, transform.rotation);
		}

		public void Spawn(Vector3 position, Vector3 normal)
		{
			Spawn(position, Quaternion.LookRotation(normal));
		}

		public void Spawn(Vector3 position, Quaternion rotation)
		{
			if (prefab != null)
			{
				var clone     = Instantiate(prefab, position, transform.rotation, default(Transform));
				var rigidbody = clone.GetComponent<Rigidbody>();

				if (rigidbody != null)
				{
					rigidbody.velocity = transform.rotation * velocity;
				}

				clone.SetActive(true);
			}
		}

		public void HandleHitPoint(bool preview, int priority, float pressure, int seed, Vector3 position, Quaternion rotation)
		{
			Spawn(position + rotation * Vector3.forward * offset, rotation);
		}
	}
}

#if UNITY_EDITOR
namespace PaintIn3D
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(P3dSpawner))]
	public class P3dSpawner_Editor : P3dEditor<P3dSpawner>
	{
		protected override void OnInspector()
		{
			BeginError(Any(t => t.Prefab == null));
				Draw("prefab", "The prefab that will be spawned.");
			EndError();
			Draw("offset", "The offset from the hit point based on the normal in world space.");
			Draw("velocity", "If the prefab contains a Rigidbody, it will be given this velocity in local space.");
		}
	}
}
#endif