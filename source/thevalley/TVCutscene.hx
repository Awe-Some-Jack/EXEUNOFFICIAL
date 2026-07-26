package thevalley;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import thevalley.player.Player;
import thevalley.player.HUD;
import thevalley.cutscenes.CSSkull;

class TVCutscene
{
	public var eButton:FlxSprite;
	public var onGameplayStart:Void->Void;
	public var onSkullCS2Done:Void->Void;
	public var onSkullWin:Void->Void;
	public var skullUsedOnce:Bool = false;

	var _csSkull:CSSkull;

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
		eButton.frames = FlxAtlasFrames.fromSparrow(
			"assets/shared/images/minigame/thevalley/characters/fakergf/button.png",
			"assets/shared/images/minigame/thevalley/characters/fakergf/button.xml"
		);
		eButton.animation.addByPrefix("idle", "button press", 8, true);
		eButton.animation.play("idle");
		eButton.scale.set(1.2, 1.2);
		eButton.updateHitbox();
		eButton.alpha = 0;
		eButton.scrollFactor.set(1, 1);
		eButton.cameras = [_bgCam];
		state.add(eButton);
	}

	public function skipAll():Void
	{
		if (onGameplayStart != null) onGameplayStart();
	}

	public function triggerSkullCS2():Void
	{
		if (onSkullCS2Done != null) onSkullCS2Done();
		if (_csSkull != null) _csSkull.trigger();
	}

	public function update(elapsed:Float):Void
	{
		if (_csSkull != null) _csSkull.update(elapsed);
	}
}
