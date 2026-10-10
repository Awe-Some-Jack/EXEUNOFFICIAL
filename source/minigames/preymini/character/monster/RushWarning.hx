package minigames.preymini.character.monster;

import flixel.group.FlxGroup.FlxTypedGroup;
import minigames.preymini.character.monster.RushBadnik.RushBadnikState;

class RushWarning extends FlxTypedGroup<FlxSprite>
{
	public var done(default, null):Bool = false;

	final _rush:RushBadnik;
	final _overlay:FlxCamera;
	final _sign:FlxSprite;
	final _dashes:Array<FlxSprite> = [];
	var _t:Float = 0;
	var _out:Float = -1;

	public function new(rush:RushBadnik, overlay:FlxCamera)
	{
		super();
		_rush = rush;
		_overlay = overlay;

		for (i in 0...40)
		{
			final dash = new FlxSprite().loadGraphic(Paths.image("minigame/preymini/hud/warning/chevron"));
			_setup(dash);
			dash.scale.set(2, 2);
			dash.flipX = rush.dir < 0;
			dash.visible = false;
			_dashes.push(dash);
		}

		_sign = new FlxSprite();
		_sign.frames = Paths.getSparrowAtlas("minigame/preymini/hud/warning/warning");
		_sign.animation.addByPrefix("warn", "1", 12, true);
		_sign.animation.play("warn", true);
		_setup(_sign);
		_sign.scale.set(0, 0);

		FlxG.sound.play(Paths.sound("minigame/preymini/warning"));
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (done) return;
		_t += elapsed;

		if (_out < 0 && (_rush.state == Rushing || !_rush.alive)) _out = 0;
		if (_out >= 0) _out += elapsed;
		final fade = _out < 0 ? 1 : Math.max(0, 1 - _out / 0.2);
		if (fade <= 0)
		{
			done = true;
			for (s in members) s.visible = false;
			return;
		}

		final cam = FlxG.camera;
		final midX = (_rush.x + _rush.frameWidth * 3 - cam.viewLeft) * cam.zoom;
		final midY = (_rush.y + _rush.frameHeight * 3 - cam.viewTop) * cam.zoom;

		final pop = Math.min(1, _t / 0.12);
		final grow = _out < 0 ? 1 + 0.25 * (1 - pop) * (1 - pop) : 1 - 0.6 * (1 - fade);
		_sign.scale.set(pop * grow, pop * grow);
		_sign.alpha = fade;
		_sign.setPosition(Math.round(midX - _sign.frameWidth / 2), Math.round(midY - 78 - _sign.frameHeight / 2 - Math.sin(_t * 10) * 3));

		final dir = _rush.dir;
		final start = midX + dir * 46;
		final end = dir > 0 ? FlxG.width + 20 : -20;
		final march = (_t * 140) % 26;
		final pulse = 0.55 + 0.45 * Math.abs(Math.sin(_t * 12));
		for (i in 0..._dashes.length)
		{
			final dash = _dashes[i];
			final along = i * 26 + march;
			final x = start + dir * along;
			dash.visible = dir > 0 ? x < end : x > end;
			if (!dash.visible) continue;
			dash.setPosition(Math.round(x - 3.5), Math.round(midY - 4.5));
			final reveal = Math.max(0, Math.min(1, _t * 3500 / Math.max(1, along) - 1));
			dash.alpha = pulse * fade * reveal;
		}
	}

	function _setup(s:FlxSprite):Void
	{
		s.cameras = [_overlay];
		s.scrollFactor.set(0, 0);
		s.antialiasing = false;
		s.moves = false;
		add(s);
	}
}
