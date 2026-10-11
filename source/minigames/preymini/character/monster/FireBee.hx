package minigames.preymini.character.monster;

import minigames.preymini.character.player.Sonic;
import minigames.preymini.map.Terrain;

class FireBee extends FlxSprite
{
	public static final BOX_AT_Y:Array<Float> = [38, 38, 37, 36, 37];

	public final box:FireBox;

	public var onHurt:Float->Void = null;

	public var onKilled:Float->Float->Void = null;

	public var broken(default, null):Bool = false;

	public var posX(default, null):Float;
	public var posY(default, null):Float;

	final _terrain:Terrain;
	final _sonic:Sonic;
	final _dropDelay:Float;
	final _baseY:Float;
	final _body:PixelMask;
	var _age:Float = 0;

	public function new(terrain:Terrain, sonic:Sonic, artX:Float, artY:Float, dropDelay:Float = 0)
	{
		super();
		_terrain = terrain;
		_sonic = sonic;
		_dropDelay = dropDelay;
		posX = artX;
		posY = _baseY = artY;
		frames = Paths.getSparrowAtlas("minigame/preymini/characters/enemys/Badnik_2", null, false);
		animation.addByPrefix("fly", "Badnik_2", 10, true);
		animation.play("fly");
		_body = new PixelMask(this, "fly");
		antialiasing = false;
		moves = false;
		scale.set(6, 6);
		origin.set(0, 0);
		offset.set(0, 0);

		box = new FireBox(terrain);
		_carry();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		_age += elapsed;
		if (!broken)
		{
			posX -= 1.2 * elapsed * 60;
			posY = _baseY + Math.sin(_age / 2 * Math.PI * 2) * 6;
			if (box.state == Carried)
			{
				_carry();
				if (_age >= _dropDelay && _sonicComing()) box.drop();
			}
			_touchSonic();
		}
		if (onHurt != null && !_sonic.dead && !_sonic.leaving && box.touches(_sonic.posX, _sonic.posY, _sonic.hitRadiusX, _sonic.hitRadiusY))
			onHurt(box.middleX);
	}

	function _touchSonic():Void
	{
		if (_sonic.dead || _sonic.leaving || _sonic.grabbed) return;
		final frame = animation.curAnim != null ? animation.curAnim.curFrame : 0;
		if (!_body.touches(frame, posX, posY, flipX, _sonic.posX, _sonic.posY, _sonic.hitRadiusX, _sonic.hitRadiusY)) return;
		if (_sonic.attacking)
		{
			broken = true;
			visible = false;
			box.drop();
			if (onKilled != null) onKilled(posX + frameWidth / 2, posY + frameHeight / 2);
		}
		else if (onHurt != null) onHurt(posX + frameWidth / 2);
	}

	function _sonicComing():Bool
	{
		if (_sonic.dead || _sonic.leaving || _sonic.posY < box.bottom) return false;
		final dx = box.middleX - _sonic.posX;
		if (Math.abs(dx) <= 24) return true;
		final speed = _sonic.speedX / (360);
		return speed != 0 && dx * speed > 0 && Math.abs(dx / speed) <= box.fallFrames();
	}

	function _carry():Void
	{
		final frame = animation.curAnim != null ? animation.curAnim.curFrame : 0;
		box.posX = posX + 26 - 83;
		box.posY = posY + BOX_AT_Y[frame % BOX_AT_Y.length] - 46;
		box.showCarried(frame);
	}

	public function place():Void
	{
		x = _terrain.worldX(posX);
		y = _terrain.worldY(posY);
		box.place();
	}
}
