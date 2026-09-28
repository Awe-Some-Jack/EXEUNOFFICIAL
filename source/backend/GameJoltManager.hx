package backend;

import flixel.FlxG;
import gamejolt.GameJolt;
import gamejolt.Trophies;
import gamejolt.Sessions;
import gamejolt.Scores;
import gamejolt.Types.GJTrophy;

using StringTools;

class GameJoltManager
{
	static inline final GAME_ID:Int  = 1055030;
	static inline final TABLE_ID:Int = 1068403;
	static inline final TotalScoreTableID:Int = TABLE_ID;

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

	static final SONGS_SCOREBOARD_MAP:Map<String, Int> = [
		'too-slow'         => 1117272,
		'you-cant-run' 	   => 1117296,
		'triple-trouble'   => 1117297,
		'final-escape'     => 1117298,
		'yourself'         => 1117299,
		'cycles'           => 1117300,
		'hellbent'         => 1117301,
		'fate'             => 1117302,
		'gotta-go'         => 1117303,
		'endless-us'       => 1117304,
		'endless-jp'       => 1117305,
		'vanilla-milk'     => 1117306,
		'chocolate-milk'   => 1117307,
		'sunshine'         => 1117308,
		'soulless'         => 1117308,
		'chaos'            => 1117309,
		'faker'            => 1117310,
		'black-sun'        => 1117311,
		'the-valley'       => 1117312,
		'godspeed'         => 1117313,
		'too-fest'         => 1117314,
		'round-a-bout'     => 1117315,
		'her-world'        => 1117316,
		'starline'         => 1117317,
		'hedge'            => 1117318,
		'manual-blast'     => 1117319,
		'uh-oh'            => 1117320,
		'haze'             => 1117321,
		'life-and-death'   => 1117322,
		'hollow'           => 1117323,
		'longstrider'      => 1117324,
		'universal-collapse'  => 1117325,
		'hijacked-transmission'  => 1117326,
		'flash'            => 1117327,
		'pre-design'       => 1117328,
		'fatality'         => 1117330,
		'prey'             => 1117331,
		'fight-or-flight'  => 1117332,
		'mania'            => 1117333,
		'personel'         => 1117334,
		'burning'          => 1117335,
		'forestall-desire' => 1117336,
		'deception'        => 1117337,
		'miasma'           => 1117338,
		'b4cksl4sh'        => 1117339,
		'malediction'      => 1117340,
		'found-you'        => 1117341,
		'substantial'      => 1117342,
		'digitalized'      => 1117343,
		'monochromatic'    => 1117344,
		'fakebaby'         => 1117345,
		'sharpy-showdown'  => 1117346,
		'shocker'          => TABLE_ID
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

	/**
	* Debugger function
	*/
	public static function resetAllTrophies(resetBuild:Bool = true, resetGameJolt:Bool = true):Void
    {
        if (resetBuild)
        {
            EXEAchievements.lockAll();
            EXEAchievements.save();
        }

        if (resetGameJolt)
        {
            if (!isLoggedIn())
            {
                return;
            }

            Trophies.fetch(true, function(trophies:Array<GJTrophy>):Void
            {
                if (trophies == null || trophies.length == 0)
                {
                    return;
                }

                for (trophy in trophies)
                {
                    Trophies.remove(trophy.id, function(success:Bool):Void
                    {
                        if (success)
                            trace("Removed trophy' (ID:"+trophy.id+")");
                    });
                }
            });
        }
    }

	public static function syncAllTrophies():Void
	{
		if (!GameJolt.initialized) return;

		for (id => achieve in EXEAchievements.achievements.keyValueIterator())
		{
			if (achieve.unlocked ?? false)
			{
				unlockTrophy(id);
			}
		}

		/**
			* Sync GJ Trophies on build trophies
		*/
		Trophies.fetch(true, function(trophies:Array<GJTrophy>):Void
		{
			if (trophies == null || trophies.length == 0) return;

			for (trophy in trophies)
			{
				var trophyId:Int = trophy.id;

				for (localId => gjId in TROPHY_MAP.keyValueIterator())
				{
					if (gjId == trophyId)
					{
						if (EXEAchievements.exists(localId))
						{
							var localAchieve = EXEAchievements.get(localId);

							if (!(localAchieve.unlocked ?? false))
							{
								localAchieve.unlocked = true;
							}
						}
						break; 
					}
				}
			}
			EXEAchievements.save();
		});
	}
	
	public static function submitScore(scoreText:String, scoreValue:Int, tableId:Null<Int> = null, guestNickname:String="", extraData:String = "", callback:Bool->Void = null):Void
	{
		if (!isLoggedIn()) return;
		Scores.add(scoreText, scoreValue, (tableId ?? TABLE_ID), guestNickname, extraData, callback);
	}

	/**
     * Send the best score for a especified song
     * @param songName Song Tag / ID / Name  (ex. 'too-slow').
     * @param score obtained song points. (¿money...?)
     */
    public static function submitSongScore(songName:String, score:Int, callback:Bool->Void = null):Void
    {
        if (!isLoggedIn())
        {
            if (callback != null) callback(false);
            return;
        }

        final formattedSong:String = Paths.formatToSongPath(songName);

        if (SONGS_SCOREBOARD_MAP.exists(formattedSong))
        {
            final tableId:Int = SONGS_SCOREBOARD_MAP.get(formattedSong);
            final scoreText:String = formatNumber(score) + " SCR";

			submitScore(scoreText, score, tableId, "", "", function(success:Bool)
            {
                if (success)
					trace("Nice, Sending "+score+" points to the table of "+formattedSong);
                else
					trace("Uh! failed to send the points dude!");

                if (callback != null) callback(success);
            });
        }
        else
        {
            if (callback != null) callback(false);
        }
    }

	public static function submitTotalScore(callback:Bool->Void = null):Void
	{
		if (!isLoggedIn())
		{
			if (callback != null) callback(false);
			return;
		}

		var totalScore:Int = 0;

		for (song in SONGS_SCOREBOARD_MAP.keys())
		{
			if (SONGS_SCOREBOARD_MAP.get(song) == TotalScoreTableID) continue;

			var songScore:Int = Highscore.getScore(song, 1); 
			if (songScore > 0)
			{
				totalScore += songScore;
			}
		}

		if (totalScore > 0)
		{
			final scoreText:String = formatNumber(totalScore) + " SCR";
			
			submitScore(scoreText, totalScore, TotalScoreTableID, "", "", function(success:Bool)
			{
				if (callback != null) callback(success);
			});
		}
		else
		{
			if (callback != null) callback(false);
		}
	}

	function formatNumber(num:Int):String {
		var str = Std.string(num);
		var result = "";
		var len = str.length;
		for (i in 0...len) {
			if ((len - i) % 3 == 0 && i != 0) {
				result += ",";
			}
			result += str.charAt(i);
		}
		return result;
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