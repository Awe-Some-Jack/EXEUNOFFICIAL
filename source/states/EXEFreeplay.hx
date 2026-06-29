package states;

import backend.WeekData;
import backend.Song;
import backend.Highscore;
import backend.Language;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;

import openfl.display.BitmapData;

typedef ExeSongInfo = {
	var songName:String;
	var coverFile:String;
	var title:String;
	var exeLabel:String;
	var transitionShape:String;
	var bgColor:Array<Int>;
}

typedef ExeSongEntry = {
	var week:Int;
	var folder:String;
	var songs:Array<ExeSongInfo>;
}

class EXEFreeplay extends MusicBeatState
{
	static inline final BOX_SCALE:Float = 0.52;
	static inline final BOX_SCALE_SELECTED:Float = 0.58;
	static inline final BOX_SCALE_SONG:Float = 0.63;
	static inline final COVER_SCALE:Float = 0.35;
	static inline final COVER_SCALE_SELECTED:Float = 0.39;
	static inline final COVER_SCALE_SONG:Float = 0.421;
	static inline final BOX_SPACING_X:Float = -75;
	static inline final CHANGE_COOLDOWN:Float = 0;
	static inline final ARROW_UPDATE_INTERVAL:Float = 0.5;
	static inline final TWEEN_DURATION:Float = 0.3;

	static inline final PATH_FREEBOX:String = 'assets/exe/freeplayassets/boxes/FreeBox.png';
	static inline final PATH_COVERS:String = 'assets/exe/freeplayassets/covers/';
	static inline final FONT_PATH:String = 'assets/fonts/sonicfree.otf';

	static inline final TITLE_SIZE:Int = 44;
	static inline final EXE_LABEL_SIZE:Int = 34;
	static inline final SONG_TITLE_SIZE:Int = 48;
	static inline final SONG_SPACING_Y:Float = 65;
	static inline final MAX_VISIBLE_SONGS:Int = 2;
	
	var songEntries:Array<ExeSongEntry> = [];

	var bgChecker:FlxBackdrop;
	var bgSonic:FlxBackdrop;
	var verticalLine:FlxSprite;
	var degradado:FlxSprite;
	var spikesUp:FlxBackdrop;
	var freeBoxes:FlxTypedGroup<FlxSprite>;
	var covers:FlxTypedGroup<FlxSprite>;
	var exeTexts:FlxTypedGroup<FlxText>;
	var intendedColor:Int;

	var charText:FlxText;
	var songTexts:FlxTypedGroup<FlxText>;

	var staticScreens:FlxTypedGroup<FlxSprite>;
	var staticTween:FlxTween;

	var cardGroups:Array<FlxTypedGroup<FlxSprite>> = [];
	var cardGroupsLayer:FlxTypedGroup<FlxTypedGroup<FlxSprite>>;
	var cardPositions:Array<FlxObject> = [];
	
	public static var selectedBox:Int = 0;
	var changeCooldown:Float = 0;
	var choosingSong:Bool = false;
	var songSelector:Int = 0;
	var songScrollOffset:Int = 0;
	var activeSongCount:Int = 0;
	var boxWidth:Float = 0;
	var centerX:Float = 0;
	var centerY:Float = 0;
	var previousWindowName:String = "";

	static final ARROW_ICONS:Array<String> = ["^", "<", "v", ">"];
	var currentArrowIndex:Int = 0;
	var arrowTimer:FlxTimer;

	var curDifficulty:Int = -1;
	static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var rankText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;
	
	var stopMusicPlay:Bool = false;
	
	var holdCheck:Float = 0;

