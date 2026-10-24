
import flixel.FlxCameraFollowStyle;
import shaders.ColorSwap;

var chaosBG:Array<BackgroundSprite> = [
	{path: 'bg/4', tag: '4', position: [200, 300],  scale: [1, 1], scroll: [0.7, 0.9]},
	{path: 'bg/3', tag: '3', position: [720, 600], scale: [0.9, 0.9]},
	{path: 'bg/rayo', tag: 'fuente', position: [1840, -180], color: 0xFFCCCCCC, scale: [0.85, 0.8], animation: [{name: 'ramaquin instancia', looped: true}, {name: 'ramaquintranqui', looped: true}]},
	{path: 'bg/rayo', tag: 'fuente', alpha: 0.35, blend: 'add', position: [1840, -180], scale: [0.9, 0.8], animation: [{name: 'ramaquin instancia', looped: true}, {name: 'ramaquintranqui', looped: true}]},
	{path: 'bg/2', tag: '2', position: [720, 600], scale: [0.9, 0.9], layer: 'top'},
	{path: 'bg/sonic', tag: 'sonic', position: [2255, 1640], scale: [0.545, 0.545], layer: 'top', isAtlas: true, animation: [{name: 'intro'}, {name: 'fuentes', indices: [92, 92]}]},
	{path: 'bg/1', tag: 'pillars', position: [1400, 500], scale: [0.9, 1.1], scroll: [1.3, 1.1], layer: 'top'},
	{path: 'bg/puelco', tag: 'cochinito', position: [3900, 2150], scale: [1.2, 1.2], scroll: [1.3, 1.3], front: true, animation: [{name: 'Porker Lewis'}]}
];

var firstTime:Bool = true;
var colorShader:ColorSwap;

var bgCam:FlxCamera;
var camOppOffset:Array = [-400, -500];
var camOpp:FlxCamera;
var camOppBG:FlxSprite;

var black:FlxSprite;

