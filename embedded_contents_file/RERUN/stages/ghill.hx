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
import flixel.tweens.FlxEase;

using StringTools;

var ground:FlxSprite;
var cascade:FlxSprite;
var sky:FlxSprite;
var clouds:FlxBackdrop;
var black:FlxSprite;
var black2:FlxSprite;
var alphaShit:Float = 0;
var multiplier:Float = 1;

//-900, -200
// 0.35

final singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

function onCreate() {
	sky = new FlxSprite(-2640, -1335).loadGraphic(Paths.image('bg/cielo', 'RERUN'));
	sky.scale.set(1.6, 1.4);
	sky.scrollFactor.set(0.7, 0.7);
	sky.updateHitbox();
	addBehindGF(sky);

	clouds = new FlxBackdrop(Paths.image('bg/nubes', 'RERUN'), FlxAxes.X);
	clouds.scale.set(1.8, 1.8);
	clouds.x = 0;
	clouds.y = -950;
	clouds.scrollFactor.set(0.7, 0.7);
	addBehindGF(clouds);

	mountains = new FlxSprite(-3640, -1355).loadGraphic(Paths.image('bg/bg', 'RERUN'));
	mountains.scale.set(1.8, 1.8);
	mountains.updateHitbox();
	mountains.scrollFactor.set(0.85, 0.95);
	addBehindGF(mountains);

	cascade = new FlxSprite(-1500, -665);
	cascade.frames = Paths.getSparrowAtlas('bg/cascada', 'RERUN');
	cascade.animation.addByPrefix('idle', 'Símbolo 9 instancia 1', 12, true);
	cascade.animation.play('idle');
	cascade.scale.set(2.1, 1.8);
	cascade.updateHitbox();
	cascade.scrollFactor.set(0.85, 0.95);
	addBehindGF(cascade);

	ground = new FlxSprite(-3840, -805).loadGraphic(Paths.image('bg/piso', 'RERUN'));
	ground.scale.set(1.8, 1.8);
	ground.updateHitbox();
	addBehindGF(ground);

	black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black.alpha = 0;
	add(black);
	
	black3 = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black3.alpha = 0;
	addBehindDad(black3);

	dad.danceIdle = false;
}

function onCreatePost() {
	camZooming = false;
	camHUD.alpha = 0;

	logo = new FlxSprite(0, 0).loadGraphic(Paths.image('bg/cartoon-network', 'RERUN'));
	logo.scale.set(0.8, 0.8);
	logo.cameras = [camVideo];
	logo.alpha = 0.00001;
	logo.screenCenter();
	add(logo);

	black2 = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black2.alpha = 0;
	black2.cameras = [camOther];
	black2.screenCenter();
	// black2.blend = LuaUtils.blendModeFromString('INVERT');
	add(black2);

	overlay = new FlxSprite(-1400, -900).loadGraphic(Paths.image('bg/overlay', 'RERUN'));
	overlay.scale.set(1.8, 1.8);
	overlay.alpha = 0.3;
	overlay.blend = LuaUtils.blendModeFromString('HARDLIGHT');
	add(overlay);

	gfGroup.scrollFactor.set(1, 1);

	// game.cpuControlled = true;
}

