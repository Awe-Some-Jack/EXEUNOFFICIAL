package minigames.thevalley.cutscenes;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import minigames.Camera;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.character.player.ValleyInput;
import minigames.thevalley.map.BGValley;

enum IntroPhase
{
	TitleIn;
	TitleHold;
	Reveal;
	Admire;
	Descend;
	Trapped;
	Escaping;
	Freed;
	Confused;
	Settle;
	Skipping;
	Done;
}

class IntroCutscene
{
	static final FALL_BOTTOMS:Array<Float> = [55, 55, 55, 55, 55, 54, 56, 57, 62, 68];

	public static var quickStart:Bool = false;

	public var onDone:Void->Void;
	public var musicMix(default, null):Float = 0;

	final _camera:Camera;
	final _player:Player;
	final _bg:BGValley;
	final _eButton:FlxSprite;
	final _state:FlxState;
	final _dimmer:FlxSprite;
	final _flash:FlxSprite;
	final _skipText:FlxText;
	final _title:FlxSprite;
	final _dirt:FlxSprite;
	final _meter:MashMeter;
	final _pressTimes:Array<Float> = [];

	var _phase:IntroPhase = TitleIn;
	var _timer:Float = 0;
	var _clock:Float = 0;
	var _progress:Float = 0;
	var _shown:Float = 0;
	var _heat:Float = 0;
	var _sincePress:Float = 99;
	var _beatTimer:Float = 0;
	var _stage:Int = 0;
	var _walkStart:Float = 0;
	var _baseOffsetY:Float = 0;
	var _directing:Bool = false;
	var _canSkip:Bool = false;
	var _skipShown:Float = 0;
	var _glancePan:Float = 0;
	var _musicStarted:Bool = false;
	var _mixFrom:Float = 0;
	var _mixTo:Float = 0;
	var _mixTime:Float = 0;
	var _mixLength:Float = 1;
	var _dirX:Float = 0;
	var _dirY:Float = 0;
	var _zoomFrom:Float = 0;
	var _zoomTo:Float = 0;
	var _zoomTime:Float = 0;
	var _zoomLength:Float = 1;
	var _skyY:Float = 0;
	var _savedButtonScale:Float = 1.0;

