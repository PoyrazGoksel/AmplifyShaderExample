using System;
using System.Collections.Generic;
using System.Linq;
using Extensions.System;
using UnityEngine;
using UnityEngine.Events;
using Object = UnityEngine.Object;

namespace Extensions.Unity.Utils
{
    public class MonoPool
    {
        public int ActiveCount{get;private set;}

        private readonly MonoPoolData _monoPoolData;

        private readonly List<PoolObjData> _myPool = new();
        public event Func<GameObject, GameObject> On_InstantiateRequest;
        public event UnityAction<IPoolObj> On_Create;
        public event UnityAction<IPoolObj> On_Spawn;
        public event UnityAction<IPoolObj> On_DeSpawn;
        
        public readonly bool ManualInstantiate;

        /// <summary>
        /// Initializes pool params. Best to call at Awake.
        /// </summary>
        /// <param name="monoPoolData"></param>
        /// <param name="manualInstantiate">If you want to use your class for instantiate algorithm. Mainly for dependency injection famework like Zenject</param>
        public MonoPool(MonoPoolData monoPoolData, bool manualInstantiate = false)
        {
            ManualInstantiate = manualInstantiate;
            _monoPoolData = monoPoolData;

            if(_monoPoolData.Prefab.TryGetComponent(out IPoolObj _) == false)
            {
                Debug.LogError
                ("This is not a pool object. Make sure you inherit IPoolObj at prefab main parent");
            }
        }

        
        /// <summary>
        /// Creates pool with initial size. Best to call at start to be able to listen On_Create events;
        /// </summary>
        public void CreatePool()
        {
            for(int i = 0; i < _monoPoolData.InitSize; i ++) { Create(); }
        }

        private PoolObjData Create(Transform parent = null, Vector3 worldPos = default, Quaternion worldRot = default)
        {
            if (parent == null)
            {
                parent = _monoPoolData.ParentToInstUnder;
            }

            if (worldPos == default)
            {
                worldPos = _monoPoolData.DefaultCreateWorldPos;
            }

            if (worldRot == default)
            {
                worldRot = _monoPoolData.DefaultCreateWorldRot;
            }

            GameObject newObj;

            if(ManualInstantiate == false)
            {
                newObj = Object.Instantiate(_monoPoolData.Prefab, worldPos, worldRot, parent);
            }
            else
            {
                newObj = On_InstantiateRequest?.Invoke(_monoPoolData.Prefab);
            }
            
            
            IPoolObj newPoolObj = newObj.GetComponent<IPoolObj>();

            PoolObjData newPoolListObjData = new
            (
                newPoolObj
            );

            _myPool.Add(newPoolListObjData);
            AfterCreate(newPoolListObjData);
            newPoolListObjData.GameObject.SetActive(false);
            newPoolListObjData.Transform.position = worldPos;
            newPoolListObjData.Transform.rotation = worldRot;
            newPoolListObjData.AssignPool(this);
            newPoolListObjData.IsActive = false;

            return newPoolListObjData;
        }

        public void Request(Transform parent = null, Vector3 worldPos = default, Quaternion worldRot = default) => Request<IPoolObj>(parent, worldPos, worldRot);

        public T Request<T>(Transform parent = null, Vector3 worldPos = default, Quaternion worldRot = default) where T : IPoolObj
        {
            if (parent == null)
            {
                parent = _monoPoolData.ParentToInstUnder;
            }

            if (worldPos == default)
            {
                worldPos = _monoPoolData.DefaultCreateWorldPos;
            }

            if (worldRot == default)
            {
                worldRot = _monoPoolData.DefaultCreateWorldRot;
            }

            PoolObjData foundObjData = _myPool.FirstOrDefault(e => e.IsActive == false);

            if (foundObjData != null)
            {
                foundObjData.GameObject.SetActive(true);
                foundObjData.IsActive = true;

                if (parent != null)
                {
                    foundObjData.Transform.SetParent(parent);
                }

                foundObjData.Transform.position = worldPos;

                foundObjData.Transform.rotation = worldRot;

                AfterRespawn(foundObjData);
                ActiveCount++;
                return (T)foundObjData.MyPoolObj;
            }

            foundObjData = Create(parent, worldPos, worldRot);
            foundObjData.GameObject.SetActive(true);
            AfterRespawn(foundObjData);
            PoolObjData createdPoolObjData = _myPool.Last();
            createdPoolObjData.IsActive = true;
            _myPool[^1] = createdPoolObjData;

            ActiveCount++;
            return (T)foundObjData.MyPoolObj;
        }

        private void AfterCreate(PoolObjData poolObjData)
        {
            poolObjData.AfterCreate();
            On_Create?.Invoke(poolObjData.MyPoolObj);
        }
        
