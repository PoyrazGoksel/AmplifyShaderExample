using UnityEngine;

namespace Extensions.Unity.PhysicsExt
{
    public static class ColliderExt
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="charCollider"></param>
        /// <param name="charColliderPos"></param>
        /// <param name="newCharacterTransform"></param>
        /// <param name="terrainSpawnPos"></param>
        /// <param name="colliderLayers"></param>
        /// <param name="groundLayer"></param>
        /// <param name="rayCastToSpawnHeight"></param>
        /// <returns>False if can`t find pos IE: No ground</returns>
        public static bool TryFitColliderInPhysics
        (
            this Collider charCollider, Vector3 charColliderPos,
            Transform newCharacterTransform,
            out Vector3 terrainSpawnPos, LayerMask colliderLayers, string groundLayer = "Ground", float rayCastToSpawnHeight = 200f
        )
        {
            if(GetTerrainPos
                (
                    charColliderPos,
                    out terrainSpawnPos,
                    groundLayer,
                    rayCastToSpawnHeight
                )
                == false)
            {
                return false;
            }

            for (int i = 0; i < 10; i++)
            {
                Collider[] overlapCols = Physics.OverlapBox(terrainSpawnPos, charCollider.bounds.extents, Quaternion.identity, colliderLayers ,QueryTriggerInteraction.Ignore);
                
                if (overlapCols.Length == 0)
                {
                    newCharacterTransform.position = terrainSpawnPos;

                    return false;
                }

                foreach (Collider col in overlapCols)
                {
                    Physics.ComputePenetration
                    (
                        charCollider,
                        terrainSpawnPos,
                        Quaternion.identity,
                        col,
                        col.bounds.center,
                        Quaternion.identity,
                        out Vector3 dirToSeperate,
                        out float distToSeperate
                    );
                    
                    terrainSpawnPos += dirToSeperate * distToSeperate;
                }
                
                if (!GetTerrainPos(terrainSpawnPos, out terrainSpawnPos, groundLayer, rayCastToSpawnHeight))
                {
                    break;
                }
            }

            return true;
        }

        private static bool GetTerrainPos
        (Vector3 spawnPos, out Vector3 newTerrainPos, string groundLayer, float rayCastToSpawnHeight)
        {
            newTerrainPos = Vector3.zero;
            Vector3 topPos = spawnPos + Vector3.up * rayCastToSpawnHeight;
            
            RaycastHit[] groundHits = Physics.RaycastAll(
                topPos,
                Vector3.down,
                Mathf.Infinity,
                LayerMask.GetMask(groundLayer),
                QueryTriggerInteraction.Ignore
            );

            if (groundHits.Length == 0)
            {
                Debug.LogWarning("No ground found for spawning.");

                return false;
            }

            newTerrainPos = groundHits[0].point/* + GetSpawnHeight(charExtents.y)*/;

            return true;
        }
    }
}