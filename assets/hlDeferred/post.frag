#version 330 core

in vec2 v_UV;

uniform sampler2D u_Texture;
uniform sampler2D u_NormalTexture;
uniform sampler2D u_PositionTexture;
uniform sampler2D u_SpecularTexture;

uniform vec4 u_Ambient;

uniform mat4 u_Camera;

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 240

vec3 genNoise(vec2 p) {
    vec3 q = vec3(
            dot(p, vec2(127.1, 311.7)),
            dot(p, vec2(269.5, 183.3)),
            dot(p, vec2(419.2, 371.9))
        );
    return fract(sin(q) * 43758.5453);
}

float computeAO(vec2 uv) {
    // SSAO Generation Process
    vec3 fragPos = texture(u_PositionTexture, uv).xyz;
    if (fragPos.z == 0.0) {
        return 1.0;
    }
    vec3 normal = texture(u_NormalTexture, uv).xyz;

    // get camera from world to screen space
    vec4 camPos = u_Camera * vec4(0.0, 0.0, 0.0, 1.0);
    vec2 camSeed = vec2(camPos.x, camPos.y);
    camSeed.xy = camSeed.xy / vec2(SCREEN_WIDTH, SCREEN_HEIGHT) * 16.0;

    // Create random vector
    vec3 randomVec = genNoise(floor((uv - camSeed) * vec2(SCREEN_WIDTH, SCREEN_HEIGHT)) / vec2(SCREEN_WIDTH, SCREEN_HEIGHT));
    //  vec3 randomVec = genNoise(uv);

    vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 TBN = mat3(tangent, bitangent, normal);

    // Generate a quick projection matrix

    float occlusion = 0.0;
    float radius = 0.3;
    float bias = 0.01;
    for (int i = 0; i < 128; i++) {
        vec3 sample = genNoise(vec2(float(i), float(i*2))*0.1)* vec3(2.0, 2.0, 1.0)- vec3(1.0, 1.0, 0.0);
        sample = TBN * sample;
        vec3 samplePos = fragPos + sample * radius;
        
        vec4 offset = vec4(samplePos, 1.0);
        offset = u_Camera * offset;
        
        // Mapping is successful, but the left side has an unexpected effect
        // TODO: Fix this before merging to main
        //offset.w = offset.z / 10.0;
        offset.z = log(offset.z+1.0)/ log(60.0+1.0);
        offset.xy = offset.xy / vec2(160.0, 120.0) * 16.0 ;
        
        //offset.xy = offset.xy / offset.w;
        offset.xy = offset.xy * 0.5 + 0.5 ;
        
        float sampleDepth = texture(u_PositionTexture, offset.xy).z;
        
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        occlusion += ( sampleDepth <= samplePos.z + bias ? 1.0: 0.0 ) * rangeCheck;
    }

    occlusion = 1.0 - ( occlusion / 128.0 ) ;

    return occlusion;
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

vec3 computeSSR() {
    // TODO: Implement SSR
    vec4 normal = texture(u_NormalTexture, v_UV);
    vec4 position = texture(u_PositionTexture, v_UV);

    // vec3 reflectDir = reflect(vec3(0.0, 0.0, 1.0), normalize(normal.xyz));
    vec3 reflectDir = normalize(normal.xyz);
    for (int j = 1; j < 10; j++) {
        vec3 point = position.xyz + reflectDir * 0.05 * vec3(j);
        vec4 offset = vec4(point, 1.0);
        offset = u_Camera * offset;

        // Mapping is successful, but the left side has an unexpected effect
        // TODO: Fix this before merging to main
        //offset.w = offset.z / 10.0;
        offset.xy = offset.xy / vec2(160.0, 120.0) * 16.0;
        offset.xy = offset.xy * 0.5 + 0.5;
        // get new position from texture
        vec4 samplePos = texture(u_PositionTexture, offset.xy); 

        // check if this point is a collision. We will only use one pass
        float distance = length(samplePos.xyz - point.xyz);
        if (distance < 0.1 && distance > 0.001) {
            vec3 hitColor = texture(u_Texture, offset.xy).xyz * computeAO(offset.xy);
            return hitColor;
        }
    }

    return u_Ambient.xyz;
}

void main() {
    vec4 position = texture(u_PositionTexture, v_UV);
    if (position.w == 0.0) {
        discard;
    }

    float occlusion = computeAO(v_UV);
    vec4 color = texture(u_Texture, v_UV) * occlusion;
    
    vec3 normal = texture(u_NormalTexture, v_UV).xyz;
    normal = (u_Camera * vec4(normal, 0.0)).xyz;

    float specular = texture(u_SpecularTexture, v_UV).x;

    float F0 = 0.04;
    float fresnel = F0 + (1.0 - F0) * pow(1.0 - max(0.0, dot(normalize(normal), vec3(0.0, 0.0, -1.0))), 5.0);
    color.xyz += computeSSR() * vec3(fresnel) * specular * 2.0;

    // Apply bloom effect
    color.xyz = desaturate(color.xyz);

    // gl_FragColor = vec4(specular, specular, specular, 1.0);
    gl_FragColor = vec4(color.rgb, color.a);
}
