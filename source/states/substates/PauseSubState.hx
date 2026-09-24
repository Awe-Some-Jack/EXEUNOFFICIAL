package states.substates;

import flixel.effects.FlxFlicker;

import backend.WeekData;
import states.StoryModeState;
import states.EXEFreeplay;
import options.OptionsState;
import states.substates.PauseSubState;
import backend.EXEAchievements;

import openfl.utils.Assets;

class PauseSubState extends MusicBeatSubstate
{
	var camPause:FlxCamera;

	var selectionButtons:Array<String> = ['continue', 'restart', 'options', 'exit'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var whiteBG:FlxSprite;
	var separator:FlxSprite;
	var pauseBar:FlxSprite;
	var pauseText:FlxSprite;
	var miniSonic:FlxSprite;
	var selBar:FlxSprite;

	public static var cameraWidth:Int = 1280;
	public static var miniSonicImage:String = 'sonic';
	public static var miniSonicOffsets:Array<Int> = [0, 0];
	public static var songName:String = null;

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true;
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;
		if (noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		FlxG.resetState();
	}

	var menuItems:FlxTypedGroup<FlxSprite>;
	var longneck:FlxTypedGroup<FlxSprite>;
	var _exitTweens:Array<FlxTween> = [];

	override function create()
	{
		camPause = new FlxCamera();
		camPause.bgColor = 0x00000000;
		FlxG.cameras.add(camPause, false);

		super.create();

		whiteBG = new FlxSprite(0, -FlxG.height).makeGraphic(cameraWidth, FlxG.height, 0xFFFFFFFF);
		whiteBG.alpha = 0.35;
		whiteBG.scrollFactor.set();
		add(whiteBG);
		FlxTween.tween(whiteBG, {y: 0}, 0.1);

		separator = new FlxSprite(cameraWidth).loadGraphic(Paths.getBitmapData('assets/exe/pause/separator.webp'));
		separator.scale.set(3, 3);
		separator.updateHitbox();
		separator.antialiasing = false;
		separator.scrollFactor.set();
		add(separator);
		FlxTween.tween(separator, {x: (cameraWidth - separator.width)}, 0.1);

		pauseBar = new FlxSprite(-cameraWidth, 643).makeGraphic(cameraWidth, 39, 0xFF000000);
		add(pauseBar);
		FlxTween.tween(pauseBar, {x: 0}, 0.1);

		var image:String = 'pauseText';
		var weekKey:String = WeekData.weeksList[PlayState.storyWeek];
		var curWeek:WeekData = weekKey != null ? WeekData.weeksLoaded.get(weekKey) : null;
		if (curWeek != null && (curWeek.exeLabel == 'NON EXE' || curWeek.exeLabel == 'MEME' || curWeek.exeLabel == 'OFFICIAL')) 
			image = 'pauseText-normal';
		
		pauseText = new FlxSprite(196, 589).loadGraphic(Paths.getBitmapData('assets/exe/pause/$image.webp'));
		pauseText.scale.set(3, 3);
		pauseText.updateHitbox();
		pauseText.alpha = 0;
		pauseText.antialiasing = false;
		pauseText.scrollFactor.set();
		add(pauseText);
		FlxTween.tween(pauseText, {alpha: 1}, 0.1);

		var daImage:String = 'sonic';
		for (exts in Paths.IMAGE_EXTS)
		{
		    if (Paths.fileExists('pause/mini-sonics/$miniSonicImage-1.$exts', IMAGE, 'exe')) 
			{
			    daImage = miniSonicImage + '-1';
				break;
			}
		}

		for (exts in Paths.IMAGE_EXTS)
		{
		    if (Paths.fileExists('pause/mini-sonics/$miniSonicImage.$exts', IMAGE, 'exe')) 
			{
			    daImage = miniSonicImage;
				break;
			}
		}

		final basePath = 'assets/exe/pause/mini-sonics/' + daImage;
		final bitmap = Paths.getBitmapData(basePath);

		miniSonic = new FlxSprite();

		if (bitmap != null)
		{
			miniSonic.loadGraphic(bitmap);
		}
		else
		{
			trace('Mini Sonic graphic not found: $basePath');
			miniSonic.makeGraphic(1, 1, 0x00000000);
		}

		miniSonic.scale.set(3, 3);
		miniSonic.updateHitbox();
		miniSonic.antialiasing = false;
		miniSonic.scrollFactor.set();
		miniSonic.alpha = 0;
		add(miniSonic);

		FlxTween.tween(miniSonic, {alpha: 1}, 0.1);

		longneck = new FlxTypedGroup<FlxSprite>();
		add(longneck);
		if (miniSonicImage == 'omw')
		{
			longneck.add(miniSonic);

			var neck:FlxSprite = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/pause/mini-sonics/omw-2.webp'));
			neck.scale.set(3, 3);
			neck.updateHitbox();
			neck.antialiasing = false;
			neck.scrollFactor.set();
			neck.alpha = 0;
			FlxTween.tween(neck, {alpha: 1}, 0.1);
			longneck.add(neck);
			add(neck);

			var head:FlxSprite = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/pause/mini-sonics/omw-3.webp'));
			head.scale.set(3, 3);
			head.updateHitbox();
			head.antialiasing = false;
			head.scrollFactor.set();
			head.alpha = 0;
			FlxTween.tween(head, {alpha: 1}, 0.1);
			longneck.add(head);
			add(head);
		}

		selBar = new FlxSprite(cameraWidth, 181 - 40).loadGraphic(Paths.getBitmapData('assets/exe/pause/selected.webp'));
		selBar.scale.set(3, 3);
		selBar.updateHitbox();
		selBar.antialiasing = false;
		selBar.scrollFactor.set();
		add(selBar);
		FlxTween.tween(selBar, {x: (cameraWidth - (selBar.width - 56))}, 0.1);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		final itemSpacing:Float = 16;
		final itemHeight:Float  = 129;
		final itemX:Float       = cameraWidth - 241;
		for (i in 0...selectionButtons.length)
		{
			var menuItem:FlxSprite = new FlxSprite(itemX, itemHeight * (i + 1) + itemSpacing * (i + 1) - 40)
				.loadGraphic(Paths.getBitmapData('assets/exe/pause/${selectionButtons[i]}.webp'));
			menuItem.scale.set(3, 3);
			menuItem.updateHitbox();
			menuItem.antialiasing = false;
			menuItem.alpha = 0;
			menuItem.scrollFactor.set();
			menuItems.add(menuItem);
			add(menuItem);
			FlxTween.tween(menuItem, {alpha: 1}, 0.1);
		}

		miniSonic.x = menuItems.members[0].x - miniSonic.width + miniSonicOffsets[0];
		miniSonic.y = (menuItems.members[0].y + menuItems.members[0].height) - miniSonic.height + miniSonicOffsets[1];
		if (miniSonicImage == 'omw')
		{
			longneck.members[1].x = longneck.members[0].x;
			longneck.members[1].y = longneck.members[0].y - longneck.members[1].height;
			longneck.members[2].x = longneck.members[0].x;
			longneck.members[2].y = longneck.members[1].y - longneck.members[2].height;
		}

		cameras = [camPause];

		pauseMusic = new FlxSound();
		if (miniSonicImage == 'vanilla-milk-2')
		{
			pauseMusic.loadEmbedded(Assets.getSound('assets/exe/music/trololo.ogg'), true, true);

			EXEAchievements.unlock('troll');
			EXEAchievements.save();
		}
		else pauseMusic.loadEmbedded(Assets.getSound('assets/exe/music/pause.ogg'), true, true);
		pauseMusic.volume = 0;
		if (miniSonicImage == 'vanilla-milk-2') pauseMusic.volume = 0.5;
		pauseMusic.play(false, 0);
		FlxG.sound.list.add(pauseMusic);

		if (miniSonicImage == 'hollow-3')
		{
			EXEAchievements.unlock('void');
			EXEAchievements.save();
		}
	}

	static inline final MUSIC_FADE_RATE:Float = 0.01;

	var isSelecting:Bool = false;
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += MUSIC_FADE_RATE * elapsed;

		super.update(elapsed);

		if (isSelecting) return;

		if (controls.BACK)
		{
			isSelecting = true;
			selectOption(0);
			return;
		}

		#if mobile
		if(curSelected != 0 && FlxG.mouse.overlaps(menuItems.members[0], camPause)) {
			curSelected = 0;
			changeSelection(0);
		} else if(curSelected != 1 && FlxG.mouse.overlaps(menuItems.members[1], camPause)) {
			curSelected = 1;
			changeSelection(0);
		} else if(curSelected != 2 && FlxG.mouse.overlaps(menuItems.members[2], camPause)) {
			curSelected = 2;
			changeSelection(0);
		} else if(curSelected != 3 && FlxG.mouse.overlaps(menuItems.members[3], camPause)) {
			curSelected = 3;
			changeSelection(0);
		}
		#end
		
		if (controls.UI_UP_P)   changeSelection(-1);
		if (controls.UI_DOWN_P) changeSelection(1);

		if (controls.ACCEPT #if mobile || (shortPress && FlxG.mouse.overlaps(menuItems.members[curSelected], camPause)) #end)
		{
			FlxG.sound.play(Paths.sound('confirmCD'), 0.7);
			isSelecting = true;
			new FlxTimer().start(0.4, (_) -> selectOption(curSelected));
			FlxFlicker.flicker(menuItems.members[curSelected], 0.4, 0.05, false);
		}
	}

	var ableToChange:Bool = true;
	function changeSelection(change:Int)
	{
		if (!ableToChange) return;

		curSelected = FlxMath.wrap(curSelected + change, 0, selectionButtons.length - 1);
		ableToChange = false;
		new FlxTimer().start(0.1, (_) -> ableToChange = true);

		var item:FlxSprite = menuItems.members[curSelected];
		miniSonic.y = (item.y + item.height) - miniSonic.height + miniSonicOffsets[1];
		if (miniSonicImage == 'omw')
		{
			longneck.members[1].scale.y = ((curSelected + 1) * 3) + (curSelected * (48 * 3));
			longneck.members[1].updateHitbox();

			backend.EXEAchievements.unlock('neck');
			backend.EXEAchievements.checkFinale();
			backend.EXEAchievements.save();
		}

		selBar.x = cameraWidth;
		selBar.y = 36 + (129 * (curSelected + 1) + (16 * (curSelected + 1))) - 40;
		FlxTween.tween(selBar, {x: (cameraWidth - (selBar.width - 56))}, 0.1);

		FlxG.sound.play(Paths.sound('changeCD'), 0.5);
	}

	override function destroy()
	{
		FlxG.cameras.remove(camPause, true);
		pauseMusic.destroy();
		super.destroy();
	}

	function selectOption(select:Int = 0)
	{
		FlxTween.tween(whiteBG,   {y: -FlxG.height}, 0.1);
		FlxTween.tween(separator, {x: cameraWidth},   0.1);
		FlxTween.tween(pauseBar,  {x: -cameraWidth},  0.1);
		FlxTween.tween(pauseText, {alpha: 0},          0.1);
		FlxTween.tween(miniSonic, {alpha: 0},          0.1);
		if (miniSonicImage == 'omw')
		{
			FlxTween.tween(longneck.members[1], {alpha: 0}, 0.1);
			FlxTween.tween(longneck.members[2], {alpha: 0}, 0.1);
		}
		FlxTween.tween(selBar,    {x: cameraWidth},   0.1);
		for (button in menuItems.members)
			FlxTween.tween(button, {alpha: 0}, 0.1);

		new FlxTimer().start(0.1, (_) -> {
			switch (select)
			{
				case 0:
					close();
				case 1:
					PauseSubState.restartSong();
				case 2:
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.canResync = false;
					OptionsState.onPlayState = true;
					FlxG.switchState(() -> new OptionsState());
					FlxG.sound.playMusic(Assets.getSound('assets/exe/music/pause.ogg'), 1);
				case 3:
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter    = 0;
					PlayState.seenCutscene    = false;
					PlayState.firstPlay       = false;
					PlayState.instance.canResync = false;
					Mods.loadTopMod();
					if (states.StoryModeState.fromStoryMode) { states.StoryModeState.fromStoryMode = false; FlxG.switchState(() -> new states.StoryModeState()); }
					else if (states.SoundTest.fromSoundTest) { states.SoundTest.fromSoundTest = false; FlxG.switchState(() -> new states.SoundTest()); }
					else if (states.parallax.StoryParallaxState.fromParallax) { states.parallax.StoryParallaxState.fromParallax = false; FlxG.switchState(() -> new states.parallax.StoryParallaxState()); }
					else if (states.access.FridgeAccess.fromFridge) { states.access.FridgeAccess.fromFridge = false; FlxG.switchState(() -> new states.access.FridgeAccess()); }
					else if (states.access.MajinAccess.fromMajin) { states.access.MajinAccess.fromMajin = false; FlxG.switchState(() -> new states.access.MajinAccess()); }
					else FlxG.switchState(() -> new EXEFreeplay());
					PlayState.changedDifficulty = false;
					PlayState.chartingMode      = false;
					FlxG.camera.followLerp      = 0;
			}
		});
	}
}
