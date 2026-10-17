package minigames;

import flixel.FlxCamera;
import flixel.FlxG;

//camara para shake noma por los fork de flixel
class ShakeCamera extends FlxCamera
{
	public var shakeView:Bool = false;

	var _shakeX:Float = 0;
	var _shakeY:Float = 0;
	var _leftX:Float = Math.NaN;
	var _leftY:Float = Math.NaN;

	override function updateShake(elapsed:Float):Void
	{
		if (shakeView)
		{
			if (scroll.x == _leftX) scroll.x -= _shakeX;
			if (scroll.y == _leftY) scroll.y -= _shakeY;
		}
		_shakeX = _shakeY = 0;

		if (_fxShakeDuration > 0)
		{
			_fxShakeDuration -= elapsed;
			if (_fxShakeDuration <= 0)
			{
				if (_fxShakeComplete != null) _fxShakeComplete();
			}
			else
			{
				final pixelPerfect = pixelPerfectShake == null ? pixelPerfectRender : pixelPerfectShake;
				if (_fxShakeAxes.x)
				{
					final pixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * width;
					_shakeX = (pixelPerfect ? Math.round(pixels) : pixels) * (shakeView ? 1 : zoom * FlxG.scaleMode.scale.x);
				}
				if (_fxShakeAxes.y)
				{
					final pixels = FlxG.random.float(-1, 1) * _fxShakeIntensity * height;
					_shakeY = (pixelPerfect ? Math.round(pixels) : pixels) * (shakeView ? 1 : zoom * FlxG.scaleMode.scale.y);
				}
			}
		}

		if (shakeView)
		{
			scroll.x += _shakeX;
			scroll.y += _shakeY;
			_leftX = scroll.x;
			_leftY = scroll.y;
		}
	}

	override function updateFlashSpritePosition():Void
	{
		super.updateFlashSpritePosition();
		if (flashSprite == null || shakeView) return;
		flashSprite.x += _shakeX;
		flashSprite.y += _shakeY;
	}
}
