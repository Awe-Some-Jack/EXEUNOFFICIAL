package minigames.thevalley.tiles.npcs;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.util.FlxDirectionFlags;

import minigames.Camera;
import minigames.thevalley.TheValley;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.cutscenes.Subtitles;

class DeadNPC extends FlxSprite
{
	public function new(x:Float, y:Float, atlas:String, anim:String, fps:Int = 8)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('minigame/thevalley/characters/dead/$atlas');
		animation.addByPrefix("idle", anim, fps, true);
		animation.play("idle");
		moves = false;
	}

	public function distTo(player:Player):Float
	{
		if (player == null) return 9999.0;
		final dx = player.x + player.width * 0.5 - (x + width * 0.5);
		final dy = player.y + player.height * 0.5 - (y + height * 0.5);
		return Math.abs(dy) > 40.0 ? 9999.0 : Math.sqrt(dx * dx + dy * dy);
	}
}

// jajajaja pinshe treno se te murio la pendeja
class AmyNPC extends DeadNPC
{
	public function new(x:Float, y:Float)
	{
		super(x, y, "amy", "amy dead");
	}
}

// i dont think he chuckles anymore
class KnucklesNPC extends DeadNPC
{
	public function new(x:Float, y:Float)
	{
		super(x, y, "knuckles", "knuckles dead");
	}
}

enum abstract GaryState(Int)
{
	var GIdle    = 0;
	var GTalking = 1;
	var GClosing = 2;
}

class GaryNPC extends DeadNPC
{
	static final CLIPS:Array<{ sound:String, len:Float, lines:Array<{ text:String, start:Float, end:Float }> }> = [
		{ sound: "Gary1", len: 13.11, lines: [
			{ text: "Your friend isn't just asleep, girl.",       start: 0.00, end: 4.90 },
			{ text: "Whatever put him under.....",                start: 5.20, end: 7.90 },
			{ text: "*it* knew what it was doing.",               start: 8.05, end: 12.40 },
		] },
		{ sound: "Gary2", len: 13.25, lines: [
			{ text: "An impersonation of something everybody loves,", start: 0.00, end: 4.70 },
			{ text: "but close enough to fool you,",                  start: 5.00, end: 8.75 },
			{ text: "wrong enough to haunt you.",                     start: 9.00, end: 12.40 },
		] },
		{ sound: "GaryInterrumpt", len: 7.64, lines: [
			{ text: "Are you going to let me finish?", start: 0.00, end: 4.50 },
			{ text: "*clears throat*",                 start: 4.85, end: 6.80 },
		] },
		{ sound: "GaryEnd", len: 5.60, lines: [
			{ text: "There's no more to it,", start: 0.00, end: 1.95 },
			{ text: "now scram.",             start: 2.00, end: 4.90 },
		] },
	];

	public var isTalking(get, never):Bool;
	inline function get_isTalking() return _state != GIdle;

	var _player:Player;
	var _eButton:FlxSprite;
	var _camera:Camera;
	var _subs:Subtitles;

	var _state:GaryState = GIdle;
	var _time:Float = 0;
	var _line:Int = -1;
	var _closeTimer:Float = 0;
	var _voice:FlxSound;
	var _prompting:Bool = false;
	var _flicker:Float = 0;
	var _next:Int = 0;
	var _cutOff:Bool = false;
	var _clip:Int = 0;
	var _queue:Array<Int> = [];

	public function new(x:Float, y:Float, ?valley:TheValley)
	{
		super(x, y, "gary", "gary aura");
		if (valley != null) attach(valley.player, valley.cutscene?.eButton, valley.gameCamera, new Subtitles(valley, valley.uiCam, "assets/fonts/SonicFont.ttf", true));
	}

	public function attach(player:Player, eButton:FlxSprite, camera:Camera, subs:Subtitles):Void
	{
		_player  = player;
		_eButton = eButton;
		_camera  = camera;
		_subs    = subs;
	}

