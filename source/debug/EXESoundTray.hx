package debug;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.Assets;
import openfl.filters.GlowFilter;
import openfl.filters.DropShadowFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

class EXESoundTray extends Sprite
{
	static final NUM_BARS:Int  = 10;
	static final BAR_W:Int     = 22;
	static final BAR_H:Int     = 15;
	static final BAR_GAP:Int   = 5;
	static final PADDING_X:Int = 12;
	static final PADDING_Y:Int = 10;
	static final TEXT_H:Int    = 32;
	static final CORNER:Float  = 9;

	static final W:Int = PADDING_X * 2 + NUM_BARS * BAR_W + (NUM_BARS - 1) * BAR_GAP;
	static final H:Int = PADDING_Y + TEXT_H + 5 + BAR_H + PADDING_Y;

	var trayXVisible:Float = 10;
	var trayXHidden:Float  = -(W + 20);

	var animationDuration:Float = 0.18;
	var holdDuration:Float      = 1.8;

	var colorBG:UInt          = 0xFF0D0D0D;
	var colorBorder:UInt      = 0xFF8B0000;
	var colorBarGlow:UInt     = 0xFFFF1133;
	var colorTransparent:UInt = 0x00000000;

	var bg:Bitmap;
	var volumeText:Bitmap;
	var bars:Array<Bitmap> = [];

	var timerHold:Float   = 0;
	var isActive:Bool     = false;
	var _lastVolume:Float  = -1;
	var _lastMuted:Bool    = false;
	var _lastScale:Float   = -1;
	var _lastLanguage:String = '';

	var boxTween:FlxTween;

	var glowFilter:GlowFilter;
	var shadowFilter:DropShadowFilter;

	public function new()
	{
		super();

		glowFilter   = new GlowFilter(colorBarGlow, 0.85, 5, 5, 2, 1, false, false);
		shadowFilter = new DropShadowFilter(3, 60, 0x000000, 0.75, 5, 5, 1, 1, false, false, false);

		createBackground();
		createVolumeText();
		createBars();

		applyScale();

		visible       = false;
		mouseEnabled  = false;
		mouseChildren = false;

		initializeState();
	}

	function createBackground():Void
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(colorBG, 0.93);
		shape.graphics.drawRoundRect(0, 0, W, H, CORNER * 2, CORNER * 2);
		shape.graphics.endFill();
		shape.graphics.lineStyle(1.5, colorBorder, 0.9);
		shape.graphics.drawRoundRect(0.75, 0.75, W - 1.5, H - 1.5, CORNER * 2, CORNER * 2);

