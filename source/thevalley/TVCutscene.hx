package thevalley;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import thevalley.player.Player;
import thevalley.player.HUD;
import thevalley.cutscenes.CSSkull;
import thevalley.cutscenes.IntroCutscene;

class TVCutscene
{
	public var eButton:FlxSprite;
	public var onGameplayStart:Void->Void;
	public var onSkullCS2Done:Void->Void;
	public var onSkullWin:Void->Void;
	public var skullUsedOnce:Bool = false;

	var _csSkull:CSSkull;
	var _intro:IntroCutscene;

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
		_csSkull.onDone = null;

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

		_intro = new IntroCutscene(state, _bgCam, uiCam, _player, eButton);
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

	public function triggerSkullCS2():Void
	{
		if (onSkullCS2Done != null) onSkullCS2Done();
		if (_csSkull != null) _csSkull.trigger();
	}

	public function update(elapsed:Float):Void
	{
		if (_csSkull != null) _csSkull.update(elapsed);
		if (_intro   != null) _intro.update(elapsed);
	}
}