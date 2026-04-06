package states;

import backend.WeekData;
import backend.Song;
import backend.Highscore;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;

import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;

typedef ExeSongInfo = {
	var songName:String;
	var coverFile:String;
	var title:String;
	var exeLabel:String;
	var exeColor:Int;
	var transitionShape:String;
}

typedef ExeSongEntry = {
	var week:Int;
	var folder:String;
	var songs:Array<ExeSongInfo>;
}


class EXEFreeplay extends MusicBeatState
{
	static inline final BOX_SCALE:Float          = 0.52;
	static inline final BOX_SCALE_SELECTED:Float = 0.58;
	static inline final BOX_SCALE_SONG:Float     = 0.63;
	static inline final COVER_SCALE:Float          = 0.35;
	static inline final COVER_SCALE_SELECTED:Float = 0.39;
	static inline final COVER_SCALE_SONG:Float     = 0.421;
	static inline final BOX_SPACING_X:Float     = -75;
	static inline final CHANGE_COOLDOWN:Float   = 0;
	static inline final ARROW_UPDATE_INTERVAL:Float = 0.5;
	static inline final TWEEN_DURATION:Float    = 0.3;

	static inline final PATH_FREEBOX:String    = 'assets/exe/freeplayassets/boxes/FreeBox.png';
	static inline final PATH_COVERS:String     = 'assets/exe/freeplayassets/covers/';
	static inline final FONT_PATH:String       = 'assets/fonts/sonicfree.otf';

	static inline final TITLE_SIZE:Int    = 52;
	static inline final EXE_LABEL_SIZE:Int = 34;
	static inline final SONG_TITLE_SIZE:Int = 48;
	static inline final SONG_SPACING_Y:Float  = 65;
	static inline final MAX_VISIBLE_SONGS:Int = 2;

	var songEntries:Array<ExeSongEntry> = [];

	var bgSonic:FlxBackdrop;
	var verticalLine:FlxSprite;
	var degradado:FlxSprite;
	var spikesUp:FlxBackdrop;
	var freeBoxes:FlxTypedGroup<FlxSprite>;
	var covers:FlxTypedGroup<FlxSprite>;
	var exeTexts:FlxTypedGroup<FlxText>;

	var charText:FlxText;
	var songTexts:FlxTypedGroup<FlxText>;

	var staticScreens:FlxTypedGroup<FlxSprite>;
	var staticTween:FlxTween;

	var selectedBox:Int  = 0;
	var changeCooldown:Float = 0;
	var choosingSong:Bool = false;
	var songSelector:Int = 0;
	var songScrollOffset:Int = 0;
	var activeSongCount:Int = 0;

	var boxWidth:Float = 0;
	var centerX:Float = 0;
	var centerY:Float = 0;

	var activeTweens:Array<FlxTween> = [];
	var previousWindowName:String = "";

	var arrowIcons:Array<String> = ["^", "<", "v", ">"];
	var currentArrowIndex:Int = 0;
	var arrowTimer:FlxTimer;
	var transitionTimer:FlxTimer;

	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var rankText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var instPlaying:Int = -1;
	var stopMusicPlay:Bool = false;