var timeline:Array<{step:Float, callback:Void->Void}> = [
	{
		step: 464, callback: () -> {
			camOpp.active = true;
			FlxTween.tween(camOpp, {x: 40, alpha: 1}, 0.25, {ease: FlxEase.cubeInOut});
			//FlxTween.tween(camOppBG, {alpha: 1}, 0.25, {ease: FlxEase.cubeInOut});
			for(strum in opponentStrums.members) FlxTween.tween(strum, {alpha: 0.25}, 0.5);
		}
	},
	{
		step: 512, callback: () -> {
			FlxTween.tween(camOpp, {width: camOpp.width * 1.1, height: camOpp.height * 1.175}, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(black, {alpha: black.alpha + 0.25}, 0.2);
		}
	},
	{
		step: 516, callback: () -> {
			FlxTween.tween(camOpp, {width: camOpp.width * 1.1, height: camOpp.height * 1.175}, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(black, {alpha: black.alpha + 0.25}, 0.2);
		}
	},
	{
		step: 520, callback: () -> {
			FlxTween.tween(camOpp, {width: camOpp.width * 1.1, height: camOpp.height * 1.175}, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(black, {alpha: black.alpha + 0.25}, 0.2);
		}
	},
	{
		step: 524, callback: () -> {
			FlxTween.tween(camOpp, {width: camOpp.width * 1.1, height: camOpp.height * 1.175}, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(black, {alpha: black.alpha + 0.25}, 0.2);
		}
	},
	{
		step: 529, callback: () -> {
			camOpp.target = null;

			FlxTween.tween(camOpp, {x: camGame.x, y: camGame.y, width: camGame.width, height: camGame.height}, 0.2, {ease: FlxEase.cubeInOut});
			FlxTween.tween(camOpp, {"scroll.x": camGame.scroll.x, "scroll.y": camGame.scroll.y, zoom: camGame.zoom, "targetOffset.x": camGame.targetOffset.x, "targetOffset.y": camGame.targetOffset.y}, 0.2, {ease: FlxEase.cubeInOut});
			FlxTimer.wait(0.2, () -> {
				camOpp.active = false;
				camOpp.alpha = 0;
				black.alpha = 0;
			});

			for(strum in opponentStrums.members) FlxTween.tween(strum, {alpha: 1}, 0.5);
		}
	},
	{
		step: 1600, callback: () -> {
			camOpp.active = true;
			camOpp.width = FlxG.width / 2 - 80; camOpp.height = 200;
			camOpp.x = -camOpp.width; camOpp.y = 40;
			camOpp.target = dad;
			camOpp.targetOffset.set(camOppOffset[0], camOppOffset[1]);
			camOpp.followLerp = 0.07;
			camOpp.zoom = 0.7;
			camOpp.alpha = 0;

			for(strum in opponentStrums.members) FlxTween.tween(strum, {alpha: 0.1}, 0.2);
			for(strum in opponentStrums.members) FlxTween.tween(strum, {alpha: 1}, 0.5, {startDelay: 1});
			FlxTween.tween(camOpp, {x: 40, alpha: 1}, 0.25, {ease: FlxEase.cubeInOut});
			FlxTween.tween(camOpp, {x: -camOpp.width, alpha: 0}, 0.5, {ease: FlxEase.cubeInOut, startDelay: 0.75, onComplete: () -> {
				camOpp.active = false;
			}});
		}
	},
];

function onCreate()
{
	firstPlay = !PlayState.seenCutscene;

	camOpp = new FlxCamera();
	camOpp.width = FlxG.width / 2 - 80; camOpp.height = 200;
	camOpp.x = -camOpp.width; camOpp.y = 40;
	camOpp.scroll.set(600, 500);
	camOpp.target = dad;
	camOpp.targetOffset.set(camOppOffset[0], camOppOffset[1]);
	camOpp.followLerp = 0.07;
	camOpp.zoom = 0.7;
	camOpp.alpha = 0;
	camOpp.active = false;
	FlxG.cameras.insert(camOpp, 2);

	bgCam = new FlxCamera();
	bgCam.bgColor = 0x0;
	FlxG.cameras.insert(bgCam, 2, false);

	black = new FlxSprite();
	black.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	black.camera = bgCam;
	black.alpha = 0;
	add(black);

	camOppBG = new FlxSprite();
	camOppBG.makeGraphic(camOpp.width + 20, camOpp.height + 20);
	camOppBG.camera = bgCam;
	camOppBG.alpha = 0;
	camOppBG.color = 0xFF000000;
	add(camOppBG);

	colorShader = new ColorSwap();
	colorShader.hue = Math.abs(182 - 48) / 180; // targetColor - baseColor / 180
	colorShader.saturation = -0.2;
	colorShader.brightness = -0.2;

	makeBackground(chaosBG);
	for (spr in chaosBG) {
		if (firstPlay) {
			if (spr.tag == 'sonic') {
				spr.sprite.animation.play('intro', true); 
				spr.sprite.animation.paused = true;
			}
			if (spr.tag == 'fuente') {
				spr.sprite.animation.play('ramaquintranqui', true);
				spr.sprite.offset.set(0, 0);
			}

			switch(spr.tag) {
				case '4', '3', '2', 'pillars':
					spr.sprite.shader = colorShader.shader;
			}
		}
		else {
			if (spr.tag == 'fuente') {
				spr.sprite.animation.play('ramaquin instancia', true);
				spr.sprite.offset.set(75, -25);
			}
		}
	}

	dad.cameras = [camGame, camOpp];
}

function onGameOver()
{
	camOpp.visible = bgCam.visible = false;
}

function onUpdate(e)
{
	if(!camOpp.active) {
		camOppBG.alpha = 0;
		return;
	}
	
	camOppBG.setPosition(camOpp.x - 10, camOpp.y - 10);
	camOppBG.setGraphicSize(camOpp.width + 20, camOpp.height + 20);
	camOppBG.updateHitbox();
	camOppBG.alpha = camOpp.alpha;

	switch(dad.animation.name) {
		case 'singLEFT': camOpp.targetOffset.set(camOppOffset[0] + -75, camOppOffset[1] + 0);
		case 'singDOWN': camOpp.targetOffset.set(camOppOffset[0] + 0, camOppOffset[1] + 150);
		case 'singUP': camOpp.targetOffset.set(camOppOffset[0] + 0, camOppOffset[1] + -130);
		case 'singRIGHT': camOpp.targetOffset.set(camOppOffset[0] + 100, camOppOffset[1] + 60);
		default: camOpp.targetOffset.set(camOppOffset[0], camOppOffset[1]);
	}
}

function onBeatHit()
{
	if (curBeat % 2 == 0) for (spr in chaosBG) if (spr.tag == 'cochinito') spr.sprite.animation.play('Porker Lewis', true);
}

var curEvent;
function onStepHit() {
	if (curEvent == null) curEvent = timeline.shift();
	if(curEvent != null && curStep >= curEvent.step) {
		curEvent.callback();
		curEvent = timeline.shift();
	}
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
			for (spr in chaosBG) if (spr.tag == 'sonic') spr.sprite.animation.play('intro', true);
			FlxG.sound.play(Paths.sound('robot'));
			camGame.flash(0xFFFF0000, 0.7, null, true);

			new FlxTimer().start(0.95, _ -> {
				FlxG.sound.play(Paths.sound('sonicscream'), 0.85);

				new FlxTimer().start(1.22, _ -> {
					for (spr in chaosBG) { 
						if(spr.tag == 'sonic') {
							var idx = members.indexOf(spr.sprite);
							remove(spr.sprite);
							insert(20, spr.sprite); //just behind the fountain floor
						}
					}
				});

				new FlxTimer().start(4, _ -> {
					PlayState.instance.startCountdown();
					FlxG.sound.play(Paths.sound('beam'), 0.6);
					camGame.flash(0xFFFFFFBB, 1, null, true);
					FlxTween.num(0.05, 0.0, 0.75, null, val -> camGame.shake(val, 0.025));
					FlxTween.tween(camHUD, {alpha: 1}, 0.5, {startDelay: 6.5});
					boyfriend.visible = true;

					FlxTween.tween(camGame, {zoom: 0.6}, 0.6, {ease: FlxEase.circOut});

					for (spr in chaosBG) {
						switch(spr.tag) {
							case '4', '3', '2', 'pillars':
								spr.sprite.shader = null;
							case 'fuente':
								spr.sprite.animation.play('ramaquin instancia', true);
								spr.sprite.offset.set(75, -25);
						}
					}
				});
			});
		});
		
		firstTime = false;
		return Function_Stop;
	}
}