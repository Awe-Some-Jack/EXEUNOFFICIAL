package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.display.FlxBackdrop;
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
	public static var yourselfMode:Bool = false;

	var randomMIC:FlxSprite;

	var toMenu:Bool = false;

	var scoreRecorded:Bool = false;

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

	//Pillado del freeplay jijijijijijijiijijiijijijijiijijjijiijijijiijijijijjiijijijijijijijij
	var scoreBG:FlxSprite;
	var rankText:FlxText;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

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

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		instance = this;

		final yt = yourselfMode;
		yourselfMode = false;
		createAssets(yt);

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/story.ogg'));

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Story Mode", null);
		#end

		super.create();
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

		covers = null;

		if (toMenu) FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		super.destroy();
	}

	function createAssets(yourselfTime:Bool) {
		var clouds:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData("assets/exe/story/nuves de movimiento.png"), FlxAxes.X, 0, 0);
		clouds.velocity.x = 180;
		clouds.setGraphicSize(FlxG.width, FlxG.height * 2);
		clouds.updateHitbox();
		add(clouds);

		var smmStatic:FlxSprite = new FlxSprite(0, 0);
		smmStatic.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/SMMStatic.png', 'assets/exe/story/SMMStatic.xml');
		smmStatic.animation.addByPrefix('static', 'static', 24);
		smmStatic.animation.play('static');
		smmStatic.setGraphicSize(FlxG.width, FlxG.height);
		smmStatic.updateHitbox();
		smmStatic.alpha = 0.4;
		add(smmStatic);

		var dataSelect:FlxSprite = new FlxSprite(340, 560);
		dataSelect.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/data.png', 'assets/exe/story/data.xml');
		dataSelect.animation.addByPrefix('idle', 'Símbolo 13', 12);
		dataSelect.animation.play('idle');
		dataSelect.setGraphicSize(FlxG.width * 0.5);
		dataSelect.updateHitbox();
		add(dataSelect);
		
		// ── BOX 1 ──
		greyBOX = new FlxSprite();
		greyBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/greybox.png'));
		greyBOX.setGraphicSize(Std.int(FlxG.width * 0.2635));
		greyBOX.updateHitbox();
		greyBOX.setPosition(175, 64);
		add(greyBOX);
		
		tooSlowCover = new FlxSprite();
		tooSlowCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/too-slow.png'));
		tooSlowCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		tooSlowCover.updateHitbox();
		tooSlowCover.visible = true;
		add(tooSlowCover);
		
		youCantRunCover = new FlxSprite();
		youCantRunCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/you-cant-run.png'));
		youCantRunCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		youCantRunCover.updateHitbox();
		youCantRunCover.visible = false;
		add(youCantRunCover);
		
		tripleTroubleCover = new FlxSprite();
		tripleTroubleCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/triple-trouble.png'));
		tripleTroubleCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		tripleTroubleCover.updateHitbox();
		tripleTroubleCover.visible = false;
		add(tripleTroubleCover);
		
		finalEscapeCover = new FlxSprite();
		finalEscapeCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/final-escape.png'));
		finalEscapeCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		finalEscapeCover.updateHitbox();
		finalEscapeCover.visible = false;
		add(finalEscapeCover);
		
		yourselfCover = new FlxSprite();
		yourselfCover.loadGraphic(Assets.getBitmapData('assets/exe/cover/yourself.png'));
		yourselfCover.setGraphicSize(Std.int(FlxG.width * 0.24));
		yourselfCover.updateHitbox();
		yourselfCover.visible = false;
		add(yourselfCover);
		
		for (coversPos in [tooSlowCover, youCantRunCover, tripleTroubleCover, finalEscapeCover, yourselfCover]) coversPos.setPosition(192, 74);
		
		staticscreen = new FlxSprite();
		staticscreen.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.png', 'assets/exe/story/screenstatic.xml');
		staticscreen.animation.addByPrefix('screenstaticANIM', 'screenSTATIC', 24);
		staticscreen.animation.play('screenstaticANIM');
		staticscreen.setGraphicSize(Std.int(FlxG.width * 0.24));
		staticscreen.updateHitbox();
		staticscreen.setPosition(189, 74);
		staticscreen.alpha = 0.3;
		staticscreen.antialiasing = ClientPrefs.data.antialiasing;
		add(staticscreen);
		
		bfBOX = new FlxSprite();
		bfBOX.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/bf_menu.png', 'assets/exe/story/bf_menu.xml');
		bfBOX.animation.addByPrefix('idle', 'idle', 24, true);
		bfBOX.animation.addByPrefix('ouch', 'ay', 24, false);
		bfBOX.animation.addByPrefix('black', 'nega', 24, true);
		bfBOX.animation.addByPrefix('yeah', 'yeah', 24, false);
		bfBOX.animation.play('idle', true);
		bfBOX.setGraphicSize(Std.int(FlxG.width * 0.12));
		bfBOX.updateHitbox();
		bfBOX.setPosition(270, 300);
		bfBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(bfBOX);
		
		var yellowBOX:FlxSprite = new FlxSprite();
		yellowBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/yellowbox.png'));
		yellowBOX.setGraphicSize(Std.int(FlxG.width * 0.252));
		yellowBOX.updateHitbox();
		yellowBOX.setPosition(178, 64);
		yellowBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(yellowBOX);
		
		// ── BOX 2 ──
		greyBOX2 = new FlxSprite();
		greyBOX2.loadGraphic(Assets.getBitmapData('assets/exe/story/greybox.png'));
		greyBOX2.setGraphicSize(Std.int(FlxG.width * 0.2635));
		greyBOX2.updateHitbox();
		greyBOX2.setPosition(799, 64);
		greyBOX2.antialiasing = ClientPrefs.data.antialiasing;
		add(greyBOX2);
		
		var tooSlowCoverBlack:FlxSprite = new FlxSprite();
		tooSlowCoverBlack.loadGraphic(Assets.getBitmapData('assets/exe/cover/too-slow.png'));
		tooSlowCoverBlack.setGraphicSize(Std.int(FlxG.width * 0.24));
		tooSlowCoverBlack.updateHitbox();
		tooSlowCoverBlack.antialiasing = ClientPrefs.data.antialiasing;
		tooSlowCoverBlack.color = FlxColor.BLACK;
		tooSlowCoverBlack.setPosition(802, 74);
		tooSlowCoverBlack.visible = true;
		add(tooSlowCoverBlack);
		
		staticscreen2 = new FlxSprite();
		staticscreen2.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/screenstatic.png', 'assets/exe/story/screenstatic.xml');
		staticscreen2.animation.addByPrefix('screenstaticANIM', 'screenSTATIC', 24);
		staticscreen2.animation.play('screenstaticANIM');
		staticscreen2.setGraphicSize(Std.int(FlxG.width * 0.24));
		staticscreen2.updateHitbox();
		staticscreen2.setPosition(813, 74);
		staticscreen2.alpha = 0.3;
		staticscreen2.antialiasing = ClientPrefs.data.antialiasing;
		add(staticscreen2);
		
		gfBOX = new FlxSprite();
		gfBOX.loadGraphic(Assets.getBitmapData('assets/exe/story/gf.png'));
		gfBOX.setGraphicSize(Std.int(FlxG.width * 0.09));
		gfBOX.updateHitbox();
		gfBOX.setPosition(910, 300);
		gfBOX.color = 0xFF888888;
		gfBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(gfBOX);
		
		padLock = new FlxSprite();
		padLock.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/padLock.png', 'assets/exe/story/padLock.xml');
		padLock.animation.addByPrefix('idle', 'idle', 24, true);
		padLock.animation.play('idle');
		padLock.setGraphicSize(Std.int(padLock.width * 0.27));
		padLock.updateHitbox();
		padLock.x = greyBOX2.x + greyBOX2.width / 2 - padLock.width / 2;
		padLock.y = greyBOX2.y + greyBOX2.height / 2 - padLock.height / 2;
		padLock.antialiasing = ClientPrefs.data.antialiasing;
		add(padLock);
		
		yellowBOX2 = new FlxSprite();
		yellowBOX2.loadGraphic(Assets.getBitmapData('assets/exe/story/yellowbox.png'));
		yellowBOX2.setGraphicSize(Std.int(FlxG.width * 0.252));
		yellowBOX2.updateHitbox();
		yellowBOX2.setPosition(802, 64);
		yellowBOX2.antialiasing = ClientPrefs.data.antialiasing;
		add(yellowBOX2);
		
		// ── REDBOX ──
		redBOX = new FlxSprite();
		redBOX.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/cuadro.png', 'assets/exe/story/cuadro.xml');
		redBOX.animation.addByPrefix('idle', 'cuandrado', 1, true);
		redBOX.animation.addByPrefix('break', 'evet', 16, false);
		redBOX.animation.play('idle', true);
		redBOX.setGraphicSize(Std.int(FlxG.width * 0.3057));
		redBOX.updateHitbox();
		redBOX.setPosition(greyBOX.x - 25, greyBOX.y - 17);
		redBOX.antialiasing = ClientPrefs.data.antialiasing;
		add(redBOX);
		
		arrow = new FlxSprite();
		arrow.loadGraphic(Assets.getBitmapData('assets/exe/story/arrow.png'));
		arrow.setGraphicSize(Std.int(190 * 0.28));
		arrow.updateHitbox();
		arrow.setPosition(60, 200);
		arrow.antialiasing = ClientPrefs.data.antialiasing;
		arrow.visible = false;
		add(arrow);
		
		arrow2 = new FlxSprite();
		arrow2.loadGraphic(Assets.getBitmapData('assets/exe/story/arrow.png'));
		arrow2.setGraphicSize(Std.int(190 * 0.285));
		arrow2.updateHitbox();
		arrow2.setPosition(560, 200);
		arrow2.flipX = true;
		arrow2.antialiasing = ClientPrefs.data.antialiasing;
		arrow2.visible = false;
		add(arrow2);
		
		covers  = [tooSlowCover,  youCantRunCover,  tripleTroubleCover,  finalEscapeCover,  yourselfCover];
		
		box1BaseX = greyBOX.x - 30;
		box2BaseX = greyBOX2.x - 30;
		
		for (s in [greyBOX2, gfBOX, yellowBOX2, staticscreen2])
			s.color = 0xFF666666;
		
		//bfTween  = FlxTween.tween(bfBOX,  {y: bfBOX.y  - 5}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		//bf2Tween = FlxTween.tween(gfBOX, {y: gfBOX.y - 5}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
		
		if (yourselfTime) { canInteract = false; new FlxTimer().start(1, function(_) yourselfCutscene());}

		rankText  = new FlxText(0, 0, 0, "RANK: -",  44);
		rankText.setFormat('assets/fonts/sonicfree.otf', 44, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankText.antialiasing = false;
		rankText.borderSize = 3;
		rankText.y = FlxG.height - rankText.height - 10;

		scoreText = new FlxText(0, 0, 0, "SCORE: 0", 44);
		scoreText.setFormat('assets/fonts/sonicfree.otf', 44, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.antialiasing = false;
		scoreText.borderSize = 3;
		scoreText.y = rankText.y - scoreText.height - 4;

		scoreBG = new FlxSprite(0, scoreText.y - 4).makeGraphic(1, Std.int(FlxG.height - scoreText.y + 4), 0xFF000000);
		scoreBG.alpha = 0.6;

		add(scoreBG);
		add(scoreText);
		add(rankText);
	}
	
	
	function yourselfCutscene() {
		FlxG.sound.music.stop();
		FlxG.camera.shake(0.01, 0.2);
		
		randomMIC = new FlxSprite();
		randomMIC.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/microfono_lookalike.png', 'assets/exe/story/microfono_lookalike.xml');
		randomMIC.animation.addByPrefix('idle', 'micro', 24, false);
		randomMIC.setGraphicSize(Std.int(FlxG.width * 0.18));
		randomMIC.setPosition(320, 120);
		randomMIC.updateHitbox();
		add(randomMIC);
		
		bfBOX.animation.play('ouch', true);
		redBOX.animation.play('break', true);
		randomMIC.animation.play('idle', false);
		//bfTween.cancel();
		bfBOX.y -= 80;
		//bfTween  = FlxTween.tween(bfBOX,  {y: bfBOX.y  - 5}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});

		new FlxTimer().start(2.3, (_) -> randomMIC.destroy());

		new FlxTimer().start(5, (_) -> {
			FlxTween.tween(FlxG.camera.scroll, {y: FlxG.camera.scroll.y + FlxG.height * 2}, 1.2, {ease: FlxEase.smootherStepInOut, onComplete: (_) -> {
				bfBOX.animation.play('black', true);
				//bfTween.cancel();
				bfBOX.x += 220;
				FlxTween.tween(bfBOX, {y: bfBOX.y + 720 * 2}, 3, {ease: FlxEase.circOut, onComplete: (_) -> {
					new FlxTimer().start(0.5, (_) -> FlxTween.tween(bfBOX, {y: bfBOX.y + 720}, 3, {ease: FlxEase.circInOut, onComplete: (_) -> forceLoadYourselfSong()}));
				}});
			}});
		});
	}

	function destroyMic() randomMIC.destroy();

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
		}

		if (redBoxTween != null) redBoxTween.cancel();
		redBoxTween = FlxTween.tween(redBOX, {x: targetX}, 0.15, {ease: FlxEase.sineOut});
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

	var moveText:Bool = false;
	override public function update(elapsed:Float)
	{
		if (!canInteract || Controls.instance == null || subState != null) { super.update(elapsed); return; }

		if (!isSelecting) {
			if (inCoverSelect)
			{
				if (controls.UI_RIGHT_P && selectedCover < covers.length - 1)
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

				if (controls.BACK)
					exitCoverSelect();

				final prevScore = lerpScore;
				final prevRating = lerpRating;

				lerpScore  = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
				lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

				if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
				if (Math.abs(lerpRating - intendedRating) <= 0.01) lerpRating = intendedRating;

				if (lerpScore != prevScore || lerpRating != prevRating) updateScoreDisplay();

				moveText = true;
				for (scoreTexts in [scoreText, rankText]){
					FlxTween.num(scoreTexts.y + 120, scoreTexts.y - 120, 1, {ease:FlxEase.circOut}, (val:Float) -> scoreTexts.y = val);
					scoreTexts.alpha = 1;
					moveText = false;
				}
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

				if (controls.BACK)
				{
					toMenu = true;
					FlxG.switchState(() -> new EXEMenu());
					super.update(elapsed);
					FlxG.sound.music.fadeOut(0.3);
					return;
				}

				if (controls.ACCEPT)
				{
					if (selectedBox == 0) onBox1Accept();
					else shakeBox2();
				}

				for (scoreTexts in [scoreText, rankText])
					scoreTexts.alpha = 0;
			}
		}

		super.update(elapsed);
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
		rankText.x = FlxG.width - rankText.width - 6;
		rankText.y = FlxG.height - rankText.height - 8;
		scoreText.y = rankText.y - scoreText.height - 4;

		final bgWidth = FlxG.width - Math.min(scoreText.x, rankText.x) + 6;
		scoreBG.scale.x = bgWidth;
		scoreBG.x = FlxG.width - bgWidth / 2;
		scoreBG.y = scoreText.y - 4;
	}

	static function getRankLetter(rating:Float):String
	{
		switch (rating)
		{
			case _ if (rating >= 1): return 'P';
			case _ if (rating >= 0.96): return 'SS';
			case _ if (rating >= 0.93): return 'S';
			case _ if (rating >= 0.85): return 'AA';
			case _ if (rating >= 0.75): return 'A';
			case _ if (rating >= 0.6): return 'B';
			case _ if (rating >= 0.45): return 'C';
			case _ if (rating >= 0.2): return 'D';
			case _ if (rating > 0.0): return 'F';
			default: return '?';
		}
	}

	function onBox1Accept():Void
	{
		inCoverSelect = true;
		selectedCover = 0;

		updateCoverVisibility();

		arrow.visible = arrow2.visible = true;

		arrowTween  = FlxTween.tween(arrow,  {x: arrow.x  - 6}, 1.2, {ease: FlxEase.sineInOut, type: PINGPONG});
		arrow2Tween = FlxTween.tween(arrow2, {x: arrow2.x + 6}, 1.2, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	function exitCoverSelect():Void
	{
		if (selectedCover != 0) {
			final staticSound = FlxG.sound.play(Paths.sound('static'), 0.15);
			staticSound?.fadeOut(0.3, 0);
			
			flashStaticScreen();
		}
		inCoverSelect = false;
		selectedCover = 0;

		updateCoverVisibility();

		arrow.visible = arrow2.visible = false;

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
			PlayState.storyPlaylist   = STORY_SONGS.slice(curIndex);
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

		if (STORY_SONGS[selectedCover] == 'yourself')
		{
			canInteract = false;
			yourselfCutscene();
			return;
		}

		canInteract = false;

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());

		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
	}

	function forceLoadYourselfSong() {
		final song:String = 'yourself';

		Mods.currentModDirectory = STORY_MOD;
		WeekData.reloadWeekFiles(false);
		PlayState.storyWeek = 1;
		Difficulty.loadFromWeek();

		final normalIdx = Lambda.findIndex(Difficulty.list, d -> d.toLowerCase() == 'normal');
		final launchDiff = (normalIdx > -1) ? normalIdx : 0;

		try
		{
			Song.loadFromJson(song, Highscore.formatSong(song, launchDiff));
			PlayState.isStoryMode     = true;
			PlayState.storyDifficulty = 1;
		}
		catch (e:haxe.Exception)
		{
			trace('Error loading song: ' + e.message);
			return;
		}

		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());

		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
	}
}
