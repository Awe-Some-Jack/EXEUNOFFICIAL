import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
var bg:FlxSprite;
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

var bgCamera:FlxCamera;

function onCreate()
{
	oldGT = prefs.ghostTapping;

	setupCameras();

	if (prefs.shaders)
	{
		brightness = new ErrorHandledRuntimeShader('brightness', File.getContent('contents/LORD X/shaders/brightness.frag'));
		brightness.setFloat('saturation', 1);
		brightness.setFloat('brightness', 0);
		brightness.setFloat('contrast', 1);

		pixelShader = new ErrorHandledRuntimeShader('pixel', File.getContent('contents/LORD X/shaders/pixel.frag'));
		pixelShader.setFloat('pixelsize', 0);

		cloneImage = new ErrorHandledRuntimeShader('CloneImageError', File.getContent('contents/LORD X/shaders/CloneImageError.frag'));
		cloneImage.setFloat('interval', Conductor.stepCrochet / 1000);

		antiPiracy = new ErrorHandledRuntimeShader('AntiPiracyShader', File.getContent('contents/LORD X/shaders/AntiPiracyShader.frag'));

		glitch = new ErrorHandledRuntimeShader('glitch', File.getContent('contents/LORD X/shaders/glitch.frag'));
		glitch.setFloat('prob', 0);

		glitch2 = new ErrorHandledRuntimeShader('individualGlitches', File.getContent('contents/LORD X/shaders/individualGlitches.frag'));
		glitch2.setFloat('binaryIntensity', 0);

		fishEye = new ErrorHandledRuntimeShader('fisheye', File.getContent('contents/LORD X/shaders/fisheye.frag'));
		fishEye.setFloat('amount', -0.4);
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

	var ring = new FlxSprite(-1090, -500);
	ring.loadGraphic(Paths.image('gottago/ring'));
	ring.scale.set(0.3, 0.3);
	ring.updateHitbox();
	ring.antialiasing = prefs.antialiasing;
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), ring);

	vg = new FlxSprite(0, 0).loadGraphic(Paths.image('VG'));
	vg.updateHitbox();
	vg.color = 0xFF000000;
	vg.alpha = 0.5;
	vg.antialiasing = prefs.antialiasing;
	vg.camera = camHUD;
	vg.screenCenter();
	add(vg);

	black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
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
		bgCamera.filters = [new ShaderFilter(fishEye), new ShaderFilter(brightness), new ShaderFilter(pixelShader), new ShaderFilter(glitch), new ShaderFilter(glitch2)];
		camGame.filters = camHUD.filters = [new ShaderFilter(brightness), new ShaderFilter(pixelShader), new ShaderFilter(glitch), new ShaderFilter(glitch2)];
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

final separation:Float = 50;
function onCreatePost()
{
	for (i in 0...4)
	{
		opponentStrums.members[i].x = -1000;
		playerStrums.members[i].y += (ClientPrefs.data.downScroll ? 10 : -10);
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width) + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i;
	}
}

var savedThings:Array<Float>;
var _phase:String = 'intro';
var _iT:Float = 0;
function onUpdatePost(elapsed:Float)
{
	bgCamera.zoom = camGame.zoom;
	bgCamera.scroll.set(camGame.scroll.x, camGame.scroll.y);

	_iT += elapsed;
	if (_phase == 'clone')
	{
		cloneImage.setFloat('iTime', _iT);

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
					pixelShader.setFloat('pixelsize', v);
				});
			case 'fadeback':
				if (pixelTween?.active ?? false) pixelTween.cancel();
				camHUD.flash(0x55FF0000, 1, null, true);
				pixelShader.setFloat('pixelsize', 0);
				bg.velocity.x = -2000;
				glitch.setFloat('prob', 0.15);
			case 'XD': prefs.ghostTapping = true;
			case 'pauseshit':
				illegalInstruction.visible = true;
				glitch.setFloat('prob', 0.5);
				glitch2.setFloat('binaryIntensity', 6);
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
				if (prefs.shaders)
				{
					bgCamera.filters = [new ShaderFilter(fishEye), new ShaderFilter(brightness), new ShaderFilter(antiPiracy), new ShaderFilter(cloneImage), new ShaderFilter(pixelShader), new ShaderFilter(glitch), new ShaderFilter(glitch2)];
					camGame.filters = camHUD.filters = [new ShaderFilter(brightness), new ShaderFilter(antiPiracy), new ShaderFilter(cloneImage), new ShaderFilter(pixelShader), new ShaderFilter(glitch), new ShaderFilter(glitch2)];
				}
			case 'blackshit':
				illegalInstruction.destroy();
				vg.alpha = 0.75;
				_phase = 'halfway';
				if (prefs.shaders)
				{
					bgCamera.filters = [new ShaderFilter(fishEye), new ShaderFilter(brightness), new ShaderFilter(pixelShader), new ShaderFilter(glitch)];
					camGame.filters = camHUD.filters = [new ShaderFilter(brightness), new ShaderFilter(pixelShader), new ShaderFilter(glitch)];
				}
				bgCamera.visible = false;
				camGame.visible = camHUD.visible = false;
			case 'resumeshit':
				glitch.setFloat('prob', 0.3);
				bg.velocity.x = -2500;
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
				glitch.setFloat('prob', 0.4);
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
				lyrics.x += 100;
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
			brightness.setFloat('brightness', v);
		});
	}
}

function onBeatHit()
{
	if (curBeat % speed == 0)
		glitch.setFloat('time', FlxG.random.float(0,20));
}

function onDestroy() prefs.ghostTapping = oldGT;