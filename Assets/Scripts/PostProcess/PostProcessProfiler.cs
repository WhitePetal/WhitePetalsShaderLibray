using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

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

	public int _MShadowMapDepth = 64;
	[Range(0.0001f, 1.0f)]
	public float shadowMapSize = 1;

	private Camera cam;
	private Camera cam_Shadow;
	private RenderBuffer[] colorBuffers;
	private RenderTexture[] renderTextures;
	private RenderTexture shadowMap;
	private RenderTexture tempDst;

	private Light mainLight;

	private int width, height;

	public List<PostProcessBase> postProcessList;
	public RenderTexture PostProcessRenderTexture
	{
		get
		{
			return renderTextures[1];
		}
	}
	public RenderTexture ShadowMap
	{
		get
		{
			return shadowMap;
		}
	}

	private void Awake()
	{
		cam = GetComponent<Camera>();
		if(instance != null)
		{
            Debug.LogError("A singleton already Exists!!!!" + this);
			DestroyImmediate(instance.gameObject.GetComponent<PostProcessProfiler>());
			return;
		}
		instance = GetComponent<PostProcessProfiler>();
		postProcessList = new List<PostProcessBase>();
		mainLight = Light.GetLights(LightType.Directional, 0)[0];
		InitRenderBuffer();
	}

	private void InitRenderBuffer()
	{
		if(renderTextures != null && renderTextures.Length > 0)
		{
			cam.targetTexture = null;
			foreach (var r in renderTextures) r.Release();
		}
		renderTextures = new RenderTexture[2]
		{
			new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear),
			new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear)
		};
		renderTextures[1].filterMode = FilterMode.Point;
		width = Screen.width;
		height = Screen.height;
		foreach (var r in renderTextures)
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
		if (tempDst != null) RenderTexture.ReleaseTemporary(tempDst);
		tempDst = RenderTexture.GetTemporary(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBHalf);
		cam.SetTargetBuffers(colorBuffers, renderTextures[0].depthBuffer);

		if (shadowMap != null) shadowMap.Release();
		shadowMap = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.RG16);
		shadowMap.name = "MShadowMap";

		if (cam_Shadow == null)
		{
			cam_Shadow = new GameObject().AddComponent<Camera>();
			cam_Shadow.transform.parent = mainLight.transform;
			cam_Shadow.name = "Camera_Shadow";
			cam_Shadow.enabled = false;
		}
		cam_Shadow.transform.localPosition = Vector3.zero;
		cam_Shadow.transform.localRotation = Quaternion.identity;
		cam_Shadow.targetTexture = shadowMap;
		cam_Shadow.clearFlags = CameraClearFlags.SolidColor;
		cam_Shadow.backgroundColor = Color.white;
		cam_Shadow.orthographic = true;
	}

	private void OnPreRender()
	{
		if (width != Screen.width || height != Screen.height) InitRenderBuffer();
		mainLight.transform.position = -mainLight.transform.forward * _MShadowMapDepth * 0.5f;
		Matrix4x4 mworldToLightMat = mainLight.transform.worldToLocalMatrix;
		Shader.SetGlobalMatrix("_MWorldToLightMat", mworldToLightMat);
		float x_mshadow = Screen.width * shadowMapSize;
		//float x_min_mshadow = -x_max_mshadow;
		float y_mshadow = Screen.height * shadowMapSize;
		//float y_min_mshadow = -y_max_mshadow;
		float z_max_mshadow = _MShadowMapDepth;
		Matrix4x4 mshadowMapProjMat = new Matrix4x4
		{
			m00 = 1.0f / x_mshadow, m01 = 0.0f, m02 = 0.0f, m03 = 0.0f,
			m10 = 0.0f, m11 = 1.0f / y_mshadow, m12 = 0.0f, m13 = 0.0f,
			m20 = 0.0f, m21 = 0.0f, m22 = 2.0f / z_max_mshadow, m23 = -1.0f,
			m30 = 0.0f, m31 = 0.0f, m32 = 0.0f, m33 = 1.0f
		};
		Shader.SetGlobalVector("_MShadowMapParams", new Vector4(Screen.width, Screen.height, _MShadowMapDepth));
		Shader.SetGlobalMatrix("_MWorldToShadowClipMat", mshadowMapProjMat * mworldToLightMat);
		//cam_Shadow.orthographicSize = Screen.width * Screen.height * 0.01f;
		Camera.SetupCurrent(cam_Shadow);
		cam_Shadow.RenderWithShader(Shader.Find("Hidden/ShadowMapGenerater"), "RenderWithShader");
		Camera.SetupCurrent(cam);
		Shader.SetGlobalTexture("_MShadowMap", shadowMap);
		Shader.SetGlobalVector("_MShadowMapParams", new Vector4(Screen.width, Screen.height, _MShadowMapDepth));
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
			cam.targetTexture = null;
			foreach(var r in renderTextures)
			{
				r.Release();
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
