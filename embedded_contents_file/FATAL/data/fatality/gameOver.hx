import states.substates.GameOverSubstate;
import objects.Character;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.sound.FlxSound;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var fatalLine:FlxSound;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;

function onCreate()
{
	GameOverSubstate.characterName = 'bf-fatal-dead';
	GameOverSubstate.deathSoundName = 'gameover';
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
	deadBoyfriend.setPosition(350, 410);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 1;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	var voiceLine = FlxG.random.int(1,9);
	makeSubtitle(voiceLine);

	fatalLine = new FlxSound();
	fatalLine.load(Paths.sound('deadlines/' + voiceLine), true);
	fatalLine.onComplete = function() {
		deadMusic.fadeIn(1, 0.5, 1);
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(fatalLine);
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "ANNOYING SODS LIKE YOU REALLY ARE NOT AS IMPRESSIVE AS YOU THINK.",
		"2" => "DON'T BOTHER TRYING TO USE YOUR ANTIVIRUS TO GET RID OF ME FROM HERE. I HAVE ALREADY TAKEN CARE OF THAT.",
		"3" => "GENUINELY, I GET SO TIRED OF BUGGERS LIKE YOU TRYING TO ACT LIKE YOU HAVE ANY SAY IN THIS.",
		"4" => "I EXPECTED MORE FROM SUCH PLENTIFUL CODE. LOOKS LIKE I REALLY NEED TO LEARN TO DEAL WITH DISSAPOINTMENT.",
		"5" => "I EXPECTED MUCH MORE, BUT THIS JUST MAKES THINGS EASIER ON ME.",
		"6" => "HOW UTTERLY PATHETHIC.",
		"7" => "HM... I WONDER WHAT OTHER FILES I CAN MESS WITH AROUND HERE?",
		"8" => "JUST GIVE UP. YOU ARE OUT OF YOUR DEPTH.",
		"9" => "YOU WANT TO ATTEMPT THIS AGAIN? FOOLISH, BUT I RESPECT THAT. GO AHEAD. LET'S SEE IF YOU DIE AGAIN."
	];

	subtitle = new FlxText(0, Std.int(FlxG.height * 0.8), Std.int(FlxG.width * 0.75), subtitles.get(daLine));
	subtitle.setFormat(Paths.font("vcr.ttf"), 25, 0xFFFF0000, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
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

	if (deadBoyfriend.getAnimationName() == 'deathLoop')
	{
		if (!toggleOnce) {
			toggleOnce = true;
			deadMusic.play();
			deadMusic.fadeOut(1, 0.3);
			fatalLine.play();
			gameOverHUD.alpha = 1;
			FlxG.sound.music.volume = 0;
		}
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		FlxG.cameras.remove(gameOverHUD, true);
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
		var flashCam = getVar('popupCam');
		if (flashCam == null) flashCam = FlxG.camera;
		flashCam.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		fatalLine.stop();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}