	public function new(state:flixel.FlxState, camera:Camera, uiCam:FlxCamera, player:Player, eButton:FlxSprite, bg:BGValley)
	{
		_state = state;
		_camera = camera;
		_player = player;
		_bg = bg;
		_eButton = eButton;
		_savedButtonScale = eButton.scale.x;

		final world = eButton.camera;
		_dimmer = _screen(state, uiCam, FlxColor.BLACK);
		_dimmer.alpha = 1;

		_title = _art(state, uiCam, "thevalley", 194.0);
		_dirt = _art(state, uiCam, "dirt", 276.0);

		_meter = new MashMeter(state, uiCam, world);

		_flash = _screen(state, uiCam, FlxColor.WHITE);
		_flash.alpha = 0;

		_skipText = new FlxText(0, FlxG.height - 44, FlxG.width - 24, Language.getPhrase("valley_skip_cutscene", "PRESS SPACE TO SKIP CUTSCENE"), 20);
		final skipFont = Language.getPhrase("valley_subtitle_font", "");
		_skipText.font = skipFont.length > 0 ? Paths.font(skipFont) : "assets/fonts/SonicFont.ttf";
		_skipText.alignment = FlxTextAlign.RIGHT;
		_skipText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 2);
		_skipText.alpha = 0;
		_skipText.visible = false;
		_ui(state, uiCam, _skipText);
	}

	static function _screen(state:flixel.FlxState, uiCam:FlxCamera, color:FlxColor):FlxSprite
	{
		final spr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, color);
		_ui(state, uiCam, spr);
		return spr;
	}

	static function _art(state:flixel.FlxState, uiCam:FlxCamera, name:String, y:Float):FlxSprite
	{
		final spr = new FlxSprite(0, y, Paths.image('minigame/thevalley/bg/title/$name'));
		spr.scale.set(3.2, 3.2);
		spr.updateHitbox();
		spr.visible = false;
		_ui(state, uiCam, spr);
		return spr;
	}

	static function _ui(state:flixel.FlxState, uiCam:FlxCamera, spr:flixel.FlxObject):Void
	{
		spr.scrollFactor.set(0, 0);
		spr.cameras = [uiCam];
		state.add(spr);
	}

	public function trigger():Void
	{
		if (quickStart)
		{
			quickStart = false;
			_quick(false);
			return;
		}
		_canSkip = FlxG.save.data.tvIntroSeen == true;
		_setPhase(TitleIn);
		_dimmer.alpha = 1;
		_title.visible = _dirt.visible = true;
		_title.alpha = _dirt.alpha = 1;
		_title.x = -_title.width;
		_dirt.x = FlxG.width;

		_skyY = _eButton.camera.height * 0.5 - BGValley.ECLIPSE_DISK_Y;
		_bg.skyOffset(0, Math.min(_skyY, _skyRoom(6.6)));
		_camera.lookAt(146.0, -216.0, 6.6);

		_player.cinematic = true;
		_player.mode = minigames.thevalley.character.player.Player.PlayerMode.Ground;
		_player.wingOpenTimer = 0;
		_player.glideCooldown = 0;
		_player.body.position.setxy(146.0 + _player.width * 0.5, 153.0 + _player.height * 0.5);
		_player.body.velocity.setxy(0, 0);
		_baseOffsetY = _player.cfg.hitbox.offsetY;
		_player.offset.y = _baseOffsetY;
		_lock("break_idle");

		_eButton.alpha = 0;
		_progress = _shown = _heat = 0;
		_stage = 0;
		_pressTimes.resize(0);

		FlxG.sound.playMusic(Paths.music("minigame/thevalley/ambient"), 1, true);
		musicMix = 0;
		_fadeMusic(1, 4.5);
	}

	public function update(elapsed:Float):Void
	{
		_timer += elapsed;
		_clock += elapsed;
		final tied = _phase != Escaping && _phase != Freed && _phase != Confused && _phase != Settle && _phase != Done;
		if (tied) _player.body.velocity.setxy(0, 0);

		final skippable = _canSkip && _phase != Settle && _phase != Skipping && _phase != Done;
		if (skippable && ValleyInput.skip())
		{
			_fadeMusic(0, 0.4);
			_setPhase(Skipping);
		}
		_skipShown = skippable && _phase != Skipping ? Math.min(1, _skipShown + elapsed) : Math.max(0, _skipShown - elapsed * 4);
		_skipText.visible = _skipShown > 0;
		_skipText.alpha = _skipShown * (0.6 + 0.2 * Math.sin(_clock * 3));

		switch (_phase)
		{
			case TitleIn:
				final t = FlxEase.quartOut(Math.min(1, _timer / 1.8));
				_title.x = -_title.width + (FlxG.width * 0.5 - 254.0 + _title.width) * t;
				_dirt.x = FlxG.width + (FlxG.width * 0.5 - 274.0 - FlxG.width) * t;
				if (_timer >= 1.8) _setPhase(TitleHold);

			case TitleHold:
				if (_timer >= 3.2) _setPhase(Reveal);

			case Reveal:
				final t = Math.min(1, _timer / 3.8);
				_title.alpha = _dirt.alpha = 1 - Math.min(1, t * 2);
				final out = FlxEase.sineIn(Math.min(1, t * 2));
				_title.x = FlxG.width * 0.5 - 254.0 - 220.0 * out;
				_dirt.x = FlxG.width * 0.5 - 274.0 + 220.0 * out;
				_dimmer.alpha = 1 - FlxEase.sineInOut(t);
				if (_timer >= 3.8)
				{
					_title.visible = _dirt.visible = false;
					_dimmer.alpha = 0;
					_setPhase(Admire);
				}

			case Admire:
				if (_timer >= 2.8)
				{
					_setPhase(Descend);
					_camera.lookAt(143.5, 162.5, 3.7, 9.0, FlxEase.smootherStepInOut, true);
				}

			case Descend:
				final e = 1 - FlxEase.smootherStepInOut(Math.min(1, _timer / 9.0));
				_bg.skyOffset(0, Math.min(_skyY * e, _skyRoom(_camera.zoom)));
				if (_timer >= 9.0) _startTrapped();

			case Trapped:
				_updateTrapped(elapsed);

			case Escaping:
				_player.body.velocity.x = 0;
				final anim = _player.animation.curAnim;
				if (anim != null && anim.name == "break_full" && anim.finished)
				{
					_setPhase(Freed);
					_walkStart = -1;
					_lock("idle");
					_direct(_camera.baseZoom + 0.6, 1.2 + 0.5);
				}

			case Freed:
				_player.body.velocity.x = 0;
				if (_timer < 1.2) {}
				else if (_walkStart < 0)
				{
					_walkStart = _player.body.position.x;
					_lock("walk");
					_direct(_camera.baseZoom + 1.4, 4.5);
				}
				else
				{
					_player.body.position.x += 40.0 * elapsed;
					if (_player.body.position.x - _walkStart >= 52.0)
					{
						_setPhase(Confused);
						_lock("looking");
					}
				}

			case Confused:
				_player.body.velocity.x = 0;
				final anim = _player.animation.curAnim;
				final moved = _timer >= 2.0 && ValleyInput.movedJust();
				if (moved || (anim != null && anim.name == "looking" && anim.finished)) _finish();

			case Skipping:
				_dimmer.alpha = Math.max(_dimmer.alpha, Math.min(1, _timer / 0.4));
				if (_timer >= 0.4) _quick(true);

			case Settle:
				_player.body.velocity.x = 0;
				if (_timer >= 2.8)
				{
					_setPhase(Done);
					if (onDone != null) onDone();
				}

			case Done:
				_dimmer.alpha = Math.max(0, _dimmer.alpha - elapsed / 0.7);
				if (!_musicStarted && _timer >= 1.6)
				{
					_musicStarted = true;
					FlxG.sound.playMusic(Paths.music("minigame/thevalley/thevalley"), 1, true);
					_fadeMusic(1, 4.0);
				}
		}

		_mixTime += elapsed;
		musicMix = _mixFrom + (_mixTo - _mixFrom) * Math.min(1, _mixTime / _mixLength);

		final trapped = _phase == Trapped;
		_meter.update(elapsed, trapped ? _shown : 1, trapped ? _heat : 0, trapped && _sincePress > 0.45 && _progress > 0, trapped, 143.5, 186.0);
		if (_directing) _updateDirector(elapsed);
		_sink();
		_flash.alpha = Math.max(0, _flash.alpha - elapsed * 2.5);
	}

	function _skyRoom(zoom:Float):Float
	{
		final h = _eButton.camera.height;
		return Math.max(0, h * 0.5 - h * 0.5 / zoom - BGValley.SKY_TOP);
	}

	function _startTrapped():Void
	{
		_setPhase(Trapped);
		_bg.skyOffset(0, 0);
		_savedButtonScale = _eButton.scale.x;
		_eButton.scale.set(_savedButtonScale * 0.8, _savedButtonScale * 0.8);
		_eButton.updateHitbox();
		_beatTimer = 0.4;
		_eButton.animation.play("idle", true);
	}

	function _updateTrapped(elapsed:Float):Void
	{
		_sincePress += elapsed;
		while (_pressTimes.length > 0 && _clock - _pressTimes[0] > 0.75) _pressTimes.shift();
		final heatTarget = Math.min(1, _pressTimes.length / 0.75 / 8.0);
		_heat += (heatTarget - _heat) * (1.0 - Math.pow(0.01, elapsed * (heatTarget > _heat ? 8.0 : 3.0)));

		_progress = Math.max(0, _progress - (_sincePress > 0.45 ? 0.25 : 0.06) * elapsed);

		if (ValleyInput.interact()) _press();

		final cur = _player.animation.curAnim;
		if (_sincePress > 0.3 && cur != null && cur.name == "break_tap" && (cur.finished || cur.looped)) _lock("break_idle");

		_beatTimer -= elapsed;
		if (_beatTimer <= 0)
		{
			_beatTimer = 1.0 + (0.45 - 1.0) * Math.max(_progress, _heat * 0.6);
			FlxG.sound.play(Paths.sound("minigame/thevalley/heartbeat"), 0.25 + 0.35 * _progress);
		}

		_shown += (_progress - _shown) * (1.0 - Math.pow(0.001, elapsed * 2.5));

		_camera.lookAt(143.5, 162.5, 3.7 + _shown * 0.6, 0, null, true);

		_eButton.x = 143.5 - _eButton.width * 0.5;
		_eButton.y = 139.0 - _eButton.height - 6.0;
		_eButton.alpha += (0.4 - _eButton.alpha) * (1.0 - Math.pow(0.01, elapsed * 8.0));

		if (_progress >= 1.0) _breakFree();
	}

	function _press():Void
	{
		_sincePress = 0;
		_pressTimes.push(_clock);
		_progress = Math.min(1, _progress + 0.025 + 0.025 * _heat);

		final cur = _player.animation.curAnim;
		if (cur == null || cur.name != "break_tap" || cur.finished || cur.curFrame >= cur.numFrames - 2) _lock("break_tap");
		_eButton.animation.play("press", true);
		_meter.pulse();

		final rope = FlxG.sound.play(Paths.sound("minigame/thevalley/breakrope"), 0.22 + 0.15 * _heat);
		rope.pitch = 0.85 + 0.35 * _progress + FlxG.random.float(-0.05, 0.05);

		final stage = Std.int(_progress * 3);
		if (stage > _stage && stage < 3)
		{
			_stage = stage;
			_camera.shake(0.004, 0.25);
			_flash.alpha = 0.25;
			_meter.burst();
			FlxG.sound.play(Paths.sound("minigame/thevalley/ropesnap"), 0.2).pitch = 0.75;
		}
	}

	function _breakFree():Void
	{
		_setPhase(Escaping);
		_eButton.alpha = 0;
		_eButton.scale.set(_savedButtonScale, _savedButtonScale);
		_eButton.updateHitbox();
		_lock("break_full");
		_meter.burst();
		FlxG.sound.play(Paths.sound("minigame/thevalley/ropesnap"), 0.45);
		_camera.shake(0.006, 0.35);
		_flash.alpha = 0.7;
		_camera.lookAt(143.5 + 4, 162.5 + 10, 3.7 + 0.6 + 0.9, 0.35, FlxEase.expoOut, true);
	}

	function _finish():Void
	{
		_setPhase(Settle);
		FlxG.save.data.tvIntroSeen = true;
		FlxG.save.flush();
		_player.lockedAnim = null;
		_player.animation.play("idle", true);
		_directing = false;
		_camera.followTarget(2.8);
		_fadeMusic(0, 2.8);

		final tv = Std.downcast(_state, minigames.thevalley.TheValley);
		if (tv != null)
		{
			for (m in tv.monsters)
				m.forgetHunt();
		}
	}

	function _quick(skipped:Bool):Void
	{
		if (!skipped) _dimmer.alpha = 0;
		_title.visible = _dirt.visible = false;
		_flash.alpha = 0;
		_eButton.alpha = 0;
		_eButton.scale.set(_savedButtonScale, _savedButtonScale);
		_eButton.updateHitbox();
		_bg.skyOffset(0, 0);
		_directing = false;
		_player.mode = minigames.thevalley.character.player.Player.PlayerMode.Ground;
		_player.body.position.setxy(146.0 + _player.width * 0.5 + 52.0, 153.0 + _player.height * 0.5);
		_player.body.velocity.setxy(0, 0);
		_baseOffsetY = _player.cfg.hitbox.offsetY;
		_player.offset.y = _baseOffsetY;
		_player.lockedAnim = null;
		_player.animation.play("idle", true);
		_camera.followTarget();
		_camera.cut();
		FlxG.sound.playMusic(Paths.music("minigame/thevalley/thevalley"), 1, true);
		musicMix = 1;
		_fadeMusic(1, 0.01);
		_musicStarted = true;
		_setPhase(Done);
		if (onDone != null) onDone();
	}

	function _fadeMusic(to:Float, time:Float):Void
	{
		_mixFrom = musicMix;
		_mixTo = to;
		_mixTime = 0;
		_mixLength = time;
	}

	function _glance():Float
	{
		final anim = _player.animation.curAnim;
		if (_phase != Confused || anim == null || anim.name != "looking") return 0;
		final side = _player.flipX ? -1.0 : 1.0;
		final at = anim.curFrame;
		if (at >= 10 && at < 22) return -18.0 * side;
		if (at >= 22 && at < 34) return 18.0 * side;
		if (at >= 34 && at < 47) return 18.0 * 0.6 * side;
		return 0;
	}

	function _direct(zoom:Float, time:Float):Void
	{
		if (!_directing)
		{
			_directing = true;
			_dirX = _camera.x;
			_dirY = _camera.y;
		}
		_zoomFrom = _camera.zoom;
		_zoomTo = zoom;
		_zoomTime = 0;
		_zoomLength = time;
	}

	function _updateDirector(elapsed:Float):Void
	{
		_zoomTime += elapsed;
		final zoom = _zoomFrom + (_zoomTo - _zoomFrom) * FlxEase.sineInOut(Math.min(1, _zoomTime / _zoomLength));
		final follow = 1.0 - Math.pow(0.01, elapsed * 2.0);
		_glancePan += (_glance() - _glancePan) * (1.0 - Math.pow(0.01, elapsed * 1.6));
		_dirX += (_playerX() + _glancePan - _dirX) * follow;
		_dirY += (_playerY() - 5.0 - _dirY) * follow;
		_camera.lookAt(_dirX, _dirY, zoom, 0, null, true);
	}

	function _sink():Void
	{
		var drop = 0.0;

		final anim = _player.animation.curAnim;
		if (anim != null && (anim.name == "break_idle" || anim.name == "break_tap")) 
			drop = 13.0;
		else if (anim != null && anim.name == "break_full" && anim.curFrame < FALL_BOTTOMS.length)
			drop = 13.0 * Math.min(1, (73.0 - FALL_BOTTOMS[anim.curFrame]) / 18.0);

		_player.offset.y = _baseOffsetY - Math.round(drop);
	}

	inline function _setPhase(p:IntroPhase):Void
	{
		_phase = p;
		_timer = 0;
	}

	inline function _lock(name:String):Void
	{
		_player.lockedAnim = name;
		_player.animation.play(name, true);
	}

	inline function _playerX():Float return _player.x + _player.width * 0.5;

	inline function _playerY():Float return _player.y + _player.height * 0.5;
}

