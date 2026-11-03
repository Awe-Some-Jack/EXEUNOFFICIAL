import objects.VideoSprite;
var introCutscene:VideoSprite;
var grad:FlxSprite;
function onCreatePost()
{
	camGame.alpha = 0;
	camGame.bgColor = 0xFFFFFFFF;

	grad = new FlxSprite().loadGraphic(Paths.image('grad'));
	grad.scale.set(3000, 1.5); grad.updateHitbox();
	grad.screenCenter();
	addBehindDad(grad);

	introCutscene = new VideoSprite();
	introCutscene.onFormat(() -> {
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.screenCenter();
	});
	introCutscene.camera = camVideo;
	game.add(introCutscene);
	introCutscene.precacheVideo(Paths.video('intro'));
}

function onEvent(n,v1)
{
	if (n == 'Dadbattle Spotlight' && v1 == 'xd')
	{
		introCutscene.destroy();
	}
}

function onSectionHit()
{
	FlxTween.cancelTweensOf(grad);
	grad.color = 0xFFFFB5F0;
	FlxTween.color(grad, 1, 0xFFFFB5F0, 0xFFFFFFFF, {ease: FlxEase.cubeOut});
}

function onDestroy() FlxG.camera.bgColor = 0x0;
function onSongStart()
{
	if (introCutscene?.loadVideo(Paths.video('intro')))
	{
		camGame.alpha = 1;
		introCutscene.playDelayed();
	}
}
function onGameOverStart() { introCutscene?.destroy(); FlxG.camera.bgColor = 0x0; }
function onPause() introCutscene?.pause();
function onResume() introCutscene?.resume();