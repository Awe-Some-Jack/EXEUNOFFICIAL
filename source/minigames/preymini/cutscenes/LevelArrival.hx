package minigames.preymini.cutscenes;

import flixel.FlxState;
import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;
import minigames.preymini.tiles.Rings;

class LevelArrival
{
	public var onDone:Void->Void = null;

	final _sonic:Sonic;
	final _terrain:Terrain;
	final _rings:Rings;
	final _actor:FlxSprite;
	final _rush:FlxSprite;
	final _holds:Array<Int> = [
		80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 100, 1000,
		80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 2000,
		100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1000, 80, 80, 80, 1500,
		80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 600, 80
	];

	var _t:Float = -1;

	public function new(state:FlxState, sonic:Sonic, terrain:Terrain, rings:Rings)
	{
		_sonic = sonic;
		_terrain = terrain;
		_rings = rings;
		_sonic.alpha = 0;
		_rings.collectable = false;

		_rush = new FlxSprite();
		_rush.frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Badnik_3", null, false);
		_rush.animation.addByPrefix("spin", "Badnik_3", 16, true);
		_rush.animation.play("spin");
		_pixel(_rush, 0, 0);

		_actor = new FlxSprite();
		_actor.frames = Paths.getSparrowAtlas("minigame/preymini/bg/cutscene/SonicIntro");
		_pixel(_actor, 105.5, 55);

		final at = state.members.indexOf(sonic) + 1;
		state.insert(at, _actor);
		state.insert(at, _rush);
	}

	public function start():Void
	{
		_t = 0;
		_actor.visible = true;
	}

	public function update(elapsed:Float):Void
	{
		if (_t < 0) return;
		final prev = _t;
		_t += elapsed;
		final sx = _sonic.posX, sy = _sonic.posY;
		final hit = _startOf(38);

		if (prev < 0.75 && _t >= 0.75) _sound("skid");
		if (prev < hit - 0.55 && _t >= hit - 0.55) _sound("badnickfast");
		if (prev < hit && _t >= hit)
		{
			_sound("loseRings");
			_rings.scatter(sx - 25.5, sy - 6, 16);
			FlxG.camera.shake(0.008, 0.25);
		}
		if (prev < _startOf(49) && _t >= _startOf(49)) _sound("jump");

		final rushX = sx - 92.5 + 300 * (_t - hit);
		_rush.visible = rushX > sx - 280 && rushX < sx + 280;
		_rush.x = _terrain.worldX(rushX);
		_rush.y = _terrain.worldY(sy - 14);

		if (_t < 0.75)
		{
			final p = _t / 0.75;
			_actor.animation.frameName = 'ball${StringTools.lpad(Std.string(Std.int(_t / 0.03) % 8), "0", 4)}';
			_put(sx - 250 + 198.5 * p, sy - 24 + 17 * p - 360 * p * (1 - p));
			return;
		}

		var ms = (_t - 0.75) * 1000;
		for (i in 0..._holds.length)
		{
			ms -= _holds[i];
			if (ms >= 0) continue;
			_actor.animation.frameName = 'intro${StringTools.lpad(Std.string(i + 6), "0", 4)}';
			_put(sx, sy);
			return;
		}
		_finish();
	}

	function _startOf(frame:Int):Float
	{
		var ms = 0;
		for (i in 0...frame - 6) ms += _holds[i];
		return 0.75 + ms / 1000;
	}

	function _put(artX:Float, artY:Float):Void
	{
		_actor.x = _terrain.worldX(artX) - 105.5;
		_actor.y = _terrain.worldY(artY) - 55;
	}

	function _finish():Void
	{
		_t = -1;
		_actor.kill();
		_rush.kill();
		_rings.collectable = true;
		_sonic.alpha = 1;
		_sonic.placeAt(_sonic.posX);
		if (onDone != null) onDone();
	}

	function _sound(name:String):Void
	{
		FlxG.sound.play(Paths.sound('minigame/preymini/$name'));
	}

	function _pixel(sprite:FlxSprite, pivotX:Float, pivotY:Float):Void
	{
		sprite.antialiasing = false;
		sprite.moves = false;
		sprite.scale.set(6, 6);
		sprite.updateHitbox();
		sprite.origin.set(pivotX, pivotY);
		sprite.offset.set(0, 0);
		sprite.visible = false;
	}
}
