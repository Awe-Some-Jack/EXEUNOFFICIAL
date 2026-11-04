// pjflix sucks ass

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import openfl.display.BlendMode;
import minigames.preymini.map.SkyParade;
import minigames.preymini.map.MapLights;
import minigames.preymini.map.SongFloors;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;

var bgGroup:Array<FlxBackdrop> = [];
var lightning:FlxBackdrop;
var floorGroup:Array<FlxSprite> = [];
var floorBGGroup:Array<FlxSprite> = [];
var fg:FlxBackdrop;
var parade:SkyParade;
var lights:MapLights;
var paradeOn:Bool = false;
var frozen:Bool = false;

var rampTimers:Array<FlxTimer> = [];
var rampTweens:Array<FlxTween> = [];

final movementOffset:Int = 220;


var replaceColor:ErrorHandledRuntimeShader;
function onCreate()
{
	if (!prefs.lowQuality)
	{
		replaceColor = new ErrorHandledRuntimeShader('replaceColor', File.getContent(Paths.mods('STARVED/shaders/replaceColor.frag')));
		replaceColor.setFloatArray('targetColor', [255, 255, 168]);
		replaceColor.setFloatArray('replaceColor', [0, 0, 0]);
		for (i in 0...15)
		{
			var bg:FlxBackdrop = new FlxBackdrop(Paths.image('prey/bg/bg' + (i + 1)), FlxAxes.X);
			bg.y = -900;
			bg.antialiasing = false;
			bg.scrollFactor.set(0.2, 0.6);
			bg.scale.set(3, 3); bg.updateHitbox();
			bg.ID = i;
			bg.shader = replaceColor;
			bg.color = 0xFF000000;
			bgGroup.push(bg);
			insert(0, bg);
		}

		lightning = new FlxBackdrop(null, FlxAxes.X);
		lightning.frames = Paths.getSparrowAtlas('prey/bg/sky15-lightning-anim');
		lightning.animation.addByPrefix('idle', 'idle', 12, false); lightning.animation.play('idle', true);
		lightning.y = -900;
		lightning.antialiasing = false;
		lightning.scrollFactor.set(0.2, 0.6);
		lightning.scale.set(3, 3); lightning.updateHitbox();
		lightning.visible = false;
		insert(game.members.indexOf(bgGroup[13]), lightning);

		parade = new SkyParade(layer -> bgGroup[layer - 1].velocity.x, () -> bgGroup[0].y, 3);
		parade.crowd = 2;
		for (i in 0...parade.groups.length)
		{
			parade.groups[i].visible = false;
			insert(game.members.indexOf(bgGroup[SkyParade.LANES[i].layer - 1]) + 1, parade.groups[i]);
		}
		for (atlas in ['Badnik_1', 'Badnik_2', 'Badnik_3', 'Fire_Box', 'Explosion', 'Animal_Burning', 'Animal_Burning2']) Paths.getSparrowAtlas('minigame/preymini/characters/enemys/' + atlas, null, false);
		SkyParade.halo();

		lights = new MapLights();
		for (id in 1...SongFloors.count() + 1) SongFloors.clear(id);
		for (i in 0...2)
		{
			final v = FlxG.random.int(1, SongFloors.count());

			var floorBG:FlxSprite = new FlxSprite(0, -1912).loadGraphic(Paths.image('prey/floor-variants/$v/floor2'));
			floorBG.antialiasing = false;
			floorBG.scale.set(6, 6); floorBG.updateHitbox();
			floorBG.x = i == 0 ? 0 : floorBGGroup[0].x + floorBGGroup[0].width;
			floorBG.color = 0xFF000000;
			floorBGGroup.push(floorBG);
			insert(game.members.indexOf(bgGroup[0]) + 1, floorBG);

			var floor:FlxSprite = new FlxSprite(0, -1912).loadGraphic(Paths.image('prey/floor-variants/$v/floor1'));
			floor.shader = lights.shader;
			floor.antialiasing = false;
			floor.scale.set(6, 6); floor.updateHitbox();
			floor.x = i == 0 ? 0 : floorGroup[0].x + floorGroup[0].width;
			floor.color = 0xFF000000;
			floor.ID = v;
			floorGroup.push(floor);
			add(floor);
		}

		fg = new FlxBackdrop(null, FlxAxes.X, 800);
		fg.frames = Paths.getSparrowAtlas('prey/bg/fg-pilar-anim');
		fg.animation.addByPrefix('idle', 'idle', 8, true); fg.animation.play('idle', true);
		fg.y = -600;
		fg.antialiasing = false;
		fg.scrollFactor.set(1.5, 1.5);
		fg.scale.set(6, 6); fg.updateHitbox();
		fg.color = 0xFF000000;
		add(fg);

		setVar('bgGroup', bgGroup);
		setVar('floorBGGroup', floorBGGroup);
		setVar('floorGroup', floorGroup);
		setVar('fg', fg);
	}
	else
	{
	}

	changeBGVelocity(1);
	setVar('floorY', 420);
	checkTimers(1, -movementOffset);
}

