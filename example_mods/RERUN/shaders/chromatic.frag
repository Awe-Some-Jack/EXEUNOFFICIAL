// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

uniform float amount;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec4 color;
    color.r = texture(iChannel0, uv - (amount / 100.0)).r;
    color.g = texture(iChannel0, uv).g;
    color.b = texture(iChannel0, uv + (amount / 100.0)).b;
    color.a = texture(iChannel0, uv).a;

    // Output to screen
    fragColor = color;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}