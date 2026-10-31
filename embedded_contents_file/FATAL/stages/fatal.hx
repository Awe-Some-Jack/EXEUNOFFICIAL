import objects.Character;
import openfl.display.BlendMode;
import openfl.geom.Rectangle;
import objects.VideoSprite;
import flixel.text.FlxText;
import DateTools;
import Date;

var bgIntro:Array<BackgroundSprite> = [
	{path: "fatality/new/launchbase/fondo1", scale: [4, 4, false], animation: [{name: "fondo_gif", looped: true}], scroll: [0.2, 0.2]},
	{path: "fatality/new/launchbase/agua1", position: [0, 700], scale: [4, 4, false], animation: [{name: "agua", looped: true}], scroll: [0.4, 0.4]},
	{path: "fatality/new/launchbase/montanas", position: [-1, 462], scale: [4, 4, false], scroll: [0.4, 0.4]},
	{path: "fatality/new/launchbase/agua2", position: [0, 800], scale: [4, 4, false], animation: [{name: "agua2", looped: true}], scroll: [0.5, 0.5]},
	{path: "fatality/new/launchbase/pla", position: [2, -49], scale: [4, 4, false], scroll: [0.5, 0.5]},
	{path: "fatality/new/bgmask", scale: [4, 4, false], scroll: [0.8, 0.8], rainMask: true},
	{path: "fatality/new/launchbase/planta", position: [0, 1000], scale: [4, 4, false], scroll: [0.8, 0.8]},
	{path: "fatality/new/launchbase/piso", position: [0, 1120], scale: [4, 4, false]}
];

var bgGlitch:Array<BackgroundSprite> = [
	{path: "fatality/new/bgmask", scale: [4, 4, false], scroll: [0.2, 0.2], canDestroy: false},
	{path: "fatality/new/domain/popupsbg", position: [0, -400], scale: [3, 3, false], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.2, 0.2], backdrop: ['x', [-200, 0], [80, 0]]},
	{path: "fatality/new/domain/montanas", position: [73.5, 56], scale: [4, 4, false], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.4, 0.4], canDestroy: false},
	{path: "fatality/new/domain/popupsbg", position: [0, 100], scale: [4, 4, false], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.4, 0.4], backdrop: ['x', [-400, 0], [80, 0]]},
	{path: "fatality/new/domain/edificios", position: [30, 70], scale: [4, 4, false], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.5, 0.5]},
	{path: "fatality/new/domain/planta2", position: [0, 1000], scale: [4, 4, false], scroll: [0.8, 0.8]},
	{path: "fatality/new/bgmask", scale: [4, 4, false], scroll: [0.8, 0.8], rainMask: true},
	{path: "fatality/new/domain/piso2", position: [0, 1120], scale: [4, 4, false]},
	{path: "fatality/new/domain/piso2fatal", position: [0, 1120], scale: [4, 4, false], backdrop: ['x', [-100, 0], [40, 0]]},
	//victims
	{path: "fatality/new/domain/Bot", position: [-1800, 20], scale: [4, 4, false], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 4},
	{path: "fatality/new/domain/tails", position: [-800, 20], scale: [4, 4, false], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 2},
	{path: "fatality/new/domain/mecha-and-egg", position: [1700, -80], scale: [4, 4, false], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 4, flip: [true, false]},
	{path: "fatality/new/domain/knux", position: [300, 20], scale: [4, 4, false], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 2, flip: [false, false]},
	{path: "fatality/new/bgmask", scale: [4, 4, false], scroll: [2, 2], canDestroy: false, front: true, rainMask: true}
];

var bgFinal:Array<BackgroundSprite> = [
	{path: "fatality/new/domain/popupsbg", position: [0, -400], scale: [2, 2, false], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.3, 0.3], backdrop: ['x', [-600, 0], [80, 0]]},
	{path: "fatality/new/domain/popupsbg", position: [0, 0], scale: [4, 4, false], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.3, 0.3], backdrop: ['x', [-1200, 0], [80, 0]]},
	{path: "fatality/new/final/finaledificios", position: [-220, -150], scale: [4, 4, false], scroll: [0.4, 0.4], animation: [{name: "idle", looped: true, fps: 12}]},
	{path: "fatality/new/final/pops", position: [-220, -150], scale: [4, 4, false], scroll: [0.6, 0.6], animation: [{name: "idle", looped: true, fps: 12}]},
	{path: "fatality/new/bgmask", scale: [4, 4, false], scroll: [2, 2], canDestroy: false, front: true, rainMask: true}
	{path: "fatality/new/final/bush", position: [-300, -130], scale: [4, 4, false], scroll: [0.8, 0.8]},
	{path: "fatality/new/final/floor", position: [-401, -130], scale: [4, 4, false]}
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

