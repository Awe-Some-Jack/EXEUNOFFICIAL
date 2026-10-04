package states.substates;

import backend.WeekData;
import backend.Highscore;
import backend.Language;
import backend.Paths;
import backend.Difficulty;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.HealthIcon;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var textArray:Array<FlxText> = [];
	var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:FlxText;
	var noText:FlxText;

	var song:String;
	var difficulty:Int;
	var week:Int;

	// Week -1 = Freeplay
	public function new(song:String, difficulty:Int, character:String, week:Int = -1)
	{
		this.song = song;
		this.difficulty = difficulty;
		this.week = week;
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var tooLong:Float = (song.length > 18) ? 0.8 : 1; 
		
		var fontPath = Paths.font(Language.getFontForLanguage());
		var baseSize = Language.scaledFontSize(32);

		var promptString = Language.getPhrase('freeplay.reset', 'RESET SCORE FOR {1}?', [song]);

		var promptTxt = new FlxText(0, 220, 0, promptString, baseSize);
		promptTxt.setFormat(fontPath, baseSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		promptTxt.borderSize = 2;
		promptTxt.scale.set(tooLong, tooLong);
		promptTxt.screenCenter(X);
		if(week == -1) promptTxt.x += 60 * tooLong;
		promptTxt.alpha = 0;
		textArray.push(promptTxt);
		add(promptTxt);

		if(week == -1) {
			icon = new HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(promptTxt.x - icon.width + (10 * tooLong), promptTxt.y - 30);
			icon.alpha = 0;
			add(icon);
		}

		yesText = new FlxText(0, promptTxt.y + 150, 0, Language.getPhrase('Yes', 'Yes'), baseSize);
		yesText.setFormat(fontPath, baseSize, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		yesText.borderSize = 2;
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);

		noText = new FlxText(0, promptTxt.y + 150, 0, Language.getPhrase('No', 'No'), baseSize);
		noText.setFormat(fontPath, baseSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		noText.borderSize = 2;
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (spr in textArray) {
			spr.alpha += elapsed * 2.5;
		}
		if(week == -1) icon.alpha += elapsed * 2.5;

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		} else if(controls.ACCEPT) {
			if(onYes) {
				if(week == -1) {
					Highscore.resetSong(song, difficulty);
				} else {
					Highscore.resetWeek(WeekData.weeksList[week], difficulty);
				}
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1.0];
		var alphas:Array<Float> = [0.6, 1.0];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		// noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);

		if(week == -1) icon.animation.curAnim.curFrame = confirmInt;
	}
}