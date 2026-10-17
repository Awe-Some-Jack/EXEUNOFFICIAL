package minigames.thevalley.tiles;

import flixel.FlxG;

class ShardHunt
{
	public var skulls(default, null):Int = 0;
	public var searched(default, null):Int = 0;
	public var found(default, null):Int = 0;

	public var missing(get, never):Int;
	inline function get_missing() return 6 - found < 0 ? 0 : 6 - found;

	public var complete(get, never):Bool;
	inline function get_complete() return found >= 6;

	public function new() {}

	public inline function addSkull():Void
	{
		skulls++;
	}

	public function search():Bool
	{
		final left = skulls - searched;
		final first = searched == 0;
		searched++;
		if (missing == 0) return false;

		final chance = first ? 1.0 : missing / Math.max(1, left - 2);
		if (chance < 1 && FlxG.random.float() >= chance) return false;
		found++;
		return true;
	}
}
