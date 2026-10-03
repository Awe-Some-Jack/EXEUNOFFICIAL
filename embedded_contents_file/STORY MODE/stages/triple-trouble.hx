import psychlua.LuaUtils;
import openfl.display.BlendMode;
import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

using StringTools;

typedef BackgroundSpriteAlt =
{
	var path:String;
	var sprite:FlxSprite;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool;
	@:optional var visible:Bool;
	@:optional var alpha:Float;
	@:optional var flipX:Bool;
	@:optional var animation:Array<Dynamic>;
	@:optional var isFire:Bool;
	@:optional var pathF:String;
	@:optional var spriteF:FlxSprite;
}

var normal:Array<BackgroundSpriteAlt> = [
	{path: 'tt/bgn/bg', position: [-600, -300], scale: [1.1, 1.1], scroll: [0.3, 0.3], pathF: 'tt/bgn/fire/bg'},
	{path: 'tt/bgn/trees4', position: [-600, -300], scroll: [0.3, 0.3], pathF: 'tt/bgn/fire/trees4'},
	{path: 'tt/bgn/trees3', position: [-900, -200], scroll: [0.55, 0.55], pathF: 'tt/bgn/fire/trees3'},
	{path: 'tt/bgn/fire/FIRE 2', position: [-1000, -2700], scroll: [0.55, 0.55], scale: [6, 10, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgn/trees2', position: [-800, -200], scroll: [0.7, 0.7], pathF: 'tt/bgn/fire/trees2'},
	{path: 'tt/bgn/fire/fire', position: [-600, 100], scroll: [0.85, 0.85], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgn/trees1', position: [-600, -200], scroll: [0.85, 0.85], pathF: 'tt/bgn/fire/trees1'},
	{path: 'tt/bgn/fire/fire', position: [-800, 400], scroll: [0.925, 0.925], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgn/floor', position: [-600, -200], pathF: 'tt/bgn/fire/floor'},
	{path: 'tt/bgn/foreground', position: [-600, -200], scroll: [1.2, 1.2], front: true, pathF: 'tt/bgn/fire/foreground'},
	{path: 'tt/bgn/fire/FIRE 2', position: [-800, 100], scroll: [1.2, 1.2], front: true, scale: [6, 6, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true}
];

var xeno:Array<BackgroundSpriteAlt> = [
	{path: 'tt/bgx/bg', position: [-1000, -1000], scroll: [0.3, 0.3], visible: false, pathF: 'tt/bgx/fire/bg'},
	{path: 'tt/bgx/trees4', position: [-800, -800], scroll: [0.3, 0.3], visible: false, pathF: 'tt/bgx/fire/trees4'},
	{path: 'tt/bgx/trees3', position: [-700, -600], scroll: [0.55, 0.55], visible: false, pathF: 'tt/bgx/fire/trees3'},
	{path: 'tt/bgx/fire/FIRE 2', position: [-1000, -700], scroll: [0.55, 0.55], scale: [6, 10, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/trees2', position: [-600, -600], scroll: [0.7, 0.7], visible: false, pathF: 'tt/bgx/fire/trees2'},
	{path: 'tt/bgx/NewTitleMenuBG', position: [-300, -200], scroll: [0.85, 0.85], scale: [6, 6, true], animation: [{name: 'TitleMenuSSBG instance 1', looped: true}], visible: false, oushi: true},
	{path: 'tt/bgx/fire/FIRE', position: [-600, 2250], scroll: [0.85, 0.85], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/trees1', position: [-600, -200], scroll: [0.9, 0.9], visible: false, pathF: 'tt/bgx/fire/trees1'},
	{path: 'tt/bgx/fire/FIRE', position: [-800, 2400], scroll: [0.9, 0.9], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/crystals', position: [-400, 600], visible: false, pathF: 'tt/bgx/fire/crystals'},
	{path: 'tt/bgx/floor', position: [-600, -800], visible: false, pathF: 'tt/bgx/fire/floor'},
	{path: 'tt/bgx/foreground2', position: [-600, -200], scroll: [1.2, 1.2], front: true, visible: false, pathF: 'tt/bgx/fire/foreground2'},
	{path: 'tt/bgx/fire/FIRE 2', position: [-800, 2300], scroll: [1.2, 1.2], front: true, scale: [6, 6, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/foreground', position: [-1700, 1300], scroll: [1.3, 1.3], front: true, visible: false, pathF: 'tt/bgx/fire/foreground'}
];

var tails:Array<BackgroundSpriteAlt> = [
	{path: 'tt/tails/bg5', position: [-650, -900], scroll: [0.3, 0.3], visible: false},
	{path: 'tt/tails/bg4', position: [-450, -850], scroll: [0.55, 0.55], visible: false},
	{path: 'tt/tails/bg3', position: [-450, -850], scroll: [0.6, 0.6], visible: false},
	{path: 'tt/tails/bg2', position: [-450, -850], scroll: [0.65, 0.65], visible: false},
	{path: 'tt/tails/bg1', position: [-450, -850], scroll: [0.7, 0.7], visible: false},
	{path: 'tt/tails/floor', position: [-1850, -2350], visible: false}
];

var knux:Array<BackgroundSpriteAlt> = [
	{path: 'tt/knux/bg', position: [-780, -500], scroll: [0.4, 0.4], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/platform3', position: [-780, -600], scroll: [0.5, 0.5], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/fog2', position: [-780, -700], scroll: [0.5, 0.5], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/platform2', position: [-810, -660], scroll: [0.6, 0.6], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/platform', position: [-780, -550], scroll: [0.7, 0.7], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/fog', position: [-780, -600], scroll: [0.8, 0.8], visible: false},
	{path: 'tt/knux/floor', position: [-730, -350], visible: false}
];

var egg:Array<BackgroundSpriteAlt> = [
	{path: 'tt/egg/sky', position: [-680, -850], scroll: [0.3, 0.3], visible: false},
	{path: 'tt/egg/bg1', position: [-630, -770], scroll: [0.45, 0.45], visible: false},
	{path: 'tt/egg/bg2', position: [-580, -670], scroll: [0.65, 0.65], visible: false},
	{path: 'tt/egg/bg3', position: [-520, -600], scroll: [0.8, 0.8], visible: false},
	{path: 'tt/egg/floor', position: [-500, -650], visible: false},
	{path: 'tt/egg/overlay', position: [-500, -650], front: true, visible: false}
];

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var glow:FlxSprite;
var overlayTails:FlxSprite;
var vgSpr:FlxSprite;
var fogOverlay:FlxSprite;
var fogShader:FlxRuntimeShader;
var curBG:String = 'tails';
var isFlashback:Bool = false;
var canMakeParticles:Bool = false;
var hideParticles:Bool = false;
var particleSprites:Array<FlxSprite> = [];
var shaderTimer:Float = 0;
var frameCounter:Int = 0;

function onCreate()
{
	makeBackgroundAlt(normal, true);
	makeBackgroundAlt(xeno, true);
	makeBackgroundAlt(tails);
	makeBackgroundAlt(knux);
	makeBackgroundAlt(egg);

	for (spr in normal)
	{
		if (spr.isFire)
		{
			spr.sprite.scale.x /= 1.25;
			spr.sprite.scale.y /= 1.25;
			spr.sprite.updateHitbox();
		}
	}

	for (spr in xeno)
	{
		spr.sprite.scale.x *= 1.25;
		spr.sprite.scale.y *= 1.25;
		spr.sprite.updateHitbox();

		if (spr.spriteF != null) {
			spr.spriteF.scale.x *= 1.25;
			spr.spriteF.scale.y *= 1.25;
			spr.spriteF.updateHitbox();
		}

		if (spr.isFire)
		{
			spr.sprite.scale.x /= 1.5;
			spr.sprite.scale.y /= 1.5;
			spr.sprite.updateHitbox();
		}
	}
	
	glow = new FlxSprite(-700, 500).loadGraphic(Paths.image('tt/bgn/glow'));
	glow.alpha = 0.3;
	glow.scrollFactor.set(1.2, 1.2);
	glow.scale.set(2.5, 2.5); glow.updateHitbox();
	glow.blend = BlendMode.ADD;
	game.add(glow);

	overlayTails = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFF7100);
	overlayTails.blend = BlendMode.ADD;
	overlayTails.camera = camHUD;
	overlayTails.alpha = 0.3;
	overlayTails.visible = false;
	game.insert(0, overlayTails);

	vgSpr = new FlxSprite();
	vgSpr.loadGraphic(Paths.image('VG'));
	vgSpr.screenCenter();
	vgSpr.color = 0xFFFF0000;
	vgSpr.camera = camOther;
	vgSpr.visible = false;
	game.add(vgSpr);

	fogOverlay = new FlxSprite();
	fogOverlay.loadGraphic(Paths.image('overlay/fog'));
	fogOverlay.screenCenter();
	fogOverlay.camera = camOther;
	fogOverlay.alpha = 0.4;
	fogOverlay.visible = false;
	game.add(fogOverlay);

	if (!ClientPrefs.data.lowQuality)
	{
		fogShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment('wavyDistortion')));
		fogShader.setFloat('amount', 2);
		fogOverlay.shader = fogShader;
	}

	//preload chars
	preloadCharacter(1, 'BEAST');
	preloadCharacter(0, 'bf-perspective');
	preloadCharacter(1, 'knux');
	preloadCharacter(1, 'eggman');
}

function onSongStart() {
	if(ClientPrefs.data.middleScroll && (buildTarget == 'ios' || buildTarget == 'android')) PlayState.instance.mobileComboOffsetX = playerStrums.members[0].x / 2 - FlxG.width / 2;
}

function onEvent(n, v1, v2)
{
	switch(n)
	{
		case 'tripletroublebgchange': changeBG(v1);
		case 'flashbackstt': toggleFlashback();
		case 'ttfirestart': 
			FlxG.camera.flash(0xFFCE2BFF, 1, null, true);
			vgSpr.visible = true;
			for (spr in xeno) {
				if (!spr.isFire) spr.sprite?.destroy();
				if (spr.isFire) spr.sprite.visible = true;
				if (spr.spriteF != null) spr.spriteF.visible = true;
			}
			var fireDur:Float = Conductor.crochet / (1000 / 2) / playbackRate;
			if (xeno[3].sprite != null) FlxTween.tween(xeno[3].sprite, {y: -2700}, fireDur, {ease: FlxEase.cubeOut});
			if (!ClientPrefs.data.lowQuality && xeno[6].sprite != null) FlxTween.tween(xeno[6].sprite, {y: 250}, fireDur, {ease: FlxEase.cubeOut});
			if (xeno[8].sprite != null) FlxTween.tween(xeno[8].sprite, {y: 400}, fireDur, {ease: FlxEase.cubeOut});
			if (!ClientPrefs.data.lowQuality && xeno[12].sprite != null) FlxTween.tween(xeno[12].sprite, {y: 300}, fireDur, {ease: FlxEase.cubeOut});
			canMakeParticles = true;
		case 'fadecam':
			canMakeParticles = false;
			var dur:Float = Conductor.crochet / (1000 / Std.parseFloat(v2)) / playbackRate;
			for (p in particleSprites) FlxTween.tween(p, {alpha: 0}, dur, {onComplete: (_) -> game.remove(p, true)});
			particleSprites = [];
		case 'fadeHUD': FlxTween.tween(camHUD, {alpha: 0}, 2.8);
	}

	if (n == 'Dadbattle Spotlight') vgSpr.visible = false;
}

function toggleFlashback()
{
	isFlashback = !isFlashback;
	glow.visible = !isFlashback;
	if (fogOverlay != null) fogOverlay.visible = isFlashback;
	if (isFlashback) for (spr in normal) spr.sprite?.visible = false;
	switch(curBG)
	{
		case 'tails':
			if (isFlashback)
			{
				for (spr in tails) spr.sprite.visible = true;
				overlayTails.visible = true;
			}
		case 'knux':
			if (isFlashback)
			{
				for (spr in knux) spr.sprite.visible = true;
				for (spr in normal) if (!spr.isFire) spr.sprite.destroy();
			}
		case 'egg':
			if (isFlashback)
			{
				FlxG.camera.flash(0xFFFFFFFF, 1, null, true);
				for (spr in egg) spr.sprite.visible = true;
				for (spr in normal) { spr.sprite?.destroy(); spr.spriteF?.destroy(); }
				hideParticles = true;
				for (p in particleSprites) p.alpha = 0;
			}
	}
}

function changeBG(bg:String):Void
{
	curBG = bg;
	switch(bg)
	{
		case 'xeno':
			triggerEvent('flashbackstt', '', '');

			for (spr in xeno) if (!spr.isFire) spr.sprite.visible = true;
			for (spr in tails) spr.sprite.destroy();
			glow.visible = true;
			overlayTails.destroy();

			changeCharacter('dad', 'BEAST');
			changeCharacter('bf', 'bf-perspective');

			dad.setPosition(350, 680);
			boyfriend.setPosition(1200, 950);
		case 'xeno2':
			FlxG.camera.flash(0xFFFFFFFF, 1, null, true);
			triggerEvent('flashbackstt', '', '');

			for (spr in xeno) {
				if (!spr.isFire) { spr.sprite.visible = true; spr.sprite.flipX = true; }
				if (spr.spriteF != null) spr.spriteF.flipX = true;
			}
			for (spr in knux) spr.sprite?.destroy();
			glow.visible = true;

			changeCharacter('dad', 'BEAST-RIGHT');
			changeCharacter('bf', 'bf-perspective');

			dad.setPosition(1435, 695);
			boyfriend.setPosition(130, 950);

			boyfriend.idleSuffix = '-knux';
			boyfriend.recalculateDanceIdle();
		case 'xeno3':
			vgSpr.visible = true;
			hideParticles = false;
			triggerEvent('flashbackstt', '', '');

			for (spr in xeno) { if (spr.spriteF != null) { spr.spriteF.visible = true; spr.spriteF.flipX = false; } if (spr.isFire) spr.sprite.visible = true; }
			for (spr in egg) spr.sprite.destroy();
			glow.visible = true;

			changeCharacter('dad', 'BEAST');
			changeCharacter('bf', 'bf-perspective');

			boyfriend.idleSuffix = '';
			boyfriend.recalculateDanceIdle();

			dad.setPosition(350, 680);
			boyfriend.setPosition(1200, 950);
		case 'knux':
			triggerEvent('Knux', '', '');

			for (spr in xeno) spr.sprite.visible = false;
			xeno[5].sprite.destroy();
			for (spr in normal)
			{
				if (!spr.isFire)
				{
					spr.sprite.visible = true;
					spr.sprite.flipX = true;
				}
			}
			normal[1].sprite.x += 150; normal[2].sprite.x += 50; normal[4].sprite.x += 500; normal[6].sprite.x += 100;

			changeCharacter('dad', 'knux');
			changeCharacter('bf', 'bf');

			dad.setPosition(1248, 900);
			boyfriend.setPosition(110, 768);

			boyfriend.idleSuffix = '-knux';
			boyfriend.recalculateDanceIdle();
		case 'egg':
			vgSpr.visible = false;
			triggerEvent('Knux', '', '');

			for (spr in xeno) { spr.sprite?.visible = false; if (spr.spriteF != null) spr.spriteF.visible = false; }
			for (spr in normal) {if (spr.spriteF != null) spr.spriteF.visible = true; if (spr.isFire) spr.sprite.visible = true;}

			changeCharacter('dad', 'eggman');
			changeCharacter('bf', 'bf');

			boyfriend.idleSuffix = '';
			boyfriend.recalculateDanceIdle();

			dad.setPosition(315, 815);
			boyfriend.setPosition(1045, 777);
	}
}

function spawnParticle()
{
	var p:FlxSprite = new FlxSprite(FlxG.random.int(0, 2000), 1500);
	p.loadGraphic(Paths.image('tt/particles/dust' + FlxG.random.int(1, 6)));
	var pScale:Float = FlxG.random.float(0.6, 1.3);
	var pScroll:Float = FlxG.random.float(0.8, 1.2);
	p.scale.set(pScale, pScale); p.updateHitbox();
	p.scrollFactor.set(pScroll, pScroll);
	p.acceleration.x = FlxG.random.float(-300, 50);
	p.acceleration.y = FlxG.random.float(-400, -100);
	p.antialiasing = !ClientPrefs.data.lowQuality;
	p.angularVelocity = FlxG.random.float(25, 240);
	p.alpha = hideParticles ? 0 : 1;
	if (FlxG.random.bool()) game.add(p);
	else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), p);
	particleSprites.push(p);
}

function fadeParticles(duration:Float)
{

}

function onUpdatePost(elapsed:Float)
{
	frameCounter++;
	if (frameCounter % 30 == 0 && canMakeParticles && !ClientPrefs.data.lowQuality)
		spawnParticle();
	if (!ClientPrefs.data.lowQuality && fogShader != null)
	{
		shaderTimer += elapsed * playbackRate;
		fogShader.setFloat('iTime', shaderTimer);
	}
}

function goodNoteHitPre(note) if (curBG == 'knux' || curBG == 'xeno2') note.animSuffix = '-knux';
function noteMiss(note) if (curBG == 'knux' || curBG == 'xeno2') boyfriend.playAnim(game.singAnimations[note.noteData] + 'miss-knux', true);
function noteMissPress(note) if (curBG == 'knux' || curBG == 'xeno2') boyfriend.playAnim(game.singAnimations[note] + 'miss-knux', true);

function onBeatHit()
{
	// Ending
	if(curBeat >= 1284) return;
	
	if (curBG != 'xeno3')
	{
		if (curBeat % 2 == 0 && vgSpr.visible)
		{
			FlxTween.cancelTweensOf(vgSpr);
			FlxTween.tween(vgSpr, {alpha: (curBeat % 4 == 0 ? 1 : 0)}, Conductor.crochet / 1000 * 2);
		}
	}
	else
	{
		FlxTween.cancelTweensOf(vgSpr);
		vgSpr.alpha = 0.7;
		FlxTween.tween(vgSpr, {alpha: 0}, Conductor.crochet / 750);
	}

	if (curBG.startsWith('xeno') && curBeat % 2 == 0)
	{
		if (dad.getAnimationName() == 'idle') dad.playAnim('idle', true);
		if (boyfriend.getAnimationName() == 'idle' + (curBG == 'xeno2' ? '-knux' : '')) boyfriend.playAnim('idle' + (curBG == 'xeno2' ? '-knux' : ''), true);
	}
}

function triggerEvent(n, v1, v2) game.triggerEvent(n, v1, v2, Conductor.songPosition);
function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);
function makeBackgroundAlt(background:Array<BackgroundSpriteAlt>, ?makeFire:Bool = false)
{
	for (spriteDef in background)
	{
		//making the normal bg
		var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		if (spriteDef.animation != null)
		{
			sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
			for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
		}
		else sprite.loadGraphic(Paths.image(spriteDef.path));
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]);

		//fuck myself why i need to do this, FUCK KAZU!!!!!!!! Si ok entiendo :C
		sprite.scale.x *= 1.2; sprite.scale.y *= 1.2;
		if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();

		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		if (spriteDef.flipX != null) sprite.flipX = spriteDef.flipX;
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;

		//then the fire variation
		if (!makeFire) continue;
		if (spriteDef.isFire || spriteDef.oushi) continue;
		var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		if (spriteDef.animation != null)
		{
			sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
			for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
		}
		else sprite.loadGraphic(Paths.image(spriteDef.pathF));
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]);

		//fuck myself why i need to do this, FUCK KAZU!!!!!!!! Si ok entiendo :C
		sprite.scale.x *= 1.2; sprite.scale.y *= 1.2;
		if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();

		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		sprite.visible = false;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		if (spriteDef.flipX != null) sprite.flipX = spriteDef.flipX;
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.spriteF = sprite;
	}
}