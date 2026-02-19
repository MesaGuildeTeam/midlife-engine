precision mediump float;

attribute vec3 a_Position;
attribute vec2 a_UV;
attribute vec3 a_Normal;

uniform mat4 u_Transform;

varying vec3 v_Position;
varying vec2 v_UV;
varying vec3 v_Normal;

void main() {
    float pixPerUnit = 16.0;
    float unitZ = 10.0;

    vec4 position = u_Transform * vec4(a_Position, 1.0);
    v_Position = position.xyz;
    //vec4 position = vec4(a_Position, 1.0);

    gl_Position = position;

    // perspective distance correction and adding depth
    gl_Position.w = position.z / (unitZ);
    gl_Position.z = log(position.z + 1.0) / log(60.0 + 1.0) * 2.0 - 1.0;
    //gl_Position.z = gl_Position.z / 60.0;

    // Correct width to game screen ratio and add screen space
    gl_Position.xy = gl_Position.xy / vec2(160.0, 120.0) * (pixPerUnit);

    v_Normal = (u_Transform * vec4(a_Normal, 0.0)).xyz;
    v_UV = a_UV;
}