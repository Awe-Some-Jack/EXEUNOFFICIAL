package states;

import backend.WeekData;
import backend.Song;
import backend.Highscore;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.Assets as AssetPaths;
import backend.Paths;

class SoundTest extends MusicBeatState 
{
	static final COLOR_INACTIVE:FlxColor = FlxColor.fromRGB(174, 179, 251);
	static final COLOR_INACTIVE_SHADOW:FlxColor = FlxColor.fromRGB(106, 110, 159);
	static final COLOR_ACTIVE:FlxColor = FlxColor.fromRGB(254, 174, 0);
	static final COLOR_ACTIVE_SHADOW:FlxColor = FlxColor.fromRGB(253, 36, 3);
	static final COLOR_TITLE:FlxColor = FlxColor.fromRGB(0, 163, 255);

	static final ARROW_ICONS:Array<String> = ["^", "<", "v", ">"];

	var codes:Map<String, Array<Int>> = new Map();

	var backdrop:FlxBackdrop;
	var titleText:FlxText;

	var pcmLabel:FlxText;
	var daLabel:FlxText;
	var pcmNumber:FlxText;
	var daNumber:FlxText;

	var pcmValue:Int = 0;
	var daValue:Int = 0;

	var isPCMSelected:Bool = true;
	var currentArrowIndex:Int = 0;

	var arrowTimer:FlxTimer;
	var previousWindowTitle:String;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();

		previousWindowTitle = FlxG.stage.window.title;

		initPsychCamera();
		loadMusic();
		createBackground();
		createTitle();
		createLabels();
		createNumbers();
		startArrowAnimation();
		updateTextColors();

		Paths.clearUnusedMemory();

