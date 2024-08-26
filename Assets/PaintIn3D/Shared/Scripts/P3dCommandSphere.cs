﻿using System.Collections.Generic;
using UnityEngine;

namespace PaintIn3D
{
	/// <summary>This class manages the sphere painting command.</summary>
	public class P3dCommandSphere : P3dCommand
	{
		public bool      In3D;
		public Vector3   Position;
		public Vector3   EndPosition;
		public Vector3   Position2;
		public Vector3   EndPosition2;
		public int       Extrusions;
		public Matrix4x4 Matrix;
		public Color     Color;
		public float     Opacity;
		public float     Hardness;
		public Texture   TileTexture;
		public Matrix4x4 TileMatrix;
		public float     TileOpacity;
		public float     TileTransition;
		public Matrix4x4 MaskMatrix;
		public Texture   MaskShape;
		public Vector4   MaskChannel;
		public Vector3   MaskStretch;

		public static P3dCommandSphere Instance = new P3dCommandSphere();

		private static Stack<P3dCommandSphere> pool = new Stack<P3dCommandSphere>();

		private static Material[] cachedSpotMaterials;

		private static Material[] cachedLineMaterials;

		private static Material[] cachedQuadMaterials;

		public override bool RequireMesh { get { return true; } }

		static P3dCommandSphere()
		{
			cachedSpotMaterials = P3dShader.BuildMaterialsBlendModes("Hidden/Paint in 3D/Sphere");
			cachedLineMaterials = P3dShader.BuildMaterialsBlendModes("Hidden/Paint in 3D/Sphere", "P3D_LINE");
			cachedQuadMaterials = P3dShader.BuildMaterialsBlendModes("Hidden/Paint in 3D/Sphere", "P3D_QUAD");
		}

		public override void Apply()
		{
			Blend.Apply(Material);

			var inv = Matrix.inverse;
				
			Material.SetFloat(P3dShader._In3D, In3D ? 1.0f : 0.0f);
			Material.SetVector(P3dShader._Position, inv.MultiplyPoint(Position));
			Material.SetVector(P3dShader._EndPosition, inv.MultiplyPoint(EndPosition));
			Material.SetVector(P3dShader._Position2, inv.MultiplyPoint(Position2));
			Material.SetVector(P3dShader._EndPosition2, inv.MultiplyPoint(EndPosition2));
			Material.SetMatrix(P3dShader._Matrix, inv);
			Material.SetColor(P3dShader._Color, Color);
			Material.SetFloat(P3dShader._Opacity, Opacity);
			Material.SetFloat(P3dShader._Hardness, Hardness);
			Material.SetTexture(P3dShader._TileTexture, TileTexture);
			Material.SetMatrix(P3dShader._TileMatrix, TileMatrix);
			Material.SetFloat(P3dShader._TileOpacity, TileOpacity);
			Material.SetFloat(P3dShader._TileTransition, TileTransition);
			Material.SetMatrix(P3dShader._MaskMatrix, MaskMatrix);
			Material.SetTexture(P3dShader._MaskTexture, MaskShape);
			Material.SetVector(P3dShader._MaskChannel, MaskChannel);
			Material.SetVector(P3dShader._MaskStretch, MaskStretch);
		}

		public override void Pool()
		{
			pool.Push(this);
		}

		public override void Transform(Matrix4x4 posMatrix, Matrix4x4 rotMatrix)
		{
			Position     = posMatrix.MultiplyPoint(Position);
			EndPosition  = posMatrix.MultiplyPoint(EndPosition);
			Position2    = posMatrix.MultiplyPoint(Position2);
			EndPosition2 = posMatrix.MultiplyPoint(EndPosition2);
			Matrix       = rotMatrix * Matrix;
		}

		public override P3dCommand SpawnCopy()
		{
			var command = SpawnCopy(pool);
			
			command.In3D           = In3D;
			command.Position       = Position;
			command.EndPosition    = EndPosition;
			command.Position2      = Position2;
			command.EndPosition2   = EndPosition2;
			command.Extrusions     = Extrusions;
			command.Matrix         = Matrix;
			command.Color          = Color;
			command.Opacity        = Opacity;
			command.Hardness       = Hardness;
			command.TileTexture    = TileTexture;
			command.TileMatrix     = TileMatrix;
			command.TileOpacity    = TileOpacity;
			command.TileTransition = TileTransition;
			command.MaskMatrix     = MaskMatrix;
			command.MaskShape      = MaskShape;
			command.MaskChannel    = MaskChannel;
			command.MaskStretch    = MaskStretch;

			return command;
		}

		public void SetLocation(Vector3 position, bool in3D = true)
		{
			In3D       = in3D == true;
			Extrusions = 0;
			Position   = position;
		}

		public void SetLocation(Vector3 position, Vector3 endPosition, bool in3D = true)
		{
			In3D        = in3D == true;
			Extrusions  = 1;
			Position    = position;
			EndPosition = endPosition;
		}

		public void SetLocation(Vector3 positionA, Vector3 positionB, Vector3 positionC, bool in3D = true)
		{
			In3D         = in3D == true;
			Extrusions   = 2;
			Position     = positionA;
			EndPosition  = positionB;
			Position2    = positionC;
			EndPosition2 = positionA;
		}

		public void SetLocation(Vector3 position, Vector3 endPosition, Vector3 position2, Vector3 endPosition2, bool in3D = true)
		{
			In3D         = in3D == true;
			Extrusions   = 2;
			Position     = position;
			EndPosition  = endPosition;
			Position2    = position2;
			EndPosition2 = endPosition2;
		}

		public void ClearMask()
		{
			MaskChannel = Vector3.one;
		}

		public void SetMask(Matrix4x4 matrix, Texture shape, P3dChannel channel, Vector3 stretch)
		{
			MaskMatrix  = matrix;
			MaskShape   = shape;
			MaskChannel = P3dHelper.IndexToVector((int)channel);
			MaskStretch = new Vector3(2.0f / stretch.x, 2.0f / stretch.y, 2.0f);
		}

		public void ApplyAspect(Texture texture)
		{
			if (texture != null)
			{
				var width  = texture.width;
				var height = texture.height;

				if (width > height)
				{
					Matrix.m00 *= height / (float)width;
				}
				else
				{
					Matrix.m00 *= width / (float)height;
				}
			}
		}

		public void SetShape(float radius)
		{
			Matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one * radius);
		}

		public void SetShape(Quaternion rotation, Vector3 size, float angle)
		{
			if (In3D == true)
			{
				Matrix = Matrix4x4.TRS(Vector3.zero, rotation * Quaternion.Euler(0.0f, 0.0f, angle), size);
			}
			else
			{
				Matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(0.0f, 0.0f, angle), size);
			}
		}

		public void SetMaterial(P3dBlendMode blendMode, float hardness, Color color, float opacity, Texture tileTexture, Matrix4x4 tileMatrix, float tileOpacity, float tileTransition)
		{
			switch (Extrusions)
			{
				case 0: Material = cachedSpotMaterials[blendMode]; break;
				case 1: Material = cachedLineMaterials[blendMode]; break;
				case 2: Material = cachedQuadMaterials[blendMode]; break;
			}

			Blend          = blendMode;
			Hardness       = hardness;
			Color          = color;
			Opacity        = opacity;
			TileTexture    = tileTexture;
			TileMatrix     = tileMatrix;
			TileOpacity    = tileOpacity;
			TileTransition = tileTransition;
		}
	}
}