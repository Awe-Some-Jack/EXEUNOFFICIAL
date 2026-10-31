package minigames.thevalley.cutscenes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;

import openfl.filters.ShaderFilter;

import shaders.WiggleEffect;

enum GameOverPhase
{
	Idle;
	Titles;
	Falling;
	Body;
	Countdown;
	Dark;
	Silence;
	Jumpscare;
	AfterScare;
	End;
	Continue;
}

class GameOver
{
	public var active(get, never):Bool;
	inline function get_active() return _phase != Idle;

	public var onContinue:Void->Void;
	public var onQuit:Void->Void;

	final _state:FlxState;
	final _ui:FlxCamera;

	var _phase:GameOverPhase = Idle;
	var _timer:Float = 0;
	var _byExe:Bool = false;
	var _spikes:Bool = false;
	var _scares:Int = 0;

	var _song:FlxSound;
	var _breath:FlxSound;
	var _black:FlxSprite;
	var _fakerback:FlxSprite;
	var _game:FlxSprite;
	var _over:FlxSprite;
	var _body:FlxSprite;
	var _scare:FlxSprite;
	var _count:FlxText;
	var _grower:FlxSprite;
	var _growBase:Float = 1;
	var _wiggle:WiggleEffect;

	var _backX:Float = 0;
	var _backY:Float = 0;
	var _gameX:Float = 0;
	var _overX:Float = 0;
	var _fallGame:Float = 0;
	var _fallOver:Float = 0;
	var _value:Int = 15;
	var _tick:Float = 0;
	var _countTime:Float = 0;

	public function new(state:FlxState, ui:FlxCamera)
	{
		_state = state;
		_ui = ui;
	}

	public function start(byExe:Bool, spikes:Bool = false):Void
	{
		if (active) return;
		_byExe = byExe || spikes;
		_spikes = spikes;
		_scares = 0;
		_black = _add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
		if (byExe) _darkness();
		else _titles();
	}

	public function update(elapsed:Float):Void
	{
		if (!active) return;
		_timer += elapsed;
		final songTime = _song != null && _song.playing ? _song.time / 1000.0 : 0.0;

		if ((_phase == Titles || _phase == Falling || _phase == Body) && _timer >= 1.0 && Controls.instance.ACCEPT)
		{
			_retry();
			return;
		}

		switch (_phase)
		{
			case Titles:
				final t = _cubicOut(Math.min(1, _timer / 2.0));
				_game.x = _lerp(-_game.width, _gameX, t);
				_over.x = _lerp(FlxG.width, _overX, t);
				if (songTime >= 14.0) _setPhase(Falling);

			case Falling:
				_dropTitles(elapsed);
				final t = Math.min(1, _timer / 1.8);
				_fakerback.alpha = t * t * (3 - 2 * t);
				_jitter(0);
				if (songTime >= 17.0) _startCountdown();

			case Body:
				_wiggle.update(elapsed);
				final t = _timer - 0.6;
				if (t > 0)
				{
					_game.visible = _over.visible = true;
					_game.x = _lerp(FlxG.width, _gameX, _cubicOut(Math.min(1, t / 1.8)));
					_over.x = _lerp(FlxG.width, _overX, _cubicOut(Math.min(1, t / 2.6)));
				}
				if (songTime >= 17.0) _startCountdown();

			case Countdown:
				_updateCountdown(elapsed);

			case Dark:
				if (_breath != null) _breath.volume = Math.min(0.9, _timer / 0.5 * 0.9);
				if (_timer >= 2.0) _jumpscare();

			case Silence:
				if (_timer >= 1.5) _jumpscare();

			case Jumpscare:
				if (_scare.animation.finished) _setPhase(AfterScare);

			case AfterScare:
				if (_timer < 1.0) return;
				_scare.visible = false;
				if (_byExe && _scares == 1) _showBody();
				else _setPhase(End);

			case End:
				if (_timer >= 0.6)
				{
					_setPhase(Idle);
					if (onQuit != null) onQuit();
				}

			case Continue:
				_black.alpha = Math.min(1, _timer / 0.8);
				if (_song != null) _song.volume = 1 - _black.alpha;
				if (_timer >= 0.8)
				{
					_setPhase(Idle);
					if (onContinue != null) onContinue();
				}

			case Idle:
		}
	}

