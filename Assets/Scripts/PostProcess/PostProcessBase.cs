using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class PostProcessBase : MonoBehaviour
{
    protected Material material;
    protected Shader shader;
    protected abstract Material Material { get; }

	protected virtual void OnEnable()
	{
		PostProcessProfiler.Instance.postProcessList.Add(this);
	}

	protected virtual void OnDisable()
	{
		if (PostProcessProfiler.Instance == null || PostProcessProfiler.Instance.postProcessList == null) return;
		PostProcessProfiler.Instance.postProcessList.Remove(this);
	}

	public abstract void RenderImage(RenderTexture src, RenderTexture dst);
}
