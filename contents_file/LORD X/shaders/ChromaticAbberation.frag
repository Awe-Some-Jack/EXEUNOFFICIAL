#pragma header

uniform float amount;

void main()
{
    vec2 st = openfl_TextureCoordv - 0.5;
    float pull = amount * dot(st, st);

    gl_FragColor = vec4(
        flixel_texture2D(bitmap, 0.5 + st * (1.0 - 0.3 * pull)).r,
        flixel_texture2D(bitmap, 0.5 + st * (1.0 - 0.15 * pull)).g,
        flixel_texture2D(bitmap, 0.5 + st * (1.0 - 0.075 * pull)).b,
        1.0
    );
}
