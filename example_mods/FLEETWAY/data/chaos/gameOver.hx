import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import states.substates.PauseSubState;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxCamera;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var fleetLine:FlxSound;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;
function onCreate()
{
	GameOverSubstate.characterName = 'bffleet-dead';
	GameOverSubstate.deathSoundName = 'laser_moment';
}

function onGameOverStart()
{
	gameOverHUD = new FlxCamera();
	gameOverHUD.bgColor = 0x0;
	FlxG.cameras.add(gameOverHUD, false);
	gameOverHUD.alpha = 0;

	inGameOver = true;
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;
	deadBoyfriend.scrollFactor.set();
	deadBoyfriend.setPosition(500, 300);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);

	var voiceLine = FlxG.random.int(1,12);
	makeSubtitle(voiceLine);

	fleetLine = new FlxSound();
	fleetLine.load(Paths.sound('voicelines/' + voiceLine), true);
	fleetLine.onComplete = function() {
		deadMusic.fadeIn(1, 0.5, 1);
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(fleetLine);
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "That was almost too easy!",
		"2" => "Let's do that again some time! When you are little less... death.",
		"3" => "I was a little bit skeptical the whole singing thing earlier, but... That was actually kinda fun! Specially considering that I won, Heh.",
		"4" => "Who's god now?!",
		"5" => "It's all about speed, pal.",
		"6" => "That was way past cool! And you are way past death.",
		"7" => "That blood crying fakers got nothing on me!",
		"8" => "What does 'hyperrealistic' even mean? Like, it's the Super Emeralds involved or...?",
		"9" => "If little dolls and hedgehogs covered in blood gives you nightmares, you ain't ready to fight with me.",
		"10" => "Looks like fun wasn't so endless after all! Heh?",
		"11" => "No, I'm not making an Eggman pisses on the moon joke. Find new material.",
		"12" => "Imagine being in an executable file... Heh.. couldn't be me."
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
	if (GameOverSubstate.instance.boyfriend != null && deadBoyfriend == null) deadBoyfriend = GameOverSubstate.instance.boyfriend;

	if (deadBoyfriend.animation.curAnim.name == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			deadMusic.fadeOut(1, 0.3);
			fleetLine.play();
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
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		fleetLine.stop();
	}
}