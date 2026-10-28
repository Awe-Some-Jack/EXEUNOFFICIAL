package minigames.preymini.cutscenes;

import flixel.FlxState;
import minigames.Camera;
import minigames.preymini.character.player.HUD;
import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.BGPrey;
import minigames.preymini.map.SkyParade;
import minigames.preymini.map.Terrain;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;

class LevelEnding
{
	public var onDone:Void->Void = null;

	public var furnaceLimit:Float = Math.POSITIVE_INFINITY;

	final _state:FlxState;
	final _sonic:Sonic;
	final _terrain:Terrain;
	final _camera:Camera;
	final _bg:BGPrey;
	final _hud:HUD;

	final _actor:FlxSprite;
	final _runner:FlxSprite;
	final _ghosts:Array<FlxSprite> = [];
	final _ghostAge:Array<Float> = [];
	final _fire:FlxSprite;
	final _dim:FlxSprite;
	final _streaks:Array<FlxSprite> = [];
	final _streakSpeed:Array<Float> = [];
	final _render:FlxSprite;
	final _top:FlxSprite;
	final _bottom:FlxSprite;
	final _black:FlxSprite;
	final _subtitle:FlxText;
	final _halos:Array<FlxSprite> = [];
	final _haloSpots:Array<Array<Float>> = [];

	var _furnace:FlxSprite = null;
	var _heat:FlxSprite = null;
	var _tung:Bool = false;
	var _braking:Bool = true;
	var _brakeTime:Float = 0;
	var _settle:Float = 0;
	var _age:Float = 0;
	var _t:Float = 0;
	var _prev:Float = 0;
	var _seq:Array<Int> = [];
	var _seqTime:Float = 0;
	var _px:Float = 0;
	var _py:Float = 0;
	var _charging:Float = -1;
	var _charge:FlxSound = null;
	var _running:Bool = false;
	var _runSpeed:Float = 0;
	var _ghostTimer:Float = 0;
	var _fireLevel:Float = 0;
	var _fireFlash:Float = 0;
	var _closeT:Float = -1;
	var _struck:Float = -1;
	var _faceX:Float = 0;
	var _faceY:Float = 0;
	var _panX:Float = 0;
	var _words:Array<String> = [];
	var _shown:Int = 0;
	var _wordTime:Float = 0;

