using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Fur_Inspector : ShaderGUI
{
	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	{
		MaterialProperty shapeTex = FindProperty("_ShapeTex", properties);
		MaterialProperty normalScale_FurOffset_FurLength = FindProperty("_NormalScale_FurOffset_FurLength", properties);

		MaterialProperty albedo = FindProperty("_Albedo", properties);
		MaterialProperty diffuseColor = FindProperty("_DiffuseColor", properties);
		MaterialProperty specularColor = FindProperty("_SpecularColor", properties);
		MaterialProperty normal = FindProperty("_NormalMap", properties);

		MaterialProperty ambient = FindProperty("_AmbientTex", properties);
		MaterialProperty ambientColor = FindProperty("_AmbientColor", properties);

		MaterialProperty shiftTex = FindProperty("_ShiftTex", properties);
		MaterialProperty shifts_specularWidths = FindProperty("_Shifts_SpecularWidths", properties);
		MaterialProperty exponents = FindProperty("_Exponents_SpecStrengths", properties);
		MaterialProperty specularColor1 = FindProperty("_SpecColor1", properties);
		MaterialProperty specularColor2 = FindProperty("_SpecColor2", properties);

		//MaterialProperty point_light_color = FindProperty("_PointLightColor", properties);
		//MaterialProperty point_light_pos = FindProperty("_PointLightPos", properties);

		GUILayout.Label(new GUIContent("FurShape"));
		EditorGUI.indentLevel += 2;
		materialEditor.TexturePropertySingleLine(new GUIContent("BaseShape(R) FurShape(G)"), shapeTex);
		materialEditor.TextureScaleOffsetProperty(shapeTex);
		materialEditor.ShaderProperty(normalScale_FurOffset_FurLength, new GUIContent("NormalScale_FurOffset_FurLength"));
		EditorGUI.indentLevel -= 2;

		GUILayout.Label(new GUIContent("MainTex"));
		EditorGUI.indentLevel += 2;
		materialEditor.TexturePropertySingleLine(new GUIContent("Albedo"), albedo, diffuseColor);
		materialEditor.ColorProperty(specularColor, "Specular Color");
		materialEditor.TexturePropertySingleLine(new GUIContent("NormalMap"), normal);
		materialEditor.ShaderProperty(FindProperty("_KdKsExpoure", properties), "KdKsExpoure");
		materialEditor.TextureScaleOffsetProperty(albedo);
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		GUILayout.Label(new GUIContent("AmbientTex"));
		EditorGUI.indentLevel += 2;
		materialEditor.TexturePropertySingleLine(new GUIContent("Ambient"), ambient, ambientColor);
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		GUILayout.Label(new GUIContent("Aniso Specular"));
		EditorGUI.indentLevel += 2;
		materialEditor.TexturePropertySingleLine(new GUIContent("Shift Texture"), shiftTex);
		materialEditor.TextureScaleOffsetProperty(shiftTex);
		materialEditor.ShaderProperty(shifts_specularWidths, "Shifts_SpecularWidth");
		materialEditor.ShaderProperty(exponents, "Exponents_SpecStrengths");
		materialEditor.ShaderProperty(specularColor1, new GUIContent("SpecularColor1"));
		materialEditor.ShaderProperty(specularColor2, new GUIContent("SpecularColor2"));
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		GUILayout.Label(new GUIContent("Custome Point Light"));
		EditorGUI.indentLevel += 2;
		//materialEditor.ShaderProperty(point_light_color, new GUIContent("Point Light Color"));
		//materialEditor.ShaderProperty(point_light_pos, new GUIContent("Point Light Position"));
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		materialEditor.RenderQueueField();
	}
}
