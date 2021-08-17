using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessProfiler : MonoBehaviour
{
	private static PostProcessProfiler instance;
    public static PostProcessProfiler Instance
	{
		get
		{
			if(instance == null)
			{
				if (Camera.main == null) return null;
				if(!Camera.main.TryGetComponent<PostProcessProfiler>(out instance))
				{
					instance = Camera.main.gameObject.AddComponent<PostProcessProfiler>();
				}
			}
			return instance;
		}
	}

	private Camera cam;
	private RenderBuffer[] colorBuffers;
	private RenderTexture[] renderTextures;
	private RenderTexture tempDst;

	public List<PostProcessBase> postProcessList;
	public RenderTexture PostProcessRenderTexture
	{
		get
		{
			return renderTextures[1];
		}
	}

	private void Awake()
	{
		if(instance != null)
		{
            Debug.LogError("A singleton already Exists!!!!" + this);
			Destroy(gameObject.GetComponent<PostProcessProfiler>());
			return;
		}
		instance = GetComponent<PostProcessProfiler>();
		postProcessList = new List<PostProcessBase>();
		renderTextures = new RenderTexture[2]
		{
			new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear),
			new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.Default, RenderTextureReadWrite.Linear)
		};
		foreach(var r in renderTextures)
		{
			r.antiAliasing = 4;
		}
		renderTextures[0].name = "MainRenderTexture";
		renderTextures[1].name = "PostProcessRenderTexture";
		colorBuffers = new RenderBuffer[2]
		{
			renderTextures[0].colorBuffer,
			renderTextures[1].colorBuffer
		};

		cam = Camera.main;
		cam.SetTargetBuffers(colorBuffers, renderTextures[0].depthBuffer);
		//Graphics.SetRenderTarget(colorBuffers, renderTextures[0].depthBuffer);
		tempDst = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBHalf);
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		RenderTexture src = renderTextures[0];
		RenderTexture dst = tempDst;
		foreach (var effect in postProcessList)
		{
			effect.RenderImage(src, dst);
			// 交换指针，将当前后处理的输出 作为 下个后处理的输入
			RenderTexture temp = src;
			src = dst;
			dst = temp;
		}
		Graphics.Blit(src, destination);
	}

	private void OnDestroy()
	{
		cam.targetTexture = null;
		if(renderTextures != null)
		{
			foreach(var r in renderTextures)
			{
				r.Release();
				Debug.Log(r);
			}
		}
		RenderTexture.ReleaseTemporary(tempDst);
		tempDst = null;
		renderTextures = null;
		colorBuffers = null;
		postProcessList.Clear();
		postProcessList = null;
		instance = null;
	}
}
