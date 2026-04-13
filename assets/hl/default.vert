precision mediump float;

attribute vec3 a_Position;
attribute vec2 a_UV;
attribute vec3 a_Normal;

uniform mat4 u_Transform;
uniform mat4 u_Camera;

varying vec3 v_Position;
varying vec2 v_UV;
varying vec3 v_Normal;
varying vec3 v_CameraDir;

void main() {
    float pixPerUnit = 16.0;
    float unitZ = 10.0;

    vec4 position = u_Transform * vec4(a_Position, 1.0);
    v_Position = position.xyz;
    v_CameraDir = normalize((u_Camera * vec4(0.0, 0.0, 1.0, 0.0)).xyz + vec3(v_Position.xy / v_Position.z, 0.0));

    vec4 screen_pos = u_Camera * position;
    gl_Position = screen_pos;

    // perspective distance correction and adding depth
    gl_Position.w = screen_pos.z / (unitZ);
    gl_Position.z = log(screen_pos.z + 1.0) / log(60.0 + 1.0) * 2.0 - 1.0;

    // Correct width to game screen ratio and add screen space
    gl_Position.xy = gl_Position.xy / vec2(160.0, 120.0) * (pixPerUnit);

    v_Normal = (u_Transform * vec4(a_Normal, 0.0)).xyz;
    v_UV = a_UV;
}