// Shader by Owk06
// Edited by Raimbowcore12

#pragma header

uniform float iTime;
uniform float sort;

const float maskLow = 0.6 - 0.7;
const float maskHigh = 0.6 + 0.7;

void main()
{
    vec2 uv = (openfl_TextureCoordv * openfl_TextureSize) / openfl_TextureSize;
    vec4 tex = flixel_texture2D(bitmap, uv);

    if (sort <= 0.0 || iTime < 0.0)
    {
        gl_FragColor = tex;
        return;
    }

    float blackMix = smoothstep(1.5, 2.5, sort);
    if (blackMix >= 1.0)
    {
        gl_FragColor = vec4(0.0);
        return;
    }

    float mask = smoothstep(maskLow, maskHigh, (tex.r + tex.g + tex.b) / 3.0);
    float turbulence = fract(sin(dot(vec2(uv.x), vec2(12.9, 78.2))) * 437.5);
    vec2 transitionUV = vec2(uv.x, uv.y + pow(sort, 2.0 + (sort * 2.0)) * mask * turbulence);
    vec2 sortUV = vec2(uv.x, 1.0 - clamp(sort / 2.6, 0.0, 1.0));

    vec4 result = flixel_texture2D(bitmap, transitionUV.y > 1.0 ? sortUV : transitionUV);
    gl_FragColor = mix(result, vec4(0.0), blackMix);
}
