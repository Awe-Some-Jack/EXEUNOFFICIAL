package minigames.preymini.map;

import minigames.preymini.map.Shader;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import openfl.display.BlendMode;

class BGPrey
{
	static final GLOW:Array<Float>   = [255, 255, 168];
	static final DARK:Array<Float>   = [0, 0, 0];
	static final STRIKE:Array<Float> = [216, 108, 180];
	static final EMBERS:Array<Float> = [9, 0, 0];

	public var speed(default, null):Float = 0;
	public var lit(default, null):Bool = false;
	public var layerY(get, never):Float;

	final _state:FlxState;
	final _shader = new ReplaceColorShader();
	final _layers:Array<FlxBackdrop> = [];
	final _lightning:FlxBackdrop;
	final _fg:FlxBackdrop;
	final _flash:FlxSprite;
	final _parade:SkyParade;

	var _striking:Bool = false;
	var _startScroll:Null<Float> = null;
	var _bgOffset:Float = 0;
	var _fgOffset:Float = 0;
	var _afterglow:FlxTween = null;
	var _flashTween:FlxTween = null;

	public function new(state:FlxState, overlayCam:FlxCamera)
	{
		_state = state;
		_shader.setColors(GLOW, DARK);
		_parade = new SkyParade(this);

		for (i in 0...15)
		{
			final bg = new FlxBackdrop(Paths.image('minigame/preymini/bg/bg/bg${i + 1}'), FlxAxes.X);
			_pixelArt(bg, 4, 0.2, 0.6);
			bg.y = -1130;
			bg.shader = _shader;
			bg.color = FlxColor.BLACK;
			_layers.push(bg);
		}

		_lightning = new FlxBackdrop(null, FlxAxes.X);
		_lightning.frames = Paths.getSparrowAtlas("minigame/preymini/bg/bg/sky15-lightning-anim");
		_lightning.animation.addByPrefix("idle", "idle", 12, false);
		_lightning.animation.play("idle", true);
		_pixelArt(_lightning, 4, 0.2, 0.6);
		_lightning.y = -1130;
		_lightning.visible = false;

		state.add(_layers[14]);
		state.add(_lightning);
		var i = 13;
		while (i >= 0)
		{
			state.add(_layers[i]);
			final lane = _parade.groupAfter(i + 1);
			if (lane != null) state.add(lane);
			i--;
		}

		_fg = new FlxBackdrop(null, FlxAxes.X, 800);
		_fg.frames = Paths.getSparrowAtlas("minigame/preymini/bg/bg/fg-pilar-anim");
		_fg.animation.addByPrefix("idle", "idle", 8, true);
		_fg.animation.play("idle", true);
		_pixelArt(_fg, 6, 1.5, 1.5);
		_fg.y = -600;
		_fg.color = FlxColor.BLACK;

		_flash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFF99);
		_flash.cameras = [overlayCam];
		_flash.scrollFactor.set(0, 0);
		_flash.blend = BlendMode.ADD;
		_flash.alpha = 0;

		setSpeed(1);
	}

	public function addFront():Void
	{
		_state.add(_fg);
		_state.add(_flash);
	}

	public function setSpeed(target:Float):Void
	{
		speed = target;
		for (i in 0...15) _layers[i].velocity.x = (-1250 + 50 * i) * target;
		_lightning.velocity.x = (-500) * target;
		_fg.velocity.x = -3500 * target;
	}

	public inline function layerVelocity(layer:Int):Float
	{
		return (-1250 + 50 * (layer - 1)) * speed;
	}

	inline function get_layerY():Float return _layers[0].y;

	public function rally(on:Bool, ?onBoom:Float->Float->Void):Void
	{
		_parade.onBoom = onBoom;
		_parade.rally(on);
	}

	public function ignite():Void
	{
		_parade.burning = true;
	}

	public function setLit(on:Bool):Void
	{
		lit = on;
		final c = on ? FlxColor.WHITE : FlxColor.BLACK;
		for (i in 1...15) _layers[i].color = c;
		_fg.color = c;
	}

	public function strike():Void
	{
		_striking = true;
		_lightning.visible = true;
		_lightning.alpha = 1;
		_lightning.animation.play("idle", true);

		_afterglow?.cancel();
		_shader.setReplace(STRIKE);
		_parade.strike();

		if (ClientPrefs.data.flashing)
		{
			_flashTween?.cancel();
			_flash.alpha = 0.3;
			_flashTween = FlxTween.tween(_flash, { alpha: 0 }, 4 * (60 / 176), { ease: FlxEase.cubeOut });
		}
	}

	public function followCamera(cam:FlxCamera):Void
	{
		final scrollY = cam.scroll.y;
		if (_startScroll == null)
		{
			_startScroll = scrollY;
			_bgOffset = -1130 + scrollY * 0.4 - cam.viewTop;
			_fgOffset = -600 - scrollY * 0.5 - cam.viewTop;
		}
		final moved = scrollY - _startScroll;

		final bgTop = Math.max(cam.viewHeight - 768 * 4, Math.min(0, _bgOffset - moved * 0.12));
		final bgY = cam.viewTop + bgTop - scrollY * 0.4;
		for (bg in _layers) bg.y = bgY;
		_lightning.y = bgY;

		final fgTop = Math.max(cam.viewHeight - 469 * 6, _fgOffset - moved * 1.5);
		_fg.y = cam.viewTop + fgTop + scrollY * 0.5;
	}

	public function update(elapsed:Float):Void
	{
		_parade.update(elapsed);
		if (!_striking || !_lightning.animation.finished) return;

		_lightning.alpha -= elapsed * 0.75;
		if (_lightning.alpha > 0) return;

		_striking = false;
		_lightning.visible = false;
		_afterglow = FlxTween.num(0, 1, 2.0, null, n -> _shader.setReplace([
			for (c in 0...3) STRIKE[c] + (EMBERS[c] - STRIKE[c]) * n
		]));
	}

	static function _pixelArt(spr:FlxSprite, scale:Float, scrollX:Float, scrollY:Float):Void
	{
		spr.antialiasing = false;
		spr.scrollFactor.set(scrollX, scrollY);
		spr.scale.set(scale, scale);
		spr.updateHitbox();
	}
}
