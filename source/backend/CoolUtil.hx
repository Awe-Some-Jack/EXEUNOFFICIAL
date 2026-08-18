package backend;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;

#if sl_windows_api
import winapi.WindowsAPI.MessageBoxIcon;
import winapi.WindowsAPI.MessageBoxType;
#end

class CoolUtil
{
	inline public static function quantize(f:Float, snap:Float){
		// changed so this actually works lol
		final m:Float = Math.fround(f * snap);
		//trace(snap);
		return (m / snap);
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:String = null;
		
		if (daList == null && openfl.utils.Assets.exists(path)) daList = openfl.utils.Assets.getText(path);

		#if sys
		if (sys.FileSystem.exists(path)) daList = sys.io.File.getContent(path);
		#end

		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor
	{
		final hideChars = ~/[\t\n\r]/;

		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		colorNum ??= FlxColor.fromString('#$color');
		return colorNum ?? FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		return Math.floor(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth)
		{
			for(row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel.alphaFloat > 0.05)
				{
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key => count in countByColor)
		{
			if(count >= maxCount)
			{
				maxCount = count;
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function showPopUp(message:String, title:String #if sl_windows_api, ?icon:MessageBoxIcon, ?type:MessageBoxType #end, showScrollableMSG:Bool = false):Void
	{
		#if android
		extension.androidtools.Tools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#elseif sl_windows_api
		if (showScrollableMSG)
			WindowsAPI.showScrollableMessage(message, title);
		else
			WindowsAPI.showMessageBox(message, title, icon, type);
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}

	inline public static function fpsLerp(amount:Float, elapsed:Float):Float
		return amount * elapsed * 60;

	inline public static function lerp(from:Float, to:Float, factor:Float, elapsed:Float):Float
		return from + (to - from) * (1 - Math.pow(1 - factor, elapsed * 60));

	inline public static function lerpX(spr:flixel.FlxObject, targetX:Float, factor:Float, elapsed:Float):Void
		spr.x = lerp(spr.x, targetX, factor, elapsed);

	inline public static function lerpY(spr:flixel.FlxObject, targetY:Float, factor:Float, elapsed:Float):Void
		spr.y = lerp(spr.y, targetY, factor, elapsed);

	inline public static function lerpPos(spr:flixel.FlxObject, targetX:Float, targetY:Float, factor:Float, elapsed:Float):Void
	{
		spr.x = lerp(spr.x, targetX, factor, elapsed);
		spr.y = lerp(spr.y, targetY, factor, elapsed);
	}

	inline public static function lerpScale(spr:flixel.FlxSprite, target:Float, factor:Float, elapsed:Float):Void
	{
		final s = lerp(spr.scale.x, target, factor, elapsed);
		spr.scale.set(s, s);
	}

	inline public static function lerpAlpha(spr:flixel.FlxSprite, target:Float, factor:Float, elapsed:Float):Void
		spr.alpha = lerp(spr.alpha, target, factor, elapsed);

	inline public static function lerpZoom(cam:flixel.FlxCamera, target:Float, factor:Float, elapsed:Float):Void
		cam.zoom = lerp(cam.zoom, target, factor, elapsed);

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
			if(!absolute) folder = Sys.getCwd() + '$folder';

			folder = folder.replace('/', '\\');
			if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

			
			final command:String = #if linux '/usr/bin/xdg-open' #else 'explorer.exe' #end;
			Sys.command(command, [folder]);

			trace('$command $folder');
		#else
			FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}

	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch(border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}
}
