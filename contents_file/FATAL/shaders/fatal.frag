#pragma header

uniform float iTime;
uniform float brightint;

#define iter 40.0
#define scaleSpeed 3.0
#define satSpeed 4.2
#define PI 3.14159265359

float N2(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx) * vec3(443.897, 441.423, 437.195));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float letterRow(float character, float y)
{
    if (character < 1.0)
    {
        if (y < 1.0) return 31.0;
        if (y < 3.0) return 16.0;
        if (y < 4.0) return 30.0;
        return 16.0;
    }
    if (character < 2.0 || (character >= 3.0 && character < 4.0))
    {
        if (y < 1.0) return 14.0;
        if (y < 3.0) return 17.0;
        if (y < 4.0) return 31.0;
        return 17.0;
    }
    if (character < 3.0)
    {
        return y < 1.0 ? 31.0 : 4.0;
    }
    return y < 6.0 ? 16.0 : 31.0;
}

float pixelLetter(vec2 p, float character)
{
    if (p.x < -0.5 || p.x > 0.5 || p.y < -0.5 || p.y > 0.5)
        return 0.0;

    float x = clamp(floor((p.x + 0.5) * 5.0), 0.0, 4.0);
    float y = clamp(floor((0.5 - p.y) * 7.0), 0.0, 6.0);

    return floor(mod(letterRow(character, y) / exp2(4.0 - x), 2.0));
}

void main()
{
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    float alpha = flixel_texture2D(bitmap, openfl_TextureCoordv).a;

    fragCoord.y = openfl_TextureSize.y - fragCoord.y;

    vec2 uv = (fragCoord - 0.5 * openfl_TextureSize) / openfl_TextureSize.y;
    uv *= iter;

    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);

    float ran = N2(id);
    float phase = iTime * scaleSpeed * mix(0.25, 1.0, ran);
    float size = max(abs(sin(phase)) * 0.5 - 0.05, 0.0);

    if (max(abs(gv.x), abs(gv.y)) > size)
    {
        gl_FragColor = vec4(0.0, 0.0, 0.0, alpha);
        return;
    }

    float cycle = floor(phase / PI);
    float character = floor(N2(id + vec2(cycle * 17.37, cycle * 31.91)) * 5.0);

    vec2 letterUV = gv / max(size / 0.45, 0.001);
    letterUV.x *= 1.15;

    float letter = pixelLetter(letterUV, character);
    float brightness = abs(sin(iTime * satSpeed * N2(id + 64.0))) * 0.8;

    gl_FragColor = vec4(letter * brightness * brightint, 0.0, 0.0, alpha);
}
