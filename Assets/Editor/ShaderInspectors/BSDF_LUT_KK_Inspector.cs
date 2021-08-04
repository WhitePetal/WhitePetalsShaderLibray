using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class BSDF_LUT_KK_Inspector : ShaderGUI
{
	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	{
		//base.OnGUI(materialEditor, properties);
		MaterialProperty lut = FindProperty("_LUT", properties);
		MaterialProperty albedo = FindProperty("_Albedo", properties);
		MaterialProperty diffuseColor = FindProperty("_DiffuseColor", properties);
		MaterialProperty specularColor = FindProperty("_SpecularColor", properties);
		MaterialProperty normal = FindProperty("_NormalTex", properties);
		MaterialProperty parallx = FindProperty("_ParallxTex", properties);
		MaterialProperty mra = FindProperty("_MRATex", properties);
		MaterialProperty fresnel = FindProperty("_Fresnel", properties);

		MaterialProperty detil = FindProperty("_DetilTex", properties);
		MaterialProperty detilColor = FindProperty("_DetilColor", properties);
		MaterialProperty detilNormal = FindProperty("_DetilNormalTex", properties);

		MaterialProperty ambient = FindProperty("_AmbientTex", properties);
		MaterialProperty ambientColor = FindProperty("_AmbientColor", properties);

		MaterialProperty shiftTex = FindProperty("_ShiftTex", properties);
		MaterialProperty shifts_specularWidths = FindProperty("_Shifts_SpecularWidths", properties);
		MaterialProperty exponents = FindProperty("_Exponents", properties);
		MaterialProperty specularColor1 = FindProperty("_SpecColor1", properties);
		MaterialProperty specularColor2 = FindProperty("_SpecColor2", properties);

		materialEditor.TexturePropertySingleLine(new GUIContent("LUT"), lut);
		GUILayout.Label(new GUIContent("MainTex"));
		EditorGUI.indentLevel += 2;
		materialEditor.TexturePropertySingleLine(new GUIContent("Albedo"), albedo, diffuseColor);
		materialEditor.ColorProperty(specularColor, "Specular Color");
		materialEditor.TexturePropertySingleLine(new GUIContent("NormalMap"), normal);
		materialEditor.ShaderProperty(FindProperty("_KdKsExpoureParalxScale", properties), "KdKsExpoureParalxScale");
		materialEditor.TexturePropertySingleLine(new GUIContent("HeightMap"), parallx);
		materialEditor.TexturePropertySingleLine(new GUIContent("Metallic(R) Roughness(G)\nAO(B)"), mra);
		materialEditor.ColorProperty(fresnel, "Fresnel0");
		materialEditor.ShaderProperty(FindProperty("_MetallicRoughnessAO", properties), "_MetallicRoughnessAO");
		materialEditor.TextureScaleOffsetProperty(albedo);
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		GUILayout.Label(new GUIContent("DetilTex"));
		EditorGUI.indentLevel += 2;
		materialEditor.TexturePropertySingleLine(new GUIContent("Detil"), detil, detilColor);
		materialEditor.TexturePropertySingleLine(new GUIContent("DetilNormal"), detilNormal);
		materialEditor.TextureScaleOffsetProperty(detil);
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		GUILayout.Label(new GUIContent("NormalScales"));
		EditorGUI.indentLevel += 2;
		materialEditor.ShaderProperty(FindProperty("_NormalScales", properties), "_NormalScales");
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
		materialEditor.ShaderProperty(exponents, "Exponents");
		materialEditor.ShaderProperty(specularColor1, new GUIContent("SpecularColor1"));
		materialEditor.ShaderProperty(specularColor2, new GUIContent("SpecularColor2"));
		EditorGUI.indentLevel -= 2;

		GUILayout.Space(20);
		materialEditor.RenderQueueField();
	}
}
