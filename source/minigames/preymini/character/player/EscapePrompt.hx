package minigames.preymini.character.player;

import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;

import openfl.display.BitmapData;

class EscapePrompt extends FlxTypedGroup<FlxSprite>
{
	final _cam:FlxCamera;
	final _label:FlxSprite;
	final _keys:Array<FlxSprite> = [];
	final _barBack:FlxSprite;
	final _segments:Array<FlxSprite> = [];
	final _tap:Array<Float> = [0, 0];

	var _shown:Float = 0;
	var _t:Float = 0;

	public function new(cam:FlxCamera)
	{
		super();
		_cam = cam;
		_label = _setup(new FlxSprite().loadGraphic(Paths.image("minigame/preymini/hud/escape/escape")));
		for (action in ["ui_left", "ui_right"])
		{
			final cap = FlxGraphic.fromBitmapData(_keycap(_keyGlyph(action, action == "ui_left" ? "<" : ">")), false, null, false);
			_keys.push(_setup(new FlxSprite().loadGraphic(cap, true, 17, 17)));
		}
		_barBack = _setup(new FlxSprite().loadGraphic(Paths.image("minigame/preymini/hud/escape/bar")));
		for (i in 0...8)
		{
			final segment = _setup(new FlxSprite().loadGraphic(Paths.image("minigame/preymini/hud/escape/segments"), true, 4, 5));
			segment.animation.frameIndex = i;
			_segments.push(segment);
		}
		for (s in members) s.alpha = 0;
	}

	public function track(elapsed:Float, screenX:Float, screenY:Float, progress:Float, active:Bool):Void
	{
		_t += elapsed;
		_shown = active ? Math.min(1, _shown + elapsed / 0.15) : Math.max(0, _shown - elapsed / 0.2);
		if (_shown <= 0)
		{
			for (s in members) s.visible = false;
			return;
		}

		final controls = Controls.instance;
		if (active && controls.UI_LEFT_P) _tap[0] = 0.09;
		if (active && controls.UI_RIGHT_P) _tap[1] = 0.09;
		for (i in 0...2) _tap[i] = Math.max(0, _tap[i] - elapsed);

		final ease = 1 - Math.pow(1 - _shown, 3);
		final lift = (1 - ease) * 18 + Math.sin(_t * 6) * 2;
		final keysWidth = 17 * 3 * 2 + 12;
		final left = Math.round(Math.max(8, Math.min(FlxG.width - keysWidth - 8, screenX - keysWidth / 2)));
		final top = Math.round(Math.max(8, Math.min(FlxG.height - 130, screenY + 18 + lift)));

		_label.setPosition(left + (keysWidth - _label.frameWidth * 3) / 2, top);
		_label.alpha = ease * (0.8 + 0.2 * Math.sin(_t * 9));

		final alternate = Std.int(_t / 0.14) % 2;
		for (i in 0...2)
		{
			final key = _keys[i];
			final down = _tap[i] > 0 || (_tap[0] <= 0 && _tap[1] <= 0 && alternate == i);
			key.animation.frameIndex = down ? 1 : 0;
			key.setPosition(left + i * (17 * 3 + 12), top + 30);
			key.alpha = ease;
		}

		final barX = left + (keysWidth - 41 * 3) / 2, barY = top + 30 + 17 * 3 + 9;
		_barBack.setPosition(barX, barY);
		_barBack.alpha = ease;
		final lit = Std.int(Math.min(8, Math.max(0, progress) * 8 + 0.001));
		for (i in 0...8)
		{
			final segment = _segments[i];
			segment.setPosition(barX + (1 + i * 5) * 3, barY + 3);
			segment.visible = i < lit;
			segment.alpha = ease;
		}
		for (s in [_label, _barBack].concat(_keys)) s.visible = true;
	}

	function _setup(s:FlxSprite):FlxSprite
	{
		s.cameras = [_cam];
		s.scrollFactor.set(0, 0);
		s.antialiasing = false;
		s.origin.set(0, 0);
		s.scale.set(3, 3);
		add(s);
		return s;
	}

	static function _keyGlyph(action:String, fallback:String):String
	{
		final binds = Controls.instance.keyboardBinds.get(action);
		if (binds == null || binds.length == 0) return fallback;
		final name = (binds[0] : FlxKey).toString();
		if (name == "LEFT") return "<";
		if (name == "RIGHT") return ">";
		return name.length == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ!<>".indexOf(name) >= 0 ? name : fallback;
	}

	static function _keycap(glyph:String):BitmapData
	{
		final originalCap = Paths.getBitmapData(Paths.getPath("images/minigame/preymini/hud/escape/keycap.png", IMAGE));
		final cap = originalCap.clone(); 
		
		final font = Paths.getBitmapData(Paths.getPath("images/minigame/preymini/hud/escape/font.png", IMAGE));
		final index = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!<>".indexOf(glyph);
		if (index >= 0)
			for (frame in 0...2)
				for (y in 0...7)
					for (x in 0...5)
						if ((font.getPixel32(index * 6 + x, y) >>> 24) & 0xFF >= 128)
							cap.setPixel32(frame * 17 + 6 + x, (frame == 1 ? 3 : 1) + 3 + y, 0xFF2A2440);
		font.dispose();
		return cap;
	}
}