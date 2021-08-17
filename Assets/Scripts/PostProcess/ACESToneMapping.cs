using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ACESToneMapping : PostProcessBase
{
	[Range(0.0f, 4.0f)]
	public float aces_factor = 1.0f;
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/ACESToneMapping");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	private int aces_factor_id;

	protected override void OnEnable()
	{
		base.OnEnable();

		aces_factor_id = Shader.PropertyToID("_ACES_Factor");
	}

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if (Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}
		material.SetFloat(aces_factor_id, aces_factor);
		Graphics.Blit(src, dst, material);
	}
}
