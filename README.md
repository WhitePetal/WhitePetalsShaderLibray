

## 版本计划


1、brdf、bsrdf、bssdf 添加 烘焙光 支持


2、用于远景等低层次物体的兰伯特简易Shader
3、fur shader 添加重力、风力影响


## PBR_BRDF_LUT
| 功能 | 支持 |
| --- | --- |
| forward add | √ |
| 阴影 | √ |
| 烘焙光 | × |
| 自带点光源 | √ |

![image.png](https://cdn.nlark.com/yuque/0/2021/png/12427755/1628400523909-37363e18-4527-4093-a631-cc6aeca5510b.png#clientId=u9b250518-99ec-4&from=paste&height=297&id=u3f9e66fb&margin=%5Bobject%20Object%5D&name=image.png&originHeight=593&originWidth=717&originalType=binary&ratio=1&size=315333&status=done&style=none&taskId=u338515ec-6aac-4ac3-bf95-185832f7eb9&width=358.5)
## PBR_BSRDF_KK_LUT
| 功能 | 支持 |
| --- | --- |
| forward add | √ |
| 阴影 | √ |
| 烘焙光 | × |
| 自带点光源 | √ |

![image.png](https://cdn.nlark.com/yuque/0/2021/png/12427755/1628400861541-10a4e9e1-9a85-4952-b377-61d5d0aa6e9a.png#clientId=u9b250518-99ec-4&from=paste&height=354&id=u09fc9e6c&margin=%5Bobject%20Object%5D&name=image.png&originHeight=708&originWidth=751&originalType=binary&ratio=1&size=742718&status=done&style=none&taskId=u95b35b4d-f052-41b3-8a02-c777590dfa5&width=375.5)
## PBR_BSSSDF_LUT
| 功能 | 支持 |
| --- | --- |
| forward add | √ |
| 阴影 | √ |
| 烘焙光 | × |
| 自带点光源 | √ |

![image.png](https://cdn.nlark.com/yuque/0/2021/png/12427755/1628401116411-0f01f690-0473-4ce1-869a-388aa6864994.png#clientId=u9b250518-99ec-4&from=paste&height=387&id=uf28a5878&margin=%5Bobject%20Object%5D&name=image.png&originHeight=773&originWidth=623&originalType=binary&ratio=1&size=304650&status=done&style=none&taskId=ud437b760-5f4d-4966-8233-b500ae2527e&width=311.5)
# 
## Fur Shader
| 功能 | 支持 |
| --- | --- |
| forward add | 性能考虑，暂不添加 |
| 阴影 | × |
| 烘焙光 | × |
| 自带点光源 | × |
| 重力影响 | × |
| 风力影响 | × |

![image.png](https://cdn.nlark.com/yuque/0/2021/png/12427755/1628401580083-ccc510cc-f6e5-4db8-9717-c7be3ac22439.png#clientId=u9b250518-99ec-4&from=paste&height=307&id=uf9ea8100&margin=%5Bobject%20Object%5D&name=image.png&originHeight=613&originWidth=666&originalType=binary&ratio=1&size=270968&status=done&style=none&taskId=u98a472b6-1ed9-4fd0-a8c8-336d21090a9&width=333)
