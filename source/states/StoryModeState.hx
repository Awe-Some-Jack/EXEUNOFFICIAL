package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import backend.Paths;
import backend.Song;
import backend.Highscore;
import backend.WeekData;
import backend.Difficulty;
import backend.Mods;
import states.LoadingState;
import states.PlayState;
import states.cutscenes.YourselfCutscene;

class StoryModeState extends MusicBeatState
{
	public static var instance:StoryModeState;
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var yourselfMode:Bool = false;
	

	static var allSongsDone:Bool;
	public static var lastPlayedCover:Int; 

	var _yourselfCutscene:YourselfCutscene;

	var toMenu:Bool = false;

	var greyBOX:FlxSprite;
	var bfBOX:FlxSprite;
	var staticscreen:FlxSprite;
	var arrow:FlxSprite;
	var arrow2:FlxSprite;
	var tooSlowCover:FlxSprite;
	var youCantRunCover:FlxSprite;
	var tripleTroubleCover:FlxSprite;
	var finalEscapeCover:FlxSprite;
	var yourselfCover:FlxSprite;

	var greyBOX2:FlxSprite;
	var gfBOX:FlxSprite;
	var padLock:FlxSprite;
	var yellowBOX2:FlxSprite;
	var staticscreen2:FlxSprite;

	var redBOX:FlxSprite;
	var microphone:FlxSprite;

	var selectedBox:Int = 0;
	var canInteract:Bool = true;
	var redBoxTween:FlxTween;
	var inCoverSelect:Bool = false;
	var selectedCover:Int = 0;
	var covers:Array<FlxSprite>;

	var box1BaseX:Float = 0;
	var box2BaseX:Float = 0;

	var shakeTimer:FlxTimer;
	var box2SpriteBaseXs:Array<Float> = [];
	var arrowTween:FlxTween;
	var arrow2Tween:FlxTween;
	var bfTween:FlxTween;
	var bf2Tween:FlxTween;
	var staticTween:FlxTween;
	var isShaking:Bool = false;
	var isSelecting:Bool = false;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var rankText:FlxText;
	var scoreVisible:Bool = false;

	public static var fromStoryMode:Bool = false;


	final yt = FlxG.save.data.theYourselfCutscene;
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		createAssets(yt);
		unlockCoverIndex(lastPlayedCover);
		
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/story.ogg'));

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Story Mode", null);
		#end

