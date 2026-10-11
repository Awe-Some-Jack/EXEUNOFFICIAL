package minigames.preymini.character.monster;

import flixel.FlxBasic;
import flixel.FlxState;
import haxe.Json;
import minigames.preymini.character.monster.BigOven.BigOvenState;
import minigames.preymini.character.monster.HookBadnik.HookBadnikState;
import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

class EnemySpawner
{
	static final DROP_DELAY:Array<Float> = [0.7, 0.45];
	static final WINDUP:Array<Float> = [0.8, 0.55];

	static final BEE_HEIGHT:Array<Float> = [90, 130];
	static final HOOK_HEIGHT:Array<Float> = [70, 110];

	final _state:FlxState;
	final _terrain:Terrain;
	final _sonic:Sonic;
	final _hurt:Float->Void;
	final _grabbed:Void->Void;
	final _killed:Float->Float->Void;
	final _ovenHit:Float->Bool->Void;
	final _bossDown:Float->Float->Void;
	final _ovenSpots:Array<Array<Float>>;
	final _animals:Array<BurningAnimal> = [];
	final _respawnX:Float;
	final _respawnFloor:Float;

	final _bees:Array<FireBee> = [];
	final _hooks:Array<HookBadnik> = [];
	final _rushes:Array<RushBadnik> = [];
	final _kamas:Array<KamaBadnik> = [];
	final _blades:Array<KamaBlades> = [];
	final _ovens:Array<BigOven> = [];
	final _booms:Array<EnemyExplosion> = [];
	final _warnings:Array<RushWarning> = [];
	final _overlay:FlxCamera;
	final _last:Array<Int> = [];
	public var quiet:Bool = false;
	var _run:Float = 0;
	var _gap:Float;
	var _lastX:Float;

	public function new(state:FlxState, overlay:FlxCamera, terrain:Terrain, sonic:Sonic, hurt:Float->Void, grabbed:Void->Void, killed:Float->Float->Void,
			ovenHit:Float->Bool->Void, bossDown:Float->Float->Void, respawnX:Float, respawnFloor:Float)
	{
		_overlay = overlay;
		_grabbed = grabbed;
		_killed = killed;
		_ovenHit = ovenHit;
		_bossDown = bossDown;
		final data:{ bigovens:Array<Array<Float>> } = Json.parse(Paths.getContent(Paths.getPath("data/minigame/preymini/bigovens.json")));
		_ovenSpots = data.bigovens;
		_state = state;
		_terrain = terrain;
		_sonic = sonic;
		_hurt = hurt;
		_respawnX = respawnX;
		_respawnFloor = respawnFloor;
		_lastX = sonic.posX;
		_gap = _nextGap();
	}

	public function update(viewX:Float, viewHalf:Float):Void
	{
		_forget(viewX);
		_wakeOvens(viewX, viewHalf);
		if (quiet) return;
		_run += Math.max(0, _sonic.posX - _lastX);
		_lastX = _sonic.posX;
		if (_run < _gap || !_canSend(viewX + viewHalf)) return;
		_run = 0;
		_gap = _nextGap();
		_send(viewX + viewHalf + 12);
	}

	public function place():Void
	{
		for (bee in _bees) bee.place();
		for (hook in _hooks) hook.place();
		for (rush in _rushes) rush.place();
		for (kama in _kamas) kama.place();
		for (blades in _blades) blades.place();
		for (oven in _ovens) oven.place();
		for (boom in _booms) boom.place();
		for (animal in _animals) animal.place();
	}

	public function clear():Void
	{
		for (bee in _bees)
		{
			_drop(bee.box);
			_drop(bee);
		}
		for (hook in _hooks) _drop(hook);
		for (rush in _rushes) _drop(rush);
		for (kama in _kamas) _drop(kama);
		for (blades in _blades) _drop(blades);
		for (oven in _ovens) _drop(oven);
		for (warning in _warnings) _drop(warning);
		_bees.resize(0);
		_hooks.resize(0);
		_rushes.resize(0);
		_kamas.resize(0);
		_blades.resize(0);
		_ovens.resize(0);
		_warnings.resize(0);
	}

