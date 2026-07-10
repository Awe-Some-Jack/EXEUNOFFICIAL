import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;

var deadBoyfriend:Character;
var soink:FlxSprite;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var soinkLaugh:Int = 0;
var blackFuck:FlxSprite;
var cursor:FlxSprite;
var bluebox:FlxSprite;
var cursorStartX:Float = 0;
var cursorStartY:Float = 0;
var doCursorThing = false;
var bluescreen:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'void';
}

function onGameOverStart()
{
	inGameOver = true;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('peakGameoverMusic'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	soink = new FlxSprite();
	soink.frames = Paths.getSparrowAtlas('characters/soink');
	soink.animation.addByPrefix('laugh', 'risa', 24, false);
	soink.alpha = 0.00001;
	soink.animation.finishCallback = function(n:String) { 
		if(soinkLaugh <= 6) {
			soink.animation.play('laugh');
			soinkLaugh++;
		}
	}

	soink.scale.set(1, 1); 
	soink.updateHitbox();
	soink.screenCenter();
	soink.scrollFactor.set();
	soink.y -= 30;
	soink.x -= 370;
	GameOverSubstate.instance.add(soink);

	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.screenCenter();
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.x += 300;

    cursor = new FlxSprite(0, 0, Paths.image('gay/cursor'));
    cursor.scale.set(0.4, 0.4);
    cursor.updateHitbox();
	cursor.screenCenter();
	cursor.y -= 400;
	cursor.x -= 550;
	cursor.scrollFactor.set();
    GameOverSubstate.instance.add(cursor);

	bluescreen = new FlxSprite(0, 0, Paths.image('bg/bluescreen'));
    bluescreen.setGraphicSize(FlxG.width, FlxG.height);
    bluescreen.updateHitbox();
	bluescreen.screenCenter();
	bluescreen.alpha = 0.00001;
	bluescreen.scrollFactor.set();
    GameOverSubstate.instance.add(bluescreen);

	blackFuck = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackFuck.scrollFactor.set();
	blackFuck.screenCenter();
	blackFuck.visible = false;
	GameOverSubstate.instance.add(blackFuck);

	bluebox = new FlxSprite().makeGraphic(1, 1, 0xFF00a6ff);
	bluebox.scrollFactor.set();
	bluebox.screenCenter();
	bluebox.alpha = 0.00001;
	GameOverSubstate.instance.add(bluebox);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 1;

	FlxG.sound.play(Paths.sound('kys'));

	new FlxTimer().start(1.1, function(_) {
        FlxTween.tween(soink, {alpha: 1}, 0.3, {ease: FlxEase.smoothStepOut});
		soink.animation.play('laugh');
    });

	new FlxTimer().start(2.6, function(_) {
		FlxTween.tween(cursor, {y: cursor.y + 200}, 0.3, {ease: FlxEase.smoothStepOut});
	});

	new FlxTimer().start(3.6, function(_) {
		doCursorThing = true;
		bluebox.alpha = 0.1;
		cursorStartX = bluebox.x = cursor.x;
		cursorStartY = bluebox.y = cursor.y;
		FlxTween.tween(cursor, {x: cursor.x + 1150, y: cursor.y + 500}, 0.4, {ease: FlxEase.smoothStepOut});
	});

	FlxG.sound.music.volume = 0;
	new FlxTimer().start(4.1, function(_) {
		var pixelShader = game.getLuaObject('pixel').shader;

		var gameFilters = [new ShaderFilter(pixelShader)];
		FlxG.camera.filters = gameFilters;
		game.getLuaObject('pixel').x = 40;
	});

	new FlxTimer().start(4.6, function(_) {
		FlxG.camera.flash(0xFFFFFFFF, 1.2, null, true);
		soink.alpha = deadBoyfriend.alpha = cursor.alpha = bluebox.alpha = 0;
		doCursorThing = false;
		FlxTween.tween(game.getLuaObject('pixel'), {x: 80}, 1, {ease: FlxEase.smoothStepOut});
	});

	new FlxTimer().start(6.5, function(_) {
		game.getLuaObject('pixel').x = 0;
		bluescreen.alpha = 1;
	});

	new FlxTimer().start(9, function(_) {
		deadMusic.fadeIn(1, 0, 1);
		deadMusic.play();
	});
}

function onUpdatePost()
{
	if (!inGameOver) return;

	if(doCursorThing) {
		var deltaX = Math.abs(cursor.x - cursorStartX);
		var deltaY = Math.abs(cursor.y - cursorStartY);

		bluebox.setGraphicSize(Std.parseInt(deltaX), Std.parseInt(deltaY));
		bluebox.updateHitbox();
	}

	if(deadBoyfriend.animation.curAnim.curFrame == 34)
		deadBoyfriend.active = false;
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;

		FlxG.sound.play(Paths.sound('rety'));
		deadMusic.stop();
	}
}