package states.stages;

import backend.StageData;
import states.stages.objects.*;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lime.app.Application;
import objects.*;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import states.PlayState;
import states.PlayState.instance as PS;

class Hijacked extends BaseStage
{
	public var GF2_X:Float = 400;
	public var GF2_Y:Float = 130;
	public var gf2Map:Map<String, Character> = new Map<String, Character>();
	public var gf2Group:FlxSpriteGroup;
	public var gf2:Character = null;
	final singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public static var instance:Hijacked = null;

	override function create() {
		instance = this;

		var stageData:StageFile = StageData.getStageFile(PlayState.curStage);

		GF2_X = stageData.opponent[0]-50;
		GF2_Y = stageData.opponent[1];
		
		gf2Group = new FlxSpriteGroup(GF2_X, GF2_Y);

		gf2 = new Character(0, 0, 'lili');
		PS.startCharacterPos(gf2);
		gf2Group.add(gf2);
		gf2.blend = psychlua.LuaUtils.blendModeFromString('screen');
		gf2.alpha = 0;
	}

	override function createPost() {
		add(gf2Group);
	}

	override function characterBopper(beat:Int) {
		if(gf2 != null && beat % gf2.danceEveryNumBeats == 0 && !gf2.stunned && !gf2.getAnimationName().startsWith('sing'))
			gf2.dance();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function destroy() {
        instance = null;
        super.destroy();
    }
}