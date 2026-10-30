import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
var bg:FlxSprite;
var bgBlue:FlxSprite;
var ring:FlxSprite;
var ringBlue:FlxSprite;
var vg:FlxSprite;
var black:FlxSprite;
var oldGT:Bool = false;
var lyrics:FlxSprite;

//shaders
var brightness:ErrorHandledRuntimeShader;
var pixelShader:ErrorHandledRuntimeShader;
var cloneImage:ErrorHandledRuntimeShader;
var antiPiracy:ErrorHandledRuntimeShader;
var glitch:ErrorHandledRuntimeShader;
var glitch2:ErrorHandledRuntimeShader;
var fishEye:ErrorHandledRuntimeShader;
var illegalInstruction:FlxSprite;

//gameover vars
var deadBoyfriend:Character;
var deadMusic:FlxSound;
var inGameOver:Bool = false;

var bgCamera:FlxCamera;
function onCreate()
{
	oldGT = prefs.ghostTapping;

	setupCameras();

	GameOverSubstate.characterName = 'redglovegameover';
	GameOverSubstate.deathSoundName = '../music/gameOverStartGo';

	if (prefs.shaders)
	{
		brightness = new ErrorHandledRuntimeShader('brightness', File.getContent('contents/LORD X/shaders/brightness.frag'));
		brightness?.setFloat('saturation', 1);
		brightness?.setFloat('brightness', 0);
		brightness?.setFloat('contrast', 1);

		pixelShader = new ErrorHandledRuntimeShader('pixel', File.getContent('contents/LORD X/shaders/pixel.frag'));
		pixelShader?.setFloat('pixelsize', 0);

		cloneImage = new ErrorHandledRuntimeShader('CloneImageError', File.getContent('contents/LORD X/shaders/CloneImageError.frag'));
		cloneImage?.setFloat('interval', Conductor.stepCrochet / 1000);

		antiPiracy = new ErrorHandledRuntimeShader('AntiPiracyShader', File.getContent('contents/LORD X/shaders/AntiPiracyShader.frag'));

		glitch = new ErrorHandledRuntimeShader('glitch', File.getContent('contents/LORD X/shaders/glitch.frag'));
		glitch?.setFloat('prob', 0);

		glitch2 = new ErrorHandledRuntimeShader('individualGlitches', File.getContent('contents/LORD X/shaders/individualGlitches.frag'));
		glitch2?.setFloat('binaryIntensity', 0);

		fishEye = new ErrorHandledRuntimeShader('fisheye', File.getContent('contents/LORD X/shaders/fisheye.frag'));
		fishEye?.setFloat('amount', -0.4);
	}

	bg = new FlxBackdrop(Paths.image('gottago/bg'), 0x01);
	bg.scale.set(0.9, 0.9);
	bg.updateHitbox();
	bg.y = -600;
	bg.camera = bgCamera;
	bg.scrollFactor.set(0.6, 0.6);
	bg.antialiasing = false;
	bg.velocity.x = -1500;
	add(bg);

	bgBlue = new FlxBackdrop(Paths.image('gameovers/bg'), 0x01);
	bgBlue.scale.set(0.9, 0.9);
	bgBlue.updateHitbox();
	bgBlue.y = -600;
	bgBlue.camera = bgCamera;
	bgBlue.scrollFactor.set(0.6, 0.6);
	bgBlue.antialiasing = false;
	bgBlue.alpha = 0.0001;
	add(bgBlue);

	ring = new FlxSprite(-1090, -500);
	ring.loadGraphic(Paths.image('gottago/ring'));
	ring.scale.set(0.3, 0.3);
	ring.updateHitbox();
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), ring);

	ringBlue = new FlxSprite(-1090, -500);
	ringBlue.loadGraphic(Paths.image('gameovers/ring'));
	ringBlue.scale.set(0.3, 0.3);
	ringBlue.updateHitbox();
	ringBlue.alpha = 0.0001;
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), ringBlue);

	vg = new FlxSprite(0, 0).loadGraphic(Paths.image('VG'));
	vg.updateHitbox();
	vg.color = 0xFF000000;
	vg.alpha = 0.5;
	vg.camera = camHUD;
	vg.screenCenter();
	add(vg);

	black = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
	black.scale.set(8000, 8000);
	black.updateHitbox();
	black.alpha = 0;
	black.camera = camHUD;
	black.screenCenter();
	add(black);

	illegalInstruction = new FlxSprite().loadGraphic(Paths.image('gottago/illegalinstruction'));
	illegalInstruction.scale.set(3, 3);
	illegalInstruction.updateHitbox();
	illegalInstruction.camera = camOther;
	illegalInstruction.antialiasing = false;
	illegalInstruction.visible = false;
	illegalInstruction.setPosition(FlxG.random.float(100, FlxG.width / 2 - illegalInstruction.width), FlxG.random.float(FlxG.height / 2, FlxG.height - illegalInstruction.height - 100));
	add(illegalInstruction);

	lyrics = new FlxSprite(-280, 0);
	lyrics.frames = Paths.getSparrowAtlas('gottago/gottagolyrics');
	lyrics.animation.addByPrefix('idle', 'gottagolyrics', 10, false);
	lyrics.antialiasing = false;
	lyrics.camera = camOther;
	lyrics.scale.set(1.8, 1.8);
	lyrics.updateHitbox();
	lyrics.visible = false;
	add(lyrics);

	boyfriend.alpha = 0;
	if (prefs.shaders)
	{
		FilterPruner.addStatic(bgCamera, fishEye);
		for (cam in [bgCamera, camGame, camHUD])
		{
			FilterPruner.add(cam, brightness, 'brightness', 0);
			FilterPruner.addStatic(cam, antiPiracy, false);
			FilterPruner.addStatic(cam, cloneImage, false);
			FilterPruner.add(cam, pixelShader, 'pixelsize', 0);
			FilterPruner.add(cam, glitch, 'prob', 0);
			FilterPruner.add(cam, glitch2, 'binaryIntensity', 0);
		}
	}
}

