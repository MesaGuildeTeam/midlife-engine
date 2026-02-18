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

/**
 * Computes the light distribution relative to the object
 *
 * @param lightPos the position of the light relative to the object
 * @param strength the light strength
 * @param color the RGB of the light
 */
vec3 computeBRDF(vec3 lightPos, vec4 color) {
    float distance = length(lightPos);
    float lightOnObj = color.w / (distance * distance);
    vec3 halfway = normalize(vec3(0.0, 0.0, -1.0) + lightPos); 
    float kd = 1.0;
    float ks = 2.0;

    vec3 diffuse = lightOnObj 
        * max(dot(normalize(v_Normal), normalize(lightPos)), 0.0) * color.xyz;
    vec3 specular = ks * lightOnObj 
        * max(0.0, pow(dot(halfway, normalize(v_Normal)), 10.0 * ks)) * vec3(1.0); 
    vec3 fresnel = ks * lightOnObj
        * pow(1.0 - max(0.0, dot(normalize(v_Normal), vec3(0.0, 0.0, 1.0))), 3.0) * vec3(1.0);

    // Option 1: Just Diffuse and Specular
    //return kd * diffuse + specular;
    // Option 2: Replace Specular with fresnel
    //return (kd + 2.0 * fresnel) * diffuse;
    // Option 3: Combine Fresnel with Diffuse
    return (kd + 3.0 * fresnel) * diffuse + specular;
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
    vec4 color_diffuse = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 color_diffuse2 = vec4(0.0);

    if (u_usesTexture[0] == 1)
        color_diffuse = texture2D(u_Diffuse, v_UV);

    // colorMix is the combination of the base diffuse, but the second diffuse layer is mapped on top
    vec4 colorMix = mix(color_diffuse, color_diffuse2, color_diffuse2.a);
    if (colorMix.a < 0.01)
        discard;

    // Point Lights 
    vec3 lighting = vec3(0.0);
    for (int i = 0; i < u_LightCount; i++) {
        if (u_LightPos[i].w >= 1.0) {
            lighting += computeBRDF(v_Position - u_LightPos[i].xyz, 
                u_LightColor[i]);
                continue;
        }
        lighting += computeBRDF(-u_LightPos[i].xyz, u_LightColor[i]);
    }

    // add more color depth by making brighter values than 1 whiter
    vec3 color_out = desaturate(colorMix.xyz * (u_Ambient.xyz + lighting));

    gl_FragColor = vec4(color_out, colorMix.a);
}