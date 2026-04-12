package states.access;

import backend.Song;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;

class FridgeAccess extends MusicBeatState
{
	var vanilla:FlxSprite;
	var chocolate:FlxSprite;
	var mustard:FlxSprite;
	var amongus:FlxSprite;

	var whiteBG:FlxSprite;
	var daOffset:Array<Float> = [0,0];
	var camFollow:FlxObject;

	//var ref:FlxSprite;
	//var object:FlxSprite;

	var transitioning:Bool = true;
	var toSong:Bool = false;
	override function create()
	{
		super.create();

		CustomShapeTransition.shape = SUNKY;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/wall.png'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scale.set(0.51, 0.51);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var gang:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/the gang.png'));
		gang.antialiasing = ClientPrefs.data.antialiasing;
		gang.scale.set(0.52, 0.52);
		gang.updateHitbox();
		gang.setPosition(57, 41);
		add(gang);

		var frige:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/frige.png'));
		frige.antialiasing = ClientPrefs.data.antialiasing;
		frige.scale.set(0.521, 0.521);
		frige.updateHitbox();
		frige.setPosition(354, 14);
		add(frige);

		var paper:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/paper.png'));
		paper.antialiasing = ClientPrefs.data.antialiasing;
		paper.scale.set(0.52, 0.52);
		paper.updateHitbox();
		paper.setPosition(536, 486);
		add(paper);

		vanilla = new FlxSprite();
		vanilla.frames = FlxAtlasFrames.fromSparrow('assets/exe/access/fridge/Vanilla-Milk.png', 'assets/exe/access/fridge/Vanilla-Milk.xml');
		vanilla.animation.addByPrefix('idle', 'vanilla instancia 1', 24, false);
		vanilla.animation.addByPrefix('selected', 'vanilla selected instancia 1', 24, false);
		vanilla.animation.play('idle');
		vanilla.antialiasing = ClientPrefs.data.antialiasing;
		vanilla.scale.set(0.52, 0.52);
		vanilla.updateHitbox();
		vanilla.setPosition(446, 470);
		add(vanilla);

		chocolate = new FlxSprite();
		chocolate.frames = FlxAtlasFrames.fromSparrow('assets/exe/access/fridge/Choco-Milk.png', 'assets/exe/access/fridge/Choco-Milk.xml');
		chocolate.animation.addByPrefix('idle', 'chocolate instancia 1', 24, false);
		chocolate.animation.addByPrefix('selected', 'chocolate selected instancia 1', 24, false);
		chocolate.animation.play('idle');
		chocolate.antialiasing = ClientPrefs.data.antialiasing;
		chocolate.scale.set(0.52, 0.52);
		chocolate.updateHitbox();
		chocolate.setPosition(697, 461);
		add(chocolate);

		mustard = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/MUSTARD.png'));
		mustard.antialiasing = ClientPrefs.data.antialiasing;
		mustard.scale.set(0.52, 0.52);
		mustard.updateHitbox();
		mustard.setPosition(643, 546);
		add(mustard);
		
		var sushi:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/sushi.png'));
		sushi.antialiasing = ClientPrefs.data.antialiasing;
		sushi.scale.set(0.52, 0.52);
		sushi.updateHitbox();
		sushi.setPosition(430, 703);
		add(sushi);

		var flower:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/flower.png'));
		flower.antialiasing = ClientPrefs.data.antialiasing;
		flower.scale.set(0.52, 0.52);
		flower.updateHitbox();
		flower.setPosition(529, 698);
		add(flower);

		amongus = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/amongus.png'));
		amongus.antialiasing = ClientPrefs.data.antialiasing;
		amongus.scale.set(0.52, 0.52);
		amongus.updateHitbox();
		amongus.setPosition(604, 814);
		add(amongus);

		var tv:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/tv.png'));
		tv.antialiasing = ClientPrefs.data.antialiasing;
		tv.scale.set(0.52, 0.52);
		tv.updateHitbox();
		tv.setPosition(625, 685);
		add(tv);

		var doordown:FlxSprite = new FlxSprite();
		doordown.frames = FlxAtlasFrames.fromSparrow('assets/exe/access/fridge/door.png', 'assets/exe/access/fridge/door.xml');
		doordown.animation.addByPrefix('idle', 'door instancia 1', 24, false);
		doordown.animation.play('idle');
		doordown.antialiasing = ClientPrefs.data.antialiasing;
		doordown.scale.set(0.52, 0.52);
		doordown.updateHitbox();
		doordown.setPosition(71, 426);
		add(doordown);

		var doorup:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/door up.png'));
		doorup.antialiasing = ClientPrefs.data.antialiasing;
		doorup.scale.set(0.52, 0.52);
		doorup.updateHitbox();
		doorup.setPosition(381, 62);
		add(doorup);

		var sunkyhand:FlxSprite = new FlxSprite();
		sunkyhand.frames = FlxAtlasFrames.fromSparrow('assets/exe/access/fridge/sunky-hand.png', 'assets/exe/access/fridge/sunky-hand.xml');
		sunkyhand.animation.addByPrefix('idle', 'sunky hand instancia 1', 24, false);
		sunkyhand.animation.play('idle');
		sunkyhand.animation.paused = true;
		sunkyhand.animation.finishCallback = function(name:String) {sunkyhand.visible = false;};
		sunkyhand.antialiasing = ClientPrefs.data.antialiasing;
		sunkyhand.scale.set(0.52, 0.52);
		sunkyhand.updateHitbox();
		sunkyhand.setPosition(30, 327);
		add(sunkyhand);

		new FlxTimer().start(0.5, function(tmr:FlxTimer){
			doordown.animation.play('idle');
			new FlxTimer().start(0.5, function(tmr:FlxTimer){
				sunkyhand.animation.play('idle');
				new FlxTimer().start(1, function(tmr:FlxTimer){
					FlxTween.tween(FlxG.camera, {zoom: 1.63}, 1, {ease: FlxEase.cubeInOut, onComplete: function (_) {transitioning = false;}});
					FlxTween.num(0, 100, 1.75, function(num) {daOffset[0] = num * -0.17;});
					FlxTween.num(0, 100, 0.5, function(num) {daOffset[1] = num * 2.76;});
				});
			});
		});

		var shit:FlxSprite = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/shit.png'));
		shit.antialiasing = ClientPrefs.data.antialiasing;
		shit.scale.set(0.52, 0.52);
		shit.updateHitbox();
		shit.setPosition(893, 433);
		add(shit);

		/*ref = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/access/fridge/ref inside.png'));
		ref.setGraphicSize(1280, 720);
		ref.updateHitbox();
		ref.alpha = 0.5;
		ref.scrollFactor.set();
		add(ref);*/

		whiteBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		whiteBG.alpha = 0;
		whiteBG.scrollFactor.set();
		whiteBG.screenCenter();
		add(whiteBG);

		FlxG.sound.playMusic(Assets.getSound('assets/exe/access/fridge/sunky.ogg'), 0.8);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		FlxG.camera.follow(camFollow, null, 0.1);

		//object = doorup;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		//ref.setGraphicSize(Std.int(1280 / FlxG.camera.zoom), Std.int(720 / FlxG.camera.zoom));
		//ref.updateHitbox();
		//ref.screenCenter();

		if (!transitioning)
		{
			if (Controls.instance.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.sound.music.fadeOut(0.3);
				FlxG.switchState(() -> new EXEMenu());
				transitioning = true;
			}
			
			if (FlxG.mouse.overlaps(mustard) && FlxG.mouse.justPressed) FlxG.sound.play(Paths.sound('mustard'));
			if (FlxG.mouse.overlaps(amongus) && FlxG.mouse.justPressed) FlxG.sound.play(Paths.sound('amogus'));

			vanilla.animation.play('idle', true);
			if (FlxG.mouse.overlaps(vanilla))
			{
				vanilla.animation.play('selected', true);

				if(FlxG.mouse.justPressed || Controls.instance.ACCEPT)
				{
					transitioning = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(whiteBG, {alpha: 1}, 1);
					FlxTween.tween(FlxG.camera, {zoom: 2.5}, 1.15, {ease: FlxEase.expoIn});
					if (loadSong('Vanilla Milk'))
					{
						new FlxTimer().start(1, function(tmr:FlxTimer){
							LoadingState.prepareToSong();
							LoadingState.loadAndSwitchState(new PlayState());
							FlxG.sound.music.fadeOut(0.3);
						});
					}
				}
			}
			vanilla.centerOffsets();
			vanilla.centerOrigin();
			if (vanilla.animation.curAnim.name == 'selected') vanilla.offset.y -= 0.1;

			chocolate.animation.play('idle', true);
			if (FlxG.mouse.overlaps(chocolate))
			{
				chocolate.animation.play('selected', true);

				if(FlxG.mouse.justPressed || Controls.instance.ACCEPT)
				{
					transitioning = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(whiteBG, {alpha: 1}, 1);
					FlxTween.tween(FlxG.camera, {zoom: 2.5}, 1.15, {ease: FlxEase.expoIn});
					if (loadSong('Chocolate Milk'))
					{
						new FlxTimer().start(1, function(tmr:FlxTimer){
							LoadingState.prepareToSong();
							LoadingState.loadAndSwitchState(new PlayState());
							FlxG.sound.music.fadeOut(0.3);
						});
					}
				}
			}
			chocolate.centerOffsets();
			chocolate.centerOrigin();
			if (chocolate.animation.curAnim.name == 'selected') chocolate.offset.set(chocolate.offset.x + 0.1, chocolate.offset.y - 0.2);
		}

		camFollow.setPosition(
			FlxG.width / 2 + (((FlxG.mouse.getScreenPosition().x - (FlxG.width / 2)) / (FlxG.width / 2)) * 5) + daOffset[0],
			FlxG.height / 2 + (((FlxG.mouse.getScreenPosition().y - (FlxG.height / 2)) / (FlxG.height / 2)) * 5) + daOffset[1]
		);
	}

	function loadSong(milk:String):Bool
	{
		try
		{
			Mods.currentModDirectory = 'SUNKY';

			var firstSong:String = Paths.formatToSongPath(milk);
			Song.loadFromJson(firstSong, firstSong);

			PlayState.storyPlaylist = [milk];
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
		if (!toSong) {
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
			CustomShapeTransition.shape = HEAD;
		}
		super.destroy();
	}
}