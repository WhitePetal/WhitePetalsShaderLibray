using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthOfField : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/DepthOfField");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	[Tooltip("焦距")]
	public float f = 1.0f;
	[Tooltip("主体放大倍数")]
	public float m_s = 1.0f;
	[Tooltip("光圈数")]
	public int N = 2;
	[Range(0.0f, 1.0f)]
	public float Imr = 0.5f;
	[Range(0.0f, 0.1f)]
	public float z_focus = 0.3f;
	[Range(0.0f, 1.0f)]
	public float z_cam = 0.1f;
	[Range(0, 6)]
	public int downSample = 2;
	[Range(0, 30)]
	public int iteration = 3;
	[Range(0.0f, 1.0f)]
	public float blurRadius;

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if(Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}
		float s = z_cam + Imr * (z_focus);
		material.SetTexture("_MDepthTex", PostProcessProfiler.Instance.PostProcessRenderTexture);
		material.SetFloat("_z_cam", z_cam);
		material.SetFloat("_ms", m_s);
		material.SetFloat("_N", N);
		material.SetFloat("_s", s);
		material.SetFloat("_Imr", Imr);
		material.SetFloat("_z_focus", z_focus);
		int width = src.width >> downSample;
		int height = src.height >> downSample;

		var rt0 = RenderTexture.GetTemporary(width, height, 0, src.format);
		var rt1 = RenderTexture.GetTemporary(width, height, 0, src.format);

		Graphics.Blit(src, rt0);
		for (int i = 0; i < iteration; ++i)
		{
			material.SetVector("_GaussBlurOffset", new Vector4(i * blurRadius / src.width, 0f, 0f));
			Graphics.Blit(rt0, rt1, material);

			material.SetVector("_GaussBlurOffset", new Vector4(0f, i * blurRadius / src.height, 0f, 0f));
			Graphics.Blit(rt1, rt0, material);
		}
		Graphics.Blit(rt0, dst);
		RenderTexture.ReleaseTemporary(rt0);
		RenderTexture.ReleaseTemporary(rt1);
	}
}
