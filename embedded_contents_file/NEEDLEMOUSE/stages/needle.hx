import psychlua.LuaUtils;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
import shaders.ColorSwap;
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

var bgNeedle:Array<BackgroundSprite> = [
	{path: 'roundabout/sky', position: [-750, -900], scroll: [0.3, 0.3], shader: true},
	{path: 'roundabout/bg3', position: [-500, -700], scroll: [0.5, 0.5], shader: true},
	{path: 'roundabout/bg2', position: [-600, -550], scroll: [0.65, 0.65], shader: true},
	{path: 'roundabout/lava', position: [0, 880], scale: [1.2, 1.2], scroll: [0.8, 0.8], animation: [{name: 'Dance', looped: true}], shader: true},
	{path: 'roundabout/bg1', position: [-350, -150], scroll: [0.8, 0.8], shader: true},
	{path: 'roundabout/floor', position: [-200, 1080], shader: false},
	{path: 'roundabout/foreground', position: [100, 450], scroll: [1.2, 1.2], front: true, shader: true}
];

var bgLuther:Array<BackgroundSprite> = [
	{path: 'herworld/bg', position: [-750, -900], scroll: [0.3, 0.3]},
	{path: 'herworld/2', position: [300, 180], scroll: [0.45, 0.45]},
	{path: 'herworld/1', position: [0, 300], scroll: [0.5, 0.5]},
	{path: 'herworld/egg', position: [100, 800], scale: [1.2, 1.2], scroll: [0.8, 0.8], front: true},
	{path: 'herworld/knux', position: [3350, 1050], scroll: [1.2, 1.2], front: true},
	{path: 'herworld/luz', position: [900, 200]},
];

var activeSprites:Array<FlxSprite> = [];
var glitch:FlxRuntimeShader;
var colorShader:ColorSwap;
var camGlitch:FlxRuntimeShader;

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

    colorSwap = new ColorSwap();
    colorSwap.hue = -0.04;
    colorSwap.brightness = -0.8;
    colorSwap.saturation = -0.3;

	black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	black.alpha = 0;
	black.camera = game.camHUD;
	game.add(black);

	makeBackground(bgNeedle);
}

var time:Float = 0;
function onUpdate(e) 
{
	time += e;
	glitch.setFloat('iTime', time);
	camGlitch.setFloat('iTime', time);
}

function onEvent(n, v1, v2) {
	if(n == 'Change Character') {
		switch(v2) {
			case 'bf-needle': boyfriend.shader = colorSwap.shader;
			case 'gf-needlemouse': gf.shader = colorSwap.shader;
			case 'atem': 
				dad.setPosition(2600, 700);
				triggerEvent('Set customCamera Position', 'dad', '2700, 650');
			case 'lutherfinal':
				gf.setPosition(2600, 800);
				triggerEvent('Set customCamera Position', 'gf', '2900, 800');
			case 'bf-needlefinal':
				boyfriend.setPosition(1900, 800);
				triggerEvent('Set customCamera Position', 'bf', '2500, 800');
				boyfriend.flipX = false;
		}
	}
}

function onStepHit() {
	if (PlayState.SONG.song == 'Her World') {
		switch(curStep) {
			case 798:	// luther transition
				FlxTween.tween(black, {alpha: 1}, 1.5, {onComplete: _ -> 
				{
					makeBackground(bgLuther); 
					boyfriend.shader = colorSwap.shader;
					gf.shader = colorSwap.shader;
				}});
				FlxTween.num(0, 1, 1.5, null, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
				FlxTween.tween(black, {alpha: 0}, 1.5, {startDelay: 2});
				FlxTween.num(1, 0, 1.5, {startDelay: 2}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});

			case 1269:
				FlxTween.num(0, 0.1, 4.2, {onComplete: () -> {
					camGlitch.setFloat('AMT', 0); 
					camGlitch.setFloat('SPEED', 0);
				}}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v / 2);
				});

			case 2976:	//solo transition
				FlxTween.tween(black, {alpha: 1}, 2, {onComplete: _ -> makeBackground([]) });
				FlxTween.num(0, 1, 2, {onComplete: _ -> {
					camGlitch.setFloat('AMT', 0.0); 
					camGlitch.setFloat('SPEED', 0.0);
					boyfriend.shader = null;
					gf.alpha = 0.0001;
					dad.alpha = 0.0001;
					for(strum in opponentStrums.members) strum.x -= 600;
					for(strum in playerStrums.members) strum.x -= 320;
				}}, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
				FlxTween.tween(black, {alpha: 0}, 5, {startDelay: 5});

			case 3292:
				FlxTween.tween(black, {alpha: 1}, 1.5, {onComplete: _ -> 
				{
					boyfriend.alpha = 0;
					dad.alpha = 1;
				}});
				FlxTween.tween(black, {alpha: 0}, 1, {startDelay: 2.5});


			case 3328:	// atem sings
				for(i => strum in opponentStrums.members) FlxTween.tween(strum, {x: strum.x + 600}, 1.25 - 0.1 * i, {ease: FlxEase.cubeInOut});
				for(i => strum in playerStrums.members) FlxTween.tween(strum, {x: strum.x + 320}, 1.25, {ease: FlxEase.cubeInOut});

			case 3344:	// change bf and luther to final sprites
				//gf.alpha = 1;
				triggerEvent('Change Character', 'BF', 'bf-needlefinal');
				triggerEvent('Change Character', 'GF', 'lutherfinal');
				game.remove(dadGroup);
				game.addBehindGF(dadGroup);
				FlxTween.tween(boyfriend, {alpha: 1}, 1);
				FlxTween.tween(gf, {alpha: 1}, 1);

			case 4768:
				FlxTween.tween(black, {alpha: 1}, 3);
				FlxTween.num(0, 1, 3, null, v -> {
					camGlitch.setFloat('AMT', v); 
					camGlitch.setFloat('SPEED', v);
				});
		}
	}
}

function makeBackground(background:Array<BackgroundSprite>)
{
	for (sprite in activeSprites) 
	{
		game.remove(sprite);
		sprite.destroy();
	}

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
		if(PlayState.SONG.song == 'Her World') sprite.shader = spriteDef?.shader ? glitch : null;
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
		activeSprites.push(sprite);
	}
}