	public function grabber():Null<HookBadnik>
	{
		for (hook in _hooks)
			if (hook.alive && hook.state == Carry) return hook;
		return null;
	}

	function _broke(x:Float, y:Float):Void
	{
		_boom(x, y, 0);
		_animal(x, y);
		if (_killed != null) _killed(x, y);
	}

	function _animal(x:Float, y:Float):Void
	{
		final animal = new BurningAnimal(_terrain, x, y);
		_behindSonic(animal);
		_animals.push(animal);
		animal.place();
	}

	function _boom(x:Float, y:Float, delay:Float):Void
	{
		final boom = new EnemyExplosion(_terrain, x, y, delay);
		_state.insert(_state.members.indexOf(_sonic) + 1, boom);
		_booms.push(boom);
		boom.place();
	}

	function _burst(x:Float, y:Float, count:Int):Void
	{
		_boom(x, y, 0);
		for (i in 1...count)
		{
			final a = FlxG.random.float(0, Math.PI * 2), r = FlxG.random.float(16, 40);
			_boom(x + Math.cos(a) * r, y + Math.sin(a) * r * 0.8, i * 0.09);
		}
	}

	function _wakeOvens(viewX:Float, viewHalf:Float):Void
	{
		if (_sonic.dead || _sonic.leaving) return;
		for (spot in _ovenSpots.copy())
		{
			if (Math.abs(spot[0] - viewX) > viewHalf + 120) continue;
			_ovenSpots.remove(spot);
			final oven = new BigOven(_terrain, _sonic, spot[0], spot[1]);
			oven.onHurt = _hurt;
			oven.onHit = _ovenHit;
			oven.onDefeated = (cx, cy) ->
			{
				_burst(cx, cy, 6);
				_animal(cx - 12, cy);
				_animal(cx + 12, cy);
				if (_bossDown != null) _bossDown(cx, cy);
			};
			oven.onBlast = (cx, cy) ->
			{
				_burst(cx, cy, 3);
				FlxG.sound.play(Paths.sound("minigame/preymini/explosion"));
				final dx = _sonic.posX - cx, dy = _sonic.posY - cy;
				if (dx * dx + dy * dy <= 80 * 80) _hurt(cx);
			};
			_behindSonic(oven);
			_ovens.push(oven);
			oven.place();
		}
	}