var flashOverlay:FlxSprite;
function onCreatePost()
{
	camGame.pixelPerfectRender = true;
	camHUD.pixelPerfectRender = true;

	flashOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFF99);
	flashOverlay.camera = camOther;
	flashOverlay.alpha = 0;
	flashOverlay.blend = BlendMode.ADD;
	add(flashOverlay);
}

var lightningActive:Bool = false;
function onUpdatePost(elapsed:Float)
{
	if (getVar('ending'))
	{
		if (parade != null) for (group in parade.groups) group.visible = false;
		for (tmr in rampTimers) if (!tmr.finished) tmr.cancel();
		for (twn in rampTweens) if (!twn.finished) twn.cancel();
		return;
	}
	if (frozen) return;

	if (!prefs.lowQuality)
	{
		if (paradeOn) parade.update(elapsed);
		lights.update(elapsed * 2 / 3);

		if (lightningActive)
		{
			if (lightning.animation.curAnim.finished)
			{
				FlxTween.num(0, 1, 2, null, n -> {
					var r = 216 + (9 - 216) * n;
					var g = 108 + (0 - 108) * n;
					var b = 180 + (0 - 180) * n;

					replaceColor.setFloatArray('replaceColor', [r, g, b]);
				});
				lightning.alpha -= (elapsed * 0.75);
			}
			if (lightning.alpha <= 0)
			{
				lightningActive = false;
				lightning.visible = false;
			}
		}

		for (i in 0...floorGroup.length)
		{
			if (floorGroup[i].x + floorGroup[i].width < -1200)
			{
				var right = 0;
				for (floor in floorGroup) right = Math.max(right, floor.x + floor.width);
				final v = FlxG.random.int(1, SongFloors.count());

				floorGroup[i].loadGraphic(Paths.image('prey/floor-variants/$v/floor1'));
				floorGroup[i].updateHitbox();
				floorGroup[i].x = right;
				floorGroup[i].ID = v;

				floorBGGroup[i].loadGraphic(Paths.image('prey/floor-variants/$v/floor2'));
				floorBGGroup[i].updateHitbox();
				floorBGGroup[i].x = right;

				checkTimers(i);
			}
		}
	}

	for (i in rampTimers.length-1...-1) if (rampTimers[i].finished) rampTimers.splice(i, 1);
	for (i in rampTweens.length-1...-1) if (rampTweens[i].finished) rampTweens.splice(i, 1);
}

function checkTimers(?i:Int = 0, ?extraOffset:Float = 0)
{
	clearRampTimers();

	final floor = 1 - i;
	final speed = Math.abs(floorGroup[floor].velocity.x);
	for (ramp in SongFloors.ramps(floorGroup[floor].ID)) scheduleRamp(floor, ramp, ((ramp[0] - (movementOffset + extraOffset)) * 6) / speed);
}

function scheduleRamp(floor:Int, ramp:Array<Int>, time:Float)
{
	addRampTimer(time, _ -> addRampTween(ramp[1], ramp[2], (142 * 6) / Math.abs(floorGroup[floor].velocity.x)));
}

function updateBFY(n:Float)
{
	setVar('floorY', 420 - (n * (64 * 6)));
	if (!getVar('isJumping')) boyfriend.y = getVar('floorY');
}

function changeBGVelocity(target:Float = 1)
{
	if (!prefs.lowQuality)
	{
		final oldSpeed = Math.abs(floorGroup[0].velocity.x) / 2000;
		final ratio = oldSpeed > 0 ? target / oldSpeed : 1;

		if (ratio != 1)
		{
			for (timer in rampTimers) if (timer.active && !timer.finished) timer.time = timer.elapsedTime + ((timer.time - timer.elapsedTime) / ratio);
			for (tween in rampTweens)
			{
				if (!tween.finished)
				{
					final percent = tween.percent;
					tween.duration /= ratio;
					tween.percent = percent;
				}
			}
		}

		for (bg in bgGroup) bg.velocity.x = (-1250 + (50 * bg.ID)) * target;
		for (floor in floorGroup) floor.velocity.x = -2000 * target;
		for (floorBG in floorBGGroup) floorBG.velocity.x = -2000 * target;
		lightning.velocity.x = (-1250 + (50 * 15)) * target;
		fg.velocity.x = -3500 * target;
	}
}