function setClonePhaseFilters(active:Bool)
{
	for (cam in [bgCamera, camGame, camHUD])
	{
		FilterPruner.setActive(cam, antiPiracy, active);
		FilterPruner.setActive(cam, cloneImage, active);
	}
}

function setupCameras()
{
	bgCamera = new FlxCamera();

	FlxG.cameras.remove(camGame, false);
	FlxG.cameras.remove(camVideo, false);
	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.remove(camOther, false);
	FlxG.cameras.add(bgCamera, false);
	FlxG.cameras.add(camGame);
	FlxG.cameras.add(camVideo, false);
	FlxG.cameras.add(camHUD, false);
	FlxG.cameras.add(camOther, false);
	camGame.bgColor = 0x0; 
}

var threshold:Float = 1550;
final separation:Float = 50;
function onCreatePost()
{
	for (i in 0...4)
	{
		opponentStrums.members[i].downScroll = true;
		opponentStrums.members[i].scale.set(1.5, 1.5);
		opponentStrums.members[i].x = -opponentStrums.members[i].width - 1000;
		opponentStrums.members[i].y = -190 + ((opponentStrums.members[i].height + 150) * i);
		opponentStrums.members[i].direction = 180;
		opponentStrums.members[i].angle = 90;
		opponentStrums.members[i].camera = bgCamera;
		opponentStrums.members[i].scrollFactor.set(1, 1);
		playerStrums.members[i].y += (ClientPrefs.data.downScroll ? 10 : -10);
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width) + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i;
	}
	for (i in 0...unspawnNotes.length)
	{
		var note:Note = unspawnNotes[i];
		if (note.mustPress) continue;
		note.camera = bgCamera;
		if (!note.isSustainNote || (note.isSustainNote && note.parent != null && note.parent.tail[note.parent.tail.length - 1] == note)) note.scale.set(1.5, 1.5);
		else note.scale.set(1.5, note.scale.y);
		if (note.isSustainNote) note.offsetY = 55;
		if (note.isSustainNote && note.parent != null && note.parent.tail[note.parent.tail.length - 1] == note)
		{
			note.offsetX = -3;
			note.offsetY = 57.5;
		}
		note.copyAngle = false;
		note.color = 0xFF721111;
		note.angle = 90;
		note.multSpeed = Math.abs(bg.velocity.x) / threshold;
		note.scrollFactor.set(1, 1);
	}
}

