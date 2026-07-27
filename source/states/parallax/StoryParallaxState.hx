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

	public static var fromParallax:Bool = false;
	public static var fromSong:Bool = false;
	override function create()
	{
		super.create();

		backend.EXEAchievements.unlock('parallax');
		backend.EXEAchievements.checkFinale();
		backend.EXEAchievements.save();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/story mode/1.webp'));
		bg.scale.set(0.34, 0.34);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var tables:FlxSprite = new FlxSprite(0, 80).loadGraphic(Paths.getBitmapData('assets/exe/parallax/story mode/2.webp'));
		tables.scale.set(0.34, 0.34);
		tables.updateHitbox();
		tables.screenCenter(X);
		add(tables);

		megadrive = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/story mode/consola.webp'));
		megadrive.scale.set(0.9, 0.9);
		megadrive.updateHitbox();
		megadrive.screenCenter(X);
		megadrive.y = FlxG.height - megadrive.height - 20;
		add(megadrive);

		mdcd = new FlxSprite(megadrive.x + 752, megadrive.y + 82);
		mdcd.frames = FlxAtlasFrames.fromSparrow('assets/exe/parallax/story mode/cd.webp', 'assets/exe/parallax/story mode/cd.xml');
		mdcd.animation.addByPrefix('idle', 'idle instancia 1', 24, true);
		mdcd.animation.addByPrefix('selected', 'cd instancia 1', 24, false);
		mdcd.animation.play('idle');
		mdcd.scale.set(0.9, 0.9);
		mdcd.updateHitbox();
		add(mdcd);

		cd = new FlxSprite(914, 126);
		cd.frames = FlxAtlasFrames.fromSparrow('assets/exe/parallax/story mode/educador.webp', 'assets/exe/parallax/story mode/educador.xml');
		cd.animation.addByPrefix('idle', 'ecuador idle instancia 1', 24, true);
		cd.animation.addByPrefix('selected', 'ecuador instancia 1', 24, false);
		cd.animation.play('idle');
		cd.scale.set(0.9, 0.9);
		cd.updateHitbox();
		add(cd);

		luz = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/parallax/story mode/luz.webp'));
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

		if (fromSong) FlxG.sound.playMusic(Assets.getSound('assets/exe/music/parallax.ogg'));
		fromSong = false;
	}
	
	var activateOnce:Bool = true;
	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (subState != null) return;

		luz.alpha = FlxG.random.float(0.85,1);

		if (!transitioning)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new ParallaxState());
				transitioning = true;
			}

			if (controls.ACCEPT)
			{
				transitioning = true;
				mdcd.animation.play('selected');
				mdcd.offset.set(mdcd.offset.x + 14.5, mdcd.offset.y + 222.3);
				cd.animation.play('selected');
				cd.offset.set(cd.offset.x + 51.5, cd.offset.y + 174);

				if(FlxG.sound.music != null)
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
					if(FlxG.sound.music != null)
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

			fromSong = true;
			StoryParallaxState.fromParallax = true;
		}
		catch (e:Dynamic)
		{
			trace("Error cargando cancion: " + e);
			return false;
		}
		return true;
	}
}