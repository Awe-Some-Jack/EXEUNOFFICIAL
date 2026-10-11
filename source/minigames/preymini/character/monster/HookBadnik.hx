package minigames.preymini.character.monster;

import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

enum HookBadnikState
{
	Hover;
	Chase;
	Carry;
	Return;
}

class HookBadnik extends FlxSprite
{
	static final _hookCache:Map<String, Array<Array<Int>>> = new Map();

	public var state(default, null):HookBadnikState = Hover;

	public var onGrab:Void->Void = null;

	public var onHurt:Float->Void = null;

	public var onKilled:Float->Float->Void = null;

	public var escape(get, never):Float;
	inline function get_escape() return state == Carry ? Math.min(1, _struggle / 8) : 0;

	public var posX(default, null):Float;
	public var posY(default, null):Float;

	final _terrain:Terrain;
	final _sonic:Sonic;
	final _homeX:Float;
	final _homeY:Float;
	final _respawnX:Float;
	final _respawnY:Float;
	final _hooks:Array<Array<Int>> = [];
	var _struggle:Float = 0;
	var _stun:Float = 0;
	var _body:PixelMask;

	public function new(terrain:Terrain, sonic:Sonic, artX:Float, artY:Float, respawnX:Float, respawnFloor:Float)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		posX = _homeX = artX;
		posY = _homeY = artY;
		_respawnX = respawnX;
		_respawnY = respawnFloor;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Badnik_1", null, false);
		animation.addByPrefix("fly", "Badnik_1", 10, true);
		animation.play("fly");
		
		final cacheKey = "Badnik_1_fly";
		if (_hookCache.exists(cacheKey))
		{
			for (h in _hookCache.get(cacheKey)) _hooks.push(h);
		}
		else
		{
			for (i in animation.getByName("fly").frames)
			{
				final h = _findHook(i);
				_hooks.push(h);
			}
			_hookCache.set(cacheKey, _hooks);
		}

		_body = new PixelMask(this, "fly");
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		final f = elapsed * 60;
		_stun = Math.max(0, _stun - elapsed);
		if (_sonic.dead || _sonic.leaving)
		{
			if (state == Carry || state == Chase) state = Return;
		}

