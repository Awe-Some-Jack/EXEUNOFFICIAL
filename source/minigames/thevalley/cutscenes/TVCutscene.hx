package minigames.thevalley.cutscenes;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import minigames.thevalley.TheValley;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.character.player.HUD;
import minigames.thevalley.cutscenes.CSSkull;
import minigames.thevalley.cutscenes.IntroCutscene;

class TVCutscene
{
	public var eButton:FlxSprite;
	public var onGameplayStart:Void->Void;
	public var onSkullCS2Done:Void->Void;
	public var onSkullWin:Void->Void;

	public var skullCSPlaying(get, never):Bool;
	function get_skullCSPlaying() return _csSkull != null && _csSkull.playing;

	var _csSkull:CSSkull;
	var _intro:IntroCutscene;

	public var musicMix(get, never):Float;
	function get_musicMix() return _intro != null ? _intro.musicMix : 1.0;
	var _skullCSPending:Bool = false;

	var _state:TheValley;
	var _player:Player;
	var _bgCam:FlxCamera;
	var _uiCam:FlxCamera;
	var _hud:HUD;

	public function new(state:TheValley, player:Player, bgCam:FlxCamera, uiCam:FlxCamera, hud:HUD)
	{
		_state  = state;
		_player = player;
		_bgCam  = bgCam;
		_uiCam  = uiCam;
		_hud    = hud;
	}

	public function addSprites(state:TheValley, uiCam:FlxCamera):Void
	{
		_csSkull = new CSSkull(state, uiCam);
		_csSkull.addSprites();
		_csSkull.onDone = () -> _player.cinematic = false;

		eButton = new FlxSprite(0, 0);
		eButton.frames = Paths.getSparrowAtlas('minigame/thevalley/characters/fakergf/button');

		eButton.animation.addByIndices("idle", "button press", [0], "", 1, true);
		eButton.animation.addByPrefix("press", "button press", 10, false);
		eButton.animation.onFinish.add((name) -> {
			if (name == "press") eButton.animation.play("idle");
		});
		eButton.animation.play("idle");
		eButton.scale.set(1.2, 1.2);
		eButton.updateHitbox();
		eButton.alpha = 0;
		eButton.scrollFactor.set(1, 1);
		eButton.cameras = [_bgCam];
		state.add(eButton);

		_intro = new IntroCutscene(state, state.gameCamera, uiCam, _player, eButton, state.bg);
		_intro.onDone = () -> { if (onGameplayStart != null) onGameplayStart(); };
	}

	public function skipAll():Void
	{
		if (onGameplayStart != null) onGameplayStart();
	}

	public function playIntro():Void
	{
		if (_intro != null) _intro.trigger();
	}

	public function triggerSkullCS2(later:Bool = false):Void
	{
		if (onSkullCS2Done != null) onSkullCS2Done();
		if (later) _skullCSPending = true;
		else _playSkullCS();
	}

	function _playSkullCS():Void
	{
		if (_csSkull == null) return;
		_player.cinematic = true;
		_player.body.velocity.setxy(0, 0);
		_csSkull.trigger();
	}

	public function update(elapsed:Float):Void
	{
		if (_skullCSPending && !_state.dying && !_player.cinematic)
		{
			_skullCSPending = false;
			_playSkullCS();
		}
		if (_csSkull != null) _csSkull.update(elapsed);
		if (_intro   != null) _intro.update(elapsed);
	}
}