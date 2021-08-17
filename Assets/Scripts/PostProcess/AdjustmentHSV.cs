using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AdjustmentHSV : PostProcessBase
{
	protected override Material Material
	{
		get
		{
			if (shader == null) shader = Shader.Find("PostProcess/AdjustmentHSV");
			if (!shader.isSupported) return null;
			if (material == null) material = new Material(shader);
			return material;
		}
	}

	[Range(0.0f, 4.0f), Tooltip("亮度")]
	public float brightness = 1.0f;
	[Range(0.0f, 4.0f), Tooltip("饱和度")]
	public float saturation = 1.0f;
	[Range(0.0f, 4.0f), Tooltip("对比度")]
	public float constrast = 1.0f;

	private int _brightness_saturation_contrast_id;
	protected override void OnEnable()
	{
		base.OnEnable();
		_brightness_saturation_contrast_id = Shader.PropertyToID("_Brightness_Saturation_Contrast");
	}

	public override void RenderImage(RenderTexture src, RenderTexture dst)
	{
		if (Material == null)
		{
			Graphics.Blit(src, dst);
			return;
		}
		material.SetVector(_brightness_saturation_contrast_id, new Vector4(brightness, saturation, constrast));
		Graphics.Blit(src, dst, material);
	}
}
