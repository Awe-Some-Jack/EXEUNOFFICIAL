import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import objects.VideoSprite;
import objects.Character;
import openfl.display.BlendMode;

final game = PlayState.instance;

//shaders
var rgbShit:ErrorHandledRuntimeShader;
var brightness:ErrorHandledRuntimeShader;

var stars:FlxBackdrop;
var introCutscene:VideoSprite;
var sanicBG:VideoSprite;
var videos:Array<VideoSprite> = [];
var spotlights:Array<FlxSprite> = [];

var topBar:FlxSprite;
var botBar:FlxSprite;

var sanics1:FlxBackdrop;
var sanics2:FlxBackdrop;

var preloadedVideos:Array<VideoSprite> = [];
var precacheVideos:Array<String> = [
	'Mlg',
	'Explosion',
	'Glasses',
	'Weed',
	'Guns',
	'Hitmarkers',
	'OHHH',
	'teletubby',
	'Noscope',
	'smg4',
	'Illuminaticonfirmed'
];

final prefs = ClientPrefs.data;
var oldGT:Bool = false;
var sanicSentimental:Character;
var bfSentimental:Character;
function onCreate()
{
	camGame.alpha = 0; camHUD.alpha = 0;
	introCutscene = new VideoSprite();
	introCutscene.camera = camVideo;
	introCutscene.onFormat(() -> {
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.screenCenter();
		introCutscene.video.antialiasing = ClientPrefs.data.antialiasing;
	});
	introCutscene.onEnd(() -> {camGame.alpha = 1; introCutscene.destroy();});
	add(introCutscene);
	videos.push(introCutscene);

	sanicBG = new VideoSprite(-1700, -1100);
	sanicBG.onFormat(() -> { 
		sanicBG.scale.set(1.5, 1.5);
		sanicBG.updateHitbox();
		sanicBG.video.antialiasing = ClientPrefs.data.antialiasing;
	});
	sanicBG.onEnd(() -> {sanicBG.destroy();});
	insert(0, sanicBG);
	videos.push(sanicBG);
	sanicBG.precacheVideo(Paths.video('bg${FlxG.random.int(1,2)}'), [VideoSprite.ARG_MUTED]);

	stars = new FlxBackdrop(null, FlxAxes.XY);
	stars.drawBlit = false;
	stars.frames = Paths.getSparrowAtlas('star');
	stars.scale.set(2, 2); stars.updateHitbox();
	stars.antialiasing = false;
	stars.animation.addByPrefix('idle', 'idle', 6, true);
	stars.animation.play('idle', true);
	//insert(1, stars);

	for (s in 0...2)
	{
		var spotlight:FlxSprite = new FlxSprite(-320 + (900 * s), -700).loadGraphic(Paths.image('spotlight'));
		spotlight.scale.set(1.5, 2.5); spotlight.updateHitbox();
		spotlight.alpha = 0;
		spotlight.blend = BlendMode.ADD;
		spotlights.push(spotlight);
		game.add(spotlight);
	}

	//shaders
	rgbShit = new ErrorHandledRuntimeShader('Gay', File.getContent('contents/SANIC/shaders/Gay.frag'));
	brightness = new ErrorHandledRuntimeShader('brightness', File.getContent('contents/SANIC/shaders/brightness.frag'));
	brightness.setFloat('saturation', 1);
	brightness.setFloat('brightness', 0);
	brightness.setFloat('contrast', 1);
	camGame.filters = camHUD.filters = [new ShaderFilter(brightness)];

	//precache
	preloadCharacter(1, 'supersanic');
	preloadCharacter(0, 'bfsanicmgl');
	preloadCharacter(1, 'sanicsad');
	preloadCharacter(0, 'bfsanicsad');

	sanics2 = new FlxBackdrop(Paths.image('characters/sanic'), 0x01);
	sanics2.frames = Paths.getSparrowAtlas('characters/sanic');
	sanics2.animation.addByPrefix('singLEFT', 'left', 24, false);
	sanics2.animation.addByPrefix('singDOWN', 'down', 24, false);
	sanics2.animation.addByPrefix('singUP', 'up', 24, false);
	sanics2.animation.addByPrefix('singRIGHT', 'right', 24, false);
	sanics2.animation.addByPrefix('idle', 'idle', 24, false); sanics2.animation.play('idle', true);
	sanics2.alpha = 0.0001;
	sanics2.scale.set(0.5, 0.5); sanics2.updateHitbox();
	sanics2.velocity.x = 1000;
	insert(game.members.indexOf(dadGroup), sanics2);

	sanics1 = new FlxBackdrop(Paths.image('characters/sanic'), 0x01);
	sanics1.frames = Paths.getSparrowAtlas('characters/sanic');
	sanics1.animation.addByPrefix('singLEFT', 'left', 24, false);
	sanics1.animation.addByPrefix('singDOWN', 'down', 24, false);
	sanics1.animation.addByPrefix('singUP', 'up', 24, false);
	sanics1.animation.addByPrefix('singRIGHT', 'right', 24, false);
	sanics1.animation.addByPrefix('idle', 'idle', 24, false); sanics1.animation.play('idle', true);
	sanics1.alpha = 0.0001;
	sanics1.y = 100;
	sanics1.scale.set(0.8, 0.8); sanics1.updateHitbox();
	sanics1.velocity.x = 2000;
	insert(game.members.indexOf(dadGroup), sanics1);

	topBar = new FlxSprite(-50, -100).makeGraphic(FlxG.width + 100, 100, 0xFF000000);
	topBar.camera = camVideo;
	insert(0, topBar);

	botBar = new FlxSprite(-50, FlxG.height).makeGraphic(FlxG.width + 100, 100, 0xFF000000);
	botBar.camera = camVideo;
	insert(0, botBar);

	sanicSentimental = new Character(-1300, 400, 'sanicsad', false);
	sanicSentimental.camera = camOther;
	sanicSentimental.alpha = 0;
	sanicSentimental.scale.set(2.5, 2.5); sanicSentimental.updateHitbox();
	add(sanicSentimental);

	bfSentimental = new Character(1700, 400, 'bfsanicsad', true);
	bfSentimental.camera = camOther;
	bfSentimental.alpha = 0;
	bfSentimental.scale.set(2.5, 2.5); bfSentimental.updateHitbox();
	add(bfSentimental);
}

