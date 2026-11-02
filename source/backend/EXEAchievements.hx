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

    public static final achievementSongGroups:Map<String, Array<String>> = [
        'xeno' => ['yourself', 'too-slow', 'you-cant-run', 'triple-trouble', 'final-escape'],
        'lordx' => ['cycles', 'hellbent', 'fate', 'gotta-go'],
        'majin' => ['endless-us', 'endless-jp'],
        'tailsdoll' => ['sunshine', 'soulless'],
        'fleetway' => ['chaos'],
        'exe' => ['faker', 'black-sun', 'godspeed'],
        'sanic' => ['too-fest'],
        'needlemouse' => ['round-a-bout', 'her-world'],
        'chaotix' => ['starline'],
        'bratwurst' => ['life-and-death'],
        'demogri' => ['uh-oh', 'haze'],
        'scorched' => ['hedge', 'manual-blast'],
        'omw' => ['longstrider', 'universal-collapse'],
        'devoid' => ['hollow'],
        'rerun' => ['hijacked-transmission'],
        'soink' => ['flash'],
        'ugly' => ['pre-design'],
        'sunky' => ['vanilla-milk', 'chocolate-milk'],
        'fatal' => ['fatality'],
        'starved' => ['prey', 'fight-or-flight'],
        'crazy' => ['mania'],
        'coldsteel' => ['personel'],
        'genesys' => ['burning'],
        'educator' => ['expulsion'],
        'sonichu' => ['shocker'],
        'fileextensions' => ['b4cksl4sh', 'monochromatic', 'found-you', 'forestall-desire', 'deception', 'sharpy-showdown', 'substantial', 'digitalized', 'fakebaby', 'miasma', 'malediction']
    ];

    static function get_achievements():Map<String, EXEAchievement>
    {
        if(FlxG.save.data.EXEAchievements == null) init();
        else if(!_synced) sync();
        _synced = true;
        return FlxG.save.data.EXEAchievements;
    }

    static var _synced:Bool = false;

    static function sync():Void
    {
        final saved:Map<String, EXEAchievement> = FlxG.save.data.EXEAchievements;
        final renamed = ['pepe' => 'magosymagas', 'luigikid' => 'exechallenge', 'explotion' => 'mehead'];
        final rawJson = Paths.getContent('assets/exe/extras/achievements/achievements.json').trim();
        final parsed:Array<EXEAchievement> = cast tjson.TJSON.parse(rawJson);

        for(achieve in parsed)
        {
            var old = saved.get(achieve.id);
            if(old == null)
                for(from => to in renamed)
                    if(to == achieve.id && saved.exists(from)) old = saved.get(from);
            if(old != null)
            {
                achieve.unlocked = old.unlocked;
                achieve.extra = old.extra;
            }
            saved.set(achieve.id, achieve);
        }
        for(from in renamed.keys()) saved.remove(from);
    }

    public static function init():Void
    {
        FlxG.save.data.EXEAchievements = new Map<String, EXEAchievement>();

        final rawJson = Paths.getContent('assets/exe/extras/achievements/achievements.json').trim();
        final parsed:Array<EXEAchievement> = cast tjson.TJSON.parse(rawJson);

        for(achieve in parsed)
            FlxG.save.data.EXEAchievements.set(achieve.id, achieve);
    }

	public static function get(name:String):EXEAchievement return achievements.get(name);
	public static function exists(name:String):Bool return achievements.exists(name);

    public static function isUnlocked(name:String):Bool
    {
        if(get(name) != null) return get(name).unlocked ?? false; 
		return false;
    }

    public static function unlock(name:String):Void
    {
        final a = get(name);
        if(a == null || (a.unlocked ?? false)) return;
        
        a.unlocked = true;
        states.extras.achievements.AchievementPopup.show(name);
        GameJoltManager.unlockTrophy(name);
        checkFinale();
    }

    public static function unlockAll():Void { for(a in achievements) a.unlocked = true; }
    public static function lockAll():Void { 
        for(a in achievements) a.unlocked = false;
        GameJoltManager.resetAllTrophies(false, true);
    }

    public static function achieveGameOver(songId:String):Void
    {
        if(isUnlocked('die')) return;

        final a = get('die');
        if(a == null) return;

        final saved:Array<String> = cast(a.extra ?? []);
        final deathList:Array<String> = [for(s in saved) Paths.formatToSongPath(s)];
        final id:String = Paths.formatToSongPath(songId);
        if(!deathList.contains(id))
        {
            deathList.push(id);
            a.extra = deathList;

            final keepList = WeekData.weeksList;
            final keepLoaded = WeekData.weeksLoaded;
            WeekData.weeksLoaded = new Map<String, WeekData>();
            WeekData.reloadWeekFiles(false);
            final allSongs:Array<String> = [];
            for(week in WeekData.weeksLoaded)
                for(song in week.songs)
                {
                    final name:String = Paths.formatToSongPath(song[0]);
                    if(name != 'stardust-speedway' && name != 'the-valley' && !allSongs.contains(name)) allSongs.push(name);
                }
            WeekData.weeksList = keepList;
            WeekData.weeksLoaded = keepLoaded;

            if(allSongs.length > 0 && Lambda.foreach(allSongs, name -> deathList.contains(name)))
            {
                unlock(a.id);
            }
            save();
        }
    }

    public static function save():Void 
        FlxG.save.flush();

    public static function incrementCount(id:String, max:Int):Void
    {
        if(isUnlocked(id)) return;

        final a = get(id);
        if(a == null) return;
        
        final count:Int = cast(a.extra ?? 0);
        a.extra = count + 1;
        if(count + 1 >= max)
        {
            unlock(a.id);
        }
        save();
    }

    public static function checkSongCompletion(songId:String, misses:Int, ratingPercent:Float):Void
    {
        if(ratingPercent >= 1.0 && misses == 0) unlock('hyper');
        if(ratingPercent >= 0.8) incrementCount('super', 5);

        for (achieveId => songList in achievementSongGroups)
        {
            if (songList.contains(songId))
            {
                checkGroupCompletion(achieveId, songId, songList);
            }
        }

        save();
    }

    static function checkGroupCompletion(achieveId:String, songId:String, requiredSongs:Array<String>):Void
    {
        if(isUnlocked(achieveId)) return;

        final a = get(achieveId);
        if(a == null) return;

        final beaten:Array<String> = (a.extra != null && Std.isOfType(a.extra, Array)) ? cast a.extra : [];
        if(!beaten.contains(songId))
        {
            beaten.push(songId);
            a.extra = beaten;
            save(); 
        }

        if(beaten.length >= requiredSongs.length)
            unlock(a.id);
    }

    public static function checkFinale():Void
    {
        if(isUnlocked('finale')) return;

        var itsFinale:Bool = true;
        for (a in achievements)
        {
            if (!itsFinale) break;
            if (a == get('finale')) continue;
            if (!isUnlocked(a.id)) itsFinale = false;
        }
        if (itsFinale) unlock('finale');
        save();
    }

    static var SECONDARY_CODES:Array<Array<Int>> = [
        [0, 0], [24, 4], [4, 10], [50, 3], [1, 72], [26, 16], [0, 67], [22, 74], [14, 2]
    ];

    public static function checkSecondaryCodes():Void
    {
        if(isUnlocked('secondary')) return;

        final a = get('secondary');
        if(a == null) return;

        final codes = cast(a.extra ?? []);
        if (codes.length >= SECONDARY_CODES.length) 
        {
            unlock(a.id);
            save();
        }
    }
}