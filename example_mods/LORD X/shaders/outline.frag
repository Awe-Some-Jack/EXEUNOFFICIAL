#pragma header

uniform float thickness;
uniform vec4 outlineColor;

void main()
{
    vec4 col = texture2D(bitmap, openfl_TextureCoordv);

    float gradient = mix(0.5, 1.0, openfl_TextureCoordv.y);

    if (col.a > 0.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, col.a);
        return;
    }

    vec2 px = 1.0 / openfl_TextureSize;
    float t = thickness;
    float maxDist = t * t;
    float total = 0.0;
    float weight = 0.0;

    for (int x = -5; x <= 5; x++) {
        for (int y = -5; y <= 5; y++) {
            float fx = float(x);
            float fy = float(y);
            float dist2 = fx * fx + fy * fy;
            if (dist2 > maxDist) continue;
            float a = texture2D(bitmap, openfl_TextureCoordv + vec2(fx, fy) * px).a;
            float w = exp(-dist2 / (t * t * 0.5));
            total += a * w;
            weight += w;
        }
    }

    float alpha = weight > 0.0 ? clamp(total / weight, 0.0, 1.0) : 0.0;

    if (alpha > 0.01) {
        float soft = smoothstep(0.0, 0.5, alpha);
        vec3 outCol = outlineColor.rgb * gradient;
        gl_FragColor = vec4(outCol, outlineColor.a * soft);
    } else {
        gl_FragColor = vec4(0.0);
    }
}
