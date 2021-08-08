#ifndef TRANSFORM_LIBRARY_INCLUDE
#define TRANSFORM_LIBRARY_INCLUDE

#include "UnityStandardUtils.cginc"

half3 GetTangentSpaceViewDir(half4 tangent, half3 normal, half4 vertex)
{
    half3 binormal = cross(tangent.xyz, normal) * tangent.w;
    float3x3 objToTanMat = float3x3( tangent.xyz, binormal, normal);
    return mul(objToTanMat, ObjSpaceViewDir(vertex));
}

half2 GetParallxOffset(half height, half3 view_tangent, half ParallxScale)
{
    return view_tangent.xy / view_tangent.z * height * ParallxScale;
}

half3 GetNormalWorldFromMap(v2f i, half4 normalMap, half normalScale)
{
    i.tangent_world = normalize(i.tangent_world);
    i.normal_world = normalize(i.normal_world);
    i.binormal_world = normalize(i.binormal_world);
    half3 normal_tangent = UnpackScaleNormal(normalMap, normalScale);
    half3 n = normalize(
        normal_tangent.x * i.tangent_world +
        normal_tangent.y * i.binormal_world +
        normal_tangent.z * i.normal_world
    );
    return  n;
}

half3 GetBlendNormalWorldFromMap(v2f i, half4 mainNormalMap, half4 detilNormalMap, half mainNormalScale, half detilNormalScale, fixed mask)
{
    i.tangent_world = normalize(i.tangent_world);
    i.normal_world = normalize(i.normal_world);
    i.binormal_world = normalize(i.binormal_world);
    half3 mainNor = UnpackScaleNormal(mainNormalMap, mainNormalScale);
    half3 detilNor = UnpackScaleNormal(detilNormalMap, detilNormalScale);
    half3 normal_tangent = lerp(mainNor, BlendNormals(mainNor, detilNor), mask);
    half3 n = normalize(
        normal_tangent.x * i.tangent_world +
        normal_tangent.y * i.binormal_world +
        normal_tangent.z * i.normal_world
    );
    return  n;
}

#endif