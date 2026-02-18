//precision mediump float;

// Varying Variables from Mesh
varying vec3 v_Position;
varying vec2 v_UV;
varying vec3 v_Normal;

// Light Uniforms
uniform vec4 u_Ambient;

uniform vec4 u_LightPos[32];
uniform vec4 u_LightColor[32];
uniform int u_LightCount;

// Textures and Material
uniform sampler2D u_Diffuse;
uniform sampler2D u_Diffuse2;

uniform int u_usesTexture[2];

uniform vec4 u_DiffuseColor;

void main() {
    gl_FragColor = vec4(1.0);
    
    if (u_usesTexture[0] == 1)
        gl_FragColor = texture2D(u_Diffuse, v_UV);
}