	public function new(state:FlxState, sonic:Sonic, terrain:Terrain, camera:Camera, bg:BGPrey, hud:HUD, overlay:FlxCamera)
	{
		_state = state;
		_sonic = sonic;
		_terrain = terrain;
		_camera = camera;
		_bg = bg;
		_hud = hud;
		_sonic.controllable = false;
		_sonic.autoDir = 0;

		_fire = new FlxSprite().loadGraphic(_fireArt());
		_fire.antialiasing = false;
		_fire.moves = false;
		_fire.origin.set(0, 0);
		_fire.blend = BlendMode.ADD;
		_fire.alpha = 0;
		state.insert(state.members.indexOf(sonic), _fire);

		_runner = new FlxSprite();
		_runner.frames = Paths.getSparrowAtlas("minigame/preymini/characters/sonic/sonic");
		_runner.animation.addByPrefix("peelout", "peelout0", 20, true);
		_pixel(_runner, 29.5, 32);
		state.insert(state.members.indexOf(sonic), _runner);

		_actor = new FlxSprite();
		_actor.frames = Paths.getSparrowAtlas("minigame/preymini/bg/cutscene/SonicCutscene");
		_pixel(_actor, 44.5, 60);
		_actor.animation.frameIndex = 0;
		state.insert(state.members.indexOf(sonic), _actor);

		_dim = _screen(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK), overlay);
		_dim.alpha = 0;
		for (i in 0...16)
		{
			final streak = _screen(new FlxSprite().makeGraphic(FlxG.random.int(90, 280), FlxG.random.int(2, 4), FlxColor.WHITE), overlay);
			streak.visible = false;
			_streaks.push(streak);
			_streakSpeed.push(FlxG.random.float(1700, 2600));
			_resetStreak(i, FlxG.random.float(0, FlxG.width));
		}
		_render = _screen(new FlxSprite().loadGraphic(Paths.image("minigame/preymini/bg/cutscene/sonicrender")), overlay);
		_render.scale.set(3.5, 3.5);
		_render.origin.set(0, 0);
		_render.setPosition(FlxG.width, 17);
		_render.visible = false;
		_top = _screen(new FlxSprite(0, -60).makeGraphic(FlxG.width, 60, FlxColor.BLACK), overlay);
		_bottom = _screen(new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 60, FlxColor.BLACK), overlay);
		_subtitle = new FlxText((FlxG.width - 860) / 2, 0, 860, "", 28);
		_subtitle.setFormat(Paths.font("sonichud.ttf"), 28, 0xFF4848B4, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		_subtitle.borderSize = 2;
		_subtitle.alpha = 0;
		_screen(_subtitle, overlay);
		_black = _screen(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK), overlay);
		_black.alpha = 0;
	}

	public function boom(pan:Float, size:Float):Void
	{
		_fireFlash = Math.min(1, _fireFlash + 0.3 * size * (0.5 + 0.5 * Math.max(0, pan)));
	}

	public function update(elapsed:Float):Void
	{
		_age += elapsed;
		final bars = FlxEase.quadOut(Math.min(1, _age / 0.6));
		_top.y = -60 + 60 * bars;
		_bottom.y = FlxG.height - 60 * bars;
		final hud = Math.max(0, 1 - _age / 0.5);
		for (s in _hud.members) if (s != null) s.alpha = hud;
		_updateFire(elapsed);

		if (_braking)
		{
			_brake(elapsed);
			return;
		}

		_prev = _t;
		_t += elapsed;
		_script();
		_updateSubtitle(elapsed);
		_animateActor(elapsed);
		_updateRunner(elapsed);
		_updateGhosts(elapsed);
		_updateCloseUp(elapsed);
		_updateFurnace(elapsed);
	}

	function _brake(elapsed:Float):Void
	{
		_brakeTime += elapsed;
		final s = _sonic.speed / 360;
		_sonic.autoDir = !_sonic.grounded ? 0 : s > 0.6 ? -1 : s < -0.6 ? 1 : 0;
		final still = _sonic.grounded && s == 0 && !_sonic.rolling && !_sonic.spinDashing && !_sonic.peelingOut;
		_settle = still ? _settle + elapsed : 0;
		if (_settle < 0.35 && _brakeTime < 8) return;
		_braking = false;
		_sonic.autoDir = 0;
		_begin();
	}

	function _begin():Void
	{
		_px = _sonic.posX;
		_py = _sonic.posY;
		_sonic.visible = false;
		_sonic.active = false;
		_actor.visible = true;
		_actor.flipX = false;
		_placeActor();
		_playSeq([1, 2, 3, 4, 5]);

		final center = Math.min((_camera.x - _terrain.x) / 6 - 418, furnaceLimit);
		_panX = _terrain.worldX(center + 118);
		final ground = _terrain.topAt(Std.int(center), Std.int(_py - 60));
		final floor = ground >= 0 ? ground : _py + 19;
		_tung = FlxG.random.bool(2);
		final art = Paths.image(_tung ? "minigame/preymini/bg/cutscene/tungtung" : "minigame/preymini/bg/cutscene/furnace", null, false);
		_furnace = _terrain.attach(new FlxSprite().loadGraphic(art), center - 24.5, floor - 74);
		_state.insert(_state.members.indexOf(_runner), _furnace);
		_faceX = _terrain.worldX(center + 4);
		_faceY = _terrain.worldY(floor - 52);
		if (_tung) return;

		_heat = _terrain.attach(new FlxSprite().loadGraphic(_heatArt(art.bitmap)), center - 24.5, floor - 74);
		_heat.blend = BlendMode.ADD;
		_heat.alpha = 0;
		_state.insert(_state.members.indexOf(_runner), _heat);
		for (spot in _haloSpots)
		{
			final halo = new FlxSprite().loadGraphic(SkyParade.halo());
			halo.antialiasing = false;
			halo.moves = false;
			halo.origin.set(0, 0);
			halo.color = 0xFFFF5A12;
			halo.blend = BlendMode.ADD;
			halo.alpha = 0;
			_halos.push(halo);
			_state.insert(_state.members.indexOf(_runner), halo);
		}
	}

	function _script():Void
	{
		if (_at(0.55)) FlxG.sound.play(Paths.sound("minigame/preymini/sonicvoiceline"));
		if (_at(0.75)) _say(1);
		if (_at(1.15)) _say(0);
		if (_at(1.85)) _say(2);
		if (_at(3.35)) _say(0);
		if (_at(4.05)) _say(3);
		if (_at(5.25)) _say(0);
		if (_at(7.05)) _say(4);
		if (_at(9.05)) _say(0);
		if (_at(5.45)) _playSeq([10, 11, 12, 13]);
		if (_at(5.55)) _bg.ignite();
		if (_at(5.85)) _closeT = 0;
		if (_at(9.6)) _playSeq([14, 15, 16, 17]);
		if (_at(10.45)) _startCharge();
		if (_at(11.65)) _launch();
		for (i in 0...5)
			if (_at(13.3 + i * 0.85)) _stomp(i / 4);
		if (_at(18.0)) _camera.lookAt(_panX, _camera.y, _camera.zoom, 4.2, FlxEase.sineInOut);
		if (_at(22.7)) _strike();
		if (_at(22.9)) _thunder(0.75, 0.36);
		if (_tung)
			for (i in 0...3)
				if (_at(23.3 + i * 0.28))
				{
					final knock = FlxG.sound.play(Paths.sound("minigame/preymini/tung"), 0.9);
					#if FLX_PITCH
					knock.pitch = 1 - i * 0.04;
					#end
				}
		_black.alpha = Math.floor(Math.max(0, Math.min(1, (_t - 25.2) / 1.6)) * 8) / 8;
		if (_at(27.6) && onDone != null) onDone();
	}

	inline function _at(time:Float):Bool return _prev < time && _t >= time;

	function _say(line:Int):Void
	{
		if (line == 0)
		{
			FlxTween.tween(_subtitle, {alpha: 0}, 1);
			return;
		}
		final english = ["Woah!", "Check out all those badniks...", "Where are they all heading?", "Better go find out what's going on!"];
		_words = Language.getPhrase('prey_ending_$line', english[line - 1]).split(" ");
		_shown = 0;
		_wordTime = 0;
		FlxTween.cancelTweensOf(_subtitle);
		_subtitle.text = "";
		_subtitle.alpha = 1;
	}

	function _updateSubtitle(elapsed:Float):Void
	{
		if (_shown >= _words.length) return;
		_wordTime -= elapsed;
		if (_wordTime > 0) return;
		_wordTime = 0.18;
		_shown++;
		_subtitle.text = _words.slice(0, _shown).join(" ");
	}

	function _playSeq(frames:Array<Int>):Void
	{
		_seq = frames;
		_seqTime = 0;
		_actor.animation.frameIndex = frames[0];
	}

	function _animateActor(elapsed:Float):Void
	{
		_placeActor();
		if (_seq.length == 0) return;
		_seqTime += elapsed;
		_actor.animation.frameIndex = _seq[Std.int(Math.min(_seq.length - 1, _seqTime / 0.1))];
	}

	inline function _placeActor():Void
	{
		_actor.setPosition(_terrain.worldX(_px) - 44.5, _terrain.worldY(_py) - 60);
	}

	function _startCharge():Void
	{
		_actor.visible = false;
		_runner.visible = true;
		_runner.animation.play("peelout", true);
		_charging = 0;
		_charge = FlxG.sound.play(Paths.sound("minigame/preymini/peeloutcharge"));
	}

	function _launch():Void
	{
		_charging = -1;
		_charge?.stop();
		FlxG.sound.play(Paths.sound("minigame/preymini/peeloutgo"));
		_running = true;
		_runSpeed = 0;
		_bg.rally(false);
	}

	function _updateRunner(elapsed:Float):Void
	{
		if (!_runner.visible) return;
		if (_charging >= 0)
		{
			_charging += elapsed;
			_runner.animation.curAnim.frameRate = 8 + 42 * Math.min(1, _charging / 1.1);
		}
		if (_running)
		{
			_runSpeed = Math.min(14, _runSpeed + 1.4 * elapsed * 60);
			_px += _runSpeed * elapsed * 60;
			_ghostTimer += elapsed;
			if (_ghostTimer >= 0.03)
			{
				_ghostTimer = 0;
				_ghost();
			}
		}
		_runner.setPosition(_terrain.worldX(_px) - 29.5, _terrain.worldY(_py) - 32);
		if (_running && _runner.x > FlxG.camera.viewRight + 240)
		{
			_running = false;
			_runner.visible = false;
		}
	}

	function _ghost():Void
	{
		var i = _ghosts.length;
		for (j in 0..._ghosts.length)
			if (!_ghosts[j].visible)
			{
				i = j;
				break;
			}
		if (i == _ghosts.length)
		{
			final g = new FlxSprite();
			g.frames = _runner.frames;
			_pixel(g, 29.5, 32);
			g.color = 0xFF5A78FF;
			_state.insert(_state.members.indexOf(_runner), g);
			_ghosts.push(g);
			_ghostAge.push(0);
		}
		final g = _ghosts[i];
		g.visible = true;
		g.animation.frameIndex = _runner.animation.frameIndex;
		g.setPosition(_runner.x, _runner.y);
		_ghostAge[i] = 0;
	}

	function _updateGhosts(elapsed:Float):Void
	{
		for (i in 0..._ghosts.length)
		{
			final g = _ghosts[i];
			if (!g.visible) continue;
			_ghostAge[i] += elapsed;
			g.alpha = 0.5 * Math.max(0, 1 - _ghostAge[i] / 0.2);
			if (_ghostAge[i] >= 0.2) g.visible = false;
		}
	}

	function _stomp(k:Float):Void
	{
		_camera.shake(0.003 + 0.007 * k, 0.3);
		final clank = FlxG.sound.play(Paths.sound("minigame/preymini/hit"), 0.45 + 0.55 * k);
		final thud = FlxG.sound.play(Paths.sound("minigame/preymini/explosion"), 0.25 + 0.35 * k);
		clank.pan = thud.pan = -0.8 + 0.4 * k;
		#if FLX_PITCH
		clank.pitch = 0.45;
		thud.pitch = 0.3;
		#end
	}

	function _strike():Void
	{
		_struck = 0;
		_bg.strike();
		_thunder(1, 0.5);
		_camera.shake(0.004, 0.4);
		_camera.lookAt(_faceX, _faceY, 0.62, 2.8, FlxEase.sineInOut);
	}

	function _thunder(volume:Float, pitch:Float):Void
	{
		final sound = FlxG.sound.play(Paths.sound("minigame/preymini/explosion"), volume);
		#if FLX_PITCH
		sound.pitch = pitch;
		#end
	}

	function _updateFire(elapsed:Float):Void
	{
		final target = !_braking && _t >= 5.55 && _t < 12 ? 1 : 0;
		_fireLevel = target > _fireLevel ? Math.min(1, _fireLevel + elapsed / 0.6) : Math.max(0, _fireLevel - elapsed / 1.8);
		_fireFlash = Math.max(0, _fireFlash - elapsed * 2.2);
		final flicker = 0.8 + 0.12 * Math.sin(_age * 9) + 0.08 * Math.sin(_age * 23);
		_fire.alpha = _fireLevel * Math.min(1, 0.6 * flicker + 0.5 * _fireFlash);
		final cam = FlxG.camera;
		final w = (cam.viewRight - cam.viewLeft) * 0.5;
		_fire.scale.set(w / 24, (cam.viewBottom - cam.viewTop) / 16);
		_fire.setPosition(cam.viewRight - w, cam.viewTop);
	}

	function _updateCloseUp(elapsed:Float):Void
	{
		if (_closeT < 0) return;
		_closeT += elapsed;
		final enter = Math.min(1, _closeT / 0.35);
		final leave = Math.max(0, Math.min(1, (_closeT - 3.4) / 0.3));
		final show = FlxEase.quadOut(enter) * (1 - FlxEase.quadIn(leave));
		_dim.alpha = 0.6 * show;

		final rest = 299 - 8 * _closeT;
		_render.visible = true;
		_render.x = leave > 0 ? rest + (FlxG.width + 60 - rest) * FlxEase.quadIn(leave) : FlxG.width + (rest - FlxG.width) * FlxEase.expoOut(enter);

		for (i in 0..._streaks.length)
		{
			final streak = _streaks[i];
			streak.visible = show > 0;
			streak.alpha = 0.22 * show;
			streak.x -= _streakSpeed[i] * elapsed;
			if (streak.x + streak.width < 0) _resetStreak(i, FlxG.width + FlxG.random.float(0, 300));
		}

		if (leave < 1) return;
		_closeT = -1;
		_render.visible = false;
		_dim.alpha = 0;
		for (streak in _streaks) streak.visible = false;
	}

	function _resetStreak(i:Int, x:Float):Void
	{
		_streaks[i].setPosition(x, FlxG.random.float(70, FlxG.height - 70));
	}

	function _updateFurnace(elapsed:Float):Void
	{
		if (_furnace == null) return;
		var glow = 0.0;
		if (_struck >= 0)
		{
			_struck += elapsed;
			final settle = _struck < 0.12 ? 1 : 0.62 + 0.38 * Math.exp(-(_struck - 0.12) * 2.2);
			glow = Math.min(1, settle + 0.18 * Math.sin(_struck * 6.5) * Math.min(1, _struck));
		}
		if (_heat != null) _heat.alpha = glow;
		final ember = 0.14 + 0.06 * Math.sin(_age * 3);
		for (i in 0..._halos.length)
		{
			final halo = _halos[i], spot = _haloSpots[i];
			halo.alpha = Math.min(1, ember + glow * 0.85);
			final size = spot[2] * 6 * (2.4 + 0.8 * glow) / 32;
			halo.scale.set(size, size);
			halo.setPosition(_furnace.x + spot[0] * 6 - 16 * size, _furnace.y + spot[1] * 6 - 16 * size);
		}
	}

	function _heatArt(src:BitmapData):BitmapData
	{
		final w = src.width, h = src.height;
		final out = new BitmapData(w, h, true, 0);
		final hot = new haxe.ds.IntMap<Bool>();
		for (py in 0...h)
			for (px in 0...w)
			{
				final c = src.getPixel32(px, py);
				final a = (c >>> 24) & 0xFF, r = (c >> 16) & 0xFF, g = (c >> 8) & 0xFF, b = c & 0xFF;
				if (a < 128 || r < 200 || b > 80) continue;
				out.setPixel32(px, py, FlxColor.fromRGB(255, Std.int(Math.min(255, g * 0.6 + 100)), Std.int(Math.min(255, g * 0.4 + 40))));
				hot.set(py * w + px, true);
			}

		for (key in hot.keys())
		{
			if (!hot.get(key)) continue;
			final open = [key];
			hot.set(key, false);
			var sumX = 0.0, sumY = 0.0, count = 0;
			var left = w, right = 0, top = h, bottom = 0;
			while (open.length > 0)
			{
				final cell = open.pop();
				final cx = cell % w, cy = Std.int(cell / w);
				sumX += cx + 0.5;
				sumY += cy + 0.5;
				count++;
				left = Std.int(Math.min(left, cx));
				right = Std.int(Math.max(right, cx));
				top = Std.int(Math.min(top, cy));
				bottom = Std.int(Math.max(bottom, cy));
				for (dy in -2...3)
					for (dx in -2...3)
					{
						final nx = cx + dx, ny = cy + dy;
						if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
						final next = ny * w + nx;
						if (hot.get(next) != true) continue;
						hot.set(next, false);
						open.push(next);
					}
			}
			_haloSpots.push([sumX / count, sumY / count, Math.max(4, Math.max(right - left + 1, bottom - top + 1))]);
		}
		return out;
	}

	function _fireArt():BitmapData
	{
		final art = new BitmapData(24, 16, true, 0);
		for (py in 0...16)
			for (px in 0...24)
			{
				final level = Math.pow(px / 23, 1.7) * (0.3 + 0.7 * py / 15);
				final a = Math.round(level * 6) / 6;
				if (a > 0) art.setPixel32(px, py, FlxColor.fromRGBFloat(1, 0.42, 0.1, a));
			}
		return art;
	}

	function _pixel(sprite:FlxSprite, pivotX:Float, pivotY:Float):Void
	{
		sprite.antialiasing = false;
		sprite.moves = false;
		sprite.scale.set(6, 6);
		sprite.updateHitbox();
		sprite.origin.set(pivotX, pivotY);
		sprite.offset.set(0, 0);
		sprite.visible = false;
	}

	function _screen(sprite:FlxSprite, overlay:FlxCamera):FlxSprite
	{
		sprite.cameras = [overlay];
		sprite.scrollFactor.set(0, 0);
		sprite.antialiasing = false;
		sprite.moves = false;
		_state.add(sprite);
		return sprite;
	}
}