		switch (state)
		{
			case Hover:
				if (_sees()) state = Chase;
			case Chase:
				final dx = _sonic.posX - _hookX(), dy = _sonic.posY - _hookY();
				if (Math.abs(dx) > 420 || Math.abs(dy) > 420) state = Return;
				else
				{
					_fly(_sonic.posX - _hookOffsetX(), _sonic.posY - _hookOffsetY(), 2 * f);
					if (_hookTouches()) _grab();
				}
			case Carry:
				_struggle = Math.max(0, _struggle - 3 * elapsed) + _sonic.struggles();
				if (_struggle >= 8)
				{
					_sonic.release(-4);
					_stun = 2;
					state = Return;
				}
				else
				{
					final sonicY = _respawnY - 19 - 24;
					final there = _fly(_respawnX - _hookOffsetX(), sonicY - 12 - _hookBottom(), 4.5 * f);
					_hang();
					if (there)
					{
						_sonic.release(0);
						_stun = 2;
						state = Return;
					}
				}
			case Return:
				if (_fly(_homeX, _homeY, 2 * f)) state = Hover;
				else if (_stun <= 0 && _sees()) state = Chase;
		}
		_touchSonic();
	}

	function _touchSonic():Void
	{
		if (!alive || state == Carry || _sonic.dead || _sonic.leaving || _sonic.grabbed) return;
		final frame = animation.curAnim != null ? animation.curAnim.curFrame : 0;
		if (!_body.touches(frame, posX, posY, flipX, _sonic.posX, _sonic.posY, _sonic.hitRadiusX, _sonic.hitRadiusY)) return;
		if (_sonic.attacking)
		{
			kill();
			if (onKilled != null) onKilled(posX + frameWidth / 2, posY + frameHeight / 2);
		}
		else if (_stun <= 0 && onHurt != null) onHurt(posX + frameWidth / 2);
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}

	function _sees():Bool
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed || _stun > 0) return false;
		return Math.abs(_sonic.posX - _hookX()) <= 180 && Math.abs(_sonic.posY - _hookY()) <= 160;
	}

	function _grab():Void
	{
		state = Carry;
		_struggle = 0;
		if (onGrab != null) onGrab();
		_sonic.grab();
		_hang();
	}

	function _hang():Void
	{
		_sonic.hangAt(posX + _hookOffsetX(), posY + _hookBottom() + 12);
	}

	function _fly(tx:Float, ty:Float, step:Float):Bool
	{
		final dx = tx - posX, dy = ty - posY;
		final dist = Math.sqrt(dx * dx + dy * dy);
		if (Math.abs(dx) > 0.5) flipX = dx > 0;
		if (dist <= step)
		{
			posX = tx;
			posY = ty;
			return true;
		}
		posX += dx / dist * step;
		posY += dy / dist * step;
		return false;
	}

	function _hookTouches():Bool
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed || _sonic.hurting || _sonic.invulnerable || _stun > 0) return false;
		final left = _sonic.posX - _sonic.hitRadiusX, right = _sonic.posX + _sonic.hitRadiusX;
		final top = _sonic.posY - _sonic.hitRadiusY, bottom = _sonic.posY + _sonic.hitRadiusY;
		final hook = _hook();
		var i = 0;
		while (i < hook.length)
		{
			final hx = posX + _flipped(hook[i]) + 0.5, hy = posY + hook[i + 1] + 0.5;
			if (hx >= left && hx <= right && hy >= top && hy <= bottom) return true;
			i += 2;
		}
		return false;
	}

	inline function _hook():Array<Int> return _hooks[animation.curAnim != null ? animation.curAnim.curFrame : 0];

	inline function _flipped(x:Int):Float return flipX ? frameWidth - 1 - x : x;

	function _hookOffsetX():Float
	{
		final hook = _hook();
		var sum = 0.0;
		var i = 0;
		while (i < hook.length) { sum += _flipped(hook[i]) + 0.5; i += 2; }
		return sum / (hook.length / 2);
	}

	function _hookOffsetY():Float
	{
		final hook = _hook();
		var sum = 0.0;
		var i = 1;
		while (i < hook.length) { sum += hook[i] + 0.5; i += 2; }
		return sum / (hook.length / 2);
	}

	function _hookBottom():Float
	{
		final hook = _hook();
		var bottom = 0;
		var i = 1;
		while (i < hook.length) { if (hook[i] + 1 > bottom) bottom = hook[i] + 1; i += 2; }
		return bottom;
	}

	inline function _hookX():Float return posX + _hookOffsetX();
	inline function _hookY():Float return posY + _hookOffsetY();

	function _findHook(index:Int):Array<Int>
	{
		final frame = frames.frames[index];
		final bitmap = frames.parent.bitmap;
		final fx = Std.int(frame.frame.x), fy = Std.int(frame.frame.y);
		final ox = Std.int(frame.offset.x), oy = Std.int(frame.offset.y);
		final w = Std.int(frame.frame.width), h = Std.int(frame.frame.height);
		final opaque = (x:Int, y:Int) -> x >= 0 && x < w && y >= 0 && y < h && (bitmap.getPixel32(fx + x, fy + y) >>> 24) & 0xFF > 0;

		var bottom = -1;
		for (y in 0...h)
			for (x in 0...w)
				if (opaque(x, y)) bottom = y;
		final seen = new Map<Int, Bool>();
		final todo = [for (x in 0...w) if (opaque(x, bottom)) x + bottom * w];
		for (p in todo) seen.set(p, true);
		final hook:Array<Int> = [];
		while (todo.length > 0)
		{
			final p = todo.pop();
			final x = p % w, y = Std.int(p / w);
			hook.push(ox + x);
			hook.push(oy + y);
			for (dy in -1...2)
				for (dx in -1...2)
				{
					final nx = x + dx, ny = y + dy, n = nx + ny * w;
					if (ny > bottom - 11 && opaque(nx, ny) && !seen.exists(n))
					{
						seen.set(n, true);
						todo.push(n);
					}
				}
		}
		return hook;
	}
}