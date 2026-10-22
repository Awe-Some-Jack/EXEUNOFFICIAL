package minigames.thevalley.cutscenes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxDirectionFlags;

import minigames.thevalley.TheValley;
import minigames.thevalley.character.player.Player;

enum abstract SunkyState(Int)
{
	var SWalk  = 0;
	var SShow  = 1;
	var SBlack = 2;
}

@:access(minigames.thevalley.TheValley)
class SunkyGag
{
	public var blackout(get, never):Bool;
	inline function get_blackout() return _state == SBlack;

	final _game:TheValley;
	final _sunky:FlxSprite;
	final _cereal:Array<FlxSprite> = [];
	final _milk:Array<FlxSprite> = [];
	final _events:Array<{ t:Float, run:Void->Void }> = [];
	final _black:FlxSprite;
	final _text1:FlxSprite;
	final _text2:FlxSprite;
	final _standX:Float;

	var _state:SunkyState = SWalk;
	var _time:Float = 0;
	var _next:Int = 0;
	var _pour:FlxSound;
	var _song:FlxSound;
	var _waiting:Bool = false;

	public static function inZone(sunky:FlxSprite, player:Player):Bool
	{
		final dx = player.x + player.width * 0.5 - sunky.x;
		final dy = player.y + player.height - (sunky.y + sunky.height);
		return dx > 40 && dx < 260 && dy > -20 && dy < 90;
	}

	public function new(game:TheValley, sunky:FlxSprite)
	{
		_game = game;
		_sunky = sunky;
		_standX = sunky.x + 92;

		final p = game.player;
		p.cinematic = true;
		p.body.velocity.setxy(0, 0);

		final dir = "minigame/thevalley/characters/easteregg/";
		final at = game.members.indexOf(p);
		for (k in 0...3)
		{
			final c = new FlxSprite();
			c.frames = Paths.getSparrowAtlas(dir + "cereal");
			c.animation.add("loop", [0, 1, 2], 10, true);
			c.animation.add("end", [3, 4], 10, false);
			c.visible = false;
			game.insert(at + 1, c);
			_cereal.push(c);

			final m = new FlxSprite();
			m.frames = Paths.getSparrowAtlas(dir + "milk");
			m.animation.add("start", [0], 10, false);
			m.animation.add("loop", [1, 2, 3], 10, true);
			m.animation.add("end", [4], 10, false);
			m.visible = false;
			game.insert(at + 1, m);
			_milk.push(m);
		}

		_black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		_text1 = new FlxSprite(0, 0, Paths.image(dir + "sunkytext1"));
		_text2 = new FlxSprite(0, 0, Paths.image(dir + "sunkytext2"));
		for (s in [_black, _text1, _text2])
		{
			s.scrollFactor.set(0, 0);
			s.cameras = [game.uiCam];
			s.visible = false;
			if (s != _black)
			{
				s.antialiasing = true;
				s.scale.set(1.4, 1.4);
				s.updateHitbox();
				s.screenCenter();
			}
			game.add(s);
		}

		final feet = p.body.position.y + p.height * 0.5;
		game.gameCamera.lookAt((sunky.x + 12 + _standX) * 0.5, feet - 46, 3.2, 0.9, FlxEase.sineInOut);
		_build();
	}

