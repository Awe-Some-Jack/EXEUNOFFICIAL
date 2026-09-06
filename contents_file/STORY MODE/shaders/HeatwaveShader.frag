#pragma header

uniform float iTime;
uniform sampler2D distortTexture;

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec2 map_uv = vec2(uv.x, fract(uv.y - iTime * 0.05));
    
    vec2 offset = flixel_texture2D(distortTexture, map_uv).xy;
    offset = (offset - 0.5) * (0.018 * pow(uv.y, 1.4));
    
    gl_FragColor = flixel_texture2D(bitmap, uv + offset); 
}