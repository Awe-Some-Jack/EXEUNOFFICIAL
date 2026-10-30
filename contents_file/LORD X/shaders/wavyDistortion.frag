// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float amount;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	float t = iTime * 1.4;
	float k = amount * 0.01;
	
	//uv.y = -1.0 - uv.y;
	
	uv.x += cos(uv.y*5.2+t)*k;
    uv.y += sin(uv.x*5.1+t)*k;
	uv.x -= cos(uv.y*5.2+t)*k;
	uv.x -= cos(uv.x*5.2+t)*k;
	
	fragColor = texture(iChannel0, uv);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}