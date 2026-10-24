#pragma header

uniform float iTime;

#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor

void main()
{
    vec2 uv_coord = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;

    vec2 uv = fragCoord / iResolution.xy;

    vec4 camera = texture(iChannel0, uv);

    vec3 invertedCol = 1.0 - camera.xyz;

    vec3 finalCol = invertedCol * camera.a;

    fragColor = vec4(finalCol, camera.a);
}

// https://www.shadertoy.com/view/dssXRl