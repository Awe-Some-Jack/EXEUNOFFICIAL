// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define texture flixel_texture2D
#define iResolution openfl_TextureSize
uniform float iTime;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;

#define SPEED 2.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float c = cos(iTime*SPEED);
	float s = sin(iTime*SPEED);
	
	mat4 hueRotation =	
					mat4( 	 0.299,  0.587,  0.114, 0.0,
					    	 0.299,  0.587,  0.114, 0.0,
					    	 0.299,  0.587,  0.114, 0.0,
					   		 0.000,  0.000,  0.000, 1.0) +
		
					mat4(	 0.701, -0.587, -0.114, 0.0,
							-0.299,  0.413, -0.114, 0.0,
							-0.300, -0.588,  0.886, 0.0,
						 	 0.000,  0.000,  0.000, 0.0) * c +
		
					mat4(	 0.168,  0.330, -0.497, 0.0,
							-0.328,  0.035,  0.292, 0.0,
							 1.250, -1.050, -0.203, 0.0,
							 0.000,  0.000,  0.000, 0.0) * s;
	
	vec4 pixel = texture(iChannel0, uv);

	fragColor = pixel * hueRotation;

}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}