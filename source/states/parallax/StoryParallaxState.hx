package states.parallax;

import backend.WeekData;
import backend.Song;
import backend.Highscore;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;

class StoryParallaxState extends MusicBeatState
{
	var megadrive:FlxSprite;
	var mdcd:FlxSprite;
	var cd:FlxSprite;
	var luz:FlxSprite;

	var whiteBG:FlxSprite;

	override function create()
	{
		super.create();
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/storyparallax.ogg'));

		var bg:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/story mode/1.png'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scale.set(0.34, 0.34);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var tables:FlxSprite = new FlxSprite(0, 80).loadGraphic(Assets.getBitmapData('assets/exe/parallax/story mode/2.png'));
		tables.antialiasing = ClientPrefs.data.antialiasing;
		tables.scale.set(0.34, 0.34);
		tables.updateHitbox();
		tables.screenCenter(X);
		add(tables);

		megadrive = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/story mode/consola.png'));
		megadrive.antialiasing = ClientPrefs.data.antialiasing;
		megadrive.scale.set(0.9, 0.9);
		megadrive.updateHitbox();
		megadrive.screenCenter(X);
		megadrive.y = FlxG.height - megadrive.height - 20;
		add(megadrive);

		mdcd = new FlxSprite();
		mdcd.frames = FlxAtlasFrames.fromSparrow('assets/exe/parallax/story mode/cd.png', 'assets/exe/parallax/story mode/cd.xml');
		mdcd.animation.addByPrefix('idle', 'idle instancia 1', 24, true);
		mdcd.animation.addByPrefix('selected', 'cd instancia 1', 24, false);
		mdcd.animation.play('idle');
		mdcd.antialiasing = ClientPrefs.data.antialiasing;
		mdcd.scale.set(0.9, 0.9);
		mdcd.updateHitbox();
		mdcd.setPosition(megadrive.x + 752, megadrive.y + 82);
		add(mdcd);

		cd = new FlxSprite(914, 126);
		cd.frames = FlxAtlasFrames.fromSparrow('assets/exe/parallax/story mode/educador.png', 'assets/exe/parallax/story mode/educador.xml');
		cd.animation.addByPrefix('idle', 'ecuador idle instancia 1', 24, true);
		cd.animation.addByPrefix('selected', 'ecuador instancia 1', 24, false);
		cd.animation.play('idle');
		cd.antialiasing = ClientPrefs.data.antialiasing;
		cd.scale.set(0.9, 0.9);
		cd.updateHitbox();
		add(cd);

		luz = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/parallax/story mode/luz.png'));
		luz.antialiasing = ClientPrefs.data.antialiasing;
		luz.scale.set(0.34, 0.34);
		luz.updateHitbox();
		luz.screenCenter();
		add(luz);

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		whiteBG.alpha = 0;
		whiteBG.screenCenter();
		add(whiteBG);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Parallax Menus", 'Checking Story Menu');
		#end
	}
	
	var activateOnce:Bool = true;
	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		luz.alpha = FlxG.random.float(0.85,1);

		if (!transitioning)
		{
			if (Controls.instance.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new ParallaxState());
				transitioning = true;
			}

			if (Controls.instance.ACCEPT)
			{
				transitioning = true;
				mdcd.animation.play('selected');
				mdcd.offset.set(mdcd.offset.x + 14.5, mdcd.offset.y + 222.3);
				cd.animation.play('selected');
				cd.offset.set(cd.offset.x + 51.5, cd.offset.y + 174);

				FlxG.sound.music.fadeOut(2);
			}
		}

		if (cd.animation.curAnim.curFrame >= 49 && cd.visible == true) cd.visible = false;
		if (mdcd.animation.curAnim.name == 'selected' && mdcd.animation.curAnim.finished && activateOnce)
		{
			activateOnce = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTween.tween(whiteBG, {alpha: 1}, 1);
			FlxTween.tween(FlxG.camera, {zoom: 2}, 1.15, {ease: FlxEase.expoIn});
			if (loadSong())
			{
				new FlxTimer().start(1, function(tmr:FlxTimer){
					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.stop();
				});
			}
		}
	}

	function loadSong():Bool
	{
		try
		{
			Mods.currentModDirectory = 'PARALLAX';

			var firstSong:String = 'expulsion';
			Song.loadFromJson(firstSong, firstSong);

			PlayState.storyPlaylist = ['Expulsion'];
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 0;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
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
		if (!transitioning)
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		super.destroy();
	}
}