	override function create()
	{
		if (FlxG.stage?.window != null)
			previousWindowName = FlxG.stage.window.title;

		Paths.clearStoredMemory();

		PlayState.isStoryMode = false;
		Mods.loadTopMod();
		WeekData.reloadWeekFiles(false);

		buildSongList();

		//Desactiva esto para usar el desbloqueo de Mania! - Uncomment this to use Mania's Unlock!
		// new FlxTimer().start(0.6, (_) -> maniaNotif());
		
		if (songEntries.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			FlxG.switchState(() -> new EXEMenu());
			return;
		}

		covers = new FlxTypedGroup<FlxSprite>();
		freeBoxes = new FlxTypedGroup<FlxSprite>();
		exeTexts = new FlxTypedGroup<FlxText>();
		songTexts = new FlxTypedGroup<FlxText>();

		final charSize = Language.cjkSize(TITLE_SIZE);
		charText = new FlxText(0, 5, FlxG.width, "", charSize);
		charText.setFormat(Paths.font(Language.getFontForLanguage()), charSize, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charText.antialiasing = false;
		charText.borderSize = 3;
		
		loadBgSonic();
		loadBgChecker();
		loadVerticalLine();

		staticScreens = new FlxTypedGroup<FlxSprite>();
		cardGroups = [];
		cardPositions = [];
		cardGroupsLayer = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();
		add(cardGroupsLayer);

		loadDegradado();
		loadSpikesUp();
		loadVignette();

		add(exeTexts);

		final uiSize = Language.cjkSize(44);
		rankText = new FlxText(0, 0, 0, Language.get('freeplay.rank', 'RANK') + ': -', uiSize);
		rankText.setFormat(Paths.font(Language.getFontForLanguage()), uiSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankText.antialiasing = false;
		rankText.borderSize = 3;
		rankText.y = FlxG.height - rankText.height - 10;

		scoreText = new FlxText(0, 0, 0, Language.get('freeplay.score', 'SCORE') + ': 0', uiSize);
		scoreText.setFormat(Paths.font(Language.getFontForLanguage()), uiSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.antialiasing = false;
		scoreText.borderSize = 3;
		scoreText.y = rankText.y - scoreText.height - 4;

		scoreBG = new FlxSprite(0, scoreText.y - 4).makeGraphic(1, Std.int(FlxG.height - scoreText.y + 4), 0xFF000000);
		scoreBG.alpha = 0.6;
		
		add(scoreBG);
		add(scoreText);
		add(rankText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		add(charText);
		add(songTexts);

		createBoxesAndCovers();

		if (songEntries.length > 0)
		{
			Mods.currentModDirectory = songEntries[0].folder;
			PlayState.storyWeek = songEntries[0].week;
			Difficulty.loadFromWeek();
		}

		final firstSongColor = songEntries[selectedBox].songs[0].bgColor;
		bgSonic.color = FlxColor.fromRGB(firstSongColor[0], firstSongColor[1], firstSongColor[2]);
		intendedColor = bgSonic.color;
		if (verticalLine != null) verticalLine.color = intendedColor;

		curDifficulty = getNormalDiffIdx();
		if (Difficulty.list.length == 0) curDifficulty = 0;
		lastDifficultyName = Difficulty.list.length > 0 ? Difficulty.getString(curDifficulty, false) : '';

		updateSelection(false);
		loadCharText(selectedBox);
		loadSongList(selectedBox);
		changeDiff(0);
		updateScoreDisplay();

		updateWindowTitle();
		
		arrowTimer = new FlxTimer().start(ARROW_UPDATE_INTERVAL, (_) -> {
			currentArrowIndex = (currentArrowIndex + 1) % ARROW_ICONS.length;
			updateWindowTitle();
		}, 0);

		super.create();
		
		CustomShapeTransition.shape = HEAD;
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/freeplay.ogg'));
		Conductor.bpm = 96;
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Freeplay", null);
		#end
	}

	function buildSongList():Void
	{
		songEntries = [];
		for (i in 0...WeekData.weeksList.length)
		{
			if (i == 0) continue;
			
			final weekName:String = WeekData.weeksList[i];
			if (weekIsLocked(weekName)) continue;

			final leWeek:WeekData = WeekData.weeksLoaded.get(weekName);
			WeekData.setDirectoryFromWeek(leWeek);

			final songInfoList:Array<ExeSongInfo> = [];
			final weekExeTitle:String = (leWeek.exeTitle != null && leWeek.exeTitle.length > 0) ? leWeek.exeTitle : null;
			final weekExeCover:String = (leWeek.exeCover != null && leWeek.exeCover.length > 0) ? leWeek.exeCover : 'placeholder';
			final weekExeLabel:String = (leWeek.exeLabel != null && leWeek.exeLabel.length > 0) ? leWeek.exeLabel : 'NON EXE';
			final weekTransition:String = (leWeek.transitionShape != null && leWeek.transitionShape.length > 0) ? leWeek.transitionShape : 'HEAD';

			for (song in leWeek.songs)
			{
				final sName:String = song[0];
				final title:String = weekExeTitle ?? sName.toUpperCase();
				
				songInfoList.push({
					songName: sName,
					coverFile: weekExeCover,
					title: title,
					exeLabel: weekExeLabel,
					bgColor: leWeek.bgColor,
					transitionShape: weekTransition
				});
			}

			if (songInfoList.length == 0) continue;
			
			songEntries.push({
				week: i,
				folder: Mods.currentModDirectory ?? '',
				songs: songInfoList
			});
		}
	}

	public static var maniaUnlock:Bool = false;
	
	function maniaNotif():Void 
	{
		final maniaNotifSprite = new FlxSprite();
		maniaNotifSprite.loadGraphic(Assets.getBitmapData('assets/exe/freeplayassets/unlock/mania-notif.png'));
		maniaNotifSprite.scale.set(0.3, 0.3);
		maniaNotifSprite.setPosition(250, -340);
		add(maniaNotifSprite);

		FlxG.sound.play(Paths.sound('maniacorreo'));
		FlxTween.tween(maniaNotifSprite, {y: maniaNotifSprite.y + 120}, 1, {
			ease: FlxEase.circOut, 
			onComplete: (_) -> {
				new FlxTimer().start(2, (_) -> FlxTween.tween(maniaNotifSprite, {y: maniaNotifSprite.y - 140}, 1, {
					ease: FlxEase.circIn, 
					onComplete: (_) -> {
						FlxG.camera.fade(FlxColor.BLACK, 1);
						FlxG.sound.music?.fadeOut(0, 1);
						new FlxTimer().start(1, (_) -> { 
							FlxG.switchState(() -> new EXEMenu()); 
							maniaUnlock = true;
						});
					}
				}));
			}
		});
	}

	static function loadRawBitmap(path:String):BitmapData
	{
		try
		{
			#if sys
			return BitmapData.fromFile(path);
			#else
			return openfl.utils.Assets.getBitmapData(path);
			#end
		}
		catch (e:Dynamic) {}
		return null;
	}

	function createBoxesAndCovers():Void
	{
		final boxBitmap = loadRawBitmap(PATH_FREEBOX);
		boxWidth = (boxBitmap != null) ? (boxBitmap.width * BOX_SCALE) + BOX_SPACING_X : 150;

		centerX = FlxG.width / 2;
		centerY = FlxG.height / 2;

		for (i in 0...songEntries.length)
		{
			final entry = songEntries[i];
			final firstSong = entry.songs[0];

			final cardGroup = new FlxTypedGroup<FlxSprite>();
			cardGroups.push(cardGroup);
			cardGroupsLayer.add(cardGroup);
			
			final proxy = new FlxObject(0, 0);
			cardPositions.push(proxy);

			final coverPath = PATH_COVERS + Paths.formatToSongPath(firstSong.songName) + '.png';
			var coverBitmap = loadRawBitmap(coverPath);
			coverBitmap ??= loadRawBitmap(PATH_COVERS + 'placeholder.png');
			coverBitmap ??= loadRawBitmap('assets/exe/freeplayassets/placeholder.png');
			
			if (coverBitmap != null)
			{
				final cover = new FlxSprite(0, 0).loadGraphic(coverBitmap);
				cover.scale.set(COVER_SCALE, COVER_SCALE);
				cover.updateHitbox();
				cover.ID = i;
				covers.add(cover);
				cardGroup.add(cover);

				final ss = new FlxSprite(0, 0);
				ss.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.png', 'assets/exe/story/screenstatic.xml');
				ss.animation.addByPrefix('play', 'screenSTATIC', 24);
				ss.animation.play('play');
				ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
				ss.updateHitbox();
				ss.x = cover.x;
				ss.y = cover.y;
				ss.alpha = 0.18;
				ss.ID = i;
				staticScreens.add(ss);
				cardGroup.add(ss);
			}

			if (boxBitmap != null)
			{
				final box = new FlxSprite(0, 0).loadGraphic(boxBitmap);
				box.scale.set(BOX_SCALE, BOX_SCALE);
				box.updateHitbox();
				box.ID = i;

				freeBoxes.add(box);
				cardGroup.add(box);
			}

			final daColor:Int = switch (firstSong.exeLabel)
			{
				case 'NON EXE': 0xFF8888FF;
				case 'OFFICIAL': 0xFFFFDD2F;
				case 'ENTITY': 0xFFC23EFF;
				case 'GLITCH': 0xFFFFFFFF;
				case 'MEME': 0xFF19EAA8;
				default: 0xFFFF0000;
			}

			final labelIndex:Int = switch (firstSong.exeLabel)
			{
				case 'NON EXE': 1;
				case 'OFFICIAL': 2;
				case 'MEME': 3;
				case 'ENTITY': 4;
				case 'GLITCH': 5;
				default: 0;
			};

			final translatedLabels = Language.getArray('freeplay.labels', []);
			final actualLabel = (translatedLabels.length > labelIndex) ? translatedLabels[labelIndex] : firstSong.exeLabel;

			final exeSize = Language.cjkSize(EXE_LABEL_SIZE);
			final exeText = new FlxText(30, 0, 0, actualLabel, exeSize);
			exeText.setFormat(Paths.font(Language.getFontForLanguage()), exeSize, daColor, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			exeText.borderSize = 2;
			exeText.ID = i;
			exeText.visible = (i == selectedBox);
			exeText.alpha = exeText.visible ? 1.0 : 0.0;
			exeText.antialiasing = false;
			exeTexts.add(exeText);
		}
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (subState != null) return;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (bgChecker != null && bgSonic != null)
		{
			bgChecker.color = bgSonic.color;
			bgChecker.alpha = 0.10;
		}

		if (changeCooldown > 0) changeCooldown -= elapsed;

		final prevScore = lerpScore;
		final prevRating = lerpRating;
		
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));
		
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;
		
		if (lerpScore != prevScore || lerpRating != prevRating) updateScoreDisplay();

		if (controls.BACK)
		{
			if (choosingSong)
			{
				exitSongChoose();
				return;
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new EXEMenu());
			FlxG.sound.music?.fadeOut(0.3);
			return;
		}

		if (changeCooldown <= 0 && !choosingSong)
		{
			var newSel = selectedBox;
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				newSel = selectedBox + (controls.UI_RIGHT_P ? 1 : -1);
				holdCheck = 0;
			}

			if (controls.UI_LEFT || controls.UI_RIGHT) holdCheck += elapsed;
			else holdCheck = 0;
			
			newSel = FlxMath.wrap(newSel, 0, songEntries.length - 1);

			if (newSel != selectedBox)
				changeSelection(newSel);
		}

		if (choosingSong)
		{
			if (controls.UI_DOWN_P) { chooseSong(1); holdCheck = 0; }
			if (controls.UI_UP_P) { chooseSong(-1); holdCheck = 0; }

			if (controls.ACCEPT)
				launchSong();

			if (controls.RESET)
			{
				final songs2 = getSongsForBox(selectedBox);
				if (songSelector < songs2.length)
				{
					final songKey = songs2[songSelector];
					openSubState(new ResetScoreSubState(songKey, curDifficulty, songKey));
				}
			}

			return;
		}

		if (controls.ACCEPT)
		{
			holdCheck = 0;
			final entry = songEntries[selectedBox];
			
			Mods.currentModDirectory = entry.folder;
			PlayState.storyWeek = entry.week;
			Difficulty.loadFromWeek();

			curDifficulty = getNormalDiffIdx();
			choosingSong = true;
			cancelAllTweens();

			freeBoxes.forEach((box:FlxSprite) -> {
				if (box.ID != selectedBox)
				{
					final offset:Float = -selectedBox * boxWidth;
					final baseX = centerX + (box.ID * boxWidth) + offset;
					box.scale.set(BOX_SCALE, BOX_SCALE);
					box.updateHitbox();
					box.x = baseX - box.width / 2;
					box.y = centerY - box.height / 2;
					box.alpha = 0.5;
					if (cardPositions != null && box.ID < cardPositions.length)
						cardPositions[box.ID].setPosition(box.x, box.y);
				}
			});

			covers.forEach((cover:FlxSprite) -> {
				if (cover.ID != selectedBox)
				{
					final offset:Float = -selectedBox * boxWidth;
					final baseX = centerX + (cover.ID * boxWidth) + offset;
					cover.scale.set(COVER_SCALE, COVER_SCALE);
					cover.updateHitbox();
					cover.x = baseX - cover.width / 2;
					cover.y = centerY - cover.height / 2;
					cover.alpha = 0.5;
					_applyCardPosition(cover.ID);
				}
			});

			scaleSongBox(true);
			chooseSong(0, false);
		}
	}

	function loadSongList(index:Int):Void
	{
		songSelector = 0;
		songScrollOffset = 0;

		final songs:Array<String> = getSongsForBox(index);
		activeSongCount = songs.length;

		for (spr in songTexts.members)
			if (spr != null) FlxTween.cancelTweensOf(spr);
			
		while (songTexts.length < songs.length)
		{
			final t = new FlxText(0, 0, FlxG.width, "", SONG_TITLE_SIZE);
			t.setFormat(FONT_PATH, SONG_TITLE_SIZE, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.antialiasing = false;
			t.borderSize = 2;
			songTexts.add(t);
		}

		final slot0Y:Float = FlxG.height - 18 - (MAX_VISIBLE_SONGS * SONG_SPACING_Y);
		
		for (i in 0...songs.length)
		{
			final spr = songTexts.members[i];
			spr.text = songs[i].toUpperCase();
			spr.color = FlxColor.WHITE;
			spr.ID = i;
			spr.y = slot0Y + (i * SONG_SPACING_Y);
			
			if (i < MAX_VISIBLE_SONGS)
			{
				spr.visible = true;
				spr.alpha = 0;
				spr.y = slot0Y + (i * SONG_SPACING_Y) + 14;
				FlxTween.tween(spr, {alpha: 1.0, y: slot0Y + (i * SONG_SPACING_Y)}, 0.2, {ease: FlxEase.sineOut, startDelay: i * 0.05});
			}
			else
			{
				spr.visible = false;
				spr.alpha = 0;
			}
		}

		for (i in songs.length...songTexts.length)
		{
			final extra = songTexts.members[i];
			if (extra != null) 
			{ 
				extra.visible = false;
				extra.alpha = 0; 
			}
		}
	}

	function getSongsForBox(index:Int):Array<String>
	{
		if (index < 0 || index >= songEntries.length) return [];
		return songEntries[index].songs.map(s -> s.songName);
	}

	function updateSelectedCover(daStatic:Bool = true):Void
	{
		if (selectedBox < 0 || selectedBox >= songEntries.length) return;

		final entry = songEntries[selectedBox];
		if (songSelector < 0 || songSelector >= entry.songs.length) return;

		final songName = entry.songs[songSelector].songName;
		final coverPath = PATH_COVERS + Paths.formatToSongPath(songName) + '.png';

		var bmp = loadRawBitmap(coverPath);
		bmp ??= loadRawBitmap('assets/exe/freeplayassets/placeholder.png');
		
		final cover = covers.members[selectedBox];
		final ss = staticScreens.members[selectedBox];
		
		if (cover != null && bmp != null)
		{
			cover.loadGraphic(bmp);
			cover.updateHitbox();
			cover.x = centerX - cover.width / 2;
			cover.y = centerY - cover.height / 2;

			if (ss != null)
			{
				ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
				ss.updateHitbox();
				ss.x = cover.x;
				ss.y = cover.y;

				if (choosingSong && daStatic)
				{
					staticTween?.cancel();
					ss.alpha = 1.0;
					staticTween = FlxTween.tween(ss, {alpha: 0.18}, 0.45, {ease: FlxEase.quadOut});
				}
			}
		}
	}

	function chooseSong(delta:Int, daStatic:Bool = true):Void
	{
		final songs = getSongsForBox(selectedBox);
		if (songs.length == 0) return;

		final newSel = songSelector + delta;
		if (newSel < 0 || newSel >= songs.length) return;
		
		songSelector = newSel;
		
		if (daStatic) 
		{
			final staticSound = FlxG.sound.play(Paths.sound('static'), 0.15);
			staticSound?.fadeOut(0.3, 0);
		}

		if (songSelector < songScrollOffset)
			songScrollOffset = songSelector;
		else if (songSelector >= songScrollOffset + MAX_VISIBLE_SONGS)
			songScrollOffset = songSelector - MAX_VISIBLE_SONGS + 1;

		final slot0Y:Float = FlxG.height - 18 - (MAX_VISIBLE_SONGS * SONG_SPACING_Y);

		for (j in 0...activeSongCount)
		{
			final spr = songTexts.members[j];
			if (spr == null) continue;
			
			FlxTween.cancelTweensOf(spr);

			final inWindow = (spr.ID >= songScrollOffset && spr.ID < songScrollOffset + MAX_VISIBLE_SONGS);
			final slot = spr.ID - songScrollOffset;
			final targetY = slot0Y + (slot * SONG_SPACING_Y);
			final isSelected = (spr.ID == songSelector);

			spr.color = isSelected ? FlxColor.YELLOW : FlxColor.WHITE;

			if (inWindow)
			{
				final wasOut = !spr.visible || spr.alpha < 0.1;
				spr.visible = true;

				if (wasOut)
				{
					spr.y = targetY + (delta > 0 ? 18 : -18);
					spr.alpha = 0;
				}
				FlxTween.tween(spr, {alpha: 1.0, y: targetY}, 0.18, {ease: FlxEase.sineOut});
			}
			else
			{
				FlxTween.tween(spr, {alpha: 0.0, y: spr.y + (delta > 0 ? -4 : 4)}, 0.12, {
					ease: FlxEase.sineIn,
					onComplete: (_) -> spr.visible = false
				});
			}
		}

		if (songSelector < songs.length)
		{
			final entry = songEntries[selectedBox];
			Mods.currentModDirectory = entry.folder;
			intendedScore = Highscore.getScore(songs[songSelector], curDifficulty);
			intendedRating = Highscore.getRating(songs[songSelector], curDifficulty);
		}

		updateSelectedCover(daStatic);
	}

	function exitSongChoose():Void
	{
		if (songSelector != 0) 
		{
			final staticSound = FlxG.sound.play(Paths.sound('static'), 0.15);
			staticSound?.fadeOut(0.3, 0);
		}
		
		choosingSong = false;

		for (j in 0...activeSongCount)
		{
			final spr = songTexts.members[j];
			if (spr == null) continue;
			spr.color = FlxColor.WHITE;
			spr.alpha = 1;
		}

		final oldSelector:Int = songSelector;
		songSelector = 0;
		final entry = songEntries[selectedBox];
		
		if (entry != null && entry.songs.length > 0)
		{
			final firstSong = entry.songs[0].songName;
			var bmp = loadRawBitmap(PATH_COVERS + Paths.formatToSongPath(firstSong) + '.png');
			bmp ??= loadRawBitmap('assets/exe/freeplayassets/placeholder.png');
			
			final cover = covers.members[selectedBox];
			final ss = staticScreens.members[selectedBox];
			
			if (cover != null && bmp != null)
			{
				cover.loadGraphic(bmp);
				cover.updateHitbox();
				cover.x = centerX - cover.width / 2;
				cover.y = centerY - cover.height / 2;
				
				if (ss != null)
				{
					ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
					ss.updateHitbox();
					ss.x = cover.x;
					ss.y = cover.y;
					
					if (oldSelector != 0) 
					{
						staticTween?.cancel();
						ss.alpha = 1.0;
						staticTween = FlxTween.tween(ss, {alpha: 0.18}, 0.45, {ease: FlxEase.quadOut});
					}
				}
			}
		}

		scaleSongBox(false);
	}

	function launchSong():Void
	{
		final songs = getSongsForBox(selectedBox);
		if (songs.length == 0 || songSelector >= songs.length) return;
		
		final entry = songEntries[selectedBox];
		final songLower = Paths.formatToSongPath(songs[songSelector]);

		Mods.currentModDirectory = entry.folder;
		PlayState.storyWeek = entry.week;
		Difficulty.loadFromWeek();
		final launchDiff = getNormalDiffIdx();

		final poop:String = Highscore.formatSong(songLower, launchDiff);
		
		try
		{
			Mods.currentModDirectory = entry.folder;
			Song.loadFromJson(poop, songLower);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = launchDiff;
			PlayState.storyWeek = entry.week;
		}
		catch (e:haxe.Exception)
		{
			var errorStr = e.message;
			if (errorStr.contains('There is no TEXT asset with an ID of'))
				errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLower), errorStr.length - 1);
			else 
				errorStr += '\n\n' + e.stack;

			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.screenCenter(Y);
			missingText.visible = true;
			missingTextBG.visible = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		@:privateAccess
		if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			Paths.freeGraphicsFromMemory();

		if (songEntries[selectedBox].songs[0].transitionShape != null) 
			CustomShapeTransition.shape = CustomShapeTransition.getShapeByString(songEntries[selectedBox].songs[0].transitionShape);

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
		FlxG.sound.music?.fadeOut(0.3);
		stopMusicPlay = true;

		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	function changeSelection(newIndex:Int):Void
	{
		songSelector = 0;
		updateSelectedCover();

		selectedBox = newIndex;
		changeCooldown = CHANGE_COOLDOWN;

		final newColorArray = songEntries[selectedBox].songs[0].bgColor;
		final newColor:Int = FlxColor.fromRGB(newColorArray[0], newColorArray[1], newColorArray[2]);
		
		if (newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bgSonic);
			FlxTween.color(bgSonic, 1, bgSonic.color, intendedColor);
			if (verticalLine != null)
			{
				FlxTween.cancelTweensOf(verticalLine);
				FlxTween.color(verticalLine, 1, verticalLine.color, intendedColor);
			}
		}

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		cancelAllTweens();
		loadCharText(selectedBox);
		loadSongList(selectedBox);
		updateSelection(true);

		final songs = getSongsForBox(selectedBox);
		if (songs.length > 0)
		{
			final entry = songEntries[selectedBox];
			Mods.currentModDirectory = entry.folder;
			PlayState.storyWeek = entry.week;
			Difficulty.loadFromWeek();
			curDifficulty = getNormalDiffIdx();
			changeDiff(0);
		}
	}

	function changeDiff(delta:Int = 0):Void
	{
		if (Difficulty.list.length == 0) return;
		
		curDifficulty = FlxMath.wrap(curDifficulty + delta, 0, Difficulty.list.length - 1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);

		final songs = getSongsForBox(selectedBox);
		if (songs.length > 0)
		{
			final sel = choosingSong ? songSelector : 0;
			if (sel < songs.length)
			{
				intendedScore = Highscore.getScore(songs[sel], curDifficulty);
				intendedRating = Highscore.getRating(songs[sel], curDifficulty);
			}
		}
		positionHighscore();
	}

	function loadCharText(index:Int):Void
	{
		final title = (index >= 0 && index < songEntries.length && songEntries[index].songs.length > 0)
			? songEntries[index].songs[0].title : "???";

		charText.text = title;
		FlxTween.cancelTweensOf(charText);
		charText.alpha = 0;
		charText.y = 5;
		FlxTween.tween(charText, {y: 18, alpha: 1}, 0.4, {ease: FlxEase.circOut});
	}

	static function getRankLetter(rating:Float):String
	{
		if (rating >= 1) return 'P';
		if (rating >= 0.96) return 'SS';
		if (rating >= 0.93) return 'S';
		if (rating >= 0.85) return 'AA';
		if (rating >= 0.75) return 'A';
		if (rating >= 0.6) return 'B';
		if (rating >= 0.45) return 'C';
		if (rating >= 0.2) return 'D';
		if (rating > 0.0) return 'F';
		return '?';
	}

	function updateScoreDisplay():Void
	{
		if (scoreText == null) return;
		scoreText.text = Language.get('freeplay.score', 'SCORE') + ': ${lerpScore}';
		if (rankText != null)
			rankText.text = Language.get('freeplay.rank', 'RANK') + ': ' + getRankLetter(lerpRating);
			
		positionHighscore();
	}

	function positionHighscore():Void
	{
		if (scoreText == null || scoreBG == null || rankText == null) return;

		scoreText.x = FlxG.width - scoreText.width - 6;
		rankText.x = FlxG.width - rankText.width - 6;
		rankText.y = FlxG.height - rankText.height - 8;
		scoreText.y = rankText.y - scoreText.height - 4;
		
		final bgWidth = FlxG.width - Math.min(scoreText.x, rankText.x) + 6;
		scoreBG.scale.x = bgWidth;
		scoreBG.x = FlxG.width - bgWidth / 2;
		scoreBG.y = scoreText.y - 4;
	}

	function scaleSongBox(enlarge:Bool):Void
	{
		final targetBoxScale = enlarge ? BOX_SCALE_SONG : BOX_SCALE_SELECTED;
		final targetCoverScale = enlarge ? COVER_SCALE_SONG : COVER_SCALE_SELECTED;
		
		freeBoxes.forEach((box:FlxSprite) -> {
			FlxTween.cancelTweensOf(box); 
			FlxTween.cancelTweensOf(box.scale);
			
			if (box.ID == selectedBox)
			{
				final idx = box.ID;
				FlxTween.tween(box.scale, {x: targetBoxScale, y: targetBoxScale}, TWEEN_DURATION, {
					ease: FlxEase.backOut,
					onUpdate: (_) -> {
						box.updateHitbox();
						box.x = centerX - box.width / 2;
						box.y = centerY - box.height / 2;
						if (cardPositions != null && idx < cardPositions.length)
							cardPositions[idx].setPosition(box.x, box.y);
					}
				});
				FlxTween.tween(box, {alpha: 1.0}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
			else
			{
				FlxTween.tween(box, {alpha: 0.5}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
		});

		covers.forEach((cover:FlxSprite) -> {
			FlxTween.cancelTweensOf(cover); 
			FlxTween.cancelTweensOf(cover.scale);
			
			if (cover.ID == selectedBox)
			{
				final ss = staticScreens.members[cover.ID];
				FlxTween.tween(cover.scale, {x: targetCoverScale, y: targetCoverScale}, TWEEN_DURATION, {
					ease: FlxEase.backOut,
					onUpdate: (_) -> {
						cover.updateHitbox();
						cover.x = centerX - cover.width / 2;
						cover.y = centerY - cover.height / 2;
						if (ss != null)
						{
							ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
							ss.updateHitbox();
							ss.x = cover.x;
							ss.y = cover.y;
						}
					}
				});
				FlxTween.tween(cover, {alpha: 1.0}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
			else
			{
				FlxTween.tween(cover, {alpha: 0.5}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
		});
	}

	function updateSelection(animate:Bool = true):Void
	{
		final offset:Float = -selectedBox * boxWidth;

		for (i in 0...songEntries.length)
		{
			final isSelected = (i == selectedBox);
			final proxy = cardPositions[i];
			final box = freeBoxes.members[i];
			final cover = covers.members[i];
			final ss = staticScreens.members[i];

			final targetAlpha:Float = isSelected ? 1.0 : 0.5;
			final targetBoxScale = isSelected ? BOX_SCALE_SELECTED : BOX_SCALE;
			final targetCoverScale = isSelected ? COVER_SCALE_SELECTED : COVER_SCALE;
			final baseX = centerX + (i * boxWidth) + offset;

			if (box != null) { 
				box.scale.set(targetBoxScale, targetBoxScale); 
				box.updateHitbox(); 
			}
			if (cover != null) { 
				cover.scale.set(targetCoverScale, targetCoverScale); 
				cover.updateHitbox();
			}

			final targetX = baseX - (box != null ? box.width : 0) / 2;
			final targetY = centerY - (box != null ? box.height : 0) / 2;

			if (animate)
			{
				FlxTween.cancelTweensOf(proxy);
				final fi = i;
				FlxTween.tween(proxy, {x: targetX, y: targetY}, TWEEN_DURATION, {
					ease: FlxEase.cubeOut,
					onUpdate: (_) -> _applyCardPosition(fi)
				});
				
				if (box != null) FlxTween.tween(box, {alpha: targetAlpha}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
				if (cover != null) FlxTween.tween(cover, {alpha: targetAlpha}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
			else
			{
				proxy.setPosition(targetX, targetY);
				_applyCardPosition(i);
				if (box != null) box.alpha = targetAlpha;
				if (cover != null) cover.alpha = targetAlpha;
			}
		}

		exeTexts.forEach((text:FlxText) -> {
			FlxTween.cancelTweensOf(text);
			text.y = FlxG.height - text.height - 30;
			
			if (text.ID == selectedBox)
			{
				text.visible = true;
				if (animate)
					FlxTween.tween(text, {alpha: 1.0}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
				else
					text.alpha = 1.0;
			}
			else
			{
				text.visible = false;
				text.alpha = 0.0;
			}
		});
	}

	inline function _applyCardPosition(i:Int):Void
	{
		final proxy = cardPositions[i];
		final box = freeBoxes.members[i];
		final cover = covers.members[i];
		final ss = staticScreens.members[i];
		
		if (box != null)
		{
			box.x = proxy.x;
			box.y = proxy.y;
		}
		
		if (cover != null)
		{
			final offsetX = box != null ? (box.width - cover.width) / 2 : 0;
			final offsetY = box != null ? (box.height - cover.height) / 2 : 0;
			cover.x = proxy.x + offsetX;
			cover.y = proxy.y + offsetY;
			
			if (ss != null) 
			{ 
				ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height)); 
				ss.updateHitbox(); 
				ss.x = cover.x; 
				ss.y = cover.y;
			}
		}
	}

	override function stepHit():Void
	{
		super.stepHit();
		if (curStep % 2 == 0 && holdCheck > ((Conductor.bpm / 60) / 4)) 
			changeSelection(FlxMath.wrap(selectedBox + (controls.UI_RIGHT ? 1 : -1), 0, songEntries.length - 1));
	}

	function loadBgChecker():Void
	{
		final tileSize:Int = 40;
		final bmp = new openfl.display.BitmapData(tileSize * 2, tileSize * 2, false, 0xFF000000);
		bmp.fillRect(new openfl.geom.Rectangle(0, 0, tileSize, tileSize), 0xFF888888);
		bmp.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0xFF888888);
		
		bgChecker = new FlxBackdrop(bmp, FlxAxes.XY);
		bgChecker.antialiasing = false;
		bgChecker.velocity.y = 60;
		bgChecker.alpha = 0.10;
		add(bgChecker);
	}

	function loadBgSonic():Void
	{
		final bmp = loadRawBitmap('assets/exe/freeplayassets/bgsonic.png');
		if (bmp == null) return;
		
		bgSonic = new FlxBackdrop(bmp, FlxAxes.X);
		bgSonic.antialiasing = false;
		bgSonic.velocity.x = 80;
		add(bgSonic);
	}

	function loadVerticalLine():Void
	{
		final lh = 20;
		final lw = Std.int(FlxG.width * 2);
		
		verticalLine = new FlxSprite(0, FlxG.height / 2 - lh / 2);
		verticalLine.makeGraphic(lw, lh, 0xFF000000);
		
		final px = verticalLine.pixels;
		px.lock();
		for (y in 0...lh) {
			final t = y / (lh - 1);
			final v = Std.int(0x4B * (1 - t) + 0x1A * t);
			final c:Int = (0xFF << 24) | (v << 16) | (v << 8) | v;
			for (x in 0...lw) px.setPixel32(x, y, c);
		}
		px.unlock();
		verticalLine.dirty = true;
		
		add(verticalLine);
	}

	function loadVignette():Void
	{
		final vigWLeft:Int = 420;
		final vigWRight:Int = 420;
		final vigH:Int = 200;
		
		final left = FlxGradient.createGradientFlxSprite(vigWLeft, FlxG.height, [0x55000000, 0x00000000], 1, 0);
		left.x = -vigWLeft / 2;
		left.scrollFactor.set(0, 0);
		add(left);
		
		final right = FlxGradient.createGradientFlxSprite(vigWRight, FlxG.height, [0x00000000, 0x55000000], 1, 0);
		right.x = FlxG.width - vigWRight / 2;
		right.scrollFactor.set(0, 0);
		add(right);
		
		final top = FlxGradient.createGradientFlxSprite(FlxG.width, vigH, [0x66000000, 0x00000000], 1, 90);
		top.scrollFactor.set(0, 0);
		add(top);
	}

	function loadDegradado():Void
	{
		final bmp = loadRawBitmap('assets/exe/freeplayassets/degradado.png');
		if (bmp == null) return;
		
		degradado = new FlxSprite(0, FlxG.height).loadGraphic(bmp);
		degradado.scale.set(0.5, 0.5);
		degradado.updateHitbox();
		degradado.y = FlxG.height - degradado.height + 30;
		
		add(degradado);
		FlxTween.tween(degradado, {y: degradado.y - 6}, 2.0, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	function loadSpikesUp():Void
	{
		final bmp = loadRawBitmap('assets/exe/freeplayassets/spikesup.png');
		if (bmp == null) return;
		
		spikesUp = new FlxBackdrop(bmp, FlxAxes.X);
		spikesUp.scale.set(0.5, 0.5);
		spikesUp.updateHitbox();
		spikesUp.y = -25;
		spikesUp.velocity.x = -80;
		
		add(spikesUp);
	}

	function updateWindowTitle():Void
	{
		if (FlxG.stage?.window != null)
			FlxG.stage.window.title = ARROW_ICONS[currentArrowIndex] + " FREEPLAY " + ARROW_ICONS[currentArrowIndex];
	}

	inline function getNormalDiffIdx():Int
	{
		final idx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		return idx > -1 ? idx : 0;
	}

	function weekIsLocked(name:String):Bool
	{
		final w:WeekData = WeekData.weeksLoaded.get(name);
		return !w.startUnlocked && w.weekBefore.length > 0
			&& (!StoryModeState.weekCompleted.exists(w.weekBefore) || !StoryModeState.weekCompleted.get(w.weekBefore));
	}

	function cancelAllTweens():Void
	{
		freeBoxes?.forEach((b) -> { FlxTween.cancelTweensOf(b); FlxTween.cancelTweensOf(b.scale); });
		covers?.forEach((c) -> { FlxTween.cancelTweensOf(c); FlxTween.cancelTweensOf(c.scale); });
		
		exeTexts?.forEach((t) -> {
			FlxTween.cancelTweensOf(t);
			if (t.ID == selectedBox) { 
				t.visible = true; 
				t.alpha = 1.0; 
			} else { 
				t.visible = false; 
				t.alpha = 0.0; 
			}
		});
		
		songTexts?.forEach((t) -> FlxTween.cancelTweensOf(t));
		
		if (charText != null) 
		{ 
			FlxTween.cancelTweensOf(charText); 
			charText.alpha = 1.0; 
			charText.y = 28;
		}
		
		if (cardPositions != null) 
			for (p in cardPositions) FlxTween.cancelTweensOf(p);
	}

	override function closeSubState():Void
	{
		super.closeSubState();
		if (choosingSong)
		{
			final songs2 = getSongsForBox(selectedBox);
			if (songSelector < songs2.length)
			{
				intendedScore = Highscore.getScore(songs2[songSelector], curDifficulty);
				intendedRating = Highscore.getRating(songs2[songSelector], curDifficulty);
			}
		}
	}

	override function destroy():Void
	{
		if (FlxG.stage?.window != null)
			FlxG.stage.window.title = previousWindowName;
			
		arrowTimer?.cancel();
		arrowTimer = null;
		
		staticTween?.cancel(); 
		staticTween = null;
		
		cancelAllTweens();
		
		bgChecker = null;
		bgSonic = null;
		spikesUp = null;
		verticalLine = null; 
		degradado = null;
		charText = null; 
		freeBoxes = null;
		covers = null;
		exeTexts = null; 
		songTexts = null;
		staticScreens = null;
		cardGroups = null; 
		cardGroupsLayer = null;
		cardPositions = null;
		scoreBG = null; 
		scoreText = null; 
		rankText = null;
		missingTextBG = null;
		missingText = null;

		if (!stopMusicPlay)
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
			
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		super.destroy();
	}
}

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var icon:objects.HealthIcon;
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	var song:String;
	var difficulty:Int;
	var week:Int;
	
	public function new(song:String, difficulty:Int, character:String, week:Int = -1)
	{
		this.song = song;
		this.difficulty = difficulty;
		this.week = week;

		super();
		
		var name:String = song;
		if (week > -1)
			name = backend.WeekData.weeksLoaded.get(backend.WeekData.weeksList[week]).weekName;
			
		name += ' (' + Difficulty.getString(difficulty) + ')?';
		
		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		
		final tooLong:Float = (name.length > 18) ? 0.8 : 1;
		
		final titleText = new Alphabet(0, 180, Language.get('freeplay.reset', 'RESET SCORE FOR {1}?').split('{1}')[0].trim(), true);
		titleText.screenCenter(X);
		alphabetArray.push(titleText);
		titleText.alpha = 0;
		add(titleText);
		
		final nameText = new Alphabet(0, titleText.y + 90, name, true);
		nameText.scaleX = tooLong;
		nameText.screenCenter(X);
		if (week == -1) nameText.x += 60 * tooLong;
		alphabetArray.push(nameText);
		nameText.alpha = 0;
		add(nameText);
		
		if (week == -1)
		{
			icon = new objects.HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(nameText.x - icon.width + (10 * tooLong), nameText.y - 30);
			icon.alpha = 0;
			add(icon);
		}

		yesText = new Alphabet(0, nameText.y + 150, Language.getPhrase('Yes', 'Yes'), true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		
		noText = new Alphabet(0, nameText.y + 150, Language.getPhrase('No', 'No'), true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		
		for (letter in yesText.letters) letter.color = FlxColor.RED;
		
		updateOptions();
	}

	override function update(elapsed:Float):Void
	{
		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6) bg.alpha = 0.6;

		for (spr in alphabetArray)
			spr.alpha += elapsed * 2.5;
			
		if (week == -1 && icon != null) icon.alpha += elapsed * 2.5;

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			onYes = !onYes;
			updateOptions();
		}
		
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		else if (controls.ACCEPT)
		{
			if (onYes)
			{
				if (week == -1)
					backend.Highscore.resetSong(song, difficulty);
				else
					backend.Highscore.resetWeek(backend.WeekData.weeksList[week], difficulty);
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		
		super.update(elapsed);
	}

	function updateOptions():Void
	{
		final scales:Array<Float> = [0.75, 1];
		final alphas:Array<Float> = [0.6, 1.25];
		final confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		
		if (week == -1 && icon != null) icon.animation.curAnim.curFrame = confirmInt;
	}
}