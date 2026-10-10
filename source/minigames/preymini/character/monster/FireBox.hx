package minigames.preymini.character.monster;

import haxe.io.Bytes;
import minigames.preymini.map.Terrain;

enum FireBoxState
{
	Carried;
	Falling;
	Exploding;
	Burning;
}

class FireBox extends FlxSprite
{
	public var state(default, null):FireBoxState = Carried;

	public var posX:Float = 0;
	public var posY:Float = 0;

	final _terrain:Terrain;
	var _vy:Float = 0;
	var _floor:Int = -1;
	final _fire:Map<Int, Bytes> = [];

	public function new(terrain:Terrain)
	{
		super();
		_terrain = terrain;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Fire_Box", null, false);
		animation.addByPrefix("box", "box", 10, true);
		animation.addByPrefix("explosion", "explosion", 10, false);
		animation.addByPrefix("burned", "burned", 10, true);
		animation.play("box");
		for (anim in ["explosion", "burned"])
			for (i in animation.getByName(anim).frames) _fire.set(i, _fireMask(i));
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
	}

	public var middleX(get, never):Float;
	inline function get_middleX() return posX + 83 + 33 / 2;

	public var bottom(get, never):Float;
	inline function get_bottom() return posY + 77;

	public function fallFrames():Float
	{
		final floor = _floorUnder();
		return floor < 0 ? Math.POSITIVE_INFINITY : Math.sqrt(2 * Math.max(0, floor - bottom) / 0.12);
	}

	public function drop():Void
	{
		if (state != Carried) return;
		state = Falling;
		FlxG.sound.play(Paths.sound("minigame/preymini/dropbox"));
		_vy = 0;
		_floor = _floorUnder();
	}

	public function touches(cx:Float, cy:Float, rx:Float, ry:Float):Bool
	{
		if (!alive) return false;
		final left = cx - rx, right = cx + rx, top = cy - ry, bottom = cy + ry;
		if (state == Carried || state == Falling)
			return right > posX + 83 && left < posX + 83 + 33 && bottom > posY + 46 && top < posY + 46 + 31;

		final mask = _fire.get(animation.frameIndex);
		if (mask == null) return false;
		final x0 = Std.int(Math.max(0, Math.floor(left - posX))), x1 = Std.int(Math.min(200, Math.ceil(right - posX)));
		final y0 = Std.int(Math.max(0, Math.floor(top - posY))), y1 = Std.int(Math.min(100, Math.ceil(bottom - posY)));
		for (y in y0...y1)
			for (x in x0...x1)
				if (mask.get(y * 200 + x) == 1) return true;
		return false;
	}

	function _fireMask(index:Int):Bytes
	{
		final mask = Bytes.alloc(20000);
		final frame = frames.frames[index];
		final bitmap = frames.parent.bitmap;
		final fx = Std.int(frame.frame.x), fy = Std.int(frame.frame.y);
		final ox = Std.int(frame.offset.x), oy = Std.int(frame.offset.y);
		for (y in 0...Std.int(frame.frame.height))
			for (x in 0...Std.int(frame.frame.width))
			{
				final argb = bitmap.getPixel32(fx + x, fy + y);
				final a = (argb >>> 24) & 0xFF, r = (argb >> 16) & 0xFF, b = argb & 0xFF;
				final cx = ox + x, cy = oy + y;
				if (a >= 128 && r >= 150 && r > b + 40 && cx < 200 && cy < 100) mask.set(cy * 200 + cx, 1);
			}
		return mask;
	}

	public function showCarried(frame:Int):Void
	{
		if (state == Carried && animation.curAnim != null) animation.curAnim.curFrame = frame;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		switch (state)
		{
			case Falling:
				final f = elapsed * 60;
				_vy = Math.min(_vy + 0.12 * f, 16);
				posY += _vy * f;
				if (_floor >= 0 && bottom >= _floor)
				{
					posY = _floor - 77;
					state = Exploding;
					animation.play("explosion", true);
					FlxG.sound.play(Paths.sound("minigame/preymini/hit"));
				}
				else if (_floor < 0 && posY > _terrain.height) kill();
			case Exploding:
				if (animation.finished)
				{
					state = Burning;
					animation.play("burned", true);
				}
			default:
		}
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}

	function _floorUnder():Int
	{
		return _terrain.topAt(Math.floor(middleX), Math.ceil(bottom));
	}
}
