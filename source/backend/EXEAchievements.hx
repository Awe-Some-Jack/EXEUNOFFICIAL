package backend;

import backend.WeekData;
import backend.Song;

typedef EXEAchievement =
{
	var name:String;
	var description:String;
    var id:String;
	@:optional var unlocked:Bool;
	@:optional var secret:Bool;
	@:optional var maxScore:Float;
	@:optional var extra:Dynamic;
}

class EXEAchievements 
{
    public static var achievements(get, never):Map<String, EXEAchievement>;
    static function get_achievements():Map<String, EXEAchievement>
    {
        if(FlxG.save.data.EXEAchievements == null) init();
        return FlxG.save.data.EXEAchievements;
    }

    public static function init():Void
    {
        FlxG.save.data.EXEAchievements = new Map<String, EXEAchievement>();

        var rawJson = File.getContent('assets/exe/extras/achievements/achievements.json').trim();
        var parsed:Array<EXEAchievement> = cast tjson.TJSON.parse(rawJson);

        for(achieve in parsed)
            FlxG.save.data.EXEAchievements.set(achieve.id, achieve);
    }

	public static function get(name:String):EXEAchievement
		return achievements.get(name);
	public static function exists(name:String):Bool
		return achievements.exists(name);

    public static function isUnlocked(name:String):Bool
    {
        if(get(name) != null)
            return get(name).unlocked ?? false; 
		return false;
    }
    public static function unlock(name:String):Void
    {
        var a = get(name);
        if(a == null) return;
        if(a.unlocked ?? false) return;
        a.unlocked = true;
        states.extras.achievements.AchievementPopup.show(name);
        GameJoltManager.unlockTrophy(name);
    }
    public static function unlockAll():Void
    {
        for(name => achieve in achievements.keyValueIterator()) 
            achieve.unlocked = true;
    }
    public static function lockAll():Void
    {
        for(name => achieve in achievements.keyValueIterator()) 
            achieve.unlocked = false;
    }

    public static function achieveGameOver(songId:String):Void
    {
        if(isUnlocked('die')) return;

        var a = get('die');
        if(a == null) return;

        var deathList:Array<String> = cast(a.extra ?? []);
        if(deathList.contains(songId)) return;
        deathList.push(songId);
        a.extra = deathList;

        var allSongs:Array<String> = [];
        for(name => week in WeekData.weeksLoaded.keyValueIterator())
            for(song in week.songs)
                allSongs.push(Paths.formatToSongPath(song[0]));

        if(deathList.length >= allSongs.length)
        {
            unlock(a.id);
            checkFinale();
        }
        save();
    }

    public static function save():Void
        FlxG.save.flush();

    public static function incrementCount(id:String, max:Int):Void
    {
        if(isUnlocked(id)) return;
        var a = get(id);
        if(a == null) return;
        var count:Int = cast(a.extra ?? 0);
        a.extra = count + 1;
        if(count + 1 >= max)
        {
            unlock(a.id);
            checkFinale();
            save();
        }
    }

    public static function checkSongCompletion(songId:String, misses:Int, ratingPercent:Float):Void
    {
        // Global rank achievements
        if(ratingPercent >= 1.0 && misses == 0) unlock('hyper');
        if(ratingPercent >= 0.8) incrementCount('super', 5);

        switch(songId) {
            // Main Week
            case 'yourself' | 'too-slow' | 'you-cant-run' | 'triple-trouble' | 'final-escape':
                unlock('xeno');
            // Lord X
            case 'cycles' | 'hellbent' | 'fate' | 'gotta-go':
                unlock('lordx');
            // Majin / Mazin
            case 'endless-us' | 'endless-jp':
                unlock('majin');
            // Tails Doll
            case 'sunshine' | 'soulless':
                unlock('tailsdoll');
            // Fleetway
            case 'chaos':
                unlock('fleetway');
            // EXE
            case 'faker' | 'black-sun' | 'the-valley' | 'godspeed':
                unlock('exe');
            // Sanic
            case 'too-fest':
                unlock('sanic');
            // Needlemouse
            case 'round-a-bout' | 'her-world':
                unlock('needlemouse');
            // Chaotix
            case 'starline':
                unlock('chaotix');
            // Bratwurst (Trilogy)
            case 'life-and-death':
                unlock('bratwurst');
            // Demogri & Griatos (Grieving)
            case 'uh-oh' | 'haze':
                unlock('demogri');
            // Scorched (HOG)
            case 'hedge' | 'manual-blast':
                unlock('scorched');
            // OMW.EXE
            case 'longstrider' | 'universal-collapse':
                unlock('omw');
            // Devoid
            case 'hollow':
                unlock('devoid');
            // Re-Run
            case 'hijacked-transmission':
                unlock('rerun');
            // Soink.FLA (Flash)
            case 'flash':
                unlock('soink');
            // Movie Sonic
            case 'pre-design':
                unlock('ugly');
            // Sunky
            case 'vanilla-milk' | 'chocolate-milk':
                unlock('sunky');
            // Fatal Error
            case 'fatality':
                unlock('fatal');
            // Starved Eggman
            case 'prey' | 'fight-or-flight':
                unlock('starved');
            // Psycho Tails (Crazy Tails)
            case 'mania':
                unlock('crazy');
            // Coldsteel
            case 'personel':
                unlock('coldsteel');
            // Genesys Eggman
            case 'burning':
                unlock('genesys');
            // Educator (Parallax)
            case 'expulsion':
                unlock('educator');
            // Sonichu
            case 'shocker':
                unlock('sonichu');
            // File Extensions characters (all of them must be beaten)
            case 'b4cksl4sh' | 'monochromatic' | 'found-you' | 'forestall-desire' | 'deception'
               | 'sharpy-showdown' | 'substantial' | 'digitalized' | 'fakebaby' | 'miasma':
                checkFileExtensions(songId);
            default:
        }
        checkFinale();
        save();
    }

    public static function checkFinale():Void
    {
        if(isUnlocked('finale')) return;
        var itsFinale:Bool = true;
        for (a in achievements)
        {
            if (!itsFinale) break;
            if (a == get('finale')) continue;
            if (!isUnlocked(a.name)) itsFinale = false;
        }
        if (itsFinale) unlock('finale');
        save();
    }

    static var FILE_EXTENSIONS_SONGS:Array<String> = [
        'b4cksl4sh', 'monochromatic', 'found-you', 'forestall-desire', 'deception',
        'sharpy-showdown', 'substantial', 'digitalized', 'fakebaby', 'miasma'
    ];

    static function checkFileExtensions(songId:String):Void
    {
        if(isUnlocked('fileextensions')) return;
        var a = get('fileextensions');
        if(a == null) return;
        var beaten:Array<String> = cast(a.extra ?? []);
        if(!beaten.contains(songId)) beaten.push(songId);
        a.extra = beaten;
        if(beaten.length >= FILE_EXTENSIONS_SONGS.length)
        {
            unlock(a.id);
            checkFinale();
            save();
        }
    }

    static var SECONDARY_CODES:Array<Array<Int>> = [
        [0, 0], [24, 4], [4, 10], [50, 3], [1, 72], [26, 16], [0, 67], [22, 74], [14, 2]
    ];

    public static function checkSecondaryCodes():Void
    {
        if(isUnlocked('secondary')) return;
        var a = get('secondary');
        if(a == null) return;
        var codes = cast(a.extra ?? []);
        if (codes.length >= SECONDARY_CODES.length) 
        {
            unlock(a.id);
            checkFinale();
            save();
        }
    }
}