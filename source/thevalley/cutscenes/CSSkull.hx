package thevalley.cutscenes;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;

// skull searching shi
class CSSkull
{
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

	var _dimmer:FlxSprite;
	var _ball:FlxSprite;
	var _hand:FlxSprite;
	var _subBar:FlxSprite;
	var _subTxt:FlxText;

	public function new(state:flixel.FlxState, uiCam:FlxCamera)
	{
		_state  = state;
		_uiCam  = uiCam;
	}

	public function addSprites():Void
	{
		_dimmer = new FlxSprite(0, 0);
		_dimmer.makeGraphic(1280, 896, 0xFF000000);
		_dimmer.alpha = 0;
		_dimmer.scrollFactor.set(0, 0);
		_dimmer.cameras = [_uiCam];
		_state.add(_dimmer);

		_hand = new FlxSprite(0, 0);
		_hand.loadGraphic("assets/shared/images/minigame/thevalley/bg/cutscene/CSkull/gfhand.png");
		_hand.scale.set(2.0, 2.0);
		_hand.updateHitbox();
		_hand.scrollFactor.set(0, 0);
		_hand.cameras = [_uiCam];
		_hand.alpha = 0;
		_state.add(_hand);

		_ball = new FlxSprite(0, 0);
		_ball.loadGraphic("assets/shared/images/minigame/thevalley/bg/cutscene/CSkull/gfball.png");
		_ball.scale.set(3.2, 3.2);
		_ball.updateHitbox();
		_ball.scrollFactor.set(0, 0);
		_ball.cameras = [_uiCam];
		_ball.alpha = 0;
		_state.add(_ball);

		var barH = 54;
		_subBar = new FlxSprite(0, 896);
		_subBar.makeGraphic(1280, barH, 0xFF000000);
		_subBar.scrollFactor.set(0, 0);
		_subBar.cameras = [_uiCam];
		_subBar.alpha = 0.82;
		_state.add(_subBar);

		_subTxt = new FlxText(0, 0, 1280, "", 18);
		_subTxt.font = "assets/fonts/timer.otf";
		_subTxt.color = FlxColor.WHITE;
		_subTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_subTxt.alignment = flixel.text.FlxText.FlxTextAlign.CENTER;
		_subTxt.scrollFactor.set(0, 0);
		_subTxt.cameras = [_uiCam];
		_subTxt.visible = false;
		_state.add(_subTxt);
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
		_subBar.y      = 896;
		_subTxt.visible = false;
		_ball.x  = -_ball.width;
		_ball.y  = 896 - _ball.height;
		_hand.x  = (1280 - _hand.width) * 0.5 + 110;
		_hand.y  = 896;
		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(1.0, 0.3);
	}

	public function update(elapsed:Float):Void
	{
		if (!playing) return;
		_timer += elapsed;

		var slideT = Math.min(_timer / 1.2, 1.0);
		slideT = 1.0 - (1.0 - slideT) * (1.0 - slideT); // ease out so it slams in fast then chills at the end, ithink its way less stiff than linear

		_ball.x = _lerp(-_ball.width, 0.0, slideT);
		_ball.y = 896 - _ball.height;

		var handTargetY = 896 - _hand.height;
		_hand.x = (1280 - _hand.width) * 0.5 + 110;
		_hand.y = _lerp(896.0, handTargetY, slideT);

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
			_subTxt.visible = true;
		}

		var barTargetY:Float = 896 - _subBar.height;
		if (_timer >= 1.2 && !_fadeOut)
		{
			var barT = Math.min((_timer - 1.2) / 0.25, 1.0);
			barT = 1.0 - (1.0 - barT) * (1.0 - barT);
			_subBar.y = _lerp(896.0, barTargetY, barT);
		}

		if (_voice != null && !_voiceDone && !_fadeOut)
		{
			if (_voice.playing)
				_lastVoiceTime = _voice.time / 1000.0;
			_subTxt.text = _lastVoiceTime < 5.088
				? "I have to wake up BF but how?"
				: "I guess i'll have to find the other parts...";
			_subTxt.y = _subBar.y + (_subBar.height - _subTxt.height) * 0.5;
		}

		if (_fadeOut)
		{
			var fadeT2 = (_fadeOutStart >= 0) ? Math.min((_timer - _fadeOutStart) / 0.8, 1.0) : 0.0;
			_subBar.y = _lerp(barTargetY, 896.0, fadeT2);
			_subTxt.y = _subBar.y + (_subBar.height - _subTxt.height) * 0.5;
			if (fadeT2 >= 1.0) _subTxt.visible = false;
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
			if (_fadeOutStart < 0) _fadeOutStart = _timer;
			var fadeT = Math.min((_timer - _fadeOutStart) / 0.8, 1.0);
			var eased = 0.5 - Math.cos(fadeT * Math.PI) * 0.5;

			_ball.x = _lerp(0, -_ball.width - 20, eased);
			_hand.y = _lerp(896 - _hand.height, 896 + _hand.height + 20, eased);
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
	}

	inline function _lerp(a:Float, b:Float, t:Float):Float return a + (b - a) * t;
}