var toggleOnce:Bool = false;
var savedThings:Array<Float>;
var _phase:String = 'intro';
var _iT:Float = 0;
var _glitchTimer:Float = 0.5;
function onUpdatePost(elapsed:Float)
{
	if (inGameOver)
	{
		_glitchTimer -= elapsed;
		if (_glitchTimer <= 0)
		{
			_glitchTimer = 0.5;
			if (prefs.shaders) glitch?.setFloat('time', FlxG.random.float(0,50));
		}
		if (deadBoyfriend.getAnimationName() == 'deathLoop')
		{
			if (!toggleOnce) {
				toggleOnce = true;
				FlxG.sound.music.stop();
			}
		}
	}

	bgCamera.zoom = camGame.zoom;
	bgCamera.scroll.set(camGame.scroll.x, camGame.scroll.y);

	_iT += elapsed;
	if (_phase == 'clone')
	{
		cloneImage?.setFloat('iTime', _iT);

		game.getLuaObject('iconBF').scale.set(savedThings[0], savedThings[0]);
		game.getLuaObject('iconOpp').scale.set(savedThings[0], savedThings[0]);
		game.getLuaObject('exeScoreTxt').scale.set(savedThings[1], savedThings[1]);

		dad.animation.paused = _phase == 'clone';
		for (i in 0...8) strumLineNotes.members[i].animation.paused = _phase == 'clone';
	}
}

