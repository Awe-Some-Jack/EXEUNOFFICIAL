import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.addons.display.FlxBackdrop;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'ojojojo';
}

var text:FlxSprite; var text2:FlxSprite;
var bfjp:FlxBackdrop;
function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.visible = false;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	bfjp = new FlxBackdrop(Paths.image('gameovers/jp/2'), 0x11);
	bfjp.scale.set(0.5, 0.5); bfjp.updateHitbox();
	bfjp.velocity.x = -50;
	bfjp.visible = false;
	GameOverSubstate.instance.add(bfjp);

	text = new FlxSprite().loadGraphic(Paths.image('gameovers/jp/1'));
	text.scale.set(0.5, 0.5); text.updateHitbox();
	text.screenCenter();
	text.visible = false;
	GameOverSubstate.instance.add(text);

	text2 = new FlxSprite().loadGraphic(Paths.image('gameovers/jp/11'));
	text2.scale.set(0.5, 0.5); text2.updateHitbox();
	text2.screenCenter();
	text2.alpha = 0;
	GameOverSubstate.instance.add(text2);

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	Conductor.bpm = 97;
}

var oldBeat:Int = 0; var curBeat:Int = 0;
var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (deadBoyfriend.animation.curAnim.name == 'deathLoop')
	{
		Conductor.songPosition = FlxG.sound.music.time;
		if (!toggleOnce) {
			text.visible = true;
			bfjp.visible = true;
			toggleOnce = true;
			deadMusic.play();
			FlxG.sound.music.volume = 0;
		}
	}
	curBeat = GameOverSubstate.instance.curBeat;
	if (oldBeat != curBeat)
	{
		if (curBeat % 2 == 1) {
			FlxTween.cancelTweensOf(text);
			text.scale.set(0.51, 0.51); FlxTween.tween(text.scale, {x: 0.5, y: 0.5}, Conductor.crochet / 750, {ease: FlxEase.backOut});
			FlxTween.cancelTweensOf(text2.scale); FlxTween.cancelTweensOf(text2);
			text2.scale.set(0.51, 0.51); FlxTween.tween(text2.scale, {x: 0.5, y: 0.5}, Conductor.crochet / 750, {ease: FlxEase.backOut});
			text2.alpha = 1; FlxTween.tween(text2, {alpha: 0}, Conductor.crochet / 750, {ease: FlxEase.cubeOut});
			bfjp.velocity.x = -300;
			bfjp.acceleration.x = 300;
		}
		oldBeat = curBeat;
	}

	if (bfjp.velocity.x > -50) { bfjp.acceleration.x = 0; bfjp.velocity.x = -50; }
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.camera.flash(0xFFEA00FF, 1, null, true);
		bfjp.visible = false; text.visible = false;
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
	}
}