		WeekData.reloadWeekFiles(true);
		loadCodesFromWeeks();
	}

	function loadCodesFromWeeks():Void
	{
		codes.clear();
		for (weekName in WeekData.weeksList)
		{
			var week:WeekData = WeekData.weeksLoaded.get(weekName);
			if (week == null || week.soundTestCode == null) continue;
			var code = week.soundTestCode;
			if (code.length < 3) continue;
			var enabled:Bool = code[2] == true;
			if (!enabled) continue;
			var pcm:Int = Std.int(code[0]);
			var da:Int  = Std.int(code[1]);
			codes.set(weekName, [pcm, da]);
		}
	}

	function loadMusic():Void
	{
		FlxG.sound.playMusic(AssetPaths.getSound('assets/exe/music/soundtest.ogg'));
	}

	function createBackground():Void
	{
		backdrop = new FlxBackdrop('assets/exe/soundtest/bgtest.png', FlxAxes.XY);
		backdrop.scale.set(3.0, 3.0);
		backdrop.velocity.set(-50.0, -50.0);
		add(backdrop);
	}

	function createTitle():Void
	{
		titleText = new FlxText(0, 0, 0, 'SOUND TEST', 25);
		titleText.setFormat("assets/fonts/SonicCD.ttf", 25, COLOR_TITLE);
		titleText.setBorderStyle(SHADOW, FlxColor.BLACK, 3, 3);
		titleText.antialiasing = false;
		titleText.screenCenter();
		titleText.y += -180.0;
		titleText.x += 20.0;
		add(titleText);
	}

	function createLabels():Void
	{
		var pcmX:Float = (FlxG.width / 6) + 100.0;
		var daX:Float = FlxG.width * 0.6;
		var labelY:Float = (FlxG.height / 2) + -70.0;

		pcmLabel = createStyledText(pcmX, labelY, 'PCM  NO .', COLOR_INACTIVE, COLOR_INACTIVE_SHADOW);
		daLabel = createStyledText(daX, labelY, 'DA  NO .', COLOR_INACTIVE, COLOR_INACTIVE_SHADOW);

		add(pcmLabel);
		add(daLabel);
	}

	function createNumbers():Void
	{
		var pcmX:Float = (FlxG.width / 6) + 270.0;
		var daX:Float = (FlxG.width * 0.6) + 150.0;
		var numberY:Float = (FlxG.height / 2) + -70.0;

		pcmNumber = createStyledText(pcmX, numberY, '00', COLOR_INACTIVE, COLOR_INACTIVE_SHADOW);
		daNumber = createStyledText(daX, numberY, '00', COLOR_INACTIVE, COLOR_INACTIVE_SHADOW);

		add(pcmNumber);
		add(daNumber);
	}

	function startArrowAnimation():Void
	{
		updateWindowTitle();
		arrowTimer = new FlxTimer().start(3.0, function(timer:FlxTimer):Void
		{
			currentArrowIndex = (currentArrowIndex + 1) % ARROW_ICONS.length;
			updateWindowTitle();
		}, 0);
	}

	function createStyledText(x:Float, y:Float, text:String, color:FlxColor, shadowColor:FlxColor):FlxText
	{
		var txt:FlxText = new FlxText(x, y, 0, text, 23);
		txt.setFormat("assets/fonts/SonicCD.ttf", 23, color);
		txt.setBorderStyle(SHADOW, FlxColor.BLACK, 3, 3);
		txt.antialiasing = false;
		return txt;
	}

	function updateTextColors():Void
	{
		if (isPCMSelected)
		{
			setTextStyle(pcmLabel, COLOR_ACTIVE, COLOR_ACTIVE_SHADOW);
			setTextStyle(daLabel, COLOR_INACTIVE, COLOR_INACTIVE_SHADOW);
		}
		else
		{
			setTextStyle(pcmLabel, COLOR_INACTIVE, COLOR_INACTIVE_SHADOW);
			setTextStyle(daLabel, COLOR_ACTIVE, COLOR_ACTIVE_SHADOW);
		}
	}

	inline function setTextStyle(text:FlxText, color:FlxColor, shadowColor:FlxColor):Void
	{
		text.setFormat("assets/fonts/SonicCD.ttf", 23, color);
		text.setBorderStyle(SHADOW, FlxColor.BLACK, 3, 3);
	}

	function updateWindowTitle():Void
	{
		try
		{
			var arrow:String = ARROW_ICONS[currentArrowIndex];
			FlxG.stage.window.title = arrow + " SOUND TEST " + arrow;
		}
		catch (e:Dynamic)
		{
			trace("Error updating window title: " + e);
		}
	}

	var updateOnce:String = 'left';
	function handleSelection():Void
	{
		var mouseX = FlxG.mouse.getWorldPosition().x;
		var middleScreen = FlxG.width / 2;
		
		if (Controls.instance.UI_RIGHT_P || Controls.instance.UI_LEFT_P)
		{
			isPCMSelected = !isPCMSelected;
			updateTextColors();
		}
		
		if (mouseX < middleScreen && updateOnce == 'right')
		{
			updateOnce = 'left';
			isPCMSelected = true;
			updateTextColors();
		}
		else if (mouseX > middleScreen && updateOnce == 'left')
		{
			updateOnce = 'right';
			isPCMSelected = false;
			updateTextColors();
		}
		
		if (mouseX >= middleScreen && updateOnce == 'left')
			updateOnce = 'right';
		else if (mouseX <= middleScreen && updateOnce == 'right')
			updateOnce = 'left';
	}

	function handleValueChange():Void
	{
		var change:Int = 0;

		if (Controls.instance.UI_DOWN_P || FlxG.mouse.wheel < 0)
			change = (FlxG.keys.pressed.SHIFT ? 3 : 1);
		else if (Controls.instance.UI_UP_P || FlxG.mouse.wheel > 0)
			change = -(FlxG.keys.pressed.SHIFT ? 3 : 1);

		if (change != 0)
		{
			if (isPCMSelected)
				pcmValue = (pcmValue + change + 70) % 70;
			else
				daValue = (daValue + change + 38) % 38;
		}
	}

	function updateDisplayedValues():Void
	{
		pcmNumber.text = formatNumber(pcmValue);
		daNumber.text = formatNumber(daValue);
	}

	inline function formatNumber(value:Int):String
	{
		return (value < 10) ? '0' + value : Std.string(value);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (subState != null)
			return;

		if (Controls.instance.BACK)
		{
			FlxG.switchState(() -> new Exemenu());
			return;
		}

		handleSelection();
		handleValueChange();
		updateDisplayedValues();

		if (Controls.instance.ACCEPT)
		{
			for (weekName => value in codes)
			{
				if (pcmValue == value[0] && daValue == value[1])
				{
					loadSong(weekName, true);
					break;
				}
			}
		}
	}

	function loadSong(name:String, isWeek:Bool = false)
	{
		PlayState.isSoundTest = true;

		if (isWeek)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(name);
			if (leWeek == null)
			{
				trace("Week no encontrada: " + name);
				return;
			}

			if (leWeek.folder != null && leWeek.folder != "")
				Mods.currentModDirectory = leWeek.folder;

			WeekData.setDirectoryFromWeek(leWeek);

			var songArray:Array<String> = [];
			for (song in leWeek.songs)
				songArray.push(song[0]);

			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 1;
				PlayState.storyWeek = WeekData.weeksList.indexOf(name);

				var firstSong:String = songArray[0].toLowerCase();

				Song.loadFromJson(firstSong, firstSong);

				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch (e:Dynamic)
			{
				trace("Error cargando week: " + e);
				return;
			}
		}
		else
		{
			var songLower = Paths.formatToSongPath(name);

			try
			{
				PlayState.storyPlaylist = [songLower];
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 0;

				Song.loadFromJson(songLower, songLower);
			}
			catch (e:Dynamic)
			{
				trace("Error cargando canción: " + e);
				return;
			}
		}

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
		FlxG.sound.music.stop();
	}

	override public function destroy():Void
	{
		if (arrowTimer != null)
		{
			arrowTimer.cancel();
			arrowTimer = null;
		}

		FlxG.stage.window.title = previousWindowTitle;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		backdrop = null;
		titleText = null;
		pcmLabel = null;
		daLabel = null;
		pcmNumber = null;
		daNumber = null;

		super.destroy();
	}
}
