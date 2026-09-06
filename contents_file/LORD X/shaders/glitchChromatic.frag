#pragma header
uniform float iTime;
uniform float GLITCH;
#define texture flixel_texture2D

float sat(float t) { return clamp(t, 0.0, 1.0); }
float remap(float t, float a, float b) { return sat((t - a) / (b - a)); }
float linterp(float t) { return sat(1.0 - abs(2.0 * t - 1.0)); }

vec3 spectrum_offset(float t) {
    float lo = step(t, 0.5);
    float w = linterp(remap(t, 0.1666667, 0.8333333));
    vec3 ret = vec3(lo, 1.0, 1.0 - lo) * vec3(1.0 - w, w, 1.0 - w);
    return pow(ret, vec3(0.454545));
}

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453);
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
    
    vec4 sum = vec4(0.0);
    vec3 wsum = vec3(0.0);
    const float RCP = 0.1666667; 
    
    for (int i = 0; i < 6; ++i) {
        float t = float(i) * RCP;
        vec4 samplecol = texture(bitmap, vec2(sat(uv.x + ofs * t), uv.y));
        vec3 s = spectrum_offset(t);
        samplecol.rgb *= s;
        sum += samplecol;
        wsum += s;
    }
    
    gl_FragColor = vec4(sum.rgb / wsum, sum.a * RCP);
}