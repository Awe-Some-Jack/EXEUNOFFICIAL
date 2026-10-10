package minigames.preymini.map;

import flixel.system.FlxAssets.FlxShader;

class LightsShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec3 src0;
		uniform vec3 src1;
		uniform vec3 src2;
		uniform vec3 src3;
		uniform vec3 src4;
		uniform vec3 src5;
		uniform vec3 dst0;
		uniform vec3 dst1;
		uniform vec3 dst2;

		const float CLOSE_SQ = 16.0;

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 c = color.rgb * 255.0;

			vec3 d0 = c - src0; vec3 d3 = c - src3;
			vec3 d1 = c - src1; vec3 d4 = c - src4;
			vec3 d2 = c - src2; vec3 d5 = c - src5;

			if (dot(d0, d0) < CLOSE_SQ || dot(d3, d3) < CLOSE_SQ) color.rgb = dst0 / 255.0;
			else if (dot(d1, d1) < CLOSE_SQ || dot(d4, d4) < CLOSE_SQ) color.rgb = dst1 / 255.0;
			else if (dot(d2, d2) < CLOSE_SQ || dot(d5, d5) < CLOSE_SQ) color.rgb = dst2 / 255.0;

			gl_FragColor = color;
		}
	')
	public function new()
	{
		super();
	}

	public function setSources(bars:Array<Array<Array<Float>>>):Void
	{
		src0.value = bars[0][0];
		src1.value = bars[0][1];
		src2.value = bars[0][2];
		src3.value = bars[1][0];
		src4.value = bars[1][1];
		src5.value = bars[1][2];
	}

	public function setColors(colors:Array<Array<Float>>):Void
	{
		dst0.value = colors[0];
		dst1.value = colors[1];
		dst2.value = colors[2];
	}
}

class ParadeShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec3 haze;
		uniform vec3 rim;
		uniform float rimAlpha;
		uniform float flash;
		uniform vec3 flashColor;

		void main()
		{
			vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
			if (tex.a <= 0.0)
			{
				gl_FragColor = tex;
				return;
			}

			vec3 c = tex.rgb / tex.a;
			float hi = max(c.r, max(c.g, c.b));
			float lo = min(c.r, min(c.g, c.b));
			vec3 result = c;
			if (hi - lo < 0.35 || hi < 0.55)
			{
				vec3 body = haze / 255.0 + vec3(dot(c, vec3(0.3, 0.59, 0.11)) * 0.1);
				vec2 texel = 1.0 / openfl_TextureSize;

				if (flixel_texture2D(bitmap, openfl_TextureCoordv - vec2(0.0, texel.y)).a < 0.1)
					body = mix(body, rim / 255.0, rimAlpha);
				else if (flixel_texture2D(bitmap, openfl_TextureCoordv - vec2(texel.x, 0.0)).a < 0.1)
					body = mix(body, rim / 255.0, rimAlpha * 0.45);

				vec3 lit = min(c * flashColor / 255.0 * 1.7, vec3(1.0));
				result = mix(body, lit, flash);
			}
			gl_FragColor = vec4(result * tex.a, tex.a);
		}
	')
	public function new(haze:Array<Float>, rim:Array<Float>, rimAlpha:Float)
	{
		super();
		this.haze.value = haze;
		this.rim.value = rim;
		this.rimAlpha.value = [rimAlpha];
		flash.value = [0];
		flashColor.value = [216, 108, 180];
	}

	public inline function setFlash(amount:Float):Void
	{
		flash.value = [amount];
	}
}

class ReplaceColorShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform vec3 targetColor;
		uniform vec3 replaceColor;

		const float THRESHOLD_SQ = 0.0025;

		void main()
		{
			vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 targetNorm = targetColor / 255.0;
			vec3 diff = color.rgb - targetNorm;

			if (dot(diff, diff) < THRESHOLD_SQ)
				color.rgb = replaceColor / 255.0;

			gl_FragColor = color;
		}
	')
	public function new()
	{
		super();
		setColors([255, 255, 255], [255, 255, 255]);
	}

	public inline function setTarget(rgb:Array<Float>):Void
	{
		targetColor.value = rgb;
	}

	public inline function setReplace(rgb:Array<Float>):Void
	{
		replaceColor.value = rgb;
	}

	public function setColors(target:Array<Float>, replace:Array<Float>):Void
	{
		setTarget(target);
		setReplace(replace);
	}
}