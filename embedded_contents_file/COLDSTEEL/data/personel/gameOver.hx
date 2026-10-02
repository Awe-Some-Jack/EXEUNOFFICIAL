import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var keith:FlxSprite;
var luis:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.alpha = 0;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 1;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.sound('keith'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.onComplete = () ->
	{
		GameOverSubstate.instance.endBullshit();
	};

	keith = new FlxSprite().loadGraphic(Paths.image('gameover'));
	keith.screenCenter();
	keith.alpha = 0;
	GameOverSubstate.instance.add(keith);

	luis = new FlxSprite().loadGraphic(Paths.image('luis'));
	luis.scale.set(0.6, 0.6);
	luis.updateHitbox();
	luis.screenCenter(0x10);
	luis.x = 2200;
	luis.alpha = 0;
	GameOverSubstate.instance.add(luis);
}

var _canZoom = false;
var toggleOnce:Bool = false;
function onUpdatePost(e)
{
	if (!inGameOver) return;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (_canZoom){
		keith.scale.set(keith.scale.x + e / 500, keith.scale.y + e / 500);
		keith.y -= e / 2.5;
		luis.x -= e * 20;
	}

	if (deadBoyfriend.getAnimationName() == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			FlxG.sound.music.volume = 0;
			new FlxTimer().start(5, _ -> {
				_canZoom = true;
				FlxTween.tween(keith, {alpha: 1}, 40, {ease: FlxEase.easeInOut});
				new FlxTimer().start(70, _ -> {
					FlxTween.tween(luis, {alpha: 1}, 10, {ease: FlxEase.easeInOut});
					new FlxTimer().start(20, _ -> {
						FlxTween.tween(luis, {alpha: 0}, 10, {ease: FlxEase.easeInOut});
					});
				});
			});
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
		_canZoom = false;
		keith.destroy();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}