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
	var ground:FlxSprite;
	var cascade:FlxSprite;
	var sky:FlxSprite;
	var clouds:FlxBackdrop;
	var black:FlxSprite;
	var black2:FlxSprite;

	public var GF2_X:Float = 400;
	public var GF2_Y:Float = 130;
	public var gf2Map:Map<String, Character> = new Map<String, Character>();
	public var gf2Group:FlxSpriteGroup;
	public var gf2:Character = null;
	public var gf2Speed:Int = 1;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
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

		sky = new FlxSprite(-2340, -1335).loadGraphic(Paths.image('bg/cielo', 'RERUN'));
		sky.scale.set(1.4, 1.4);
		sky.scrollFactor.set(0.7, 0.7);
		sky.updateHitbox();
		add(sky);

		clouds = new FlxBackdrop(Paths.image('bg/nubes', 'RERUN'), X);
		clouds.scale.set(1.12 ,1.12);
		clouds.x = 0;
		clouds.y = -900;
		clouds.scrollFactor.set(0.7, 0.7);
		add(clouds);
		
		ground = new FlxSprite(-2540, -935).loadGraphic(Paths.image('bg/piso', 'RERUN'));
		ground.scale.set(1.12, 1.12);
		ground.updateHitbox();
		add(ground);

		cascade = new FlxSprite(-850, -395);
		cascade.frames = Paths.getSparrowAtlas('bg/cascada', 'RERUN');
		cascade.animation.addByPrefix('idle', 'Símbolo 9 instancia 1', 12, true);
		cascade.animation.play('idle');
		cascade.scale.set(1.12, 1.12);
		cascade.updateHitbox();
		add(cascade);

        black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
		black.alpha = 0;
		add(black);

        PS.addBehindDad(black);
	}

	override function createPost() {
		PS.camZooming = false;
		add(gf2Group);

		PS.camHUD.alpha = 0;

		black2 = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
		black2.alpha = 0;
		black2.blend = psychlua.LuaUtils.blendModeFromString('alpha');
		add(black2);
	}

	override function opponentNoteHit(note:Note):Void {
		if(curStep < 1056) {
			if(note.noteType == 'Alt Animation') {
				MusicBeatState.getVariables().get('iconOpp').changeIcon('creepshow-sonic');
				dad.idleSuffix = '-alt';
				dad.recalculateDanceIdle();
			} else {
				MusicBeatState.getVariables().get('iconOpp').changeIcon('sonic');
				dad.idleSuffix = '';
				dad.recalculateDanceIdle();
			}
		}

		if(note.noteType == 'GF2andDad' || note.noteType == 'GF2Sing') {
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;

			if(gf2 != null) {
				var canPlay:Bool = true;
				if(note.isSustainNote)
				{
					var holdAnim:String = animToPlay + '-hold';
					if(gf2.animation.exists(holdAnim)) animToPlay = holdAnim;
					final _curCharAnim:String = gf2.getAnimationName();
				if(_curCharAnim == holdAnim || _curCharAnim == holdAnim + '-loop') canPlay = false;
				}

				var charCurFrame = 0;
				if (gf2?.anim != null) charCurFrame = gf2.anim.frameIndex; else if (gf2.animation?.curAnim != null) charCurFrame = gf2.animation.curAnim.curFrame;
				if (gf2.getAnimationName().startsWith('sing') && note.isSustainNote && charCurFrame < 2) canPlay = false;
				if (note.noteType == 'Sustain Animation' && note.isSustainNote) canPlay = false;
				if(canPlay) gf2.playAnim(animToPlay, true);
				gf2.holdTimer = 0;
			}
		}
	}

	override function stepHit() {
		switch(curStep) {
			case 48:
				FlxTween.tween(PS.camHUD, {alpha: 1}, 1.24, {ease: FlxEase.smoothStepOut});
			case 1584:
				FlxTween.tween(black, {alpha: 1}, 9.85);
			case 1920:
				gf.idleSuffix = '-alt';
				gf.recalculateDanceIdle();
				gf.visible = true;
			case 1824:
				FlxTween.tween(black2, {alpha: 1}, 1.23, {ease: FlxEase.smoothStepOut});
				FlxTween.tween(PS.camHUD, {alpha: 0}, 1.23, {ease: FlxEase.smoothStepOut});
			case 1852:
				gf2.visible = gf.visible = false;
				for(note in PS.unspawnNotes) if(!note.mustPress) note.visible = false;
				for(i in 0...PS.opponentStrums.length) PS.opponentStrums.members[i].x = 10000;
			case 1856:
				FlxTween.tween(black2, {alpha: 0}, 0.2, {ease: FlxEase.linear});
			case 1916:
				FlxTween.tween(black2, {alpha: 1}, 0.3, {ease: FlxEase.linear});
				FlxTween.tween(PS.camHUD, {alpha: 1}, 0.3, {ease: FlxEase.linear});
			case 2696:
				FlxTween.tween(PS.camHUD, {alpha: 0}, 0.6, {ease: FlxEase.smoothStepInOut});
			case 2940:
				black2.alpha = black.alpha = 1;
				camGame.alpha = 0;
		}
	}

	override function goodNoteHitPre(note:Note):Void {
		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + '-alt';
		if(curStep >= 1920 && PS.boyfriend.animOffsets.exists(animToPlay))
			PS.boyfriend.animSuffix = '-alt';
		else
			PS.boyfriend.animSuffix = '';
	}

	override function noteMiss(daNote:Note) {
		PS.boyfriend.animSuffix = '';
	}

	override function characterBopper(beat:Int) {
		if(gf2 != null && beat % gf2.danceEveryNumBeats == 0 && !gf2.stunned && !gf2.getAnimationName().startsWith('sing'))
			gf2.dance();
	}

	var alphaShit:Float = 0;
	var multiplier:Float = 1;
	override function update(elapsed:Float) {
		super.update(elapsed);
		clouds.x += elapsed*100*multiplier;

		if(curStep >= 1920 && curStep < 2940) {
			black.alpha = black2.alpha = 0;
			multiplier += elapsed;
		}

		if(curStep >= 1056 && curStep < 1852) {
			for(i in 0...PS.opponentStrums.length) {
				PS.opponentStrums.members[i].alpha = .05+(Math.abs(1*Math.cos(alphaShit * (Math.PI / 180)))*.9);
				PS.opponentStrums.members[i].blend = psychlua.LuaUtils.blendModeFromString('screen');
			}
			for(note in PS.unspawnNotes) {
				if(!note.mustPress) {
					note.alpha = .05+(Math.abs(1*Math.cos(alphaShit * (Math.PI / 180)))*.9);
					note.blend = psychlua.LuaUtils.blendModeFromString('screen');
				}
			} 
		}

		if(curStep >= 1040 && curStep < 1852) {
			gf2.alpha = .05+(Math.abs(1*Math.sin(alphaShit * (Math.PI / 180)))*.9);
			alphaShit += elapsed*50;
		}
		// PlayState.instance.gameplayCam._sectionZoom = false;
	}
	override function destroy() {
        instance = null;
        super.destroy();
    }
	
}