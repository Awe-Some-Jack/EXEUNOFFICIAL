import psychlua.LuaUtils;
import objects.VideoSprite;

final fixedScale:Float = 1.2;
var mazin:Array<BackgroundSprite> = [
	{path: 'mazin/newBG/5', position: [-350, -900], scroll: [0.4, 0.4]},
	{path: 'mazin/newBG/4', position: [1250, 0], scroll: [0.6, 0.6], canRotate: true, color: 0xFFd5d7b8, blend: 'add'},
	{path: 'mazin/newBG/4', position: [1150, 100], scroll: [0.6, 0.6], canRotate: true, color: 0xFFf5de2f, blend: 'add'},
	{path: 'mazin/newBG/4', position: [950, 100], scroll: [0.6, 0.6], scale: [1.3, 1.3, false], canRotate: true, color: 0xFFf5de2f, blend: 'add'},
	{path: 'mazin/newBG/4', position: [800, 150], scroll: [0.6, 0.6], scale: [0.8, 0.8, false], canRotate: true, color: 0xFFd5d7b8, blend: 'add'},
	{path: 'mazin/newBG/3', position: [420, 300], scroll: [0.6, 0.6]},
	{path: 'mazin/newBG/2', position: [-100, -200], scroll: [0.8, 0.8]},
	{path: 'mazin/newBG/1', position: [20, 800]}
];

var BG2:FlxSprite;
var commercial:VideoSprite;

function onCreate()
{
	makeBackground(mazin);
	for (spr in mazin)
	{
		spr.sprite.scale.set(spr.sprite.scale.x * fixedScale, spr.sprite.scale.y * fixedScale);
		spr.sprite.updateHitbox();
		if (spr.canRotate) spr.sprite.origin.set(22 * spr.sprite.scale.x, 383 * spr.sprite.scale.y);
	}

	commercial = new VideoSprite(650, 150, false);
	commercial.onFormat(() -> {
		commercial.scale.set(0.5, 0.7);
		commercial.updateHitbox();
	});
	commercial.alpha = 0.0001;
	commercial.precacheVideo(Paths.video('../images/mazin/commercial'), [VideoSprite.ARG_LOOPING]);
	commercial.onEnd(() -> {commercial.seekToSeconds(0); commercial.play();});
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), commercial);

	BG2 = new FlxSprite(50, 200).loadGraphic(Paths.image('mazin/bg-2'));
	BG2.scale.set(1.2, 1.2); BG2.updateHitbox();
	BG2.alpha = 0.0001;
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), BG2);
}

function onCreatePost()
{
	triggerEvent("Tweening Camera", "250, -800", "0.001, linear");
	triggerEvent("Tween Camera Zoom", "1.1, true", "0.001, linear");
}

var sine:Float = 0;
function onUpdatePost(elapsed)
{
	for (spr in mazin)
	{
		sine += elapsed * 0.1;
		if (spr.sprite.visible && spr.canRotate)
		{
			spr.sprite.angle = Math.sin(sine + (spr.orderNum * 1.5)) * 10;
		}
	}
}

function onEvent(n,v1,v2)
{
	if (n == 'mazinEvents')
	{
		switch(v1)
		{
			case 'cfbg':
				for (spr in mazin) spr.sprite.visible = false;
				BG2.alpha = 1;
				if (commercial?.loadVideo(Paths.video('../images/mazin/commercial'), [VideoSprite.ARG_LOOPING])) commercial.playDelayed();
				commercial.alpha = 1;
			case 'cpbg':
				for (spr in mazin) spr.sprite.visible = true;
				BG2.alpha = 0;
				commercial.alpha = 0;
		}
	}
}


function onGameOverStart()  commercial?.destroy();
function onPause() commercial?.pause();
function onResume() commercial?.resume();