package sys;

using StringTools;

class SwitchPath
{
	public static final ROMFS:String = 'romfs:/';

	public static function resolve(path:String):String
	{
		if (path == null || path.length == 0)
			return path;

		if (path.charCodeAt(0) == '/'.code)
			return path;

		final colon:Int = path.indexOf(':');
		final slash:Int = path.indexOf('/');
		if (colon > 0 && (slash == -1 || colon < slash))
			return path;

		if (path.startsWith('./'))
			path = path.substr(2);

		return ROMFS + path;
	}
}
