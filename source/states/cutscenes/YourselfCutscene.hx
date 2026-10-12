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
		randomMIC.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/story/microfono_lookalike.webp'), 'assets/exe/story/microfono_lookalike.xml');
		randomMIC.animation.addByPrefix('idle', 'micro', 24, false);
		randomMIC.setGraphicSize(Std.int(FlxG.width * 0.183));
		randomMIC.setPosition(302, 116);
		randomMIC.updateHitbox();
		state.add(randomMIC);

		FlxG.camera.shake(0.025, 0.4);

		bfBOX.animation.play('ouch', true);
		redBOX.animation.play('break', true);
		randomMIC.animation.play('idle', false);
		bfBOX.y -= 80;

		new FlxTimer().start(2.3, (_) -> randomMIC?.destroy());

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
		StoryModeState.fromStoryMode = true;

		#if !SHOW_LOADING_SCREEN FlxG.sound.music?.stop(); #end
	}
}
