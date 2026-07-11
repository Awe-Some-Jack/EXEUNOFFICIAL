import psychlua.LuaUtils;
import openfl.display.BlendMode;
import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;

using StringTools;

typedef BackgroundSprite =
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
	@:optional var fireOffset:Float;
}

var normal:Array<BackgroundSprite> = [
	{path: 'tt/bgn/bg', position: [-600, -200], scroll: [0.3, 0.3], pathF: 'tt/bgn/fire/bg'},
	{path: 'tt/bgn/trees4', position: [-600, -300], scroll: [0.3, 0.3], pathF: 'tt/bgn/fire/trees4'},
	{path: 'tt/bgn/trees3', position: [-900, -200], scroll: [0.55, 0.55], pathF: 'tt/bgn/fire/trees3'},
	{path: 'tt/bgn/fire/FIRE 2', position: [-1000, -2700], scroll: [0.55, 0.55], scale: [6, 10, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgn/trees2', position: [-800, -200], scroll: [0.7, 0.7], pathF: 'tt/bgn/fire/trees2', fireOffset: -662},
	{path: 'tt/bgn/fire/FIRE', position: [-600, 100], scroll: [0.85, 0.85], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgn/trees1', position: [-600, -200], scroll: [0.85, 0.85], pathF: 'tt/bgn/fire/trees1', fireOffset: -684},
	{path: 'tt/bgn/fire/FIRE', position: [-800, 400], scroll: [0.925, 0.925], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgn/floor', position: [-600, -200], pathF: 'tt/bgn/fire/floor', fireOffset: -679},
	{path: 'tt/bgn/foreground', position: [-600, -200], scroll: [1.2, 1.2], front: true, pathF: 'tt/bgn/fire/foreground', fireOffset: -347},
	{path: 'tt/bgn/fire/FIRE 2', position: [-800, 100], scroll: [1.2, 1.2], front: true, scale: [6, 6, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true}
];

var xeno:Array<BackgroundSprite> = [
	{path: 'tt/bgx/bg', position: [-1000, -1000], scroll: [0.3, 0.3], visible: false, pathF: 'tt/bgx/fire/bg'},
	{path: 'tt/bgx/trees4', position: [-800, -800], scroll: [0.3, 0.3], visible: false, pathF: 'tt/bgx/fire/trees4'},
	{path: 'tt/bgx/trees3', position: [-700, -600], scroll: [0.55, 0.55], visible: false, pathF: 'tt/bgx/fire/trees3'},
	{path: 'tt/bgx/fire/FIRE 2', position: [-1000, -700], scroll: [0.55, 0.55], scale: [6, 10, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/trees2', position: [-600, -600], scroll: [0.7, 0.7], visible: false, pathF: 'tt/bgx/fire/tres2'},
	{path: 'tt/bgx/NewTitleMenuBG', position: [-300, -200], scroll: [0.85, 0.85], scale: [6, 6, true], animation: [{name: 'TitleMenuSSBG instance 1', looped: true}], visible: false},
	{path: 'tt/bgx/fire/FIRE', position: [-600, -800], scroll: [0.85, 0.85], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/trees1', position: [-600, -200], scroll: [0.9, 0.9], visible: false, pathF: 'tt/bgx/fire/trees1'},
	{path: 'tt/bgx/fire/FIRE', position: [-800, -600], scroll: [0.9, 0.9], scale: [3, 3, true], animation: [{name: 'fuego true instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/crystals', position: [-400, 600], visible: false, pathF: 'tt/bgx/fire/crystals'},
	{path: 'tt/bgx/floor', position: [-600, -800], visible: false, pathF: 'tt/bgx/fire/floor'},
	{path: 'tt/bgx/foreground2', position: [-600, -200], scroll: [1.2, 1.2], front: true, visible: false, pathF: 'tt/bgx/fire/foreground2'},
	{path: 'tt/bgx/fire/FIRE 2', position: [-800, -700], scroll: [1.2, 1.2], front: true, scale: [6, 6, true], animation: [{name: 'fire instancia 1', looped: true}], visible: false, isFire: true},
	{path: 'tt/bgx/foreground', position: [-1700, 1300], scroll: [1.3, 1.3], front: true, visible: false, pathF: 'tt/bgx/fire/foreground'}
];

var tails:Array<BackgroundSprite> = [
	{path: 'tt/tails/bg5', position: [-650, -900], scroll: [0.3, 0.3], visible: false},
	{path: 'tt/tails/bg4', position: [-450, -850], scroll: [0.55, 0.55], visible: false},
	{path: 'tt/tails/bg3', position: [-450, -850], scroll: [0.6, 0.6], visible: false},
	{path: 'tt/tails/bg2', position: [-450, -850], scroll: [0.65, 0.65], visible: false},
	{path: 'tt/tails/bg1', position: [-450, -850], scroll: [0.7, 0.7], visible: false},
	{path: 'tt/tails/floor', position: [-1850, -2350], visible: false}
];

var knux:Array<BackgroundSprite> = [
	{path: 'tt/knux/bg', position: [-750, -500], scroll: [0.4, 0.4], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/platform3', position: [-750, -600], scroll: [0.5, 0.5], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/fog2', position: [-750, -700], scroll: [0.5, 0.5], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/platform2', position: [-780, -660], scroll: [0.6, 0.6], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/platform', position: [-750, -550], scroll: [0.7, 0.7], scale: [1, 1, true], visible: false},
	{path: 'tt/knux/fog', position: [-750, -600], scroll: [0.8, 0.8], visible: false},
	{path: 'tt/knux/floor', position: [-700, -350], visible: false}
];

var egg:Array<BackgroundSprite> = [
	{path: 'tt/egg/sky', position: [-680, -850], scroll: [0.3, 0.3], visible: false},
	{path: 'tt/egg/bg1', position: [-630, -770], scroll: [0.45, 0.45], visible: false},
	{path: 'tt/egg/bg2', position: [-580, -670], scroll: [0.65, 0.65], visible: false},
	{path: 'tt/egg/bg3', position: [-520, -600], scroll: [0.8, 0.8], visible: false},
	{path: 'tt/egg/floor', position: [-500, -650], visible: false},
	{path: 'tt/egg/overlay', position: [-500, -650], front: true, visible: false}
];

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final lq:Bool = ClientPrefs.data.lowQuality;
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
	makeBackground(normal);
	makeBackground(xeno);
	makeBackground(tails);
	makeBackground(knux);
	makeBackground(egg);

	makeBackground(normal, true); //fire bg
	makeBackground(xeno, true); //fire bg

	for (spr in xeno)
	{
		spr.sprite.scale.x *= 1.25;
		spr.sprite.scale.y *= 1.25;
		spr.sprite.updateHitbox();
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

	if (!lq)
	{
		fogShader = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('wavyDistortion')));
		fogShader.setFloat('amount', 2);
		fogOverlay.shader = fogShader;
	}

	//preload chars
	preloadCharacter(1, 'BEAST');
	preloadCharacter(0, 'bf-perspective-right');
	preloadCharacter(1, 'BEAST-RIGHT');
	preloadCharacter(0, 'bf-perspective-left');
	preloadCharacter(1, 'knux');
	preloadCharacter(1, 'eggman');
}

function onEvent(n, v1, v2)
{
	/*if n == 'tripletroublebgchange' then
		onBGChange(v1)
	elseif n == 'ttfirestart' then
		onFireStart()
	elseif n == 'flashbackstt' then
		onFlashbackToggle()
	elseif n == 'fadecam' then
		fadeParticles(tonumber(v2))
	elseif n == 'fadeHUD' then
		doTweenAlpha('camHUDAlpha', 'camHUD', 0, 2.8)
	end*/
	switch(n)
	{
		case 'tripletroublebgchange': changeBG(v1);
		case 'flashbackstt': toggleFlashback();
		case 'ttfirestart': onFireStart();
		case 'fadecam':    fadeParticles(Std.parseFloat(v2));
		case 'fadeHUD':    FlxTween.tween(camHUD, {alpha: 0}, 2.8);
	}
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
				if (ClientPrefs.data.flashingLights) triggerEvent('Flash', 'FFFFFF,1', 'game');
				for (spr in tails) spr.sprite.visible = true;
				overlayTails.visible = true;
			}
			else
			{
				for (spr in normal) if (spr.sprite != null) spr.sprite.alpha = 1;
				for (spr in tails) if (spr.sprite != null) { game.remove(spr.sprite, true); spr.sprite = null; }
				overlayTails.visible = false;
			}
		case 'knux':
			if (isFlashback)
			{
				if (ClientPrefs.data.flashingLights) triggerEvent('Flash', 'FFFFFF,1', 'game');
				for (spr in knux) spr.sprite.visible = true;
				for (spr in normal) if (!spr.isFire) spr.sprite.destroy();
			}
			else
			{
				for (spr in normal) if (spr.sprite != null) spr.sprite.alpha = 1;
				for (spr in knux) if (spr.sprite != null) { game.remove(spr.sprite, true); spr.sprite = null; }
			}
		case 'egg':
			if (isFlashback)
			{
				if (ClientPrefs.data.flashingLights) triggerEvent('Flash', 'FFFFFF,1', 'game');
				for (spr in egg) spr.sprite.visible = true;
				for (spr in normal)
				{
					spr.sprite?.destroy();
					spr.spriteF?.destroy();
				}
				hideParticles = true;
				for (p in particleSprites) p.alpha = 0;
			}
			else
			{
				for (spr in normal) if (spr.sprite != null) { spr.sprite.alpha = 1; if (spr.spriteF != null) spr.spriteF.alpha = 1; }
				for (spr in egg) if (spr.sprite != null) { game.remove(spr.sprite, true); spr.sprite = null; }
				hideParticles = false;
				for (p in particleSprites) p.alpha = 1;
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
			changeCharacter('bf', 'bf-perspective-right');

			dad.setPosition(260, 635);
			boyfriend.setPosition(1450, 910);
		case 'xeno2':
			triggerEvent('flashbackstt', '', '');

			for (spr in xeno) if (!spr.isFire) { spr.sprite.visible = true; spr.sprite.flipX = true; }
			for (spr in knux) spr.sprite?.destroy();
			glow.visible = true;

			boyfriend.idleSuffix = '';
			boyfriend.recalculateDanceIdle();

			changeCharacter('dad', 'BEAST-RIGHT');
			changeCharacter('bf', 'bf-perspective-left');
		case 'xeno3':
			triggerEvent('flashbackstt', '', '');

			for (spr in xeno) if (spr.animation == null || spr.isFire) spr.spriteF?.visible = true;
			for (spr in egg) spr.sprite.destroy();
			glow.visible = true;

			changeCharacter('dad', 'BEAST');
			changeCharacter('bf', 'bf-perspective-right');
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

			dad.setPosition(1085, 785);
			boyfriend.setPosition(145, 760);

			boyfriend.idleSuffix = '-knux';
			boyfriend.recalculateDanceIdle();
		case 'egg':
			triggerEvent('Knux', '', '');

			for (spr in xeno) spr.sprite?.destroy();
			for (spr in normal) spr.spriteF.visible = true;

			changeCharacter('dad', 'eggman');
			changeCharacter('bf', 'bf');
	}
	/**
	if phase == 'xeno' then
		if onFlashback then triggerEvent('flashbackstt', '', '') end

		triggerEvent('Change Character', 'dad', 'BEAST')
		triggerEvent('Change Character', 'bf', 'bf-perspective-right')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') + 400, getProperty('dadGroup.y') + 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 100, getProperty('boyfriendGroup.y') + 150})

		setGroupVisible(normal, false)
		setGroupVisible(xeno, true)

		setProperty('staticx.alpha', 1)

	elseif phase == 'xeno2' then
		if onFlashback then triggerEvent('flashbackstt', '', '') end

		triggerEvent('Change Character', 'dad', 'BEAST-RIGHT')
		triggerEvent('Change Character', 'bf', 'bf-perspectiveLeft')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') + 300, getProperty('dadGroup.y') + 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 0, getProperty('boyfriendGroup.y') + 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) then
				if not def.animated then
					removeLuaSprite(def.name, true)
				end
				setProperty(def.name .. 'fire.alpha', 0.001)
			end
		end

		for _, def in ipairs(xeno) do
			if not (def.lowQualityHide and lowQuality) then
				setProperty(def.name .. '.visible', true)
				setProperty(def.name .. '.flipX', true)
				if not def.animated then
					setProperty(def.name .. 'fire.flipX', true)
					setProperty(def.name .. 'fire.alpha', 0.001)
				end
			end
		end

		removeLuaSprite('staticx', true)

	elseif phase == 'xeno3' then
		if onFlashback then triggerEvent('flashbackstt', '', '') end

		triggerEvent('Change Character', 'dad', 'BEAST')
		triggerEvent('Change Character', 'bf', 'bf-perspective-right')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') + 400, getProperty('dadGroup.y') + 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 100, getProperty('boyfriendGroup.y') + 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) and not def.animated then
				removeLuaSprite(def.name .. 'fire', true)
			end
		end

		for _, def in ipairs(xeno) do
			if not (def.lowQualityHide and lowQuality) then
				if def.animated then
					setProperty(def.name .. '.visible', true)
				end
				if not def.animated then
					setProperty(def.name .. 'fire.visible', true)
					setProperty(def.name .. 'fire.flipX', false)
				end
			end
		end

		setProperty('vg.visible', true)

		if not lowQuality then
			removeLuaSprite('bgxfire', true)
			removeLuaSprite('trees4x', true)
			removeLuaSprite('trees3x', true)
			removeLuaSprite('fire4x', true)
			removeLuaSprite('trees2x', true)
		end

	elseif phase == 'knux' then
		triggerEvent('Change Character', 'dad', 'knux')
		triggerEvent('Change Character', 'bf', 'bf-mirror')
		triggerEvent('Knux', '', '')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') - 300, getProperty('dadGroup.y') - 550})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') - 300, getProperty('boyfriendGroup.y') - 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) and not def.animated then
				setProperty(def.name .. '.visible', true)
				setProperty(def.name .. '.flipX', true)
			end
		end
		setGroupVisible(xeno, false)

		if not lowQuality then
			setProperty('trees1.x', getProperty('trees1.x') + 150)
			setProperty('trees2.x', getProperty('trees2.x') + 50)
			setProperty('trees3.x', getProperty('trees3.x') + 500)
			setProperty('trees4.x', getProperty('trees4.x') + 100)
		end

		curSect = 'knux'

	elseif phase == 'egg' then
		triggerEvent('Change Character', 'dad', 'eggman')
		triggerEvent('Change Character', 'bf', 'bf')
		triggerEvent('Knux', '', '')

		callMethod('dadGroup.setPosition', {getProperty('dadGroup.x') - 350, getProperty('dadGroup.y') - 500})
		callMethod('boyfriendGroup.setPosition', {getProperty('boyfriendGroup.x') + 200, getProperty('boyfriendGroup.y') - 150})

		for _, def in ipairs(normal) do
			if not (def.lowQualityHide and lowQuality) then
				setProperty(def.name .. '.visible', true)
				if not def.animated then
					setProperty(def.name .. 'fire.alpha', 1)
				end
			end
		end
		for _, def in ipairs(xeno) do
			if not (def.lowQualityHide and lowQuality) then
				setProperty(def.name .. '.visible', false)
				if not def.animated then
					setProperty(def.name .. 'fire.visible', false)
				end
			end
		end

		curSect = 'egg'
	end
	**/
}

function onFireStart()
{
	for (spr in xeno)
	{
		if (spr.isFire && spr.spriteF != null)
		{
			spr.spriteF.visible = true;
			FlxTween.tween(spr.spriteF, {alpha: 1}, Conductor.crochet / (1000 / 8) / playbackRate);
		}
	}
	var fireDur:Float = Conductor.crochet / (1000 / 10) / playbackRate;
	if (xeno[3].sprite != null) FlxTween.tween(xeno[3].sprite, {y: -2700}, fireDur, {ease: FlxEase.cubeOut});
	if (!lq && xeno[6].sprite != null) FlxTween.tween(xeno[6].sprite, {y: 250}, fireDur, {ease: FlxEase.cubeOut});
	if (xeno[8].sprite != null) FlxTween.tween(xeno[8].sprite, {y: 400}, fireDur, {ease: FlxEase.cubeOut});
	if (!lq && xeno[12].sprite != null) FlxTween.tween(xeno[12].sprite, {y: 300}, fireDur, {ease: FlxEase.cubeOut});
	canMakeParticles = true;
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
	p.antialiasing = !lq;
	p.angularVelocity = FlxG.random.float(25, 240);
	p.alpha = hideParticles ? 0 : 1;
	if (FlxG.random.bool()) game.add(p);
	else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), p);
	particleSprites.push(p);
}

function fadeParticles(duration:Float)
{
	canMakeParticles = false;
	var dur:Float = Conductor.crochet / (1000 / duration) / playbackRate;
	for (p in particleSprites)
		FlxTween.tween(p, {alpha: 0}, dur, {onComplete: (_) -> game.remove(p, true)});
	particleSprites = [];
}

function onUpdatePost(elapsed:Float)
{
	frameCounter++;
	if (frameCounter % 30 == 0 && canMakeParticles && !lq)
		spawnParticle();
	if (!lq && fogShader != null)
	{
		shaderTimer += elapsed * playbackRate;
		fogShader.setFloat('iTime', shaderTimer);
	}
}

function goodNoteHitPre(note) if (curBG == 'knux') note.animSuffix = '-knux';

var vgTween:FlxTween = null;
function onBeatHit()
{
	if (curBeat % 4 == 0)
	{
		if (vgTween != null) vgTween.cancel();
		vgTween = FlxTween.tween(vgSpr, {alpha: 1}, Conductor.crochet / 1000 * 2);
	}
	else if (curBeat % 4 == 2)
	{
		if (vgTween != null) vgTween.cancel();
		vgTween = FlxTween.tween(vgSpr, {alpha: 0}, Conductor.crochet / 1000 * 2);
	}

	if (curBG.startsWith('xeno') && curBeat % 2 == 0)
	{
		if (dad.getAnimationName() == 'idle') dad.playAnim('idle', true);
		if (boyfriend.getAnimationName() == 'idle') boyfriend.playAnim('idle', true);
	}
}

function triggerEvent(n, v1, v2) game.triggerEvent(n, v1, v2, Conductor.songPosition);
function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);
function makeBackground(background:Array<BackgroundSprite>, ?makeFire:Bool = false)
{
	for (spriteDef in background)
	{
		var daoffset:Float = 0;
		if (makeFire) daoffset = spriteDef.fireOffset ?? 0;
		var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1] + daoffset);
		if (spriteDef.animation != null)
		{
			sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
			for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
		}
		else
		{
			if (makeFire) sprite.loadGraphic(Paths.image(spriteDef.pathF));
			else sprite.loadGraphic(Paths.image(spriteDef.path));
		}
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]);

		//fuck myself why i need to do this, FUCK KAZU!!!!!!!! Si ok entiendo :C
		sprite.scale.x *= 1.2; sprite.scale.y *= 1.2;
		if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();

		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (makeFire) sprite.visible = false;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		if (spriteDef.flipX != null) sprite.flipX = spriteDef.flipX;
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		if (makeFire) spriteDef.spriteF = sprite; else spriteDef.sprite = sprite;
	}
}