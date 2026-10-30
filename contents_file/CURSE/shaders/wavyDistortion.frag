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

	float margin = 0.08;
	float falloffX = smoothstep(0.0, margin, uv.x) * (1.0 - smoothstep(1.0 - margin, 1.0, uv.x));
	float falloffY = smoothstep(0.0, margin, uv.y) * (1.0 - smoothstep(1.0 - margin, 1.0, uv.y));
	float falloff = falloffX * falloffY;

	uv.x += cos(uv.y*5.2+iTime*1.4)/50.0*amount*falloff;
    uv.y += sin(uv.x*5.1+iTime*1.4)/50.0*amount*falloff;
	uv.x -= cos(uv.y*5.2+iTime*1.4)/100.0*amount*falloff;
	uv.x -= cos(uv.x*5.1+iTime*1.4)/100.0*amount*falloff;

	fragColor = texture(iChannel0, clamp(uv, 0.0, 1.0));
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}