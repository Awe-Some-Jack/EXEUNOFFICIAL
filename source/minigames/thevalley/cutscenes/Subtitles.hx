package minigames.thevalley.cutscenes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Subtitles
{
	public var visible(get, never):Bool;

	final _bar:FlxSprite;
	final _top:Null<FlxSprite>;
	final _text:FlxText;
	final _red = new FlxTextFormat(FlxColor.RED);

	var _line:String = "";
	final _redRanges:Array<Int> = [];
	var _shown:Int = 0;
	var _typeDelay:Float = 0;
	var _typeTimer:Float = 0;

	var _pos:Float = 0;
	var _from:Float = 0;
	var _to:Float = 0;
	var _time:Float = 0;
	var _duration:Float = 0;

	public function new(state:FlxState, cam:FlxCamera, ?font:String, letterbox:Bool = false)
	{
		_top = letterbox ? _addBar(state, cam) : null;
		_bar = _addBar(state, cam);

		_text = new FlxText(0, 0, FlxG.width, "", 18);
		if (font != null) _text.font = font;
		_text.color = FlxColor.WHITE;
		_text.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_text.alignment = FlxTextAlign.CENTER;
		_text.scrollFactor.set(0, 0);
		_text.cameras = [cam];
		state.add(_text);
		_place();
	}

	inline function get_visible():Bool return _pos > 0 || _to > 0;

	public inline function open():Void
	{
		_slide(1, 0.25);
	}

	public inline function close(time:Float = 0.35):Void
	{
		_slide(0, time);
	}

	public function say(line:String, typeDelay:Float = 0):Void
	{
		final buf = new StringBuf();
		_redRanges.resize(0);
		for (i in 0...line.length)
		{
			final c = line.charAt(i);
			if (c == "*") _redRanges.push(buf.length);
			else buf.add(c);
		}
		_line = buf.toString();
		if (_redRanges.length % 2 == 1) _redRanges.push(_line.length);

		_typeDelay = typeDelay;
		_typeTimer = typeDelay;
		_shown = typeDelay > 0 ? 0 : _line.length;
		_render();
	}

	public function clear():Void
	{
		_line = "";
		_shown = 0;
		_render();
	}

	public function update(elapsed:Float):Void
	{
		if (_time < _duration)
		{
			_time = Math.min(_time + elapsed, _duration);
			final t = _time / _duration;
			_pos = _from + (_to - _from) * (_to > _from ? 1 - (1 - t) * (1 - t) : t * t);
		}

		if (_shown < _line.length)
		{
			_typeTimer -= elapsed;
			var typed = false;
			while (_typeTimer <= 0 && _shown < _line.length)
			{
				_shown++;
				_typeTimer += _typeDelay;
				typed = true;
			}
			if (typed) _render();
		}

		_place();
	}

	function _slide(to:Float, time:Float):Void
	{
		_from = _pos;
		_to = to;
		_time = 0;
		_duration = Math.max(time, 0.001);
	}

	function _render():Void
	{
		_text.text = _line.substr(0, _shown);
		_text.clearFormats();
		var i = 0;
		while (i + 1 < _redRanges.length)
		{
			final end = Std.int(Math.min(_redRanges[i + 1], _shown));
			if (_redRanges[i] < end) _text.addFormat(_red, _redRanges[i], end);
			i += 2;
		}
	}

	function _place():Void
	{
		final on = _pos > 0;
		_bar.y = FlxG.height - 54 * _pos;
		_bar.visible = on;
		if (_top != null)
		{
			_top.y = 54 * (_pos - 1);
			_top.visible = on;
		}
		_text.y = _bar.y + (54 - _text.height) * 0.5;
		_text.visible = on && _shown > 0;
	}

	static function _addBar(state:FlxState, cam:FlxCamera):FlxSprite
	{
		final bar = new FlxSprite(0, FlxG.height);
		bar.makeGraphic(FlxG.width, 54, 0xFF000000);
		bar.scrollFactor.set(0, 0);
		bar.cameras = [cam];
		bar.alpha = 0.82;
		bar.active = false;
		state.add(bar);
		return bar;
	}
}
