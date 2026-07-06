import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxCamera;

var whiteBG:FlxSprite;
var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var cdLine:FlxSound;
var daGameOver:FlxSprite;
var daGameOverLoop:FlxSprite;
var daGameOverRetry:FlxSprite;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;
function onCreate()
{
	GameOverSubstate.deathSoundName = 'empty';
}

function onGameOverStart()
{
	gameOverHUD = new FlxCamera();
	gameOverHUD.bgColor = 0x0;
	FlxG.cameras.add(gameOverHUD, false);
	gameOverHUD.alpha = 0;

	whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
	whiteBG.scrollFactor.set();
	whiteBG.screenCenter();
	whiteBG.visible = false;
	GameOverSubstate.instance.add(whiteBG);

	daGameOverLoop = new FlxSprite();
	daGameOverLoop.frames = Paths.getSparrowAtlas('characters/loop');
	daGameOverLoop.animation.addByPrefix('xd', 'Símbolo 4', 24, true); daGameOverLoop.animation.play('xd');
	daGameOverLoop.screenCenter();
	daGameOverLoop.scrollFactor.set();
	daGameOverLoop.visible = false;
	GameOverSubstate.instance.add(daGameOverLoop);

	daGameOverRetry = new FlxSprite();
	daGameOverRetry.frames = Paths.getSparrowAtlas('characters/retry');
	daGameOverRetry.animation.addByPrefix('c', 'confirm', 24, false);
	daGameOverRetry.animation.addByPrefix('idle', 'Símbolo 1', 24, true); daGameOverRetry.animation.play('idle');
	daGameOverRetry.screenCenter(); daGameOverRetry.y -= 350;
	daGameOverRetry.scrollFactor.set();
	daGameOverRetry.visible = false;
	GameOverSubstate.instance.add(daGameOverRetry);

	daGameOver = new FlxSprite();
	daGameOver.frames = Paths.getSparrowAtlas('characters/normal cd');
	daGameOver.animation.addByPrefix('intro', 'terapia instancia 1', 14, false); daGameOver.animation.play('intro');
	daGameOver.animation.finishCallback = function(n:String) { if(n == 'intro') {FlxG.camera.flash(0xFFFFFFFF, 1, null, true); daGameOverLoop.visible = true; daGameOverRetry.visible = true; whiteBG.visible = true; daGameOver.visible = false;}};
	daGameOver.scale.set(1.42, 1.42); daGameOver.updateHitbox();
	daGameOver.screenCenter(); daGameOver.y += 80;
	daGameOver.scrollFactor.set();
	GameOverSubstate.instance.add(daGameOver);

	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.visible = false;
	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	var voiceLine = FlxG.random.int(1,7);
	makeSubtitle(voiceLine);

	cdLine = new FlxSound();
	cdLine.load(Paths.sound('voicelines/cd' + voiceLine), true);
	cdLine.onComplete = function() {
		deadMusic.fadeIn(1, 0.5, 1);
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(cdLine);

	FlxG.sound.play(Paths.sound('die'));
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "That's right everybody! It's your favorite boy!",
		"2" => "Wooh! Nice place you got here, Metal! Shame I'm gonna fuck it all up!",
		"3" => "C'mon, Metal. Let me in into your House. Oh? I can't? Well... Too bad!",
		"4" => "You can't hide from me, Metal!",
		"5" => "I am breaking in entering in your house!",
		"6" => "Knock, knock, guess who~?",
		"7" => "Get the FUCK out or I'm going to shoot Amy in the FUCKING face! I swear to god! I'll do *Laughs* it you bitch! *Laughs harder* GET OUT!"
	];

	subtitle = new FlxText(0, Std.int(FlxG.height * 0.8), Std.int(FlxG.width * 0.75), subtitles.get(daLine));
	subtitle.setFormat(Paths.font("vcr.ttf"), 25, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	subtitle.borderSize = 2;
	subtitle.camera = gameOverHUD;
	subtitle.screenCenter(0x01);

	subtitleBG = new FlxSprite(0, Std.int(FlxG.height * 0.8)).makeGraphic(subtitle.textField.textWidth + 8, subtitle.height + 2, 0xFF000000);
	subtitleBG.screenCenter(0x01);
	subtitleBG.alpha = 0.6;
	subtitleBG.camera = gameOverHUD;

	GameOverSubstate.instance.add(subtitleBG);
	GameOverSubstate.instance.add(subtitle);
}

var toggleOnce:Bool = false;
function onUpdatePost()
{
	if (!inGameOver) return;

	whiteBG.scale.set(1 / FlxG.camera.zoom, 1 / FlxG.camera.zoom);
	if (deadBoyfriend.animation.curAnim.name == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			deadMusic.fadeOut(1, 0.5);
			cdLine.play();
			FlxG.sound.music.volume = 0;
			gameOverHUD.alpha = 1;
		}
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		FlxG.cameras.remove(gameOverHUD, true);
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;

		FlxG.camera.flash(0xFFFFFFFF, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		daGameOverRetry.animation.play('c', true);
		deadMusic.stop();
		cdLine.stop();
		daGameOver.destroy();
	}
}