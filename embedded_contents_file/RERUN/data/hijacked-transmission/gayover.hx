import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import animate.FlxAnimate;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

var deadBF:FlxAnimate;
var deadGF:FlxAnimate;
var speaker:FlxAnimate;

var blackfuck:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'die';
}

function onGameOverStart()
{
	inGameOver = true;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('spookysounds'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	if(GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.screenCenter();
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.visible = false;

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 1.1;

	FlxG.sound.music.volume = 0;

	speaker = new FlxAnimate(-20, 200);
	speaker.frames = Paths.getAnimateAtlas('game over/rerun');
	speaker.anim.addBySymbol('idle', 'Símbolo 5', 24, true);
	speaker.anim.play('idle', true);
	speaker.updateHitbox();

	deadGF = new FlxAnimate(370, -15);
	deadGF.frames = Paths.getAnimateAtlas('game over/rerun');
	deadGF.anim.addBySymbol('idle', 'Símbolo 4', 24, true);
	deadGF.anim.play('idle', true);
	deadGF.updateHitbox();

	deadBF = new FlxAnimate(600, 120);
	deadBF.frames = Paths.getAnimateAtlas('game over/rerun');
	deadBF.anim.addBySymbol('idle', 'Símbolo 3', 24, true);
	deadBF.anim.play('idle', true);
	deadBF.updateHitbox();

	GameOverSubstate.instance.add(deadGF);
	GameOverSubstate.instance.add(deadBF);
	GameOverSubstate.instance.add(speaker);

	blackfuck = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackfuck.scrollFactor.set();
	blackfuck.screenCenter();
	GameOverSubstate.instance.add(blackfuck);

	game.camGame.filters = [
		new ShaderFilter(game.getLuaObject('sexo').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('glitch').shader)
	];

	new FlxTimer().start(1, function(_) {
		deadMusic.fadeIn(3, 0, 1);
		deadMusic.play();

		FlxTween.tween(FlxG.camera, {zoom: 0.7}, 5, {ease: FlxEase.smootherStepInOut});
		FlxTween.tween(blackfuck, {alpha: 0}, 5, {ease: FlxEase.smootherStepInOut});
	});

}

function onUpdatePost()
{
	if(!inGameOver) return;

	if(deadBoyfriend.animation.curAnim.curFrame >= 34)
		deadBoyfriend.active = false;
}

function onGameOverConfirm(retry)
{
	if(retry) {
		for(sound in FlxG.sound.list) if(sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.sound.play(Paths.sound('retry'));
		deadMusic.stop();
	}
}