using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Texture3DGenerater : MonoBehaviour
{
    public Collider mesh;
    public Texture3D tex3D;

    // Start is called before the first frame update
    void Start()
    {
        tex3D = new Texture3D(128, 128, 128, TextureFormat.ARGB32, false);
        for(int x = 0; x < 128; ++x)
		{
            for(int y = 0; y < 128; ++y)
			{
                for(int z = 0; z < 128; ++z)
				{
                    Vector3 pos = new Vector3(x / 120f, y / 128f, z / 128f);
                    Vector3 closePos = mesh.ClosestPoint(pos);
                    float dst = Vector3.Distance(pos, closePos);
                    Color col = new Color(0.0f, 0.0f, 0.0f, 0.0f);
                    if (dst < 0.01f) col = Color.white;
                    tex3D.SetPixel(x, y, z, col);
				}
			}
		}
        tex3D.Apply();
        AssetDatabase.CreateAsset(tex3D, "Assets/Tex3D.asset");
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
