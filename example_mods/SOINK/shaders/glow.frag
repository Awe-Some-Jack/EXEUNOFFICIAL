#pragma header

uniform float glowSize;
uniform float glowIntensity;
uniform vec3 glowColor;

vec4 unmultiply(vec4 c) {
    if(c.a > 0.0) c.rgb /= c.a;
    return c;
}

void main() {
    vec4 color = unmultiply(flixel_texture2D(bitmap, openfl_TextureCoordv));
    vec2 size = openfl_TextureSize;

    float totalAlpha = 0.0;
    float maxSamples = 0.0;

    for (float x = -20.0; x <= 20.0; x += 2.0) {
        if(abs(x) > glowSize) continue;

        for (float y = -20.0; y <= 20.0; y += 2.0) {
            if(abs(y) > glowSize) continue;

            float dist = length(vec2(x, y));
            if(dist > glowSize) continue;

            vec2 offset = vec2(x, y) / size;
            vec2 sampleUV = openfl_TextureCoordv + offset;

            if(sampleUV.x < 0.0 || sampleUV.x > 1.0 || sampleUV.y < 0.0 || sampleUV.y > 1.0) continue;

            vec4 s = unmultiply(flixel_texture2D(bitmap, sampleUV));
            float weight = 1.0 - (dist / glowSize);
            totalAlpha += s.a * weight;
            maxSamples += weight;
        }
    }

    float glowAlpha = 0.0;
    if(maxSamples > 0.0) {
        glowAlpha = clamp((totalAlpha / maxSamples) * glowIntensity, 0.0, 1.0);
    }

    glowAlpha *= (1.0 - color.a);

    vec3 finalRGB = mix(glowColor * glowAlpha, color.rgb * color.a, color.a);
    float finalA = mix(glowAlpha, color.a, color.a);

    gl_FragColor = vec4(finalRGB, finalA);
}