var wallpaperCamera:FlxCamera;
var wallpaperVideo:VideoSprite;

final isMobile:Bool = (buildTarget == 'ios' || buildTarget == 'android');

final desktopFolders:Array<String> = ['Android Studio', 'Memes', 'Godot', 'Funkin Lullaby Reboot', 'videos', 'flowery', 'Mirror Modulation', 'Unofficial'];

function desktopImage(key:String):FlxSprite
{
	return wallpaperSprite(new FlxSprite(0, 0).loadGraphic(Paths.getBitmapData('assets/exe/access/fatal/mobile/' + key + '.webp')));
}

function wallpaperSprite(spr:FlxSprite):FlxSprite
{
	spr.camera = wallpaperCamera;
	game.add(spr);
	return spr;
}

function buildWallpaperDesktop()
{
	for (i in 0...desktopFolders.length)
	{
		var icon:FlxSprite = desktopImage('desktopIcons/1');
		icon.scale.set(0.325, 0.325);
		icon.updateHitbox();
		icon.setPosition(30, (icon.height * i) + (30 * i));

		var label:FlxText = new FlxText(0, 0, 1000, desktopFolders[i]);
		label.setPosition(icon.x - icon.width + 10, icon.y + icon.height + 3);
		label.setFormat(Paths.font('UbuntuSans.ttf'), 100, 0xFFFFFFFF, 'center');
		label.scale.set(0.08, 0.08);
		label.updateHitbox();
		wallpaperSprite(label);
	}

	var bar:FlxSprite = wallpaperSprite(new FlxSprite(0, 0).makeGraphic(FlxG.width, 20, 0xFF1C1C20));
	bar.setPosition(0, FlxG.height - bar.height);

	var mint:FlxSprite = desktopImage('desktopIcons/mint');
	mint.scale.set(0.043, 0.043);
	mint.updateHitbox();
	mint.setPosition(bar.x + 2, bar.y + 2);

	for (i in 1...9)
	{
		var icon:FlxSprite = desktopImage('desktopIcons/' + i);
		icon.scale.set(0.16, 0.16);
		icon.updateHitbox();
		icon.setPosition(10 + (icon.width * i) + (6 * i), bar.y + 2);
	}

	var clock:FlxText = new FlxText(0, 0, 1000, DateTools.format(Date.now(), '%H:%M'));
	clock.setFormat(Paths.font('UbuntuSans.ttf'), 100, 0xFFFFFFFF, 'center');
	clock.scale.set(0.08, 0.08);
	clock.updateHitbox();
	clock.setPosition(FlxG.width - clock.width + 30, bar.y + 8);
	wallpaperSprite(clock);

	var tray:Array<String> = ['volume', 'network', 'printer', 'notifications'];
	var trayX:Float = clock.x + clock.width / 2 - 17;
	for (i in 0...tray.length)
	{
		var icon:FlxSprite = desktopImage(tray[i]);
		icon.scale.set(0.14, 0.14);
		icon.updateHitbox();
		trayX -= icon.width + (i == 0 ? 0 : 8);
		icon.setPosition(trayX, bar.y + 5);
	}

	var mintLine:FlxSprite = wallpaperSprite(new FlxSprite(0, 0).makeGraphic(1, Std.int(bar.height - 2), 0xFF303036));
	mintLine.setPosition(mint.x + 23, mint.y - 1);
}
var popupCam:FlxCamera;
var windowBorder:FlxSprite;
var borderCam:FlxCamera;
var barCam:FlxCamera;

final borderThickness:Int = 6;
final borderLayers:Array<Array<Int>> = [[0xFFFFFFFF, 1], [0xFFC0C0C0, 3], [0xFF808080, 1], [0xFF000000, 1]];

final camWidth:Int = 960;
final camHeight:Int = 720;
final displayWidth:Int = 720;
final displayScale:Float = displayWidth / camWidth;

var targetMatrix:Float = 0.2;
var rainIntensity:Float = 0;
var rainVelocity:Float = 0.5;
var targetRain:Float = 0.2;

var canRain:Bool = false;

