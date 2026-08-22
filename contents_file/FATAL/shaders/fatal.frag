#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float brightint;

#define iChannel0 bitmap
#define texture flixel_texture2D

#define iter 40.0
#define scaleSpeed 3.0
#define satSpeed 4.2
#define PI 3.14159265359

float N2(vec2 p)
{
    vec3 p3 = fract(
        vec3(p.xyx) *
        vec3(443.897, 441.423, 437.195)
    );

    p3 += dot(
        p3,
        p3.yzx + 19.19
    );

    return fract(
        (p3.x + p3.y) *
        p3.z
    );
}

float readPixel(float row, float x)
{
    float bit = 4.0 - x;

    return floor(
        mod(
            row / pow(2.0, bit),
            2.0
        )
    );
}

float rowF(float y)
{
    if (y < 1.0) return 31.0;
    if (y < 2.0) return 16.0;
    if (y < 3.0) return 16.0;
    if (y < 4.0) return 30.0;
    if (y < 5.0) return 16.0;
    if (y < 6.0) return 16.0;

    return 16.0;
}

float rowA(float y)
{
    if (y < 1.0) return 14.0;
    if (y < 2.0) return 17.0;
    if (y < 3.0) return 17.0;
    if (y < 4.0) return 31.0;
    if (y < 5.0) return 17.0;
    if (y < 6.0) return 17.0;

    return 17.0;
}

float rowT(float y)
{
    if (y < 1.0) return 31.0;

    return 4.0;
}

float rowL(float y)
{
    if (y < 6.0)
        return 16.0;

    return 31.0;
}

float pixelLetter(
    vec2 p,
    float character
)
{
    if (
        p.x < -0.5 ||
        p.x >  0.5 ||
        p.y < -0.5 ||
        p.y >  0.5
    )
        return 0.0;

    float x = floor(
        (p.x + 0.5) *
        5.0
    );

    float y = floor(
        (0.5 - p.y) *
        7.0
    );

    x = clamp(
        x,
        0.0,
        4.0
    );

    y = clamp(
        y,
        0.0,
        6.0
    );

    float row;

    if (character < 1.0)
    {
        row = rowF(y);
    }
    else if (character < 2.0)
    {
        row = rowA(y);
    }
    else if (character < 3.0)
    {
        row = rowT(y);
    }
    else if (character < 4.0)
    {
        row = rowA(y);
    }
    else
    {
        row = rowL(y);
    }

    return readPixel(
        row,
        x
    );
}

void mainImage(
    out vec4 fragColor,
    in vec2 fragCoord
)
{
    fragCoord.y =
        iResolution.y -
        fragCoord.y;

    vec2 uv =
        (
            fragCoord -
            0.5 *
            iResolution.xy
        )
        /
        iResolution.y;

    uv *= iter;

    vec2 gv =
        fract(uv) -
        0.5;

    vec2 id =
        floor(uv);

    float ran =
        N2(id);

    float ran2 =
        N2(
            id +
            64.0
        );

    float cellSpeed =
        mix(
            0.25,
            1.0,
            ran
        );

    float phase =
        iTime *
        scaleSpeed *
        cellSpeed;

    float cycle =
        floor(
            phase /
            PI
        );

    float letterRandom =
        N2(
            id +
            vec2(
                cycle * 17.37,
                cycle * 31.91
            )
        );

    float character =
        floor(
            letterRandom *
            5.0
        );

    float size =
        abs(
            sin(phase)
        ) *
        0.5 -
        0.05;

    size =
        max(
            size,
            0.0
        );

    float normalizedSize =
        size /
        0.45;

    normalizedSize =
        max(
            normalizedSize,
            0.001
        );

    vec2 letterUV =
        gv /
        normalizedSize;

    letterUV.x *= 1.15;

    float letter =
        pixelLetter(
            letterUV,
            character
        );

    float bounds =
        step(
            max(
                abs(gv.x),
                abs(gv.y)
            ),
            size
        );

    letter *= bounds;

    float brightness =
        abs(
            sin(
                iTime *
                satSpeed *
                ran2
            )
        ) *
        0.8;

    vec3 col =
        vec3(letter) *
        brightness;

    col *= vec3(
        1.0 * brightint,
        0.0,
        0.0
    );

    vec2 textureUV =
        vec2(
            fragCoord.x,
            iResolution.y - fragCoord.y
        )
        /
        iResolution.xy;

    fragColor =
        vec4(
            col,
            texture(
                iChannel0,
                textureUV
            ).a
        );
}

void main()
{
    mainImage(
        gl_FragColor,
        openfl_TextureCoordv *
        openfl_TextureSize
    );
}