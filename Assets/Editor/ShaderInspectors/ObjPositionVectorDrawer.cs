using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ObjPositionVectorDrawer : MaterialPropertyDrawer
{
	private MaterialProperty m_prop;
	private bool drawSceneGUI = false;
	private bool startDraw = true;

	//public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
	//{
	//	return EditorGUI.GetPropertyHeight(SerializedPropertyType.Vector3, new GUIContent(label));
	//}

	public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
	{
		EditorGUI.BeginChangeCheck();
		Vector4 vecValue = prop.vectorValue;
		prop.vectorValue = new Vector4(Mathf.Min(3.0f, vecValue.x), Mathf.Min(3.0f, vecValue.y), Mathf.Min(3.0f, vecValue.z), 1.0f);
		drawSceneGUI = GUILayout.Toggle(drawSceneGUI, new GUIContent("Draw Position Handle"));
		if (drawSceneGUI)
		{
			if (startDraw)
			{
				m_prop = prop;
				RegisterSceneGUI();
			}
		}
		else
		{
			if (!startDraw) RemoveSceneGUI();
		}
		Vector4 pos = prop.vectorValue;
		pos = EditorGUI.Vector3Field(position, label, pos);
		if (EditorGUI.EndChangeCheck())
		{
			prop.vectorValue = pos;
		}
	}

	private void RegisterSceneGUI()
	{
		SceneView.duringSceneGui += OnSceneGUI;
		startDraw = false;
	}

	private void RemoveSceneGUI()
	{
		SceneView.duringSceneGui -= OnSceneGUI;
		startDraw = true;
		m_prop = null;
	}

	private void OnSceneGUI(SceneView sceneView)
	{
		GameObject selectObj = Selection.activeGameObject;
		if (selectObj == null)
		{
			RemoveSceneGUI();
			return;
		}
		Transform curObj = selectObj.transform;
		while (curObj.parent != null) curObj = curObj.parent;
		Vector4 vecValue = m_prop.vectorValue;
		Vector3 pos_world = Handles.PositionHandle(curObj.TransformPoint(vecValue), Quaternion.identity);
		m_prop.vectorValue = curObj.InverseTransformPoint(pos_world);
		Handles.color = Color.yellow;
		Handles.SphereHandleCap(0, pos_world, Quaternion.identity, .2f, EventType.Repaint);
	}
}
