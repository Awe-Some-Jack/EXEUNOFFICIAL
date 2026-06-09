package shaders;

import flixel.system.FlxAssets.FlxShader;

class CirclesShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float u_radius1;
		uniform float u_radius2;
		uniform float u_thickness;
		uniform vec2 u_resolution;

		// 0x4a0008 = rgb(74, 0, 8)
		const vec4 color1 = vec4(74.0/255.0, 0.0, 8.0/255.0, 1.0);
		// 0x3b060c = rgb(59, 6, 12)
		const vec4 color2 = vec4(59.0/255.0, 6.0/255.0, 12.0/255.0, 1.0);

		void main()
		{
			vec2 pixelCoord = openfl_TextureCoordv.xy * u_resolution;
			vec2 center = u_resolution * 0.5;
			
			float d = distance(pixelCoord, center);
			
			float r1_outer = u_radius1;
			float r1_inner = u_radius1 - u_thickness;
			float alpha1 = smoothstep(r1_outer + 1.0, r1_outer - 1.0, d) - smoothstep(r1_inner + 1.0, r1_inner - 1.0, d);
			
			float r2_outer = u_radius2;
			float r2_inner = u_radius2 - u_thickness;
			float alpha2 = smoothstep(r2_outer + 1.0, r2_outer - 1.0, d) - smoothstep(r2_inner + 1.0, r2_inner - 1.0, d);
			
			vec4 finalColor = vec4(0.0);
			
			finalColor = mix(finalColor, color1, max(0.0, alpha1));
			finalColor = mix(finalColor, color2, max(0.0, alpha2));
			
			gl_FragColor = finalColor;
		}
	')
	public function new()
	{
		super();
		u_radius1.value = [0.0];
		u_radius2.value = [0.0];
		u_thickness.value = [22.0];
		u_resolution.value = [1280.0, 720.0];
	}
}