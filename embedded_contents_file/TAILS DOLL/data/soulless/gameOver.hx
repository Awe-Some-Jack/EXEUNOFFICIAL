import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var bg:FlxSprite;
var eyes:FlxSprite;

function onCreate()
{
	GameOverSubstate.characterName = 'bfsoulless-dead';
	GameOverSubstate.deathSoundName = 'dead';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(253, -1128);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	bg = new FlxSprite().loadGraphic(Paths.image('characters/go'));
	bg.scale.set(1.4, 1.4); bg.updateHitbox();
	bg.screenCenter();
	GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(deadBoyfriend), bg);

	eyes = new FlxSprite(497, 410);
	eyes.frames = Paths.getSparrowAtlas('characters/tdgameover/ojo');
	eyes.animation.addByPrefix('ojos', 'ojos', 24, false); eyes.animation.play('ojos', true);
	eyes.scale.set(0.3, 0.3); eyes.updateHitbox();
	eyes.visible = false;
	GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(deadBoyfriend) + 1, eyes);

	blacks = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blacks.scale.set(1 / 0.7, 1 / 0.7); blacks.updateHitbox();
	blacks.screenCenter();
	FlxTween.tween(blacks, {alpha: 0}, 2);
	GameOverSubstate.instance.add(blacks);
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (deadBoyfriend.getAnimationName() == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			FlxG.sound.music.volume = 0;
		}
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		deadBoyfriend.visible = false;
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		bg.destroy();
		eyes.visible = true;
		eyes.animation.play('ojos', true);
	}
}