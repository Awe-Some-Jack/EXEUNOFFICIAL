package;

#if android
import extension.androidtools.content.Context;
#end

import debug.FPSCounter;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;

import haxe.io.Path;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

import lime.app.Application;

import states.EXETitle;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end

#if (linux || mac)
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

import backend.FunkinCache;
import backend.MemoryUtil;
import backend.Highscore;

import states.EXEFreeplay;

// // // // // // // // //
class Main extends Sprite
{
	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: EXETitle,
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;

	// Al terminar el mod pueden quitar esta variable xdd
	public static var DEVELOPMENT_BUILD:Bool = true;

	// You can pretty much ignore everything from here on - your code should go in your states.

	@:noCompletion
	private static function __init__():Void
	{
		#if (linux && !debug)
		if (hxgamemode.GamemodeClient.request_start() != 0)
		{
		  Sys.println('Failed to request gamemode start: ${hxgamemode.GamemodeClient.error_string()}... continuing without it.');
		}
		else
		{
		  Sys.println('Succesfully requested gamemode to start...');
		}
		#end
	}


	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Sys.println("sonic.exe: hola");

		#if CRASH_HANDLER
		backend.CrashHandler.init();
		#end

		#if sl_windows_api
		WindowsAPI.disableWindowsReport();
		WindowsAPI.disableWindowsGhosting();
		#end

		#if mobile
		#if android
		MobileUtil.getPermissions();
		MobileUtil.initDirectory();
		#end
		Sys.setCwd(MobileUtil.getAssetDirectory());
		MobileUtil.mountAssets();
		#if flixel_animate
		MobileUtil.initAnimateAssetOverrides();
		#end
    	#end

		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) ->
		{
			if (e.keyCode == FlxKey.F11) FlxG.fullscreen = !FlxG.fullscreen;
			if (e.keyCode == FlxKey.ENTER && e.altKey) e.stopImmediatePropagation();
		}, false, 100);

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		Highscore.load();
		backend.GameJoltManager.autoLogin((_) -> {});

		//FlxG.saves
		FlxG.save.data.theYourselfCutscene = null;
		
		#if HSCRIPT_ALLOWED
		Iris.warn = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			PlayState.instance?.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}
		Iris.error = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			PlayState.instance?.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}
		Iris.fatal = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';
			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += 'HScript:';
				newPos.showLine = false;
			}
			#end
			if (newPos.showLine == true) {
				msgInfo += '${newPos.lineNumber}:';
			}
			msgInfo += ' $x';
			PlayState.instance?.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}

		crowplexus.iris.macro.AbstractMacro.init();
		#end

		//#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		FunkinCache.init();
		Paths.initStateSignals();

		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		backend.Language.reload();

		if (states.StoryModeState.fromTooSlow) states.StoryModeState.fromTooSlow = false;

		final push = new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		@:privateAccess
        push._customSoundTray = debug.EXESoundTray;

		addChild(push);

		final fontCache:Map<String, openfl.text.Font> = [];
		final getAssetOriginal = FlxG.assets.getAssetUnsafe;
		FlxG.assets.getAssetUnsafe = function(id:String, type:flixel.system.frontEnds.AssetFrontEnd.FlxAssetType, useCache:Bool = true):Null<Any>
		{
			if (type != flixel.system.frontEnds.AssetFrontEnd.FlxAssetType.FONT) return getAssetOriginal(id, type, useCache);
			var font = fontCache.get(id);
			if (font == null)
			{
				font = cast getAssetOriginal(id, type, useCache);
				#if mobile
				if (font == null && !haxe.io.Path.isAbsolute(id))
				{
					final absolutePath:String = haxe.io.Path.join([MobileUtil.getAssetDirectory(), id]);
					if (sys.FileSystem.exists(absolutePath))
						font = openfl.text.Font.fromFile(absolutePath);
				}
				#end
				if (font != null)
				{
					#if mobile
					try openfl.text.Font.registerFont(font) catch (e:Dynamic) {}
					#end
					fontCache.set(id, font);
				}
			}
			return font;
		};

		#if final
		final cheatCheckTimer = new haxe.Timer(1000);
        cheatCheckTimer.run = () -> backend.AntiCheat.checkDebugger();
		#end

		FlxG.mouse.useSystemCursor = true;

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		fpsVar.visible = false;
		addChild(fpsVar);
		
		FlxG.stage.align = "tl";
		FlxG.stage.scaleMode = StageScaleMode.NO_SCALE;

		#if (linux || mac) // fix the app icon not showing up on the Linux Panel / Mac Dock
		var icon = Image.fromFile("icon.webp");
		FlxG.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if windows
		backend.windows.WindowsApi.enableDarkMode();
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

		// MemoryUtil.clearMajor is called inside FunkinCache.clearSecondLayer (postStateSwitch)
		// but you forgor to enable it bru-
		MemoryUtil.enable();

		// shader coords fix
		FlxG.signals.gameResized.add((w, h) -> {
			if (fpsVar != null)
                fpsVar.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height));

			for (cam in FlxG.cameras?.list) {
				if (cam?.filters != null)
					resetSpriteCache(cam.flashSprite);
			}

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	public static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
			if (sprite != null) {
				for (bitmap in [sprite.__cacheBitmapData, sprite.__cacheBitmapData2, sprite.__cacheBitmapData3])
					if (bitmap != null && bitmap.__texture != null)
						bitmap.__texture.dispose();

		   		sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
			}
		}
    }
}
