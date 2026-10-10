package minigames.preymini.character.monster;

import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

class KamaBadnik extends FlxSprite
{
	public var onHurt:Float->Void = null;

	public var onKilled:Float->Float->Void = null;

	public var onThrow:KamaBlades->Void = null;

	public var posX(default, null):Float;
	public var posY(default, null):Float;

	public var handX(get, never):Float;
	inline function get_handX() return posX + (flipX ? 65 - 25 : 25);

	public var handY(get, never):Float;
	inline function get_handY() return posY + 18;

	final _terrain:Terrain;
	final _sonic:Sonic;
	final _armedBody:PixelMask;
	final _bareBody:PixelMask;
	var _armed:Bool = true;
	var _winding:Float = -1;
	var _flying:Bool = false;
	var _rest:Float = 0;

	public function new(terrain:Terrain, sonic:Sonic, artX:Float, floorY:Float)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Badnik5", null, false);
		animation.addByPrefix("knife", "Badnik5_Knife", 10, true);
		animation.addByPrefix("noknife", "Badnik5_NOKnife", 10, true);
		_armedBody = new PixelMask(this, "knife");
		_bareBody = new PixelMask(this, "noknife");
		animation.play("knife");
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);
		posX = artX;
		posY = floorY - 45;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!alive) return;
		final midX = posX + 35, midY = posY + 26;
		if (_winding < 0 && !_flying) flipX = _sonic.posX > midX;
		_rest = Math.max(0, _rest - elapsed);

		if (_armed && _winding < 0 && _rest <= 0 && _sees(midX, midY)) _winding = 0;
		if (_winding >= 0)
		{
			_winding += elapsed;
			offset.x = (Std.int(_winding / 0.04) % 2 == 0 ? 1 : -1) * 6;
			animation.curAnim.frameRate = 24;
			if (_winding >= 0.45) _throw();
		}
		_touchSonic(midX, midY);
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
	}

	function _sees(midX:Float, midY:Float):Bool
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed) return false;
		final cam = camera != null ? camera : FlxG.camera;
		if (x < cam.viewLeft || x + frameWidth * 6 > cam.viewRight) return false;
		return Math.abs(_sonic.posX - midX) <= 150 && Math.abs(_sonic.posY - midY) <= 90;
	}

	public function catchBlades():Void
	{
		if (!alive || !exists) return;
		_flying = false;
		_armed = true;
		_rest = 1.5;
		animation.play("knife", true);
	}

	function _throw():Void
	{
		_armed = false;
		_flying = true;
		_winding = -1;
		offset.x = 0;
		animation.play("noknife", true);
		final dx = _sonic.posX - handX, dy = _sonic.posY - handY;
		final len = Math.max(1, Math.sqrt(dx * dx + dy * dy));
		final speed = Math.sqrt(2 * 0.05 * (len + 16));
		final blades = new KamaBlades(_terrain, _sonic, this, handX, handY, dx / len * speed, dy / len * speed);
		if (onThrow != null) onThrow(blades);
	}

	function _touchSonic(midX:Float, midY:Float):Void
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed) return;
		final frame = animation.curAnim != null ? animation.curAnim.curFrame : 0;
		final body = _armed ? _armedBody : _bareBody;
		if (!body.touches(frame, posX, posY, flipX, _sonic.posX, _sonic.posY, _sonic.hitRadiusX, _sonic.hitRadiusY)) return;
		if (_sonic.attacking)
		{
			kill();
			if (onKilled != null) onKilled(midX, midY);
		}
		else if (onHurt != null) onHurt(midX);
	}
}
