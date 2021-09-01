using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VolumeLightScatter : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/VolumeLightScatter");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if (Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}
		RenderTexture rt0 = RenderTexture.GetTemporary(src.width >> 2, src.height >> 2, 0, src.format);
		RenderTexture rt1 = RenderTexture.GetTemporary(src.width >> 2, src.height >> 2, 0, src.format);
		material.SetTexture("_MDepthTex", PostProcessProfiler.Instance.PostProcessRenderTexture);
		Graphics.Blit(rt0, rt1, material, 0);
		material.SetTexture("_VolumeLightTex", rt1);
		Graphics.Blit(src, dst, material, 1);
		RenderTexture.ReleaseTemporary(rt0);
		RenderTexture.ReleaseTemporary(rt1);
	}
}
