// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

const float Soft = 0.001;
const float Threshold = 0.35;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float f = Soft/2.0;
	float a = Threshold - f;
	float b = Threshold + f;
	
	vec4 tx = texture(iChannel0, fragCoord.xy / iResolution.xy);
	float l = (tx.r + tx.g + tx.b) / 3.0;

	float v = smoothstep(a, b, l);

	fragColor = vec4(vec3(v), tx.a);

}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}