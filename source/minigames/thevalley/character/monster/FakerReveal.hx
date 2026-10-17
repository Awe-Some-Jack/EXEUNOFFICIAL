package minigames.thevalley.character.monster;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import minigames.Camera;
import minigames.thevalley.character.player.Player;

// the little cutscene when she finds the FAKER you know the one guy that goes like eee a u eeau eoeeeee eee aa auuuu
class FakerReveal
{
	public var dread(default, null):Float = 0;
	public var quiet(default, null):Float = 0;

	final _camera:Camera;
	final _player:Player;
	final _top:FlxSprite;
	final _bottom:FlxSprite;
	final _flash:FlxSprite;
	var _exe:Monster = null;
	var _bars:Float = 0;
	var _grew:Bool = false;
	var _opened:Bool = false;

	public function new(state:FlxState, ui:FlxCamera, camera:Camera, player:Player)
	{
		_camera = camera;
		_player = player;
		_top = _bar(state, ui);
		_bottom = _bar(state, ui);
		_flash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFB00000);
		_flash.scrollFactor.set(0, 0);
		_flash.cameras = [ui];
		_flash.alpha = 0;
		_flash.active = false;
		state.add(_flash);
		_place();
	}

	static function _bar(state:FlxState, ui:FlxCamera):FlxSprite
	{
		final bar = new FlxSprite().makeGraphic(FlxG.width, Std.int(72.0), FlxColor.BLACK);
		bar.scrollFactor.set(0, 0);
		bar.cameras = [ui];
		bar.active = false;
		state.add(bar);
		return bar;
	}

	public function update(elapsed:Float, monsters:Array<Monster>):Void
	{
		if (_exe == null)
			for (m in monsters)
				if (m.revealing && !_player.isHidden && !_player.isHiding)
				{
					_begin(m);
					break;
				}

		if (_exe != null)
		{
			if (!_exe.revealing) _end();
			else
			{
				if (_exe.transforming && !_opened)
				{
					_opened = true;
					_shot(_camera.baseZoom + 0.2, 0.8, FlxEase.sineOut);
				}
				if (_exe.grew && !_grew)
				{
					_grew = true;
					_flash.alpha = 0.4;
				}
			}
		}

		final on = _exe != null;
		final ease = 1.0 - Math.pow(0.01, elapsed * 3.0);
		_bars += ((on ? 1.0 : 0.0) - _bars) * ease;
		dread += ((on ? 0.55 : 0.0) - dread) * ease;
		quiet += ((on ? 1.0 : 0.0) - quiet) * ease;
		_flash.alpha = Math.max(0, _flash.alpha - elapsed * 0.4 * 2.2);
		_place();
	}

	function _begin(exe:Monster):Void
	{
		_exe = exe;
		_grew = false;
		_opened = false;
		_player.cinematic = true;
		_player.body.velocity.x = 0;
		_player.lockedAnim = "looking";
		_player.animation.play("looking", true);
		_shot(_camera.baseZoom + 0.7, 1.4, FlxEase.sineInOut);
	}

	function _shot(zoom:Float, time:Float, ease:EaseFunction):Void
	{
		final spr = _exe.sprite;
		_camera.lookAt(spr.x + spr.width * 0.5, spr.y + spr.height - 34.0, zoom, time, ease, true);
	}

	function _end():Void
	{
		_exe = null;
		_player.cinematic = false;
		if (_player.lockedAnim == "looking") _player.lockedAnim = null;
		_camera.followTarget();
	}

	function _place():Void
	{
		final h = 72.0 * _bars;
		_top.y = h - 72.0;
		_bottom.y = FlxG.height - h;
		_top.visible = _bottom.visible = _bars > 0.01;
	}
}
