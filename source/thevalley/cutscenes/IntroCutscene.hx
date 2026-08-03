package thevalley.cutscenes;

import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxSprite;
import flixel.FlxG;
import thevalley.player.Player;

enum IntroPhase
{
	FadeHold;
	PanZoom;
	Trapped;
	Escaping;
	TitleCard;
}

class IntroCutscene
{
	public var onDone:Void->Void;

	var _state:flixel.FlxState;
	var _bgCam:FlxCamera;
	var _player:Player;
	var _eButton:FlxSprite;
	var _dimmer:FlxSprite;
	var _title:FlxSprite;
	var _dirt:FlxSprite;

	var _phase:IntroPhase = FadeHold;
	var _timer:Float      = 0;

	var _musicStarted:Bool = false;
	var _donePlayed:Bool   = false;
	var _cardHoldTimer:Float = -1.0;

	var _panFromX:Float    = 0;
	var _panFromY:Float    = 0;
	var _panFromZoom:Float = 0;

	var _pressTimes:Array<Float> = [];
	var _progress:Float = 0;
	var _tapTimer:Float = 0;
	var _savedButtonScale:Float = 1.0;

	var _savedMinX:Null<Float>;
	var _savedMaxX:Null<Float>;
	var _savedMinY:Null<Float>;
	var _savedMaxY:Null<Float>;

	public function new(state:flixel.FlxState, bgCam:FlxCamera, uiCam:FlxCamera, player:Player, eButton:FlxSprite)
	{
		_state   = state;
		_bgCam   = bgCam;
		_player  = player;
		_eButton = eButton;

		_dimmer = new FlxSprite(0, 0);
		_dimmer.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		_dimmer.alpha = 1.0;
		_dimmer.scrollFactor.set(0, 0);
		_dimmer.cameras = [uiCam];
		state.add(_dimmer);

		_title = new FlxSprite(0, 0);
		_title.loadGraphic(Paths.image("minigame/thevalley/bg/title/thevalley"));
		_title.scrollFactor.set(0, 0);
		_title.cameras = [uiCam];
		_title.scale.set(3.2, 3.2);
		_title.updateHitbox();
		_title.y = 194.0;
		_title.x = -_title.width;
		_title.visible = false;
		state.add(_title);

		_dirt = new FlxSprite(0, 0);
		_dirt.loadGraphic(Paths.image("minigame/thevalley/bg/title/dirt"));
		_dirt.scrollFactor.set(0, 0);
		_dirt.cameras = [uiCam];
		_dirt.scale.set(3.2, 3.2);
		_dirt.updateHitbox();
		_dirt.y = 276.0;
		_dirt.x = FlxG.width;
		_dirt.visible = false;
		state.add(_dirt);
	}

	public function trigger():Void
	{
		_phase = FadeHold;
		_timer = 0;
		_dimmer.alpha = 1.0;
		_musicStarted = false;
		_donePlayed   = false;

		_bgCam.target = null;

		_savedMinX = _bgCam.minScrollX;
		_savedMaxX = _bgCam.maxScrollX;
		_savedMinY = _bgCam.minScrollY;
		_savedMaxY = _bgCam.maxScrollY;
		_bgCam.setScrollBounds(null, null, null, null);

		_bgCam.scroll.set(146.0 - _bgCam.width * 0.5, -216.0 - _bgCam.height * 0.5);
		_bgCam.zoom = 2.8;

		_player.cinematic     = true;
		_player.mode          = thevalley.player.Player.PlayerMode.Ground;
		_player.wingOpenTimer = 0;
		_player.glideCooldown = 0;
		_player.body.position.setxy(146.0 + _player.width * 0.5, 134.0 + _player.height * 0.5);
		_player.body.velocity.setxy(0, 0);
		_player.lockedAnim = "break_idle";
		_player.animation.play("break_idle", true);

		_eButton.alpha = 0;
		_pressTimes = [];
		_progress   = 0;
		_tapTimer   = 0;
	}

	public function update(elapsed:Float):Void
	{
		_timer += elapsed;
		if (!_donePlayed)
			_player.body.velocity.setxy(0, 0);

		switch (_phase)
		{
			case FadeHold:
				_updateFadeHold();

			case PanZoom:
				_updatePanZoom();

			case Trapped:
				_updateTrapped(elapsed);

			case Escaping:
				var anim = _player.animation.curAnim;
				if (anim != null && anim.name == "break_full" && anim.finished)
				{
					_phase = TitleCard;
					_timer = 0;
					_player.lockedAnim = null;
					_player.animation.play("idle", true);
					_bgCam.setScrollBounds(_savedMinX, _savedMaxX, _savedMinY, _savedMaxY);

					_cardHoldTimer = -1.0;
					_title.visible = true;
					_dirt.visible  = true;
					_title.alpha   = 1.0;
					_dirt.alpha    = 1.0;
					_title.x = -_title.width;
					_dirt.x  = FlxG.width;
				}

			case TitleCard:
				_updateTitleCard(elapsed);
		}
	}

