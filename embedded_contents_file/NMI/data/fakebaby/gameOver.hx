import states.substates.GameOverSubstate;
import objects.Character;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;

var inGameOver:Bool = false;
var deadMusic:FlxSound;
var gameOverHUD:FlxCamera;

var glitchShader:ErrorHandledRuntimeShader;
var nmi:FlxSprite;
var leftHand:FlxSprite;
var rightHand:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	gameOverHUD = new FlxCamera();
	gameOverHUD.bgColor = 0x0;
	FlxG.cameras.add(gameOverHUD, false);

	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null) GameOverSubstate.instance.boyfriend.visible = false;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.play();
	deadMusic.looped = true;

	glitchShader = new ErrorHandledRuntimeShader('followedglitch', File.getContent(Paths.mods('NMI/shaders/followedglitch.frag')));
	glitchShader.setFloat('size', 0.01);

	var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/bg'));
	bg.screenCenter();
	bg.camera = gameOverHUD;
	GameOverSubstate.instance.add(bg);
	bg.shader = glitchShader;

	var gf:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/gf'));
	gf.screenCenter();
	gf.camera = gameOverHUD;
	GameOverSubstate.instance.add(gf);

	nmi = new FlxSprite().loadGraphic(Paths.image('gameover/nmi'));
	nmi.screenCenter();
	nmi.camera = gameOverHUD;
	GameOverSubstate.instance.add(nmi);

	leftHand = new FlxSprite().loadGraphic(Paths.image('gameover/lefthand'));
	leftHand.screenCenter();
	leftHand.camera = gameOverHUD;
	GameOverSubstate.instance.add(leftHand);

	rightHand = new FlxSprite().loadGraphic(Paths.image('gameover/righthand'));
	rightHand.screenCenter();
	rightHand.camera = gameOverHUD;
	GameOverSubstate.instance.add(rightHand);

	var jp2:FlxBackdrop = new FlxBackdrop(Paths.image('gameover/jp2'), 0x01, 40);
	jp2.velocity.x = 25;
	jp2.camera = gameOverHUD;
	GameOverSubstate.instance.add(jp2);

	var jp:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gameover/jp1'));
	jp.screenCenter(0x01);
	jp.camera = gameOverHUD;
	GameOverSubstate.instance.add(jp);
}

var toggleOnce:Bool = false;
var handSin:Float = 0;
function onUpdatePost(elapsed:Float)
{
	if (!inGameOver) return;

	if (GameOverSubstate.instance.boyfriend.animation.curAnim.name == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			FlxG.sound.music.volume = 0;
		}
	}

	glitchShader.setFloat('iTime', FlxG.random.float(0, 1));
	handSin += elapsed;
	leftHand.y = Math.sin(handSin) * 20;
	rightHand.y = Math.sin(handSin - (Math.PI / 4)) * 20;
	nmi.x = FlxG.random.float(-1,1);
	nmi.y = FlxG.random.float(-1,1);
	nmi.angle = FlxG.random.float(-0.5, 0.5);
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		FlxG.cameras.remove(gameOverHUD, true);
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}