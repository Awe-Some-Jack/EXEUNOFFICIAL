package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
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

class StoryModeState extends MusicBeatState
{
	public static var instance:StoryModeState;
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var smmStatic:FlxSprite;

	var greyBOX:FlxSprite;
	var bfBOX:FlxSprite;
	var yellowBOX:FlxSprite;
	var staticscreen:FlxSprite;
	var arrow:FlxSprite;
	var arrow2:FlxSprite;
	var tooSlowCover:FlxSprite;
	var youCantRunCover:FlxSprite;
	var tripleTroubleCover:FlxSprite;
	var finalEscapeCover:FlxSprite;
	var yourselfCover:FlxSprite;

	var greyBOX2:FlxSprite;
	var bfBOX2:FlxSprite;
	var padLock:FlxSprite;
	var yellowBOX2:FlxSprite;
	var staticscreen2:FlxSprite;
	var tooSlowCover2:FlxSprite;
	var youCantRunCover2:FlxSprite;
	var tripleTroubleCover2:FlxSprite;
	var finalEscapeCover2:FlxSprite;
	var yourselfCover2:FlxSprite;

	var redBOX:FlxSprite;

	var selectedBox:Int = 0;
	var canInteract:Bool = true;
	var redBoxTween:FlxTween;
	var inCoverSelect:Bool = false;
	var selectedCover:Int = 0;
	var covers:Array<FlxSprite>;
	var covers2:Array<FlxSprite>;

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


	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		instance = this;

		smmStatic = new FlxSprite(0, 0);
		smmStatic.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/SMMStatic.png', 'assets/exe/story/SMMStatic.xml');
		smmStatic.animation.addByPrefix('static', 'static', 24);
		smmStatic.animation.play('static');
		smmStatic.setGraphicSize(FlxG.width, FlxG.height);
		smmStatic.updateHitbox();
		smmStatic.scrollFactor.set();
		add(smmStatic);

		// ── BOX 1 ──
		greyBOX = new FlxSprite();
		greyBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/greybox.png'));
		greyBOX.setGraphicSize(Std.int(FlxG.width * 0.335));
		greyBOX.updateHitbox();
		greyBOX.x = 115; greyBOX.y = 64;
		greyBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(greyBOX);

		tooSlowCover = new FlxSprite();
		tooSlowCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/too-slow.png'));
		tooSlowCover.setGraphicSize(Std.int(FlxG.width * 0.3));
		tooSlowCover.updateHitbox();
		tooSlowCover.x = 132; tooSlowCover.y = 74;
		tooSlowCover.antialiasing = ClientPrefs.data.antialiasing;
		tooSlowCover.visible = true;
		add(tooSlowCover);

		youCantRunCover = new FlxSprite();
		youCantRunCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/you-cant-run.png'));
		youCantRunCover.setGraphicSize(Std.int(FlxG.width * 0.3));
		youCantRunCover.updateHitbox();
		youCantRunCover.x = 132; youCantRunCover.y = 74;
		youCantRunCover.antialiasing = ClientPrefs.data.antialiasing;
		youCantRunCover.visible = false;
		add(youCantRunCover);

		tripleTroubleCover = new FlxSprite();
		tripleTroubleCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/triple-trouble.png'));
		tripleTroubleCover.setGraphicSize(Std.int(FlxG.width * 0.3));
		tripleTroubleCover.updateHitbox();
		tripleTroubleCover.x = 132; tripleTroubleCover.y = 74;
		tripleTroubleCover.antialiasing = ClientPrefs.data.antialiasing;
		tripleTroubleCover.visible = false;
		add(tripleTroubleCover);

		finalEscapeCover = new FlxSprite();
		finalEscapeCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/final-escape.png'));
		finalEscapeCover.setGraphicSize(Std.int(FlxG.width * 0.3));
		finalEscapeCover.updateHitbox();
		finalEscapeCover.x = 132; finalEscapeCover.y = 74;
		finalEscapeCover.antialiasing = ClientPrefs.data.antialiasing;
		finalEscapeCover.visible = false;
		add(finalEscapeCover);

		yourselfCover = new FlxSprite();
		yourselfCover.loadGraphic(Assets.getBitmapData('assets/exe/freeplayassets/placeholder.png'));
		yourselfCover.setGraphicSize(Std.int(FlxG.width * 0.3));
		yourselfCover.updateHitbox();
		yourselfCover.x = 132; yourselfCover.y = 74;
		yourselfCover.antialiasing = ClientPrefs.data.antialiasing;
		yourselfCover.visible = false;
		add(yourselfCover);

