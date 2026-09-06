#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float amount;
#define texture flixel_texture2D

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float A = amount * 0.01;
    float T = iTime * 1.4;
    
    uv.x += cos(uv.y * 5.2 + T) * A;
    uv.y += sin(uv.x * 5.1 + T) * A;
    uv.x -= cos(uv.y * 5.2 + T) * A;
    uv.x -= cos(uv.x * 5.2 + T) * A;
    
    fragColor = texture(bitmap, uv);
}

void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}