var stopNextShock:Bool = false;
function doLightning()
{
	if (stopNextShock)
	{
		stopNextShock = false;
		return;
	}
	lightningActive = true;
	lightning.visible = true;
	lightning.alpha = 1;
	lightning.animation.play('idle', true);

	replaceColor.setFloatArray('replaceColor', [216, 108, 180]);
	if (paradeOn) parade.strike();

	if (prefs.flashing)
	{
		FlxTween.cancelTweensOf(flashOverlay);
		flashOverlay.alpha = 0.3;
		FlxTween.tween(flashOverlay, {alpha: 0}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeOut});
	}
}

function onSectionHit() if (curSection % 16 == 0) doLightning();

function onEvent(n, v1)
{
	if (n == 'Change BG Velocity') changeBGVelocity(Std.parseFloat(v1));
	if (n == 'preyEvent')
	{
		switch(v1)
		{
			case 'stopnextshock': stopNextShock = true;
			case 'shock': doLightning();
			case 'addbg':
				if (parade != null)
				{
					paradeOn = true;
					for (group in parade.groups) group.visible = true;
				}
		}
	}
}

//shit for the ramps

function addRampTimer(time:Float, callback:FlxTimer->Void):FlxTimer
{
	final timer = new FlxTimer();
	timer.start(time, t ->
	{
		rampTimers.remove(t);
		callback(t);
	});
	rampTimers.push(timer);
	return timer;
}

function addRampTween(from:Float, to:Float, duration:Float):FlxTween
{
	final tween = FlxTween.num(from, to, duration, null, n -> {updateBFY(n);});
	rampTweens.push(tween);
	return tween;
}

function isRampAt(startX:Float, endX:Float):Bool
{
	for (floor in floorGroup)
	{
		if (endX >= floor.x && startX <= floor.x + floor.width)
		{
			var checkX = Math.max(startX, floor.x);
			while (checkX <= Math.min(endX, floor.x + floor.width))
			{
				if (floorLevel(floor.ID, (checkX - floor.x) / 6, 24) != 0) return true;
				checkX += 40;
			}
		}
	}
	return false;
}

function floorLevel(id:Int, tex:Float, margin:Float):Float
{
	return SongFloors.levelAt(id, tex, margin);
}

function floorSpot(startX:Float, endX:Float, clear:Bool):Float
{
	for (floor in floorGroup)
	{
		if (startX < floor.x || endX > floor.x + floor.width) continue;
		final a = (startX - floor.x) / 6;
		final b = (endX - floor.x) / 6;
		final level = floorLevel(floor.ID, a, 24);
		if (Math.isNaN(level) || floorLevel(floor.ID, b, 24) != level) return -1;
		if (clear)
		{
			var inside = false;
			for (span in SongFloors.clear(floor.ID)) if (a >= span[0] && b <= span[1]) inside = true;
			if (!inside) return -1;
		}
		return 584 - 384 * level;
	}
	return -1;
}

function opponentBody():Array<Float>
{
	final dad = game.dad;
	if (dad == null || dad.curCharacter != 'furnace' || !dad.visible || dad.alpha < 0.5) return null;
	final bounds = dad.getGraphicBounds();
	return [bounds.x + bounds.width * 0.13, bounds.y + bounds.height * 0.25, bounds.x + bounds.width * 0.68, bounds.y + bounds.height * 0.89];
}

function freezeStage()
{
	frozen = true;
	clearRampTimers();
	if (prefs.lowQuality) return;
	for (bg in bgGroup) bg.velocity.x = 0;
	lightning.velocity.x = 0;
	for (floor in floorGroup) floor.velocity.x = 0;
	for (floorBG in floorBGGroup) floorBG.velocity.x = 0;
	fg.velocity.x = 0;
	fg.animation.pause();
	paradeOn = false;
}

function clearRampTimers()
{
	for (timer in rampTimers) if (!timer.finished) timer.cancel();
	for (tween in rampTweens) if (!tween.finished) tween.cancel();
	rampTimers.resize(0);
	rampTweens.resize(0);
}