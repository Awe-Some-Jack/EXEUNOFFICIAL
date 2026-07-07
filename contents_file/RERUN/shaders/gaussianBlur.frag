#pragma header

uniform float distort;
uniform float iTime;

uniform float Directions;
uniform float Quality;

void main()
{
    if (distort == 0.0)
    {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
        return;
    }

    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    vec2 uv = fragCoord.xy / iResolution.xy;
    float Pi = 6.28318530718;
    
    float Size1 = distort * 0.75;
    
    vec2 Radius = Size1 / iResolution.xy;
    vec4 Color = flixel_texture2D(bitmap, uv);
    
    float totalWeight = 1.0;
    for (float d = 0.0; d < Pi; d += Pi / Directions)
    {
        for (float i = 1.0 / Quality; i <= 1.0; i += 1.0 / Quality)
        {
            vec4 sampleColor = flixel_texture2D(bitmap, uv + vec2(cos(d), sin(d)) * Radius * i);
            Color += sampleColor;
            totalWeight += 1.0;
        }
    }
    
    Color /= totalWeight;
    gl_FragColor = Color;
}