	function _build():Void
	{
		_at(0.0, () -> _lock("sunkystart"));
		_at(1.0, () -> _sunky.animation.play("raise"));
		_at(1.6, () -> _lock("sunkylookup"));

		for (k in 0...3)
		{
			final c = _cereal[2 - k];
			_at(1.9 + k * 0.08, () ->
			{
				c.visible = true;
				c.animation.play("loop", true);
			});
			_at(2.75 + k * 0.08, () -> c.animation.play("end", true));
			_at(2.95 + k * 0.08, () -> c.visible = false);
		}
		_at(1.9, () -> _pour = FlxG.sound.play(_sound("pourincereal"), 0.8));
		_at(2.75, () -> _pour?.fadeOut(0.35, 0));
		_at(2.14, () -> _lock("sunkycereal"));
		_at(3.11, () -> _lock("sunkycerealend"));
		_at(3.35, () -> FlxG.sound.play(_sound("pourinmilk"), 1.0));

		for (k in 0...3)
		{
			final m = _milk[2 - k];
			_at(3.35 + k * 0.08, () ->
			{
				m.visible = true;
				m.animation.play("start", true);
			});
			_at(3.43 + k * 0.08, () -> m.animation.play("loop", true));
			_at(4.3 + k * 0.08, () -> m.animation.play("end", true));
			_at(4.4 + k * 0.08, () -> m.visible = false);
		}
		_at(3.59, () -> _lock("sunkymilkin"));
		_at(3.69, () -> _lock("sunkymilk"));
		_at(4.4, () -> _sunky.animation.play("lower"));
		_at(4.56, () -> _lock("sunkyend"));
		_at(5.1, () ->
		{
			_lock("sunkychew");
			FlxG.sound.play(_sound("chewing"), 0.9);
		});
		_at(7.5, _cut);
		_at(8.4, () ->
		{
			_text1.visible = false;
			_text2.visible = true;
			_song = FlxG.sound.play(_sound("milkandcereal"), 0.8, true);
		});
		_at(8.9, () -> _waiting = true);
		_events.sort((a, b) -> Reflect.compare(a.t, b.t));
	}

	public function update(elapsed:Float):Void
	{
		switch (_state)
		{
			case SWalk:
				_walk(elapsed);
			case SShow | SBlack:
				_time += elapsed;
				while (_next < _events.length && _events[_next].t <= _time)
					_events[_next++].run();
				if (_waiting && Controls.instance.ACCEPT)
				{
					_waiting = false;
					_song?.stop();
					FlxG.resetState();
				}
		}
		if (_sunky.animation.curAnim != null && _sunky.animation.curAnim.name == "lower" && _sunky.animation.curAnim.finished)
			_sunky.animation.play("idle");
	}

	function _walk(elapsed:Float):Void
	{
		final p = _game.player;
		final body = p.body;
		final dx = _standX - body.position.x;
		final step = 90.0 * elapsed;
		if (Math.abs(dx) <= step)
		{
			body.position.x = _standX;
			_begin();
			return;
		}
		body.position.x += dx > 0 ? step : -step;
		p.facing = dx > 0 ? FlxDirectionFlags.RIGHT : FlxDirectionFlags.LEFT;
		_lock("walk");
		if (p.animation.curAnim != null) p.animation.curAnim.frameRate = 10;
	}

	function _begin():Void
	{
		_state = SShow;
		final p = _game.player;
		p.facing = FlxDirectionFlags.LEFT;
		_lock("idle");

		final left = p.body.position.x - p.width * 0.5 - p.offset.x + 17;
		final top = p.body.position.y - p.height * 0.5 - p.offset.y + 3;
		for (k in 0...3)
		{
			_cereal[k].setPosition(left + 3, top - 91 - 80 * k);
			_milk[k].setPosition(left, top - 96 * (k + 1));
		}
	}

	function _cut():Void
	{
		_state = SBlack;
		FlxG.sound.music?.pause();
		_game._pauseSounds();
		_black.visible = true;
		_text1.visible = true;
		if (!backend.EXEAchievements.isUnlocked("sunkyvalley"))
		{
			backend.EXEAchievements.unlock("sunkyvalley");
			backend.EXEAchievements.save();
		}
	}

	static inline function _sound(name:String)
		return Paths.sound("minigame/thevalley/sunky/" + name);

	inline function _lock(name:String):Void
		_game.player.lockedAnim = name;

	inline function _at(t:Float, run:Void->Void):Void
		_events.push({ t: t, run: run });
}
