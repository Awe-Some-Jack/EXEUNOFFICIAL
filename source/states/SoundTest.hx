package states;

import backend.WeekData;
import backend.Song;
import backend.Highscore;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
import openfl.utils.Assets as AssetPaths;
import backend.Paths;
import haxe.Json;
import states.substates.SoundTestSubState;

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
	static final ARROW_ICONS:Array<String> = ["^", "<", "v", ">"];

	var codes:Array<SoundTestData> = [];
	public static var savedCode:Array<Int> = [];

	var backdrop:FlxBackdrop;
	var whiteBG:FlxSprite;
	var pcmLabel:FlxSprite;
	var daLabel:FlxSprite;

	var pcmDigits:Array<FlxSprite> = [];
	var daDigits:Array<FlxSprite> = [];

	var _digitFrames:Array<flixel.graphics.frames.FlxFrame> = [];
	var pcmValue:Int = 0;
	var daValue:Int = 0;

	var cooldownTimer = 0.1;

	var isPCMSelected:Bool = true;
	var currentArrowIndex:Int = 0;

	var arrowTimer:FlxTimer;
	var previousWindowTitle:String;
	static var menuSong:Bool = false;

	public static var fromSoundTest:Bool = false;
	public static var enterTheValleyAfterBlackSun:Bool = false;

	var save:FlxSave;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();

		if (FlxG.stage?.window != null)
			previousWindowTitle = FlxG.stage.window.title;

		initCamera();
		loadMusic();
		createBackground();
		createTitle();
		createLabels();
		createNumbers();
		startArrowAnimation();
		updateLabelColors();

		menuSong = false;

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		whiteBG.alpha = 0;
		whiteBG.scrollFactor.set();
		whiteBG.screenCenter();
		add(whiteBG);

		Paths.clearUnusedMemory();

		WeekData.reloadWeekFiles(true);
		loadCodesFromJSON();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Sound test", null);
		#end

		save = new FlxSave();
		save.bind('savedSongs', CoolUtil.getSavePath());
		if (save.data.songs == null) save.data.songs = [];

		#if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
	}

	function loadCodesFromJSON():Void
	{
		codes = [];

		if (!AssetPaths.exists("assets/exe/soundtest/extraCodes.json"))
		{
			trace("JSON not founded");
			return;
		}

		try
		{
			final raw:String = AssetPaths.getText("assets/exe/soundtest/extraCodes.json");
			final data:Array<Dynamic> = Json.parse(raw);

			for (entry in data)
			{
				if (entry.code == null || entry.code.length < 2) continue;
				final isWeekEntry:Bool = entry.type == "week";
				codes.push({
					pcm: Std.int(entry.code[0]),
					da: Std.int(entry.code[1]),
					type: entry.type,
					path: isWeekEntry ? "" : entry.path,
					isWeek: isWeekEntry,
					weekName: isWeekEntry ? entry.weekName : ""
				});
			}
		}
		catch (e:Dynamic)
		{
			trace("Errpr on soundTest JSON: " + e);
		}
	}

	function loadMusic():Void
	{
		FlxG.sound.playMusic(AssetPaths.getSound('assets/exe/music/pause.ogg'));
	}

	function createBackground():Void
	{
		backdrop = new FlxBackdrop('assets/exe/soundtest/bgtest.webp', FlxAxes.XY);
		backdrop.scale.set(3.0, 3.0);
		backdrop.velocity.set(-50.0, -50.0);
		add(backdrop);
	}

	function createTitle():Void
	{
		final title = new FlxSprite().loadGraphic(AssetPaths.getBitmapData('assets/exe/soundtest/soundtest.webp', true, true));
		title.antialiasing = false;
		title.scale.set(3.0, 3.0);
		title.updateHitbox();
		title.screenCenter(X); title.x = Std.int(title.x);
		title.y = (FlxG.height / 2) - 220.0;
		add(title);
	}

	function createLabels():Void
	{
		final pcmX:Float = (FlxG.width / 6) + 100.0;
		final daX:Float = FlxG.width * 0.6;
		final labelY:Float = (FlxG.height / 2) - 70.0;

		pcmLabel = new FlxSprite(pcmX, labelY);
		pcmLabel.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/soundtest/pcm.webp', true, true), 'assets/exe/soundtest/pcm.xml');
		pcmLabel.animation.addByPrefix('idle', 'pcm idle', 24, false);
		pcmLabel.animation.addByPrefix('selected', 'pcm selected', 24, false);
		pcmLabel.animation.play('idle');
		pcmLabel.antialiasing = false;
		pcmLabel.scale.set(3.0, 3.0);
		pcmLabel.updateHitbox();
		add(pcmLabel);

		daLabel = new FlxSprite(daX, labelY);
		daLabel.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/soundtest/dano.webp', true, true), 'assets/exe/soundtest/dano.xml');
		daLabel.animation.addByPrefix('idle', 'dano idle', 24, false);
		daLabel.animation.addByPrefix('selected', 'dano selected', 24, false);
		daLabel.animation.play('idle');
		daLabel.antialiasing = false;
		daLabel.scale.set(3.0, 3.0);
		daLabel.updateHitbox();
		add(daLabel);
	}

	function createNumbers():Void
	{
		final frames = FlxAtlasFrames.fromSparrow(
			'assets/exe/soundtest/numbers.webp',
			'assets/exe/soundtest/numbers.xml'
		);
		
		for (i in 0...10)
			_digitFrames.push(frames.getByName('numbers ' + i + '0000'));

		final pcmX:Float = (FlxG.width / 6) + 270.0;
		final daX:Float = (FlxG.width * 0.6) + 150.0;
		final numberY:Float = (FlxG.height / 2) - 70.0;
		final digitScale:Float = 3.0;
		final digitGap:Float = 8.0 * digitScale;
		
		for (i in 0...2)
		{
			final pd = new FlxSprite(pcmX + i * digitGap, numberY);
			pd.frames = frames;
			pd.antialiasing = false;
			pd.scale.set(digitScale, digitScale);
			pd.updateHitbox();
			add(pd);
			pcmDigits.push(pd);

			final dd = new FlxSprite(daX + i * digitGap, numberY);
			dd.frames = frames;
			dd.antialiasing = false;
			dd.scale.set(digitScale, digitScale);
			dd.updateHitbox();
			add(dd);
			daDigits.push(dd);
		}
	}

	function startArrowAnimation():Void
	{
		updateWindowTitle();
		arrowTimer = new FlxTimer().start(3.0, (_) -> {
			currentArrowIndex = (currentArrowIndex + 1) % ARROW_ICONS.length;
			updateWindowTitle();
		}, 0);
	}

	function updateLabelColors():Void
	{
		if (isPCMSelected)
		{
			pcmLabel.animation.play('selected');
			daLabel.animation.play('idle');
		}
		else
		{
			pcmLabel.animation.play('idle');
			daLabel.animation.play('selected');
		}
	}

	function updateWindowTitle():Void
	{
		try
		{
			final arrow:String = ARROW_ICONS[currentArrowIndex];
			if (FlxG.stage?.window != null)
				FlxG.stage.window.title = arrow + " SOUND TEST " + arrow;
		}
		catch (e:Dynamic)
		{
			trace("Error updating window title: " + e);
		}
	}

	var _mouseWasRight:Bool = false;
	
	function handleSelection():Void
	{
		if (controls.UI_RIGHT_P || controls.UI_LEFT_P)
		{
			isPCMSelected = !isPCMSelected;
			updateLabelColors();
		}

		final mouseRight:Bool = FlxG.mouse.x > FlxG.width / 2;
		if (mouseRight != _mouseWasRight)
		{
			_mouseWasRight = mouseRight;
			isPCMSelected = !mouseRight;
			updateLabelColors();
		}
	}

	var changeHold:Float = 0;
	
	function handleValueChange(elapsed:Float):Void
	{
		var change:Int = 0;

		if (controls.UI_DOWN_P || FlxG.mouse.deltaWheel.y < 0 #if mobile || swipeDOWN || (deltaMouseY > 5 && cooldownTimer <= 0 && pressHolding) #end)
		{
			cooldownTimer = 0.1;
			change = (FlxG.keys.pressed.SHIFT ? 3 : 1);
			changeHold = 0;
		}
		else if (controls.UI_UP_P || FlxG.mouse.deltaWheel.y > 0 #if mobile || swipeUP || (deltaMouseY < -5 && cooldownTimer <= 0 && pressHolding) #end)
		{
			cooldownTimer = 0.1;
			change = -(FlxG.keys.pressed.SHIFT ? 3 : 1);
			changeHold = 0;
		}

		if (controls.UI_DOWN || controls.UI_UP)
		{
			final checkLastHold:Int = Math.floor((changeHold - 0.3) * 10);
			changeHold += elapsed;
			final checkNewHold:Int = Math.floor((changeHold - 0.3) * 10);

			if (changeHold > 0.3 && checkNewHold - checkLastHold > 0)
				change = (checkNewHold - checkLastHold) * (controls.UI_UP ? -(FlxG.keys.pressed.SHIFT ? 3 : 1) : (FlxG.keys.pressed.SHIFT ? 3 : 1));
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
		setDigitFrames(pcmDigits, pcmValue);
		setDigitFrames(daDigits, daValue);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Sound test", 'PCM NO. $pcmValue - DA NO. $daValue');
		#end
	}

	inline function setDigitFrames(digits:Array<FlxSprite>, value:Int):Void
	{
		digits[0].frame = _digitFrames[Std.int(value / 10)];
		digits[1].frame = _digitFrames[value % 10];
	}

	var notFoundAny:Bool = true;
	var soundCooldown:Bool = true;
	var transitioning:Bool = false;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (subState != null) return;
		if (transitioning) return;

		if(cooldownTimer > 0) cooldownTimer -= elapsed;

		handleSelection();
		handleValueChange(elapsed);
		updateDisplayedValues();

		if (controls.BACK #if mobile || backPressed #end)
		{
			menuSong = true;
			transitioning = true;
			FlxG.sound.music?.fadeOut(0.3);
			FlxG.switchState(() -> new EXEMenu());
		}

		if (controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end)
		{
			notFoundAny = true;
			
			for (code in codes)
			{
				if (pcmValue == code.pcm && daValue == code.da)
				{
					notFoundAny = false;
					transitioning = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.sound.music?.fadeOut(0.3);
					whiteBG.alpha = 0;
					FlxTween.cancelTweensOf(whiteBG);
					FlxTween.tween(whiteBG, {alpha: 1}, 1, {
						onComplete: (_) -> {
							if (code.isWeek && code.weekName == 'starv')
							{
								minigames.preymini.PreyMini.fromSoundTest = true;
								FlxG.switchState(() -> new minigames.preymini.PreyMini());
							}
							else if (code.isWeek) 
							{
								trace("loading week");
								loadSong(code.weekName, true);
							}
							else
							{
								savedCode = [pcmValue, daValue];

								trace("Saving code: " + savedCode);
								var a = backend.EXEAchievements.get('secondary');
								var savedCodes:Array<Array<Int>> = cast(a.extra ?? []);
								if(!savedCodes.contains(savedCode)) savedCodes.push(savedCode);
								a.extra = savedCodes;

								persistentUpdate = false;
								persistentDraw = true;
								openSubState(new SoundTestSubState((code.type.toLowerCase() == 'video'), code.path));
							}
						}
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
				FlxG.sound.music?.fadeOut(0.3);
				
				FlxTween.tween(whiteBG, {alpha: 1}, 1, {
					onComplete: (_) -> {
						FlxG.switchState(() -> new states.access.MajinAccess());
						FlxG.sound.music?.fadeOut(0.3);
					}
				});
				return;
			}

			if (pcmValue == 19 && daValue == 91) {
				notFoundAny = false;
				transitioning = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.sound.music?.fadeOut(0.3);
				
				FlxTween.tween(whiteBG, {alpha: 1}, 1, {
					onComplete: (_) -> {
						{
							persistentUpdate = false;
							persistentDraw = true;
							openSubState(new SoundTestSubState(true, "assets/exe/soundtest/videos/starvedarg1final.mp4"));
						}
					}
				});
			}
			if (pcmValue == 9 && daValue == 23) {
				notFoundAny = false;
				CoolUtil.browserLoad('https://youtu.be/ectquv64pZ0');
			}
			if (pcmValue == 11 && daValue == 21) {
				notFoundAny = false;
				CoolUtil.browserLoad('https://youtu.be/o1Oum6QOEnk?si=J2AnC6JyMiVLK5Sy ');
			}

			//19-91 - Starved arg 1
			//09-23 - Starved arg 2
			//11-21 - Starved arg 3
			//02-23 - Starved Eggman

			if (notFoundAny && soundCooldown)
			{
				soundCooldown = false;
				FlxG.sound.play(Paths.sound('deniedMOMENT'), 0.6);
				new FlxTimer().start(0.8, (_) -> { soundCooldown = true; });
			}
		}
	}

	function loadSong(name:String, isWeek:Bool = false):Void
	{
		enterTheValleyAfterBlackSun = false;
		minigames.preymini.PreyMini.songLives = 0;
		minigames.preymini.PreyMini.songRings = -1;
		if (isWeek)
		{
			final leWeek:WeekData = WeekData.weeksLoaded.get(name);
			if (leWeek == null)
			{
				trace(leWeek);
				lime.app.Application.current.window.alert("NOT FOUNDED WEEK: " + name, "SoundTest Error:");
				FlxG.resetState();
				return;
			}

			if (leWeek.folder != null && leWeek.folder != "")
				Mods.currentModDirectory = leWeek.folder;
				
			WeekData.setDirectoryFromWeek(leWeek);

			try
			{
				PlayState.storyPlaylist = [for (song in leWeek.songs) if (Paths.formatToSongPath(song[0]) != 'stardust-speedway') Paths.formatToSongPath(song[0])];
				final firstSong:String = PlayState.storyPlaylist[0];
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 1;
				PlayState.storyWeek = WeekData.weeksList.indexOf(name);
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;

				@:privateAccess
				if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
					Paths.freeGraphicsFromMemory();

				Song.loadFromJson(firstSong, firstSong);
			}
			catch (e:Dynamic)
			{
				trace("Error cargando week: " + e);
				transitioning = false;
				return;
			}
		}
		else
		{
			final songLower = Paths.formatToSongPath(name);

			try
			{
				PlayState.storyPlaylist = [songLower];
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 0;

				@:privateAccess
				if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
					Paths.freeGraphicsFromMemory();

				Song.loadFromJson(songLower, songLower);
			}
			catch (e:Dynamic)
			{
				trace("Error cargando canción: " + e);
				transitioning = false;
				return;
			}
		}

		if (isWeek && name == 'exetior')
		{
			FlxG.sound.music?.stop();
			SoundTest.fromSoundTest = true;
			FlxG.switchState(() -> new states.access.cutscene.SharpyCutscene());
			return;
		}
		enterTheValleyAfterBlackSun = isWeek && name.toLowerCase() == 'exe';
		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
		FlxG.sound.music?.stop();
		SoundTest.fromSoundTest = true;
	}

	override function closeSubState():Void
	{
		super.closeSubState();

		persistentUpdate = true;
		transitioning = false;
		FlxTween.tween(whiteBG, {alpha: 0}, 0.2);

		if (savedCode == [24, 4])
		{
			backend.EXEAchievements.unlock('mattpro');
			backend.EXEAchievements.save();
		}

		backend.EXEAchievements.checkSecondaryCodes();
		savedCode = [];
	}

	override public function destroy():Void
	{
		arrowTimer?.cancel();
		arrowTimer = null;

		if (FlxG.stage?.window != null)
			FlxG.stage.window.title = previousWindowTitle;

		if (menuSong) 
			FlxG.sound.playMusic(AssetPaths.getSound('assets/exe/music/menu.ogg'));

		super.destroy();
	}
}