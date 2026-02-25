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

//precision mediump float;

// Varying Variables from Mesh
varying vec3 v_Position;
varying vec2 v_UV;
varying vec3 v_Normal;
varying vec3 v_CameraDir;

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
 * @param color the RGB of the light
 */
vec3 computeBRDF(vec3 lightPos, vec4 color) {
    float distance = length(lightPos);
    float lightOnObj = color.w / (distance * distance);
    vec3 halfway = normalize(v_CameraDir + lightPos); 
    float kd = 1.0;
    float ks = 1.0;
    float lh = 0.5;

    // Lambert
    float lambert = dot(normalize(v_Normal), normalize(lightPos));

    // Lambertian Wrap. Comment first line below if regular lambert is preferred 
    //lambert = mix((lambert + lh) / (1.0 + lh), lambert, clamp(ks, 0.0, 1.0));
    lambert = max(lambert, 0.0);

    vec3 diffuse = lightOnObj 
        * lambert * color.xyz;

    // Specular with fresnel
    vec3 specular = ks * lightOnObj 
        * max(0.0, pow(dot(halfway, normalize(v_Normal)), 20.0)) * color.xyz; 
    vec3 fresnel = ks * lightOnObj
        * pow(1.0 - max(0.0, dot(normalize(v_Normal), v_CameraDir)), 3.0) * color.xyz;

    vec3 result = kd * diffuse;
    // Enable Specular
    result += specular;
    // Enable Fresnel
    result += (3.0 * fresnel * length(diffuse + u_Ambient.xyz));
    
    return result;
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
    vec4 color_diffuse = vec4(1.0);
    vec4 color_diffuse2 = vec4(0.0);

    if (u_usesTexture[0] == 1)
        color_diffuse = texture2D(u_Diffuse, v_UV);

    color_diffuse *= u_DiffuseColor;

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