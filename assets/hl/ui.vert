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
    vec4 position = vec4(a_Position, 1.0);
    position = u_Transform * position;
    position.xy *= vec2(16.0, 16.0) / vec2(320.0, 240.0);
    position.xy += vec2(-1.0, 1.0) - vec2(0.0, 16.0/240.0);
    gl_Position = position;

    v_UV = a_UV;
}