	function _titles():Void
	{
		_fakerback = _add(new FlxSprite().loadGraphic(_img("fakerback")), 4.5);
		_fakerback.alpha = 0;
		_backX = (FlxG.width - _fakerback.width) * 0.5;
		_backY = (FlxG.height - _fakerback.height) * 0.5 + 40;
		_fakerback.setPosition(_backX, _backY);
		_grower = _fakerback;
		_growBase = 4.5;

		_makeTitles(5.0);
		final gap = 12.0;
		final top = (FlxG.height - (_game.height + gap + _over.height)) * 0.5 - 30;
		_gameX = (FlxG.width - _game.width) * 0.5;
		_overX = (FlxG.width - _over.width) * 0.5;
		_game.setPosition(-_game.width, top);
		_over.setPosition(FlxG.width, top + _game.height + gap);

		_makeCountdown();
		_playSong(8.0);
		_setPhase(Titles);
	}

	function _darkness():Void
	{
		_breath = FlxG.sound.play(Paths.sound("minigame/thevalley/EXE/breathing"), 0, true);
		_setPhase(Dark);
	}

	function _showBody():Void
	{
		_body = new FlxSprite();
		if (_spikes)
		{
			_body.loadGraphic(_img("gameoverspike"));
			_growBase = 0.8;
		}
		else
		{
			_body.frames = Paths.getSparrowAtlas("minigame/thevalley/gameover/imdead");
			_body.animation.addByPrefix("dead", "imdead dead", 4, false);
			_body.animation.play("dead", true);
			_growBase = 1.5;
		}
		_add(_body, _growBase);
		_body.setPosition((FlxG.width - _body.width) * 0.5, (FlxG.height - _body.height) * 0.5);
		_grower = _body;

		_makeTitles(3.0);
		final gap = 12.0;
		final col = Math.max(_game.width, _over.width);
		final right = FlxG.width - col - 40;
		final top = (FlxG.height - (_game.height + gap + _over.height)) * 0.5;
		_gameX = right + (col - _game.width) * 0.5;
		_overX = right + (col - _over.width) * 0.5;
		_game.setPosition(FlxG.width, top);
		_over.setPosition(FlxG.width, top + _game.height + gap);
		_game.visible = _over.visible = false;

		_makeCountdown();
		_wiggle = new WiggleEffect();
		_wiggle.effectType = DREAMY;
		_wiggle.waveSpeed = 0.6;
		_wiggle.waveFrequency = 3.0;
		_wiggle.waveAmplitude = 0.006;
		_ui.filters = [new ShaderFilter(_wiggle.shader)];

		_playSong(13.0);
		_setPhase(Body);
	}

	function _startCountdown():Void
	{
		_value = 15;
		_tick = 0;
		_countTime = 0;
		_count.visible = true;
		_setPhase(Countdown);
	}

	function _updateCountdown(elapsed:Float):Void
	{
		_countTime += elapsed;
		if (_wiggle != null) _wiggle.update(elapsed);
		if (_fakerback != null && _fakerback.visible)
		{
			_dropTitles(elapsed);
			_jitter(1 - _value / 15);
		}

		_count.y = _lerp(-80, 40, _cubicOut(Math.min(1, _countTime / 1.2)));
		_tick += elapsed;
		if (_tick >= 1.0)
		{
			_tick -= 1.0;
			_value = Std.int(Math.max(0, _value - 1));
		}
		_count.text = Std.string(_value);
		_count.color = FlxColor.interpolate(FlxColor.WHITE, FlxColor.RED, 1 - _value / 15);
		if (_grower != null)
		{
			final grow = _growBase * (1 + 0.2 * Math.min(1, _countTime / 15));
			_grower.scale.set(grow, grow);
		}

		if (Controls.instance.ACCEPT)
		{
			_retry();
			return;
		}

		if (_value <= 0 || (_song != null && !_song.playing))
		{
			if (_byExe)
			{
				FlxG.save.flush();
				#if sys
				Sys.exit(0);
				#end
				return;
			}
			_clearScreen();
			_setPhase(Silence);
		}
	}

