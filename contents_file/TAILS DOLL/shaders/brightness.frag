// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

uniform float brightness;
uniform float contrast;
uniform float saturation;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 color = texture( iChannel0, fragCoord/iResolution.xy );
    vec3 gray = vec3( dot( color.rgb, vec3( 0.3086, 0.6094, 0.0820 ) ) );
    vec3 saturated = mix( gray, color.rgb, saturation );

	fragColor = vec4( saturated * contrast + ( ( 1.0 - contrast ) / 2.0 + brightness ) * color.a, color.a );
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}