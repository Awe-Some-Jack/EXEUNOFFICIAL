package states.stages;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.WindowAttributes;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import flixel.util.FlxTimer;

class Fatality extends BaseStage
{
	static var healthWindow:Window = null;
	static var healthContainer:Sprite = null;
	static var lifeSprite:Bitmap = null;

	static inline var BAR_W:Int    = 472;
	static inline var BAR_H:Int    = 70;
	static inline var SCALE:Float  = 1.32;
	static inline var X_OFFSET:Int = 155;
	static inline var Y_ABOVE:Int  = 150;
	static inline var MAX_SQ:Int   = 25;
	static inline var SQ_W:Int     = 16;
	static inline var SQ_H:Int     = 15;
	static inline var SQ_SPACING:Int = 2;
	static inline var LIFE_X:Int   = 13;
	static inline var LIFE_Y:Int   = 64;

	// slide
	var sliding:Bool    = false;
	var slideTimer:Float = 0;
	var slideStart:Float = 0;
	var slideTarget:Float = 0;

	// shake
	var shaking:Bool = false;
	var shakeBaseX:Float = 0;
	var shakeBaseY:Float = 0;
	var mainShaking:Bool = false;
	var mainShakeBaseX:Float = 0;
	var mainShakeBaseY:Float = 0;

	// infinity
	var infinity:Bool = false;
	var infinityTime:Float = 0;
	var infCenterX:Float = 0;
	var infCenterY:Float = 0;
	var mainInfCenterX:Float = 0;
	var mainInfCenterY:Float = 0;

	// return
	var returning:Bool = false;
	var returnTime:Float = 0;
	var returnStartX:Float = 0;
	var returnStartY:Float = 0;
	var returnTargetX:Float = 0;
	var returnTargetY:Float = 0;
	var healthReturnStartX:Float = 0;
	var healthReturnStartY:Float = 0;
	var healthReturnTargetX:Float = 0;
	var healthReturnTargetY:Float = 0;

	// float
	var floating:Bool = false;
	var floatTime:Float = 0;
	var floatBaseX:Float = 0;

	// final screen
	var finalShown:Bool = false;

	override function create()
	{
		closeWindow();
	}

	override function createPost()
	{
		new FlxTimer().start(0.5, function(_) openWindow());
	}

	override function stepHit()
	{
		switch (curStep)
		{
			case 255:  beginSlide();
			case 2230: beginShake();
			case 2240: beginInfinity();
			case 2432: beginReturn();
			case 2528: beginShakeAgain();
			case 2560: showFinalScreen();
		}
	}

	override function update(elapsed:Float)
	{
		updateHealthBar();

		var mainWin:Window = Application.current.window;

		// slide
		if (sliding)
		{
			slideTimer += elapsed;
			var dur:Float = 1.0;
			if (slideTimer >= dur)
			{
				sliding = false;
				slideTimer = 0;
				if (healthWindow != null) healthWindow.y = Std.int(slideTarget);
				floating = true;
				floatTime = 0;
				if (healthWindow != null) floatBaseX = healthWindow.x;
			}
			else
			{
				var t:Float = slideTimer / dur;
				var eased:Float = 1 - Math.pow(2, -10 * t);
				if (healthWindow != null)
					healthWindow.y = Std.int(slideStart + (slideTarget - slideStart) * eased);
			}
		}

		// float
		if (floating && !infinity && !shaking && !returning && healthWindow != null)
		{
			floatTime += elapsed;
			var offset:Float = Math.sin(floatTime * 0.8) * 8;
			healthWindow.x = Std.int(floatBaseX + offset);
		}

		// shake
		if (shaking && healthWindow != null)
		{
			healthWindow.x = Std.int(shakeBaseX + FlxG.random.float(-10, 10));
			healthWindow.y = Std.int(shakeBaseY + FlxG.random.float(-10, 10));
		}
		if (mainShaking)
		{
			mainWin.x = Std.int(mainShakeBaseX + FlxG.random.float(-10, 10));
			mainWin.y = Std.int(mainShakeBaseY + FlxG.random.float(-10, 10));
		}

		// infinity
		if (infinity)
		{
			infinityTime += elapsed;
			var t:Float = infinityTime * 0.5;
			var ox:Float = Math.sin(t) * 100;
			var oy:Float = Math.sin(t * 2) * 50;
			mainWin.x = Std.int(mainInfCenterX + ox);
			mainWin.y = Std.int(mainInfCenterY + oy);
			if (healthWindow != null)
			{
				healthWindow.x = Std.int(infCenterX + ox);
				healthWindow.y = Std.int(infCenterY + oy);
			}
		}

		// return
		if (returning)
		{
			returnTime += elapsed;
			var dur:Float = 1.5;
			if (returnTime >= dur)
			{
				returning = false;
				mainWin.x = Std.int(returnTargetX);
				mainWin.y = Std.int(returnTargetY);
				if (healthWindow != null)
				{
					healthWindow.x = Std.int(healthReturnTargetX);
					healthWindow.y = Std.int(healthReturnTargetY);
				}
			}
			else
			{
				var t:Float = returnTime / dur;
				var eased:Float = 1 - Math.pow(1 - t, 3);
				mainWin.x = Std.int(returnStartX + (returnTargetX - returnStartX) * eased);
				mainWin.y = Std.int(returnStartY + (returnTargetY - returnStartY) * eased);
				if (healthWindow != null)
				{
					healthWindow.x = Std.int(healthReturnStartX + (healthReturnTargetX - healthReturnStartX) * eased);
					healthWindow.y = Std.int(healthReturnStartY + (healthReturnTargetY - healthReturnStartY) * eased);
				}
			}
		}
	}

