package minigames.preymini.character.monster;

import minigames.preymini.map.Terrain;

class EnemyExplosion extends FlxSprite
{
	public var posX(default, null):Float;
	public var posY(default, null):Float;

	final _terrain:Terrain;
	var _wait:Float;

	public function new(terrain:Terrain, cx:Float, cy:Float, delay:Float = 0)
	{
		super();
		_terrain = terrain;
		_wait = delay;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Explosion");
		animation.addByPrefix("boom", "Explosion", 12.5, false);
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
		posX = cx - 58;
		posY = cy - 60;
		visible = false;
		if (_wait <= 0) _start();
	}

	override public function update(elapsed:Float):Void
	{
		if (_wait > 0)
		{
			_wait -= elapsed;
			if (_wait <= 0) _start();
			return;
		}
		super.update(elapsed);
		if (animation.finished) kill();
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}

	function _start():Void
	{
		_wait = 0;
		visible = true;
		animation.play("boom", true);
	}
}