	function _updateFadeHold():Void
	{
		if (_timer < 1.5)
			return;

		if (_timer < 1.5 + 1.5)
		{
			if (!_musicStarted)
			{
				FlxG.sound.playMusic(Paths.music("minigame/thevalley/ambient"), 0, true);
				FlxG.sound.music.fadeIn(1.5, 0, 0.5);
				_musicStarted = true;
			}
			var t = (_timer - 1.5) / 1.5;
			t = t * t * (3.0 - 2.0 * t);
			_dimmer.alpha = 1.0 - t;
			return;
		}

		_dimmer.alpha = 0;

		if (_timer >= 1.5 + 1.5 + 3.0)
		{
			_phase = PanZoom;
			_timer = 0;
			_panFromX    = _bgCam.scroll.x;
			_panFromY    = _bgCam.scroll.y;
			_panFromZoom = _bgCam.zoom;
		}
	}

	function _updatePanZoom():Void
	{
		var t = Math.min(_timer / 5.5, 1.0);
		var eased = t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
		var targetX = _player.x + _player.width  * 0.5;
		var targetY = _player.y + _player.height * 0.5;
		var toX = targetX - _bgCam.width  * 0.5;
		var toY = targetY - _bgCam.height * 0.5;

		_bgCam.scroll.set(_panFromX + (toX - _panFromX) * eased, _panFromY + (toY - _panFromY) * eased);
		_bgCam.zoom = _panFromZoom + (5.30 - _panFromZoom) * eased;

		if (t >= 1.0)
		{
			_phase = Trapped;
			_timer = 0;
			_savedButtonScale = _eButton.scale.x;
			_eButton.scale.set(_savedButtonScale * 0.8, _savedButtonScale * 0.8);
			_eButton.updateHitbox();
		}
	}

	function _updateTrapped(elapsed:Float):Void
	{
		while (_pressTimes.length > 0 && _timer - _pressTimes[0] > 1.0)
			_pressTimes.shift();
		var cps = _pressTimes.length / 1.0;

		_progress += cps * 0.10 * elapsed;
		_progress -= 0.45 * elapsed;
		_progress = Math.max(0, Math.min(1, _progress));

		_bgCam.zoom = 5.30 + _progress * 0.8;

		_eButton.x = _player.x + _player.width * 0.5 - _eButton.width * 0.5;
		_eButton.y = _player.y - _eButton.height - 16.0;
		_eButton.alpha += (0.4 - _eButton.alpha) * (1.0 - Math.pow(0.01, elapsed * 8.0));

		if (_tapTimer > 0)
		{
			_tapTimer -= elapsed;
			if (_tapTimer <= 0)
			{
				_player.lockedAnim = "break_idle";
				_player.animation.play("break_idle", true);
			}
		}

		if (FlxG.keys.justPressed.E)
		{
			_pressTimes.push(_timer);
			_tapTimer = 0.3;
			_player.lockedAnim = "break_tap";
			_player.animation.play("break_tap", true);
			_eButton.animation.play("press");
			FlxG.sound.play(Paths.sound("minigame/thevalley/breakrope"), 0.3);
		}

		if (_progress >= 1.0)
		{
			_phase = Escaping;
			_timer = 0;
			_eButton.alpha = 0;
			_eButton.scale.set(_savedButtonScale, _savedButtonScale);
			_eButton.updateHitbox();
			_player.lockedAnim = "break_full";
			_player.animation.play("break_full", true);
			FlxG.sound.play(Paths.sound("minigame/thevalley/ropesnap"), 0.3);
		}
	}

	function _updateTitleCard(elapsed:Float):Void
	{
		var spd = 1.0 - Math.pow(0.01, elapsed);

		_dimmer.alpha = _lerp(_dimmer.alpha, 0.55, spd * 0.6);
		_title.x = _lerp(_title.x, 226.0, spd * 0.6);
		_dirt.x  = _lerp(_dirt.x,  206.0, spd * 0.6);

		_bgCam.zoom = _lerp(_bgCam.zoom, 2.8, spd * 0.6);

		var titleDist = Math.abs(_title.x - 226.0);
		var dirtDist  = Math.abs(_dirt.x  - 206.0);
		if (_cardHoldTimer < 0 && titleDist < 5.0 && dirtDist < 5.0)
		{
			_cardHoldTimer = 0;
			FlxG.sound.music.fadeOut(1.5, 0, function(_) {
				FlxG.sound.playMusic(Paths.music("minigame/thevalley/thevalley"), 0, true);
				FlxG.sound.music.fadeIn(2.0, 0, 1.0);
			});
		}

		if (_cardHoldTimer < 0) return;
		_cardHoldTimer += elapsed;

		if (_cardHoldTimer >= 2.0)
		{
			var p = Math.min((_cardHoldTimer - 2.0) / 1.5, 1.0);
			var a = 1.0 - p;
			_dimmer.alpha = 0.55 * a;
			_title.alpha  = a;
			_dirt.alpha   = a;
		}

		if (_cardHoldTimer >= 2.0 + 1.5 && !_donePlayed)
		{
			_donePlayed = true;
			_dimmer.visible = false;
			_title.visible  = false;
			_dirt.visible   = false;

			_bgCam.zoom = 2.8;
			_bgCam.follow(_player, FlxCameraFollowStyle.LOCKON);
			_bgCam.followLerp = 0.08;

			if (onDone != null) onDone();
		}
	}

	inline function _lerp(a:Float, b:Float, t:Float):Float return a + (b - a) * t;
}