	public inline function getDist():Float return distTo(_player);

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		final speaking = _state == GTalking && _line >= 0;
		_flicker = speaking ? _flicker + elapsed : 0;
		alpha = speaking ? 1.0 - 0.15 * (0.5 + 0.5 * Math.sin(_flicker * 18.0)) : 1.0;
	}

	public function npcUpdate(elapsed:Float):Void
	{
		if (_subs == null) return;
		_subs.update(elapsed);

		switch (_state)
		{
			case GIdle:
				final dist = getDist();
				_updatePrompt(dist);
				if (FlxG.keys.justPressed.E && dist <= 50.0 && _canTalk()) _start();

			case GTalking:
				if (getDist() > 90.0 * 2) _finish(true);
				else _talk(elapsed);

			case GClosing:
				_closeTimer -= elapsed;
				if (_closeTimer <= 0)
				{
					_state = GIdle;
					_player.cinematic = false;
				}
		}

		if (_state != GIdle && _camera != null)
		{
			_camera.zoomIn(0.45, 2.0);
			_camera.frame(x + width * 0.5);
		}
	}

	function _canTalk():Bool
	{
		return _player.isGrounded && !_player.cinematic && !_player.isHidden && !_player.isHiding;
	}

	function _updatePrompt(dist:Float):Void
	{
		if (_eButton == null) return;
		final t = 1.0 - Math.min(Math.max((dist - 50.0) / (90.0 - 50.0), 0.0), 1.0);
		if (t > 0)
		{
			_eButton.alpha = t * 0.55;
			_eButton.x = x + (width - _eButton.width) * 0.5;
			_eButton.y = y - _eButton.height - 6;
			_prompting = true;
		}
		else if (_prompting)
		{
			_eButton.alpha = 0;
			_prompting = false;
		}
	}

	function _start():Void
	{
		_state = GTalking;
		_time = 0;
		_line = -1;
		_prompting = false;
		if (_eButton != null) _eButton.alpha = 0;

		_player.cinematic = true;
		_player.facing = x + width * 0.5 < _player.x + _player.width * 0.5 ? FlxDirectionFlags.LEFT : FlxDirectionFlags.RIGHT;

		_queue = _next >= 2 ? [3] : (_cutOff ? [2, _next] : [_next]);
		_cutOff = false;
		_subs.open();
		_playNext();
	}

	function _playNext():Void
	{
		_clip = _queue.shift();
		_time = 0;
		_line = -1;
		_subs.clear();
		_voice = FlxG.sound.play(Paths.sound("minigame/thevalley/gary/" + CLIPS[_clip].sound), 0.8);
	}

	function _talk(elapsed:Float):Void
	{
		_time = _voice != null && _voice.playing ? _voice.time / 1000.0 : _time + elapsed;

		final line = _lineAt(_time);
		if (line != _line)
		{
			_line = line;
			if (line >= 0) _subs.say(CLIPS[_clip].lines[line].text, 0.045);
			else _subs.clear();
		}

		if (_eButton != null && _time >= 0.6 && _clip != 2)
		{
			_eButton.alpha = 0.3;
			_eButton.x = _player.x + (_player.width - _eButton.width) * 0.5;
			_eButton.y = _player.y - _eButton.height - 16;
		}

		if (_time >= CLIPS[_clip].len)
		{
			if (_clip == _next && _next < 2) _next++;
			if (_queue.length > 0) _playNext();
			else _finish(false);
		}
		else if (FlxG.keys.justPressed.E && _time >= 0.6 && _clip != 2) _finish(true);
	}

	function _finish(skipped:Bool):Void
	{
		if (skipped && _clip != 3) _cutOff = true;
		if (skipped && _voice != null)
		{
			final voice = _voice;
			voice.fadeOut(0.25, 0, _ -> voice.stop());
		}
		_voice = null;
		_line = -1;
		if (_eButton != null) _eButton.alpha = 0;

		_subs.clear();
		_subs.close(0.35);
		_state = GClosing;
		_closeTimer = 0.35;

        _camera?.followTarget();
	}

	function _lineAt(time:Float):Int
	{
		final lines = CLIPS[_clip].lines;
		for (i in 0...lines.length)
			if (time >= lines[i].start && time < lines[i].end) return i;
		return -1;
	}
}
