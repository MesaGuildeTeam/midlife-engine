#version 300 es
precision highp float;

in vec2 v_UV;

uniform sampler2D u_Texture;
uniform sampler2D u_NormalTexture;
uniform sampler2D u_PositionTexture;
uniform sampler2D u_SpecularTexture;

uniform vec4 u_Ambient;
uniform vec4 u_WindowDimensions;
uniform mat4 u_Camera;

layout(location = 0) out vec4 FragColor;

#define SCREEN_WIDTH u_WindowDimensions.x
#define SCREEN_HEIGHT u_WindowDimensions.y

vec3 genNoise(vec2 p) {
    vec3 q = vec3(
            dot(p, vec2(127.1, 311.7)),
            dot(p, vec2(269.5, 183.3)),
            dot(p, vec2(419.2, 371.9))
        );
    return fract(sin(q) * 43758.5453);
}

float computeAO(vec2 uv) {
    vec3 fragPos = texture(u_PositionTexture, uv).xyz;
    if (fragPos.z == 0.0) return 1.0;

    vec3 normal = normalize(texture(u_NormalTexture, uv).xyz);

    // Screen-stable noise, tiled every 4 pixels
    vec3 randomVec = genNoise(floor(uv * u_WindowDimensions.xy) / 4.0);

    vec3 tangent   = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 TBN       = mat3(tangent, bitangent, normal);

    float occlusion = 0.0;
    float radius    = 0.4;
    float bias      = 0.01;
    float sampleCount = 64.;

    for (int i = 0; i < int(sampleCount); i++) { // reduce samples, rely on blur pass
        // Hemisphere sample
        vec3 samp = genNoise(vec2(float(i), float(i * 2)) * 0.1) * vec3(2.0, 2.0, 1.0) - vec3(1.0, 1.0, 0.0);
        samp = TBN * samp;
        // if (dot(samp, normal) < 0.0) samp *= -1.;

        // Weight samples toward origin
        float scale = float(i) / 32.0;
        scale = mix(0.1, 1.0, scale * scale);
        samp *= scale;

        vec3 samplePos = fragPos + samp * radius;

        // Project samplePos to screen UV
        vec4 offset = u_Camera * vec4(samplePos, 1.0);
        float wDiv  = offset.z / 10.0;
        offset.xy   = offset.xy / vec2(160.0, 120.0) * 16.0;
        if (SCREEN_WIDTH > SCREEN_HEIGHT)
            offset.x *= SCREEN_HEIGHT / SCREEN_WIDTH;
        else
            offset.y *= SCREEN_WIDTH / SCREEN_HEIGHT;
        //offset.xy /= wDiv;
        offset.xy  = (offset.xy + 1.0) * 0.5;

        // if (offset.x < 0.0 || offset.x > 1.0 || offset.y < 0.0 || offset.y > 1.0) {
        //   continue;
        // }

        vec3 sampleDepth = texture(u_PositionTexture, offset.xy).xyz;
        if (length(sampleDepth) == 0.0) {
          continue;
        }

        float rangeCheck = smoothstep(0.0, 1.0, radius * length(fragPos.xyz - sampleDepth.xyz));
        // Geometry at sampleDepth occludes when it's closer to camera (smaller z if z is view depth)
        occlusion += (dot(normalize(samp), normalize(normal)) >= bias ? 1.0 : 0.0) * rangeCheck;
        // occlusion += rangeCheck;
    }

    return 1.0 - (occlusion / sampleCount);
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
        if (SCREEN_WIDTH > SCREEN_HEIGHT) {
            offset.x *= SCREEN_HEIGHT / SCREEN_WIDTH;
        } else {
            offset.y *= SCREEN_WIDTH / SCREEN_HEIGHT;
        }

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
    vec4 color = texture(u_Texture, v_UV);
    color.xyz *= occlusion;
    //color.xyz = mix(color.xyz, color.xyz + occlusion - 1.0, 0.2);

    vec3 normal = texture(u_NormalTexture, v_UV).xyz;
    normal = (u_Camera * vec4(normal, 0.0)).xyz;

    float specular = texture(u_SpecularTexture, v_UV).x;

    float F0 = 0.05;
    float fresnel = F0 + (1.0 - F0) * pow(1.0 - max(0.0, dot(normalize(normal), vec3(0.0, 0.0, -1.0))), 3.0);
    color.xyz += computeSSR() * fresnel * specular;

    // gl_FragColor = vec4(specular, specular, specular, 1.0);
    FragColor = vec4(color.rgb, color.a);
}
