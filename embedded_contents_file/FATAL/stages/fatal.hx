import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import objects.Character;
import openfl.display.BlendMode;

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
	@:optional var flip:Array<Bool>;
	@:optional var animation:Array<Dynamic>;
	@:optional var backdrop:Array<Dynamic>;
	@:optional var boopable:Bool;
	@:optional var bopInt:Int;
}

var bgIntro:Array<BackgroundSprite> = [
	{path: "fatality/new/launchbase/fondo1", scale: [4, 4], animation: [{name: "fondo_gif", looped: true}], scroll: [0.2, 0.2]},
	{path: "fatality/new/launchbase/agua1", position: [0, 700], scale: [4, 4], animation: [{name: "agua", looped: true}], scroll: [0.4, 0.4]},
	{path: "fatality/new/launchbase/montanas", position: [-1, 462], scale: [4, 4], scroll: [0.4, 0.4]},
	{path: "fatality/new/launchbase/agua2", position: [0, 800], scale: [4, 4], animation: [{name: "agua2", looped: true}], scroll: [0.5, 0.5]},
	{path: "fatality/new/launchbase/pla", position: [2, -49], scale: [4, 4], scroll: [0.5, 0.5]},
	{path: "fatality/new/bgmask", scale: [4, 4], scroll: [0.8, 0.8], rainMask: true},
	{path: "fatality/new/launchbase/planta", position: [0, 1000], scale: [4, 4], scroll: [0.8, 0.8]},
	{path: "fatality/new/launchbase/piso", position: [0, 1120], scale: [4, 4]}
];

var bgGlitch:Array<BackgroundSprite> = [
	{path: "fatality/new/bgmask", scale: [4, 4], scroll: [0.2, 0.2], canDestroy: false},
	{path: "fatality/new/domain/popupsbg", position: [0, -400], scale: [3, 3], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.2, 0.2], backdrop: [0x01, [-200, 0], [80, 0]]},
	{path: "fatality/new/domain/montañas", position: [73.5, 56], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.4, 0.4], canDestroy: false},
	{path: "fatality/new/domain/popupsbg", position: [0, 100], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.4, 0.4], backdrop: [0x01, [-400, 0], [80, 0]]},
	{path: "fatality/new/domain/edificios", position: [30, 70], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.5, 0.5]},
	{path: "fatality/new/domain/planta2", position: [0, 1000], scale: [4, 4], scroll: [0.8, 0.8]},
	{path: "fatality/new/bgmask", scale: [4, 4], scroll: [0.8, 0.8], rainMask: true},
	{path: "fatality/new/domain/piso2", position: [0, 1120], scale: [4, 4]},
	{path: "fatality/new/domain/piso2fatal", position: [0, 1120], scale: [4, 4], backdrop: [0x01, [-100, 0], [40, 0]]},
	//victims
	{path: "fatality/new/domain/Bot", position: [-1800, 20], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 4},
	{path: "fatality/new/domain/tails", position: [-800, 20], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 2},
	{path: "fatality/new/domain/mecha-and-egg", position: [1700, -80], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 4, flip: [true, false]},
	{path: "fatality/new/domain/knux", position: [300, 20], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 2, flip: [false, false]},
	{path: "fatality/new/bgmask", scale: [4, 4], scroll: [2, 2], canDestroy: false, front: true, rainMask: true}
];

var bgFinal:Array<BackgroundSprite> = [
	{path: "fatality/new/domain/popupsbg", position: [0, -400], scale: [2, 2], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.3, 0.3], backdrop: [0x01, [-600, 0], [80, 0]]},
	{path: "fatality/new/domain/popupsbg", position: [0, 0], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.3, 0.3], backdrop: [0x01, [-1200, 0], [80, 0]]},
	{path: "fatality/new/final/finaledificios", position: [-220, -150], scale: [4, 4], scroll: [0.4, 0.4], animation: [{name: "idle", looped: true, fps: 12}]},
	{path: "fatality/new/final/pops", position: [-220, -150], scale: [4, 4], scroll: [0.6, 0.6], animation: [{name: "idle", looped: true, fps: 12}]},
	{path: "fatality/new/bgmask", scale: [4, 4], scroll: [2, 2], canDestroy: false, front: true, rainMask: true}
	{path: "fatality/new/final/bush", position: [-300, -130], scale: [4, 4], scroll: [0.8, 0.8]},
	{path: "fatality/new/final/floor", position: [-401, -130], scale: [4, 4]}
];

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

