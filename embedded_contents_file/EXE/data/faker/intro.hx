import flixel.sound.FlxSound;
using StringTools;

var playedCutscene:Bool = false;
var windMusic:FlxSound;
var blackBG:FlxSprite;
var firstTime:Bool = false;
final cam = FlxG.camera;

function onCreate() firstTime = !PlayState.seenCutscene;
function onCreatePost()
{
	if (playedCutscene || !PlayState.isStoryMode || !firstTime) return;
	
	blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackBG.scrollFactor.set();
	game.insert(game.members.indexOf(dadGroup), blackBG);

	game.inCutscene = true;

	cam.zoom = 1;
	cam.targetOffset.x = -305;
	cam.targetOffset.y = 150;

	camHUD.alpha = 0;
}

function onStartCountdown()
{
	if (playedCutscene || !PlayState.isStoryMode || !firstTime) return;
	
	game.remove(dadGroup, true);
	game.insert(game.members.indexOf(boyfriendGroup) + 1, dadGroup);

	dad.playAnim('intro', true);
	getVar('glowfaker').alpha = 0;
	new FlxTimer().start(3, (_) -> {
		FlxTween.tween(getVar('glowfaker'), {alpha: 0.4}, 3, {ease: FlxEase.cubeInOut});
		FlxTween.tween(blackBG, {alpha: 0}, 3, {ease: FlxEase.cubeInOut});
		FlxTween.tween(cam, {zoom: 0.6}, 3, {ease: FlxEase.cubeInOut});
		FlxTween.num(1, 0, 3, {ease: FlxEase.cubeInOut}, n -> {
			cam.targetOffset.x = n * -305;
			cam.targetOffset.y = n * 150;
			cam.snapToTarget();
		});
	});

	windMusic = new FlxSound();
	windMusic.load(Paths.sound('wind'), true);
	FlxG.sound.list.add(windMusic);
	windMusic.volume = 0;
	windMusic.play();
	new FlxTimer().start(1, (_) -> {
		windMusic.fadeIn(3, 0, 0.4);
		new FlxTimer().start(5, (_) -> {
			windMusic.fadeOut(1);
		});
	});

	return Function_Stop;
}

function onCountdownStarted()
{
	if (!firstTime || !PlayState.isStoryMode) return;
	game.skipCountdown = true;
}

function onUpdatePost()
{
	if (playedCutscene || !firstTime || !PlayState.isStoryMode) return;

	blackBG.scale.set(1 / cam.zoom, 1 / cam.zoom);
	if (dad.getAnimationName() == 'intro' && dad.isAnimationFinished())
	{
		FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 500);
		playedCutscene = true;
		game.inCutscene = false;
		game.skipCountdown = false;
		dad.dance();
		game.remove(dadGroup, true);
		game.insert(game.members.indexOf(boyfriendGroup), dadGroup);
		FlxTween.cancelTweensOf(blackBG);
		blackBG.destroy();
		game.startCountdown();
	}

	if (gf.isAnimationFinished()) {gf.dance(); if (gf.getAnimationName() == 'danceLeft') boyfriend.dance();}
}