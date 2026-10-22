package minigames.thevalley.cutscenes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import openfl.display.BlendMode;

import minigames.thevalley.character.player.ValleyInput;

@:access(minigames.thevalley.TheValley)
class FinalCutscene
{
	public var onDone:Void->Void;
	public var skipping(default, null):Bool = false;

	final _game:TheValley;
	final _screen:FlxCamera;
	final _events:Array<{ t:Float, run:Void->Void }> = [];
	final _music:FlxSound;

	final _spot:FlxSprite;
	final _hands:FlxSprite;
	final _loop:minigames.thevalley.tiles.Tiles.LoopTile;
	final _bf:FlxSprite;
	final _bfGlow:FlxSprite;
	final _kiss:FlxSprite;
	final _heart:FlxSprite;
	final _balls:FlxSprite;
	final _faker:FlxSprite;
	final _mad:FlxSprite;
	final _hit:FlxSprite;
	final _metal:FlxSprite;
	final _carry:FlxSprite;

	final _black:FlxSprite;
	final _gfLooks:FlxSprite;
	final _bfBg:FlxSprite;
	final _bfIntro:FlxSprite;
	final _fakerPose:FlxSprite;
	final _white:FlxSprite;
	final _red:FlxSprite;
	final _skipText:FlxText;
	final _canSkip:Bool;

	final _sky = { x: 0.0, y: 0.0 };
	final _ghosts:Array<{ spr:FlxSprite, age:Float }> = [];

	var _time:Float = 0;
	var _next:Int = 0;
	var _follow:Bool = false;
	var _camFrom = { x: 0.0, y: 0.0, zoom: 1.0 };
	var _walk:{ from:Float, to:Float } = null;
	var _finished:Bool = false;
	var _carrySpeed:Float = -1;
	var _ghostTimer:Float = 0;
	var _skipShown:Float = 0;

	public function new(game:TheValley)
	{
		_game = game;
		final world = game.bgCam;

		_screen = new FlxCamera();
		_screen.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(_screen, false);

		_spot = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_spot.scrollFactor.set(0, 0);
		_put(_spot, world);

		_hands = _atlas('hands', world);
		_game.remove(_hands, true);
		_game.insert(_game.members.indexOf(_game.objectGroup), _hands);
		_anim(_hands, 'claw', 'hands0', [260, 180], true);
		_hands.color = 0xFFD2C8BE;
		_loop = game.tileMap.loops.length > 0 ? game.tileMap.loops[0] : _defaultLoop();

		_bf = _atlas('fakerbf', world);
		_anim(_bf, 'sleep', 'fakerbf0', [100], false, 1, 1);
		_bfGlow = _atlas('fakerbf', world);
		_anim(_bfGlow, 'sleep', 'fakerbf0', [100], false, 1, 1);
		_bfGlow.blend = BlendMode.ADD;
		_bfGlow.color = 0xFF55C8FF;
		_kiss = _atlas('gfbfkiss', world);
		_anim(_kiss, 'meet', 'gfbfkiss0', [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1000, 100, 100], false, 0, 14);
		_anim(_kiss, 'hug', 'gfbfkiss0', [100], false, 14, 3);
		_anim(_kiss, 'kiss', 'gfbfkiss0', [100], false, 17, 4);
		_heart = _atlas('heart', world);
		_anim(_heart, 'pop', 'heart', [100], false);
		_balls = _atlas('balls', world);
		_anim(_balls, 'appear', 'balls appear', [60], false);
		_anim(_balls, 'orbit', 'balls orbit', [70], true);
		_anim(_balls, 'gather', 'balls gather', [50], false);
		_anim(_balls, 'orbs', 'balls Tag', [50], true);

		_faker = _exe(world);
		_faker.animation.addByPrefix('faker', 'exe faker', 1, false);
		_faker.animation.addByPrefix('transform', 'exe transform', 14, false);
		_faker.animation.addByPrefix('takeoff', 'exe takeoff', 1, false);
		_faker.animation.addByPrefix('idle', 'exe idle', 1, false);
		_faker.animation.addByIndices('charge', 'exe charge', [0, 1], '', 10, true);
		_faker.animation.addByIndices('run', 'exe run', [0, 1, 2, 3, 4, 5], '', 16, true);
		_faker.animation.addByPrefix('air', 'exe airandfalling', 1, false);
		_faker.animation.addByIndices('landing', 'exe landing', [0, 1], '', 12, false);
		_anim(_faker, 'growIn', 'exe grow', [50], false, 0, 4);
		_anim(_faker, 'growLoop', 'exe grow', [150], true, 4, 2);
		_anim(_faker, 'growUp', 'exe grow', [168], false, 6, 5);
		_anim(_faker, 'growBurst', 'exe grow', [104], false, 11, 11);
		_anim(_faker, 'growEnd', 'exe grow', [100], false, 22, 1);
		_mad = _exe(world);
		_anim(_mad, 'leave', 'exe mad', [40, 100, 40, 100, 40, 100, 40, 40, 40], false, 6);
		_hit = _atlas('metalhit', world);
		_anim(_hit, 'hit', 'metalhit Final', [100], true);
		_metal = _atlas('jake', world);
		_anim(_metal, 'fly', 'jake Loop', [50], true);
		_anim(_metal, 'fall', 'jake0', [100], false, 0, 1);
		_anim(_metal, 'stand', 'jake0', [100], false, 1, 1);
		_anim(_metal, 'look', 'jake0', [100], false, 2, 2);
		_anim(_metal, 'burst', 'jake0', [50], true, 5, 2);
		_carry = _atlas('jakebfgf', world);
		_anim(_carry, 'run', 'jakebfgf0', [100], true);

		_black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_put(_black, _screen);
		_gfLooks = new FlxSprite(0, 0, Paths.image('minigame/thevalley/bg/cutscene/Final/gflooksbf'));
		_put(_gfLooks, _screen);
		_screenSprite(_gfLooks, 3);
		_bfBg = _atlas('bfintrobg', _screen);
		_anim(_bfBg, 'rays', 'bfintrobg0', [for (i in 0...165) i < 164 ? 60 : 1000], false);
		_screenSprite(_bfBg, 4);
		_bfIntro = _atlas('bfintro', _screen);
		_anim(_bfIntro, 'calm', 'bfintro Tag', [100], true);
		_anim(_bfIntro, 'closed', 'bfintro0', [100], false, 2, 1);
		_screenSprite(_bfIntro, 4);
		_fakerPose = _atlas('Faker Pose', _screen);
		_screenSprite(_fakerPose, 4);
		_white = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		_put(_white, _screen);
		_red = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF9A0000);
		_put(_red, _screen);
		_red.visible = true;
		_red.alpha = 0;

