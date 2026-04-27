## Overview

Midlife Engine comes included with all the shaders needed to develop Games. However, it is completely understandable to want to write your own shaders. [[Billiard Tactics]] is using a modified Vertex shader to use an isometric environment. 


> [!warning] 
> It is a good idea to learn how to program shaders in GLSL before proceeding. This resource assumes you know how to code in GLSL. If not LearnOpenGL is a good source to learn from as the engine is based on the OpenGL from that web tutorial.

This document goes over all the parameters when writing shaders. When writing shaders for Midlife Engine, it is recommended to use minimum `#version 330 core`. The reason for this is to have access to multiple buffers when outputting your render. The engine offers both a deferred/forward hybrid renderer and a forward renderer. This means some uniforms are only available for for the post-processing shader, and some uniforms are only available for the object rendering process. The good news is that the hybrid renderer wraps around the forward renderer making all mesh shaders compatible with both pipelines.

## Mesh Attribute Parameters

These parameters are fed to the shader by the mesh being rendered. In this case, there are only three:

| Name         | Type | Description                           |
| ------------ | ---- | ------------------------------------- |
| `a_Position` | vec3 | The vertex Position                   |
| `a_UV`       | vec2 | The texture UV assigned to the vertex |
| `a_Normal`   | vec3 | The vertex normal assigned            |



## Buffer Output Parameters

These are organized by layout locations using the format `layout(location = i) out vec4 gName;` where `i` is the buffer index and `gName` is a buffer name (although naming is optional, we recommend naming our shader outputs as documented)

These parameters are mainly used to forward to post-processing. The only one you need to write to is `gColor` (and if you wish to use only the forwarding pipeline, `gl_FragCoord` is also valid). Otherwise, all parameters are vec4.

| Index | Name        | Description                                       |
| ----- | ----------- | ------------------------------------------------- |
| 0     | `gColor`    | The output albedo at the screen pixel             |
| 1     | `gNormal`   | The normal identified at the screen pixel         |
| 2     | `gPosition` | The world position identified at the screen pixel |
| 3     | `gSpecular` | The specular strength at the following position   |

## Shader Uniforms

These are general parameters defined by either the render instruction or the scene. These are usable in both the mesh and post processing shaders, but it is recommended to follow this documentation on when to use each of them

### Scene Uniform Parameters

These parameters are safe to use when writing a post-processing shader for the pipeline.

| Name           | Type   | Description                                                                                                                                                                |
| -------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `u_Ambient`    | vec4   | The environment's natural environment color                                                                                                                                |
| `u_LightPos`   | vec4[] | An array of light positions. Although configurable per environment, the standard is If `u_LightPos[i].w >= 1.0` it is a directional light. Otherwise, it is a point light. |
| `u_LightColor` | vec4[] | An array of light colors associated with their `u_LightPos`. `u_LightColor[i].w` is assigned as the light's brightness                                                     |
| `u_LightCount` | int    | The number of lights active in the scene                                                                                                                                   |
| `u_Camera`     | mat4   | The camera transformation applied to the object                                                                                                                            |

### Mesh-Only Uniform Parameters

These parameters are suggested to **ONLY** be used when drawing a mesh. They are potentially accessible by the post-processing shaders, but will only be based on one object's 

| Name                     | Type | Description                                                                                                            |
| ------------------------ | ---- | ---------------------------------------------------------------------------------------------------------------------- |
| `u_Transform`            | mat4 | The object's transformation matrix in the scene                                                                        |
| `u_usesTexture(_,2,3,4)` | int  | A parameter that identifies if a certain texture slot is being used in the scene (Diffuse, Diffuse2, Specular, Normal) |
| `u_DiffuseColor`         | vec4 | the RGBA color used to multiply the *first* diffuse texture with                                                       |
| `u_MaterialParams`       | vec4 | A vector of constants `shininess, TBA, TBA, TBA`                                                                       |
## Textures

The textures are positioned by layout. There is a maximum of 4 textures being used at once in both mesh drawing and the buffer drawing process.

| Layout Index | Mesh         | Buffer   |
| ------------ | ------------ | -------- |
| 0            | Diffuse #1   | Diffuse  |
| 1            | Diffuse #2   | Normals  |
| 2            | Specular Map | Position |
| 3            | Normal Map   | Specular |