function onCreate() {
	if (!isMobile) return;

	wallpaperCamera = new FlxCamera();
	wallpaperCamera.bgColor = 0xFF000000;

	wallpaperVideo = new VideoSprite(0, 0, false);
	wallpaperVideo.onFormat(() -> {
		wallpaperVideo.setGraphicSize(FlxG.width, FlxG.height);
		wallpaperVideo.screenCenter();
	});
	wallpaperVideo.camera = wallpaperCamera;
	game.add(wallpaperVideo);
	var videoLoaded:Bool = wallpaperVideo.loadVideo('assets/exe/access/fatal/mobile/bakamitai.mp4', [VideoSprite.ARG_LOOPING, VideoSprite.ARG_MUTED, VideoSprite.ARG_HW_ACCEL, VideoSprite.ARG_DROP_LATE, VideoSprite.ARG_SKIP_FRAMES]);
	if (videoLoaded) wallpaperVideo.playDelayed();

	buildWallpaperDesktop();

	FlxG.cameras.remove(camGame, false);
	FlxG.cameras.remove(camVideo, false);
	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.remove(camOther, false);
	FlxG.cameras.add(wallpaperCamera, false);
	FlxG.cameras.add(camGame);
	FlxG.cameras.add(camVideo, false);
	FlxG.cameras.add(camHUD, false);
	FlxG.cameras.add(camOther, false);

	camGame.bgColor = 0xFF000000;

	for (cam in [camGame, camVideo, camHUD, camOther])
	{
		cam.setSize(camWidth, camHeight);
		cam.x = (FlxG.width - camWidth) / 2;
		cam.y = (FlxG.height - camHeight) / 2;
		cam.flashSprite.scaleX = cam.flashSprite.scaleY = displayScale;
	}

	borderCam = new FlxCamera();
	borderCam.bgColor = 0x0;
	FlxG.cameras.add(borderCam, false);

	barCam = new FlxCamera();
	barCam.bgColor = 0x0;
	FlxG.cameras.add(barCam, false);
	setVar('barCam', barCam);

	popupCam = new FlxCamera();
	popupCam.bgColor = 0x0;
	FlxG.cameras.add(popupCam, false);
	setVar('popupCam', popupCam);
	setVar('fatalBoxW', displayWidth);
	setVar('fatalBoxH', displayWidth * camHeight / camWidth);
	setVar('fatalBoxX', (FlxG.width - displayWidth) / 2);
	setVar('fatalBoxY', (FlxG.height - displayWidth * camHeight / camWidth) / 2);
	setVar('fatalCamBaseX', (FlxG.width - camWidth) / 2);
	setVar('fatalCamBaseY', (FlxG.height - camHeight) / 2);

	var boxW:Int = Std.int(displayWidth);
	var boxH:Int = Std.int(displayWidth * camHeight / camWidth);
	var borderW:Int = boxW + borderThickness * 2;
	var borderH:Int = boxH + borderThickness * 2;
	windowBorder = new FlxSprite((FlxG.width - boxW) / 2 - borderThickness, (FlxG.height - boxH) / 2 - borderThickness);
	windowBorder.makeGraphic(borderW, borderH, 0x00000000);
	windowBorder.antialiasing = false;
	windowBorder.scrollFactor.set();
	var inset:Int = 0;
	for (layer in borderLayers)
	{
		windowBorder.pixels.fillRect(new Rectangle(inset, inset, borderW - inset * 2, borderH - inset * 2), layer[0]);
		inset += layer[1];
	}
	windowBorder.pixels.fillRect(new Rectangle(borderThickness, borderThickness, boxW, boxH), 0x00000000);
	windowBorder.dirty = true;
	windowBorder.cameras = [borderCam];
	game.add(windowBorder);
}

function onCreatePost()
{
	if (isMobile && !ClientPrefs.data.middleScroll)
	{
		game.comboGroup.x -= (FlxG.width - camWidth) / 2;
		game.comboGroup.y += 100 * (ClientPrefs.data.downScroll ? -1 : 1);
	}

	FlxSprite.defaultAntialiasing = false;
	FlxG.camera.pixelPerfectRender = true;
	camHUD.pixelPerfectRender = true;
	
	if (prefs.shaders)
	{
		rainShader = new ErrorHandledRuntimeShader('fatalrain', File.getContent('contents/FATAL/shaders/fatalrain.frag'));
		rainShader.setFloat('rainIntensity', 0);
	}

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
			if (!ClientPrefs.data.middleScroll) strum.x = 10 + (strum.width * i);
		}
		else if (!ClientPrefs.data.middleScroll) strum.x = ((isMobile ? camWidth : FlxG.width) - 10 - (strum.width * 4)) + (strum.width * (i - 4));
	}
	for (i in 0...unspawnNotes.length-1)
	{
		var note:Note = game.unspawnNotes[i];
		if (note.mustPress) continue;
		note.texture = 'noteSkins/NOTEFATAL_assets';
	}

	if (prefs.shaders)
	{
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
	}

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

	if (curBG == 'fatal' && curBeat % 4 == 0) if (prefs.shaders) bgMatrix.setFloat('brightint', 1);
}

