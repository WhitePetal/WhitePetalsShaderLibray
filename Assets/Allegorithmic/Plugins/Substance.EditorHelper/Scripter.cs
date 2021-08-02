
using System;
using UnityEditor;
using UnityEngine;
using System.Runtime.InteropServices;

using System.IO;
using System.Reflection;
using System.Collections.Generic;

namespace Substance.EditorHelper
{
    public class Scripter
    {
        public static void Hello()
        {
            Debug.Log("Scripter's Hello");

#if UNITY_2019_3_OR_NEWER
            Debug.Log("UNITY_2019_3_OR_NEWER");
#endif
        }

        public static class UnityPipeline
        {
            // The active project context is in the 'Edit->Project Settings->Graphics->Scriptable Render Pipeline Settings' field.
            public static bool IsHDRP()
            {
#if UNITY_2019_3_OR_NEWER
            bool bActive = false;

            UnityEngine.Rendering.RenderPipelineAsset asset;
            asset = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset;

            if ((asset != null) &&
                (asset.GetType().ToString().EndsWith(".HDRenderPipelineAsset")))
            {
                    bActive = true;
            }

            return bActive;
#else
                return false;
#endif
            }

            public static bool IsURP()
            {
#if UNITY_2019_3_OR_NEWER
                bool bActive = false;

                UnityEngine.Rendering.RenderPipelineAsset asset;
                asset = UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset;

                if ((asset != null) &&
                    (asset.GetType().ToString().EndsWith("UniversalRenderPipelineAsset")))
                {
                    bActive = true;
                }

                return bActive;
#else
                return false;
#endif
            }

            // Keep the following for PackageManager investigation:
            /*
            public static UnityEditor.PackageManager.PackageInfo GetPackageInfo(string pName)
            {
#if UNITY_2019_3_OR_NEWER
                Debug.Log("New stuff...");

                UnityEditor.PackageManager.PackageInfo info;

                info = UnityEditor.PackageManager.PackageInfo.FindForAssetPath(pName);

                return info;
#else
                Debug.Log("Old stuff...");
                return null;
#endif
            }
            */
        }

        // =================================================================================
        // SendTo: launch launcher:
        [DllImport("substance_portal_cli", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern uint substance_portal_cli_invoke();

        // ---------------------------------------------------------------------------------
        // The following 'Shader' functions are only used for Unity2019.3 & up.
        // (so, for compilation purposes, with pre-Unity2019.3 APIs: we have to implement a dummy version of each)

#if UNITY_2019_3_OR_NEWER
        public enum ShaderPropertyType
        {
            Color = UnityEngine.Rendering.ShaderPropertyType.Color,
            Float = UnityEngine.Rendering.ShaderPropertyType.Float
        }
#else
        public enum ShaderPropertyType
        {
            Invalid = -1,
            Color = -2,
            Float = -3
        }
#endif

#if UNITY_2019_3_OR_NEWER
        public static int GetPropertyCount(Shader pShader)
        {
            return pShader.GetPropertyCount();
        }
#else
        public static int GetPropertyCount(Shader pShader)
        {
            Debug.LogWarning(string.Format("Unexpected Shader function call: '{0}'!",
                System.Reflection.MethodBase.GetCurrentMethod().Name));
            return 0;
        }
#endif

#if UNITY_2019_3_OR_NEWER
        public static string GetPropertyName(Shader pShader, int pIndex)
        {
            return pShader.GetPropertyName(pIndex);
        }
#else
        public static string GetPropertyName(Shader pShader, int pIndex)
        {
            Debug.LogWarning(string.Format("Unexpected Shader function call: '{0}'!",
                System.Reflection.MethodBase.GetCurrentMethod().Name));
            return string.Empty;
        }
#endif

#if UNITY_2019_3_OR_NEWER
        public static ShaderPropertyType GetPropertyType(Shader pShader, int pIndex)
        {
            return (ShaderPropertyType)pShader.GetPropertyType(pIndex);
        }
#else
        public static ShaderPropertyType GetPropertyType(Shader pShader, int pIndex)
        {
            Debug.LogWarning(string.Format("Unexpected Shader function call: '{0}'!",
                System.Reflection.MethodBase.GetCurrentMethod().Name));
            return ShaderPropertyType.Invalid;
        }
#endif

#if UNITY_2019_3_OR_NEWER
        public static float GetPropertyDefaultFloatValue(Shader pShader, int pIndex)
        {
            return pShader.GetPropertyDefaultFloatValue(pIndex);
        }
#else
        public static float GetPropertyDefaultFloatValue(Shader pShader, int pIndex)
        {
            Debug.LogWarning(string.Format("Unexpected Shader function call: '{0}'!",
                System.Reflection.MethodBase.GetCurrentMethod().Name));
            return 0;
        }
#endif

#if UNITY_2019_3_OR_NEWER
        public static Color GetPropertyDefaultVectorValue(Shader pShader, int pIndex)
        {
            return pShader.GetPropertyDefaultVectorValue(pIndex);
        }
#else
        public static Color GetPropertyDefaultVectorValue(Shader pShader, int pIndex)
        {
            Debug.LogWarning(string.Format("Unexpected Shader function call: '{0}'!",
                System.Reflection.MethodBase.GetCurrentMethod().Name));
            return new Color(0,0,0,0);
        }
#endif

    }
}