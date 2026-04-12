package states.access;

import backend.Song;
import flixel.graphics.frames.FlxAtlasFrames;
import shaders.ColorOut;

#if !flash
import openfl.filters.ShaderFilter;
#end

class MajinAccess extends MusicBeatState
{
	var buttonUS:FlxSprite;
	var buttonJP:FlxSprite;

	var soundOne:FlxSprite;
	var soundTwo:FlxSprite;

	var isJP:Bool = false;

	var shaderOut:ColorOut = new ColorOut();
	var blackBG:FlxSprite;
	var transitioning:Bool = false;
	var toSong:Bool = false;
	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Assets.getSound('assets/exe/access/majin/selectsoundtrack.ogg'), 0.8);
		
		var box:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/majin/cuadro.png'));
		box.antialiasing = false;
		box.screenCenter();
		box.setPosition(Std.int(box.x), Std.int(box.y));
		add(box);

		var eggman:FlxSprite = new FlxSprite(0, box.y + 40);
		eggman.frames = FlxAtlasFrames.fromSparrow('assets/exe/access/majin/eggman.png', 'assets/exe/access/majin/eggman.xml');
		eggman.animation.addByPrefix('idle', 'idle', 2, true);
		eggman.animation.play('idle');
		eggman.antialiasing = false;
		eggman.scale.set(2, 2);
		eggman.updateHitbox();
		eggman.screenCenter(X);
		eggman.x = Std.int(eggman.x);
		add(eggman);

		var soundOne:FlxSprite = new FlxSprite(0, eggman.y).loadGraphic(Assets.getBitmapData('assets/exe/access/majin/sound1.png'));
		soundOne.antialiasing = false;
		soundOne.scale.set(2, 2);
		soundOne.updateHitbox();
		soundOne.x = eggman.x - soundOne.width - 20;
		add(soundOne);

		var soundTwo:FlxSprite = new FlxSprite(0, eggman.y).loadGraphic(Assets.getBitmapData('assets/exe/access/majin/sound2.png'));
		soundTwo.antialiasing = false;
		soundTwo.scale.set(2, 2);
		soundTwo.updateHitbox();
		soundTwo.x = eggman.x + eggman.width + 20;
		add(soundTwo);

		buttonUS = new FlxSprite(0, box.y + 144);
		buttonUS.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'));
		buttonUS.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'), true, Math.floor(buttonUS.width / 2), Math.floor(buttonUS.height / 2));
		buttonUS.animation.add('idle', [3]); buttonUS.animation.add('selected', [1]);
		buttonUS.animation.play('selected');
		buttonUS.antialiasing = false;
		buttonUS.scale.set(2, 2);
		buttonUS.updateHitbox();
		buttonUS.x = Std.int((FlxG.width / 2) - buttonUS.width - 60);
		add(buttonUS);

		buttonJP = new FlxSprite(0, box.y + 144);
		buttonJP.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'));
		buttonJP.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'), true, Math.floor(buttonJP.width / 2), Math.floor(buttonJP.height / 2));
		buttonJP.animation.add('idle', [2]); buttonJP.animation.add('selected', [0]);
		buttonJP.animation.play('idle');
		buttonJP.antialiasing = false;
		buttonJP.scale.set(2, 2);
		buttonJP.updateHitbox();
		buttonJP.x = Std.int((FlxG.width / 2) + 60);
		add(buttonJP);

		blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackBG.alpha = 0;
		blackBG.screenCenter();
		add(blackBG);

		shaderOut.invert.value = [true];
		shaderOut.lowerBound.value = [0.0];
		shaderOut.borderTint.value = [0.0, 0.0, 0.0];
		shaderOut.upperBound.value = [0.0];
		shaderOut.tint.value = [1.0, 1.0, 1.0];

		FlxG.camera.filters = [new ShaderFilter(shaderOut)];
	}

	var mouseWasOver:String = 'us';
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!transitioning)
		{
			if (Controls.instance.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new EXEMenu());
				FlxG.sound.music.fadeOut(0.3);
				transitioning = true;
			}

			if (Controls.instance.UI_LEFT_P || Controls.instance.UI_RIGHT_P || FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				isJP = !isJP;
				buttonUS.animation.play(isJP ? 'idle' : 'selected');
				buttonJP.animation.play(isJP ? 'selected' : 'idle');
			}
			if (FlxG.mouse.overlaps(buttonUS) && mouseWasOver == 'jp' && isJP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				isJP = false;
				buttonUS.animation.play(isJP ? 'idle' : 'selected');
				buttonJP.animation.play(isJP ? 'selected' : 'idle');
				mouseWasOver = 'us';
			}
			if (FlxG.mouse.overlaps(buttonJP) && mouseWasOver == 'us' && !isJP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				isJP = true;
				buttonUS.animation.play(isJP ? 'idle' : 'selected');
				buttonJP.animation.play(isJP ? 'selected' : 'idle');
				mouseWasOver = 'jp';
			}
			if (!FlxG.mouse.overlaps(buttonJP) && !FlxG.mouse.overlaps(buttonUS)) mouseWasOver = isJP ? 'jp' : 'us';

			var daButton:FlxSprite = (isJP ? buttonJP : buttonUS);
			if (Controls.instance.ACCEPT || (FlxG.mouse.overlaps(daButton) && FlxG.mouse.justPressed))
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('majinfreeplay'));
				FlxTween.tween(blackBG, {alpha: 1}, 1);
				FlxTween.num(1, 0, 0.9, function(num) {
					shaderOut.upperBound.value = [0.5 - (num / 2)];
					shaderOut.tint.value = [num, num, 0.9 + (num / 10)];
				});
				FlxG.sound.music.fadeOut(0.6);
				if (loadSong(isJP ? 'Endless JP' : 'Endless US'))
				{
					new FlxTimer().start(1.5, function(tmr:FlxTimer){
						LoadingState.prepareToSong();
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.camera.filters = [];
					});
				}
			}
		}
	}

	function loadSong(endless:String):Bool
	{
		try
		{
			Mods.currentModDirectory = 'MAJIN';

			var firstSong:String = Paths.formatToSongPath(endless);
			Song.loadFromJson(firstSong, firstSong);

			PlayState.storyPlaylist = [endless];
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 0;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;

			toSong = true;
		}
		catch (e:Dynamic)
		{
			trace("Error cargando cancion: " + e);
			return false;
		}
		return true;
	}

	override function destroy()
	{
		if (!toSong){
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
			CustomShapeTransition.shape = HEAD;
		}
		super.destroy();
	}
}