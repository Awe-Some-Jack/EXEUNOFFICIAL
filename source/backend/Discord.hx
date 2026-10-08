package backend;

#if DISCORD_ALLOWED
import Sys.sleep;
import sys.thread.Thread;
import lime.app.Application;

import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

import flixel.util.FlxStringUtil;

class DiscordClient
{
	public static var isInitialized:Bool = false;
	private inline static final _defaultID:String = "1478458307961163786";
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordPresence = new DiscordPresence();
	
	// hides this field from scripts and reflection in general
	@:unreflective private static var __thread:Thread;

	public static var username:String = "";
	public static var discriminator:String = "";
	public static var userID:String = "";

	public static function check()
	{
		if(ClientPrefs.data.discordRPC)
		{
			#if linux
			if(isDiscordRunning()) initialize();
			#else
			initialize();
			#end
		}
		else if(isInitialized) shutdown();
	}

	public static function prepare()
	{
		if (!isInitialized && ClientPrefs.data.discordRPC)
		{
			#if linux
			if(!isDiscordRunning())
				trace("Discord: Not initializing - Discord isn't running");			
			else
				initialize();
			#else
			initialize();
			#end
		}

		Application.current.onExit.add((_) -> if(isInitialized) shutdown());
	}

	public dynamic static function shutdown()
	{
		isInitialized = false;
		Discord.Shutdown();
	}
	
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		username = cast(request[0].username, String);
		discriminator = cast(request[0].discriminator, String);
		userID = cast(request[0].userId, String);

		var message = '(Discord) Connected to User ';
		if (discriminator != '0') //Old discriminators
			message += '($username#$discriminator) (ID: $userID)';
		else //New Discord IDs/Discriminator system
			message += '($username) (ID: $userID)';

		trace(message);
		changePresence();
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		var errorMsg = cast(message, String);
		trace('Discord: Error ($errorCode: $errorMsg)');
		#if linux
		trace('Discord: Linux RPC issue - ensure Discord is running and /tmp is accessible');
		#end
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected ($errorCode: ${cast(message, String)})');
	}

	#if linux
	private static function findDiscordSocket(directory:String, maxDepth:Int = 5, currentDepth:Int = 0):String
	{
		if (currentDepth >= maxDepth) return null;

		try
		{
			for (entry in sys.FileSystem.readDirectory(directory))
			{
				if (entry.startsWith("discord-ipc-"))
				{
					var fullPath = '$directory/$entry';
					if (sys.FileSystem.exists(fullPath))
					{
						trace('Discord: Found IPC socket at $fullPath');
						return fullPath;
					}
				}

				var fullPath = '$directory/$entry';
				try
				{
					if (sys.FileSystem.isDirectory(fullPath))
					{
						var result = findDiscordSocket(fullPath, maxDepth, currentDepth + 1);
						if (result != null) return result;
					}
				}
				catch (e:Dynamic) {}
			}
		}
		catch (e:Dynamic) {}

		return null;
	}

	private static function isDiscordRunning():Bool
	{
		try
		{
			var tempDir = Sys.getEnv("XDG_RUNTIME_DIR");
			if (tempDir == null) tempDir = Sys.getEnv("TMPDIR");
			if (tempDir == null) tempDir = Sys.getEnv("TMP");
			if (tempDir == null) tempDir = Sys.getEnv("TEMP");
			if (tempDir == null) tempDir = "/tmp";

			var socketPath = findDiscordSocket(tempDir);
			if (socketPath != null) return true;

			return false;
		}
		catch (e:Dynamic)
		{
			return false;
		}
	}
	#end

	public static function initialize()
	{
		var discordHandlers:DiscordEventHandlers = new DiscordEventHandlers();
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), true, null);

		if(!isInitialized) trace("Discord Client initialized");

		if (__thread == null)
		{
			__thread = Thread.create(() ->
			{
				while (true)
				{
					if (isInitialized)
					{
						#if DISCORD_DISABLE_IO_THREAD
						Discord.UpdateConnection();
						#end
						Discord.RunCallbacks();
					}

					// Wait 1 second until the next loop...
					Sys.sleep(1.0);
				}
			});
		}
		isInitialized = true;
	}

	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float, largeImageKey:String = 'icon', activityType:Int = 0, currentSongPos:Float = 0)
	{
		var startTimestamp:Float = 0;
		if (hasStartTimestamp)
			startTimestamp = Date.now().getTime() - currentSongPos; 
		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp; 

		presence.state = state;
		presence.details = details;
		presence.smallImageKey = smallImageKey;
		presence.largeImageKey = largeImageKey;
		presence.largeImageText = 'Version: ${Application.current.meta.get('version')}';
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		presence.type = activityType; 
		
		updatePresence();
	}

	public static function updatePresence()
	{
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence.__presence));
	}
	
	inline public static function resetClientID()
	{
		clientID = _defaultID;
	}

	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;

		if(change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}

	#if MODS_ALLOWED
	public static function loadModRPC()
	{
		var pack:Dynamic = Mods.getPack();
		if(pack != null && pack.discordRPC != null && pack.discordRPC != clientID)
		{
			clientID = pack.discordRPC;
			//trace('Changing clientID! $clientID, $_defaultID');
		}
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:Null<RawPointer<Lua_State>>)
	{
		LuaUtilsHx.addFunction(lua, "changeDiscordPresence", changePresence);
		LuaUtilsHx.addFunction(lua, "changeDiscordClientID", function(?newID:String) {
			if(newID == null) newID = _defaultID;
			clientID = newID;
		});
	}
	#end
}

