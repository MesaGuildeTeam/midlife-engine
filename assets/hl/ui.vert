precision mediump float;

attribute vec3 a_Position;
attribute vec2 a_UV;
attribute vec3 a_Normal;

uniform mat4 u_Transform;
uniform vec2 u_Ambient;

varying vec3 v_Position;
varying vec2 v_UV;
varying vec3 v_Normal;

void main() {
    vec4 position = u_Transform * vec4(a_Position.xy, 1.0, 1.0);
    position.xy = (position.xy / vec2(320.0, 240.0)) * 2.0 + vec2(-1.0, 1.0);
    gl_Position = vec4(position.xy, a_Position.z, 1.0);

    v_UV = a_UV;
}