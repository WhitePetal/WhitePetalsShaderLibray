using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class VectorRangeDrawer : MaterialPropertyDrawer
{
	private Vector2 range0, range1, range2, range3;
	public VectorRangeDrawer(float min0, float max0, float min1, float max1, float min2, float max2, float min3, float max3)
	{
		range0 = new Vector2(min0, max0);
		range1 = new Vector2(min1, max1);
		range2 = new Vector2(min2, max2);
		range3 = new Vector2(min3, max3);
	}
	public VectorRangeDrawer(float min0, float max0, float min1, float max1, float min2, float max2)
	{
		range0 = new Vector2(min0, max0);
		range1 = new Vector2(min1, max1);
		range2 = new Vector2(min2, max2);
		range3 = Vector2.zero;
	}
	public VectorRangeDrawer(float min0, float max0, float min1, float max1)
	{
		range0 = new Vector2(min0, max0);
		range1 = new Vector2(min1, max1);
		range2 = Vector2.zero;
		range3 = Vector2.zero;
	}
	public VectorRangeDrawer(float min0, float max0)
	{
		range0 = new Vector2(min0, max0);
		range1 = Vector2.zero;
		range2 = Vector2.zero;
		range3 = Vector2.zero;
	}

	public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
	{
		return base.GetPropertyHeight(prop, label, editor);
	}

	public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
	{
		Vector4 value = prop.vectorValue;
		string[] names = prop.displayName.Split('_');
		int count = 0;
		EditorGUI.BeginChangeCheck();
		if (range0.x < range0.y)
		{
			value.x = EditorGUI.Slider(position, new GUIContent(names[0]), value.x, range0.x, range0.y);
			position.y += position.height + 5;
			++count;
		}
		if (range1.x < range1.y)
		{
			value.y = EditorGUI.Slider(position, new GUIContent(names[1]), value.y, range1.x, range1.y);
			position.y += position.height + 5;
			++count;
		}
		if (range2.x < range2.y)
		{
			value.z = EditorGUI.Slider(position, new GUIContent(names[2]), value.z, range2.x, range2.y);
			position.y += position.height + 5;
			++count;
		}
		if (range3.x < range3.y)
		{
			value.w = EditorGUI.Slider(position, new GUIContent(names[3]), value.w, range3.x, range3.y);
			position.y += position.height + 5;
			++count;
		}
		if (EditorGUI.EndChangeCheck())
		{
			prop.vectorValue = value;
		}
		GUILayout.Space(count * 20 + 10);
	}
}
