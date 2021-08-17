using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/Bloom");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	[Range(0, 4)]
	public int iterations = 3;
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;
	[Range(1, 8)]
	public int downSample = 2;
	[Range(0.0f, 4.0f)]
	public float luminanceThreshold = 0.6f;
	public Color32 bloomColor = Color.white;

	private int _Global_BloomThreshold_id, _BloomFlagTex_id, _GaussBlurOffset_id, _BloomTex_id, _BloomColor_id;

	protected override void OnEnable()
	{
		base.OnEnable();
		_Global_BloomThreshold_id = Shader.PropertyToID("_Global_BloomThreshold");
		_BloomFlagTex_id = Shader.PropertyToID("_BloomFlagTex");
		_GaussBlurOffset_id = Shader.PropertyToID("_GaussBlurOffset");
		_BloomTex_id = Shader.PropertyToID("_BloomTex");
		_BloomColor_id = Shader.PropertyToID("_BloomColor");
	}

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if (Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}
		int width = src.width >> downSample;
		int height = src.height >> downSample;

		var rt0 = RenderTexture.GetTemporary(width, height, 0, src.format);
		var rt1 = RenderTexture.GetTemporary(width, height, 0, src.format);
		Shader.SetGlobalFloat(_Global_BloomThreshold_id, luminanceThreshold);
		material.SetTexture(_BloomFlagTex_id, PostProcessProfiler.Instance.PostProcessRenderTexture, UnityEngine.Rendering.RenderTextureSubElement.Color);
		Graphics.Blit(src, rt0, material, 0);
		for (int i = 0; i < iterations; ++i)
		{
			material.SetVector(_GaussBlurOffset_id, new Vector4(i * blurSpread / src.width, 0f, 0f));
			Graphics.Blit(rt0, rt1, material, 1);

			material.SetVector(_GaussBlurOffset_id, new Vector4(0f, i * blurSpread / src.height, 0f, 0f));
			Graphics.Blit(rt1, rt0, material, 1);
		}
		material.SetTexture(_BloomTex_id, rt0);
		material.SetColor(_BloomColor_id, bloomColor * Color.white * 2.0f);
		Graphics.Blit(src, dst, material, 2);
		RenderTexture.ReleaseTemporary(rt0);
		RenderTexture.ReleaseTemporary(rt1);
	}
}