var saveScore:Array<Dynamic> = [];
var speed:Int = 1;
var pixelTween:FlxTween;
var bloomTween:FlxTween;
function onEvent(n, v1, v2)
{
	if (n == 'gottaEvents')
	{
		switch (v1)
		{
			case 'fadeout':
				pixelTween = FlxTween.num(0, 200, Conductor.crochet / 1000, {ease: FlxEase.cubeIn}, v -> {
					pixelShader?.setFloat('pixelsize', v);
				});
			case 'fadeback':
				if (pixelTween?.active ?? false) pixelTween.cancel();
				camHUD.flash(0x55FF0000, 1, null, true);
				pixelShader?.setFloat('pixelsize', 0);
				bg.velocity.x = -2000;
				glitch?.setFloat('prob', 0.15);
				for (i in 0...unspawnNotes.length) if (!unspawnNotes[i].mustPress) unspawnNotes[i].multSpeed = Math.abs(bg.velocity.x) / threshold;
				for (i in 0...notes.length) if (!notes.members[i].mustPress) notes.members[i].multSpeed = Math.abs(bg.velocity.x) / threshold;
			case 'XD': prefs.ghostTapping = true;
			case 'pauseshit':
				illegalInstruction.visible = true;
				glitch?.setFloat('prob', 0.5);
				glitch2?.setFloat('binaryIntensity', 6);
				_iT = 0;
				savedThings = [game.getLuaObject('iconBF').scale.x, game.getLuaObject('exeScoreTxt').scale.x];
				_phase = 'clone';
				game.cpuAssist = true;
				game.camZoomingDecay = 0;
				game.camZoomingMult = 0;
				game.cameraSpeed = 0;
				bg.velocity.x = 0;
				game.noteKillOffset = 9999999999;
				for (i in 0...notes.length) notes.members[i].copyY = false;
				for (i in 0...unspawnNotes.length) unspawnNotes[i].copyY = false;
				if (prefs.shaders) setClonePhaseFilters(true);
			case 'blackshit':
				illegalInstruction.visible = false;
				vg.alpha = 0.75;
				_phase = 'halfway';
				if (prefs.shaders)
				{
					glitch2?.setFloat('binaryIntensity', 0);
					setClonePhaseFilters(false);
				}
				bgCamera.visible = false;
				camGame.visible = camHUD.visible = false;
			case 'resumeshit':
				glitch?.setFloat('prob', 0.3);
				bg.velocity.x = -2500;
				for (i in 0...unspawnNotes.length) if (!unspawnNotes[i].mustPress) unspawnNotes[i].multSpeed = Math.abs(bg.velocity.x) / threshold;
				for (i in 0...notes.length) if (!notes.members[i].mustPress) notes.members[i].multSpeed = Math.abs(bg.velocity.x) / threshold;
				game.camZoomingMult = 1;
				game.cameraSpeed = 1.15;
				game.camZoomingDecay = 1;
				prefs.ghostTapping = oldGT;
				game.noteKillOffset = Math.max(Conductor.stepCrochet, 350 / game.songSpeed * game.playbackRate);
				new FlxTimer().start(1.3, _ -> {game.cpuAssist = false;});
				bgCamera.visible = true;
				camGame.visible = camHUD.visible = true;
				for (i in 0...notes.length) notes.members[i].copyY = true;
				for (i in 0...unspawnNotes.length) unspawnNotes[i].copyY = true;
			case 'lyricslol':
				game.canPause = false;
				lyrics.visible = true;
				lyrics.animation.play('idle', true);
			case 'glitchness':
				FlxTween.tween(vg, {alpha: 1}, 10);
				if (prefs.shaders) glitch?.setFloat('prob', 0.4);
			case 'speed':
				speed = Std.parseInt(v2);
			case 'end':
				bgCamera.visible = false;
				camHUD.visible = false;
				camGame.visible = false;
			case 'l1':
				var p = game.getLuaObject('exeScoreTxt').text.split('|').map(s -> s.split(':'));
				saveScore = [StringTools.trim(p[0][0]), Std.parseInt(StringTools.trim(p[0][1])), StringTools.trim(p[1][0]), Std.parseInt(StringTools.trim(p[1][1]))];
				setVar('canChangeTxt', false);
				game.getLuaObject('exeScoreTxt').text = 'It\'s: ' + saveScore[1] + ' | ' + saveScore[2] + ': ' + saveScore[3];
			case 'l2': game.getLuaObject('exeScoreTxt').text = 'It\'s: gone | ' + saveScore[2] + ': ' + saveScore[3];
			case 'l3': game.getLuaObject('exeScoreTxt').text = 'It\'s: gone | to: ' + saveScore[3];
			case 'l4': game.getLuaObject('exeScoreTxt').text = 'It\'s: gone | to: plan?';
			case 'l5': FlxG.stage.window.title = 'Now';
			case 'l6': FlxG.stage.window.title = 'Now You\'ll';
			case 'l7': FlxG.stage.window.title = 'Now You\'ll see...';
			case 'l8': game.getLuaObject('exeScoreTxt').text = 'Come | to: plan?';
			case 'l9': game.getLuaObject('exeScoreTxt').text = 'Come With: plan?';
			case 'l10': game.getLuaObject('exeScoreTxt').text = 'Come With Me...';
			case 'l11':
				game.getLuaObject('exeScoreTxt').text = 'FAS';
				FlxG.stage.window.title = 'FAS';
				lyrics.x += 80;
			case 'l12':
				game.getLuaObject('exeScoreTxt').text = 'FASTER!';
				FlxG.stage.window.title = 'FASTER!';
			case 'l0':
				FlxG.stage.window.title = PlayState.prevWindowTitle;
				game.canPause = true;
				game.getLuaObject('exeScoreTxt').text = saveScore[0] + ': ' + saveScore[1] + ' | ' + saveScore[2] + ': ' + saveScore[3];
				setVar('canChangeTxt', true);
		}
	}

	if (n == "bloomFlash" && prefs.flashing && prefs.shaders)
	{
		var bloomValues = v1.split(',');
		var tweenSettings = v2.split(',');

		if (bloomTween?.active ?? false) bloomTween.cancel();
		bloomTween = FlxTween.num(Std.parseInt(bloomValues[0]), Std.parseInt(bloomValues[1]), Std.parseInt(tweenSettings[0]), {ease: LuaUtils.getTweenEaseByString(tweenSettings[1])}, v -> {
			brightness?.setFloat('brightness', v);
		});
	}
}

