package debug;

import flixel.FlxG;
import flixel.system.ui.FlxSoundTray;
import flixel.system.FlxAssets.FlxSoundAsset;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.filters.GlowFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.BitmapFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;

class EXESoundTray extends FlxSoundTray
{
	static final TRAY_SCALE:Float = 1.0;
	static final NUM_BARS:Int     = 10;
	static final BAR_W:Int        = 22;
	static final BAR_H:Int        = 15;
	static final BAR_GAP:Int      = 5;
	static final PADDING_X:Int    = 12;
	static final PADDING_Y:Int    = 10;
	static final TEXT_H:Int       = 32;
	static final CORNER:Float     = 9;

	static final W:Int = PADDING_X * 2 + NUM_BARS * BAR_W + (NUM_BARS - 1) * BAR_GAP;
	static final H:Int = PADDING_Y + TEXT_H + 5 + BAR_H + PADDING_Y;

	var trayXVisible:Float = 10;
	var trayXHidden:Float  = 0;

	var holdDuration:Float    = 1.8;
	var slideSpeed:Float      = 1500;

	var colorBG:UInt          = 0xFF0D0D0D;
	var colorBorder:UInt      = 0xFF8B0000;
	var colorBarGlow:UInt     = 0xFFFF1133;
	var colorTransparent:UInt = 0x00000000;

	var bg:Bitmap;
	var volumeText:Bitmap;
	var bars:Array<Bitmap>;
	var barStates:Array<Bool>;

	var timerHold:Float      = 0;
	var isActive:Bool        = false;
	var _lastVolume:Float    = -1;
	var _lastMuted:Bool      = false;
	var _lastLanguage:String = '';
	var _lastActiveBars:Int  = -1;

	var litBarBmd:BitmapData;
	var unlitBarBmd:BitmapData;

	var glowFilter:GlowFilter;
	var shadowFilter:DropShadowFilter;
	
	final filterActive:Array<BitmapFilter> = [];
	final filterInactive:Array<BitmapFilter> = [];

	public function new()
	{
		super();

		removeChildren();

		volumeUpSound = "assets/shared/sounds/VolumeSwitch.ogg";
		volumeDownSound = "assets/shared/sounds/VolumeSwitch.ogg";

		if (!silent)
		{
			FlxG.sound.cache('$volumeUpSound');
			FlxG.sound.cache('$volumeDownSound');
		}

		glowFilter   = new GlowFilter(colorBarGlow, 0.85, 5, 5, 2, 1, false, false);
		shadowFilter = new DropShadowFilter(3, 60, 0x000000, 0.75, 5, 5, 1, 1, false, false, false);
		
		filterActive.push(glowFilter);

		bars = [];
		barStates = [];

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
		final shape:Shape = new Shape();
		shape.graphics.beginFill(colorBG, 0.93);
		shape.graphics.drawRoundRect(0, 0, W, H, CORNER * 2, CORNER * 2);
		shape.graphics.endFill();
		shape.graphics.lineStyle(1.5, colorBorder, 0.9, true);
		shape.graphics.drawRoundRect(0.75, 0.75, W - 1.5, H - 1.5, CORNER * 2, CORNER * 2);
		
		final bmd:BitmapData = new BitmapData(W, H, true, colorTransparent);
		bmd.draw(shape, null, null, null, null, true);
		
		bg = new Bitmap(bmd);
		bg.filters = [shadowFilter];
		addChild(bg);
	}

	function createVolumeText():Void
	{
		final label:String    = Language.getPhrase('soundtray.volume', 'VOLUME');
		final fontName:String = Language.getFontForLanguage();
		final fontAsset       = Assets.getFont(Paths.font(fontName));

		final tf:TextField   = new TextField();
		final fmt:TextFormat = new TextFormat();
		fmt.font  = fontAsset != null ? fontAsset.fontName : fontName;
		fmt.size  = 26;
		fmt.color = 0xFFFFFFFF;
		fmt.align = TextFormatAlign.LEFT;

		tf.defaultTextFormat = fmt;
		tf.embedFonts        = true;
		tf.selectable        = false;
		tf.autoSize          = TextFieldAutoSize.LEFT;
		tf.text              = label;

		final textW:Int       = Std.int(tf.textWidth + 4);
		final src:BitmapData  = new BitmapData(textW, TEXT_H, true, colorTransparent);
		src.draw(tf);

		final grad:BitmapData = applyGradient(src, 0xFF6B0000, 0xFFFF4444);
		volumeText   = new Bitmap(grad);
		volumeText.x = PADDING_X;
		volumeText.y = PADDING_Y;
		addChild(volumeText);
		
		src.dispose();
	}

	function applyGradient(source:BitmapData, colorTop:UInt, colorBottom:UInt):BitmapData
	{
		final result:BitmapData = new BitmapData(source.width, source.height, true, colorTransparent);
		final r1 = (colorTop    >> 16) & 0xFF;
		final g1 = (colorTop    >> 8) & 0xFF; 
		final b1 = colorTop    & 0xFF;
		final r2 = (colorBottom >> 16) & 0xFF; 
		final g2 = (colorBottom >> 8) & 0xFF;
		final b2 = colorBottom & 0xFF;
		
		final hFloat:Float = source.height;

		for (py in 0...source.height)
		{
			final t:Float = py / hFloat;
			final r = Std.int(r1 + (r2 - r1) * t);
			final g = Std.int(g1 + (g2 - g1) * t);
			final b = Std.int(b1 + (b2 - b1) * t);
			final gc:UInt = 0xFF000000 | (r << 16) | (g << 8) | b;

			for (px in 0...source.width)
			{
				final pixel:UInt = source.getPixel32(px, py);
				final a:Int = (pixel >> 24) & 0xFF;
				if (a > 0) result.setPixel32(px, py, (a << 24) | (gc & 0xFFFFFF));
			}
		}
		return result;
	}

