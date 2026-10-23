package minigames.thevalley.cutscenes;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;

// skull searching shi
class CSSkull
{
	static var LINE_VARIANTS:Array<Array<String>> = [
		["I have to wake up BF but how?",         "I guess i'll have to find the other parts..."]
	];

	public var playing:Bool    = false;
	public var onDone:Void->Void;

	var _state:flixel.FlxState;
	var _uiCam:FlxCamera;

	var _timer:Float        = 0;
	var _fadeOut:Bool       = false;
	var _voiceDone:Bool     = false;
	var _afterTimer:Float   = 0;
	var _fadeOutStart:Float = -1.0;
	var _lastVoiceTime:Float = 0;
	var _voice:flixel.sound.FlxSound;
	var _lineVariant:Int = 0;
	var _lineShown:Int = -1;

	var _dimmer:FlxSprite;
	var _ball:FlxSprite;
	var _hand:FlxSprite;
	var _subs:Subtitles;

	public function new(state:flixel.FlxState, uiCam:FlxCamera)
	{
		_state  = state;
		_uiCam  = uiCam;
	}

	public function addSprites():Void
	{
		_dimmer = new FlxSprite(0, 0);
		_dimmer.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		_dimmer.alpha = 0;
		_dimmer.scrollFactor.set(0, 0);
		_dimmer.cameras = [_uiCam];
		_state.add(_dimmer);

		_hand = new FlxSprite(0, 0);
		_hand.loadGraphic(Paths.image("minigame/thevalley/bg/cutscene/CSkull/gfhand"));
		_hand.scale.set(1.7, 1.7);
		_hand.updateHitbox();
		_hand.scrollFactor.set(0, 0);
		_hand.cameras = [_uiCam];
		_hand.alpha = 0;
		_state.add(_hand);

		_ball = new FlxSprite(0, 0);
		_ball.loadGraphic(Paths.image("minigame/thevalley/bg/cutscene/CSkull/gfball"));
		_ball.scale.set(2.7, 2.7);
		_ball.updateHitbox();
		_ball.scrollFactor.set(0, 0);
		_ball.cameras = [_uiCam];
		_ball.alpha = 0;
		_state.add(_ball);

		_subs = new Subtitles(_state, _uiCam);
	}

	public function trigger():Void
	{
		playing        = true;
		_timer         = 0;
		_fadeOut       = false;
		_voiceDone     = false;
		_afterTimer    = 0;
		_fadeOutStart  = -1.0;
		_voice         = null;
		_lastVoiceTime = 0;
		_lineVariant   = Std.random(LINE_VARIANTS.length);
		_lineShown     = -1;
		_subs.clear();
		_ball.x  = -_ball.width;
		_ball.y  = FlxG.height - _ball.height;
		_hand.x  = (FlxG.width - _hand.width) * 0.5 + 110;
		_hand.y  = FlxG.height;
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(1.0, 0.3);
	}

	public function update(elapsed:Float):Void
	{
		if (!playing) return;
		_timer += elapsed;

		var slideT = Math.min(_timer / 1.2, 1.0);
		slideT = 1.0 - (1.0 - slideT) * (1.0 - slideT);

		_ball.x = _lerp(-_ball.width, 0.0, slideT);
		_ball.y = FlxG.height - _ball.height;

		var handTargetY = FlxG.height - _hand.height;
		_hand.x = (FlxG.width - _hand.width) * 0.5 + 110;
		_hand.y = _lerp(FlxG.height, handTargetY, slideT);

		var fadeInAlpha = Math.min(_timer / 1.2, 1.0);
		if (!_fadeOut)
		{
			_dimmer.alpha = 0.20 * fadeInAlpha;
			_ball.alpha   = fadeInAlpha;
			_hand.alpha   = fadeInAlpha;
		}

		if (_timer >= 1.2 && _voice == null)
		{
			_voice = FlxG.sound.play("assets/shared/sounds/minigame/thevalley/voiceline.ogg", 1.0);
			_subs.open();
		}

		if (_voice != null && !_voiceDone && !_fadeOut)
		{
			if (_voice.playing)
				_lastVoiceTime = _voice.time / 1000.0;
			final line = _lastVoiceTime < 5.088 ? 0 : 1;
			if (line != _lineShown)
			{
				_lineShown = line;
				_subs.say(Language.getPhrase('valley_skull_${line + 1}', LINE_VARIANTS[_lineVariant][line]));
			}
		}

		if (_voice != null && !_voiceDone && !_voice.playing)
		{
			_voiceDone  = true;
			_afterTimer = 0;
		}

		if (_voiceDone && !_fadeOut)
		{
			_afterTimer += elapsed;
			if (_afterTimer >= 1.0) _fadeOut = true;
		}

		if (_fadeOut)
		{
			if (_fadeOutStart < 0)
			{
				_fadeOutStart = _timer;
				_subs.close(0.8);
			}
			var fadeT = Math.min((_timer - _fadeOutStart) / 0.8, 1.0);
			var eased = 0.5 - Math.cos(fadeT * Math.PI) * 0.5;

			_ball.x = _lerp(0, -_ball.width - 20, eased);
			_hand.y = _lerp(FlxG.height - _hand.height, FlxG.height + _hand.height + 20, eased);
			_dimmer.alpha = 0.20 + (0.55 - 0.20) * fadeT;

			if (fadeT >= 1.0)
			{
				playing       = false;
				_ball.alpha   = 0;
				_hand.alpha   = 0;
				_dimmer.alpha = 0;
				if (FlxG.sound.music != null)
					FlxG.sound.music.fadeIn(1.5, 0.0, 1.0);
				if (onDone != null) onDone();
			}
		}

		_subs.update(elapsed);
	}

	inline function _lerp(a:Float, b:Float, t:Float):Float return a + (b - a) * t;
}