package minigames.preymini.character.monster;

import minigames.preymini.map.Terrain;

class BurningAnimal extends FlxSprite
{
	public var posX(default, null):Float;
	public var posY(default, null):Float;

	final _terrain:Terrain;
	var _vy:Float = -2;
	var _floor:Float;
	var _life:Float = 3;

	public function new(terrain:Terrain, cx:Float, cy:Float)
	{
		super();
		_terrain = terrain;
		final name = FlxG.random.bool() ? "Animal_Burning" : "Animal_Burning2";
		frames = Paths.getSparrowAtlas('minigame/preymini/characters/enemys/$name');
		animation.addByPrefix("burn", name, 10, true);
		animation.play("burn");
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
		posX = cx - frameWidth / 2;
		posY = cy - frameHeight / 2;
		final floor = terrain.topAt(Math.floor(cx), Math.floor(cy));
		_floor = floor >= 0 ? floor : terrain.height + frameHeight;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		final f = elapsed * 60;
		if (posY + frameHeight < _floor)
		{
			_vy += 0.21875 * f;
			posY = Math.min(posY + _vy * f, _floor - frameHeight);
		}
		_life -= elapsed;
		visible = _life > 0.6 || Std.int(_life / 0.08) % 2 == 0;
		if (_life <= 0) kill();
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}
}
