#pragma header

uniform float amount;

#define texture flixel_texture2D

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / openfl_TextureSize;
    float offset = amount * 0.01;
    
    vec4 center = texture(bitmap, uv);
    float r = texture(bitmap, uv - offset).r;
    float b = texture(bitmap, uv + offset).b;
    
    fragColor = vec4(r, center.g, b, center.a);
}
void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}