var _intro:Bool = true;
function onEvent(n,v1)
{
	if (n == 'FatalityFlashin')
	{
		switch(v1)
		{
			case 'xd':
				if (prefs.shaders)
					FlxTween.num(0, 1, Conductor.crochet / 500, null, v -> {
						pseudo.setFloat('sort', v);
					});
			case 'flash':
				canRain = false;
				_intro = false;
				rainVelocity = 1;
				if (prefs.shaders) rainShader.setFloat('rainIntensity', 0);
				game.cameraSpeed = 9999;
				new FlxTimer().start(0.1, (_) -> {game.cameraSpeed = 1;});
				if (prefs.shaders) camGame.filters = []; camHUD.filters = [];
				for (spr in bgIntro) spr.sprite.destroy();
				for (spr in bgGlitch) spr.sprite.visible = true;

				if (prefs.shaders)
				{
					bgMatrix = new ErrorHandledRuntimeShader('fatal', File.getContent('contents/FATAL/shaders/fatal.frag'));
					bgGlitch[0].sprite.shader = bgMatrix;
					bgMatrix.setFloat('brightint', 0.2);
				}
				curBG = 'fatal';
			case 'rain':
				canRain = !canRain;
				if (prefs.shaders) rainShader.setFloat('rainIntensity', 0);
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
					if (prefs.shaders) camGame.filters = [new ShaderFilter(rgbcurves)]; camHUD.filters = [new ShaderFilter(rgbcurves)];
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
					if (prefs.shaders) camGame.filters = []; camHUD.filters = [];
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

				if (prefs.shaders)
					FlxTween.num(0, 1, Conductor.crochet / 500, null, v -> {
						pseudo.setFloat('sort', v);
					});

				bgLoad.color = 0xFFFFFFFF;
				bgLoad.blend = BlendMode.NORMAL;
				FlxTween.cancelTweensOf(bgLoad);
				FlxTween.tween(bgLoad, {alpha: 0.5}, 0.2);
			case 'glitchbgg':
				if (prefs.shaders) camGame.filters = [new ShaderFilter(smear)]; camHUD.filters = [new ShaderFilter(smear)];
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
				if (prefs.shaders)
				{
					camGame.filters = [new ShaderFilter(smear), new ShaderFilter(pseudo)]; camHUD.filters = [new ShaderFilter(smear), new ShaderFilter(pseudo)];
					FlxTween.num(0, 2, Conductor.crochet / (1000 / 8), null, v -> {
						pseudo.setFloat('sort', v);
					});
				}
			case 'bluescreen':
				if (prefs.shaders) camGame.filters = []; camHUD.filters = [];
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
	if (windowBorder != null)
	{
		windowBorder.x = (FlxG.width - displayWidth) / 2 - borderThickness + camGame.x - (FlxG.width - camWidth) / 2;
		windowBorder.y = (FlxG.height - displayWidth * camHeight / camWidth) / 2 - borderThickness + camGame.y - (FlxG.height - camHeight) / 2;
	}

	if (prefs.shaders && canRain)
	{
		if (_intro) rainShader.setFloat('rainIntensity', rainShader.getFloat('rainIntensity') + e / 100);
		else rainShader.setFloat('rainIntensity', FlxMath.bound(rainShader.getFloat('rainIntensity') + e / 10, 0, targetRain));
		_iR += e * rainVelocity;
		rainShader.setFloat('iTime', _iR);
	}

	if (curBG != 'intro')
	{
		if (prefs.shaders)
		{
			_iM += e * (bgMatrix.getFloat('brightint') * 5);
			bgMatrix.setFloat('iTime', _iM);
			bgMatrix.setFloat('brightint', FlxMath.lerp(bgMatrix.getFloat('brightint'), targetMatrix, e * 3));
		}
	}
	if (curBG == 'ending')
	{
		if (prefs.shaders)
		{
			_iD += e;
			decimate.setFloat('iTime', _iD);
			smear.setFloat('amount', FlxG.random.float(0, 0.035));
			smear.setFloat('angle', FlxG.random.float(0, 1));
		}
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);

function onEndSong() { 	FlxSprite.defaultAntialiasing = ClientPrefs?.data?.antialiasing; }