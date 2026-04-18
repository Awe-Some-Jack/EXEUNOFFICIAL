package states.extras.sebas;

import backend.MusicBeatState;
import backend.Conductor;
import backend.Controls;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class SebasMiBeba extends MusicBeatState
{
	static inline var BASE_SCALE:Float        = 0.26;
	static inline var SPACING:Float           = 340.0;
	static inline var GRAVITY:Float           = 1400.0;
	static inline var ANTICIPATE_DUR:Float    = 0.08;
	static inline var LAND_DUR:Float          = 0.18;
	static inline var DRIFT_AMOUNT:Float      = 14.0;
	static inline var DRIFT_DUR:Float         = 3.0;
	static inline var SPIN_INTERVAL:Float     = 10.0;
	static inline var SPIN_DUR:Float          = 0.55;

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

	private var spinTimer:Float  = 0.0;
	private var spinning:Bool    = false;

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

			_startDrift(sp, sp.x, i * 0.55);
		}

		var snd = openfl.media.Sound.fromFile('assets/shared/music/baby.ogg');
		FlxG.sound.playMusic(snd, 1, true);

		Paths.clearUnusedMemory();
	}

	override public function beatHit():Void
	{
		super.beatHit();
		if (spinning) return;

		for (i in 0...imgs.length)
		{
			if (!jumping[i] && !anticipating[i] && !landing[i])
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

	override public function update(elapsed:Float):Void
	{
		Conductor.songPosition += elapsed * 1000;
		super.update(elapsed);

		spinTimer += elapsed;
		if (spinTimer >= SPIN_INTERVAL && !spinning)
		{
			spinTimer = 0;
			_doSpin();
		}

		if (!spinning)
		{
			for (i in 0...imgs.length)
				_updateSprite(i, elapsed);
		}

		if (Controls.instance.BACK)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			FlxG.switchState(new states.extras.ExtrasMenu());
		}
	}

	private function _updateSprite(i:Int, elapsed:Float):Void
	{
		var sp  = imgs[i];
		var bx  = baseX[i];
		var by  = baseY[i];

		if (anticipating[i])
		{
			antTimer[i] += elapsed;
			var p = Math.min(antTimer[i] / ANTICIPATE_DUR, 1.0);

			var tx = BASE_SCALE * (1 + p * 0.18);
			var ty = BASE_SCALE * (1 - p * 0.22);
			curSX[i] = FlxMath.lerp(curSX[i], tx, elapsed * 20);
			curSY[i] = FlxMath.lerp(curSY[i], ty, elapsed * 20);
			sp.scale.set(curSX[i], curSY[i]);

			if (antTimer[i] >= ANTICIPATE_DUR)
			{
				anticipating[i] = false;
				jumping[i]      = true;
				var beatDur     = 60.0 / 135.0;
				var flightTime  = 2 * beatDur - ANTICIPATE_DUR;
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

			var tx = BASE_SCALE * FlxMath.lerp(1.22, 1.0, p);
			var ty = BASE_SCALE * FlxMath.lerp(0.70, 1.0, p);
			curSX[i] = FlxMath.lerp(curSX[i], tx, elapsed * 18);
			curSY[i] = FlxMath.lerp(curSY[i], ty, elapsed * 18);
			sp.scale.set(curSX[i], curSY[i]);

			if (landTimer[i] >= LAND_DUR) landing[i] = false;
			return;
		}

		if (jumping[i])
		{
			velY[i]  += GRAVITY * elapsed;
			posY[i]  += velY[i] * elapsed;

			var jumpH   = by - peakY[i];
			var progress = jumpH > 0 ? FlxMath.bound((by - posY[i]) / jumpH, 0, 1) : 0.0;

			var stretch = 1 + progress * 0.14;
			var squish  = 1 - progress * 0.10;
			curSX[i] = FlxMath.lerp(curSX[i], BASE_SCALE * squish,  elapsed * 14);
			curSY[i] = FlxMath.lerp(curSY[i], BASE_SCALE * stretch, elapsed * 14);
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
