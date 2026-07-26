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
        if(get(name) != null)
            get(name).unlocked = true; 
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

        var deathList:Array<String> = cast get('die').extra ??= [];

        if(deathList.contains(songId)) return;
        deathList.push(songId);

        trace(get('die'));

        var allSongs:Array<String> = [];
        for(name => week in WeekData.weeksLoaded.keyValueIterator())
            for (song in week.songs)
                allSongs.push(song[0]);

        trace(allSongs);
        if(allSongs.length == deathList.length) get('die').unlocked = true;
    }
}