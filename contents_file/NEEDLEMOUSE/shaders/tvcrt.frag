// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define texture flixel_texture2D
#define iResolution openfl_TextureSize
uniform float iTime;
#define iChannel0 bitmap

vec2 curve(vec2 uv)
{
    uv = (uv - 0.5) * 2.0;
    uv *= 1.1;  
    
    vec2 abs_uv = abs(uv);
    float powX = (abs_uv.x / 4.0);
    float powY = (abs_uv.y / 5.0);
    
    uv.x *= 1.0 + (powY * powY);
    uv.y *= 1.0 + (powX * powX);
    uv = (uv / 2.0) + 0.5;
    return uv * 0.92 + 0.04;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = curve(uv);
    
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    vec3 col;
    // Chromatic
    col.r = texture(iChannel0, vec2(uv.x + 0.003, uv.y)).r;
    col.g = texture(iChannel0, vec2(uv.x,         uv.y)).g;
    col.b = texture(iChannel0, vec2(uv.x - 0.003, uv.y)).b;

    col *= 0.5 + 8.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    col *= vec3(0.95, 1.05, 0.95);

    // Scanlines
    col *= 0.9 + 0.1 * sin(10.0 * iTime + uv.y * 700.0);
    col *= 0.99 + 0.01 * sin(110.0 * iTime);

    fragColor = vec4(col, texture(iChannel0, uv).a);
}

void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}