//glitch effect lol
var pseudo:ErrorHandledRuntimeShader;
var bgLoad:FlxSprite;
var decimate:ErrorHandledRuntimeShader;
var smear:ErrorHandledRuntimeShader;
var rgbcurves:ErrorHandledRuntimeShader;

var bgMatrix:ErrorHandledRuntimeShader;
var rainShader:ErrorHandledRuntimeShader;

var curBG:String = 'intro';

var targetMatrix:Float = 0.2;
var rainIntensity:Float = 0;
var rainVelocity:Float = 0.5;
var targetRain:Float = 0.2;

var canRain:Bool = false;

function onCreatePost()
{
	FlxG.camera.pixelPerfectRender = true;
	camHUD.pixelPerfectRender = true;

	rainShader = new ErrorHandledRuntimeShader('fatalrain', File.getContent('contents/FATAL/shaders/fatalrain.frag'));
	rainShader.setFloat('rainIntensity', 0);

	makeBackground(bgIntro);
	makeBackground(bgGlitch);
	makeBackground(bgFinal);
	for (spr in bgIntro) if (spr.rainMask != null) { spr.sprite.shader = rainShader; spr.sprite.blend = BlendMode.ADD; }
	for (spr in bgGlitch)
	{
		spr.sprite.visible = false;
		if (spr.rainMask != null) { spr.sprite.shader = rainShader; spr.sprite.blend = BlendMode.ADD; }
	}
	for (spr in bgFinal)
	{
		spr.sprite.visible = false;
		if (spr.rainMask != null) { spr.sprite.shader = rainShader; spr.sprite.blend = BlendMode.ADD; }
	}
	bgGlitch[1].sprite.color = 0xFF474747;
	bgGlitch[3].sprite.color = 0xFFBBBBBB;
	bgFinal[0].sprite.color = 0xFF4D0000;
	bgFinal[1].sprite.color = 0xFFAF0000;

	preloadCharacter(0, 'bf-fatal-tiny');
	preloadCharacter(1, 'true-fatal');

	for (i in 0...8)
	{
		var strum:StrumNote = game.strumLineNotes.members[i];
		if (i < 4)
		{
			strum.texture = 'noteSkins/NOTEFATAL_assets';
			strum.x = 10 + (strum.width * i);
		}
		else strum.x = (FlxG.width - 10 - (strum.width * 4)) + (strum.width * (i - 4));
	}
	for (i in 0...unspawnNotes.length-1)
	{
		var note:Note = game.unspawnNotes[i];
		if (note.mustPress) continue;
		note.texture = 'noteSkins/NOTEFATAL_assets';
	}

	pseudo = new ErrorHandledRuntimeShader('pseudo', File.getContent('contents/FATAL/shaders/pseudo.frag'));
	pseudo.setFloat('sort', 0);
	camGame.filters = [new ShaderFilter(pseudo)]; camHUD.filters = [new ShaderFilter(pseudo)];

	rgbcurves = new ErrorHandledRuntimeShader('rgbcurves', File.getContent('contents/FATAL/shaders/rgbcurves.frag'));

	decimate = new ErrorHandledRuntimeShader('decimate', File.getContent('contents/FATAL/shaders/decimate.frag'));
	decimate.setFloat('amount', 0.3);
	decimate.setFloat('colorize', 0.1);
	decimate.setFloat('speed', 1);
	decimate.setFloat('scale', 1);

	smear = new ErrorHandledRuntimeShader('smear', File.getContent('contents/FATAL/shaders/smear.frag'));

	bgLoad = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
	bgLoad.camera = camOther;
	bgLoad.alpha = 0;
	game.add(bgLoad);
}