class MashMeter
{
	final _world:FlxCamera;
	final _glow:FlxSprite;
	final _frame:FlxSprite;
	final _segments:Array<FlxSprite> = [];
	final _flashes:Array<Float> = [];

	var _shown:Float = 0;
	var _t:Float = 0;
	var _bump:Float = 0;
	var _lit:Int = 0;

	public function new(state:FlxState, ui:FlxCamera, world:FlxCamera)
	{
		_world = world;
		_glow = _add(state, ui, new FlxSprite().loadGraphic(_img("glow")));
		_frame = _add(state, ui, new FlxSprite().loadGraphic(_img("bar")));
		for (i in 0...12)
		{
			final seg = _add(state, ui, new FlxSprite().loadGraphic(_img("segments"), true, 3, 5));
			seg.animation.frameIndex = i;
			_segments.push(seg);
			_flashes.push(0);
		}
	}

	static inline function _img(name:String) return Paths.image('minigame/thevalley/hud/mash/$name');

	static function _add(state:FlxState, ui:FlxCamera, spr:FlxSprite):FlxSprite
	{
		spr.cameras = [ui];
		spr.scrollFactor.set(0, 0);
		spr.antialiasing = false;
		spr.origin.set(0, 0);
		spr.scale.set(3, 3);
		spr.active = false;
		spr.visible = false;
		state.add(spr);
		return spr;
	}

