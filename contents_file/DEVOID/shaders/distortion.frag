#pragma header //fuck you ai im sorry

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

#define PI 3.14159

uniform float xPos;
uniform float yPos;
uniform float size;
uniform float amount;
uniform float iTime;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float effectRadius = size;
    float effectAngle = amount * PI;

    vec2 center = vec2(xPos, yPos) / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy - center;

    float len = length(
        uv * vec2(iResolution.x / iResolution.y, 1.)
    );

    float power = pow(
        smoothstep(effectRadius, 0., len),
        200.
    );

    float angle = atan(uv.y, uv.x) + effectAngle * power;
    float radius = length(uv);

    float theta = angle;

    float variation = sin(theta * 37.0) * 0.5 + 0.5;

   float movement = iTime * 15.0;

    float lines = smoothstep(
        0.98,
        1.0,
        sin(
            theta * (14.0 + variation * 7.0)
            + radius * 5.0
            + movement
        )
    );

    float lineArea = smoothstep(
        effectRadius,
        effectRadius * 0.05,
        len
    );

    lines *= lineArea;
    lines *= smoothstep(0.1, 0.15, radius);
    lines *= amount;

    radius -= lines * 0.02;

    vec4 color = texture(
        iChannel0,
        vec2(
            radius * cos(angle),
            radius * sin(angle)
        ) + center
    );

    color.rgb = mix(
        color.rgb,
        vec3(1.0),
        lines
    );

    fragColor = color;
}

void main()
{
    mainImage(
        gl_FragColor,
        openfl_TextureCoordv * openfl_TextureSize
    );
}