		staticscreen = new FlxSprite();
		staticscreen.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.png', 'assets/exe/story/screenstatic.xml');
		staticscreen.animation.addByPrefix('screenstaticANIM', 'screenSTATIC', 24);
		staticscreen.animation.play('screenstaticANIM');
		staticscreen.setGraphicSize(Std.int(FlxG.width * 0.3));
		staticscreen.updateHitbox();
		staticscreen.x = 129; staticscreen.y = 74;
		staticscreen.alpha = 0.3;
		staticscreen.antialiasing = ClientPrefs.data.antialiasing;
		add(staticscreen);

		bfBOX = new FlxSprite();
		bfBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/BFBOX.png'));
		bfBOX.setGraphicSize(Std.int(FlxG.width * 0.15));
		bfBOX.updateHitbox();
		bfBOX.x = 230; bfBOX.y = 330;
		bfBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(bfBOX);

		yellowBOX = new FlxSprite();
		yellowBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/yellowbox.png'));
		yellowBOX.setGraphicSize(Std.int(FlxG.width * 0.32));
		yellowBOX.updateHitbox();
		yellowBOX.x = 118; yellowBOX.y = 64;
		yellowBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(yellowBOX);

		arrow = new FlxSprite();
		arrow.loadGraphic(Assets.getBitmapData('assets/exe/story/arrow.png'));
		arrow.setGraphicSize(Std.int(190 * 0.21));
		arrow.updateHitbox();
		arrow.x = 60; arrow.y = 170;
		arrow.antialiasing = ClientPrefs.data.antialiasing;
		arrow.visible = false;
		add(arrow);

		arrow2 = new FlxSprite();
		arrow2.loadGraphic(Assets.getBitmapData('assets/exe/story/arrow.png'));
		arrow2.setGraphicSize(Std.int(190 * 0.195));
		arrow2.updateHitbox();
		arrow2.x = 540; arrow2.y = 170;
		arrow2.flipX = true;
		arrow2.antialiasing = ClientPrefs.data.antialiasing;
		arrow2.visible = false;
		add(arrow2);

		// ── BOX 2 ──
		greyBOX2 = new FlxSprite();
		greyBOX2.loadGraphic(Assets.getBitmapData('assets/exe/story/greybox.png'));
		greyBOX2.setGraphicSize(Std.int(FlxG.width * 0.335));
		greyBOX2.updateHitbox();
		greyBOX2.x = 115 + 624; greyBOX2.y = 64;
		greyBOX2.antialiasing = ClientPrefs.data.antialiasing;
		add(greyBOX2);

		tooSlowCover2 = new FlxSprite();
		tooSlowCover2.loadGraphic(Assets.getBitmapData('assets/exe/cover/too-slow.png'));
		tooSlowCover2.setGraphicSize(Std.int(FlxG.width * 0.3));
		tooSlowCover2.updateHitbox();
		tooSlowCover2.x = 132 + 624; tooSlowCover2.y = 74;
		tooSlowCover2.antialiasing = ClientPrefs.data.antialiasing;
		tooSlowCover2.visible = true;
		add(tooSlowCover2);

		youCantRunCover2 = new FlxSprite();
		youCantRunCover2.loadGraphic(Assets.getBitmapData('assets/exe/cover/you-cant-run.png'));
		youCantRunCover2.setGraphicSize(Std.int(FlxG.width * 0.3));
		youCantRunCover2.updateHitbox();
		youCantRunCover2.x = 132 + 624; youCantRunCover2.y = 74;
		youCantRunCover2.antialiasing = ClientPrefs.data.antialiasing;
		youCantRunCover2.visible = false;
		add(youCantRunCover2);

		tripleTroubleCover2 = new FlxSprite();
		tripleTroubleCover2.loadGraphic(Assets.getBitmapData('assets/exe/cover/triple-trouble.png'));
		tripleTroubleCover2.setGraphicSize(Std.int(FlxG.width * 0.3));
		tripleTroubleCover2.updateHitbox();
		tripleTroubleCover2.x = 132 + 624; tripleTroubleCover2.y = 74;
		tripleTroubleCover2.antialiasing = ClientPrefs.data.antialiasing;
		tripleTroubleCover2.visible = false;
		add(tripleTroubleCover2);

		finalEscapeCover2 = new FlxSprite();
		finalEscapeCover2.loadGraphic(Assets.getBitmapData('assets/exe/cover/final-escape.png'));
		finalEscapeCover2.setGraphicSize(Std.int(FlxG.width * 0.3));
		finalEscapeCover2.updateHitbox();
		finalEscapeCover2.x = 132 + 624; finalEscapeCover2.y = 74;
		finalEscapeCover2.antialiasing = ClientPrefs.data.antialiasing;
		finalEscapeCover2.visible = false;
		add(finalEscapeCover2);

