using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(ReplaceMaterials))]
public class ReplaceMaterialsEditor : Editor
{
	public override void OnInspectorGUI()
	{
		ReplaceMaterials t = (ReplaceMaterials)target;
		if (GUILayout.Button("Replace"))
		{
			var trans = t.transform.GetComponentsInChildren<Transform>();
			foreach(var tran in trans)
			{
				Renderer renderer = tran.GetComponent<Renderer>();
				if (renderer == null) continue;
				var mats = renderer.sharedMaterials;
				for(int i = 0; i < mats.Length; ++i)
				{
					var mat = mats[i];
					if (!mat.name.EndsWith("_new"))
					{
						var replaceMat = AssetDatabase.LoadAssetAtPath<Material>("Assets/CrytekSponza/Materials/" + mat.name + "_new.mat");
						if (replaceMat != null) mats[i] = replaceMat;
					}
				}
				renderer.sharedMaterials = mats;
			}
		}
	}
}
