import psychlua.LuaUtils;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
import objects.VideoSprite;
import flixel.math.FlxAngle;

using StringTools;

typedef BackgroundSprite =
{
	var path:String;
	var sprite:FlxSprite;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool;
	@:optional var visible:Bool;
	@:optional var alpha:Float;
	@:optional var animation:Array<Dynamic>;
}

//! Eventos conforme a la cancion en la parte que aparece sarah con needle
//! Vibracion cuando cambie sprite luther

var activeSprites:Array<FlxSprite> = [];
var glitch:FlxRuntimeShader;
var colorShader:ColorSwap;
var water:FlxRuntimeShader;
var camGlitch:FlxRuntimeShader;
var fireBG:FlxVideoSprite;
var blackCircle:FlxSprite;
var isAtem:Bool = false;
var camZoomingBeat:Bool = false;

var bgNeedle:Array<BackgroundSprite> = [
	{path: 'roundabout/sky', position: [-750, -900], scroll: [0.3, 0.3]},
	{path: 'roundabout/bg3', position: [-500, -700], scroll: [0.5, 0.5]},
	{path: 'roundabout/bg2', position: [-600, -550], scroll: [0.65, 0.65]},
	{path: 'roundabout/lava', position: [0, 880], scale: [1.2, 1.2], scroll: [0.8, 0.8], animation: [{name: 'Dance', looped: true}]},
	{path: 'roundabout/bg1', position: [-350, -150], scroll: [0.8, 0.8]},
	{path: 'roundabout/floor', position: [-200, 1080]},
	{path: 'roundabout/foreground', position: [100, 450], scroll: [1.2, 1.2], front: true}
];

var bgLuther:Array<BackgroundSprite> = [
	{path: 'herworld/bg', position: [-750, -900], scroll: [0.3, 0.3]},
	{path: 'herworld/2', position: [300, 180], scroll: [0.45, 0.45]},
	{path: 'herworld/1', position: [0, 300], scroll: [0.5, 0.5]},
	{path: 'herworld/egg', position: [0, 800], scale: [1.25, 1.1], scroll: [0.8, 0.8], front: true},
	{path: 'herworld/knux', position: [3350, 1050], scroll: [1.25, 1.1], front: true},
];

