#pragma header

uniform float amount;

vec2 PincushionDistortion(in vec2 uv, float strength) {
    vec2 st = uv - 0.5;
    return 0.5 + st * (1.0 - strength * dot(st, st));
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    
    float r = flixel_texture2D(bitmap, PincushionDistortion(uv, 0.3 * amount)).r;
    vec2 ga = flixel_texture2D(bitmap, PincushionDistortion(uv, 0.15 * amount)).ga;
    float b = flixel_texture2D(bitmap, PincushionDistortion(uv, 0.075 * amount)).b;
    
    gl_FragColor = vec4(r, ga.x, b, ga.y);
}