function onBeatHit()
{
	if (prefs.shaders)
		if (curBeat % speed == 0)
			glitch?.setFloat('time', FlxG.random.float(0,50));
}

function onSongStart()
{
	bgBlue.visible = false;
	ringBlue.visible = false;
}

function onDestroy() prefs.ghostTapping = oldGT;

function onGameOverStart()
{
	lyrics.visible = false;
	if (prefs.shaders)
	{

		glitch?.setFloat('prob', 0.45);
		glitch2?.setFloat('binaryIntensity', 0);
		if (bloomTween?.active ?? false) bloomTween.cancel();
		brightness?.setFloat('brightness', 0);
		FilterPruner.setActive(bgCamera, fishEye, false);
		setClonePhaseFilters(false);
		pixelShader?.setFloat('pixelsize', 15);
		if (pixelTween?.active ?? false) pixelTween.cancel();
		pixelTween = FlxTween.num(15, 0, Conductor.crochet / 250, {ease: FlxEase.cubeOut}, v -> {
			pixelShader?.setFloat('pixelsize', v);
		});
	}

	game.gameplayCam.settings.OverrideZoom = true;
	game.gameplayCam.overrideZoomValue = 0.6;
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	dad.visible = false;
	deadBoyfriend.setPosition(dadGroup.x - 330, dadGroup.y - 30);
	game.camZoomingMult = 0.5;

	FlxG.camera.follow();
	FlxG.camera.targetOffset.set();
	FlxG.camera.scroll.set(game.camFollow.x - (FlxG.width / 2), game.camFollow.y - (FlxG.height / 2));

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverGo'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;
	deadMusic.play();

	game.camHUD.alpha = 0;
	game.camVideo.alpha = 0;
	game.persistentDraw = true;
	game.persistentUpdate = true;
	game.camZoomingMult = 0;
	illegalInstruction.setPosition(FlxG.random.float(100, FlxG.width / 2 - illegalInstruction.width), FlxG.random.float(FlxG.height / 2 + 100, FlxG.height - illegalInstruction.height - 100));
	illegalInstruction.visible = true;

	for (i in 0...notes.length) if (!notes.members[i].mustPress) notes.members[i].color = 0xFF0B0BDD;

	game.generatedMusic = false;

	bgBlue.x = bg.x;
	bgBlue.velocity.x -10;
	bg.destroy();
	ring.destroy();
	bgBlue.visible = ringBlue.visible = true;
	bgBlue.alpha = 1;
	ringBlue.alpha = 1;
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;


		if (prefs.shaders)
		{
			glitch?.setFloat('prob', 0.8);
			glitch2?.setFloat('binaryIntensity', 0.1);
			new FlxTimer().start(0.2, _ -> {glitch2?.setFloat('binaryIntensity', 6);});
			new FlxTimer().start(0.3, _ -> {glitch2?.setFloat('binaryIntensity', 5);});
			new FlxTimer().start(0.6, _ -> {glitch2?.setFloat('binaryIntensity', 8);});
			new FlxTimer().start(0.7, _ -> {glitch2?.setFloat('binaryIntensity', 2);});
			new FlxTimer().start(1, _ -> {glitch2?.setFloat('binaryIntensity', 5);});
			new FlxTimer().start(1.2, _ -> {glitch2?.setFloat('binaryIntensity', 1);});
			new FlxTimer().start(1.3, _ -> {glitch2?.setFloat('binaryIntensity', 7);});
			new FlxTimer().start(1.5, _ -> {glitch2?.setFloat('binaryIntensity', 6);});
		}
		new FlxTimer().start(1.7, _ -> {for (cam in FlxG.cameras.list) cam.alpha = 0;});
		FlxG.camera.flash(0x811414FF, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEndGo'));
		deadMusic.stop();
	}
	else
	{
		for (cam in FlxG.cameras.list) cam.alpha = 0;
		for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
	}
}