		_spot.visible = true;
		_spot.alpha = 0;
		_black.visible = true;
		_black.alpha = 0;

		_hideGame();
		_build();
		_events.sort((a, b) -> Reflect.compare(a.t, b.t));

		_canSkip = FlxG.save.data.tvFinalSeen == true;
		_skipText = new FlxText(0, FlxG.height - 44, FlxG.width - 24, "PRESS SPACE TO SKIP CUTSCENE", 20);
		_skipText.font = "assets/fonts/SonicFont.ttf";
		_skipText.alignment = FlxTextAlign.RIGHT;
		_skipText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 2);
		_skipText.antialiasing = false;
		_skipText.cameras = [_screen];
		_skipText.alpha = 0;
		_skipText.visible = false;
		_game.add(_skipText);

		_music = FlxG.sound.play(Paths.sound('minigame/thevalley/finalcutscene'), 1.0);
	}

	public static function preload():Void
	{
		for (name in ['hands', 'fakerbf', 'gfbfkiss', 'heart', 'balls', 'metalhit', 'jake', 'jakebfgf', 'bfintrobg', 'bfintro', 'Faker Pose'])
			Paths.getSparrowAtlas('minigame/thevalley/bg/cutscene/Final/' + name);
		Paths.image('minigame/thevalley/bg/cutscene/Final/gflooksbf');
		Paths.sound('minigame/thevalley/finalcutscene');
	}

	function _hideGame():Void
	{
		final g = _game;
		g.player.cinematic = false;
		g.player.sparkle.visible = false;
		g.player.sparkleGlow.visible = false;
		g.hud.timerRunning = false;
		g.hud.setVisible(false);
		for (m in g.monsters) m.sprite.visible = false;
		for (t in g.tileMap.tiles) if (t.x > 9700) t.visible = false;
		g.bg.skyOffset(0, 0);
		g.bg.eclipseOffset(_sky.x, _sky.y);
	}

	function _build():Void
	{
		final ground = 138.0;
		final p = _game.player;
		final gfStart = p.body.position.x;
		final gfStop = gfStart + 288;
		final bfX = gfStop + 22;
		final kissX = bfX - 16;
		final loopX = _loop.x;
		final loopTop = _loop.y;
		final rubbleX = loopX + 140;
		final rubbleGround = loopTop + 216;
		final ledge = loopTop + 6;
		final fakerX = loopX + 150;

		_at(0, () -> {
			_feet(_bf, bfX, ground, 16, 36);
			_bf.visible = true;
			_bf.animation.play('sleep');
			final cam = _game.gameCamera;
			_camFrom = { x: cam.x, y: cam.y, zoom: cam.zoom };
			_walk = { from: gfStart, to: gfStop };
			_follow = true;
		});
		_at(4.8, () -> {
			_follow = false;
			_walk = null;
			p.body.velocity.x = 0;
			p.animation.addByIndices('stopconfused', 'fakergf looking', [4], '', 1, false);
			p.lockedAnim = 'stopconfused';
			_look((gfStop + bfX) * 0.5 + 6, 80, 4, 0.8, FlxEase.sineOut);
		});
		_at(9.5, () -> {
			_game.remove(p, true);
			_game.add(p);
			_game.remove(_balls, true);
			_game.add(_balls);
			p.animation.addByIndices('crouchlook', 'fakergf searching', [0], '', 1, false);
			p.lockedAnim = 'crouchlook';
			FlxTween.tween(_spot, { alpha: 1 }, 0.45);
		});
		_at(5.6, () -> _look((gfStop + bfX) * 0.5 + 4, 84, 4.4, 3.9, FlxEase.sineInOut));
		_at(10.0, () -> _look(bfX - 6, 112, 4.8, 2.3, FlxEase.sineInOut));
		_at(27.85, () -> _punch(0.25, 0.4));
		_at(32.5, () -> _look(bfX - 10, 104, 4.6, 2.5, FlxEase.sineInOut));
		_at(54.6, () -> _look(kissX + 6, 88, 4.6, 3.6, FlxEase.sineInOut));
		_at(58.2, () -> _punch(0.2, 0.5));
		_at(64.9, () -> _look(fakerX + 30, ledge - 22, 4.5, 1.3, FlxEase.sineInOut));
		_at(74.2, () -> _look(fakerX + 25, ledge - 26, 4.4, 1.3, FlxEase.sineInOut));
		_at(75.5, () -> _look(fakerX + 10, ledge - 28, 5.2, 0.45, FlxEase.quadIn));
		_at(76.0, () -> _punch(0.3, 0.35));
		_at(76.6, () -> _look(fakerX + 30, ledge - 32, 4.6, 1.1, FlxEase.sineInOut));
		_at(78.0, () -> _look(fakerX + 60, ledge - 68, 4.2, 0.6, FlxEase.quadOut));
		_at(78.7, () -> _look(fakerX + 80, ledge - 58, 3.8, 2.6, FlxEase.sineInOut));
		_at(82.6, () -> _look(kissX + 12, 84, 4.4, 5.6, FlxEase.sineInOut));
		_at(88.3, () -> _look(kissX - 40, 80, 3.9, 0.4, FlxEase.quadOut));
		_at(94.0, () -> _look(kissX - 175, 80, 4, 0.7, FlxEase.quadOut));
		_at(95.2, () -> _look(kissX - 200, 84, 4.4, 1.6, FlxEase.sineInOut));
		_at(96.9, () -> _look(kissX - 215, 86, 4.8, 0.35, FlxEase.quadOut));
		_at(104.2, () -> _look(rubbleX, rubbleGround - 58, 4.2, 3.2, FlxEase.sineInOut));
		_at(107.5, () -> _look(rubbleX, rubbleGround - 66, 4.8, 0.6, FlxEase.quadOut));
		_at(109.6, () -> _look(rubbleX + 4, rubbleGround - 62, 4.3, 0.8, FlxEase.sineInOut));
		_at(110.5, () -> _look(rubbleX + 6, rubbleGround - 92, 4.0, 0.45, FlxEase.quadOut));
		_at(110.95, () -> _look(rubbleX + 10, rubbleGround - 76, 4.2, 0.45, FlxEase.quadIn));
		_at(111.4, () -> _punch(0.25, 0.4));
		_at(112.0, () -> _look(rubbleX + 10, rubbleGround - 78, 5.0, 3.0, FlxEase.sineInOut));
		_at(115.94, () -> _look(rubbleX + 10, rubbleGround - 74, 4.1, 0.25, FlxEase.quadOut));
		_at(117.2, () -> _look(rubbleX + 10, rubbleGround - 90, 4.9, 3.2, FlxEase.sineInOut));
		_at(120.47, () -> _look(rubbleX + 40, rubbleGround - 74, 4.2, 0.6, FlxEase.quadOut));
		_at(122.0, () -> _look(rubbleX + 20, rubbleGround - 68, 3.9, 2.8, FlxEase.sineInOut));

		_at(12.33, () -> {
			_black.alpha = 1;
			_screen.zoom = 1;
			FlxTween.tween(_screen, { zoom: 1.07 }, 13.17, { ease: FlxEase.sineInOut });
			_gfLooks.visible = true;
			_gfLooks.setPosition(394, 13);
			FlxTween.tween(_gfLooks, { x: 40 }, 13.17);
		});
		_at(25.5, () -> {
			FlxTween.cancelTweensOf(_screen, ['zoom']);
			_screen.zoom = 1;
			_gfLooks.visible = false;
			_black.alpha = 0;
		});

		_at(27.8, () -> p.lockedAnim = 'searchreward');
		_at(28.4, () -> p.lockedAnim = 'searchingwin');
		_at(30.0, () -> {
			_balls.setPosition(p.x - p.offset.x + 28 - 40, p.y - p.offset.y + 6 - 30);
			_balls.visible = true;
			_balls.alpha = 1;
			_balls.animation.play('appear');
		});
		_at(30.72, () -> _balls.animation.play('orbit'));
		_at(32.0, () -> _balls.animation.play('gather'));
		_at(32.5, () -> {
			_balls.animation.play('orbs');
			FlxTween.tween(_balls, { x: p.x - p.offset.x + 28 - 40, y: p.y - p.offset.y + 10 - 30 }, 0.6, { ease: FlxEase.sineOut });
		});
		_at(33.1, () -> FlxTween.tween(_balls, { x: _balls.x + 6, y: _balls.y - 6 }, 3.9, { ease: FlxEase.sineInOut }));
		_at(35.0, () -> _look(bfX, 121, 5.2, 5.0, FlxEase.sineInOut));
		_at(37.0, () -> FlxTween.tween(_balls, { x: _bf.x + 16 - 40, y: _bf.y + 24 - 30 }, 2.8, { ease: FlxEase.sineInOut }));
		for (i in 0...9) _at(39.4 + i * 0.1, () -> _sparkle(_bf.x + 16 + FlxG.random.float(-10, 10), _bf.y + 20 + FlxG.random.float(-6, 8)));
		_at(39.4, () -> {
			_bfGlow.setPosition(_bf.x, _bf.y);
			_bfGlow.visible = true;
			_bfGlow.alpha = 0;
			FlxTween.tween(_bfGlow, { alpha: 0.9 }, 0.8, { ease: FlxEase.quadIn });
			FlxTween.tween(_balls, { alpha: 0 }, 0.6);
		});
		_at(40.3, () -> {
			_white.visible = true;
			_white.alpha = 0;
			FlxTween.tween(_white, { alpha: 1 }, 0.12);
		});
		_at(40.45, () -> {
			p.visible = false;
			_balls.visible = _bfGlow.visible = false;
			_look(kissX + 20, 80, 4);
		});

		_at(42.46, () -> {
			_white.alpha = 0;
			_bfBg.visible = true;
			_bfBg.animation.play('rays');
			_bfIntro.visible = true;
			_bfIntro.animation.play('closed');
			_bfIntro.setPosition(434, 720);
			FlxTween.tween(_bfIntro, { y: 268 }, 1.4, { ease: FlxEase.expoOut });
		});
		_at(43.3, () -> {
			_bfIntro.animation.play('calm');
			_screen.zoom = 1.05;
			FlxTween.tween(_screen, { zoom: 1 }, 0.4, { ease: FlxEase.quadOut });
			_white.alpha = 0.35;
			FlxTween.tween(_white, { alpha: 0 }, 0.4);
		});
		var beat = 42.41;
		while (beat < 51.8)
		{
			if (beat > 43.5) _at(beat, () -> _bop(1.012, 0.3));
			beat += 0.41418;
		}
		_at(51.9, () -> {
			FlxTween.tween(_white, { alpha: 1 }, 0.15);
		});

		_at(53.8, () -> {
			_bfBg.visible = _bfIntro.visible = false;
			_spot.alpha = 0;
			_bf.visible = false;
			_feet(_kiss, kissX, ground, 28, 46);
			_kiss.visible = true;
			_kiss.animation.play('meet');
			_look(kissX + 20, 80, 4);
			FlxTween.tween(_white, { alpha: 0 }, 0.8, { ease: FlxEase.quadOut });
		});
		_at(56.1, () -> _kiss.animation.play('hug'));
		_at(57.9, () -> _kiss.animation.play('kiss'));
		_at(58.2, () -> {
			_heart.setPosition(kissX - 4.5, ground - 65);
			_heart.visible = true;
			_heart.animation.play('pop', true);
		});
		_at(59.0, () -> _heart.visible = false);
		_at(61.0, () -> {
			_feet(_faker, fakerX, ledge, 65.5, 97);
			_faker.visible = true;
			_faker.animation.play('faker');
			_look(fakerX + 50, ledge - 30, 4, 3.8, FlxEase.smootherStepInOut);
			_skyTo(100, 22, 3.8);
		});

		_at(66.25, () -> {
			_look(fakerX + 50, ledge - 378, 4);
			_skyTo(250, 40, 0);
			_game.bg.showParallax(false);
			_game.bg.sun.visible = false;
			_fakerPose.visible = true;
			_fakerPose.animation.frameIndex = 0;
			_fakerPose.setPosition(-214, -640);
			FlxTween.tween(_fakerPose, { y: -160 }, 3.25, { ease: FlxEase.sineInOut });
		});
		_at(69.5, () -> FlxTween.num(4, 4.5, 4.29, { ease: FlxEase.sineIn }, s -> {
			_fakerPose.scale.set(s, s);
			_fakerPose.setPosition(640 - 213 * s, 360 - 130 * s);
		}));
		_at(71.5, () -> _fakerPose.animation.frameIndex = 1);
		_at(71.6, () -> _fakerPose.animation.frameIndex = 2);
		_at(73.79, () -> {
			_fakerPose.visible = false;
			_game.bg.showParallax(true);
			_game.bg.sun.visible = true;
			_look(fakerX + 50, ledge - 30, 4);
			_skyTo(100, 22, 0);
		});
		_at(75.5, () -> _faker.animation.play('transform'));
		_at(76.0, () -> {
			_redFlash(0.45, 0.6);
			_faker.animation.play('idle');
			_game.gameCamera.shake(0.004, 0.4);
		});
		_at(77.75, () -> _faker.animation.play('charge'));
		_at(78.0, () -> {
			_faker.animation.play('takeoff');
			_game.gameCamera.shake(0.003, 0.15);
			final x0 = _faker.x;
			final y0 = _faker.y;
			FlxTween.num(0, 1, 0.55, { onComplete: _ -> _faker.visible = false }, k -> _faker.setPosition(x0 + 70 * k, y0 - 260 * k + 60 * k * k));
		});
		_at(81.6, () -> {
			_look(kissX + 20, 80, 4, 0.9, FlxEase.sineInOut);
			_skyTo(0, 0, 0.9);
		});

		_at(84.0, () -> _game.gameCamera.shake(0.008, 0.35));
		_at(84.2, () -> {
			_feet(_faker, kissX - 1146, ground, 63.5, 97);
			_faker.visible = true;
			_faker.flipX = false;
			_faker.animation.play('run');
			FlxTween.tween(_faker, { x: kissX - 100 - 63.5 }, 4.55);
		});
		_at(88.3, () -> {
		});
		_at(88.5, () -> {
			_feet(_metal, kissX + 200, ground - 12, 23.5, 41);
			_metal.visible = true;
			_metal.animation.play('burst');
			FlxTween.tween(_metal, { x: kissX - 90 - 23.5 }, 0.25, { ease: FlxEase.quadIn });
		});
		_at(88.75, () -> {
			_sparks(kissX - 70, ground - 34, 14);
			_white.alpha = 0.5;
			FlxTween.tween(_white, { alpha: 0 }, 0.15);
			_faker.visible = _metal.visible = false;
			_feet(_hit, kissX - 100, ground, 39, 76);
			_hit.visible = true;
			_hit.animation.play('hit');
			_game.gameCamera.shake(0.006, 0.3);
			FlxTween.tween(_hit, { x: rubbleX - 39 }, 1.45, { ease: FlxEase.quadIn });
			_look(rubbleX + 40, rubbleGround - 58, 4, 1.45, FlxEase.sineInOut);
		});
		_at(90.2, () -> {
			_debris(rubbleX, rubbleGround - 110, 22, 1.3);
			for (i in 0...10) _dust(loopX + 20 + i * 24, rubbleGround, i * 0.03);
			_hit.visible = false;
			_white.alpha = 1;
			FlxTween.tween(_white, { alpha: 0 }, 0.25);
			_loop.collapse();
			_game.gameCamera.shake(0.012, 0.6);
			_feet(_metal, rubbleX, rubbleGround - 60, 23, 41);
			_metal.visible = true;
			_metal.animation.play('fall');
			_metal.flipY = true;
			FlxTween.tween(_metal, { x: _metal.x + 140, y: _metal.y - 220 }, 0.9, { ease: FlxEase.quadOut, onComplete: _ -> {
				_metal.visible = false;
				_metal.flipY = false;
			} });
		});

		_at(93.9, () -> {
			_look(kissX - 170, 60, 4);
			_feet(_metal, kissX - 425, ground - 210, 23, 41);
			_metal.flipX = true;
			_metal.visible = true;
			_metal.animation.play('fall');
			FlxTween.tween(_metal, { x: _metal.x + 150, y: _metal.y + 210 }, 0.55, { ease: FlxEase.quadIn, onComplete: _ -> {
				_metal.animation.play('stand');
				_game.gameCamera.shake(0.004, 0.2);
				FlxTween.tween(_metal, { x: _metal.x + 45 }, 0.45, { ease: FlxEase.quadOut });
				for (i in 0...8) _dust(_metal.x + 23 + i * 6, ground, i * 0.055);
			} });
		});
		_at(96.9, () -> _metal.animation.play('look'));
		_at(97.5, () -> _look(kissX + 20, 80, 4, 1.0, FlxEase.sineInOut));
		_at(100.5, () -> {
			_metal.flipX = true;
			_metal.animation.play('fly');
			FlxTween.tween(_metal, { x: kissX - 23.5 }, 0.3, { ease: FlxEase.quadIn });
			_look(kissX + 190, 80, 4, 1.0, FlxEase.sineInOut);
		});
		_at(100.8, () -> {
			_game.gameCamera.shake(0.004, 0.2);
			for (i in 0...6) _dust(kissX - 10 - i * 5, ground, i * 0.03);
			_metal.visible = _kiss.visible = false;
			_feet(_carry, kissX, ground, 22.5, 42);
			_carry.visible = true;
			_carry.animation.play('run');
			_carrySpeed = 0;
		});

		_at(91.1, () -> _loop.y = loopTop + 16);
		_at(104.12, () -> {
			_look(rubbleX, rubbleGround - 64, 3.7);
			_skyTo(0, 0, 0);
		});
		_at(107.5, () -> _claw(_hands, rubbleX, rubbleGround - 45));
		_at(109.6, () -> FlxTween.tween(_hands, { y: _hands.y + 46 }, 0.25, { ease: FlxEase.quadIn, onComplete: _ -> _hands.visible = false }));
		_at(110.5, () -> {
			_game.gameCamera.shake(0.01, 0.35);
			_debris(rubbleX, rubbleGround - 44, 16, 1.0);
			for (i in 0...6) _dust(rubbleX - 15 + i * 6, rubbleGround - 40, i * 0.03);
			_faker.visible = true;
			_faker.flipX = false;
			_exePose('takeoff', rubbleX, rubbleGround - 34);
			FlxTween.num(0, 1, 0.9, null, k -> {
				if (k >= 0.5 && _faker.animation.curAnim.name == 'takeoff') _faker.animation.play('air');
				_feet(_faker, rubbleX + 10 * k, rubbleGround - 34 + (-6) * k - 280 * k * (1 - k), 65.5, 97);
			});
		});
		_at(111.4, () -> {
			_exePose('landing', rubbleX + 10, rubbleGround - 40);
			_game.gameCamera.shake(0.007, 0.25);
			_debris(rubbleX + 10, rubbleGround - 40, 8, 0.5);
			for (i in 0...6) _dust(rubbleX + 10 + (i % 2 == 0 ? -1 : 1) * (6 + i * 3), rubbleGround - 40, i * 0.04);
		});
		_at(111.6, () -> _exePose('idle', rubbleX + 10, rubbleGround - 40));
		_at(112.82, () -> _exePose('growIn', rubbleX + 10, rubbleGround - 40));
		_at(113.02, () -> _exePose('growLoop', rubbleX + 10, rubbleGround - 40));
		for (i in 0...4) _at(113.1 + i * 0.5, () -> _redFlash(0.12 + i * 0.04, 0.35));
		_at(115.1, () -> _exePose('growUp', rubbleX + 10, rubbleGround - 40));
		_at(115.94, () -> {
			_redFlash(0.5, 1.0);
			_exePose('growBurst', rubbleX + 10, rubbleGround - 40);
			_game.gameCamera.shake(0.014, 0.6);
			_debris(rubbleX + 10, rubbleGround - 70, 14, 1.2);
			_white.alpha = 0.85;
			FlxTween.tween(_white, { alpha: 0 }, 0.5, { ease: FlxEase.quadOut });
		});
		_at(117.08, () -> {
			_exePose('growEnd', rubbleX + 10, rubbleGround - 40);
			_game.gameCamera.shake(0.004, 0.25);
		});
		_at(120.47, () -> {
			_faker.visible = false;
			_feet(_mad, rubbleX + 10, rubbleGround - 40, 94.5, 103);
			_mad.visible = true;
			_mad.animation.play('leave');
		});
		_at(120.93, () -> {
			_redFlash(0.3, 0.5);
			_game.gameCamera.shake(0.01, 0.3);
			_debris(rubbleX + 10, rubbleGround - 40, 10, 0.8);
		});
		_at(121.8, () -> _mad.visible = false);
		_at(124.8, () -> {
			_black.alpha = 0;
			FlxTween.tween(_black, { alpha: 1 }, 0.4);
		});
		_at(126.6, _finish);
	}

	public function update(elapsed:Float):Void
	{
		if (_finished) return;
		if (_canSkip && !skipping && _time > 0.5 && _time < 125 && ValleyInput.skip()) _skip();
		_skipShown = _canSkip && !skipping && _time < 125 ? Math.min(1, _skipShown + elapsed) : Math.max(0, _skipShown - elapsed * 4);
		_skipText.visible = _skipShown > 0;
		_skipText.alpha = _skipShown * (0.6 + 0.2 * Math.sin(_time * 3));
		if (skipping) return;
		_time = _music != null && _music.playing ? _music.time / 1000 : _time + elapsed;
		while (_next < _events.length && _events[_next].t <= _time)
			_events[_next++].run();
		final p = _game.player;
		if (_walk != null)
		{
			final k = Math.min(1, _time / 4.8) * Math.PI * 0.5;
			p.body.position.x = _walk.from + (_walk.to - _walk.from) * Math.sin(k);
			p.body.velocity.x = (_walk.to - _walk.from) * Math.PI * 0.5 / 4.8 * Math.cos(k);
		}
		if (_follow)
		{
			final e = FlxEase.sineInOut(Math.min(1, _time / 1.2));
			final tx = p.body.position.x + 30;
			_look(_camFrom.x + (tx - _camFrom.x) * e, _camFrom.y + (80 - _camFrom.y) * e, _camFrom.zoom + (4 - _camFrom.zoom) * e);
		}
		if (p.visible) p.updateAnim(elapsed);
		_updateCarry(elapsed);
		if (_hands.visible) _hands.offset.x = FlxG.random.int(-1, 1);
		_game.hud.update(elapsed);
	}

	function _updateCarry(elapsed:Float):Void
	{
		for (g in _ghosts)
		{
			if (!g.spr.visible) continue;
			g.age += elapsed;
			g.spr.alpha = 0.5 * Math.max(0, 1 - g.age / 0.2);
			if (g.age >= 0.2) g.spr.visible = false;
		}
		if (_carrySpeed < 0) return;
		_carrySpeed = Math.min(840, _carrySpeed + 5040 * elapsed);
		_carry.x += _carrySpeed * elapsed;
		_ghostTimer += elapsed;
		if (_ghostTimer >= 0.03)
		{
			_ghostTimer = 0;
			var g = null;
			for (o in _ghosts) if (!o.spr.visible) { g = o; break; }
			if (g == null)
			{
				final spr = new FlxSprite();
				spr.frames = _carry.frames;
				spr.antialiasing = false;
				spr.color = 0xFF5A78FF;
				spr.cameras = _carry.cameras;
				_game.insert(_game.members.indexOf(_carry), spr);
				g = { spr: spr, age: 0.0 };
				_ghosts.push(g);
			}
			g.spr.visible = true;
			g.spr.animation.frameIndex = _carry.animation.frameIndex;
			g.spr.setPosition(_carry.x, _carry.y);
			g.age = 0;
		}
		if (_carry.x > _game.bgCam.viewRight + 240)
		{
			_carrySpeed = -1;
			_carry.visible = false;
		}
	}

	function _exePose(anim:String, x:Float, y:Float):Void
	{
		final grow = StringTools.startsWith(anim, 'grow');
		_faker.animation.play(anim, true);
		_feet(_faker, x, y, grow ? 36 : 65.5, grow ? 104 : 97);
	}

	function _claw(hand:FlxSprite, x:Float, y:Float):Void
	{
		hand.setPosition(x - 41, y + 2);
		hand.visible = true;
		hand.animation.play('claw');
		FlxTween.tween(hand, { y: y - 38 }, 0.55, { ease: FlxEase.backOut });
		_game.gameCamera.shake(0.003, 0.2);
		_debris(x, y, 6, 0.5);
	}

	function _debris(x:Float, y:Float, count:Int, power:Float):Void
	{
		for (i in 0...count)
		{
			final size = FlxG.random.int(2, 4);
			final rock = new FlxSprite(x + FlxG.random.float(-12, 12), y).makeGraphic(size, size, FlxG.random.getObject([0xFF3E2A1E, 0xFF6B4A33, 0xFF8C6446, 0xFFA4805C]));
			rock.antialiasing = false;
			rock.cameras = [_game.bgCam];
			rock.velocity.set(FlxG.random.float(-110, 110) * power, -FlxG.random.float(90, 230) * power);
			rock.acceleration.y = 620;
			rock.angularVelocity = FlxG.random.float(-360, 360);
			_game.add(rock);
			FlxTween.tween(rock, { alpha: 0 }, 0.35, { startDelay: 0.45 + FlxG.random.float(0, 0.3), onComplete: _ -> _discard(rock) });
		}
	}

	function _punch(dz:Float, time:Float):Void
	{
		final c = _game.gameCamera;
		final x = c.x;
		final y = c.y;
		final z = c.zoom;
		_look(x, y, z + dz);
		_look(x, y, z, time, FlxEase.quadOut);
	}

	function _bop(zoom:Float, time:Float):Void
	{
		FlxTween.cancelTweensOf(_screen, ['zoom']);
		_screen.zoom = zoom;
		FlxTween.tween(_screen, { zoom: 1 }, time, { ease: FlxEase.quadOut });
	}

	function _redFlash(alpha:Float, time:Float):Void
	{
		FlxTween.cancelTweensOf(_red);
		_red.alpha = alpha;
		FlxTween.tween(_red, { alpha: 0 }, time, { ease: FlxEase.quadOut });
	}

	function _sparks(x:Float, y:Float, count:Int):Void
	{
		for (i in 0...count)
		{
			final spark = new FlxSprite(x, y).makeGraphic(2, 2, FlxG.random.getObject([0xFFFFFFFF, 0xFFFFE070, 0xFFFF9A2E]));
			spark.antialiasing = false;
			spark.blend = BlendMode.ADD;
			spark.cameras = [_game.bgCam];
			spark.velocity.set(FlxG.random.float(-200, 200), FlxG.random.float(-180, 60));
			spark.drag.set(220, 220);
			_game.add(spark);
			FlxTween.tween(spark, { alpha: 0 }, FlxG.random.float(0.25, 0.5), { onComplete: _ -> _discard(spark) });
		}
	}

	function _sparkle(x:Float, y:Float):Void
	{
		final s = new FlxSprite(x, y).makeGraphic(2, 2, 0xFF9FE9F9);
		s.antialiasing = false;
		s.blend = BlendMode.ADD;
		s.cameras = [_game.bgCam];
		s.velocity.y = -FlxG.random.float(14, 30);
		_game.add(s);
		FlxTween.tween(s, { alpha: 0 }, 0.6, { startDelay: 0.15, onComplete: _ -> _discard(s) });
	}

	function _discard(spr:FlxSprite):Void
	{
		_game.remove(spr, true);
		spr.destroy();
	}

	function _dust(x:Float, y:Float, delay:Float):Void
	{
		final puff = new FlxSprite(x - 2, y - 4).makeGraphic(4, 4, 0xFFB49C82);
		puff.antialiasing = false;
		puff.cameras = [_game.bgCam];
		puff.alpha = 0;
		_game.add(puff);
		FlxTween.tween(puff, { x: puff.x + FlxG.random.float(-4, 8), y: puff.y - FlxG.random.float(4, 9), alpha: 0.8 }, 0.12, { startDelay: delay, onComplete: _ ->
			FlxTween.tween(puff, { y: puff.y - 4, alpha: 0, "scale.x": 2, "scale.y": 2 }, 0.4, { onComplete: _ -> _discard(puff) }) });
	}

	function _skip():Void
	{
		skipping = true;
		_music?.fadeOut(0.6, 0);
		FlxTween.cancelTweensOf(_black);
		_black.visible = true;
		FlxTween.tween(_black, { alpha: 1 }, 0.6, { onComplete: _ -> _finish() });
	}

	function _finish():Void
	{
		if (_finished) return;
		_finished = true;
		_skipText.visible = false;
		FlxG.save.data.tvFinalSeen = true;
		FlxG.save.flush();
		if (onDone != null) onDone();
	}

	inline function _at(t:Float, run:Void->Void):Void
		_events.push({ t: t, run: run });

	inline function _look(x:Float, y:Float, zoom:Float, time:Float = 0, ?ease:flixel.tweens.FlxEase.EaseFunction):Void
		_game.gameCamera.lookAt(x, y, zoom, time, ease);

	function _skyTo(x:Float, y:Float, time:Float):Void
	{
		FlxTween.cancelTweensOf(_sky);
		if (time <= 0)
		{
			_sky.x = x;
			_sky.y = y;
			_game.bg.eclipseOffset(x, y);
			return;
		}
		FlxTween.tween(_sky, { x: x, y: y }, time, { ease: FlxEase.sineInOut, onUpdate: _ -> _game.bg.eclipseOffset(_sky.x, _sky.y) });
	}

	static inline function _feet(spr:FlxSprite, x:Float, y:Float, fx:Float, fy:Float):Void
		spr.setPosition(x - fx, y - fy);

	function _atlas(name:String, cam:FlxCamera):FlxSprite
	{
		final spr = new FlxSprite();
		spr.frames = Paths.getSparrowAtlas('minigame/thevalley/bg/cutscene/Final/' + name);
		_put(spr, cam);
		return spr;
	}

	function _defaultLoop():minigames.thevalley.tiles.Tiles.LoopTile
	{
		final l = new minigames.thevalley.tiles.Tiles.LoopTile(10085, -56);
		l.antialiasing = false;
		l.cameras = [_game.bgCam];
		_game.add(l);
		return l;
	}

	function _exe(cam:FlxCamera):FlxSprite
	{
		final spr = new FlxSprite();
		spr.frames = Paths.getSparrowAtlas('minigame/thevalley/characters/exe/exe');
		_put(spr, cam);
		return spr;
	}

	function _put(spr:FlxSprite, cam:FlxCamera):Void
	{
		spr.antialiasing = false;
		spr.cameras = [cam];
		spr.visible = false;
		_game.add(spr);
	}

	static function _screenSprite(spr:FlxSprite, scale:Float):Void
	{
		spr.scrollFactor.set(0, 0);
		spr.origin.set(0, 0);
		spr.scale.set(scale, scale);
	}

	static function _anim(spr:FlxSprite, name:String, prefix:String, durations:Array<Int>, loop:Bool, first:Int = 0, count:Int = -1):Void
	{
		final frames = spr.frames.frames;
		final all = [for (i in 0...frames.length) if (StringTools.startsWith(frames[i].name, prefix)) i];
		all.sort((a, b) -> Reflect.compare(frames[a].name, frames[b].name));
		final picked = all.slice(first, count < 0 ? all.length : first + count);
		final seq = [];
		for (k in 0...picked.length)
			for (_ in 0...Std.int(Math.max(1, Math.round(durations[k < durations.length ? k : durations.length - 1] / 10))))
				seq.push(picked[k]);
		spr.animation.add(name, seq, 100, loop);
	}
}
