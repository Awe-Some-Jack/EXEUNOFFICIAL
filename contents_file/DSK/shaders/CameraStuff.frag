// CameraStuff shader by Kophy232, Remember to credit if use!

#pragma header
#define iResolution openfl_TextureSize
#define iChannel0 bitmap
#define texture flixel_texture2D
uniform float cangle;
uniform float brightness;
uniform float contrast;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    if (cangle != 0.0)
    {
        float angInRad = radians(cangle);
        mat2 rotation = mat2(
            cos(angInRad), -sin(angInRad),
            sin(angInRad),  cos(angInRad)
        );
        uv = rotation * (fragCoord - iResolution.xy * 0.5) / iResolution.xy + 0.5;

        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
        {
            fragColor = vec4(0.0);
            return;
        }
    }

    vec4 tex = texture(iChannel0, uv);
    fragColor = vec4(tex.rgb * (brightness * contrast) + 0.5 - 0.5 * contrast, tex.a);
}

void main()
{
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}
