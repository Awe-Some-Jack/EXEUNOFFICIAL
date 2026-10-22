package minigames.thevalley.character.monster;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;

import openfl.display.BitmapData;
import openfl.display.BlendMode;

class ExeScream
{
	public var target:Void->{ x:Float, y:Float };

	final _cam:FlxCamera;
	final _shade:FlxSprite;
	final _letters:Array<{ spr:FlxSprite, glow:FlxSprite, sc:Float, age:Float }> = [];

	var _time:Float = -1;
	var _side:Int = 1;
	var _rowY:Float = 0;
	var _emit:Float = 0;

	public function new(state:FlxState, cam:FlxCamera)
	{
		_cam = cam;

		final bmd = new BitmapData(64, 1, true, 0);
		for (x in 0...64)
		{
			final t = 1 - x / 64;
			bmd.setPixel32(x, 0, (Std.int(t * t * 255) << 24) | 0x7A0000);
		}
		_shade = new FlxSprite().loadGraphic(bmd);
		_shade.origin.set(0, 0);
		_shade.scale.set(FlxG.width * 0.5 / 64, FlxG.height);
		_shade.scrollFactor.set(0, 0);
		_shade.cameras = [cam];
		_shade.visible = false;
		state.add(_shade);

		final graphic = Paths.image('minigame/thevalley/characters/exe/a');
		for (_ in 0...16)
		{
			final glow = _letter(state, graphic);
			glow.blend = BlendMode.ADD;
			glow.color = 0xFFFF2A1A;
			_letters.push({ spr: _letter(state, graphic), glow: glow, sc: 4, age: -1 });
		}
	}

	function _letter(state:FlxState, graphic:FlxGraphic):FlxSprite
	{
		final spr = new FlxSprite(0, 0, graphic);
		spr.antialiasing = false;
		spr.scrollFactor.set(0, 0);
		spr.cameras = [_cam];
		spr.active = false;
		spr.visible = false;
		state.add(spr);
		return spr;
	}

	public function scream(side:Int, screenY:Float):Void
	{
		_side = side;
		_rowY = Math.max(90, Math.min(FlxG.height - 90, screenY));
		_time = 0;
		_emit = 0.2;
		FlxG.sound.play(Paths.sound("minigame/thevalley/EXE/EXEScream"), 0.9).pan = side * 0.6;
		_shade.flipX = side > 0;
		_shade.x = side > 0 ? FlxG.width * 0.5 : 0;
	}

	public function update(elapsed:Float):Void
	{
		if (_time < 0) return;
		_time += elapsed;
		final env = _time < 0.2 ? 0 : (_time < 3.3 ? Math.min(1, (_time - 0.2) / 0.08) : Math.max(0, 1 - (_time - 3.3)));

		final flash = _time < 0.2 ? 0 : Math.max(0, 0.4 - (_time - 0.2) * 2);
		_shade.visible = env > 0;
		_shade.alpha = env * (0.45 + 0.08 * Math.sin(_time * 30.0) + (FlxG.random.bool(8) ? 0.15 : 0)) + flash;

		_emit -= elapsed;
		while (_emit <= 0 && _time < 3.3)
		{
			var l = null;
			for (c in _letters) if (c.age < 0) { l = c; break; }
			if (l == null) break;
			l.age = -_emit;
			l.sc = FlxG.random.float(3.5, 4.5);
			l.spr.visible = l.glow.visible = true;
			_emit += 0.12;
		}

		final gap = 42.0;
		final amp = 8 + 22 * env;
		final tgt = target != null ? target() : { x: FlxG.width * 0.5, y: _rowY };
		final ex = _side < 0 ? 60.0 : FlxG.width - 60.0;
		final midX = ex + (tgt.x - ex) * 0.5;
		final len = Math.max(200.0, Math.sqrt((tgt.x - ex) * (tgt.x - ex) + (tgt.y - _rowY) * (tgt.y - _rowY)));
		var alive = false;
		for (i in 0..._letters.length)
		{
			final l = _letters[i];
			if (l.age < 0) continue;
			l.age += elapsed;
			final d = l.age * 320.0;
			final u = d / len;
			if (u >= 1)
			{
				l.age = -1;
				l.spr.visible = l.glow.visible = false;
				continue;
			}
			alive = true;

			final iu = 1 - u;
			final px = iu * iu * ex + 2 * iu * u * midX + u * u * tgt.x;
			final py = iu * iu * _rowY + 2 * iu * u * _rowY + u * u * tgt.y;
			final tx = 2 * iu * (midX - ex) + 2 * u * (tgt.x - midX);
			final ty = 2 * u * (tgt.y - _rowY);
			final tl = Math.max(1, Math.sqrt(tx * tx + ty * ty));

			final pop = FlxEase.backOut(Math.min(1, l.age / 0.15));
			final fade = FlxEase.quadIn(Math.max(0, (u - 0.5) / 0.5));
			final chaos = 1.5 + 3.5 * env;
			// chaos referencia :eyes: 
			final phase = _time * 7 - d / gap * 0.6;
			final wave = Math.sin(phase) * amp * (1 - 0.6 * u);
			final cx = px - ty / tl * wave + FlxG.random.float(-chaos, chaos) * 0.6;
			final cy = py + tx / tl * wave * -_side + FlxG.random.float(-chaos, chaos);
			final sc = l.sc * (0.4 + 0.6 * pop) * (1 + 0.08 * Math.sin(_time * 23 + i * 2));
			_place(l.spr, cx, cy, sc * (1 + 0.6 * fade), sc * (1 - 0.4 * fade));
			l.spr.angle = Math.atan2(-_side * ty, Math.abs(tx)) * 180 / Math.PI + _side * Math.cos(phase) * amp * 0.6 / gap * 57 + FlxG.random.float(-5, 5) * env;
			l.spr.alpha = Math.min(1, l.age / 0.08) * (1 - fade) * (FlxG.random.bool(4) ? 0.35 : 1);
			_place(l.glow, cx, cy + FlxG.random.float(-chaos, chaos), sc * 1.3, sc * 1.3);
			l.glow.angle = l.spr.angle;
			l.glow.alpha = 0.4 * (1 - fade);
		}

		if (_time >= 4.3 && !alive)
		{
			_time = -1;
			_shade.visible = false;
		}
	}

	static function _place(spr:FlxSprite, cx:Float, cy:Float, sx:Float, sy:Float):Void
	{
		spr.scale.set(sx, sy);
		spr.x = cx - spr.frameWidth * 0.5;
		spr.y = cy - spr.frameHeight * 0.5;
	}
}
