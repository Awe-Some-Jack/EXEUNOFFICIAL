package backend;

import flixel.util.FlxSave;
import haxe.Json;

class SongProgress
{
	public static function beatenSongs():Array<String>
	{
		final save:FlxSave = new FlxSave();
		backend.CoolUtil.bindSave(save, 'savedSongs', CoolUtil.getSavePath());
		final songs:Array<String> = save.data.songs;
		return songs ?? [];
	}

	public static function openedSongs():Array<String>
	{
		final save:FlxSave = new FlxSave();
		backend.CoolUtil.bindSave(save, 'savedSongs', CoolUtil.getSavePath());
		final songs:Array<String> = save.data.openedSongs;
		return songs ?? [];
	}

	public static function markOpened(song:String):Void
	{
		final save:FlxSave = new FlxSave();
		backend.CoolUtil.bindSave(save, 'savedSongs', CoolUtil.getSavePath());
		final saved:Null<Array<String>> = save.data.openedSongs;
		final songs:Array<String> = saved ?? [];
		if (songs.contains(song)) return;
		songs.push(song);
		save.data.openedSongs = songs;
		save.flush();
	}

	static function allWeeks():Map<String, WeekData>
	{
		final keepList = WeekData.weeksList;
		final keepLoaded = WeekData.weeksLoaded;
		WeekData.weeksLoaded = new Map<String, WeekData>();
		try { WeekData.reloadWeekFiles(false); }
		catch (e:Dynamic) {}
		final allLoaded = WeekData.weeksLoaded;
		WeekData.weeksList = keepList;
		WeekData.weeksLoaded = keepLoaded;
		return allLoaded;
	}

	static function weekBeaten(week:WeekData, beaten:Array<String>):Bool
	{
		if (week == null || week.songs == null) return true;
		for (song in week.songs)
		{
			final name:String = Paths.formatToSongPath(song[0]);
			if (name != 'stardust-speedway' && !beaten.contains(name)) return false;
		}
		return true;
	}

	public static function soundTestComplete():Bool
	{
		final path = 'assets/exe/soundtest/extraCodes.json';
		if (!openfl.utils.Assets.exists(path)) return false;

		var codes:Array<Dynamic> = null;
		try { codes = Json.parse(openfl.utils.Assets.getText(path)); }
		catch (e:Dynamic) { return false; }

		try
		{
			final weeks = allWeeks();
			final beaten = beatenSongs();
			var anyWeek = false;
			for (code in codes)
			{
				if (code.type != 'week') continue;
				anyWeek = true;
				if (!weekBeaten(weeks.get(code.weekName), beaten)) return false;
			}
			return anyWeek;
		}
		catch (e:Dynamic) { return false; }
	}

	public static function gameComplete():Bool
	{
		try
		{
			final weeks = allWeeks();
			final beaten = beatenSongs();
			var anyWeek = false;
			for (week in weeks)
			{
				anyWeek = true;
				if (!weekBeaten(week, beaten)) return false;
			}
			return anyWeek;
		}
		catch (e:Dynamic) { return false; }
	}
}
