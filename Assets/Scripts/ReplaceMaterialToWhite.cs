using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ReplaceMaterialToWhite : MonoBehaviour
{
	public Material material;

	private void Awake()
	{
		Renderer[] renderers = GetComponentsInChildren<Renderer>();
		foreach(var r in renderers)
		{
			var mats = r.materials;
			for (int i = 0; i < mats.Length; ++i) mats[i] = material;
			r.materials = mats;
		}
	}
}
