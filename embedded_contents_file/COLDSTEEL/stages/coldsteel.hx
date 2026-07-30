import objects.VideoSprite;
var introCutscene:VideoSprite;
var grad:FlxSprite;
function onCreatePost()
{
	camGame.bgColor = 0xFFFFFFFF;

	grad = new FlxSprite().loadGraphic(Paths.image('grad'));
	grad.scale.set(3000, 1.5); grad.updateHitbox();
	grad.screenCenter();
	addBehindDad(grad);

	camGame.alpha = 0;

	introCutscene = new VideoSprite();
	introCutscene.onFormat(() -> {
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.screenCenter();
		camGame.alpha = 1;
	});
	introCutscene.camera = camVideo;
	game.add(introCutscene);
}

function onSectionHit()
{
	FlxTween.cancelTweensOf(grad);
	grad.color = 0xFFFFB5F0;
	FlxTween.color(grad, 1, 0xFFFFB5F0, 0xFFFFFFFF, {ease: FlxEase.cubeOut});
}

function onDestroy()
{
	camGame.bgColor = 0x0;
}

function onSongStart() if (introCutscene?.loadVideo(Paths.video('intro'))) introCutscene.playDelayed();
function onGameOverStart()  introCutscene?.destroy();
function onPause() introCutscene?.pause();
function onResume() introCutscene?.resume();