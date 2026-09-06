#pragma header

uniform float amount;

vec2 PincushionDistortion(in vec2 uv, float strength) {
    vec2 st = uv - 0.5;
    return 0.5 + st * (1.0 - strength * dot(st, st));
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    float r = texture2D(bitmap, PincushionDistortion(uv, 0.3 * amount)).r;
    float g = texture2D(bitmap, PincushionDistortion(uv, 0.15 * amount)).g;
    float b = texture2D(bitmap, PincushionDistortion(uv, 0.075 * amount)).b;
    
    gl_FragColor = vec4(r, g, b, texture2D(bitmap, uv).a);
}