// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

uniform float amount;
uniform float angle;

// end of ShadertoyToFlixel header

#define TWO_PI 6.283185307179586

vec2 rotate2D(vec2 position, float theta)
{
    float c = cos(theta);
    float s = sin(theta);

    return mat2(c, -s, s, c) * position;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec2 p = uv;

    vec2 off = texture(iChannel0, uv).rg - 0.5;

    off = rotate2D(off, angle * TWO_PI);

    p += off * amount * 0.15;

    p = clamp(p, 0.0, 1.0);

    fragColor = texture(iChannel0, p);
}

void main()
{
    mainImage(
        gl_FragColor,
        openfl_TextureCoordv * openfl_TextureSize
    );
}