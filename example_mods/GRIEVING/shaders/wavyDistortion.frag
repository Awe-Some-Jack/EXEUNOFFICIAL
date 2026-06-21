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
	
	//uv.y = -1.0 - uv.y;
	
	uv.x += cos(uv.y*5.2+iTime*1.4)/100.0*amount;
    uv.y += sin(uv.x*5.1+iTime*1.4)/100.0*amount;
	uv.x -= cos(uv.y*5.2+iTime*1.4)/100.0*amount;
	uv.x -= cos(uv.x*5.2+iTime*1.4)/100.0*amount;
	
	vec4 color = texture(iChannel0, uv);
	
	fragColor = color;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}