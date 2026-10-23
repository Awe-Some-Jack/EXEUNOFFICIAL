package minigames.preymini.tiles;

import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

private enum RingState
{
	Placed;
	Flying;
	Sparkling;
}

private class Ring extends FlxSprite
{
	public var state:RingState = Placed;
	public var cx:Float = 0;
	public var cy:Float = 0;
	public var xsp:Float = 0;
	public var ysp:Float = 0;
	public var life:Float = 0;
	public var age:Float = 0;

	public function new()
	{
		super();
		frames = Paths.getSparrowAtlas("minigame/preymini/objects/ring");
		animation.addByPrefix("spin", "ring", 8, true);
		animation.addByPrefix("sparkle", "sparkle", 8, false);
		animation.play("spin");
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
	}
}

class Rings extends FlxTypedGroup<Ring>
{
	public var onCollect:Void->Void = null;

	public var collectable:Bool = true;

	final _terrain:Terrain;
	final _sonic:Sonic;

	public function new(terrain:Terrain, sonic:Sonic)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		final data:{ rings:Array<Array<Float>> } = Json.parse(Paths.getContent(Paths.getPath("data/minigame/preymini/rings.json")));
		for (at in data.rings)
		{
			final ring = recycle(Ring, () -> new Ring());
			ring.state = Placed;
			ring.cx = at[0];
			ring.cy = at[1];
			ring.animation.play("spin");
		}
	}

	public function scatter(x:Float, y:Float, count:Int):Void
	{
		final n = Std.int(Math.min(count, 32));
		for (i in 0...n)
		{
			final speed = i < 16 ? 4 : 2;
			final step = Std.int((i % 16) / 2);
			final angle = (11.25 + step * 22.5) * Math.PI / 180;
			final side = i % 2 == 0 ? 1 : -1;
			final ring = recycle(Ring, () -> new Ring());
			ring.state = Flying;
			ring.cx = x;
			ring.cy = y;
			ring.xsp = Math.sin(angle) * speed * side;
			ring.ysp = -Math.cos(angle) * speed;
			ring.life = 255;
			ring.age = 0;
			ring.visible = true;
			ring.animation.play("spin", true);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		final f = elapsed * 60;
		final canTake = collectable && !_sonic.dead && !_sonic.leaving && !_sonic.grabbed && !_sonic.hurting;
		for (ring in members)
		{
			if (ring == null || !ring.alive) continue;
			switch (ring.state)
			{
				case Flying:
					ring.age += f;
					ring.life -= f;
					if (ring.life <= 0)
					{
						ring.kill();
						continue;
					}
					ring.cx += ring.xsp * f;
					ring.cy += ring.ysp * f;
					ring.ysp += (24 / 256) * f;
					if (ring.ysp > 0 && _terrain.solidAt(Math.floor(ring.cx), Math.floor(ring.cy + 8)))
					{
						while (_terrain.solidAt(Math.floor(ring.cx), Math.floor(ring.cy + 8))) ring.cy -= 1;
						ring.ysp = -(ring.ysp * 0.75);
					}
					if (canTake && ring.age >= 30 && _touches(ring)) _take(ring);
				case Placed:
					if (canTake && _touches(ring)) _take(ring);
				case Sparkling:
					if (ring.animation.finished) ring.kill();
			}
		}
	}

	public function place():Void
	{
		for (ring in members)
		{
			if (ring == null || !ring.alive) continue;
			ring.x = _terrain.worldX(ring.cx - 8);
			ring.y = _terrain.worldY(ring.cy - 8);
		}
	}

	function _touches(ring:Ring):Bool
	{
		return Math.abs(ring.cx - _sonic.posX) < 6 + _sonic.hitRadiusX && Math.abs(ring.cy - _sonic.posY) < 6 + _sonic.hitRadiusY;
	}

	function _take(ring:Ring):Void
	{
		ring.state = Sparkling;
		ring.animation.play("sparkle", true);
		FlxG.sound.play(Paths.sound("minigame/preymini/Ringer"), 0.8);
		if (onCollect != null) onCollect();
	}
}
