package shaders;

import flixel.system.FlxAssets.FlxShader;

class PincushionShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float uAmount;
		uniform float uZoom;

		void main()
		{
			vec2 cc = openfl_TextureCoordv - 0.5;
			float d2 = dot(cc, cc);            // squared distance from center: 0 at center, ~0.5 at the corners
			cc *= (1.0 - uAmount * d2);        // uAmount > 0 -> magnification grows toward the edges = pincushion
			cc /= uZoom;
			vec2 uv = cc + 0.5;

			gl_FragColor = flixel_texture2D(bitmap, uv);
		}
	')

	public function new()
	{
		super();
		uAmount.value = [0.28];
		uZoom.value = [1.0];
	}
}