var stepEvents = [
		{ 
			step: 798, callback: () -> {	// luther transition
				FlxTween.tween(black, {alpha: 1}, 1.5, {onComplete: _ -> makeBackground(bgLuther)});
				FlxTween.num(0, 1, 1.5, null, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
				FlxTween.tween(black, {alpha: 0}, 1.5, {startDelay: 2});
				FlxTween.num(1, 0, 1.5, {startDelay: 2}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
			}
		},
		{
			step: 1216, callback: () -> {
				FlxTween.tween(camHUD, {alpha: 0}, 2, {startDelay: 1.5});
			}
		},
		{ 
			step: 1269, callback: () -> {
			FlxTween.num(0, 0.1, 4.2, {onComplete: () -> {
					camGlitch.setFloat('AMT', 0); 
					camGlitch.setFloat('SPEED', 0);
				}}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v / 2);
				});

				FlxTween.num(1, 0.3, 4.2, {onComplete: () -> {
					FlxTween.num(0.3, 1, 0.5, null, v -> bright.setFloat('saturation', v));
				}}, v -> {
					bright.setFloat('saturation', v);
				});
			}
		},
		{ 
			step: 1312, callback: () -> {
				water.setFloat('waveAmplitude', 0.008);
				FlxTween.tween(camHUD, {alpha: 1}, 1);
			}
		},
		{
			step: 1570, callback: () -> {
				camZoomingBeat = true;
			}
		},
		{
			step: 1824, callback: () -> {
				camZoomingBeat = false;
			}
		},
		{ 
			step: 2176, callback: () -> {
				FlxTween.num(0, 0.3, 3, {ease: FlxEase.cubeIn}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
					camHUD.shake(v/8, 0.1);
					camGame.shake(v/8, 0.1);
				});
			}
		},
		{ 
			step: 2208, callback: () -> {
				camGlitch.setFloat('AMT', 0); 
				camGlitch.setFloat('SPEED', 0);
				water.setFloat('waveAmplitude', 0.02);
			}
		},
		{ 
			step: 2464, callback: () -> {
				FlxTween.num(0.02, 0.008, 1, null, v -> water.setFloat('waveAmplitude', v));
			},
		},	
		{ 
			step: 2976, callback: () -> {	//solo transition
				triggerEvent('Set customCamera Position', 'bf', '2500, 1000');
				FlxTween.tween(black, {alpha: 1}, 2, {onComplete: _ -> makeBackground([]) });
				FlxTween.num(0, 1, 2, {onComplete: _ -> {
					camGlitch.setFloat('AMT', 0.0); 
					camGlitch.setFloat('SPEED', 0.0);
					game.comboGroup.x = -400;
					camZooming = false;
					gf.alpha = 0.001;
					dad.alpha = 0.001;
					for(obj in [game.getLuaObject('hbBG'), game.getLuaObject('hbHealth'), game.getLuaObject('hbHealth2'), game.getLuaObject('iconBF'), game.getLuaObject('iconOpp'), game.getLuaObject('separatorHealth')]) obj.alpha = 0;
					for(strum in opponentStrums.members) strum.x -= 600;
					for(strum in playerStrums.members) strum.x -= 320;
				}}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
				FlxTween.tween(black, {alpha: 0}, 5, {startDelay: 5});
			}
		},
		{ 
			step: 3292, callback: () -> { //atem transition
				FlxTween.tween(black, {alpha: 1}, 1.5, {onComplete: _ -> 
				{
					dad.alpha = 1;
					gf.alpha = 1;
					boyfriend.alpha = 1;
					camZooming = true;

					triggerEvent('Change Character', 'BF', 'bf-needlefinal');
					triggerEvent('Change Character', 'GF', 'lutherfinal');
					game.remove(dadGroup);
					game.addBehindGF(dadGroup);

					blackCircle = new FlxSprite(0, 0, Paths.image('herworld/black'));
					blackCircle.x = dad.x - blackCircle.width / 2.5;
					blackCircle.y = dad.y - blackCircle.height / 4;
					blackCircle.scale.set(2.6, 4);
					game.addBehindDad(blackCircle);
				}});
				FlxTween.tween(black, {alpha: 0}, 1, {startDelay: 2.5});
			}
		},
		{ 
			step: 3392, callback: () -> {
				for(obj in [game.getLuaObject('hbBG'), game.getLuaObject('hbHealth'), game.getLuaObject('hbHealth2'), game.getLuaObject('iconBF'), game.getLuaObject('iconOpp'), game.getLuaObject('separatorHealth')]) 
					FlxTween.tween(obj, {alpha: 1}, 1);
			}
		},	
		{ 
			step: 3968, callback: () -> {
				game.camZoomingMult = 3;
				game.camZoomingDecay = 1.5;
				camZoomingBeat = true;
				fireBG.play();
				fireBG.alpha = 0.7;
			}
		},
		{ 
			step: 4224, callback: () -> {
				camZoomingBeat = false;
				game.camZoomingMult = 1;
				game.camZoomingDecay = 1;
				FlxTween.tween(white, {alpha: 1}, 1.5);
				for(obj in [game.getLuaObject('hbBG'), game.getLuaObject('hbHealth'), game.getLuaObject('hbHealth2'), game.getLuaObject('iconBF'), game.getLuaObject('iconOpp'), game.getLuaObject('separatorHealth')]) 
					FlxTween.tween(obj, {alpha: 0}, 1.5);
			}
		},
		{ 
			step: 4260, callback: () -> {
				FlxTween.tween(end, {alpha: 1}, 2);
			}
		},
		{ 
			step: 4280, callback: () -> {
				FlxTween.tween(end, {"scale.x": 0.5, "scale.y": 0.5}, 40);
			}
		},
		{ 
			step: 4740, callback: () -> {
				FlxTween.tween(end, {alpha: 0}, 4);
			}
		},
		{ 
			step: 4768, callback: () -> {
				FlxTween.tween(black, {alpha: 1}, 3);
				FlxTween.num(0, 1, 3, null, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
			}
		}
];

//! añadir eventos

function onCreatePost()
{
	glitch = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('glitch')));
	glitch.setFloat('AMT', 0.3);
	glitch.setFloat('SPEED', 0.6);
	glitch.setFloat('wVel', 0.5);
	glitch.setFloat('wIntensity', 0.5);

	camGlitch = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('glitch')));
	camGlitch.setFloat('AMT', 0.0);
	camGlitch.setFloat('SPEED', 0.0);
	camGlitch.setFloat('wVel', 0.1);
	camGlitch.setFloat('wIntensity', 0.1);
	game.camGame.filters.push(new ShaderFilter(camGlitch));
	game.camHUD.filters.push(new ShaderFilter(camGlitch));

	bright = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('brightness')));
	bright.setFloat('brightness', 0);
	bright.setFloat('contrast', 1);
	bright.setFloat('saturation', 1);
	game.camGame.filters.push(new ShaderFilter(bright));
	game.camHUD.filters.push(new ShaderFilter(bright));

	water = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('water')));
	water.setFloat('waveAmplitude', 0.003);
	water.setFloat('waveFrequency', 20);

	fireBG = new VideoSprite(-350, -450, false);
	fireBG.onFormat(() -> { 
		fireBG.scale.set(2.25, 2.25);
		fireBG.updateHitbox();
	});
	fireBG.scrollFactor.set(0.6, 1);
	fireBG.alpha = 0.0001;
	fireBG?.loadVideo(Paths.video('../images/herworld/fire'));
	fireBG.pause();
	fireBG.onEnd(() -> {game.remove(fireBG); fireBG.destroy();});
	game.insert(0, fireBG);

	black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	black.alpha = 0;
	black.camera = game.camHUD;
	game.add(black);

	end = new FlxSprite().loadGraphic(Paths.image('herworld/end'));
	end.scale.set(1.5, 1.5);
	end.alpha = 0.001;
	end.screenCenter();
	end.camera = game.camHUD;
	game.insert(0, end);

	white = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
	white.alpha = 0;
	white.camera = game.camHUD;
	game.insert(0, white);

	game.getLuaObject('exeScoreTxt').visible = false;

	preloadCharacter(0, 'bf-needle');
	preloadCharacter(0, 'luther');
	preloadCharacter(1, 'luther');
	preloadCharacter(1, 'luther2');
	preloadCharacter(1, 'atem');
	preloadCharacter(0, 'bf-needlefinal');
	preloadCharacter(2, 'lutherfinal');

	makeBackground(bgNeedle);
	triggerEvent("Tween Camera Zoom", "1.5, true", "0.001, cubeIn");
	triggerEvent("Tweening Camera", "0, -2000", "0.001, cubeIn");
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);

