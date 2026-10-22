package states.access;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

class FatalFall
{
	final _onDone:Void->Void;
	final _track:FlxSound;
	final _wins:Array<{ spr:FlxSprite, speed:Float, far:Bool }> = [];
	final _lines:Array<{ spr:FlxSprite, speed:Float }> = [];
	final _launch:Array<FlxSprite> = [];
	final _launchBase:Array<{ x:Float, y:Float, sf:Float }> = [];
	final _bf:FlxSprite;
	final _boy:FlxSprite;
	final _stand:FlxSprite;
	final _black:FlxSprite;
	final _path:Array<Float> = [0, 0.5, -0.2, 0.8, 0.5, 0.4, 2.0, 0.56, 0.43, 3.5, 0.44, 0.46, 5.0, 0.55, 0.42, 6.5, 0.46, 0.47, 8.0, 0.5, 0.45, 9.0, 0.5, 1.5];
	final _gif:Array<Int> = [6000, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1000, 100, 100, 100, 100, 1000, 100, 100, 1000, 100, 100, 100, 100, 3000];

	var _time:Float = 0;
	var _spawn:Float = 0;
	var _spawnFar:Float = 0;
	var _side:Int = 1;
	var _shook:Int = 0;
	var _done:Bool = false;

	public function new(state:FlxState, track:FlxSound, onDone:Void->Void)
	{
		_onDone = onDone;
		_track = track;
		final dir = 'assets/exe/access/fatal/cutscene/';

		state.add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		final scrollX = 1058.0 - FlxG.width * 0.5;
		final scrollY = 656.0 - FlxG.height * 0.5;
		for (l in [
			{ path: 'fondo1', x: 0.0, y: 0.0, sf: 0.2, anim: 'fondo_gif' },
			{ path: 'agua1', x: 0.0, y: 700.0, sf: 0.4, anim: 'agua' },
			{ path: 'montanas', x: -1.0, y: 462.0, sf: 0.4, anim: '' },
			{ path: 'agua2', x: 0.0, y: 800.0, sf: 0.5, anim: 'agua2' },
			{ path: 'pla', x: 2.0, y: -49.0, sf: 0.5, anim: '' },
			{ path: 'planta', x: 0.0, y: 1000.0, sf: 0.8, anim: '' },
			{ path: 'piso', x: 0.0, y: 1120.0, sf: 1.0, anim: '' }
		])
		{
			final spr = new FlxSprite();
			final key = 'fatality/new/launchbase/' + l.path;
			if (l.anim != '')
			{
				spr.frames = Paths.getSparrowAtlas(key);
				spr.animation.addByPrefix(l.anim, l.anim, 24, true);
				spr.animation.play(l.anim);
			}
			else spr.loadGraphic(Paths.image(key));
			spr.antialiasing = false;
			spr.origin.set(0, 0);
			spr.scale.set(1.6, 1.6);
			final cx = l.x - scrollX * l.sf + spr.frameWidth * 0.5;
			final cy = l.y - scrollY * l.sf + spr.frameHeight * 0.5;
			_launchBase.push({ x: (cx - FlxG.width * 0.5) * 0.4 + FlxG.width * 0.5 - spr.frameWidth * 0.8, y: (cy - FlxG.height * 0.5) * 0.4 + FlxG.height * 0.5 - spr.frameHeight * 0.8, sf: l.sf });
			final shade = Std.int(255 * (0.62 + 0.38 * l.sf));
			spr.color = FlxColor.fromRGB(shade, shade, Std.int(Math.min(255, shade + 12)));
			spr.visible = false;
			state.add(spr);
			_launch.push(spr);
		}

		final k = FlxG.height / 720;
		final pops = FlxAtlasFrames.fromSparrow(Paths.getBitmapData(dir + 'fatalpops.png'), Paths.getContent(dir + 'fatalpops.xml'));
		for (i in 0...22)
		{
			if (i == 10)
				for (_ in 0...26)
				{
					final l = new FlxSprite().makeGraphic(Std.int(Math.max(1, 2 * k)), Std.int(160 * k), FlxColor.WHITE);
					l.origin.set(0, 0);
					l.visible = false;
					state.add(l);
					_lines.push({ spr: l, speed: 0 });
				}
			final w = new FlxSprite();
			w.frames = pops;
			for (c in 0...3) w.animation.addByPrefix('p$c', 'pop$c ', 12, true);
			w.antialiasing = false;
			w.visible = false;
			state.add(w);
			_wins.push({ spr: w, speed: 0, far: i < 10 });
		}
		for (i in 0...6)
		{
			_spawnWindow(i % 2 == 0);
			for (w in _wins) if (w.spr.visible && w.spr.y >= FlxG.height) w.spr.y = FlxG.height * FlxG.random.float(0, 0.9);
		}
		for (l in _lines)
		{
			_spawnLine(l);
			l.spr.y = FlxG.height * FlxG.random.float(-0.2, 1);
		}

		_bf = _atlas(state, dir + 'fall');
		_bf.animation.addByPrefix('fall', 'fall', 17, true);
		_bf.animation.play('fall');
		_bf.scale.set(3 * FlxG.height / 720, 3 * FlxG.height / 720);
		_bf.updateHitbox();

		_boy = _atlas(state, dir + 'confused');
		_boy.visible = false;
		_stand = _atlas(state, dir + 'stand');
		_stand.visible = false;

		_black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		state.add(_black);
	}

