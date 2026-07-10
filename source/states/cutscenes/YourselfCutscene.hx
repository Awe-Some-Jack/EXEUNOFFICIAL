package states.cutscenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

import backend.Song;
import backend.Highscore;
import backend.WeekData;
import backend.Difficulty;
import backend.Mods;
import backend.Paths;

import states.LoadingState;
import states.PlayState;

class YourselfCutscene
{
	static inline final STORY_MOD:String = 'STORY MODE';

	var state:StoryModeState;
	var bfBOX:FlxSprite;
	var redBOX:FlxSprite;
	var yourselfCover:FlxSprite;
	var randomMIC:FlxSprite;
	var hand:FlxSprite;
	var handOpen:FlxSprite;

	var _handX:Float = 306;
	var _handY:Float = 128;
	var _handScale:Float = 0.069;
	var _handAngle:Float = -7;
	var _handDelay:Float = 1.4;

	var _handOpenX:Float = 312;
	var _handOpenY:Float = 128;
	var _handOpenScale:Float = 0.06;
	var _handOpenAngle:Float = 55;

	var _micX:Float = 302;
	var _micY:Float = 116;
	var _micScale:Float = 0.183;
	var _micAngle:Float = 0;

	public function new(state:StoryModeState, bfBOX:FlxSprite, redBOX:FlxSprite, yourselfCover:FlxSprite)
	{
		this.state = state;
		this.bfBOX = bfBOX;
		this.redBOX = redBOX;
		this.yourselfCover = yourselfCover;
	}

	public function start():Void
	{
		FlxG.sound.music.stop();
		FlxG.camera.shake(0.01, 0.2);

		randomMIC = new FlxSprite();
		randomMIC.frames = FlxAtlasFrames.fromSparrow('assets/exe/story/microfono_lookalike.png', 'assets/exe/story/microfono_lookalike.xml');
		randomMIC.animation.addByPrefix('idle', 'micro', 24, false);
		randomMIC.setGraphicSize(Std.int(FlxG.width * _micScale));
		randomMIC.setPosition(_micX, _micY);
		randomMIC.updateHitbox();
		randomMIC.angle = _micAngle;
		state.add(randomMIC);

		hand = new FlxSprite();
		hand.loadGraphic(Paths.getBitmapData('assets/exe/story/hand.png'));
		hand.setGraphicSize(Std.int(FlxG.width * _handScale));
		hand.updateHitbox();
		final handFinalScaleX = hand.scale.x;
		final handFinalScaleY = hand.scale.y;
		final handCenterX = _handX + hand.width / 2;
		final handCenterY = _handY + hand.height / 2;
		hand.scale.set(0, 0);
		hand.setPosition(handCenterX, handCenterY);
		hand.angle = _handAngle;
		state.add(hand);

		handOpen = new FlxSprite();
		handOpen.loadGraphic(Paths.getBitmapData('assets/exe/story/handopen.png'));
		handOpen.setGraphicSize(Std.int(FlxG.width * _handOpenScale));
		handOpen.updateHitbox();
		handOpen.setPosition(_handOpenX, _handOpenY);
		handOpen.angle = _handOpenAngle;
		handOpen.visible = false;
		state.add(handOpen);

		if (yourselfCover != null)
			yourselfCover.loadGraphic(Paths.getBitmapData('assets/exe/cover/yourself.png'));

		FlxTween.tween(hand.scale, {x: handFinalScaleX, y: handFinalScaleY}, 0.3, {ease: FlxEase.backOut,
			onUpdate: (_) -> {
				hand.x = handCenterX - hand.width / 2;
				hand.y = handCenterY - hand.height / 2;
			},
			onComplete: (_) -> hand.setPosition(_handX, _handY)
		});

		new FlxTimer().start(_handDelay, (_) -> {
			if (hand == null || hand.graphic == null) return;
			hand.visible = false;
			if (handOpen != null && handOpen.graphic != null)
				handOpen.visible = true;
		});

		final cw = Std.int(FlxG.width * 0.24);
		final ch = Std.int(cw * (720 / 1280));
		final coverFlash = new FlxSprite(192, 74).makeGraphic(cw, ch, 0xFFFFFFFF);
		state.add(coverFlash);
		FlxTween.tween(coverFlash, {alpha: 0}, 0.35, {ease: FlxEase.quadOut, onComplete: (_) -> coverFlash.destroy()});

		FlxG.camera.shake(0.025, 0.4);

		bfBOX.animation.play('ouch', true);
		redBOX.animation.play('break', true);
		randomMIC.animation.play('idle', false);
		bfBOX.y -= 80;

		new FlxTimer().start(2.3, (_) -> {
			randomMIC?.destroy();
			final activeHand = (handOpen != null && handOpen.visible && handOpen.graphic != null) ? handOpen : hand;
			if (activeHand != null && activeHand.graphic != null)
			{
				final cx = activeHand.x + activeHand.width / 2;
				final cy = activeHand.y + activeHand.height / 2;
				final startScaleX = activeHand.scale.x;
				FlxTween.tween(activeHand.scale, {x: 0, y: 0}, 0.6, {ease: FlxEase.quadIn,
					onUpdate: (_) -> {
						activeHand.x = cx - activeHand.width / 2;
						activeHand.y = cy - activeHand.height / 2;
						activeHand.alpha = activeHand.scale.x / startScaleX;
					},
					onComplete: (_) -> {
						activeHand.destroy();
						if (activeHand == handOpen) hand?.destroy();
						else handOpen?.destroy();
					}
				});
			}
		});

		new FlxTimer().start(5, (_) -> {
			FlxTween.tween(FlxG.camera.scroll, {y: FlxG.camera.scroll.y + FlxG.height * 2}, 1.2, {ease: FlxEase.smootherStepInOut, onComplete: (_) -> {
				bfBOX.animation.play('black', true);
				bfBOX.x += 220;
				FlxTween.tween(bfBOX, {y: bfBOX.y + 720 * 2}, 3, {ease: FlxEase.circOut, onComplete: (_) -> {
					new FlxTimer().start(0.5, (_) -> FlxTween.tween(bfBOX, {y: bfBOX.y + 720}, 3, {ease: FlxEase.circInOut, onComplete: (_) -> forceLoadYourselfSong()}));
				}});
			}});
		});
	}

	public function update(elapsed:Float):Void {}

	function forceLoadYourselfSong():Void
	{
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

		#if !SHOW_LOADING_SCREEN FlxG.sound.music?.stop(); #end
	}
}