        private void DeSpawn(PoolObjData poolObjData)
        {
            BeforeDeSpawn(poolObjData);
            poolObjData.DeSpawn();
        }

        private void AfterRespawn(PoolObjData poolObjData)
        {
            poolObjData.AfterRespawn();
            On_Spawn?.Invoke(poolObjData.MyPoolObj);
        }
        
        private void BeforeDeSpawn(PoolObjData poolObjData)
        {
            poolObjData.BeforeDeSpawn();
            On_DeSpawn?.Invoke(poolObjData.MyPoolObj);
        }

        public void DeSpawn(IPoolObj poolObj)
        {
            for (int i = 0; i < _myPool.Count; i++)
            {
                PoolObjData thisPoolObjData = _myPool[i];

                if (thisPoolObjData.MyPoolObj == poolObj)
                {
                    DeSpawn(_myPool[i]);
                    ActiveCount--;
                    break;
                }
            }
        }

        public void DeSpawnAll()
        {
            foreach (PoolObjData poolObjData in _myPool)
            {
                DeSpawn(poolObjData);
            }

            ActiveCount = 0;
        }

        public void DeSpawnAfterTween(IPoolObj poolObj)
        {
            for (int i = 0; i < _myPool.Count; i++)
            {
                PoolObjData thisPoolObjData = _myPool[i];

                if (thisPoolObjData.MyPoolObj == poolObj)
                {
                    thisPoolObjData.MyPoolObj.TweenDelayedDeSpawn(delegate
                    {
                        OnOprComplete(thisPoolObjData, i);
                        return true;
                    });

                    _myPool[i] = thisPoolObjData;
                    break;
                }
            }
        }

        private void OnOprComplete(PoolObjData thisPoolObjData, int i)
        {
            thisPoolObjData.IsActive = false;
            ActiveCount--;
            BeforeDeSpawn(thisPoolObjData);
            thisPoolObjData.GameObject.SetActive(false);
        }

        public void SendMessageAll<T>(Action<T> func)
        {
            foreach (PoolObjData poolObjData in _myPool)
            {
                func((T)poolObjData.MyPoolObj);
            }
        }

        public void SendMessage<T>(Action<T> func, int i)
        {
            func((T)_myPool[i].MyPoolObj);
        }

        public void DestroyPool()
        {
            _myPool.DoToAll(po => Object.Destroy(po.GameObject));
            _myPool.Clear();
        }
    }

    public readonly struct MonoPoolData
    {
        public readonly GameObject Prefab;
        public readonly int InitSize;
        public readonly Transform ParentToInstUnder;
        public readonly Vector3 DefaultCreateWorldPos;
        public readonly Quaternion DefaultCreateWorldRot;

        public MonoPoolData(GameObject prefab, int initSize, Transform parentToInstUnder = null, Vector3 defaultCreateWorldPos = default, Quaternion defaultCreateWorldRot = default)
        {
            Prefab = prefab;

            if (initSize <= 0)
            {
                initSize = 1;
            }

            InitSize = initSize;
            ParentToInstUnder = parentToInstUnder;
            DefaultCreateWorldPos = defaultCreateWorldPos;
            DefaultCreateWorldRot = defaultCreateWorldRot;
        }
    }

    public class PoolObjData
    {
        public readonly IPoolObj MyPoolObj;
        public readonly Transform Transform;
        public readonly GameObject GameObject;

        public bool IsActive;

        public PoolObjData(){}
        
        public PoolObjData(IPoolObj myPoolObj)
        {
            MyPoolObj = myPoolObj;
            IsActive = default;
            Transform = myPoolObj.transform;
            GameObject = myPoolObj.gameObject;
        }

        public void DeSpawn()
        {
            GameObject.SetActive(false);
            IsActive = false;
        }

        public void AssignPool(MonoPool myPool)
        {
            MyPoolObj.MyPool = myPool;
        }

        public void AfterCreate() => MyPoolObj.AfterCreate();
        public void BeforeDeSpawn() => MyPoolObj.BeforeDeSpawn();
        public void AfterRespawn() => MyPoolObj.AfterSpawn();
    }

    public interface IPoolObj
    {
        Transform transform{get;}
        GameObject gameObject { get; }
        MonoPool MyPool { get; set; }
        /// <summary>
        /// Only called on Instantiate
        /// </summary>
        void AfterCreate();
        void BeforeDeSpawn();
        void TweenDelayedDeSpawn(Func<bool> invokeOnTweenComplete);
        /// <summary>
        /// Only called after SetActive(true)
        /// </summary>
        void AfterSpawn();
    }
}