import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import objects.VideoSprite;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'die';
}

var bfDeath:FlxSprite;
function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.alpha = 0;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;
	FlxG.camera.alpha = 1;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverUC'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	bfDeath = new FlxSprite();
	bfDeath.frames = Paths.getSparrowAtlas('characters/ga');
	bfDeath.animation.addByPrefix('idle', 'feto', 24, false);
	new FlxTimer().start(0.7, _ -> { bfDeath.animation.play('idle', true); });
	bfDeath.scale.set(2, 2); bfDeath.updateHitbox();
	bfDeath.screenCenter();
	bfDeath.x -= 100; bfDeath.y += 100;
	GameOverSubstate.instance.add(bfDeath);
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
		FlxG.sound.play(Paths.music('gameOverUCEnd'));
		deadMusic.stop();
		bfDeath.destroy();
	}
}