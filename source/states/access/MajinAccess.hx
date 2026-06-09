package states.access;

import backend.Song;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxAtlasFrames;
import shaders.ColorOut;

#if !flash
import openfl.filters.ShaderFilter;
#end

class MajinAccess extends MusicBeatState
{
	var buttonUS:FlxSprite;
	var buttonJP:FlxSprite;

	var eggman:FlxSprite;
	var soundOne:FlxSprite;
	var soundTwo:FlxSprite;

	var isJP:Bool = true;

	var shaderOut:ColorOut = new ColorOut();
	var blackBG:FlxSprite;
	var transitioning:Bool = false;
	var toSong:Bool = false;
	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Assets.getSound('assets/exe/access/majin/selectsoundtrack.ogg'), 0.8);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/majin/bg.png'));
		bg.scale.set(1500, 1500);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = false;
		bg.angularVelocity = -10;
		add(bg);

		for (i in 0...2)
		{
			var sonicbg:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/majin/sonicmajin.png'));
			sonicbg.scale.set(3, 3);
			sonicbg.updateHitbox();
			sonicbg.screenCenter(X);
			sonicbg.y = Std.int(FlxG.height - sonicbg.height);
			sonicbg.alpha = 0.6;
			sonicbg.antialiasing = false;
			sonicbg.x += Std.int(((i * 2) - 1) * 15);
			add(sonicbg);
		}

		var vssonicexe:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/majin/vssonicexe.png'));
		vssonicexe.scale.set(3, 3);
		vssonicexe.updateHitbox();
		vssonicexe.antialiasing = false;
		vssonicexe.setPosition(Std.int(FlxG.width / 2), 90);
		add(vssonicexe);

		var regionbar:FlxSprite = new FlxSprite(0, 643).makeGraphic(Std.int((FlxG.width / 2)), 39, 0xFF000000);
		add(regionbar);

		var regiontext:FlxSprite = new FlxSprite(196, 589).loadGraphic(Assets.getBitmapData('assets/exe/access/majin/regionselect.png'));
		regiontext.scale.set(3, 3);
		regiontext.updateHitbox();
		regiontext.antialiasing = false;
		add(regiontext);

		var backdrop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/access/majin/linemajin.png'), FlxAxes.Y);
		backdrop.scale.set(3, 3);
		backdrop.updateHitbox();
		backdrop.screenCenter();
		backdrop.velocity.y = -80;
		backdrop.antialiasing = false;
		add(backdrop);
		
		var box:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/majin/cuadro.png'));
		box.antialiasing = false;
		box.scale.set(1.5, 1.5);
		box.updateHitbox();
		box.screenCenter();
		box.setPosition(Std.int(box.x), Std.int(box.y));
		add(box);

		eggman = new FlxSprite(0, box.y + 60);
		eggman.frames = FlxAtlasFrames.fromSparrow('assets/exe/access/majin/eggman.png', 'assets/exe/access/majin/eggman.xml');
		eggman.animation.addByPrefix('idle', 'idle', 2, true);
		eggman.animation.play('idle');
		eggman.antialiasing = false;
		eggman.scale.set(3, 3);
		eggman.updateHitbox();
		eggman.screenCenter(X);
		eggman.x = Std.int(eggman.x);
		add(eggman);

		soundOne = new FlxSprite(0, eggman.y).loadGraphic(Assets.getBitmapData('assets/exe/access/majin/sound1.png'));
		soundOne.antialiasing = false;
		soundOne.scale.set(3, 3);
		soundOne.updateHitbox();
		soundOne.x = eggman.x + eggman.width + 30;
		add(soundOne);

		soundTwo = new FlxSprite(0, eggman.y).loadGraphic(Assets.getBitmapData('assets/exe/access/majin/sound2.png'));
		soundTwo.antialiasing = false;
		soundTwo.scale.set(3, 3);
		soundTwo.updateHitbox();
		soundTwo.x = eggman.x - soundTwo.width - 30;
		add(soundTwo);

		buttonUS = new FlxSprite(0, box.y + 216);
		buttonUS.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'));
		buttonUS.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'), true, Math.floor(buttonUS.width / 2), Math.floor(buttonUS.height / 2));
		buttonUS.animation.add('idle', [3]); buttonUS.animation.add('selected', [1]);
		buttonUS.animation.play('idle');
		buttonUS.antialiasing = false;
		buttonUS.scale.set(3, 3);
		buttonUS.updateHitbox();
		buttonUS.x = Std.int((FlxG.width / 2) + 90);
		add(buttonUS);

		buttonJP = new FlxSprite(0, box.y + 216);
		buttonJP.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'));
		buttonJP.loadGraphic(Assets.getBitmapData('assets/exe/access/majin/buttons.png'), true, Math.floor(buttonJP.width / 2), Math.floor(buttonJP.height / 2));
		buttonJP.animation.add('idle', [2]); buttonJP.animation.add('selected', [0]);
		buttonJP.animation.play('selected');
		buttonJP.antialiasing = false;
		buttonJP.scale.set(3, 3);
		buttonJP.updateHitbox();
		buttonJP.x = Std.int((FlxG.width / 2) - buttonJP.width - 90);
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
		if (subState != null) return;

		soundOne.y = eggman.y + (eggman.animation.curAnim.curFrame == 0 ? 3 : -3);
		soundTwo.y = eggman.y + (eggman.animation.curAnim.curFrame == 1 ? 3 : -3);

		if (!transitioning)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new EXEMenu());
				FlxG.sound.music.fadeOut(0.3);
				transitioning = true;
			}

			if (controls.UI_LEFT_P || controls.UI_RIGHT_P || FlxG.mouse.deltaWheel.y != 0)
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
			if (controls.ACCEPT || (FlxG.mouse.overlaps(daButton) && FlxG.mouse.justPressed))
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('majinfreeplay'));
				FlxTween.tween(blackBG, {alpha: 1}, 1);
				FlxTween.num(1, -0.1, 0.9, function(num) {
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