		var bmd:BitmapData = new BitmapData(W, H, true, colorTransparent);
		bmd.draw(shape);
		bg = new Bitmap(bmd);
		bg.filters = [shadowFilter];
		addChild(bg);
	}

	function createVolumeText():Void
	{
		var label:String    = Language.getPhrase('soundtray.volume', 'VOLUME');
		var fontName:String = Language.getFontForLanguage();
		var fontAsset       = Assets.getFont(Paths.font(fontName));

		var tf:TextField   = new TextField();
		var fmt:TextFormat = new TextFormat();
		fmt.font  = fontAsset != null ? fontAsset.fontName : fontName;
		fmt.size  = 26;
		fmt.color = 0xFFFFFFFF;
		fmt.align = TextFormatAlign.LEFT;

		tf.defaultTextFormat = fmt;
		tf.embedFonts        = true;
		tf.selectable        = false;
		tf.autoSize          = openfl.text.TextFieldAutoSize.LEFT;
		tf.text              = label;

		var textW:Int       = Std.int(tf.textWidth + 4);
		var src:BitmapData  = new BitmapData(textW, TEXT_H, true, colorTransparent);
		src.draw(tf);
		var grad:BitmapData = applyGradient(src, 0xFF6B0000, 0xFFFF4444);

		volumeText   = new Bitmap(grad);
		volumeText.x = PADDING_X;
		volumeText.y = PADDING_Y;
		addChild(volumeText);
	}

	function applyGradient(source:BitmapData, colorTop:UInt, colorBottom:UInt):BitmapData
	{
		var result:BitmapData = new BitmapData(source.width, source.height, true, colorTransparent);

		var r1 = (colorTop    >> 16) & 0xFF; var g1 = (colorTop    >> 8) & 0xFF; var b1 = colorTop    & 0xFF;
		var r2 = (colorBottom >> 16) & 0xFF; var g2 = (colorBottom >> 8) & 0xFF; var b2 = colorBottom & 0xFF;

		for (py in 0...source.height)
		{
			var t:Float = py / source.height;
			var r = Std.int(r1 + (r2 - r1) * t);
			var g = Std.int(g1 + (g2 - g1) * t);
			var b = Std.int(b1 + (b2 - b1) * t);
			var gc:UInt = 0xFF000000 | (r << 16) | (g << 8) | b;

			for (px in 0...source.width)
			{
				var pixel:UInt = source.getPixel32(px, py);
				var a:Int = (pixel >> 24) & 0xFF;
				if (a > 0) result.setPixel32(px, py, (a << 24) | (gc & 0xFFFFFF));
			}
		}
		return result;
	}

	function createBars():Void
	{
		for (i in 0...NUM_BARS)
		{
			var bar:Bitmap = new Bitmap(makeBarBitmap(false));
			bar.x = PADDING_X + i * (BAR_W + BAR_GAP);
			bar.y = PADDING_Y + TEXT_H + 5;
			bars.push(bar);
			addChild(bar);
		}
		updateBars();
	}

	function makeBarBitmap(on:Bool):BitmapData
	{
		var bmd:BitmapData = new BitmapData(BAR_W, BAR_H, true, colorTransparent);
		var shape:Shape    = new Shape();

		if (on)
		{
			shape.graphics.beginFill(0xFFFF2222);
			shape.graphics.drawRoundRect(0, 0, BAR_W, BAR_H * 0.5, 3, 3);
			shape.graphics.endFill();
			shape.graphics.beginFill(0xFF990000);
			shape.graphics.drawRoundRect(0, BAR_H * 0.5, BAR_W, BAR_H * 0.5, 3, 3);
			shape.graphics.endFill();
			shape.graphics.beginFill(0xFFFFFFFF, 0.18);
			shape.graphics.drawRoundRect(2, 1, BAR_W - 4, 3, 2, 2);
			shape.graphics.endFill();
		}
		else
		{
			shape.graphics.beginFill(0xFF1A1A1A);
			shape.graphics.drawRoundRect(0, 0, BAR_W, BAR_H, 3, 3);
			shape.graphics.endFill();
			shape.graphics.lineStyle(1, 0xFF3A1010, 0.6);
			shape.graphics.drawRoundRect(0.5, 0.5, BAR_W - 1, BAR_H - 1, 3, 3);
		}

		bmd.draw(shape);
		return bmd;
	}

	function updateBars():Void
	{
		var linear:Float = FlxG.sound.logToLinear(FlxG.sound.volume);
		var active:Int   = FlxG.sound.muted ? 0 : Math.ceil(linear * NUM_BARS);

		for (i in 0...NUM_BARS)
		{
			var on:Bool = i < active;
			if (bars[i].bitmapData != null) bars[i].bitmapData.dispose();
			bars[i].bitmapData = makeBarBitmap(on);
			bars[i].filters    = on ? [glowFilter] : [];
		}
	}

	function initializeState():Void
	{
		#if FLX_SAVE
		if (FlxG.save.isBound)
		{
			if (FlxG.save.data.volume != null)
				FlxG.sound.volume = FlxG.save.data.volume;
			else
				FlxG.sound.volume = 0.5;

			if (FlxG.save.data.mute != null)
				FlxG.sound.muted = FlxG.save.data.mute;
		}
		else
		#end
		{
			FlxG.sound.volume = 0.5;
		}

		_lastVolume = FlxG.sound.volume;
		_lastMuted  = FlxG.sound.muted;
		updateBars();
	}

	function applyScale():Void
	{
		var s:Float = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);
		if (s == _lastScale) return;
		_lastScale = s;

		scaleX = s;
		scaleY = s;
		trayXVisible = 10;
		trayXHidden  = -(W + 20);
		y = FlxG.stage.stageHeight * 0.25 / s;
		if (!visible) x = trayXHidden;
	}

	override private function __enterFrame(e:Float):Void
	{
		applyScale();

		var lang:String = Language.getPhrase('soundtray.volume', 'VOLUME');
		if (lang != _lastLanguage)
		{
			_lastLanguage = lang;
			if (volumeText != null)
			{
				if (volumeText.bitmapData != null) volumeText.bitmapData.dispose();
				removeChild(volumeText);
				volumeText = null;
			}
			createVolumeText();
		}

		var vol:Float  = FlxG.sound.volume;
		var muted:Bool = FlxG.sound.muted;

		if (vol != _lastVolume || muted != _lastMuted)
		{
			_lastVolume = vol;
			_lastMuted  = muted;
			updateBars();
			show();
		}

		if (isActive)
		{
			timerHold -= e / 1000;
			if (timerHold <= 0) hide();
		}
	}

	function show():Void
	{
		timerHold = holdDuration;

		if (boxTween != null && boxTween.active) boxTween.cancel();
		visible  = true;
		isActive = true;

		boxTween = FlxTween.tween(this, {x: trayXVisible}, 0.3, {ease: FlxEase.expoOut});
	}

	function hide():Void
	{
		isActive = false;
		if (boxTween != null && boxTween.active) boxTween.cancel();

		boxTween = FlxTween.tween(this, {x: trayXHidden}, 0.25, {
			ease: FlxEase.expoIn,
			onComplete: function(_) { visible = false; saveSettings(); }
		});
	}

	function createRoundedRect(width:Int, height:Int, radius:Float, color:UInt):BitmapData
	{
		if (width  <= 0) width  = 1;
		if (height <= 0) height = 1;

		var shape:Shape = new Shape();
		shape.graphics.beginFill(color);
		shape.graphics.drawRoundRect(0, 0, width, height, radius * 2, radius * 2);
		shape.graphics.endFill();

		var bmd:BitmapData = new BitmapData(width, height, true, colorTransparent);
		bmd.draw(shape);
		return bmd;
	}

	function saveSettings():Void
	{
		#if FLX_SAVE
		if (FlxG.save.isBound)
		{
			FlxG.save.data.mute   = FlxG.sound.muted;
			FlxG.save.data.volume = FlxG.sound.volume;
			FlxG.save.flush();
		}
		#end
	}

	public function destroy():Void
	{
		if (boxTween != null && boxTween.active) boxTween.cancel();

		if (bg != null && bg.bitmapData != null) bg.bitmapData.dispose();
		if (volumeText != null && volumeText.bitmapData != null) volumeText.bitmapData.dispose();
		for (bar in bars)
			if (bar != null && bar.bitmapData != null) bar.bitmapData.dispose();

		bg = null;
		volumeText = null;
		bars = [];
		boxTween = null;
		glowFilter   = null;
		shadowFilter = null;
	}
}