	function createBars():Void
	{
		litBarBmd = makeBarBitmap(true);
		unlitBarBmd = makeBarBitmap(false);

		for (i in 0...NUM_BARS)
		{
			final bar:Bitmap = new Bitmap(unlitBarBmd);
			bar.x = PADDING_X + i * (BAR_W + BAR_GAP);
			bar.y = PADDING_Y + TEXT_H + 5;
			bars.push(bar);
			barStates.push(false);
			addChild(bar);
		}
		
		updateBars(FlxG.sound.volume, true);
	}

	function makeBarBitmap(on:Bool):BitmapData
	{
		final bmd:BitmapData = new BitmapData(BAR_W, BAR_H, true, colorTransparent);
		final shape:Shape    = new Shape();

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

	function updateBars(vol:Float, force:Bool = false):Void
	{
		var activeBars:Int = FlxG.sound.muted ? 0 : Math.round(vol * 10);
		activeBars = Std.int(Math.max(0, Math.min(NUM_BARS, activeBars)));

		if (!force && activeBars == _lastActiveBars) return;

		_lastActiveBars = activeBars;

		for (i in 0...NUM_BARS)
		{
			final on:Bool = i < activeBars;
			if (barStates[i] != on)
			{
				barStates[i] = on;
				bars[i].bitmapData = on ? litBarBmd : unlitBarBmd;
				bars[i].filters = on ? filterActive : filterInactive;
			}
		}
	}

	function initializeState():Void
	{
		#if FLX_SAVE
		if (FlxG.save.isBound)
		{
			FlxG.sound.volume = FlxG.save?.data?.volume ?? #if (FLX_KEYBOARD && !mobile) 0.5 #else 1.0 #end;
			if (FlxG.save.data.mute != null)
				FlxG.sound.muted = FlxG.save.data.mute;
		}
		else
		#end
		{
			FlxG.sound.volume = #if desktop 0.5 #else 1.0 #end;
		}

		_lastVolume = FlxG.sound.volume;
		_lastMuted  = FlxG.sound.muted;
		updateBars(FlxG.sound.volume, true);
	}

	function applyScale():Void
	{
		final baseScale:Float = Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height);
		final s:Float = baseScale * TRAY_SCALE; 
		
		scaleX = s;
		scaleY = s;
		
		trayXVisible = FlxG.stage.stageWidth - (W * s) - FlxG.game.x - 10;
		trayXHidden  = FlxG.stage.stageWidth + 50; 
		
		y = FlxG.stage.stageHeight * 0.05; 
		if (!visible) x = trayXHidden;
	}

	override public function showAnim(volume:Float, ?sound:FlxSoundAsset, duration:Float = 1.0, label:String = "VOLUME"):Void 
	{
		if (sound != null) FlxG.sound.play(sound.resolveSound(true, true));

		final lang:String = Language.getPhrase('soundtray.volume', 'VOLUME');
		if (lang != _lastLanguage)
		{
			_lastLanguage = lang;
			if (volumeText != null)
			{
				if (volumeText.bitmapData != null) volumeText.bitmapData.dispose();
				removeChild(volumeText);
			}
			createVolumeText();
		}

		_lastVolume = FlxG.sound.volume;
		_lastMuted = FlxG.sound.muted;
		updateBars(FlxG.sound.volume);

		timerHold = holdDuration;
		visible = true;
		
		active = true;
		isActive = true;
	}
    
	@:deprecated("show is deprecated, use showAnim")
	override public function show(up:Bool = false):Void {}
	override function updateSize():Void {}

	override public function update(MS:Float):Void
	{
		applyScale();
		
		if (_lastVolume != FlxG.sound.volume || _lastMuted != FlxG.sound.muted)
		{
			_lastVolume = FlxG.sound.volume;
			_lastMuted = FlxG.sound.muted;
			updateBars(FlxG.sound.volume);
		}

		if (isActive)
		{
			x += (trayXVisible - x) * (MS / 1000) * 15;
			if (Math.abs(trayXVisible - x) < 1) x = trayXVisible;

			timerHold -= MS / 1000;
			if (timerHold <= 0) isActive = false;
		}
		else
		{
			x += (MS / 1000) * slideSpeed;
			
			if (x >= trayXHidden)
			{
				x = trayXHidden;
				visible = false;
				active = false;
				saveSettings();
			}
		}
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
		bg?.bitmapData?.dispose();
		volumeText?.bitmapData?.dispose();
		litBarBmd?.dispose();
		unlitBarBmd?.dispose();
		
		if (bars != null)
		{
			for (bar in bars) 
				bar?.bitmapData?.dispose();
		}

		bg = null;
		volumeText = null;
		bars = null;
		barStates = null;
		glowFilter = null;
		shadowFilter = null;
	}
}