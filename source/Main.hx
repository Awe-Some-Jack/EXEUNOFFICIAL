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

// NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
#if (linux && !debug)
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

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

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		#if CRASH_HANDLER
		backend.CrashHandler.init();
		#end

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
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

		//FlxG.saves
		FlxG.save.data.theYourselfCutscene = null;
		FlxG.save.data.goToFinalEscape = null;
		

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
		Achievements.load();

		final push = new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		@:privateAccess
        push._customSoundTray = debug.EXESoundTray;

		addChild(push);

		FlxG.mouse.useSystemCursor = true;

		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		fpsVar.visible = false;
		addChild(fpsVar);
		
		FlxG.stage.align = "tl";
		FlxG.stage.scaleMode = StageScaleMode.NO_SCALE;

		#if (linux || mac) // fix the app icon not showing up on the Linux Panel / Mac Dock
		var icon = Image.fromFile("icon.png");
		FlxG.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
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
		   		sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
				sprite.__cacheBitmapColorTransform = null;
			}
		}
    }
}
