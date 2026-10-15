package minigames;

import flixel.FlxCamera;
import flixel.FlxG;

//camara para shake noma por los fork de flixel
class ShakeCamera extends FlxCamera
{
	var _shakeX:Float = 0;
	var _shakeY:Float = 0;

	override function updateShake(elapsed:Float):Void
	{
		_shakeX = _shakeY = 0;
		if (_fxShakeDuration <= 0) return;

		_fxShakeDuration -= elapsed;
		if (_fxShakeDuration <= 0)
		{
			if (_fxShakeComplete != null) _fxShakeComplete();
			return;
		}

		final pixelPerfect = pixelPerfectShake == null ? pixelPerfectRender : pixelPerfectShake;
		if (_fxShakeAxes.x)
		{
			final pixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * width;
			_shakeX = (pixelPerfect ? Math.round(pixels) : pixels) * zoom * FlxG.scaleMode.scale.x;
		}
		if (_fxShakeAxes.y)
		{
			final pixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * height;
			_shakeY = (pixelPerfect ? Math.round(pixels) : pixels) * zoom * FlxG.scaleMode.scale.y;
		}
	}

	override function updateFlashSpritePosition():Void
	{
		super.updateFlashSpritePosition();
		if (flashSprite == null) return;
		flashSprite.x += _shakeX;
		flashSprite.y += _shakeY;
	}
}