function onCreatePost()
{
	game.canReset = false;
	oldGT = prefs.ghostTapping;

	var bandicam:FlxSprite = new FlxSprite(0, 5).loadGraphic(Paths.image('bandimark'));
	bandicam.camera = camOther;
	bandicam.scale.set(1.2, 1.2); bandicam.updateHitbox();
	bandicam.alpha = 0.5;
	bandicam.screenCenter(0x01);
	add(bandicam);

	preloadedVideos = [];
	for (v in precacheVideos) preloadedVideos.push(makePreloadedVideo(v));
}

function makePreloadedVideo(name:String):VideoSprite
{
	var video:VideoSprite = new VideoSprite(0, 0, false);
	video.camera = camHUD;
	video.onFormat(() -> {
		video.setGraphicSize(FlxG.width, FlxG.height);
		video.screenCenter();
		video.video.antialiasing = ClientPrefs.data.antialiasing;
	});
	video.video.antialiasing = ClientPrefs.data.antialiasing;
	video.video.shader = new ErrorHandledRuntimeShader('GreenScreenShader', File.getContent('contents/SANIC/shaders/GreenScreenShader.frag'));
	video.onEnd(() -> {
		remove(video);
		video.stop();
	});
	if (!video.loadVideo(Paths.video(name), [VideoSprite.ARG_MUTED])) return null;
	add(video);
	video.alpha = 0.0001;
	video.play();
	return video;
}

var iTime:Float = 0;
function onUpdatePost(e)
{
	iTime += e;
	rgbShit.setFloat('iTime', iTime);

	sanicSentimental.animation.play(dad.getAnimationName(), true);
	sanicSentimental.animation.curAnim.curFrame = dad.animation.curAnim.curFrame;
	sanicSentimental.offset.set(dadGroup.members[0].offset.x, dadGroup.members[0].offset.y);
	bfSentimental.animation.play(boyfriend.getAnimationName(), true);
	bfSentimental.animation.curAnim.curFrame = boyfriend.animation.curAnim.curFrame;
	bfSentimental.offset.set(boyfriendGroup.members[0].offset.x, boyfriendGroup.members[0].offset.y);

	if (sanics1.alpha < 0.01) return;
	sanics1.animation.play(dad.getAnimationName(), true);
	sanics1.animation.curAnim.curFrame = dad.animation.curAnim.curFrame;
	sanics1.offset.set(dadGroup.members[0].offset.x, dadGroup.members[0].offset.y);
	sanics2.animation.play(dad.getAnimationName(), true);
	sanics2.animation.curAnim.curFrame = dad.animation.curAnim.curFrame;
	sanics2.offset.set(dadGroup.members[0].offset.x, dadGroup.members[0].offset.y);
}

