// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

uniform float amount;
uniform float angle;

#define TWO_PI 6.283185307179586

void main()
{
    vec2 uv = openfl_TextureCoordv;

    if (amount == 0.0)
    {
        gl_FragColor = flixel_texture2D(bitmap, clamp(uv, 0.0, 1.0));
        return;
    }

    float theta = angle * TWO_PI;
    float c = cos(theta);
    float s = sin(theta);
    vec2 off = mat2(c, -s, s, c) * (flixel_texture2D(bitmap, uv).rg - 0.5);

    gl_FragColor = flixel_texture2D(bitmap, clamp(uv + off * amount * 0.15, 0.0, 1.0));
}