var oldMHS:Bool = false;
function onSectionHit()
{
	if (oldMHS != mustHitSection)
	{
		cam.OGZoom = mustHitSection ? 1 : 0.4;
	}
	oldMHS = mustHitSection;
}

function onSongStart() canRain = true;

var _on:Bool = false;
function onBeatHit()
{
	for (spr in bgGlitch) if (curBeat % spr.bopInt == 0 && curBG == 'fatal' && !_on) spr.sprite.animation.play('dance', true);

	if (curBG == 'fatal' && curBeat % 4 == 0) bgMatrix.setFloat('brightint', 1);
}

var _intro:Bool = true;
function onEvent(n,v1)
{
	if (n == 'FatalityFlashin')
	{
		switch(v1)
		{
			case 'xd':
				FlxTween.num(0, 1, Conductor.crochet / 500, null, v -> {
					pseudo.setFloat('sort', v);
				});
			case 'flash':
				canRain = false;
				_intro = false;
				rainVelocity = 1;
				rainShader.setFloat('rainIntensity', 0);
				game.cameraSpeed = 9999;
				new FlxTimer().start(0.1, (_) -> {game.cameraSpeed = 1;});
				camGame.filters = []; camHUD.filters = [];
				for (spr in bgIntro) spr.sprite.destroy();
				for (spr in bgGlitch) spr.sprite.visible = true;

				bgMatrix = new ErrorHandledRuntimeShader('fatal', File.getContent('contents/FATAL/shaders/fatal.frag'));
				bgGlitch[0].sprite.shader = bgMatrix;
				bgMatrix.setFloat('brightint', 0.2);
				curBG = 'fatal';
			case 'rain':
				canRain = !canRain;
				rainShader.setFloat('rainIntensity', 0);
			case 'rgbcurves':
				_on = !_on;
				if (_on)
				{
					for (spr in bgGlitch)
					{
						if (spr.animation != null) spr.sprite.animation.paused = true;
						if (spr.backdrop != null) spr.sprite.velocity.x = 0;
					}
					bgGlitch[1].sprite.color = 0xFFDADADA;
					bgGlitch[3].sprite.color = 0xFFFFFFFF;
					FlxG.camera.shake(0.02, Conductor.crochet / 2000);
					camHUD.shake(0.01, Conductor.crochet / 2000);
					camGame.filters = [new ShaderFilter(rgbcurves)]; camHUD.filters = [new ShaderFilter(rgbcurves)];
				}
				else
				{
					for (spr in bgGlitch) 
					{
						if (spr.animation != null) spr.sprite.animation.paused = false;
						if (spr.backdrop != null) spr.sprite.velocity.x = (spr.backdrop[1] ?? [0, 0])[0];
					}
					bgGlitch[1].sprite.color = 0xFF474747;
					bgGlitch[3].sprite.color = 0xFFBBBBBB;
					camGame.filters = []; camHUD.filters = [];
					FlxTween.cancelTweensOf(bgLoad);
					bgLoad.color = 0xFFFFA023;
					bgLoad.blend = BlendMode.ADD;
					bgLoad.alpha = 0.8;
					FlxTween.tween(bgLoad, {alpha: 0}, Conductor.crochet / (1000 / 4));
				}
			case 'shakeonly':
				FlxG.camera.shake(0.02, Conductor.crochet / 2000);
				camHUD.shake(0.01, Conductor.crochet / 2000);
			case 'piratesection':
				//sx
			case 'backontrack':
				//eo
			case '3rdbg':
				curBG = 'ending';
				for (spr in bgGlitch) if (spr.canDestroy || spr.canDestroy == null) spr.sprite.destroy();
				for (spr in bgFinal) spr.sprite.visible = true;
				changeCharacter('dad', 'true-fatal');
				changeCharacter('bf', 'bf-fatal-tiny');
				dad.setPosition(-224, 0);
				boyfriend.setPosition(-8, 750);
				cam.DADx = 0;
				cam.DADy = 200;
				cam.BFx = 0;
				cam.BFy = 600;
				game.cameraSpeed = 9999;
				new FlxTimer().start(0.1, (_) -> {game.cameraSpeed = 2;});
				targetMatrix = 0.5;
			case 'glitch':
				game.camZoomingDecay = 0;
				camGame.alive = camGame.exists = camHUD.alive = camHUD.exists = false;
				FlxTween.num(0, 1, Conductor.crochet / 500, null, v -> {
					pseudo.setFloat('sort', v);
				});
				bgLoad.color = 0xFFFFFFFF;
				bgLoad.blend = BlendMode.NORMAL;
				FlxTween.cancelTweensOf(bgLoad);
				FlxTween.tween(bgLoad, {alpha: 0.5}, 0.2);
			case 'glitchbgg':
				camGame.filters = [new ShaderFilter(smear)]; camHUD.filters = [new ShaderFilter(smear)];
				for (spr in bgFinal) spr.sprite.shader = decimate; 
				targetRain = 0.5;
				rainVelocity = 2;
				FlxTween.cancelTweensOf(bgLoad);
				bgLoad.destroy();
				camHUD.flash(0xFFFF0000, 1, null, true);
				game.camZoomingDecay = 1;
				camGame.alive = camGame.exists = camHUD.alive = camHUD.exists = true;
				targetMatrix = 1;
				bgFinal[0].sprite.acceleration.x = -1000;
				bgFinal[1].sprite.acceleration.x = -2000;
			case 'scream':
				camGame.filters = [new ShaderFilter(smear), new ShaderFilter(pseudo)]; camHUD.filters = [new ShaderFilter(smear), new ShaderFilter(pseudo)];
				FlxTween.num(0, 2, Conductor.crochet / (1000 / 8), null, v -> {
					pseudo.setFloat('sort', v);
				});
			case 'bluescreen':
				camGame.filters = []; camHUD.filters = [];
				camGame.visible = camHUD.visible = false;
		}
	}
}

