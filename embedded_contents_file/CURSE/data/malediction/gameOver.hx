import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxCamera;
import backend.Language;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var curseLine:FlxSound;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;
function onCreate()
{
	GameOverSubstate.characterName = 'bfc-dead';
	GameOverSubstate.deathSoundName = 'empty';
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
	deadBoyfriend.setPosition(-50, -50);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	var voiceLine = FlxG.random.int(1,6);
	makeSubtitle(voiceLine);

	curseLine = new FlxSound();
	curseLine.load(Paths.sound('voicelines/curseDeath' + voiceLine), true);
	curseLine.onComplete = function() {
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(curseLine);

	FlxG.sound.play(Paths.sound('die'));
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "YOU GET WHAT'S COMING TO YOU, VILE CREATURE!",
		"2" => "That was... a little... too easy... Are.. you okay...?",
		"3" => "I hope hell has had a spot for you, little bastard!",
		"4" => "Just another one to scrap off a list.",
		"5" => "Did.. I do the right thing?",
		"6" => "Why... is she crying...? I... thought you hurt her..."
	];

	subtitle = new FlxText(0, Std.int(FlxG.height * 0.8), Std.int(FlxG.width * 0.75), Language.getPhrase('malediction_death_' + daLine, subtitles.get(daLine)));
	subtitle.setFormat(Paths.font(Language.getPhrase('malediction_death_font', 'vcr.ttf')), 25, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
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
			curseLine.play();
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
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		curseLine.stop();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}