		yourselfCover2 = new FlxSprite();
		yourselfCover2.loadGraphic(Assets.getBitmapData('assets/exe/freeplayassets/placeholder.png'));
		yourselfCover2.setGraphicSize(Std.int(FlxG.width * 0.3));
		yourselfCover2.updateHitbox();
		yourselfCover2.x = 132 + 624; yourselfCover2.y = 74;
		yourselfCover2.antialiasing = ClientPrefs.data.antialiasing;
		yourselfCover2.visible = false;
		add(yourselfCover2);

		staticscreen2 = new FlxSprite();
		staticscreen2.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.png', 'assets/exe/story/screenstatic.xml');
		staticscreen2.animation.addByPrefix('screenstaticANIM', 'screenSTATIC', 24);
		staticscreen2.animation.play('screenstaticANIM');
		staticscreen2.setGraphicSize(Std.int(FlxG.width * 0.3));
		staticscreen2.updateHitbox();
		staticscreen2.x = 129 + 624; staticscreen2.y = 74;
		staticscreen2.alpha = 0.3;
		staticscreen2.antialiasing = ClientPrefs.data.antialiasing;
		add(staticscreen2);

		bfBOX2 = new FlxSprite();
		bfBOX2.loadGraphic(Assets.getBitmapData('assets/exe/story/BFBOX.png'));
		bfBOX2.setGraphicSize(Std.int(FlxG.width * 0.15));
		bfBOX2.updateHitbox();
		bfBOX2.x = 230 + 624; bfBOX2.y = 330;
		bfBOX2.color = 0xFF888888;
		bfBOX2.antialiasing = ClientPrefs.data.antialiasing;
		add(bfBOX2);

		padLock = new FlxSprite();
		padLock.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/padLock.png', 'assets/exe/story/padLock.xml');
		padLock.animation.addByPrefix('idle', 'idle', 24, true);
		padLock.animation.play('idle');
		padLock.setGraphicSize(Std.int(padLock.width * 0.5));
		padLock.updateHitbox();
		padLock.x = greyBOX2.x + greyBOX2.width / 2 - padLock.width / 2;
		padLock.y = greyBOX2.y + greyBOX2.height / 2 - padLock.height / 2;
		padLock.antialiasing = ClientPrefs.data.antialiasing;
		add(padLock);

		yellowBOX2 = new FlxSprite();
		yellowBOX2.loadGraphic(Assets.getBitmapData('assets/exe/story/yellowbox.png'));
		yellowBOX2.setGraphicSize(Std.int(FlxG.width * 0.32));
		yellowBOX2.updateHitbox();
		yellowBOX2.x = 118 + 624; yellowBOX2.y = 64;
		yellowBOX2.antialiasing = ClientPrefs.data.antialiasing;
		add(yellowBOX2);

		// ── REDBOX ──
		redBOX = new FlxSprite();
		redBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/redbox.png'));
		redBOX.setGraphicSize(Std.int(FlxG.width * 0.377));
		redBOX.updateHitbox();
		redBOX.x = greyBOX.x - 30; redBOX.y = greyBOX.y - 17;
		redBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(redBOX);

		covers  = [tooSlowCover,  youCantRunCover,  tripleTroubleCover,  finalEscapeCover,  yourselfCover];
		covers2 = [tooSlowCover2, youCantRunCover2, tripleTroubleCover2, finalEscapeCover2, yourselfCover2];

		box1BaseX = greyBOX.x - 30;
		box2BaseX = greyBOX2.x - 30;

		for (s in [greyBOX2, bfBOX2, yellowBOX2, staticscreen2, tooSlowCover2, youCantRunCover2, tripleTroubleCover2, finalEscapeCover2, yourselfCover2])
			s.color = 0xFF666666;

		bfTween  = FlxTween.tween(bfBOX,  {y: bfBOX.y  - 5}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		bf2Tween = FlxTween.tween(bfBOX2, {y: bfBOX2.y - 5}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});

