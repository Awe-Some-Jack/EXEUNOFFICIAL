import states.substates.GameOverSubstate;
import objects.Character;
import flixel.sound.FlxSound;
import states.substates.PauseSubState;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxCamera;
import backend.EXEAchievements;
import backend.Language;

var deadBoyfriend:Character;
var inGameOver:Bool = false;
var deadMusic:FlxSound;
var xenoLine:FlxSound;

var subtitleBG:FlxSprite;
var subtitle:FlxText;

var gameOverHUD:FlxCamera;
function onCreate()
{
	GameOverSubstate.characterName = 'bftails-dead';
	GameOverSubstate.deathSoundName = 'dead';
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

	FlxG.camera.follow();
	FlxG.camera.scroll.set(0, 0);
	FlxG.camera.zoom = 0.7;

	deadMusic = new FlxSound();
	deadMusic.load(Paths.music('gameOverXeno'), true);
	FlxG.sound.list.add(deadMusic);
	deadMusic.looped = true;

	if(!EXEAchievements.isUnlocked('tripledeaths')) {
		var _a = EXEAchievements.get('tripledeaths');
		if(_a != null) {
			var _seen = _a.extra;
			if (_seen == null) _seen = [];
			var _key:String = PauseSubState.miniSonicImage ?? 'triple-trouble';
			if(!_seen.contains(_key)) {
				_seen.push(_key);
				_a.extra = _seen;
				if(_seen.length >= 4) EXEAchievements.unlock(_a.id);
				EXEAchievements.save();
			}
		}
	}

	var voiceLine:String = '1';
	if (PauseSubState.miniSonicImage == 'triple-trouble') voiceLine = 't';
	if (PauseSubState.miniSonicImage == 'triple-trouble-2') voiceLine = FlxG.random.int(1,3);
	if (PauseSubState.miniSonicImage == 'triple-trouble-3') voiceLine = 'k';
	if (PauseSubState.miniSonicImage == 'triple-trouble-4') voiceLine = 'e';

	makeSubtitle(voiceLine);

	xenoLine = new FlxSound();
	xenoLine.load(Paths.sound('voicelines/ttxeno-' + voiceLine), true);
	xenoLine.onComplete = function() {
		deadMusic.fadeIn(1, 0.5, 1);
		subtitleBG.destroy();
		subtitle.destroy();
	};
	FlxG.sound.list.add(xenoLine);
}

function onEvent(n, v1, v2)
{
	if (n == 'tripletroublebgchange')
	{
		switch(v1)
		{
			case 'xeno', 'xeno2', 'xeno3': { GameOverSubstate.characterName = 'bfexe-dead'; GameOverSubstate.deathSoundName = 'fnf_loss_sfx';}
			case 'knux': { GameOverSubstate.characterName = 'bfknux-dead'; GameOverSubstate.deathSoundName = 'dead';}
			case 'egg': { GameOverSubstate.characterName = 'bfegg-dead'; GameOverSubstate.deathSoundName = 'dead';}
		}
	}
}

function makeSubtitle(daLine:String):Void
{
	var subtitles:Map<String, String> = [
		"1" => "You've entered hell, and I'm not talking about Michigan.",
		"2" => "After all that, I'm quite disappointed.",
		"3" => "Out of rings, out of luck, and now out of time.",
		"t" => "What's the matter? Caught by the Tails?",
		"k" => "Seems like you couldn't handle my Knuckles. Too bad!",
		"e" => "I AM THE EGGMAN!"
	];

	subtitle = new FlxText(0, Std.int(FlxG.height * 0.8), Std.int(FlxG.width * 0.75), Language.getPhrase('tripletrouble_death_' + daLine, subtitles.get(daLine)));
	subtitle.setFormat(Paths.font(Language.getPhrase('tripletrouble_death_font', 'vcr.ttf')), 25, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
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
			deadMusic.fadeOut(1, 0.5);
			xenoLine.play();
			FlxG.sound.music.volume = 0;
			gameOverHUD.alpha = 1;
		}
	}

	if (deadBoyfriend.getAnimationName() == 'deathConfirm' && deadBoyfriend.isAnimationFinished() && deadBoyfriend.visible)
	{
		FlxG.camera.flash(0xFFFF0000, 1, null, true);
		deadBoyfriend.visible = false;
		FlxG.sound.play(Paths.music('gameOverEndXeno'));
		deadMusic.stop();
		xenoLine.stop();
	}

}

function onGameOverConfirm(retry)
{
	if (retry) {
		FlxG.cameras.remove(gameOverHUD, true);
		for (sound in FlxG.sound.list) if (sound.playing && sound != deadMusic) sound.volume = 0;
	}
	else for (sound in FlxG.sound.list) if (sound.playing && sound != null) sound.volume = 0;
}