var hudShake:Array<Dynamic> = [];
var _iR:Float = 0;
var _iM:Float = 0;
var _iD:Float = 0;
function onUpdatePost(e)
{
	if (canRain)
	{
		if (_intro) rainShader.setFloat('rainIntensity', rainShader.getFloat('rainIntensity') + e / 100);
		else rainShader.setFloat('rainIntensity', FlxMath.bound(rainShader.getFloat('rainIntensity') + e / 10, 0, targetRain));
		_iR += e * rainVelocity;
		rainShader.setFloat('iTime', _iR);
	}

	if (curBG != 'intro')
	{
		_iM += e * (bgMatrix.getFloat('brightint') * 5);
		bgMatrix.setFloat('iTime', _iM);
		bgMatrix.setFloat('brightint', FlxMath.lerp(bgMatrix.getFloat('brightint'), targetMatrix, e * 3));
	}
	if (curBG == 'ending')
	{
		_iD += e;
		decimate.setFloat('iTime', _iD);
		smear.setFloat('amount', FlxG.random.float(0, 0.035));
		smear.setFloat('angle', FlxG.random.float(0, 1));
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);
function makeBackground(background:Array<BackgroundSprite>)
{
	for (spriteDef in background)
	{
		var sprite:FlxSprite;

		if (spriteDef.backdrop != null)
		{
			sprite = new FlxBackdrop(Paths.image(spriteDef.path), spriteDef.backdrop[0] ?? 0x11, (spriteDef.backdrop[2] ?? [0, 0])[0], (spriteDef.backdrop[2] ?? [0, 0])[1]);
			sprite.setPosition((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			sprite.velocity.set((spriteDef.backdrop[1] ?? [0, 0])[0], (spriteDef.backdrop[1] ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
		}
		else
		{
			sprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
			else sprite.loadGraphic(Paths.image(spriteDef.path));
		}
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		sprite.antialiasing = false;
		if (spriteDef.flip != null) {sprite.flipX = (spriteDef.flip ?? [false, false])[0]; sprite.flipY = (spriteDef.flip ?? [false, false])[1]; }
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}