	static function _atlas(state:FlxState, path:String):FlxSprite
	{
		final spr = new FlxSprite();
		spr.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData(path + '.png'), Paths.getContent(path + '.xml'));
		spr.antialiasing = false;
		state.add(spr);
		return spr;
	}

	public function update(elapsed:Float):Void
	{
		if (_done) return;
		_time = _track != null && _track.playing ? _track.time / 1000 : _time + elapsed;
		if (Controls.instance.ACCEPT || _time >= 34.9)
		{
			_finish();
			return;
		}
		_updateFall(elapsed);
		_updateWake();

		_black.alpha = _time < 1.2 ? 1 - _time / 1.2 : _time < 15.2 ? 0 :(_time < 16.8 ? 1 - (_time - 15.2) / 1.6 : (_time < 33.4 ? 0 : Math.min(1, (_time - 33.4) / 1.5)));
	}

	function _updateFall(elapsed:Float):Void
	{
		final falling = _time < 11.05;
		final k = FlxG.height / 720;
		_bf.visible = falling && _time < 9.0;
		if (_bf.visible)
		{
			var i = 0;
			while (i + 3 < _path.length - 3 && _time >= _path[i + 3]) i += 3;
			final t0 = _path[i];
			final t1 = _path[i + 3];
			final f = Math.max(0, Math.min(1, (_time - t0) / (t1 - t0)));
			final e = i == 0 ? FlxEase.quadOut(f) : (i + 6 >= _path.length ? FlxEase.quadIn(f) : FlxEase.smoothStepInOut(f));
			final px = _path[i + 1] + (_path[i + 4] - _path[i + 1]) * e;
			final py = _path[i + 2] + (_path[i + 5] - _path[i + 2]) * e;
			final shake = (Math.sin(_time * 31) * 3 + FlxG.random.float(-2, 2)) * k;
			_bf.setPosition(px * FlxG.width - _bf.width * 0.5 + shake, py * FlxG.height - _bf.height * 0.5 + FlxG.random.float(-2, 2) * k);
			_bf.angle = Math.sin(_time * 11) * 6;
		}

		_spawn -= elapsed;
		_spawnFar -= elapsed;
		if (_time < 9.6 && _spawn <= 0)
		{
			_spawn = FlxG.random.float(0.16, 0.28);
			_spawnWindow(false);
		}
		if (_time < 9.6 && _spawnFar <= 0)
		{
			_spawnFar = FlxG.random.float(0.12, 0.25);
			_spawnWindow(true);
		}
		for (w in _wins)
		{
			final s = w.spr;
			if (!s.visible) continue;
			s.y -= w.speed * k * elapsed;
			if (s.y + s.height < 0 || !falling) s.visible = false;
		}
		for (l in _lines)
		{
			final s = l.spr;
			s.y -= l.speed * k * elapsed;
			if (s.y + s.height * s.scale.y < 0) _spawnLine(l);
			s.visible = falling && _time < 10.6;
		}

		if (_time >= 11.05 && _shook == 0)
		{
			_shook = 1;
			FlxG.camera.shake(0.02, 0.3);
		}
		if (_time >= 12.6 && _shook == 1)
		{
			_shook = 2;
			FlxG.camera.shake(0.008, 0.2);
		}
	}

	function _spawnWindow(far:Bool):Void
	{
		var w = null;
		for (c in _wins) if (c.far == far && !c.spr.visible) { w = c; break; }
		if (w == null) return;
		final k = FlxG.height / 720;
		final s = w.spr;
		s.animation.play('p' + FlxG.random.int(0, 2), true, false, FlxG.random.int(0, 5));
		final sc = (far ? FlxG.random.float(0.8, 1.0) : FlxG.random.float(1.6, 1.9)) * k;
		s.scale.set(sc, sc);
		s.updateHitbox();
		s.alpha = far ? 0.55 : 1;
		s.color = far ? 0xFF9090A0 : FlxColor.WHITE;
		if (far) s.x = FlxG.random.float(-0.1, 0.95) * FlxG.width;
		else
		{
			_side = -_side;
			s.x = (_side < 0 ? FlxG.random.float(-0.15, 0.18) : FlxG.random.float(0.68, 1.0)) * FlxG.width;
		}
		s.y = FlxG.height + FlxG.random.float(0, 60) * k;
		w.speed = far ? FlxG.random.float(600, 850) : FlxG.random.float(1100, 1500);
		s.visible = true;
	}

	function _spawnLine(l:{ spr:FlxSprite, speed:Float }):Void
	{
		final s = l.spr;
		s.scale.set(1, FlxG.random.float(0.5, 2.2));
		s.x = FlxG.random.float(0, FlxG.width);
		s.y = FlxG.height + FlxG.random.float(0, 300) * FlxG.height / 720;
		s.alpha = FlxG.random.float(0.08, 0.3);
		l.speed = FlxG.random.float(2200, 3200);
	}

	function _updateWake():Void
	{
		final k = FlxG.height / 720;
		final w = FlxG.width;
		final h = FlxG.height;

		final bg = _time >= 22.0;
		if (_launch[0].visible != bg) for (s in _launch) s.visible = bg;
		if (bg) _updateLaunch(k);

		final t = _time - 15.2;
		_boy.visible = t >= 0 && _time < 29.6;
		if (_boy.visible)
		{
			var ms = t * 1000;
			var i = 0;
			while (i < _gif.length - 1 && ms >= _gif[i])
			{
				ms -= _gif[i];
				i++;
			}
			_boy.animation.frameIndex = i;

			if (i >= 9) _focus(_boy, 75, 0, w * 0.5, 18 * k, 4.8 * k, 0);
			else if (i >= 5) _focus(_boy, 75, 72, w * 0.5, h * 0.57, (8.6 - 0.4 * Math.min(1, (t - 6.0) / 0.8)) * k, 0);
			else if (t < 2.3)
			{
				final e = FlxEase.quadOut(t / 2.3);
				_focus(_boy, 75, 72, w * 0.5 + 60 * k * (1 - e), h * 0.57 + 20 * k * (1 - e), (13 - 4 * e) * k, 28 * (1 - e));
			}
			else _focus(_boy, 75, 72, w * 0.5, h * 0.57, (9 - 1.4 * Math.min(1, (t - 2.3) / 3.7)) * k, 0);
		}

		final st = _time - 29.6;
		_stand.visible = st >= 0;
		if (_stand.visible)
		{
			_stand.animation.frameIndex = st < 0.1 ? 0 : (st < 0.2 ? 1 : (st < 0.3 ? 2 : (st < 0.4 ? 3 : 4)));
			final e = Math.min(1, st / 3.8);
			_focus(_stand, 70, 0, w * 0.52, (108 + 20 * e) * k, (7.2 - 1.2 * e) * k, 0);
		}
	}

	function _updateLaunch(k:Float):Void
	{
		final grow = 4 - 0.6 * Math.max(0, Math.min(1, (_time - 29.6) / 3.8));
		final cx = 680 * FlxG.width / 1280;
		final cy = 423 * k;
		final tx = (-40 + Math.sin(_time * 0.35) * 14) * k;
		final ty = 92 * k;
		for (i in 0..._launch.length)
		{
			final b = _launchBase[i];
			final m = Math.pow(grow, b.sf);
			final s = _launch[i];
			s.scale.set(1.6 * m, 1.6 * m);
			s.setPosition(cx + (b.x - cx) * m + tx * b.sf, cy + (b.y - cy) * m + ty * b.sf);
		}
	}

	static inline function _focus(spr:FlxSprite, fx:Float, fy:Float, sx:Float, sy:Float, scale:Float, angle:Float):Void
	{
		spr.origin.set(fx, fy);
		spr.scale.set(scale, scale);
		spr.angle = angle;
		spr.setPosition(sx - fx, sy - fy);
	}

	function _finish():Void
	{
		_done = true;
		_track?.stop();
		_onDone();
	}
}
