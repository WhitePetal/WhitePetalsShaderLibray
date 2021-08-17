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
	[Range(1, 10)]
	public int downSample = 4;

	private int _MosaicerFlagTex_id, _MosaicerDensity_id, _MoisicTex_id;

	protected override void OnEnable()
	{
		base.OnEnable();
		_MosaicerFlagTex_id = Shader.PropertyToID("_MosaicerFlagTex");
		_MosaicerDensity_id = Shader.PropertyToID("_MosaicerDensity");
		_MoisicTex_id = Shader.PropertyToID("_MoisicTex");
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
		RenderTexture rt0 = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format, 0);
		rt0.filterMode = FilterMode.Point;
		RenderTexture rt1 = RenderTexture.GetTemporary(src.width >> downSample, src.height >> downSample, 0, src.format, 0);
		rt1.filterMode = FilterMode.Point;
		Graphics.Blit(src, rt0, material, 0);
		Graphics.Blit(rt0, rt1, material, 1);
		material.SetTexture(_MoisicTex_id, rt1);
		Graphics.Blit(src, dst, material, 2);
		RenderTexture.ReleaseTemporary(rt0);
		RenderTexture.ReleaseTemporary(rt1);
	}
}
