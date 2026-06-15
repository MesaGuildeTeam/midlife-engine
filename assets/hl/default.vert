#version 300 es

precision mediump float;

in vec3 a_Position;
in vec2 a_UV;
in vec3 a_Normal;

uniform mat4 u_Transform;
uniform mat4 u_Camera;
uniform vec4 u_WindowDimensions;

out vec3 v_Position;
out vec2 v_UV;
out vec3 v_Normal;
out vec3 v_ScreenNormal;
out vec3 v_CameraDir;
out vec3 v_CameraPos;

void main() {
    float pixPerUnit = 16.0;
    float unitZ = 10.0;

    vec4 position = u_Transform * vec4(a_Position, 1.0);
    v_Position = (position).xyz;

    vec4 screen_pos = u_Camera * u_Transform * vec4(a_Position, 1.0);

    v_CameraDir = normalize((u_Camera * vec4(0.0, 0.0, 1.0, 0.0)).xyz);
    //v_CameraDir = normalize(u_Camera[2].xyz);

    gl_Position = screen_pos;

    // perspective distance correction and adding depth
    gl_Position.w = screen_pos.z / (unitZ);
    gl_Position.z = -log(screen_pos.z + 1.0) / log(60.0 + 1.0);

    // Correct width to game screen ratio and add screen space
    gl_Position.xy = gl_Position.xy / vec2(160.0, 120.0) * (pixPerUnit);

    if (u_WindowDimensions.x > u_WindowDimensions.y) {
        gl_Position.x *= u_WindowDimensions.y / u_WindowDimensions.x;
    } else {
        gl_Position.y *= u_WindowDimensions.x / u_WindowDimensions.y;
    }

    v_Normal = (u_Transform * vec4(a_Normal, 0.0)).xyz;
    v_ScreenNormal = (inverse(u_Camera) * u_Transform * vec4(a_Normal, 0.0)).xyz;
    v_UV = a_UV;
}
