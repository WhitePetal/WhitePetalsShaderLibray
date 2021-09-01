using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VolumeDecals : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/VolumeDecals");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	public Texture3D decalTex;

	private int decalTex_id;

	protected override void OnEnable()
	{
		base.OnEnable();

		decalTex_id = Shader.PropertyToID("_DecilTex");
	}

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if (Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}
		material.SetTexture(decalTex_id, decalTex);
		material.SetTexture("_MDepthTex", PostProcessProfiler.Instance.PostProcessRenderTexture);
		Graphics.Blit(src, dst, material);
	}
}
