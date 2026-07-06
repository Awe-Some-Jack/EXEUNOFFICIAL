#pragma header

uniform float hue;
uniform float saturation;
uniform float brightness;
uniform float contrast;

const vec3 grayscaleValues = vec3(
    0.3098039215686275,
    0.607843137254902,
    0.0823529411764706
);

const float e = 2.718281828459045;

vec3 applyHueRotate(vec3 color, float value)
{
    float angle = radians(value);

    mat3 m1 = mat3(
        0.213, 0.213, 0.213,
        0.715, 0.715, 0.715,
        0.072, 0.072, 0.072
    );

    mat3 m2 = mat3(
        0.787, -0.213, -0.213,
        -0.715, 0.285, -0.715,
        -0.072, -0.072, 0.928
    );

    mat3 m3 = mat3(
        -0.213, 0.143, -0.787,
        -0.715, 0.140, 0.715,
        0.928, -0.283, 0.072
    );

    return (m1 + cos(angle) * m2 + sin(angle) * m3) * color;
}

vec3 applySaturation(vec3 color, float value)
{
    if (value > 0.0)
        value *= 3.0;

    value = 1.0 + (value / 100.0);

    vec3 gray = vec3(dot(color, grayscaleValues));

    return clamp(mix(gray, color, value), 0.0, 1.0);
}

vec3 applyContrast(vec3 color, float value)
{
    value = 1.0 + (value / 100.0);

    if (value > 1.0)
    {
        value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0;
        value += 1.0;
    }

    return clamp((color - 0.25) * value + 0.25, 0.0, 1.0);
}

void main()
{
    vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

    vec3 color = tex.rgb;

    color += brightness / 255.0;
    color = applyHueRotate(color, hue);
    color = applyContrast(color, contrast);
    color = applySaturation(color, saturation);

    gl_FragColor = vec4(clamp(color, 0.0, 1.0), tex.a);
}