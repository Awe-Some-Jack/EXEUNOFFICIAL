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
import haxe.Json;

typedef SoundTestData = {
	var pcm:Int;
	var da:Int;
	var type:String;
	var path:String;
	var isWeek:Bool;
	var weekName:String;
}

class SoundTest extends MusicBeatState 
{
	static final COLOR_INACTIVE:FlxColor = FlxColor.fromRGB(174, 179, 251);
	static final COLOR_INACTIVE_SHADOW:FlxColor = FlxColor.fromRGB(106, 110, 159);
	static final COLOR_ACTIVE:FlxColor = FlxColor.fromRGB(254, 174, 0);
	static final COLOR_ACTIVE_SHADOW:FlxColor = FlxColor.fromRGB(253, 36, 3);
	static final COLOR_TITLE:FlxColor = FlxColor.fromRGB(0, 163, 255);

	static final ARROW_ICONS:Array<String> = ["^", "<", "v", ">"];

	var codes:Array<SoundTestData> = [];

	var backdrop:FlxBackdrop;
	var titleText:FlxText;
	var whiteBG:FlxSprite;

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

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		whiteBG.alpha = 0;
		whiteBG.scrollFactor.set();
		whiteBG.screenCenter();
		add(whiteBG);

		Paths.clearUnusedMemory();

		WeekData.reloadWeekFiles(true);
		loadCodesFromWeeks();
		loadCodesFromJSON();
	}

	function loadCodesFromWeeks():Void
	{
		codes = [];

		for (weekName in WeekData.weeksList)
		{
			var week:WeekData = WeekData.weeksLoaded.get(weekName);
			if (week == null || week.soundTestCode == null) continue;
			var code = week.soundTestCode;
			if (code.length < 3) continue;
			var enabled:Bool = code[2] == true;
			if (!enabled) continue;

			codes.push({
				pcm: Std.int(code[0]),
				da: Std.int(code[1]),
				type: "week",
				path: "",
				isWeek: true,
				weekName: weekName
			});
		}
	}

	function loadCodesFromJSON():Void
	{
		if (!Assets.exists("assets/exe/soundtest/extraCodes.json"))
		{
			trace("JSON no encontrado");
			return;
		}

		try
		{
			var raw:String = Assets.getText("assets/exe/soundtest/extraCodes.json");
			var data:Array<Dynamic> = Json.parse(raw);

			for (entry in data)
			{
				if (entry.code == null || entry.code.length < 2) continue;

				codes.push({
					pcm: Std.int(entry.code[0]),
					da: Std.int(entry.code[1]),
					type: entry.type,
					path: entry.path,
					isWeek: false,
					weekName: ""
				});
			}
		}
		catch (e:Dynamic)
		{
			trace("Error leyendo JSON de SoundTest: " + e);
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

	var changeHold:Float = 0;
	function handleValueChange(elapsed:Float):Void
	{
		var change:Int = 0;

		if (Controls.instance.UI_DOWN_P || FlxG.mouse.wheel < 0){
			change = (FlxG.keys.pressed.SHIFT ? 3 : 1);
			changeHold = 0;
		}
		else if (Controls.instance.UI_UP_P || FlxG.mouse.wheel > 0){
			change = -(FlxG.keys.pressed.SHIFT ? 3 : 1);
			changeHold = 0;
		}

		if(Controls.instance.UI_DOWN || Controls.instance.UI_UP)
		{
			var checkLastHold:Int = Math.floor((changeHold - 0.3) * 10);
			changeHold += elapsed;
			var checkNewHold:Int = Math.floor((changeHold - 0.3) * 10);

			if(changeHold > 0.3 && checkNewHold - checkLastHold > 0)
				change = (checkNewHold - checkLastHold) * (Controls.instance.UI_UP ? -(FlxG.keys.pressed.SHIFT ? 3 : 1) : (FlxG.keys.pressed.SHIFT ? 3 : 1));
		}

		if (change != 0)
		{
			if (isPCMSelected)
				pcmValue = (pcmValue + change + 70) % 70;
			else
				daValue = (daValue + change + 100) % 100;
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

	var notFoundAny:Bool = true;
	var soundCooldown:Bool = true;
	var transitioning:Bool = false;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (subState != null) return;
		if (transitioning) return;

		if (Controls.instance.BACK)
		{
			FlxG.sound.music.fadeOut(0.3);
			transitioning = true;
			FlxG.switchState(() -> new EXEMenu());
			return;
		}

		handleSelection();
		handleValueChange(elapsed);
		updateDisplayedValues();

		if (Controls.instance.ACCEPT)
		{
			for (code in codes)
			{
				if (pcmValue == code.pcm && daValue == code.da)
				{
					notFoundAny = false;
					transitioning = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(whiteBG, {alpha: 1}, 1);

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						if (code.isWeek) loadSong(code.weekName, true);
						else
						{
							switch(code.type)
							{
								case "image":
									trace("Mostrar imagen");

								case "video":
									trace("Reproducir video");
							}
						}

						FlxG.sound.music.fadeOut(0.3);
					});
					break;
				}
			}

			if (pcmValue == 12 && daValue == 25)
			{
				notFoundAny = false;
				CustomShapeTransition.shape = CustomShapeTransition.getShapeByString('INFINITE');
				transitioning = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(whiteBG, {alpha: 1}, 1);
				new FlxTimer().start(1, function(tmr:FlxTimer){
					FlxG.switchState(() -> new states.access.MajinAccess());
					FlxG.sound.music.fadeOut(0.3);
				});
				return;
			}

			if (notFoundAny)
			{
				if (soundCooldown)
				{
					soundCooldown = false;
					FlxG.sound.play(Paths.sound('deniedMOMENT'));
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						soundCooldown = true;
					});
				}
			}
			notFoundAny = true;
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

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));

		backdrop = null;
		titleText = null;
		pcmLabel = null;
		daLabel = null;
		pcmNumber = null;
		daNumber = null;

		super.destroy();
	}
}
