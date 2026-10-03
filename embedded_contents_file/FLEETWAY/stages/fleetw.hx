
var chaosBG:Array<BackgroundSprite> = [
	{path: 'bg/chaos plaze olders/bg', position: [-50, 150], scale: [0.694, 0.694], scroll: [0.6, 0.6]},
	{path: 'bg/chaos plaze olders/floor', position: [720, 980], scale: [0.694, 0.694]},
	{path: 'bg/chaos plaze olders/fuentes', tag: 'fuente', position: [1690, 1680], scale: [0.545, 0.545], front: true, isAtlas: true, animation: [{name: 'intro'}, {name: 'fuentes', indices: [92, 92]}]},
	{path: 'bg/chaos plaze olders/pilar izquierdo', position: [1200, 900], scale: [0.694, 0.694], scroll: [1.3, 1.3], front: true},
	{path: 'bg/chaos plaze olders/pilar derecho', position: [4250, 1160], scale: [0.694, 0.694], scroll: [1.3, 1.3], front: true},
	{path: 'bg/puelco', tag: 'cochinito', position: [3900, 2250], scale: [1.2, 1.2], scroll: [1.3, 1.3], front: true, animation: [{name: 'Porker Lewis'}]}
];

var firstTime:Bool = true;

function onCreate() firstPlay = !PlayState.seenCutscene;
function onCreatePost()
{
	makeBackground(chaosBG);
	if (PlayState.isStoryMode && firstPlay) for (spr in chaosBG) if (spr.tag == 'fuente') {spr.sprite.animation.play('intro', true); spr.sprite.animation.paused = true;}
}

function onBeatHit()
{
	if (curBeat % 2 == 0) for (spr in chaosBG) if (spr.tag == 'cochinito') spr.sprite.animation.play('Porker Lewis', true);
}

function onStartCountdown()
{
	if (!firstPlay) return;
	if (firstTime)
	{
		game.cameraSpeed = 9999;
		boyfriend.visible = false;
		camHUD.alpha = 0;
		camGame.zoom = 1;

		new FlxTimer().start(0.4, _ -> {
			game.cameraSpeed = 1;
			FlxTween.tween(camGame, {zoom: 1.2}, 1.2, {ease: FlxEase.circInOut});
			FlxTween.tween(camGame.targetOffset, {y: 20}, 1.2, {ease: FlxEase.circInOut});
			for (spr in chaosBG) if (spr.tag == 'fuente') spr.sprite.animation.play('intro', true);
			FlxG.sound.play(Paths.sound('robot'));
			camGame.flash(0xFFFF0000, 0.7, null, true);

			new FlxTimer().start(0.9, _ -> {
				FlxG.sound.play(Paths.sound('sonicscream'), 0.85);
				new FlxTimer().start(4, _ -> {
					PlayState.instance.startCountdown();
					FlxG.sound.play(Paths.sound('beam'), 0.6);
					camGame.flash(0xFFFFFFBB, 1, null, true);
					FlxTween.tween(camHUD, {alpha: 1}, 1);
					boyfriend.visible = true;

					FlxTween.tween(camGame, {zoom: 0.6}, 0.6, {ease: FlxEase.circOut});
				});
			});
		});
		firstTime = false;
		return Function_Stop;
	}
}