@:allow(backend.DiscordClient)
private final class DiscordPresence
{
	public var state(get, set):String;
	public var details(get, set):String;
	public var smallImageKey(get, set):String;
	public var largeImageKey(get, set):String;
	public var largeImageText(get, set):String;
	public var startTimestamp(get, set):Int;
	public var endTimestamp(get, set):Int;
	public var type(get, set):Int;

	@:noCompletion private var __presence:DiscordRichPresence;

	function new()
	{
		__presence = new DiscordRichPresence();
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("state", state),
			LabelValuePair.weak("details", details),
			LabelValuePair.weak("smallImageKey", smallImageKey),
			LabelValuePair.weak("largeImageKey", largeImageKey),
			LabelValuePair.weak("largeImageText", largeImageText),
			LabelValuePair.weak("startTimestamp", startTimestamp),
			LabelValuePair.weak("endTimestamp", endTimestamp),
			LabelValuePair.weak("type", type)
		]);
	}

	@:noCompletion inline function get_state():String
	{
		return __presence.state;
	}

	@:noCompletion inline function set_state(value:String):String
	{
		return __presence.state = value;
	}

	@:noCompletion inline function get_details():String
	{
		return __presence.details;
	}

	@:noCompletion inline function set_details(value:String):String
	{
		return __presence.details = value;
	}

	@:noCompletion inline function get_smallImageKey():String
	{
		return __presence.smallImageKey;
	}

	@:noCompletion inline function set_smallImageKey(value:String):String
	{
		return __presence.smallImageKey = value;
	}

	@:noCompletion inline function get_largeImageKey():String
	{
		return __presence.largeImageKey;
	}
	
	@:noCompletion inline function set_largeImageKey(value:String):String
	{
		return __presence.largeImageKey = value;
	}

	@:noCompletion inline function get_largeImageText():String
	{
		return __presence.largeImageText;
	}

	@:noCompletion inline function set_largeImageText(value:String):String
	{
		return __presence.largeImageText = value;
	}

	@:noCompletion inline function get_startTimestamp():Int
	{
		return cast(__presence.startTimestamp, Int);
	}

	@:noCompletion inline function set_startTimestamp(value:Int):Int
	{
		__presence.startTimestamp = value;
		return value;
	}

	@:noCompletion inline function get_endTimestamp():Int
	{
		return cast(__presence.endTimestamp, Int);
	}

	@:noCompletion inline function set_endTimestamp(value:Int):Int
	{
		__presence.endTimestamp = value;
		return value;
	}

	@:noCompletion inline function get_type():Int
	{
		return cast(__presence.type, Int);
	}

	@:noCompletion inline function set_type(value:Int):Int
	{
		__presence.type = value;
		return value;
	}
}
#end