	public function update(elapsed:Float, progress:Float, heat:Float, draining:Bool, active:Bool, worldX:Float, worldY:Float):Void
	{
		_t += elapsed;
		_shown = active ? Math.min(1, _shown + elapsed / 0.25) : Math.max(0, _shown - elapsed / 0.35);
		final on = _shown > 0;
		_glow.visible = _frame.visible = on;
		if (!on)
		{
			for (s in _segments) s.visible = false;
			return;
		}

		final ease = 1 - Math.pow(1 - _shown, 3);
		final sx = _world.x + (worldX - _world.viewLeft) * _world.zoom;
		final sy = _world.y + (worldY - _world.viewTop) * _world.zoom;
		_bump = Math.max(0, _bump - elapsed * 5);
		final shake = 3 * (heat * 0.5 + _bump * 0.5);
		final left = Math.round(Math.max(8.0, Math.min(FlxG.width - 51 * 3 - 8.0, sx - 51 * 3 * 0.5)) + FlxG.random.float(-shake, shake));
		final top = Math.round(Math.max(8.0, Math.min(FlxG.height - 9 * 3 - 8.0, sy + 16.0 + (1 - ease) * 20)) + FlxG.random.float(-shake, shake) * 0.5);

		_frame.setPosition(left, top);
		_frame.alpha = ease;

		_glow.setPosition(left - 2 * 3, top - 2 * 3);
		_glow.color = 0xFF8A6A48;
		_glow.alpha = ease * heat * (0.18 + 0.05 * Math.sin(_t * 12));

		final fill = Math.max(0, Math.min(1, progress)) * 12;
		final lit = Std.int(fill + 0.001);
		if (lit > _lit) for (i in _lit...lit) _flashes[i] = 1;
		_lit = lit;

		for (i in 0...12)
		{
			final seg = _segments[i];
			_flashes[i] = Math.max(0, _flashes[i] - elapsed * 4);
			final partial = i == lit ? fill - lit : 0;
			seg.visible = i < lit || partial > 0.05;
			if (!seg.visible) continue;

			seg.setPosition(left + (2 + i * 4) * 3, top + 2 * 3);
			final dim = draining && i == lit - 1 ? 0.45 + 0.35 * Math.sin(_t * 18) : 0.0;
			final flash = Std.int(80 * _flashes[i]);
			seg.setColorTransform(1 - dim, 1 - dim, 1 - dim, 1, flash, flash, flash, 0);
			seg.alpha = ease * (i < lit ? 1 : partial * (0.55 + 0.25 * Math.sin(_t * 25)));
		}
	}

	public function pulse():Void
	{
		_bump = Math.max(_bump, 1);
	}

	public function burst():Void
	{
		_bump = 2;
		for (i in 0..._lit) _flashes[i] = 1;
	}
}
