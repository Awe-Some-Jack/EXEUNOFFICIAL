package minigames.preymini.character.monster;

import haxe.io.Bytes;

import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

enum RushBadnikState
{
	Waiting;
	WindingUp;
	Rushing;
}

class RushBadnik extends FlxSprite
{
	static final _rushMaskCache:Map<String, Array<Bytes>> = new Map();

	public var state(default, null):RushBadnikState = Waiting;

	public var onHurt:Float->Void = null;

	public var onKilled:Float->Float->Void = null;

	public var onWindup:Void->Void = null;

	public var dir(get, never):Int;
	inline function get_dir() return _dir;

	public var posX(default, null):Float;
	public var posY(default, null):Float;

	final _terrain:Terrain;
	final _sonic:Sonic;
	final _homeX:Float;
	final _masks:Array<Bytes> = [];
	final _windup:Float;
	var _dir:Int = -1;
	var _wound:Float = 0;

	public function new(terrain:Terrain, sonic:Sonic, artX:Float, artY:Float, windup:Float = 0)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		_windup = windup;
		posX = _homeX = artX;
		posY = artY;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Badnik_3", null, false);
		animation.addByPrefix("spin", "Badnik_3", 10, true);
		animation.play("spin");

		final cacheKey = "Badnik_3_spin";
		if (_rushMaskCache.exists(cacheKey))
		{
			for (m in _rushMaskCache.get(cacheKey))
			{
				_masks.push(m);
			}
		}
		else
		{
			for (i in animation.getByName("spin").frames)
			{
				_masks.push(_mask(i));
			}
			_rushMaskCache.set(cacheKey, _masks);
		}

		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!alive) return;
		final midX = posX + frameWidth / 2, midY = posY + frameHeight / 2;
		switch (state)
		{
			case Waiting:
				if (!_sonic.dead && !_sonic.leaving && _onScreen() && Math.abs(_sonic.posX - midX) <= 260 && Math.abs(_sonic.posY - midY) <= 120)
				{
					_dir = _sonic.posX >= midX ? 1 : -1;
					state = WindingUp;
					if (onWindup != null) onWindup();
				}
			case WindingUp:
				_wound += elapsed;
				visible = Std.int(_wound / 0.08) % 2 == 0;
				if (_wound >= _windup)
				{
					visible = true;
					state = Rushing;
					FlxG.sound.play(Paths.sound("minigame/preymini/badnickfast"));
				}
			case Rushing:
				posX += _dir * 3 * elapsed * 60;
				if (Math.abs(posX - _homeX) > 900)
				{
					kill();
					return;
				}
		}
		if (!_sonic.dead && !_sonic.leaving && !_sonic.grabbed && _touches())
		{
			if (_sonic.attacking)
			{
				kill();
				if (onKilled != null) onKilled(posX + frameWidth / 2, posY + frameHeight / 2);
			}
			else if (onHurt != null) onHurt(posX + frameWidth / 2);
		}
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}

	function _onScreen():Bool
	{
		final cam = camera != null ? camera : FlxG.camera;
		return x >= cam.viewLeft + 144 && x + frameWidth * 6 <= cam.viewRight - 144;
	}

	function _touches():Bool
	{
		if (_masks.length == 0) return false;
		final mask = _masks[animation.curAnim != null ? animation.curAnim.curFrame : 0];
		final x0 = Std.int(Math.max(0, Math.floor(_sonic.posX - _sonic.hitRadiusX - posX)));
		final x1 = Std.int(Math.min(frameWidth, Math.ceil(_sonic.posX + _sonic.hitRadiusX - posX)));
		final y0 = Std.int(Math.max(0, Math.floor(_sonic.posY - _sonic.hitRadiusY - posY)));
		final y1 = Std.int(Math.min(frameHeight, Math.ceil(_sonic.posY + _sonic.hitRadiusY - posY)));
		for (y in y0...y1)
			for (x in x0...x1)
				if (mask.get(y * frameWidth + x) == 1) return true;
		return false;
	}

	function _mask(index:Int):Bytes
	{
		final frame = frames.frames[index];
		final bitmap = frames.parent.bitmap;
		final w = Std.int(frame.sourceSize.x), h = Std.int(frame.sourceSize.y);
		final mask = Bytes.alloc(w * h);
		final fx = Std.int(frame.frame.x), fy = Std.int(frame.frame.y);
		final ox = Std.int(frame.offset.x), oy = Std.int(frame.offset.y);
		for (y in 0...Std.int(frame.frame.height))
			for (x in 0...Std.int(frame.frame.width))
			{
				final cx = ox + x, cy = oy + y;
				if (cx < w && cy < h && (bitmap.getPixel32(fx + x, fy + y) >>> 24) & 0xFF >= 128) mask.set(cy * w + cx, 1);
			}
		return mask;
	}
}