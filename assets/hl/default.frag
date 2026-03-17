/**
 * The default fragment shader for rendering objects in a scene.
 *
 * Inspired by the Blinn-Phong reflection model, this shader uses a lambertian
 * wrap to simulate rougher surfaces, and a fresnel term to add more depth to
 * the specular highlights.
 *
 * The shader currently supports up to 32 point lights. Each light position is
 * a vec4 where w is used to determine if the light is directional (w = 0) or
 * point (w = 1). The light color uses the alpha channel as the strength of the light.
 *
 * @author Roberto Selles
 */

#version 330 core

// Varying Variables from Mesh
in vec3 v_Position;
in vec2 v_UV;
in vec3 v_Normal;
in vec3 v_CameraDir;
in vec3 v_ScreenNormal;

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
uniform vec4 u_MaterialParams;

layout(location = 0) out vec4 gColor;
layout(location = 1) out vec4 gNormal;
layout(location = 2) out vec4 gPosition;
layout(location = 3) out vec4 gSpecular;

#define kd 1.0
#define ks 1.0
#define lh 0.5

/**
 * Computes the diffuse lighting for a given light source
 *
 * If there is a specular component, we will add the fresnel term during this
 * step to take advantage of the diffuse lighting being calculated.
 *
 * @param lightPos the position of the light relative to the object
 * @param color the RGB of the light
 */
vec3 computeDiffuse(vec3 lightPos, vec4 color, vec3 surface) {
    float distance = length(lightPos);
    float lightOnObj = color.w / (distance * distance);
    vec3 halfway = normalize(v_CameraDir + lightPos);

    // Lambert
    float lambert = dot(normalize(v_Normal), normalize(lightPos));

    // Lambertian Wrap. Comment first line below if regular lambert is preferred
    lambert = mix((lambert + lh) / (1.0 + lh), lambert, clamp(ks, 0.0, 1.0));
    lambert = max(lambert, 0.0);

    vec3 diffuse = lightOnObj
            * lambert * color.xyz;
    vec3 fresnel = u_MaterialParams.x * lightOnObj
            * pow(1.0 - max(0.0, dot(normalize(v_ScreenNormal), normalize(v_CameraDir))), 5.0) * color.xyz;

    vec3 result = kd * diffuse * surface;
    // Enable Fresnel
    //result += (fresnel * 0.5 * length(diffuse + u_Ambient.xyz));

    return result;
}

vec3 computeSpecular(vec3 lightPos, vec4 color) {
    float distance = length(lightPos);
    float lightOnObj = color.w / (distance * distance);
    vec3 halfway = normalize(v_CameraDir + lightPos);

    // Specular with fresnel
    vec3 specular = u_MaterialParams.x * lightOnObj
            * max(0.0, pow(dot(halfway, normalize(v_Normal)), 50.0)) * color.xyz;

    return specular;
}

/*
 * Takes an RGB color and desaturates it based on the strongest value
 *
 * @param input the color to whiten if bright enough
 */
vec3 desaturate(vec3 color) {
    float extra = max(max(color.x, color.y), color.z) - 1.0;
    return color + max(extra, 0.0);
}

void main() {

    // Textures
    vec4 color_diffuse = u_DiffuseColor;
    vec4 color_diffuse2 = vec4(0.0);

    if (u_usesTexture[0] == 1)
        color_diffuse = texture(u_Diffuse, v_UV);

    // colorMix is the combination of the base diffuse, but the second diffuse layer is mapped on top
    vec4 colorMix = mix(color_diffuse, color_diffuse2, color_diffuse2.a);
    if (colorMix.a < 0.01)
        discard;

    // Point Lights
    vec3 lighting = vec3(0.0);
    for (int i = 0; i < u_LightCount; i++) {
        vec3 lightPos = u_LightPos[i].xyz;
        if (u_LightPos[i].w >= 1.0) {
            lightPos -= v_Position;
        }
        lighting += computeDiffuse(lightPos, u_LightColor[i], colorMix.xyz);
        lighting += computeSpecular(lightPos, u_LightColor[i]);
    }

    // add more color depth by making brighter values than 1 whiter
    //vec3 color_out = desaturate(colorMix.xyz * u_Ambient.xyz + lighting);
    vec3 color_out = colorMix.xyz * u_Ambient.xyz + lighting;

    gColor = vec4(color_out, colorMix.a);
    gNormal = vec4(v_Normal, 1.0);
    gPosition = vec4(v_Position, 1.0);
    gSpecular = vec4(u_MaterialParams.x, 0.0, 0.0, 1.0);
}
