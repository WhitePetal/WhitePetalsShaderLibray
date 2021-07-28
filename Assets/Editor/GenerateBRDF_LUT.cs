﻿using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.IO;

public class GenerateBRDF_LUT : Editor
{
	private static string lutPath = "Assets/Textures/LUTs";
	[MenuItem("Tools/GenerateBRFG_LUT")]
	private static void Generate()
	{
		ComputeShader cs = AssetDatabase.LoadAssetAtPath<ComputeShader>("Assets/Shaders/ComputeShaders/BRDF_Compute.compute");
		RenderTexture rt = RenderTexture.GetTemporary(1024, 1024, 0);
		rt.enableRandomWrite = true;
		rt.Create();
		int kernel = cs.FindKernel("CSMain");
		cs.SetTexture(kernel, "Result", rt);
		cs.Dispatch(kernel, 1024 / 8, 1024 / 8, 1);
		Texture2D tex = new Texture2D(1024, 1024, TextureFormat.ARGB32, false);
		RenderTexture activeRT = RenderTexture.active;
		RenderTexture.active = rt;
		tex.ReadPixels(new Rect(0, 0, 1024, 1024), 0, 0);
		tex.Apply();
		RenderTexture.active = activeRT;
		RenderTexture.ReleaseTemporary(rt);
		byte[] data = tex.EncodeToPNG();
		if (!Directory.Exists(lutPath)) Directory.CreateDirectory(lutPath);
		File.WriteAllBytes(lutPath + "/BRDF_LUT.png", data);
		Texture2D.DestroyImmediate(tex);
	}
}
