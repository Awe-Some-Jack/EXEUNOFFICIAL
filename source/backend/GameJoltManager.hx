package backend;

import flixel.FlxG;
import gamejolt.GameJolt;
import gamejolt.Trophies;
import gamejolt.Sessions;
import gamejolt.Scores;

using StringTools;

class GameJoltManager
{
	static inline final GAME_ID:Int  = 1055030;
	static inline final TABLE_ID:Int = 1068403;

	private static function getPrivateKey():String
	{
		#if GAMEJOLT_KEY
		return haxe.macro.Compiler.getDefine("GAMEJOLT_KEY").trim();
		#else
		return "";
		#end
	}

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
		return GameJolt.initialized;

	public static function getUsername():String
		return GameJolt.username;

	public static function getSavedUsername():String
		return FlxG.save.data.gjUsername ?? '';

	public static function getSavedToken():String
		return FlxG.save.data.gjToken ?? '';

	public static function login(username:String, token:String, callback:Bool->Void):Void
	{
		final keyStr:String = getPrivateKey();

		if (keyStr == '')
		{
			FlxG.log.warn("GameJolt Key is empty! API calls are disabled.");
			callback(false);
			return;
		}
		
		GameJolt.init(GAME_ID, keyStr);

		GameJolt.login(username, token, function(result:Bool) {
			if (result)
			{
				FlxG.save.data.gjUsername = GameJolt.username;
				FlxG.save.data.gjToken    = GameJolt.userToken;
				FlxG.save.flush();

				// Sessions.open(true);
			}
			callback(result);
		});
	}

	public static function logout():Void
	{
		// Sessions.close();

		FlxG.save.data.gjUsername = '';
		FlxG.save.data.gjToken    = '';
		FlxG.save.flush();

		GameJolt.logout();
	}

	public static function unlockTrophy(internalId:String):Void
	{
		if (!isLoggedIn()) return;
		final gjId = TROPHY_MAP.get(internalId);
		if (gjId != null) Trophies.unlock(gjId);
	}

	public static function removeTrophy(internalId:String):Void
	{
		if (!isLoggedIn()) return;
		final gjId = TROPHY_MAP.get(internalId);
		if (gjId != null) Trophies.remove(gjId);
	}

	public static function syncAllTrophies():Void
	{
		if (!isLoggedIn()) return;
		for (id => achieve in EXEAchievements.achievements.keyValueIterator())
			if (achieve.unlocked ?? false) unlockTrophy(id);
	}
	
	public static function submitScore(scoreText:String, scoreValue:Int, extraData:String = "", callback:Bool->Void = null):Void
	{
		if (!isLoggedIn()) return;
		Scores.add(scoreText, scoreValue, TABLE_ID, "", extraData, callback);
	}


	public static function pauseSession():Void
	{
		if (!isLoggedIn()) return;
		// Sessions.ping("idle");
	}

	public static function resumeSession():Void
	{
		if (!isLoggedIn()) return;
		// Sessions.ping("active");
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