function opponentNoteHit(note:Note):Void {
	if(note.noteType == 'GF2andDad' || note.noteType == 'GF2Sing') {
		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;

		if(Hijacked.instance.gf2 != null && !PlayState.instance.slideBlocked(Hijacked.instance.gf2, note)) {
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
		case 44:
			FlxTween.tween(logo, {alpha: 1}, 4.1, {ease: FlxEase.sineInOut});
			FlxTween.tween(black2, {alpha: 0}, 4.1, {ease: FlxEase.sineInOut});
		case 128:
			FlxTween.tween(logo.scale, {x: 0.2, y: 0.2}, 3.2, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(logo, {x: 670, y: 300, alpha: 0.8}, 3.2, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(camHUD, {alpha: 1}, 3.2, {ease: FlxEase.smootherStepInOut});
		case 1280:
			FlxTween.tween(camHUD, {alpha: 0}, 0.92, {ease: FlxEase.smootherStepInOut});
		case 1328:
			black2.alpha = 1;
			PlayState.instance.health = 1;
		case 1344:
			black2.alpha = 0;
		case 1400, 2200:
			FlxTween.tween(camHUD, {alpha: 1}, 0.615, {ease: FlxEase.smootherStepInOut});
		case 1464:
			FlxTween.tween(Hijacked.instance.gf2, {alpha: 0.9}, 0.307, {ease: FlxEase.smootherStepIn});
		case 1840:
			FlxTween.tween(black, {alpha: 1}, 1.23, {ease: FlxEase.smootherStepOut});
		case 1856:
			black3.alpha = 1;
			overlay.alpha = 0;
			FlxTween.tween(black, {alpha: 0}, 0.3075, {ease: FlxEase.linear});
		case 1980:
			FlxTween.tween(black, {alpha: 1}, 0.3075, {ease: FlxEase.smootherStepIn});
			FlxTween.tween(camHUD, {alpha: 0}, 0.3075, {ease: FlxEase.smootherStepIn});
			FlxTween.tween(Hijacked.instance.gf2, {alpha: 0}, 0.3075, {
				ease: FlxEase.smootherStepIn,
				onComplete: function(_) {
					Hijacked.instance.gf2.visible = false;
				}
			});
		case 1984:
			dad.animSuffix = '';
		case 2016:
			for(i in 0...opponentStrums.length) {
				opponentStrums.members[i].alpha = 0;
			}
			for(note in unspawnNotes) {
				if(!note.mustPress) {
					note.alpha = 0;
				}
			}
			for (i in 0...4) opponentStrums.members[i].x = -1000;
		case 2036:
			FlxTween.tween(black, {alpha: 0}, 0.3075, {ease: FlxEase.smootherStepIn});
			if(!ClientPrefs.data.middleScroll) comboGroup.x = -500;
		case 2076:
			FlxTween.tween(black, {alpha: 1}, 0.3, {ease: FlxEase.smootherStepIn});
		case 2080:
			black.alpha = black3.alpha = 0;
			overlay.alpha = 0.3;
			PlayState.instance.health = 1;
			gf.idleSuffix = '-alt';
			gf.recalculateDanceIdle();
		case 2608:
			FlxTween.tween(camHUD, {alpha: 0}, 1.23, {ease: FlxEase.smootherStepInOut});
		case 2630:
			FlxTween.tween(clouds, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
		case 2693:
			FlxTween.tween(sky, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
		case 2757:
			FlxTween.tween(mountains, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(cascade, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
		case 2784:
			FlxTween.tween(ground, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(overlay, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
		case 2794:
			FlxTween.tween(gfGroup, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
		case 2816:
			camHUD.visible = camHUD.alive = camHUD.exists = false;
			FlxTween.tween(boyfriendGroup, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(dadGroup, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(logo, {alpha: 0}, 2.46, {ease: FlxEase.smootherStepInOut});
	}
}

function goodNoteHitPre(note:Note):Void {
	boyfriend.idleSuffix = note.noteType == 'Alt Animation' ? '-alt' : '';
	boyfriend.recalculateDanceIdle();
}

function opponentNoteHitPre(note:Note):Void {
	if(curStep >= 1344 && curStep < 1984) {
		if(note.noteType == 'Alt Animation' || note.noteType == 'GF2Sing' || note.noteType == 'GF2andDad') {
			MusicBeatState.getVariables().get('iconOpp').changeIcon('creepshow-sonic');
			dad.animSuffix = note.noteType == 'Alt Animation' ? '' : '-alt';
			dad.danceIdle = true;
			dad.recalculateDanceIdle();
		} else {
			MusicBeatState.getVariables().get('iconOpp').changeIcon('sonic');
			dad.animSuffix = '';
			dad.danceIdle = false;
			dad.recalculateDanceIdle();
		}
	}
	// trace("mid");
}

function onUpdate(elapsed:Float) {
	if(curStep >= 2208 && curStep < 2624 && PlayState.instance.health > 0.1)
		PlayState.instance.health -= elapsed/20;

	if(curStep < 0 && PlayState.instance.startedCountdown)
		black2.alpha = 1;

	clouds.x += elapsed*100*multiplier;

	// camGame.zoom = 0.3;

	if(curStep >= 2080 && curStep < 2608) {
		multiplier += elapsed*3;
	}

	if(curStep >= 1472 && curStep < 1980) {
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