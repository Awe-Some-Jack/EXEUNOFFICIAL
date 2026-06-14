package states.stages;

import backend.StageData;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import states.PlayState;
import psychlua.LuaUtils;
import flixel.util.FlxAxes;
import backend.MusicBeatState;
import states.stages.Hijacked;

using StringTools;

var ground:FlxSprite;
var cascade:FlxSprite;
var sky:FlxSprite;
var clouds:FlxBackdrop;
var black:FlxSprite;
var black2:FlxSprite;
var alphaShit:Float = 0;
var multiplier:Float = 1;

final singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

function onCreate() {
	sky = new FlxSprite(-2340, -1335).loadGraphic(Paths.image('bg/cielo', 'RERUN'));
	sky.scale.set(1.4, 1.4);
	sky.scrollFactor.set(0.7, 0.7);
	sky.updateHitbox();
	addBehindGF(sky);

	clouds = new FlxBackdrop(Paths.image('bg/nubes', 'RERUN'), FlxAxes.X);
	clouds.scale.set(1.12 ,1.12);
	clouds.x = 0;
	clouds.y = -900;
	clouds.scrollFactor.set(0.7, 0.7);
	addBehindGF(clouds);
	
	ground = new FlxSprite(-2540, -935).loadGraphic(Paths.image('bg/piso', 'RERUN'));
	ground.scale.set(1.12, 1.12);
	ground.updateHitbox();
	addBehindGF(ground);

	cascade = new FlxSprite(-850, -395);
	cascade.frames = Paths.getSparrowAtlas('bg/cascada', 'RERUN');
	cascade.animation.addByPrefix('idle', 'Símbolo 9 instancia 1', 12, true);
	cascade.animation.play('idle');
	cascade.scale.set(1.12, 1.12);
	cascade.updateHitbox();
	addBehindGF(cascade);

	black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black.alpha = 0;
	addBehindGF(black);

	addBehindDad(black);
}

function onCreatePost() {
	camZooming = false;
	camHUD.alpha = 0;

	black2 = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black2.alpha = 0;
	black2.blend = LuaUtils.blendModeFromString('alpha');
	add(black2);
}

function opponentNoteHit(note:Note):Void {
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

		if(Hijacked.instance.gf2 != null) {
			var canPlay:Bool = true;
			if(note.isSustainNote)
			{
				var holdAnim:String = animToPlay + '-hold';
				if(Hijacked.instance.gf2.animation.exists(holdAnim)) animToPlay = holdAnim;
				final _curCharAnim:String = Hijacked.instance.gf2.getAnimationName();
				if(_curCharAnim == holdAnim || _curCharAnim == holdAnim + '-loop') canPlay = false;
			}

			var charCurFrame = 0;
			if (Hijacked.instance.gf2.animation != null) charCurFrame = Hijacked.instance.gf2.animation.curAnim.curFrame;
			if (Hijacked.instance.gf2.getAnimationName().startsWith('sing') && note.isSustainNote && charCurFrame < 2) canPlay = false;
			if (note.noteType == 'Sustain Animation' && note.isSustainNote) canPlay = false;
			if(canPlay) Hijacked.instance.gf2.playAnim(animToPlay, true);
			Hijacked.instance.gf2.holdTimer = 0;
		}
	}
}

function onStepHit() {
	switch(curStep) {
		case 48:
			FlxTween.tween(camHUD, {alpha: 1}, 1.24, {ease: FlxEase.smoothStepOut});
		case 1584:
			FlxTween.tween(black, {alpha: 1}, 9.85);
		case 1920:
			gf.idleSuffix = '-alt';
			gf.recalculateDanceIdle();
			gf.visible = true;
		case 1824:
			FlxTween.tween(black2, {alpha: 1}, 1.23, {ease: FlxEase.smoothStepOut});
			FlxTween.tween(camHUD, {alpha: 0}, 1.23, {ease: FlxEase.smoothStepOut});
		case 1852:
			Hijacked.instance.gf2.visible = gf.visible = false;
			for(note in unspawnNotes) if(!note.mustPress) note.visible = false;
			for(i in 0...opponentStrums.length) opponentStrums.members[i].x = 10000;
		case 1856:
			FlxTween.tween(black2, {alpha: 0}, 0.2, {ease: FlxEase.linear});
		case 1916:
			FlxTween.tween(black2, {alpha: 1}, 0.3, {ease: FlxEase.linear});
			FlxTween.tween(camHUD, {alpha: 1}, 0.3, {ease: FlxEase.linear});
		case 2696:
			FlxTween.tween(camHUD, {alpha: 0}, 0.6, {ease: FlxEase.smoothStepInOut});
		case 2940:
			black2.alpha = black.alpha = 1;
			camGame.alpha = 0;
	}
}

function goodNoteHitPre(note:Note):Void {
	var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + '-alt';
	if(curStep >= 1920 && boyfriend.animOffsets.exists(animToPlay))
		boyfriend.animSuffix = '-alt';
	else
		boyfriend.animSuffix = '';
}

function noteMiss(daNote:Note) {
	boyfriend.animSuffix = '';
}

function onUpdate(elapsed:Float) {
	clouds.x += elapsed*100*multiplier;

	if(curStep >= 1920 && curStep < 2940) {
		black.alpha = black2.alpha = 0;
		multiplier += elapsed;
	}

	if(curStep >= 1 && curStep < 1852) {
		Hijacked.instance.gf2.alpha = .05+(Math.abs(1*Math.sin(alphaShit * (Math.PI / 180)))*.9);
		alphaShit += elapsed*50;

		for(i in 0...opponentStrums.length) {
			opponentStrums.members[i].alpha = .05+(Math.abs(1*Math.cos(alphaShit * (Math.PI / 180)))*.9);
			opponentStrums.members[i].blend = LuaUtils.blendModeFromString('screen');
		}
		for(note in unspawnNotes) {
			if(!note.mustPress) {
				note.alpha = .05+(Math.abs(1*Math.cos(alphaShit * (Math.PI / 180)))*.9);
				note.blend = LuaUtils.blendModeFromString('screen');
			}
		} 
	}
}