var brightValue:Float = 0;
var time:Float = 0;
function onUpdate(e) 
{
	time += e;
	glitch.setFloat('iTime', time / 2);
	camGlitch.setFloat('iTime', time);
	water.setFloat('iTime', time);

	bright.setFloat('brightness', brightValue * 2);
	bright.setFloat('contrast', 1 + brightValue * 4);
}


function onEvent(n, v1, v2) {
	var shaderValues = v1.split(',');
    var tweenSettings = v2.split(',');
	if(n == 'Change Character') {
		switch(v2) {
			case 'luther':
				dad.setPosition(1025, 850);
			case 'atem': 
				dad.setPosition(2650, 750);
				triggerEvent('Set customCamera Position', 'dad', '2700, 700');
				isAtem = true;
			case 'lutherfinal':
				gf.setPosition(2650, 830);
				triggerEvent('Set customCamera Position', 'gf', '2800, 800');
			case 'bf-needlefinal':
				boyfriend.setPosition(1850, 870);
				triggerEvent('Set customCamera Position', 'bf', '2600, 800');
				boyfriend.flipX = false;
		}
	}
	else if(n == 'bloomFlash') {
		var ease = Reflect.field(FlxEase, tweenSettings[1]);
		FlxTween.num(Std.parseFloat(shaderValues[0]), Std.parseFloat(shaderValues[1]), Std.parseFloat(tweenSettings[0]), {ease: ease}, v -> brightValue = v);
	}
}

function onSectionHit(section:Dynamic) {
	if(!isAtem) return;

    if(!mustHitSection) 
		triggerEvent("Tween Camera Zoom", "0.8, true", "0.75, cubeOut");
	else 
		triggerEvent("Tween Camera Zoom", "0.65, true", "0.75, cubeOut");
}

var curEvent;
function onStepHit() {
	curEvent ??= stepEvents.shift();
	if(curEvent != null && curStep >= curEvent.step) {
		curEvent.callback();
		curEvent = stepEvents.shift();
	}
}

function onBeatHit() {
	if(camZoomingBeat && curBeat % 4 != 0)
		sectionHit();
}

function makeBackground(background:Array<BackgroundSprite>)
{
	for (sprite in activeSprites) 
	{
		game.remove(sprite);
		sprite.destroy();
	}
	activeSprites = [];

	for (spriteDef in background)
	{
		var sprite:FlxSprite;

		if (spriteDef.backdrop != null)
		{
			sprite = new FlxBackdrop(Paths.image(spriteDef.path), spriteDef.backdrop[0] ?? 0x11);
			sprite.velocity.set((spriteDef.backdrop[1] ?? [0, 0])[0], (spriteDef.backdrop[1] ?? [0, 0])[1]);
			sprite.setPosition((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		}
		else
		{
			sprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
			else sprite.loadGraphic(Paths.image(spriteDef.path));
		}
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.insert(999, sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
		activeSprites.push(sprite);
		
		var name = spriteDef.path.split('/')[1];
		switch(name) {
			case 'sky', 'bg3', 'bg2', 'lava', 'bg1', 'foreground':  sprite.shader = glitch;
			case 'bg', '2', '1': sprite.shader = water;
		}
	}
}