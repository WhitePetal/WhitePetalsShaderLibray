using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mosaicer : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/Mosaicer");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	[Range(0, 100)]
	public int mosaicerDensity = 5;
	[Range(1, 100)]
	public int mosaicerMulit = 1;

	private int _MosaicerFlagTex_id, _MosaicerDensity_id;

	protected override void OnEnable()
	{
		base.OnEnable();
		_MosaicerFlagTex_id = Shader.PropertyToID("_MosaicerFlagTex");
		_MosaicerDensity_id = Shader.PropertyToID("_MosaicerDensity");
	}

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if(Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}

		material.SetTexture(_MosaicerFlagTex_id, PostProcessProfiler.Instance.PostProcessRenderTexture);
		material.SetFloat(_MosaicerDensity_id, mosaicerDensity * mosaicerMulit);
		Graphics.Blit(src, dst, material);
	}
}
