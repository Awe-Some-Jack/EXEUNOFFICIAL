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
        vec2 pixelCoord = fragCoord;
        vec2 center = iResolution.xy * 0.5;
        vec2 centered = pixelCoord - center;
        vec2 normalized = centered / iResolution.y;
        float angInRad = radians(cangle);
        mat2 rotation = mat2(
            cos(angInRad), -sin(angInRad),
            sin(angInRad),  cos(angInRad)
        );
        normalized = rotation * normalized;
        vec2 finalCoord = normalized * iResolution.y + center;
        uv = finalCoord / iResolution.xy;
    }

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
    {
        fragColor = vec4(0.0);
    }
    else
    {
        vec4 tex = texture(iChannel0, uv);
        vec3 finalColor = tex.rgb * brightness;
        finalColor = mix(vec3(0.5), finalColor, contrast);
        fragColor = vec4(finalColor, tex.a);
    }
}

void main()
{
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}
