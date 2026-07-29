package backend;

import flixel.addons.api.FlxGameJolt;

@:file("assets/exe/gamejolt.key") private class GJKey extends haxe.io.Bytes {}

class GameJoltManager
{
	static inline final GAME_ID:Int  = 1055030;
	static inline final TABLE_ID:Int = 1068403;

	static final TROPHY_MAP:Map<String, Int> = [
		'finale'         => 303858,
		'hyper'          => 303859,
		'super'          => 303860,
		'rings'          => 303861,
		'die'            => 303863,
		'xeno'           => 303864,
		'fleetway'       => 303865,
		'fun'            => 303866,
		'tailsdoll'      => 303867,
		'chaotix'        => 303868,
		'lordx'          => 303870,
		'majin'          => 303871,
		'rerun'          => 303872,
		'needlemouse'    => 303873,
		'sanic'          => 303875,
		'omw'            => 303876,
		'chaotix2'       => 303877,
		'omw2'           => 303878,
		'soink'          => 303880,
		'ugly'           => 303881,
		'devoid'         => 303883,
		'sunky'          => 303884,
		'fatal'          => 303885,
		'starved'        => 303886,
		'educator'       => 303887,
		'sonichu'        => 303889,
		'coldsteel'      => 303890,
		'genesys'        => 303891,
		'fileextensions' => 303892,
		'demogri'        => 303893,
		'scorched'       => 303894,
		'secondary'      => 303895,
		'exe'            => 303896,
		'bratwurst'      => 303897,
		'crazy'          => 303898,
		'sega'           => 303899,
		'norings'        => 303901,
		'tripledeaths'   => 303902,
		'shocks'         => 303903,
		'music'          => 303904,
		'parallax'       => 303905,
		'magos'          => 303906,
		'fileext2'       => 303907,
		'investigator'   => 303908,
		'where'          => 303909,
		'idk'            => 303910,
	];

	static var _username:String = '';
	static var _token:String    = '';

	public static function isLoggedIn():Bool
		return FlxGameJolt.initialized;

	public static function getUsername():String
		return _username;

	public static function getSavedUsername():String
		return FlxG.save.data.gjUsername ?? '';

	public static function getSavedToken():String
		return FlxG.save.data.gjToken ?? '';

	public static function login(username:String, token:String, callback:Bool->Void):Void
	{
		_username = username.trim();
		_token    = token.trim();

		final key:GJKey = new GJKey();
		final keyStr:String = key.toString().trim();

		FlxGameJolt.init(GAME_ID, keyStr, true, _username, _token, function(result:Bool) {
			if (result)
			{
				FlxG.save.data.gjUsername = _username;
				FlxG.save.data.gjToken    = _token;
				FlxG.save.flush();
			}
			callback(result);
		});
	}

	public static function logout():Void
	{
		_username = '';
		_token    = '';
		FlxG.save.data.gjUsername = '';
		FlxG.save.data.gjToken    = '';
		FlxG.save.flush();
		@:privateAccess FlxGameJolt._initialized = false;
		@:privateAccess FlxGameJolt._gameID      = 0;
		@:privateAccess FlxGameJolt._privateKey  = '';
		@:privateAccess FlxGameJolt._userName    = null;
		@:privateAccess FlxGameJolt._userToken   = null;
	}

	public static function unlockTrophy(internalId:String):Void
	{
		if (!isLoggedIn()) return;
		final gjId = TROPHY_MAP.get(internalId);
		if (gjId != null) FlxGameJolt.addTrophy(gjId);
	}

	public static function syncAllTrophies():Void
	{
		if (!isLoggedIn()) return;
		for (id => achieve in EXEAchievements.achievements.keyValueIterator())
			if (achieve.unlocked ?? false) unlockTrophy(id);
	}

	public static function autoLogin(callback:Bool->Void):Void
	{
		final u = getSavedUsername();
		final t = getSavedToken();
		if (u != '' && t != '')
			login(u, t, callback);
		else
			callback(false);
	}
}