		super.create();
	}

	static function getUnlockedCovers(){
		return lastPlayedCover;
	}

	public function unlockCoverIndex(cover:Int){
		if (!allSongsDone)   lastPlayedCover = cover;
		if (lastPlayedCover >= 5) allSongsDone = true;
	}


	override function destroy()
	{
		instance = null;

		arrowTween?.cancel();
		arrow2Tween?.cancel();
		//if (bfTween     != null) bfTween.cancel();
		bf2Tween?.cancel();
		staticTween?.cancel();
		redBoxTween?.cancel();

		if (toMenu) FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		super.destroy();
	}

	function createAssets(yourselfTime:Bool) {
		final cloudSpeeds:Array<Float> = [120, 85, 58, 38, 24, 12];
		for (i in 0...6)
		{
			final bmp = Paths.getBitmapData('assets/exe/story/clouds/${i + 1}.webp');
			final cloud = new FlxBackdrop(bmp, FlxAxes.X);
			cloud.setGraphicSize(FlxG.width, FlxG.height);
			cloud.updateHitbox();
			cloud.velocity.x = -cloudSpeeds[i];
			add(cloud);
		}

		var smmStatic:FlxSprite = new FlxSprite(0, 0);
		smmStatic.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/SMMStatic.webp', 'assets/exe/story/SMMStatic.xml');
		smmStatic.animation.addByPrefix('static', 'static', 24);
		smmStatic.animation.play('static');
		smmStatic.setGraphicSize(FlxG.width, FlxG.height);
		smmStatic.updateHitbox();
		smmStatic.alpha = 0.4;
		add(smmStatic);

		var dataSelect:FlxSprite = new FlxSprite(0, 312);
		dataSelect.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/dataselect.webp', 'assets/exe/story/dataselect.xml');
		dataSelect.animation.addByPrefix('idle', 'dataselect dataselect', 6);
		dataSelect.animation.play('idle');
		dataSelect.setGraphicSize(FlxG.width * 0.885);
		dataSelect.updateHitbox();
		dataSelect.screenCenter(X);
		add(dataSelect);
		
		// ── BOX 1 ──
		final greyBoxBitmap = Paths.getBitmapData('assets/exe/story/greybox.webp');

		greyBOX = new FlxSprite();
		greyBOX.loadGraphic(greyBoxBitmap);
		greyBOX.setGraphicSize(Std.int(FlxG.width * 0.2635));
		greyBOX.updateHitbox();
		greyBOX.setPosition(175, 64);
		add(greyBOX);
		
		final tooSlowBitmap = Paths.getBitmapData('assets/exe/cover/too-slow.webp');

		tooSlowCover = new FlxSprite();
		tooSlowCover.loadGraphic(tooSlowBitmap);
		tooSlowCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		tooSlowCover.updateHitbox();
		tooSlowCover.visible = yt == true ? false : true;
		add(tooSlowCover);
		
		youCantRunCover = new FlxSprite();
		youCantRunCover.loadGraphic(Paths.getBitmapData('assets/exe/cover/you-cant-run.webp'));
		youCantRunCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		youCantRunCover.updateHitbox();
		youCantRunCover.visible = false;
		add(youCantRunCover);
		
		tripleTroubleCover = new FlxSprite();
		tripleTroubleCover.loadGraphic(Paths.getBitmapData('assets/exe/cover/triple-trouble.webp'));
		tripleTroubleCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		tripleTroubleCover.updateHitbox();
		tripleTroubleCover.visible = false;
		add(tripleTroubleCover);
		
		finalEscapeCover = new FlxSprite();
		finalEscapeCover.loadGraphic(Paths.getBitmapData('assets/exe/cover/final-escape.webp'));
		finalEscapeCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		finalEscapeCover.updateHitbox();
		finalEscapeCover.visible = false;
		add(finalEscapeCover);
		
		yourselfCover = new FlxSprite();
		yourselfCover.loadGraphic(Paths.getBitmapData('assets/exe/cover/yourself.webp'));
		yourselfCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		yourselfCover.updateHitbox();
		if (yt == true) yourselfCover.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
		yourselfCover.visible = yt == true ? true : false;
		add(yourselfCover);

		if (FlxG.save.data.theYourselfCutscene != null){	
			microphone = new FlxSprite();
			microphone.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/microfono_lookalike.webp', 'assets/exe/story/microfono_lookalike.xml');
			microphone.animation.addByIndices('idle', 'micro', [0], '', 24, false);
			microphone.setGraphicSize(Std.int(FlxG.width * 0.183));
			microphone.setPosition(302, 116);
			microphone.updateHitbox();
			add(microphone);
		}
		
		for (coversPos in [tooSlowCover, youCantRunCover, tripleTroubleCover, finalEscapeCover, yourselfCover]) coversPos.setPosition(192, 74);
		
		final screenstaticFrames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.webp', 'assets/exe/story/screenstatic.xml');

		staticscreen = new FlxSprite();
		staticscreen.frames = screenstaticFrames;
		staticscreen.animation.addByPrefix('screenstaticANIM', 'screenSTATIC', 24);
		staticscreen.animation.play('screenstaticANIM');
		staticscreen.setGraphicSize(Std.int(FlxG.width * 0.24));
		staticscreen.updateHitbox();
		staticscreen.setPosition(189, 74);
		staticscreen.alpha = 0.3;
		add(staticscreen);
		
		bfBOX = new FlxSprite();
		bfBOX.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/bf_menu.webp', 'assets/exe/story/bf_menu.xml');
		bfBOX.animation.addByPrefix('idle', 'idle', 24, true);
		bfBOX.animation.addByPrefix('ouch', 'ay', 24, false);
		bfBOX.animation.addByPrefix('black', 'nega', 24, true);
		bfBOX.animation.addByPrefix('yeah', 'yeah', 24, false);
		bfBOX.animation.play('idle', true);
		bfBOX.setGraphicSize(Std.int(FlxG.width * 0.12));
		bfBOX.updateHitbox();
		bfBOX.setPosition(270, 300);
		add(bfBOX);
		
		final yellowBoxBitmap = Paths.getBitmapData('assets/exe/story/yellowbox.webp');

		var yellowBOX:FlxSprite = new FlxSprite();
		yellowBOX.loadGraphic(yellowBoxBitmap);
		yellowBOX.setGraphicSize(Std.int(FlxG.width * 0.252));
		yellowBOX.updateHitbox();
		yellowBOX.setPosition(178, 64);
		add(yellowBOX);
		
		// ── BOX 2 ──
		greyBOX2 = new FlxSprite();
		greyBOX2.loadGraphic(greyBoxBitmap);
		greyBOX2.setGraphicSize(Std.int(FlxG.width * 0.2635));
		greyBOX2.updateHitbox();
		greyBOX2.setPosition(799, 64);
		add(greyBOX2);
		
		var tooSlowCoverBlack:FlxSprite = new FlxSprite();
		tooSlowCoverBlack.loadGraphic(tooSlowBitmap);
		tooSlowCoverBlack.setGraphicSize(Std.int(FlxG.width * 0.24));
		tooSlowCoverBlack.updateHitbox();
		tooSlowCoverBlack.color = FlxColor.BLACK;
		tooSlowCoverBlack.setPosition(802, 74);
		tooSlowCoverBlack.visible = true;
		add(tooSlowCoverBlack);
		
		staticscreen2 = new FlxSprite();
		staticscreen2.frames = screenstaticFrames;
		staticscreen2.animation.addByPrefix('screenstaticANIM', 'screenSTATIC', 24);
		staticscreen2.animation.play('screenstaticANIM');
		staticscreen2.setGraphicSize(Std.int(FlxG.width * 0.24));
		staticscreen2.updateHitbox();
		staticscreen2.setPosition(813, 74);
		staticscreen2.alpha = 0.3;
		add(staticscreen2);
		
		gfBOX = new FlxSprite();
		gfBOX.loadGraphic(Paths.getBitmapData('assets/exe/story/gf.webp'));
		gfBOX.setGraphicSize(Std.int(FlxG.width * 0.09));
		gfBOX.updateHitbox();
		gfBOX.setPosition(910, 300);
		gfBOX.color = 0xFF888888;
		add(gfBOX);
		
		padLock = new FlxSprite();
		padLock.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/padLock.webp', 'assets/exe/story/padLock.xml');
		padLock.animation.addByPrefix('idle', 'idle', 24, true);
		padLock.animation.play('idle');
		padLock.setGraphicSize(Std.int(padLock.width * 0.27));
		padLock.updateHitbox();
		padLock.x = greyBOX2.x + greyBOX2.width / 2 - padLock.width / 2;
		padLock.y = greyBOX2.y + greyBOX2.height / 2 - padLock.height / 2;
		add(padLock);
		
		yellowBOX2 = new FlxSprite();
		yellowBOX2.loadGraphic(yellowBoxBitmap);
		yellowBOX2.setGraphicSize(Std.int(FlxG.width * 0.252));
		yellowBOX2.updateHitbox();
		yellowBOX2.setPosition(802, 64);
		add(yellowBOX2);
		
		// ── REDBOX ──
		redBOX = new FlxSprite();
		redBOX.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/cuadro.webp', 'assets/exe/story/cuadro.xml');
		redBOX.animation.addByPrefix('idle', 'cuandrado', 1, true);
		redBOX.animation.addByPrefix('break', 'evet', 16, false);
		redBOX.animation.play('idle', true);
		redBOX.setGraphicSize(Std.int(FlxG.width * 0.3057));
		redBOX.updateHitbox();
		redBOX.setPosition(greyBOX.x - 25, greyBOX.y - 17);
		add(redBOX);
		
		final arrowBitmap = Paths.getBitmapData('assets/exe/story/arrow.webp');

		arrow = new FlxSprite();
		arrow.loadGraphic(arrowBitmap);
		arrow.setGraphicSize(Std.int(190 * 0.28));
		arrow.updateHitbox();
		arrow.setPosition(60, 200);
		arrow.visible = false;
		add(arrow);
		
		arrow2 = new FlxSprite();
		arrow2.loadGraphic(arrowBitmap);
		arrow2.setGraphicSize(Std.int(190 * 0.285));
		arrow2.updateHitbox();
		arrow2.setPosition(560, 200);
		arrow2.flipX = true;
		arrow2.visible = false;
		add(arrow2);
		
		covers  = [tooSlowCover,  youCantRunCover,  tripleTroubleCover,  finalEscapeCover,  yourselfCover];
		
		box1BaseX = greyBOX.x - 30;
		box2BaseX = greyBOX2.x - 30;

		for (s in [greyBOX2, gfBOX, yellowBOX2, staticscreen2])
			s.color = 0xFF666666;

		rankText = new FlxText(0, 0, 0, 'RANK: ?');
		rankText.setFormat(Paths.font("Plaza Regular.ttf"), 40, 0xFFA87E7E, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankText.borderSize = 2;
		rankText.antialiasing = ClientPrefs.data.antialiasing;
		rankText.visible = false;
		add(rankText);

		scoreText = new FlxText(0, 0, 0, 'SCORE: 0');
		scoreText.setFormat(Paths.font("Plaza Regular.ttf"), 40, 0xFFA87E7E, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 2;
		scoreText.antialiasing = ClientPrefs.data.antialiasing;
		scoreText.visible = false;
		add(scoreText);

		scoreBG = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.visible = false;
		add(scoreBG);
	}
	
	
	function getRankLetter(rating:Float):String
	{
		if (rating >= 1)    return 'P';
		if (rating >= 0.96) return 'SS';
		if (rating >= 0.93) return 'S';
		if (rating >= 0.85) return 'AA';
		if (rating >= 0.75) return 'A';
		if (rating >= 0.6)  return 'B';
		if (rating >= 0.45) return 'C';
		if (rating >= 0.2)  return 'D';
		if (rating > 0.0)   return 'F';
		return '?';
	}

	function updateScoreDisplay():Void
	{
		Mods.currentModDirectory = STORY_MOD;
		WeekData.reloadWeekFiles(false);
		Difficulty.loadFromWeek();
		final normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		final diff = (normalIdx > -1) ? normalIdx : 0;

		final song = STORY_SONGS[selectedCover];
		final score = Highscore.getScore(song, diff);
		final rating = Highscore.getRating(song, diff);

		scoreText.text = 'SCORE: $score';
		rankText.text = 'RANK: ' + getRankLetter(rating);

		final targetRankY = FlxG.height - rankText.height - 70;
		final targetScoreY = targetRankY + rankText.height + 4;

		if (!scoreVisible)
		{
			scoreVisible = true;
			rankText.x = -rankText.width - 10;
			rankText.y = targetRankY;
			scoreText.x = -scoreText.width - 10;
			scoreText.y = targetScoreY;
			scoreText.visible = rankText.visible = true;
			scoreBG.visible = false;
			FlxTween.cancelTweensOf(rankText);
			FlxTween.cancelTweensOf(scoreText);
			FlxTween.tween(rankText, {x: 16}, 0.35, {ease: FlxEase.cubeOut});
			FlxTween.tween(scoreText, {x: 16}, 0.35, {ease: FlxEase.cubeOut});
		}
		else
		{
			rankText.x = 16;
			rankText.y = targetRankY;
			scoreText.x = 16;
			scoreText.y = targetScoreY;
		}
	}

	function moveRedBox(targetX:Float):Void
	{
		if (shakeTimer != null) { shakeTimer.cancel(); shakeTimer = null; }
		isShaking = false;

		if (box2SpriteBaseXs.length > 0)
		{
			final sprites = [greyBOX2, gfBOX, yellowBOX2, staticscreen2, padLock, redBOX];
			for (i in 0...sprites.length)
				if (sprites[i] != null && i < box2SpriteBaseXs.length)
					sprites[i].x = box2SpriteBaseXs[i];
			box2SpriteBaseXs = [];
		}

		if (redBoxTween != null) redBoxTween.cancel();
		final dist = Math.abs(redBOX.x - targetX);
		final duration = dist / 4000.0;
		redBoxTween = FlxTween.tween(redBOX, {x: targetX}, duration, {ease: FlxEase.sineOut});
	}

	function shakeBox2():Void
	{
		if (isShaking) return;
		isShaking = true;

		final sprites = [greyBOX2, gfBOX, yellowBOX2, staticscreen2, padLock, redBOX];
		final origXs = sprites.map(s -> s != null ? s.x : 0.0);
		box2SpriteBaseXs = origXs.copy();

		var count = 0;
		shakeTimer = new FlxTimer().start(0.04, function(t:FlxTimer) {
			count++;

			final off = (count % 2 == 0 ? 8.0 : -8.0);
			for (i in 0...sprites.length)
				if (sprites[i] != null)
					sprites[i].x = origXs[i] + off;

			if (count >= 6)
			{
				for (i in 0...sprites.length)
					if (sprites[i] != null)
						sprites[i].x = origXs[i];

				isShaking = false;
				shakeTimer = null;
			}
		}, 6);
	}

	function flashStaticScreen():Void
	{
		staticTween?.cancel();
		staticscreen.alpha = 1.0;
		staticTween = FlxTween.tween(staticscreen, {alpha: 0.3}, 0.5, {ease: FlxEase.quadOut});
	}

	override public function update(elapsed:Float)
	{
		_yourselfCutscene?.update(elapsed);

		if (!canInteract || Controls.instance == null || subState != null) { super.update(elapsed); return; }

		if (!isSelecting) {
			if (inCoverSelect)
			{
				if (yt == true){
					if (controls.UI_RIGHT_P || controls.UI_LEFT_P)
						FlxG.sound.play(Paths.sound('denied'));

					if (controls.ACCEPT){
						isSelecting = true;
						FlxG.sound.play(Paths.sound('menuConfirmYourself'));
						_yourselfCutscene = new YourselfCutscene(this, bfBOX, redBOX, yourselfCover); _yourselfCutscene.start();
						microphone.destroy();
					}
				}else{

					if (controls.UI_RIGHT_P && selectedCover < getUnlockedCovers())
						changeCover(selectedCover + 1);
					else if (controls.UI_LEFT_P && selectedCover > 0)
						changeCover(selectedCover - 1);
					
					if (controls.ACCEPT){
						isSelecting = true;
						bfBOX.animation.play('yeah', true);
						bfBOX.x += 10;
						FlxG.sound.play(Paths.sound('menuConfirm'));
						FlxFlicker.flicker(redBOX, 1, 0.07, false, true, function(_) launchSong());
					}
				}
					
				if (controls.BACK)
					exitCoverSelect();
			}
			else
			{
				var moved = false;
				if (FlxG.keys.justPressed.A && selectedBox == 1)
				{
					selectedBox = 0;
					moveRedBox(box1BaseX);
					moved = true;
				}
				else if (FlxG.keys.justPressed.D && selectedBox == 0)
				{
					selectedBox = 1;
					moveRedBox(box2BaseX);
					moved = true;
				}

				if (controls.BACK)
				{
					if (yt == true)
						FlxG.sound.play(Paths.sound('denied'));
					else
					{
						toMenu = true;
						FlxG.switchState(() -> new EXEMenu());
						super.update(elapsed);
						FlxG.sound.music.fadeOut(0.3);
						return;
					}
				}

				if (!moved && controls.ACCEPT)
				{
					if (selectedBox == 0) onBox1Accept();
					else { FlxG.sound.play(Paths.sound('denied')); shakeBox2(); }
				}
			}
		}

		super.update(elapsed);
	}

	function onBox1Accept():Void
	{
		if (redBoxTween != null) { redBoxTween.cancel(); redBoxTween = null; }
		redBOX.x = box1BaseX;

		inCoverSelect = true;
		selectedCover = yt == true ? 4 : 0;

		updateCoverVisibility();

		arrow.visible = arrow2.visible = true;

		arrowTween  = FlxTween.tween(arrow,  {x: arrow.x  - 6}, 1.2, {ease: FlxEase.sineInOut, type: PINGPONG});
		arrow2Tween = FlxTween.tween(arrow2, {x: arrow2.x + 6}, 1.2, {ease: FlxEase.sineInOut, type: PINGPONG});

		updateScoreDisplay();
	}

	function exitCoverSelect():Void
	{
		if (selectedCover != 0) {
			final staticSound = FlxG.sound.play(Paths.sound('static'), 0.15);
			staticSound?.fadeOut(0.3, 0);
			
			flashStaticScreen();
		}
		inCoverSelect = false;
		selectedCover = yt == true ? 4 : 0;

		updateCoverVisibility();

		arrow.visible = arrow2.visible = false;
		scoreVisible = false;
		FlxTween.cancelTweensOf(rankText);
		FlxTween.cancelTweensOf(scoreText);
		final hideX = -Math.max(scoreText.width, rankText.width) - 20;
		FlxTween.tween(rankText, {x: hideX}, 0.3, {ease: FlxEase.cubeIn, onComplete: _ -> rankText.visible = false});
		FlxTween.tween(scoreText, {x: hideX}, 0.3, {ease: FlxEase.cubeIn, onComplete: _ -> scoreText.visible = false});

		if (arrowTween != null)  { arrowTween.cancel();  arrowTween = null; }
		if (arrow2Tween != null) { arrow2Tween.cancel(); arrow2Tween = null; }

		arrow.setPosition(60, 200);
		arrow2.setPosition(560, 200);
	}

	function changeCover(newIndex:Int):Void
	{
		selectedCover = newIndex;

		updateCoverVisibility();
		flashStaticScreen();
		updateScoreDisplay();

		final staticSound = FlxG.sound.play(Paths.sound('static'), 0.2);
		staticSound?.fadeOut(0.3, 0);
	}

	function updateCoverVisibility():Void
	{
		for (i in 0...covers.length)
			covers[i].visible = (i == selectedCover);
	}

	static final STORY_SONGS:Array<String> = ['too-slow', 'you-cant-run', 'triple-trouble', 'final-escape', 'yourself'];
	static final STORY_MOD:String = 'STORY MODE';

	function launchSong():Void
	{
		if (selectedCover < 0 || selectedCover >= STORY_SONGS.length) return;

		final songLower = STORY_SONGS[selectedCover];
		final curIndex:Int = STORY_SONGS.indexOf(songLower);

		Mods.currentModDirectory = STORY_MOD;
		WeekData.reloadWeekFiles(false);
		PlayState.storyWeek = 0;
		Difficulty.loadFromWeek();

		final normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		final launchDiff = (normalIdx > -1) ? normalIdx : 0;

		try
		{
			Song.loadFromJson(Highscore.formatSong(songLower, launchDiff), songLower);
			PlayState.isStoryMode     = true;
			PlayState.storyPlaylist   = STORY_SONGS.slice(curIndex).filter(song -> song != 'yourself');
			PlayState.storyDifficulty = launchDiff;
		}
		catch (e:haxe.Exception)
		{
			trace('Error loading song: ' + e.message);
			return;
		}

		@:privateAccess
		if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			Paths.freeGraphicsFromMemory();

		canInteract = false;

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
		StoryModeState.fromStoryMode = true;

		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
	}

}
