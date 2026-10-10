package minigames.preymini.character.monster;

import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

enum BigOvenState
{
	Waiting;
	Walking;
	Stunned;
	Alert;
	Exploding;
}

class BigOven extends FlxSprite
{
	public var state(default, null):BigOvenState = Waiting;

	public var defeated(default, null):Bool = false;

	public var onHurt:Float->Void = null;

	public var onHit:Float->Bool->Void = null;

	public var onDefeated:Float->Float->Void = null;

	public var onBlast:Float->Float->Void = null;

	public var posX(default, null):Float;
	public var posY(default, null):Float;

	public var midX(get, never):Float;
	inline function get_midX() return posX + (flipX ? 371 - 111 : 111);

	public var midY(get, never):Float;
	inline function get_midY() return posY + 131;

	final _terrain:Terrain;
	final _sonic:Sonic;
	final _body:PixelMask;
	var _hp:Int = 3;
	var _timer:Float = 0;
	var _guard:Float = 0;
	var _near:Float = 0;
	var _recovering:Bool = false;

	public function new(terrain:Terrain, sonic:Sonic, footX:Float, floorY:Float)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/BigOven", null, false);
		animation.addByPrefix("walk", "BigOven_Walk", 10, true);
		animation.addByIndices("damaged", "BigOven_Damaged", [0, 1, 2, 3, 4], "", 12.5, false);
		animation.addByIndices("recover", "BigOven_Damaged", [5], "", 1, false);
		animation.addByPrefix("alert", "BigOven_Alert", 8, true);
		animation.addByIndices("explode", "BigOven_Explosion", [0, 1, 2, 3, 4], "", 10, false);
		_body = new PixelMask(this, "walk");
		animation.play("walk");
		animation.pause();
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
		posX = footX - 111;
		posY = floorY - 168;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!alive) return;
		_guard = Math.max(0, _guard - elapsed);
		visible = state == Exploding || _guard <= 0 || Std.int(_guard / 0.06) % 2 == 0;
		offset.x = 0;

		switch (state)
		{
			case Waiting:
				if (!_sonic.dead && Math.abs(_sonic.posX - midX) <= 280 && Math.abs(_sonic.posY - midY) <= 160)
				{
					state = Walking;
					animation.play("walk");
				}
			case Walking:
				_walk(elapsed);
				final close = !_sonic.dead && !_sonic.leaving && Math.abs(_sonic.posX - midX) <= 46 && Math.abs(_sonic.posY - midY) <= 70;
				_near = close ? _near + elapsed : Math.max(0, _near - elapsed * 0.5);
				if (_near >= 0.6) _alert(1.3);
			case Stunned:
				_timer -= elapsed;
				if (!_recovering && animation.finished)
				{
					_recovering = true;
					animation.play("recover");
				}
				if (_timer <= 0)
				{
					if (defeated) _alert(0.9);
					else
					{
						state = Walking;
						_near = 0;
						animation.play("walk");
					}
				}
			case Alert:
				_timer -= elapsed;
				final urgency = 1 - Math.max(0, _timer) / (defeated ? 0.9 : 1.3);
				animation.curAnim.frameRate = 8 + 22 * urgency;
				offset.x = (Std.int(_timer / 0.03) % 2 == 0 ? 1 : -1) * 6 * urgency;
				if (_timer <= 0) _explode();
			case Exploding:
				_timer -= elapsed;
				if (animation.finished) visible = false;
				if (_timer <= 0) kill();
		}

		if (state != Exploding) _touchSonic();
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}

	function _walk(elapsed:Float):Void
	{
		final dir = _sonic.posX > midX + 4 ? 1 : (_sonic.posX < midX - 4 ? -1 : 0);
		if (dir == 0) return;
		if (flipX != (dir > 0))
		{
			final keep = midX;
			flipX = dir > 0;
			posX = keep - (flipX ? 371 - 111 : 111);
		}
		final step = dir * 0.55 * elapsed * 60;
		final foot = posY + 168;
		final aheadX = Std.int(midX + step + dir * 22);
		final floor = _terrain.topAt(aheadX, Std.int(foot - 12));
		if (floor < 0 || Math.abs(floor - foot) > 6) return;
		posX += step;
		final under = _terrain.topAt(Std.int(midX), Std.int(foot - 12));
		if (under >= 0 && Math.abs(under - foot) <= 6) posY = under - 168;
	}

	function _alert(time:Float):Void
	{
		state = Alert;
		_timer = time;
		animation.play("alert", true);
	}

	function _explode():Void
	{
		state = Exploding;
		_timer = 1.5;
		offset.x = 0;
		visible = true;
		animation.play("explode", true);
		if (defeated)
		{
			if (onDefeated != null) onDefeated(midX, midY);
		}
		else if (onBlast != null) onBlast(midX, midY);
	}

	function _touchSonic():Void
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed) return;
		final frame = animation.curAnim != null && animation.name == "walk" ? animation.curAnim.curFrame : 0;
		if (!_body.touches(frame, posX, posY, flipX, _sonic.posX, _sonic.posY, _sonic.hitRadiusX, _sonic.hitRadiusY)) return;
		if (_sonic.attacking)
		{
			if (_guard > 0 || defeated)
			{
				if (onHit != null) onHit(midX, false);
				return;
			}
			_hp--;
			_guard = 1;
			if (_hp <= 0) defeated = true;
			state = Stunned;
			_timer = defeated ? 0.5 : 1.0;
			_recovering = false;
			animation.play("damaged", true);
			if (onHit != null) onHit(midX, true);
		}
		else if (!defeated && onHurt != null) onHurt(midX);
	}
}