	function _retry():Void
	{
		_black.alpha = 0;
		_black.visible = true;
		_state.remove(_black, true);
		_state.add(_black);
		_setPhase(Continue);
	}

	function _jumpscare():Void
	{
		if (_breath != null)
		{
			_breath.stop();
			_breath = null;
		}
		_scares++;
		if (_scare == null)
		{
			_scare = new FlxSprite();
			_scare.frames = Paths.getSparrowAtlas("minigame/thevalley/gameover/jumpscare");
			_scare.animation.addByPrefix("play", "jumpscare jumpscare", 14, false);
			_add(_scare, 2.0);
			_scare.setPosition((FlxG.width - _scare.width) * 0.5, (FlxG.height - _scare.height) * 0.5);
		}
		_state.remove(_scare, true);
		_state.add(_scare);
		_scare.visible = true;
		_scare.animation.play("play", true);
		FlxG.sound.play(Paths.sound("minigame/thevalley/jumpscare"), 1.0);
		_setPhase(Jumpscare);
	}

	function _dropTitles(elapsed:Float):Void
	{
		_fallGame += 220 * elapsed;
		_fallOver += 220 * elapsed;
		_game.y += _fallGame * elapsed;
		_over.y += _fallOver * elapsed;
		_game.angle += 30 * elapsed;
		_over.angle -= 25 * elapsed;
	}

	function _jitter(intensity:Float):Void
	{
		final amp = 0.6 + 0.72 * intensity;
		_fakerback.x = _backX + FlxG.random.float(-amp, amp);
		_fakerback.y = _backY + FlxG.random.float(-amp, amp);
	}

	function _clearScreen():Void
	{
		for (spr in [_fakerback, _game, _over, _body]) if (spr != null) spr.visible = false;
		_count.visible = false;
		_ui.filters = null;
		_wiggle = null;
		if (_song != null) _song.stop();
	}

	function _makeTitles(scale:Float):Void
	{
		_fallGame = _fallOver = 0;
		_game = _add(new FlxSprite().loadGraphic(_img("game")), scale);
		_over = _add(new FlxSprite().loadGraphic(_img("over")), scale);
	}

	function _makeCountdown():Void
	{
		_count = new FlxText(0, -80, FlxG.width, Std.string(15), 64);
		_count.font = "assets/fonts/SonicFont.ttf";
		_count.alignment = FlxTextAlign.CENTER;
		_count.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_add(_count);
		_count.visible = false;
	}

	function _playSong(from:Float):Void
	{
		if (_song != null) _song.stop();
		_song = FlxG.sound.play(Paths.sound("minigame/thevalley/oversong"), 1.0, false, null, false);
		_song.time = from * 1000;
	}

	function _add<T:FlxSprite>(spr:T, scale:Float = 1.0):T
	{
		spr.antialiasing = false;
		if (scale != 1.0)
		{
			spr.scale.set(scale, scale);
			spr.updateHitbox();
		}
		spr.scrollFactor.set(0, 0);
		spr.cameras = [_ui];
		_state.add(spr);
		return spr;
	}

	inline function _setPhase(p:GameOverPhase):Void
	{
		_phase = p;
		_timer = 0;
	}

	static inline function _img(name:String) return Paths.image('minigame/thevalley/gameover/$name');

	static inline function _lerp(a:Float, b:Float, t:Float):Float return a + (b - a) * t;

	static inline function _cubicOut(t:Float):Float return 1 - Math.pow(1 - t, 3);
}