	override function destroy()
	{
		closeWindow();
		if (finalShown)
			FlxG.fullscreen = false;
		super.destroy();
	}

	// -------------------------------------------------------------------------
	// Window lifecycle

	static function closeWindow():Void
	{
		if (healthWindow != null)
		{
			try { healthWindow.close(); } catch (e:Dynamic) {}
			healthWindow = null;
		}
		healthContainer = null;
		lifeSprite = null;
	}

	function openWindow():Void
	{
		closeWindow();

		var winW:Int = Math.ceil(BAR_W * SCALE);
		var winH:Int = Math.ceil(BAR_H * SCALE);
		var mainWin:Window = Application.current.window;

		var attrs:WindowAttributes = {};
		attrs.width = winW;
		attrs.height = winH;
		attrs.title = "";
		attrs.borderless = true;
		attrs.alwaysOnTop = false;
		attrs.resizable = false;
		attrs.hidden = false;

		try
		{
			healthWindow = Application.current.createWindow(attrs);
			healthWindow.x = mainWin.x + X_OFFSET;
			healthWindow.y = mainWin.y - 500;
			slideTarget = mainWin.y - Y_ABOVE;

			var container = new Sprite();
			healthWindow.stage.addChild(container);
			healthContainer = container;

			var barBd = BitmapData.fromFile("mods/FATAL/images/fatality/bar/bar.png");
			if (barBd != null)
			{
				var barBmp = new Bitmap(barBd);
				barBmp.scaleX = SCALE;
				barBmp.scaleY = SCALE;
				container.addChild(barBmp);
			}

			var lifeBd = BitmapData.fromFile("mods/FATAL/images/fatality/bar/life.png");
			if (lifeBd != null)
			{
				var bmp = new Bitmap(lifeBd);
				bmp.x = LIFE_X;
				bmp.y = LIFE_Y;
				bmp.scaleX = SCALE;
				bmp.scaleY = SCALE;
				container.addChild(bmp);
				lifeSprite = bmp;
			}

			mainWin.focus();
		}
		catch (e:Dynamic)
		{
			healthWindow = null;
		}
	}

	// -------------------------------------------------------------------------
	// Animation triggers

	function beginSlide():Void
	{
		if (healthWindow == null || sliding) return;
		sliding = true;
		slideTimer = 0;
		slideStart = healthWindow.y;
	}

	function beginShake():Void
	{
		var mainWin = Application.current.window;
		mainShaking = true;
		mainShakeBaseX = mainWin.x;
		mainShakeBaseY = mainWin.y;
		if (healthWindow != null)
		{
			shaking = true;
			shakeBaseX = healthWindow.x;
			shakeBaseY = healthWindow.y;
		}
	}

	function beginInfinity():Void
	{
		var mainWin = Application.current.window;
		mainShaking = false;
		shaking = false;
		infinity = true;
		infinityTime = 0;
		mainInfCenterX = mainWin.x;
		mainInfCenterY = mainWin.y;
		if (healthWindow != null)
		{
			infCenterX = healthWindow.x;
			infCenterY = healthWindow.y;
		}
	}

	function beginReturn():Void
	{
		var mainWin = Application.current.window;
		infinity = false;
		returning = true;
		returnTime = 0;
		returnStartX = mainWin.x;
		returnStartY = mainWin.y;
		returnTargetX = mainShakeBaseX;
		returnTargetY = mainShakeBaseY;
		if (healthWindow != null)
		{
			healthReturnStartX = healthWindow.x;
			healthReturnStartY = healthWindow.y;
			healthReturnTargetX = shakeBaseX;
			healthReturnTargetY = shakeBaseY;
		}
	}

	function beginShakeAgain():Void
	{
		var mainWin = Application.current.window;
		returning = false;
		mainShaking = true;
		mainShakeBaseX = mainWin.x;
		mainShakeBaseY = mainWin.y;
		if (healthWindow != null)
		{
			shaking = true;
			shakeBaseX = healthWindow.x;
			shakeBaseY = healthWindow.y;
		}
	}

	function showFinalScreen():Void
	{
		if (finalShown) return;
		finalShown = true;
		mainShaking = false;
		shaking = false;
		if (healthWindow != null) healthWindow.visible = false;
		FlxG.fullscreen = true;
		var screen = new objects.BGSprite('fatality/fatal', 0, 0);
		screen.cameras = [camOther];
		add(screen);
	}

	// -------------------------------------------------------------------------
	// Health bar

	function updateHealthBar():Void
	{
		if (lifeSprite == null || !onPlayState) return;
		var pct:Float = PlayState.instance.health / 2;
		var squares:Int = Std.int(Math.max(0, Math.min(Math.round(pct * MAX_SQ), MAX_SQ)));
		var px:Int = squares * (SQ_W + SQ_SPACING);
		lifeSprite.scrollRect = new Rectangle(0, 0, px, SQ_H);
	}
}
