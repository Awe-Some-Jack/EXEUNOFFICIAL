import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxCamera;
import psychlua.ExtraFunctions;
import backend.Language;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var introDead:FlxSound;
var deadMusic:FlxSound;

var hogLine:FlxSound;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;

var blackscreen:FlxSprite;

function onCreate()
{
	GameOverSubstate.deathSoundName = '../music/empty';
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
	deadBoyfriend.setPosition(320, 200);

	blackscreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackscreen.scrollFactor.set();
	blackscreen.scale.set(1 / 0.7, 1 / 0.7);
	GameOverSubstate.instance.add(blackscreen);

	FlxTween.tween(blackscreen, {alpha: 0}, 10);

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOver'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	introDead = new FlxSound();
	introDead.load(Paths.music('gameOverStart'), true);
	FlxG.sound.list.add(introDead);
	introDead.play();

	var voiceLine = FlxG.random.int(1,5);
	makeSubtitle(voiceLine);

	hogLine = new FlxSound();
	hogLine.load(Paths.sound('../music/voicelines/' + voiceLine), true);
	hogLine.onComplete = function() {
		deadMusic.fadeIn(1, 0.5, 1);
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(hogLine);

	introDead.onComplete = function() {
		deadMusic.play();
		deadMusic.fadeOut(1, 0.3);
		hogLine.play();
		gameOverHUD.alpha = 1;
	};
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "Aw, maybe next!",
		"2" => "Let's try again!",
		"3" => "C'mon, You can do it!",
		"4" => "Practice make best!",
		"5" => "One more time, C'mon!"
	];

	var subtitleText:String = getSubtitleLine(daLine);
	if (subtitleText == null || subtitleText.length == 0) subtitleText = subtitles.get(daLine);

	subtitle = new FlxText(0, Std.int(FlxG.height * 0.8), Std.int(FlxG.width * 0.75), subtitleText);
	subtitle.setFormat(Paths.font(subtitleFont()), 25, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
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

function subtitleLang():String
{
	var lang = ClientPrefs.data.language ?? 'auto';
	if (lang.length == 0) lang = 'auto';
	if (lang == 'auto') lang = Language.getSystemLanguage();
	return lang;
}

function subtitleFont():String
{
	var lang = subtitleLang();
	if (lang == 'ja-JP') return 'japanese.ttf';
	if (lang == 'zh-CN') return 'chinese.ttf';
	if (lang == 'ko-KR') return 'korean.ttf';
	if (lang == 'pl-PL' || lang == 'tr-TR' || lang == 'hu-HU') return 'ari-w9500-bold.ttf';
	return 'vcr.ttf';
}

function getSubtitleLine(daLine:String):String
{
	var data:Dynamic = ExtraFunctions.getLyricsData('hedge', 'HOG');
	if (data == null) return null;
	var langData:Dynamic = ExtraFunctions.resolveLyricsLangData(data, subtitleLang());
	if (langData == null) return null;
	return Reflect.field(langData, "gameover.hedge." + daLine);
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
			FlxG.sound.music.volume = 0;
		}
	}
}

function onGameOverConfirm(retry)
{
	if (retry) {
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;

		FlxG.cameras.remove(gameOverHUD, true);
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		FlxG.sound.play(Paths.music('gameOverEnd'));
		deadMusic.stop();
		hogLine.stop();
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}