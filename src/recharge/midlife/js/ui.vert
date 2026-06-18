precision mediump float;

attribute vec3 a_Position;
attribute vec2 a_UV;
attribute vec3 a_Normal;

uniform mat4 u_Transform;
uniform vec4 u_WindowDimensions;

varying vec3 v_Position;
varying vec2 v_UV;
varying vec3 v_Normal;

void main() {
    vec2 dimensions = u_WindowDimensions.xy;
    float scale = 16.0;
    
    vec4 position = vec4(a_Position, 1.0);

    // Apply transform
    
    position = u_Transform * position;
    
    // Scale to UI coordinates (16x16 grid)
    position.xy *= vec2(scale) / dimensions;
    
    // Apply correction for higher resolutions

    position.xy += vec2(-1.0, 1.0) - vec2(0.0, scale/dimensions.y);
    gl_Position = position;

    v_UV = a_UV;
}