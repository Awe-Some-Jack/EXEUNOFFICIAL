package backend;

#if switch
class SwitchStorage
{
	public static inline final ROOT:String = 'sdmc:/switch/VsSonic/';
	public static inline final SAVES:String = ROOT + 'saves';
	public static inline final LOGS:String = ROOT + 'logs/';

	public static inline final ROMFS:String = 'romfs:/';

	public static function init():Void
	{
		Sys.setCwd(ROMFS);

		ensureDirectory(ROOT);
		ensureDirectory(SAVES);
		ensureDirectory(LOGS);

		@:privateAccess lime.system.System.__applicationStorageDirectory = ROOT + 'a/b/c';
	}

	public static function ensureDirectory(path:String):Void
	{
		try
		{
			var current:String = '';
			for (part in path.split('/'))
			{
				if (part == '') continue;

				if (part.endsWith(':'))
				{
					current = part + '/';
					continue;
				}

				current += part;
				if (!FileSystem.exists(current))
					FileSystem.createDirectory(current);
				current += '/';
			}
		}
		catch (e:Dynamic)
		{
			trace('Could not create directory $path: $e');
		}
	}

	public static function bootLog(message:String):Void
	{
		try
		{
			ensureDirectory(ROOT);
			final file = File.append(ROOT + 'boot.log', false);
			file.writeString(Date.now().toString() + ' ' + message + '\n');
			file.close();
		}
		catch (e:Dynamic) {}
	}

	public static function toDevicePath(path:String):String
	{
		if (path.startsWith('sdmc:/') || path.startsWith('romfs:/'))
			return path;
		return ROMFS + path;
	}
}
#end
