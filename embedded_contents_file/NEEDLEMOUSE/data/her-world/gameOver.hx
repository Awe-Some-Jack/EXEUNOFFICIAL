import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;

function onCreate()
{
	GameOverSubstate.characterName = 'bf-needle-die';
	GameOverSubstate.deathSoundName = '../music/die';
}

function onGameOverStart()
{
	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(200, -400);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverHW'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	vhsFilters();
}

var vhsCrt:ErrorHandledRuntimeShader;
var vhsTime:Float = 0;
function vhsFilters()
{
	if (!ClientPrefs.data.shaders) return;
	vhsCrt = vhsShader('tvcrt');
	final grade:ErrorHandledRuntimeShader = vhsShader('brightness');
	final chroma:ErrorHandledRuntimeShader = vhsShader('chromatic');
	if (vhsCrt == null || grade == null || chroma == null) return;
	grade.setFloat('saturation', 1.25);
	grade.setFloat('brightness', -0.08);
	grade.setFloat('contrast', 1.2);
	chroma.setFloat('amount', 0.6);
	FlxG.camera.filters = [new ShaderFilter(vhsCrt), new ShaderFilter(grade), new ShaderFilter(chroma)];
}

function vhsShader(name:String):ErrorHandledRuntimeShader
{
	final code:String = Paths.getTextFromFile('shaders/' + name + '.frag');
	return code != null ? new ErrorHandledRuntimeShader(name, code) : null;
}

function onUpdate(elapsed:Float)
{
	if (!inGameOver || vhsCrt == null) return;
	vhsTime += elapsed;
	vhsCrt.setFloat('iTime', vhsTime);
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
		deadMusic.stop();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}