var _xd:String = 'normal';
var brightTween:FlxTween;
function onEvent(n,v1,v2)
{
	if (n == 'bright zoom')
	{
		if (brightTween?.active ?? false) brightTween.cancel();
		brightTween = FlxTween.num(0.2, 0, Conductor.crochet / 250, {ease: FlxEase.cubeOut}, v -> {
			brightness.setFloat('brightness', v);
			brightness.setFloat('contrast', 1 + (v * 3.12));
		});
	}
	if (n == 'sanicEvent')
	{
		switch(v1)
		{
			case 'hud':
				if (sanicBG?.loadVideo(Paths.video('bg${FlxG.random.int(1,2)}'), [VideoSprite.ARG_MUTED])) sanicBG?.playDelayed();
				FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 250);
			case 'removeintro':
				game.canReset = true;
				prefs.ghostTapping = true;
				camGame.alpha = 1;
				introCutscene.stop();
				introCutscene.destroy();
			case 'fadein':
				camGame.fade(0x75FFFFFF, 1, false, null, true);
			case 'flash':
				camGame.fade(0x00FFFFFF, 0.0001, false, null, true);
				camGame.flash(0x75FFFFFF, 1, null, true);
			case 'sentimental':
				sanicBG.alpha = 0.4;
				camGame.flash(0xFFFFFFFF, 1, null, true);
				changeCharacter('dad', 'sanicsad');
				changeCharacter('bf', 'bfsanicsad');
				for (s in spotlights) s.alpha = 0.35;
			case 'bfsent':
				FlxTween.tween(sanicSentimental, {alpha: 0.5, x: -300}, 6, {ease: FlxEase.cubeOut});
				FlxTween.tween(bfSentimental, {alpha: 0.5, x: 1000}, 6, {ease: FlxEase.cubeOut});
			case 'fadespotlight':
				camGame.fade(0x75FFFFFF, Conductor.crochet / 250, false, null, true);
				FlxTween.tween(spotlights[0], {alpha: 0}, Conductor.crochet / 500, {ease: FlxEase.cubeIn});

				FlxTween.cancelTweensOf(sanicSentimental); FlxTween.cancelTweensOf(bfSentimental);
				FlxTween.tween(sanicSentimental, {alpha: 0, x: -1300}, 1, {ease: FlxEase.cubeIn});
				FlxTween.tween(bfSentimental, {alpha: 0, x: 1700}, 1, {ease: FlxEase.cubeIn});
			case 'mgl':
				sanics1.alpha = sanics2.alpha = 1;
				game.gameplayCam.settings.DADy = 100;
				_xd = 'mgl';
				camGame.fade(0x00FFFFFF, 0.0001, false, null, true);
				camGame.flash(0xFFFFFFFF, 1, null, true);
				for (s in spotlights) s.destroy();
				changeCharacter('dad', 'supersanic');
				changeCharacter('bf', 'bfsanicmgl');
				for (s in spotlights) s.alpha = 0;
				game.triggerEvent('Change Health Damage', '0.035', '', Conductor.songPosition);
				sanicBG.alpha = 1;
				camGame.filters = camHUD.filters = [new ShaderFilter(brightness), new ShaderFilter(rgbShit)];
			case 'normal':
				changeCharacter('bf', 'bfsanic');
				game.triggerEvent('Change Health Damage', '0.007', '', Conductor.songPosition);
				game.gameplayCam.settings.DADy = 300;
				sanics1.alpha = sanics2.alpha = 0;
				_xd = 'normal';
				camHUD.flash(0xFFFFFFFF, 1, null, true);
				camGame.filters = camHUD.filters = [new ShaderFilter(brightness)];

			case 'bars':
				FlxTween.cancelTweensOf(topBar); FlxTween.cancelTweensOf(botBar);

				var split:Array<String> = v2.split(',');
				var duration:Float = (Math.isNaN(Std.parseFloat(split[1])) ? 4 : Std.parseFloat(split[1]));

				FlxTween.tween(topBar, {y: split[0] == '1' ? -50 : -100}, Conductor.crochet / (1000 / duration), {ease: FlxEase.cubeInOut});
				FlxTween.tween(botBar, {y: split[0] == '1' ? FlxG.height - 50 : FlxG.height}, Conductor.crochet / (1000 / duration), {ease: FlxEase.cubeInOut});
			case 'video':
				var split:Array<String> = v2.split(',');
				var name:String = split[0];
				var layer:String = split[1];

				var index:Int = precacheVideos.indexOf(name);
				var video:VideoSprite = (index != -1) ? preloadedVideos[index] : null;
				if (video != null)
				{
					remove(video);
					if (layer == 'front') add(video);
					else insert(0, video);
					
					video.alpha = 1;
					video.setVideoPercent(0);
					video.playDelayed();
				}
		}
	}
}

function onSongStart() if (introCutscene?.loadVideo(Paths.video('Sanic Intro'), [VideoSprite.ARG_MUTED])) introCutscene?.playDelayed();
function onGameOverStart() 
{
	for (video in videos) video?.destroy();
	for (video in preloadedVideos) video?.destroy();
}
function onPause() 
{
	for (video in videos) video?.pause();
	for (video in preloadedVideos) video?.pause();
}
function onResume() 
{
	for (video in videos) video?.resume();
	for (video in preloadedVideos) video?.resume();
}

function onBeatHit()
{
	for (char in [boyfriend, dad])
	{
		if (char.getAnimationName() == 'idle' && char.animation.curAnim.curFrame > 3 && curBeat % 2 == 0) char.playAnim('idle', true);
	}
}

function onSectionHit()
{
	if (_xd != 'mgl') return;
	for (i in 0...8)
	{
		FlxTween.cancelTweensOf(strumLineNotes.members[i]);
		strumLineNotes.members[i].angle = 0;
		FlxTween.tween(strumLineNotes.members[i], {angle: 360}, 1, {ease: FlxEase.cubeOut});
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);
function onDestroy() prefs.ghostTapping = oldGT;