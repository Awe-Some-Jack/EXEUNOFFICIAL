package minigames.thevalley.tiles;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import openfl.display.BitmapData;

class TotemDread
{
	final _vignette:FlxSprite;
	final _baseScale:Float;

	var _level:Float = 0;
	var _pulse:Float = 0;
	var _beatTimer:Float = 0;

	public function new(state:FlxState, ui:FlxCamera)
	{
		final bmd = new BitmapData(240, 180, true, 0);
		for (y in 0...180)
			for (x in 0...240)
			{
				final dx = (x + 0.5 - 240 * 0.5) / (240 * 0.5);
				final dy = (y + 0.5 - 180 * 0.5) / (180 * 0.5);
				var t = (Math.sqrt(dx * dx + dy * dy) - 0.25) / (1 - 0.25);
				t = t < 0 ? 0 : t > 1 ? 1 : t;
				bmd.setPixel32(x, y, Std.int(t * t * (3 - 2 * t) * 255) << 24);
			}

		_vignette = new FlxSprite().loadGraphic(bmd);
		_vignette.antialiasing = true;
		_vignette.scrollFactor.set(0, 0);
		_vignette.cameras = [ui];
		_vignette.active = false;
		_vignette.alpha = 0;
		_baseScale = FlxG.width / 240;
		_vignette.screenCenter();
		state.add(_vignette);
	}

	public function update(elapsed:Float, target:Float, beating:Bool):Void
	{
		final rate = target > _level ? 1.5 : 3.0;
		_level += (target - _level) * (1.0 - Math.pow(0.01, elapsed * rate));
		if (_level < 0.001) _level = 0;

		if (beating && _level > 0.03)
		{
			_beatTimer -= elapsed;
			if (_beatTimer <= 0)
			{
				FlxG.sound.play(Paths.sound("minigame/thevalley/heartbeat"), 0.15 + (1.0 - 0.15) * _level);
				_beatTimer = 1.1 + (0.45 - 1.1) * _level;
				_pulse = 1;
			}
		}
		else _beatTimer = 0;
		_pulse = Math.max(0, _pulse - elapsed * 5.0);

		final spread = (2.6 + (1 - 2.6) * _level) * (1 - 0.07 * _pulse * _level);
		_vignette.scale.set(_baseScale * spread, _baseScale * spread);
		_vignette.alpha = Math.min(1, _level * 1.3);
		_vignette.visible = _level > 0;
	}
}
