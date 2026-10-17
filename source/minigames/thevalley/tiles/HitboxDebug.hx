package minigames.thevalley.tiles;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class HitboxDebug
{
	final _state:FlxState;
	final _sprites:Array<FlxSprite> = [];
	final _keys:Array<String> = [];
	var _used:Int = 0;

	public function new(state:FlxState)
	{
		_state = state;
	}

	public inline function begin():Void
	{
		_used = 0;
	}

	public function box(x:Float, y:Float, w:Float, h:Float, color:FlxColor):Void
	{
		final iw = Std.int(Math.max(1, Math.round(w)));
		final ih = Std.int(Math.max(1, Math.round(h)));
		_place(x, y, 'hitbox:$iw:$ih:$color', () -> {
			final bmd = new BitmapData(iw, ih, true, (color & 0x00FFFFFF) | 0x30000000);
			final c:Int = color | 0xFF000000;
			bmd.fillRect(new Rectangle(0, 0, iw, 1), c);
			bmd.fillRect(new Rectangle(0, ih - 1, iw, 1), c);
			bmd.fillRect(new Rectangle(0, 0, 1, ih), c);
			bmd.fillRect(new Rectangle(iw - 1, 0, 1, ih), c);
			bmd;
		});
	}

	public function shape(x:Float, y:Float, key:String, make:() -> BitmapData):Void
	{
		_place(x, y, key, make);
	}

	public function end():Void
	{
		for (i in _used..._sprites.length) _sprites[i].visible = false;
	}

	public function hide():Void
	{
		_used = 0;
		end();
	}

	function _place(x:Float, y:Float, key:String, make:() -> BitmapData):Void
	{
		if (_used >= _sprites.length)
		{
			final s = new FlxSprite();
			s.scrollFactor.set(1, 1);
			s.antialiasing = false;
			_state.add(s);
			_sprites.push(s);
			_keys.push(null);
		}

		final s = _sprites[_used];
		if (_keys[_used] != key)
		{
			var g = FlxG.bitmap.get(key);
			if (g == null)
			{
				g = FlxGraphic.fromBitmapData(make(), false, key);
				g.persist = true;
			}
			s.loadGraphic(g);
			_keys[_used] = key;
		}
		s.setPosition(x, y);
		s.visible = true;
		_used++;
	}
}
