package states.extras.sebas;

import backend.MusicBeatState;
import backend.Conductor;
import backend.Controls;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class SebasMiBeba extends MusicBeatState
{
	static inline final BASE_SCALE:Float      = 0.26;
	static inline final SPACING:Float         = 340.0;
	static inline final GRAVITY:Float         = 1400.0;
	static inline final ANTICIPATE_DUR:Float  = 0.08;
	static inline final LAND_DUR:Float        = 0.18;
	static inline final DRIFT_AMOUNT:Float    = 14.0;
	static inline final DRIFT_DUR:Float       = 3.0;
	static inline final SPIN_INTERVAL:Float   = 10.0;
	static inline final SPIN_DUR:Float        = 0.55;
	static inline final SHAKE_INTERVAL:Float  = 6.0;
	static inline final SHAKE_DUR:Float       = 0.4;
	static inline final SHAKE_INTENSITY:Float = 6.0;

	private var imgs:Array<FlxSprite>     = [];
	private var baseX:Array<Float>        = [];
	private var baseY:Array<Float>        = [];
	private var curSX:Array<Float>        = [];
	private var curSY:Array<Float>        = [];
	private var velY:Array<Float>         = [];
	private var posY:Array<Float>         = [];
	private var posX:Array<Float>         = [];
	private var peakY:Array<Float>        = [];
	private var dir:Array<Int>            = [];
	private var anticipating:Array<Bool>  = [];
	private var antTimer:Array<Float>     = [];
	private var jumping:Array<Bool>       = [];
	private var landing:Array<Bool>       = [];
	private var landTimer:Array<Float>    = [];
	private var shaking:Array<Bool>       = [];
	private var shakeTimer:Array<Float>   = [];
	private var shakeElapsed:Array<Float> = [];
	private var nextShake:Array<Float>    = [];

	private var spinTimer:Float  = 0.0;
	private var spinning:Bool    = false;
	private var flying:Bool      = false;
	private var _flyBackCount:Int = 0;

	private var ggezTxt:FlxText  = null;
	private var ggezVisible:Bool = false;

	private static final GGEZ_LINES:Array<String> = [
		"GG EZ", "COPE", "SKILL ISSUE", "mi putita we",
		"sal de clash lil bro", "EZ CLAP", "TOO EASY", "MI PERRITA"
	];

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();

		Conductor.bpm = 135;
		Conductor.songPosition = 0;

		var bg = new FlxSprite(0, 0);
		bg.loadGraphic(openfl.display.BitmapData.fromFile('assets/exe/sebasmibeba/1.jpg'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.antialiasing = true;
		bg.alpha = 0.18;
		add(bg);

		var centerX = FlxG.width * 0.5;

		for (i in 0...3)
		{
			var sp = new FlxSprite();
			sp.loadGraphic(openfl.display.BitmapData.fromFile('assets/exe/sebasmibeba/${i + 1}.jpg'));
			sp.scale.set(BASE_SCALE, BASE_SCALE);
			sp.updateHitbox();
			sp.antialiasing = true;

			sp.x = centerX + (i - 1) * SPACING - sp.width * 0.5;
			sp.y = 80;

			add(sp);
			imgs.push(sp);
			baseX.push(sp.x);
			baseY.push(sp.y);
			posX.push(sp.x);
			posY.push(sp.y);
			curSX.push(BASE_SCALE);
			curSY.push(BASE_SCALE);
			velY.push(0);
			peakY.push(sp.y);
			dir.push(i % 2 == 0 ? 1 : -1);
			anticipating.push(false);
			antTimer.push(0);
			jumping.push(false);
			landing.push(false);
			landTimer.push(0);
			shaking.push(false);
			shakeTimer.push(0);
			shakeElapsed.push(0);
			nextShake.push(SHAKE_INTERVAL + FlxG.random.float(0, 4));

			_startDrift(sp, sp.x, i * 0.55);
		}

		ggezTxt = new FlxText(0, 0, FlxG.width, "GG EZ", 96);
		ggezTxt.setFormat("assets/fonts/bigass.otf", 96, FlxColor.WHITE, CENTER);
		ggezTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 6);
		ggezTxt.screenCenter();
		ggezTxt.alpha = 0;
		ggezTxt.antialiasing = true;
		add(ggezTxt);

		var snd = openfl.media.Sound.fromFile('assets/shared/music/baby.ogg');
		FlxG.sound.playMusic(snd, 1, true);

		Paths.clearUnusedMemory();
	}

	override public function beatHit():Void
	{
		super.beatHit();
		if (spinning || flying) return;

		for (i in 0...imgs.length)
		{
			if (!jumping[i] && !anticipating[i] && !landing[i] && !shaking[i])
			{
				anticipating[i] = true;
				antTimer[i]     = 0;
				dir[i]          = -dir[i];
			}
		}
	}

	private function _startDrift(sp:FlxSprite, bx:Float, delay:Float):Void
	{
		FlxTween.tween(sp, {x: bx + DRIFT_AMOUNT}, DRIFT_DUR, {
			ease: FlxEase.sineInOut,
			startDelay: delay,
			type: PINGPONG
		});
	}

	private function _doSpin():Void
	{
		spinning = true;
		var done = 0;
		for (i in 0...imgs.length)
		{
			var sp = imgs[i];
			FlxTween.cancelTweensOf(sp, ["y", "angle"]);
			sp.y     = baseY[i];
			posY[i]  = baseY[i];
			sp.scale.set(BASE_SCALE, BASE_SCALE);
			curSX[i] = BASE_SCALE;
			curSY[i] = BASE_SCALE;

			FlxTween.tween(sp, {angle: sp.angle + 360}, SPIN_DUR, {
				ease: FlxEase.quadInOut,
				onComplete: function(_) {
					sp.angle = 0;
					done++;
					if (done >= imgs.length) spinning = false;
				}
			});
		}
	}

	private function _doFlyAway():Void
	{
		if (flying) return;
		flying = true;
		_flyBackCount = 0;

		_showGGEZ();

		for (i in 0...imgs.length)
		{
			var sp = imgs[i];
			FlxTween.cancelTweensOf(sp);
			FlxTween.cancelTweensOf(sp.scale);

			jumping[i]      = false;
			anticipating[i] = false;
			landing[i]      = false;
			shaking[i]      = false;

			var tx  = baseX[i] + FlxG.random.float(-400, 400);
			var ty  = FlxG.random.float(-500, -200);
			var rot = FlxG.random.float(-540, 540);

			FlxTween.tween(sp, {x: tx, y: ty, angle: rot}, 0.55, {
				ease: FlxEase.backIn,
				onComplete: function(_) _flyBack(i)
			});
		}
	}

	private function _flyBack(i:Int):Void
	{
		var sp = imgs[i];
		sp.angle = 0;
		sp.scale.set(BASE_SCALE, BASE_SCALE);
		curSX[i] = BASE_SCALE;
		curSY[i] = BASE_SCALE;

		FlxTween.tween(sp, {x: baseX[i], y: baseY[i]}, 0.6, {
			ease: FlxEase.elasticOut,
			onComplete: function(_) {
				posX[i] = baseX[i];
				posY[i] = baseY[i];
				sp.x    = baseX[i];
				sp.y    = baseY[i];
				_startDrift(sp, baseX[i], 0);

				_flyBackCount++;
				if (_flyBackCount >= imgs.length)
					flying = false;
			}
		});
	}

	private function _startShake(i:Int):Void
	{
		shaking[i]      = true;
		shakeElapsed[i] = 0;
		shakeTimer[i]   = 0;
		jumping[i]      = false;
		anticipating[i] = false;
		landing[i]      = false;
		imgs[i].y       = baseY[i];
		posY[i]         = baseY[i];
	}

	private function _showGGEZ():Void
	{
		ggezTxt.text = GGEZ_LINES[FlxG.random.int(0, GGEZ_LINES.length - 1)];
		ggezTxt.screenCenter();
		ggezVisible = true;

		FlxTween.cancelTweensOf(ggezTxt);
		ggezTxt.alpha = 0;
		ggezTxt.scale.set(2.0, 2.0);

		FlxTween.tween(ggezTxt, {alpha: 1}, 0.12, {ease: FlxEase.quadOut});
		FlxTween.tween(ggezTxt.scale, {x: 1.0, y: 1.0}, 0.25, {
			ease: FlxEase.elasticOut,
			onComplete: function(_) {
				new FlxTimer().start(1.2, function(_) {
					FlxTween.tween(ggezTxt, {alpha: 0}, 0.3, {ease: FlxEase.quadIn,
						onComplete: function(_) ggezVisible = false
					});
				});
			}
		});
	}

	override public function update(elapsed:Float):Void
	{
		Conductor.songPosition += elapsed * 1000;
		super.update(elapsed);

		spinTimer += elapsed;
		if (spinTimer >= SPIN_INTERVAL && !spinning && !flying)
		{
			spinTimer = 0;
			_doSpin();
		}

		for (i in 0...imgs.length)
		{
			if (!shaking[i] && !flying && !spinning)
			{
				nextShake[i] -= elapsed;
				if (nextShake[i] <= 0)
				{
					nextShake[i] = SHAKE_INTERVAL + FlxG.random.float(2, 6);
					_startShake(i);
				}
			}
		}

		if (!spinning && !flying)
		{
			for (i in 0...imgs.length)
				_updateSprite(i, elapsed);
		}

		if (!flying && !spinning)
		{
			if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.R
				|| FlxG.keys.justPressed.F || FlxG.keys.justPressed.G
				|| FlxG.keys.justPressed.H || FlxG.keys.justPressed.J
				|| FlxG.keys.justPressed.K || FlxG.keys.justPressed.L
				|| FlxG.keys.justPressed.Z || FlxG.keys.justPressed.X
				|| FlxG.keys.justPressed.C || FlxG.keys.justPressed.V
				|| FlxG.keys.justPressed.B || FlxG.keys.justPressed.N
				|| FlxG.keys.justPressed.M)
			{
				_doFlyAway();
			}
		}

		if (Controls.instance.BACK)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			FlxG.switchState(new states.extras.ExtrasMenu());
		}
	}

	private function _updateSprite(i:Int, elapsed:Float):Void
	{
		var sp = imgs[i];
		var bx = baseX[i];
		var by = baseY[i];

		if (shaking[i])
		{
			shakeElapsed[i] += elapsed;
			shakeTimer[i]   += elapsed;

			if (shakeElapsed[i] >= SHAKE_DUR)
			{
				shaking[i] = false;
				sp.x = bx;
				sp.y = by;
				posX[i] = bx;
				posY[i] = by;
				return;
			}

			if (shakeTimer[i] >= 0.04)
			{
				shakeTimer[i] = 0;
				sp.x = bx + FlxG.random.float(-SHAKE_INTENSITY, SHAKE_INTENSITY);
				sp.y = by + FlxG.random.float(-SHAKE_INTENSITY, SHAKE_INTENSITY);
			}
			return;
		}

		if (anticipating[i])
		{
			antTimer[i] += elapsed;
			var p = Math.min(antTimer[i] / ANTICIPATE_DUR, 1.0);

			curSX[i] = FlxMath.lerp(curSX[i], BASE_SCALE * (1 + p * 0.18), elapsed * 20);
			curSY[i] = FlxMath.lerp(curSY[i], BASE_SCALE * (1 - p * 0.22), elapsed * 20);
			sp.scale.set(curSX[i], curSY[i]);

			if (antTimer[i] >= ANTICIPATE_DUR)
			{
				anticipating[i] = false;
				jumping[i]      = true;
				var flightTime  = 2 * (60.0 / 135.0) - ANTICIPATE_DUR;
				velY[i]         = -(GRAVITY * flightTime / 2);
				peakY[i]        = by - (velY[i] * velY[i]) / (2 * GRAVITY);
				posY[i]         = by;
			}
			return;
		}

		if (landing[i])
		{
			landTimer[i] += elapsed;
			var p = Math.min(landTimer[i] / LAND_DUR, 1.0);

			curSX[i] = FlxMath.lerp(curSX[i], BASE_SCALE * FlxMath.lerp(1.22, 1.0, p), elapsed * 18);
			curSY[i] = FlxMath.lerp(curSY[i], BASE_SCALE * FlxMath.lerp(0.70, 1.0, p), elapsed * 18);
			sp.scale.set(curSX[i], curSY[i]);

			if (landTimer[i] >= LAND_DUR) landing[i] = false;
			return;
		}

		if (jumping[i])
		{
			velY[i]  += GRAVITY * elapsed;
			posY[i]  += velY[i] * elapsed;

			var jumpH    = by - peakY[i];
			var progress = jumpH > 0 ? FlxMath.bound((by - posY[i]) / jumpH, 0, 1) : 0.0;

			curSX[i] = FlxMath.lerp(curSX[i], BASE_SCALE * (1 - progress * 0.10), elapsed * 14);
			curSY[i] = FlxMath.lerp(curSY[i], BASE_SCALE * (1 + progress * 0.14), elapsed * 14);
			sp.scale.set(curSX[i], curSY[i]);

			posX[i] = bx + dir[i] * 18 * progress;
			sp.x    = posX[i];

			if (posY[i] >= by)
			{
				posY[i]      = by;
				posX[i]      = bx;
				velY[i]      = 0;
				jumping[i]   = false;
				landing[i]   = true;
				landTimer[i] = 0;
				sp.x         = bx;
			}
			sp.y = posY[i];
		}
		else if (!landing[i])
		{
			curSX[i] = FlxMath.lerp(curSX[i], BASE_SCALE, elapsed * 8);
			curSY[i] = FlxMath.lerp(curSY[i], BASE_SCALE, elapsed * 8);
			sp.scale.set(curSX[i], curSY[i]);
		}
	}

	override public function destroy():Void
	{
		for (sp in imgs) if (sp != null) { FlxTween.cancelTweensOf(sp); FlxTween.cancelTweensOf(sp.scale); }
		imgs = null;
		super.destroy();
	}
}
