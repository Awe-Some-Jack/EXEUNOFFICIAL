package minigames.preymini.map;

import minigames.preymini.map.Shader;

class MapLights
{
	static final BARS:Array<Array<Array<Float>>> = [
		[[119, 255, 255], [85, 221, 221], [51, 187, 187]],
		[[150, 217, 250], [63, 245, 172], [4, 179, 108]],
	];

	static final CYCLE:Array<Array<Array<Float>>> = [
		[[206, 138, 140], [197, 56, 57], [76, 0, 0]],
		[[76, 0, 0], [206, 138, 140], [195, 54, 0]],
		[[197, 56, 57], [76, 0, 0], [206, 138, 140]],
	];

	public final shader = new LightsShader();

	var _time:Float = 0;
	var _step:Int = -1;

	public function new()
	{
		shader.setSources(BARS);
		update(0);
	}

	public function update(elapsed:Float):Void
	{
		_time += elapsed;
		final step = Std.int(_time / (5 / 60)) % CYCLE.length;
		if (step == _step) return;
		_step = step;
		shader.setColors(CYCLE[step]);
	}
}