		super.create();
		Paths.clearUnusedMemory();
	}

	override function destroy()
	{
		instance = null;
		if (arrowTween  != null) arrowTween.cancel();
		if (arrow2Tween != null) arrow2Tween.cancel();
		if (bfTween     != null) bfTween.cancel();
		if (bf2Tween    != null) bf2Tween.cancel();
		if (staticTween != null) staticTween.cancel();
		if (redBoxTween != null) redBoxTween.cancel();
		covers = null; covers2 = null;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		super.destroy();
	}

	function moveRedBox(targetX:Float):Void
	{
		if (shakeTimer != null) { shakeTimer.cancel(); shakeTimer = null; }
		isShaking = false;

		if (box2SpriteBaseXs.length > 0)
		{
			var sprites = [greyBOX2, bfBOX2, yellowBOX2, staticscreen2,
				tooSlowCover2, youCantRunCover2, tripleTroubleCover2, finalEscapeCover2, yourselfCover2, padLock, redBOX];
			for (i in 0...sprites.length)
				if (sprites[i] != null && i < box2SpriteBaseXs.length)
					sprites[i].x = box2SpriteBaseXs[i];
		}

		if (redBoxTween != null) redBoxTween.cancel();
		redBoxTween = FlxTween.tween(redBOX, {x: targetX}, 0.15, {ease: FlxEase.sineOut});
	}

	function shakeBox2():Void
	{
		if (isShaking) return;
		isShaking = true;

		var sprites = [greyBOX2, bfBOX2, yellowBOX2, staticscreen2,
			tooSlowCover2, youCantRunCover2, tripleTroubleCover2, finalEscapeCover2, yourselfCover2, padLock, redBOX];
		var origXs = sprites.map(s -> s != null ? s.x : 0.0);
		box2SpriteBaseXs = origXs.copy();
		var count = 0;

		shakeTimer = new FlxTimer().start(0.04, function(t:FlxTimer) {
			count++;
			var off = (count % 2 == 0 ? 8.0 : -8.0);
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
		if (staticTween != null) staticTween.cancel();
		staticscreen.alpha = 1.0;
		staticTween = FlxTween.tween(staticscreen, {alpha: 0.3}, 0.5, {ease: FlxEase.quadOut});
	}

	override public function update(elapsed:Float)
	{
		if (!canInteract) { super.update(elapsed); return; }
		if (Controls.instance == null) { super.update(elapsed); return; }

		if (inCoverSelect)
		{
			if (Controls.instance.UI_RIGHT_P && selectedCover < covers.length - 1)
				changeCover(selectedCover + 1);
			else if (Controls.instance.UI_LEFT_P && selectedCover > 0)
				changeCover(selectedCover - 1);
			if (Controls.instance.ACCEPT)
				launchSong();
			if (Controls.instance.BACK)
				exitCoverSelect();
		}
		else
		{
			if (FlxG.keys.justPressed.A && selectedBox == 1)
			{
				selectedBox = 0;
				moveRedBox(box1BaseX);
			}
			else if (FlxG.keys.justPressed.D && selectedBox == 0)
			{
				selectedBox = 1;
				moveRedBox(box2BaseX);
			}

			if (Controls.instance.BACK)
			{
				FlxG.switchState(() -> new Exemenu());
				super.update(elapsed);
				return;
			}

			if (Controls.instance.ACCEPT)
			{
				if (selectedBox == 0) onBox1Accept();
				else shakeBox2();
			}
		}

		super.update(elapsed);
	}

	function onBox1Accept():Void
	{
		inCoverSelect = true;
		selectedCover = 0;
		updateCoverVisibility();
		arrow.visible  = true;
		arrow2.visible = true;
		arrowTween  = FlxTween.tween(arrow,  {x: arrow.x  - 6}, 1.2, {ease: FlxEase.sineInOut, type: PINGPONG});
		arrow2Tween = FlxTween.tween(arrow2, {x: arrow2.x + 6}, 1.2, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	function exitCoverSelect():Void
	{
		inCoverSelect = false;
		selectedCover = 0;
		updateCoverVisibility();
		arrow.visible  = false;
		arrow2.visible = false;
		if (arrowTween != null)  { arrowTween.cancel();  arrowTween = null; }
		if (arrow2Tween != null) { arrow2Tween.cancel(); arrow2Tween = null; }
		arrow.x = 100; arrow.y = 200;
		arrow2.x = 500; arrow2.y = 200;
	}

	function changeCover(newIndex:Int):Void
	{
		selectedCover = newIndex;
		updateCoverVisibility();
		flashStaticScreen();
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

		var songLower = STORY_SONGS[selectedCover];

		Mods.currentModDirectory = STORY_MOD;
		WeekData.reloadWeekFiles(false);
		PlayState.storyWeek = 1;
		Difficulty.loadFromWeek();

		var normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		var launchDiff = (normalIdx > -1) ? normalIdx : 0;

		var poop = Highscore.formatSong(songLower, launchDiff);

		try
		{
			Song.loadFromJson(poop, songLower);
			PlayState.isStoryMode     = true;
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
		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
	}
}
