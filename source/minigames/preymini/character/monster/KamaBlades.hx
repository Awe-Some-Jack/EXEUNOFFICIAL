package minigames.preymini.character.monster;

import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

class KamaBlades extends FlxSprite
{
	public var onHurt:Float->Void = null;

	public var posX(default, null):Float;
	public var posY(default, null):Float;

	final _terrain:Terrain;
	final _sonic:Sonic;
	final _owner:KamaBadnik;
	final _body:PixelMask;
	var _vx:Float;
	var _vy:Float;
	final _top:Float;
	var _age:Float = 0;
	var _fading:Float = -1;

	public function new(terrain:Terrain, sonic:Sonic, owner:KamaBadnik, cx:Float, cy:Float, vx:Float, vy:Float)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		_owner = owner;
		_vx = vx;
		_vy = vy;
		_top = Math.max(2.4, Math.sqrt(vx * vx + vy * vy));
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Badnik5_Projectile", null, false);
		animation.addByPrefix("spin", "Badnik5_Projectile", 14, true);
		animation.play("spin");
		_body = new PixelMask(this, "spin");
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
		flipX = vx > 0;
		posX = cx - 31;
		posY = cy - 20;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!alive) return;
		final f = elapsed * 60;
		_age += elapsed;

		if (_fading >= 0 || !_owner.alive || !_owner.exists || _age > 6)
		{
			if (_fading < 0) _fading = 0.4;
			_fading -= elapsed;
			alpha = Math.max(0, _fading / 0.4);
			posX += _vx * f;
			posY += _vy * f;
			if (_fading <= 0) kill();
			return;
		}

		final dx = _owner.handX - (posX + 31), dy = _owner.handY - (posY + 20);
		final dist = Math.max(0.001, Math.sqrt(dx * dx + dy * dy));
		_vx += dx / dist * 0.05 * f;
		_vy += dy / dist * 0.05 * f;
		final speed = Math.sqrt(_vx * _vx + _vy * _vy);
		if (speed > _top)
		{
			_vx *= _top / speed;
			_vy *= _top / speed;
		}
		posX += _vx * f;
		posY += _vy * f;
		animation.curAnim.frameRate = 10 + 8 * Math.min(1, speed / _top);

		if (_age > 0.4 && dist < 10 && _vx * dx + _vy * dy > 0)
		{
			_owner.catchBlades();
			kill();
			return;
		}

		if (_sonic.dead || _sonic.leaving || _sonic.grabbed || _sonic.hurting || _sonic.invulnerable) return;
		final frame = animation.curAnim != null ? animation.curAnim.curFrame : 0;
		if (_body.touches(frame, posX, posY, flipX, _sonic.posX, _sonic.posY, _sonic.hitRadiusX, _sonic.hitRadiusY) && onHurt != null)
			onHurt(posX + 31);
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}
}
