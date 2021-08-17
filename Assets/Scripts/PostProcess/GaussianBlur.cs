using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/GaussianBlur");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	[Range(0, 5)]
	public int downSample = 1;
	[Range(0, 5)]
	public int iteration = 2;
	public float blurRadius = 2f;

	private int gaussBlurOffset_id;

	protected override void OnEnable()
	{
		base.OnEnable();
		gaussBlurOffset_id = Shader.PropertyToID("_GaussBlurOffset");
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

		Graphics.Blit(src, rt0);
		for (int i = 0; i < iteration; ++i)
		{
			material.SetVector(gaussBlurOffset_id, new Vector4(1.0f + blurRadius / src.width, 0f, 0f));
			Graphics.Blit(rt0, rt1, material);

			material.SetVector(gaussBlurOffset_id, new Vector4(0f, 1.0f + blurRadius / src.height, 0f, 0f));
			Graphics.Blit(rt1, rt0, material);
		}
		Graphics.Blit(rt0, dst);
		RenderTexture.ReleaseTemporary(rt0);
		RenderTexture.ReleaseTemporary(rt1);
	}
}
