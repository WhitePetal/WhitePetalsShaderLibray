using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SetRenderTargetTest : MonoBehaviour
{
    private Camera cam;
    private RenderTexture rt1;

    // Start is called before the first frame update
    void Start()
    {
        cam = GetComponent<Camera>();
        RenderTexture rt0 = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf);
        rt1 = RenderTexture.GetTemporary(Screen.width, Screen.height, 24, RenderTextureFormat.ARGBHalf);
        cam.SetTargetBuffers(rt0.colorBuffer, rt0.depthBuffer);
        CommandBuffer cmd0 = new CommandBuffer();
        cmd0.SetRenderTarget(rt0.colorBuffer, rt0.depthBuffer);
        rt0.name = "RT0";
        cmd0.name = "CMD0";
        //cam.targetTexture = rt1;
        //cam.targetTexture = rt0;
        //cmd1.SetRenderTarget(rt1);

        CommandBuffer cmd1 = new CommandBuffer();
        cmd1.SetRenderTarget(rt1.colorBuffer, rt1.depthBuffer);
        //cmd1.Blit(rt0.colorBuffer, rt1);
        rt1.name = "RT1";
        cmd1.name = "CMD1";

        cam.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, cmd0);
		cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, cmd1);
	}

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
        Graphics.Blit(rt1, destination);
	}

	// Update is called once per frame
	void Update()
    {
        
    }
}