	override function create()
	{
		if (FlxG.stage != null && FlxG.stage.window != null)
			previousWindowName = FlxG.stage.window.title;

		Paths.clearStoredMemory();

		PlayState.isStoryMode = false;
		Mods.loadTopMod();
		WeekData.reloadWeekFiles(false);

		buildSongList();

		if (songEntries.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			FlxG.switchState(() -> new Exemenu());
			return;
		}

		covers    = new FlxTypedGroup<FlxSprite>();
		freeBoxes = new FlxTypedGroup<FlxSprite>();
		exeTexts  = new FlxTypedGroup<FlxText>();
		songTexts = new FlxTypedGroup<FlxText>();

		charText = new FlxText(0, 15, FlxG.width, "", TITLE_SIZE);
		charText.setFormat(FONT_PATH, TITLE_SIZE, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charText.borderSize = 3;

		loadBgSonic();
		loadVerticalLine();

		staticScreens = new FlxTypedGroup<FlxSprite>();

		add(covers);
		add(staticScreens);
		add(freeBoxes);

		loadDegradado();
		loadSpikesUp();

		add(exeTexts);

		rankText  = new FlxText(0, 0, 0, "RANK: -",  44);
		rankText.setFormat(FONT_PATH, 44, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankText.borderSize = 3;
		rankText.y = FlxG.height - rankText.height - 10;

		scoreText = new FlxText(0, 0, 0, "SCORE: 0", 44);
		scoreText.setFormat(FONT_PATH, 44, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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
			PlayState.storyWeek      = songEntries[0].week;
			Difficulty.loadFromWeek();
		}

		var normalIdx:Int = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		curDifficulty = (normalIdx > -1) ? normalIdx : Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		if (Difficulty.list.length == 0) curDifficulty = 0;
		lastDifficultyName = Difficulty.list.length > 0 ? Difficulty.getString(curDifficulty, false) : '';

		updateSelection(false);
		loadCharText(selectedBox);
		loadSongList(selectedBox);
		changeDiff(0);
		updateScoreDisplay();

		persistentUpdate = true;
		persistentDraw  = true;

		updateWindowTitle();
		arrowTimer = new FlxTimer().start(ARROW_UPDATE_INTERVAL, function(_)
		{
			currentArrowIndex = (currentArrowIndex + 1) % arrowIcons.length;
			updateWindowTitle();
		}, 0);

		super.create();
		CustomShapeTransition.shape = HEAD;
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/freeplay.ogg'));
		Paths.clearUnusedMemory();
	}

	function buildSongList()
	{
		songEntries = [];

		for (i in 0...WeekData.weeksList.length)
		{
			if (i == 0) continue;
			var weekName:String = WeekData.weeksList[i];
			if (weekIsLocked(weekName)) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(weekName);
			WeekData.setDirectoryFromWeek(leWeek);

			var songInfoList:Array<ExeSongInfo> = [];

			var weekExeTitle:String = (leWeek.exeTitle != null && leWeek.exeTitle.length > 0) ? leWeek.exeTitle : null;
			var weekExeCover:String = (leWeek.exeCover != null && leWeek.exeCover.length > 0) ? leWeek.exeCover : 'placeholder';
			var weekExeLabel:String = (leWeek.exeLabel != null && leWeek.exeLabel.length > 0) ? leWeek.exeLabel : 'NON EXE';
			var weekTransition:String = (leWeek.transitionShape != null && leWeek.transitionShape.length > 0) ? leWeek.transitionShape : 'HEAD';
			var weekExeColor:Int = 0xFF8888FF;
			if (leWeek.exeColor != null && leWeek.exeColor.length > 0)
				weekExeColor = Std.parseInt(leWeek.exeColor);
			else
				weekExeColor = (weekExeLabel == 'EXE') ? 0xFFFF0000 : 0xFF8888FF;

			for (song in leWeek.songs)
			{
				var sName:String = song[0];
				var title:String = (weekExeTitle != null) ? weekExeTitle : sName.toUpperCase();

				songInfoList.push({
					songName:  sName,
					coverFile: weekExeCover,
					title:     title,
					exeLabel:  weekExeLabel,
					exeColor:  weekExeColor,
					transitionShape: weekTransition
				});
			}

			if (songInfoList.length == 0) continue;

			songEntries.push({
				week:   i,
				folder: Mods.currentModDirectory != null ? Mods.currentModDirectory : '',
				songs:  songInfoList
			});
		}
	}

	static function loadRawBitmap(path:String):BitmapData
	{
		try
		{
			#if sys
			if (sys.FileSystem.exists(path))
				return BitmapData.fromFile(path);
			#end
			if (openfl.utils.Assets.exists(path))
				return openfl.utils.Assets.getBitmapData(path);
		}
		catch (e:Dynamic) {}
		return null;
	}

	function createBoxesAndCovers()
	{
		var boxBitmap = loadRawBitmap(PATH_FREEBOX);
		if (boxBitmap != null)
			boxWidth = (boxBitmap.width * BOX_SCALE) + BOX_SPACING_X;
		else
			boxWidth = 150;

		centerX = FlxG.width  / 2;
		centerY = FlxG.height / 2;

		for (i in 0...songEntries.length)
		{
			var entry    = songEntries[i];
			var firstSong = entry.songs[0];

			var coverPath   = PATH_COVERS + Paths.formatToSongPath(firstSong.songName) + '.png';
			var coverBitmap = loadRawBitmap(coverPath);
			if (coverBitmap == null)
				coverBitmap = loadRawBitmap(PATH_COVERS + 'placeholder.png');
			if (coverBitmap == null)
				coverBitmap = loadRawBitmap('assets/exe/freeplayassets/placeholder.png');

			if (coverBitmap != null)
			{
				var cover = new FlxSprite(0, 0);
				cover.loadGraphic(coverBitmap);
				cover.antialiasing = ClientPrefs.data.antialiasing;
				cover.scale.set(COVER_SCALE, COVER_SCALE);
				cover.updateHitbox();
				cover.ID = i;
				covers.add(cover);

				var ss = new FlxSprite(0, 0);
				ss.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.png', 'assets/exe/story/screenstatic.xml');
				ss.animation.addByPrefix('play', 'screenSTATIC', 24);
				ss.animation.play('play');
				ss.antialiasing = ClientPrefs.data.antialiasing;
				ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
				ss.updateHitbox();
				ss.x    = cover.x;
				ss.y    = cover.y;
				ss.alpha = 0.18;
				ss.ID   = i;
				staticScreens.add(ss);
			}

			if (boxBitmap != null)
			{
				var box = new FlxSprite(0, 0);
				box.loadGraphic(boxBitmap);
				box.antialiasing = ClientPrefs.data.antialiasing;
				box.scale.set(BOX_SCALE, BOX_SCALE);
				box.updateHitbox();
				box.ID = i;
				freeBoxes.add(box);
			}

			var exeText = new FlxText(30, 0, 0, firstSong.exeLabel, EXE_LABEL_SIZE);
			exeText.setFormat(FONT_PATH, EXE_LABEL_SIZE, firstSong.exeColor, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			exeText.borderSize = 2;
			exeText.ID         = i;
			exeText.visible    = (i == selectedBox);
			exeText.alpha      = exeText.visible ? 1.0 : 0.0;
			exeTexts.add(exeText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (changeCooldown > 0) changeCooldown -= elapsed;

		if (subState != null) return;

		lerpScore  = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;
		updateScoreDisplay();

		if (Controls.instance.BACK)
		{
			if (choosingSong)
			{
				exitSongChoose();
				return;
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new Exemenu());
			return;
		}

		if (changeCooldown <= 0 && !choosingSong)
		{
			var newSel = selectedBox;
			if (Controls.instance.UI_RIGHT_P)
				newSel = selectedBox + 1;
			else if (Controls.instance.UI_LEFT_P)
				newSel = selectedBox - 1;

			newSel = FlxMath.wrap(newSel, 0, songEntries.length - 1);

			if (newSel != selectedBox)
				changeSelection(newSel);
		}

		if (choosingSong)
		{
			if (Controls.instance.UI_DOWN_P) chooseSong(1);
			if (Controls.instance.UI_UP_P)   chooseSong(-1);

			if (Controls.instance.ACCEPT)
				launchSong();

			if (Controls.instance.RESET)
			{
				var songs2 = getSongsForBox(selectedBox);
				if (songSelector < songs2.length)
				{
					var songKey = songs2[songSelector];
					openSubState(new ResetScoreSubState(songKey, curDifficulty, songKey));
				}
			}

			return;
		}

		if (Controls.instance.ACCEPT)
		{
			var entry = songEntries[selectedBox];
			Mods.currentModDirectory = entry.folder;
			PlayState.storyWeek      = entry.week;
			Difficulty.loadFromWeek();

			var normalIdx3 = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
			curDifficulty = (normalIdx3 > -1) ? normalIdx3 : 0;

			choosingSong    = true;
			cancelAllTweens();

			freeBoxes.forEach(function(box:FlxSprite)
			{
				if (box.ID != selectedBox)
				{
					final offset:Float = -selectedBox * boxWidth;
					final baseX = centerX + (box.ID * boxWidth) + offset;
					box.scale.set(BOX_SCALE, BOX_SCALE);
					box.updateHitbox();
					box.x     = baseX - box.width / 2;
					box.y     = centerY - box.height / 2;
					box.alpha = 0.5;
				}
			});
			covers.forEach(function(cover:FlxSprite)
			{
				if (cover.ID != selectedBox)
				{
					final offset:Float = -selectedBox * boxWidth;
					final baseX = centerX + (cover.ID * boxWidth) + offset;
					cover.scale.set(COVER_SCALE, COVER_SCALE);
					cover.updateHitbox();
					cover.x     = baseX - cover.width / 2;
					cover.y     = centerY - cover.height / 2;
					cover.alpha = 0.5;
				}
			});
			scaleSongBox(true);
			chooseSong(0);
		}
	}

	function loadSongList(index:Int)
	{
		songSelector     = 0;
		songScrollOffset = 0;

		var songs:Array<String> = getSongsForBox(index);
		activeSongCount = songs.length;

		for (spr in songTexts.members)
			if (spr != null) FlxTween.cancelTweensOf(spr);

		while (songTexts.length < songs.length)
		{
			var t = new FlxText(0, 0, FlxG.width, "", SONG_TITLE_SIZE);
			t.setFormat(FONT_PATH, SONG_TITLE_SIZE, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.borderSize = 2;
			songTexts.add(t);
		}

		var slot0Y:Float = FlxG.height - 30 - (MAX_VISIBLE_SONGS * SONG_SPACING_Y);

		for (i in 0...songs.length)
		{
			var spr = songTexts.members[i];
			spr.text    = songs[i].toUpperCase();
			spr.color   = (i == 0) ? FlxColor.YELLOW : FlxColor.WHITE;
			spr.ID      = i;
			spr.y       = slot0Y + (i * SONG_SPACING_Y);

			if (i < MAX_VISIBLE_SONGS)
			{
				spr.visible = true;
				spr.alpha   = 0;
				spr.y       = slot0Y + (i * SONG_SPACING_Y) + 14;
				FlxTween.tween(spr, {alpha: 1.0, y: slot0Y + (i * SONG_SPACING_Y)}, 0.2, {ease: FlxEase.sineOut, startDelay: i * 0.05});
			}
			else
			{
				spr.visible = false;
				spr.alpha   = 0;
			}
		}

		for (i in songs.length...songTexts.length)
		{
			var extra = songTexts.members[i];
			if (extra != null) { extra.visible = false; extra.alpha = 0; }
		}
	}

	function getSongsForBox(index:Int):Array<String>
	{
		if (index < 0 || index >= songEntries.length) return [];
		return songEntries[index].songs.map(s -> s.songName);
	}

	function updateSelectedCover()
	{
		if (selectedBox < 0 || selectedBox >= songEntries.length) return;

		var entry = songEntries[selectedBox];
		if (songSelector < 0 || songSelector >= entry.songs.length) return;

		var songName = entry.songs[songSelector].songName;
		var coverPath = PATH_COVERS + Paths.formatToSongPath(songName) + '.png';

		var bmp = loadRawBitmap(coverPath);
		if (bmp == null)
			bmp = loadRawBitmap('assets/exe/freeplayassets/placeholder.png');

		var cover = covers.members[selectedBox];
		var ss    = staticScreens.members[selectedBox];
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

				if (choosingSong)
				{
					if (staticTween != null) staticTween.cancel();
					ss.alpha = 1.0;
					staticTween = FlxTween.tween(ss, {alpha: 0.18}, 0.45, {ease: FlxEase.quadOut});
				}
			}
		}
	}

	function chooseSong(delta:Int)
	{
		var songs = getSongsForBox(selectedBox);
		if (songs.length == 0) return;

		var newSel = songSelector + delta;
		if (newSel < 0 || newSel >= songs.length) return;
		songSelector = newSel;

		if (songSelector < songScrollOffset)
			songScrollOffset = songSelector;
		else if (songSelector >= songScrollOffset + MAX_VISIBLE_SONGS)
			songScrollOffset = songSelector - MAX_VISIBLE_SONGS + 1;

		var slot0Y:Float = FlxG.height - 30 - (MAX_VISIBLE_SONGS * SONG_SPACING_Y);
		var prevOffset = songScrollOffset; // saved before update above

		for (j in 0...activeSongCount)
		{
			var spr = songTexts.members[j];
			if (spr == null) continue;
			FlxTween.cancelTweensOf(spr);

			var inWindow   = (spr.ID >= songScrollOffset && spr.ID < songScrollOffset + MAX_VISIBLE_SONGS);
			var slot       = spr.ID - songScrollOffset;
			var targetY    = slot0Y + (slot * SONG_SPACING_Y);
			var isSelected = (spr.ID == songSelector);

			spr.color = isSelected ? FlxColor.YELLOW : FlxColor.WHITE;

			if (inWindow)
			{
				var wasOut = !spr.visible || spr.alpha < 0.1;
				spr.visible = true;
				if (wasOut)
				{
					spr.y    = targetY + (delta > 0 ? 18 : -18);
					spr.alpha = 0;
				}
				FlxTween.tween(spr, {alpha: 1.0, y: targetY}, 0.18, {ease: FlxEase.sineOut});
			}
			else
			{
				FlxTween.tween(spr, {alpha: 0.0, y: spr.y + (delta > 0 ? -4 : 4)}, 0.12, {
					ease: FlxEase.sineIn,
					onComplete: function(_) spr.visible = false
				});
			}
		}

		var songs2 = getSongsForBox(selectedBox);
		if (songSelector < songs2.length)
		{
			var entry = songEntries[selectedBox];
			Mods.currentModDirectory = entry.folder;
			intendedScore  = Highscore.getScore(songs2[songSelector], curDifficulty);
			intendedRating = Highscore.getRating(songs2[songSelector], curDifficulty);
		}

		updateSelectedCover();
	}

	function exitSongChoose()
	{
		choosingSong = false;
		for (j in 0...activeSongCount)
		{
			var spr = songTexts.members[j];
			if (spr == null) continue;
			spr.color = FlxColor.WHITE;
			spr.alpha = 1;
		}

		songSelector = 0;
		var entry = songEntries[selectedBox];
		if (entry != null && entry.songs.length > 0)
		{
			var firstSong = entry.songs[0].songName;
			var bmp = loadRawBitmap(PATH_COVERS + Paths.formatToSongPath(firstSong) + '.png');
			if (bmp == null) bmp = loadRawBitmap('assets/exe/freeplayassets/placeholder.png');
			var cover = covers.members[selectedBox];
			var ss    = staticScreens.members[selectedBox];
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
					if (staticTween != null) staticTween.cancel();
					ss.alpha = 1.0;
					staticTween = FlxTween.tween(ss, {alpha: 0.18}, 0.45, {ease: FlxEase.quadOut});
				}
			}
		}

		scaleSongBox(false);
	}

	function launchSong()
	{
		var songs = getSongsForBox(selectedBox);
		if (songs.length == 0 || songSelector >= songs.length) return;

		var entry    = songEntries[selectedBox];
		var songLower = Paths.formatToSongPath(songs[songSelector]);

		Mods.currentModDirectory = entry.folder;
		PlayState.storyWeek      = entry.week;
		Difficulty.loadFromWeek();
		var normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		var launchDiff = (normalIdx > -1) ? normalIdx : 0;

		var poop:String = Highscore.formatSong(songLower, launchDiff);

		try
		{
			Mods.currentModDirectory  = entry.folder;
			Song.loadFromJson(poop, songLower);
			PlayState.isStoryMode     = false;
			PlayState.storyDifficulty = launchDiff;
			PlayState.storyWeek       = entry.week;
		}
		catch (e:haxe.Exception)
		{
			var errorStr = e.message;
			if (errorStr.contains('There is no TEXT asset with an ID of'))
				errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLower), errorStr.length - 1);
			else errorStr += '\n\n' + e.stack;

			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.screenCenter(Y);
			missingText.visible    = true;
			missingTextBG.visible  = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		@:privateAccess
		if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			Paths.freeGraphicsFromMemory();

		if (songEntries[selectedBox].songs[0].transitionShape != null) CustomShapeTransition.shape = CustomShapeTransition.getShapeByString(songEntries[selectedBox].songs[0].transitionShape);

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
		stopMusicPlay = true;
		destroyFreeplayVocals();

		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	function changeSelection(newIndex:Int)
	{
		songSelector = 0;
		updateSelectedCover();

		selectedBox    = newIndex;
		changeCooldown = CHANGE_COOLDOWN;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		cancelAllTweens();
		loadCharText(selectedBox);
		loadSongList(selectedBox);
		updateSelection(true);

		var songs = getSongsForBox(selectedBox);
		if (songs.length > 0)
		{
			var entry = songEntries[selectedBox];
			Mods.currentModDirectory = entry.folder;
			PlayState.storyWeek      = entry.week;
			Difficulty.loadFromWeek();

			var normalIdx2 = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
			curDifficulty = (normalIdx2 > -1) ? normalIdx2 : 0;
			changeDiff(0);
		}
	}

	function changeDiff(delta:Int = 0)
	{
		if (Difficulty.list.length == 0) return;
		curDifficulty = FlxMath.wrap(curDifficulty + delta, 0, Difficulty.list.length - 1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);

		var songs = getSongsForBox(selectedBox);
		if (songs.length > 0)
		{
			var sel = choosingSong ? songSelector : 0;
			if (sel < songs.length)
			{
				intendedScore  = Highscore.getScore(songs[sel], curDifficulty);
				intendedRating = Highscore.getRating(songs[sel], curDifficulty);
			}
		}
		positionHighscore();
	}

	function loadCharText(index:Int)
	{
		var title = (index >= 0 && index < songEntries.length && songEntries[index].songs.length > 0)
			? songEntries[index].songs[0].title : "???";
		charText.text = title;
		FlxTween.cancelTweensOf(charText);
		charText.alpha = 0;
		charText.y    = 15;
		FlxTween.tween(charText, {y: 28, alpha: 1}, 0.4, {ease: FlxEase.circOut});
	}

	static function getRankLetter(rating:Float):String
	{
		if (rating >= 1.0)  return 'P';
		if (rating >= 0.96) return 'SS';
		if (rating >= 0.93) return 'S';
		if (rating >= 0.85) return 'AA';
		if (rating >= 0.75) return 'A';
		if (rating >= 0.60) return 'B';
		if (rating >= 0.45) return 'C';
		if (rating >= 0.20) return 'D';
		if (rating < 0.20) return 'F';
		return '?';
	}

	function updateScoreDisplay()
	{
		if (scoreText == null) return;
		scoreText.text = 'SCORE: ${lerpScore}';
		if (rankText != null)
			rankText.text = 'RANK: ' + getRankLetter(lerpRating);
		positionHighscore();
	}

	function positionHighscore()
	{
		if (scoreText == null || scoreBG == null || rankText == null) return;
		scoreText.x = FlxG.width - scoreText.width - 6;
		rankText.x  = FlxG.width - rankText.width - 6;
		rankText.y  = FlxG.height - rankText.height - 8;
		scoreText.y = rankText.y - scoreText.height - 4;
		var bgWidth = FlxG.width - Math.min(scoreText.x, rankText.x) + 6;
		scoreBG.scale.x = bgWidth;
		scoreBG.x       = FlxG.width - bgWidth / 2;
		scoreBG.y       = scoreText.y - 4;
	}

	function scaleSongBox(enlarge:Bool)
	{
		final targetBoxScale   = enlarge ? BOX_SCALE_SONG   : BOX_SCALE_SELECTED;
		final targetCoverScale = enlarge ? COVER_SCALE_SONG : COVER_SCALE_SELECTED;

		freeBoxes.forEach(function(box:FlxSprite)
		{
			FlxTween.cancelTweensOf(box); FlxTween.cancelTweensOf(box.scale);
			if (box.ID == selectedBox)
			{
				FlxTween.tween(box.scale, {x: targetBoxScale, y: targetBoxScale}, TWEEN_DURATION,
				{
					ease: FlxEase.backOut,
					onUpdate: function(_)
					{
						box.updateHitbox();
						box.x = centerX - box.width / 2;
						box.y = centerY - box.height / 2;
					},
					onComplete: function(_)
					{
						box.scale.set(targetBoxScale, targetBoxScale);
						box.updateHitbox();
						box.x = centerX - box.width / 2;
						box.y = centerY - box.height / 2;
					}
				});
				FlxTween.tween(box, {alpha: 1.0}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
			else
			{
				FlxTween.tween(box, {alpha: 0.5}, TWEEN_DURATION, {ease: FlxEase.cubeOut});
			}
		});

		covers.forEach(function(cover:FlxSprite)
		{
			FlxTween.cancelTweensOf(cover); FlxTween.cancelTweensOf(cover.scale);
			if (cover.ID == selectedBox)
			{
				var ss = staticScreens.members[cover.ID];
				FlxTween.tween(cover.scale, {x: targetCoverScale, y: targetCoverScale}, TWEEN_DURATION,
				{
					ease: FlxEase.backOut,
					onUpdate: function(_)
					{
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
					},
					onComplete: function(_)
					{
						cover.scale.set(targetCoverScale, targetCoverScale);
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

	function updateSelection(animate:Bool = true)
	{
		var offset:Float = -selectedBox * boxWidth;

		freeBoxes.forEach(function(box:FlxSprite)
		{
			final isSelected  = (box.ID == selectedBox);
			final targetScale = isSelected ? BOX_SCALE_SELECTED : BOX_SCALE;
			final targetAlpha = isSelected ? 1.0 : 0.5;
			final baseX       = centerX + (box.ID * boxWidth) + offset;
			box.scale.set(targetScale, targetScale);
			box.updateHitbox();
			final targetX = baseX - box.width / 2;
			final targetY = centerY - box.height / 2;
			if (animate)
				activeTweens.push(FlxTween.tween(box, {x: targetX, y: targetY, alpha: targetAlpha}, TWEEN_DURATION, {ease: FlxEase.cubeOut}));
			else { box.x = targetX; box.y = targetY; box.alpha = targetAlpha; }
		});

		covers.forEach(function(cover:FlxSprite)
		{
			final isSelected  = (cover.ID == selectedBox);
			final targetScale = isSelected ? COVER_SCALE_SELECTED : COVER_SCALE;
			final targetAlpha = isSelected ? 1.0 : 0.5;
			final baseX       = centerX + (cover.ID * boxWidth) + offset;
			cover.scale.set(targetScale, targetScale);
			cover.updateHitbox();
			final targetX = baseX - cover.width / 2;
			final targetY = centerY - cover.height / 2;
			if (animate)
				activeTweens.push(FlxTween.tween(cover, {x: targetX, y: targetY, alpha: targetAlpha}, TWEEN_DURATION, {ease: FlxEase.cubeOut}));
			else { cover.x = targetX; cover.y = targetY; cover.alpha = targetAlpha; }

			var ss = staticScreens.members[cover.ID];
			if (ss != null)
			{
				ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
				ss.updateHitbox();
				if (animate)
					activeTweens.push(FlxTween.tween(ss, {x: targetX, y: targetY}, TWEEN_DURATION, {ease: FlxEase.cubeOut}));
				else { ss.x = targetX; ss.y = targetY; }
			}
		});

		exeTexts.forEach(function(text:FlxText)
		{
			text.y = FlxG.height - text.height - 30;
			if (text.ID == selectedBox)
			{
				text.visible = true;
				if (animate)
					activeTweens.push(FlxTween.tween(text, {alpha: 1.0}, TWEEN_DURATION, {ease: FlxEase.cubeOut}));
				else
					text.alpha = 1.0;
			}
			else
			{
				text.visible = false;
				text.alpha   = 0.0;
			}
		});
	}

	function loadBgSonic()
	{
		var bmp = loadRawBitmap('assets/exe/freeplayassets/bgsonic.png');
		if (bmp == null) return;
		bgSonic = new FlxBackdrop(bmp, FlxAxes.X);
		bgSonic.antialiasing = false;
		bgSonic.velocity.x   = 80;
		add(bgSonic);
	}

	function loadVerticalLine()
	{
		var lh = 20;
		var lw = Std.int(FlxG.width * 2);
		verticalLine = new FlxSprite(0, FlxG.height / 2 - lh / 2);
		verticalLine.makeGraphic(lw, lh, 0xFF000000);
		var px = verticalLine.pixels;
		px.lock();
		for (y in 0...lh) {
			var t  = y / (lh - 1);
			var r  = Std.int(0x4B * (1 - t) + 0x1A * t);
			var c:Int = (0xFF << 24) | (r << 16);
			for (x in 0...lw) px.setPixel32(x, y, c);
		}
		px.unlock();
		verticalLine.dirty = true;
		add(verticalLine);
	}

	function loadDegradado()
	{
		var bmp = loadRawBitmap('assets/exe/freeplayassets/degradado.png');
		if (bmp == null) return;
		degradado = new FlxSprite(0, FlxG.height);
		degradado.loadGraphic(bmp);
		degradado.antialiasing = ClientPrefs.data.antialiasing;
		degradado.scale.set(0.5, 0.5);
		degradado.updateHitbox();
		degradado.y = FlxG.height - degradado.height + 30;
		add(degradado);
		FlxTween.tween(degradado, {y: degradado.y - 6}, 2.0, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	function loadSpikesUp()
	{
		var bmp = loadRawBitmap('assets/exe/freeplayassets/spikesup.png');
		if (bmp == null) return;
		spikesUp = new FlxBackdrop(bmp, FlxAxes.X);
		spikesUp.antialiasing = ClientPrefs.data.antialiasing;
		spikesUp.scale.set(0.5, 0.5);
		spikesUp.updateHitbox();
		spikesUp.y = -25;
		spikesUp.velocity.x = -80;
		add(spikesUp);
	}

	function updateWindowTitle()
	{
		if (FlxG.stage != null && FlxG.stage.window != null)
			FlxG.stage.window.title = arrowIcons[currentArrowIndex] + " FREEPLAY " + arrowIcons[currentArrowIndex];
	}

	function weekIsLocked(name:String):Bool
	{
		var w:WeekData = WeekData.weeksLoaded.get(name);
		return !w.startUnlocked && w.weekBefore.length > 0
			&& (!StoryModeState.weekCompleted.exists(w.weekBefore) || !StoryModeState.weekCompleted.get(w.weekBefore));
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);
		if (opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function cancelAllTweens()
	{
		if (freeBoxes  != null) freeBoxes.forEach(function(b) { FlxTween.cancelTweensOf(b); FlxTween.cancelTweensOf(b.scale); });
		if (covers     != null) covers.forEach(function(c)    { FlxTween.cancelTweensOf(c); FlxTween.cancelTweensOf(c.scale); });
		if (exeTexts   != null) exeTexts.forEach(function(t)  FlxTween.cancelTweensOf(t));
		if (songTexts  != null) songTexts.forEach(function(t) FlxTween.cancelTweensOf(t));
		if (charText   != null) FlxTween.cancelTweensOf(charText);
		if (activeTweens != null) activeTweens.resize(0);
	}

	override function closeSubState()
	{
		super.closeSubState();

		if (choosingSong)
		{
			var songs2 = getSongsForBox(selectedBox);
			if (songSelector < songs2.length)
			{
				intendedScore  = Highscore.getScore(songs2[songSelector], curDifficulty);
				intendedRating = Highscore.getRating(songs2[songSelector], curDifficulty);
			}
		}
	}

	override function destroy()
	{
		if (FlxG.stage != null && FlxG.stage.window != null)
			FlxG.stage.window.title = previousWindowName;
		if (arrowTimer      != null) { arrowTimer.cancel();      arrowTimer = null; }
		if (transitionTimer != null) { transitionTimer.cancel(); transitionTimer = null; }
		if (staticTween     != null) { staticTween.cancel();     staticTween = null; }
		cancelAllTweens();
		bgSonic = null; spikesUp = null;
		verticalLine = null; degradado = null;
		charText = null; freeBoxes = null; covers = null; exeTexts = null; songTexts = null;
		staticScreens = null;
		activeTweens = null;
		scoreBG = null; scoreText = null; rankText = null;
		missingTextBG = null; missingText = null;

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

		var tooLong:Float = (name.length > 18) ? 0.8 : 1;
		var text:Alphabet = new Alphabet(0, 180, Language.getPhrase('reset_score', 'Reset the score of'), true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);
		var text:Alphabet = new Alphabet(0, text.y + 90, name, true);
		text.scaleX = tooLong;
		text.screenCenter(X);
		if (week == -1) text.x += 60 * tooLong;
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);
		if (week == -1)
		{
			icon = new objects.HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(text.x - icon.width + (10 * tooLong), text.y - 30);
			icon.alpha = 0;
			add(icon);
		}

		yesText = new Alphabet(0, text.y + 150, Language.getPhrase('Yes'), true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text.y + 150, Language.getPhrase('No'), true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);

		for (letter in yesText.letters) letter.color = FlxColor.RED;
		updateOptions();
	}

	override function update(elapsed:Float)
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

	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		if (week == -1 && icon != null) icon.animation.curAnim.curFrame = confirmInt;
	}
}