	function _canSend(screenRight:Float):Bool
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed || !_sonic.controllable) return false;
		if (_sonic.posX < 450 || screenRight + 400 > _terrain.width) return false;
		return _bees.length + _hooks.length + _rushes.length + _kamas.length < 2 + (_progress() > 0.25 ? 1 : 0) + (_progress() > 2 / 3 ? 1 : 0);
	}

	function _send(x:Float):Void
	{
		final floor = _floorAhead(x + 40);
		final p = _progress();
		var kind = _pickKind();
		final spot = kind == 3 ? _groundSpot(x) : null;
		if (kind == 3 && spot == null) kind = 0;
		switch (kind)
		{
			case 0:
				final h = FlxG.random.float(BEE_HEIGHT[0], BEE_HEIGHT[1]);
				final bee = new FireBee(_terrain, _sonic, x, floor - h - 69, _lerp(DROP_DELAY, p));
				bee.onHurt = _hurt;
				bee.onKilled = _broke;
				_behindSonic(bee.box);
				_behindSonic(bee);
				_bees.push(bee);
			case 1:
				final h = FlxG.random.float(HOOK_HEIGHT[0], HOOK_HEIGHT[1]);
				final hook = new HookBadnik(_terrain, _sonic, x, floor - h - 65, _respawnX, _respawnFloor);
				hook.onGrab = _grabbed;
				hook.onHurt = _hurt;
				hook.onKilled = _broke;
				_state.insert(_state.members.indexOf(_sonic) + 1, hook);
				_hooks.push(hook);
			case 3:
				final kama = new KamaBadnik(_terrain, _sonic, spot[0], spot[1]);
				kama.onHurt = _hurt;
				kama.onKilled = _broke;
				kama.onThrow = blades ->
				{
					blades.onHurt = _hurt;
					_state.insert(_state.members.indexOf(_sonic) + 1, blades);
					_blades.push(blades);
					blades.place();
				};
				_behindSonic(kama);
				_kamas.push(kama);
			default:
				final rush = new RushBadnik(_terrain, _sonic, x, floor - 19 - 17.5, _lerp(WINDUP, p));
				rush.onHurt = _hurt;
				rush.onKilled = _broke;
				rush.onWindup = () ->
				{
					final warning = new RushWarning(rush, _overlay);
					_state.add(warning);
					_warnings.push(warning);
				};
				_behindSonic(rush);
				_rushes.push(rush);
		}
		place();
	}

	function _pickKind():Int
	{
		var kind = FlxG.random.int(0, 3);
		if (_last.length == 2 && _last[0] == _last[1] && kind == _last[0]) kind = (kind + FlxG.random.int(1, 3)) % 4;
		_last.push(kind);
		if (_last.length > 2) _last.shift();
		return kind;
	}

	function _groundSpot(x:Float):Null<Array<Float>>
	{
		for (step in 0...24)
		{
			final left = x + step * 8;
			final floor = _terrain.topAt(Std.int(left + 35), Std.int(_sonic.posY - 120));
			if (floor < 0 || Math.abs(floor - _sonic.posY) > 160) continue;
			var flat = true;
			for (i in 0...10)
			{
				final under = _terrain.topAt(Std.int(left + 16 + i * 4), floor - 60);
				if (under < floor - 1 || under > floor + 2)
				{
					flat = false;
					break;
				}
			}
			if (flat) return [left, floor];
		}
		return null;
	}

	function _floorAhead(x:Float):Float
	{
		final ahead = _terrain.topAt(Std.int(x), Std.int(_sonic.posY - 90));
		if (ahead >= 0 && ahead < _sonic.posY + 200) return ahead;
		final under = _terrain.topAt(Std.int(_sonic.posX), Std.int(_sonic.posY));
		return under >= 0 ? under : _sonic.posY + 19;
	}

	function _forget(viewX:Float):Void
	{
		final far = (x:Float) -> Math.abs(x - viewX) > 600;
		for (bee in _bees.copy())
			if (far(bee.posX) && (!bee.box.alive || far(bee.box.posX)))
			{
				_bees.remove(bee);
				_drop(bee.box);
				_drop(bee);
			}
		for (animal in _animals.copy())
			if (!animal.alive || far(animal.posX))
			{
				_animals.remove(animal);
				_drop(animal);
			}
		for (hook in _hooks.copy())
			if (!hook.alive || (hook.state != Carry && far(hook.posX)))
			{
				_hooks.remove(hook);
				_drop(hook);
			}
		for (rush in _rushes.copy())
			if (!rush.alive || far(rush.posX))
			{
				_rushes.remove(rush);
				_drop(rush);
			}
		for (kama in _kamas.copy())
			if (!kama.alive || far(kama.posX))
			{
				_kamas.remove(kama);
				_drop(kama);
			}
		for (blades in _blades.copy())
			if (!blades.alive || far(blades.posX))
			{
				_blades.remove(blades);
				_drop(blades);
			}
		for (oven in _ovens.copy())
			if (!oven.alive || (oven.state != Exploding && Math.abs(oven.midX - viewX) > 900))
			{
				_ovens.remove(oven);
				_drop(oven);
			}
		for (warning in _warnings.copy())
			if (warning.done)
			{
				_warnings.remove(warning);
				_drop(warning);
			}
		for (boom in _booms.copy())
			if (!boom.alive)
			{
				_booms.remove(boom);
				_drop(boom);
			}
	}

	function _behindSonic(sprite:FlxBasic):Void
	{
		_state.insert(_state.members.indexOf(_sonic), sprite);
	}

	function _drop(sprite:FlxBasic):Void
	{
		_state.remove(sprite, true);
		sprite.destroy();
	}

	function _nextGap():Float
	{
		final gap = 800 + (-420) * _progress();
		return gap * FlxG.random.float(0.75, 1.25);
	}

	inline function _progress():Float return Math.max(0, Math.min(1, _sonic.posX / _terrain.width));

	static inline function _lerp(range:Array<Float>, p:Float):Float return range[0] + (range[1] - range[0]) * p;
}
