#pragma header
uniform float iTime;
uniform float GLITCH;
#define texture flixel_texture2D

const float HALF_WEIGHT = 0.72974;

float sat(float t) { return clamp(t, 0.0, 1.0); }

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 sampleAt(vec2 uv, float offset) {
    return texture(bitmap, vec2(sat(uv.x + offset), uv.y));
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    float time = mod(iTime * 10.0, 3.2);

    float gnm = sat(GLITCH);
    float r0 = sat((1.0 - gnm) * 0.7 + rand(floor(vec2(time) * 6.0) / 6.0));

    float rnd1 = rand(vec2(floor(uv.x * 10.0 * r0) / (10.0 * r0), time));
    float r1 = 0.0001 - 0.5 * gnm + rnd1;

    float r2 = sat(rand(vec2(floor(uv.y * 40.0 * r1) / (40.0 * r1), time)));
    float r3 = 0.9 - sat(rand(vec2(floor(uv.y * 2.0 * r0) / (2.0 * r0), time)) + 0.8);

    float ofs = 0.05 * r2 * GLITCH;
    ofs += 0.5 * rand(uv + time) * ofs;
    uv.y += 0.4 * r3 * GLITCH;

    vec4 s0 = sampleAt(uv, 0.0);
    vec4 s1 = sampleAt(uv, ofs * 0.1666667);
    vec4 s2 = sampleAt(uv, ofs * 0.3333334);
    vec4 s3 = sampleAt(uv, ofs * 0.5000001);
    vec4 s4 = sampleAt(uv, ofs * 0.6666668);
    vec4 s5 = sampleAt(uv, ofs * 0.8333335);

    vec3 color = vec3(
        (s0.r + s1.r + HALF_WEIGHT * s2.r) / (2.0 + HALF_WEIGHT),
        (HALF_WEIGHT * s2.g + s3.g + HALF_WEIGHT * s4.g) / (1.0 + 2.0 * HALF_WEIGHT),
        (HALF_WEIGHT * s4.b + s5.b) / (1.0 + HALF_WEIGHT)
    );

    gl_FragColor = vec4(color, (s0.a + s1.a + s2.a + s3.a + s4.a + s5.a) * 0.1666667);
}
