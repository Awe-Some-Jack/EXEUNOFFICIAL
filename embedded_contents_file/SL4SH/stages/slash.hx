var firstBG:Array<BackgroundSprite> = [
	{path: 'newbg/bg', position: [-849, -596], scale: [6, 6], scroll: [0.5, 0.5]},
	{path: 'newbg/eyes', position: [-849, -596], scale: [6, 6], scroll: [0.5, 0.5], animation: [{name: 'idle', fps: 12, looped: false}]},
	{path: 'newbg/bg2', position: [-953, -660], scale: [6, 6], scroll: [0.75, 0.75]},
	{path: 'newbg/floor', position: [-1056, -726], scale: [6, 6]},
	{path: 'newbg/lava', position: [-1056, -726], scale: [6, 6], animation: [{name: 'idle', fps: 12, looped: true}]},
	{path: 'newbg/zzz', position: [-1056, -726], scale: [6, 6], animation: [{name: 'idle', fps: 12, looped: true}], front: true},
	{path: 'newbg/mist', position: [-1056, -726], scale: [6, 6], animation: [{name: 'idle', fps: 12, looped: true}], front: true},
	{path: 'newbg/badnick', position: [-1150, -830], scale: [6, 6], scroll: [1.4, 1.4], front: true, animation: [{name: 'idle', fps: 12, looped: false}]},
	{path: 'newbg/fg', position: [-1150, -830], scale: [6, 6], scroll: [1.4, 1.4], front: true}
];

var secondBG:Array<BackgroundSprite> = [
	{path: 'newbg/bg2slash', position: [-950, -526], scale: [6, 6], animation: [{name: 'Bg2W', fps: 12, looped: true}]},
];

var intro:FlxSprite;
var bgChanged:Bool = false;
function onCreate()
{
	intro = new FlxSprite(-849, -4436);
	intro.frames = Paths.getSparrowAtlas('newbg/backslashintro');
	intro.animation.addByPrefix('idle', 'idle', 12, false);
	intro.scrollFactor.set(0.5, 0.5);
	intro.scale.set(6, 6); intro.updateHitbox();
	intro.antialiasing = false;
	add(intro);

	makeBackground(firstBG);
	firstBG[1].sprite.animation.paused = true;
	firstBG[7].sprite.visible = false;

	makeBackground(secondBG);
	secondBG[0].sprite.animation.paused = true;
	secondBG[0].sprite.visible = false;
	
	for (i in 0...firstBG.length) //Fuck antialiasing
		firstBG[i].sprite.antialiasing = false;
	
	secondBG[0].sprite.antialiasing = false;
	
	
	camHUD.alpha = 0;
	PlayState.instance.defaultCamZoom = 0.55;
	game.cameraSpeed = 0;
	camGame.targetOffset.set(250, -8000);
}

function onEvent(n, v1, v2) {
	if (n != "slashchangeBG") return;

	bgChanged = true;
	
	for (i in 0...firstBG.length)
		firstBG[i].sprite.destroy();
	
	secondBG[0].sprite.visible = true;
	secondBG[0].sprite.animation.play('Bg2W', true);

	game.triggerEvent("Set customCamera Position", "dad", "-40, 200");
}

function onSongStart()
{
	FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / (1000 / 8), {ease: FlxEase.expoIn});
	FlxTween.num(0, 1, Conductor.crochet / 250, {ease: FlxEase.cubeIn}, v -> game.cameraSpeed = v);
	new FlxTimer().start(4, _ -> intro.destroy());
	intro.animation.play('idle', true);
}

var oldMHS:Bool = false;
function onSectionHit()
{
	if (oldMHS != mustHitSection && !bgChanged)
	{
		if (mustHitSection)
			firstBG[1].sprite.animation.play('idle', true, false);
		else
			firstBG[1].sprite.animation.play('idle', true, true);
	}

	if (curSection % 16 == 2 && !bgChanged)
	{
		firstBG[7].sprite.visible = true;
		firstBG[7].sprite.animation.play('idle', true);
	}

	oldMHS = mustHitSection;
}