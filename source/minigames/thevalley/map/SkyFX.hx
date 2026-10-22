package minigames.thevalley.map;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

class SkyFX
{
	final _state:FlxState;
	final _ramp:Array<FlxColor> = [0xFF4A2513, 0xFF6D3314, 0xFF905C24, 0xFFCE8639, 0xFFFFB361, 0xFFFFBD75];
	final _stars:Array<{ spr:FlxSprite, phase:Float, speed:Float, top:Int, lv:Int }> = [];
	final _embers:Array<{ spr:FlxSprite, phase:Float, sway:Float, c:Int }> = [];

	var _time:Float = 0;
	var _placed:Bool = false;

	public function new(state:FlxState)
	{
		_state = state;
	}

	public function addSky(eclipse:FlxSprite, register:FlxSprite->Void):Void
	{
		final sky = Paths.getBitmapData('assets/shared/images/minigame/thevalley/bg/mountain/eclipse.webp');
		if (sky != null)
		{
			var tries = 0;
			while (_stars.length < 60 && tries++ < 600)
			{
				final ix = FlxG.random.int(2, 767);
				final iy = FlxG.random.int(100, 253);
				var flat = true;
				for (dx in [-2, 0, 2]) for (dy in [-2, 0, 2])
					if (sky.getPixel(ix + dx, iy + dy) != 0x2D1C12) flat = false;
				if (!flat) continue;
				final s = new FlxSprite(eclipse.x + ix * 1.1, eclipse.y + iy * 1.1);
				s.makeGraphic(1, 1, FlxColor.WHITE);
				s.scale.set(1.1, 1.1);
				s.updateHitbox();
				s.moves = false;
				register(s);
				_stars.push({ spr: s, phase: FlxG.random.float(0, Math.PI * 2), speed: FlxG.random.float(0.6, 2.2), top: FlxG.random.weightedPick([0, 0, 5, 4, 2, 1]), lv: -1 });
			}
		}
	}

	public function addEmbers():Void
	{
		for (_ in 0...36)
		{
			final s = new FlxSprite();
			s.makeGraphic(FlxG.random.bool(30) ? 2 : 1, 1, FlxColor.WHITE);
			s.scrollFactor.set(0.38, 0.08);
			_state.add(s);
			_embers.push({ spr: s, phase: FlxG.random.float(0, Math.PI * 2), sway: FlxG.random.float(0.5, 1.4), c: -1 });
		}
	}

	public function showParallax(on:Bool):Void
	{
		for (e in _embers) e.spr.visible = on;
	}

	public function update(elapsed:Float):Void
	{
		_time += elapsed;

		for (s in _stars)
		{
			final level = Math.round(s.top * Math.max(0, Math.sin(_time * s.speed + s.phase)));
			if (level == s.lv) continue;
			s.lv = level;
			s.spr.visible = level > 0;
			if (level > 0) s.spr.color = _ramp[level - 1];
		}

		_updateEmbers(FlxG.camera);
	}

	function _updateEmbers(cam:FlxCamera):Void
	{
		if (_embers.length == 0) return;
		if (!_placed)
		{
			_placed = true;
			for (e in _embers) _spawnEmber(e.spr, cam, false);
		}
		for (e in _embers)
		{
			final s = e.spr;
			s.velocity.x = -4 + Math.sin(_time * e.sway + e.phase) * 6;
			final c = 3 + Std.int(Math.abs(Math.sin(_time * 2.6 * e.sway + e.phase)) * 2.99);
			if (c != e.c)
			{
				e.c = c;
				s.color = _ramp[c];
			}
			final rx = s.x - cam.scroll.x * s.scrollFactor.x;
			final ry = s.y - cam.scroll.y * s.scrollFactor.y;
			if (ry < cam.viewMarginTop - 6 || ry > cam.viewMarginBottom + 60) _spawnEmber(s, cam, ry < cam.viewMarginTop);
			else if (rx < cam.viewMarginLeft - 6) s.x += cam.viewWidth + 12;
			else if (rx > cam.viewMarginRight + 6) s.x -= cam.viewWidth + 12;
		}
	}

	function _spawnEmber(s:FlxSprite, cam:FlxCamera, fromBottom:Bool):Void
	{
		s.x = cam.scroll.x * s.scrollFactor.x + cam.viewMarginLeft + FlxG.random.float(0, cam.viewWidth);
		s.y = cam.scroll.y * s.scrollFactor.y + (fromBottom ? cam.viewMarginBottom + FlxG.random.float(2, 30) : cam.viewMarginTop + FlxG.random.float(0, cam.viewHeight));
		s.velocity.y = -FlxG.random.float(5, 13);
	}
}
