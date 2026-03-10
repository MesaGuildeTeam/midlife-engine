#version 330 core

in vec2 v_UV;

uniform sampler2D u_Texture;
uniform sampler2D u_NormalTexture;
uniform sampler2D u_PositionTexture;

uniform mat4 u_Camera;

vec3 genNoise(vec2 p) {
    vec3 q = vec3(
        dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3)),
        dot(p, vec2(419.2, 371.9))
    );
    return fract(sin(q) * 43758.5453);
}

float computeOcclusion(vec2 uv) {
    // SSAO Generation Process
    vec3 fragPos = texture(u_PositionTexture, uv).xyz;
    vec3 normal = texture(u_NormalTexture, uv).xyz;

    // get camera from world to screen space
    vec4 camPos = u_Camera * vec4(0.0, 0.0, 0.0, 1.0);
    vec2 camSeed = vec2(camPos.x, camPos.y);
    camSeed.xy = camSeed.xy / vec2(320.0, 240.0) * 16.0;

    // Create random vector
    vec3 randomVec = genNoise(floor((uv - camSeed) * vec2(320.0, 240.0)) / vec2(320.0, 240.0));
    //randomVec = randomVec * vec3(2.0, 2.0, 0.0) - vec3(1.0, 1.0, 0.0);
    //vec3 randomVec = genNoise(uv);

    vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 TBN = mat3(tangent, bitangent, normal);

    // Generate a quick projection matrix

    float occlusion = 0.0;
    float radius = 0.5;
    float bias = 0.01;
    for (int i = 0; i < 128; i++) {
        vec3 sample = genNoise(vec2(float(i), float(i * 2)) * 0.1) * vec3(2.0, 2.0, 1.0) - vec3(1.0, 1.0, 0.0);
        sample = TBN * sample;
        vec3 samplePos = fragPos + sample * radius;

        vec4 offset = vec4(samplePos, 1.0);
        offset = u_Camera * offset;
        
        // Mapping is successful, but the left side has an unexpected effect
        // TODO: Fix this before merging to main
        //offset.w = offset.z / 10.0;
        offset.z = log(offset.z + 1.0) / log(60.0 + 1.0);
        offset.xy = offset.xy / vec2(160.0, 120.0) * 16.0;
        
        //offset.xy = offset.xy / offset.w;
        offset.xy = offset.xy * 0.5 + 0.5;

        float sampleDepth = texture(u_PositionTexture, offset.xy).z;
        
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        occlusion += (sampleDepth <= samplePos.z + bias ? 1.0 : 0.0) * rangeCheck;
    }

    occlusion = 1.0 - (occlusion / 128.0);

    return occlusion;
}

void main() {
    float occlusion = computeOcclusion(v_UV);

    vec4 color = texture(u_Texture, v_UV);

    gl_FragColor = vec4(color.rgb * vec3(occlusion), 1.0);
}