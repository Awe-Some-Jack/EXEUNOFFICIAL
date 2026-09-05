#pragma header

uniform float distort;
uniform float Directions;
uniform float Quality;

void main() {
    if (distort == 0.0) {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        return;
    }

    vec2 uv = openfl_TextureCoordv;
    vec2 Radius = (distort * 0.75) / openfl_TextureSize;
    vec4 Color = flixel_texture2D(bitmap, uv);
    
    float totalWeight = 1.0;
    float qStep = 1.0 / Quality;
    float dStep = 6.28318530718 / Directions;
    
    for (float d = 0.0; d < 6.28318530718; d += dStep) {
        vec2 dir = vec2(cos(d), sin(d)) * Radius;
        for (float i = qStep; i <= 1.0; i += qStep) {
            Color += flixel_texture2D(bitmap, uv + dir * i);
            totalWeight += 1.0;
        }
    }
    
    gl_FragColor = Color / totalWeight;
}