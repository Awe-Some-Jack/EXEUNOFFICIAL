package thevalley.npcs;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import thevalley.player.Player;
import thevalley.TVCutscene;

enum abstract GaryState(Int)
{
	var GIdle    = 0;
	var GTalking = 1;
	var GDone    = 2;
}

class GaryNPC extends FlxSprite
{
	static inline var INTERACT_DIST:Float = 90.0;
	static inline var CHAR_DELAY:Float    = 0.045;

// gary spitting on my co- i mean spitting bars :fire: :fire:
	static final LINES:Array<String> = [
		"Your beloved dear isn't just asleep, girl.",
		"Whatever put him under —",
		"it knew what it was doing.",
	];
	static final LINE_HOLD:Array<Float> = [1.2, 1.0, 1.5];

	var _player:Player;
	var _eButton:FlxSprite;
	var _state:GaryState = GIdle;

	var _subBar:FlxSprite;
	var _subTxt:FlxText;

	var _lineIdx:Int      = 0;
	var _lineTimer:Float  = 0;
	var _charIdx:Int      = 0;
	var _charTimer:Float  = 0;
	var _typing:Bool      = false;
	var _holdTimer:Float  = 0;
	var _slideOut:Bool    = false;
	var _slideTimer:Float = 0;

	public function new(wx:Float, wy:Float, player:Player, cutscene:TVCutscene, uiCam:FlxCamera, flxState:flixel.FlxState)
	{
		super(wx, wy);
		_player  = player;
		_eButton = cutscene?.eButton ?? null;

		frames = Paths.getSparrowAtlas("minigame/thevalley/characters/dead/gary");
		animation.addByPrefix("aura", "gary aura", 8, true);
		animation.play("aura");
		scrollFactor.set(1, 1);
		moves = false;

		if (uiCam == null) return;

		_subBar = new FlxSprite(0, 896);
		_subBar.makeGraphic(1280, 54, 0xFF000000);
		_subBar.scrollFactor.set(0, 0);
		_subBar.cameras = [uiCam];
		_subBar.alpha = 0.82;
		flxState.add(_subBar);

		_subTxt = new FlxText(0, 0, 1280, "", 18);
		_subTxt.font = "assets/fonts/timer.otf";
		_subTxt.color = FlxColor.WHITE;
		_subTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_subTxt.alignment = flixel.text.FlxText.FlxTextAlign.CENTER;
		_subTxt.scrollFactor.set(0, 0);
		_subTxt.cameras = [uiCam];
		_subTxt.visible = false;
		flxState.add(_subTxt);
	}

	public function getDist():Float
	{
		var dx = _player.x + _player.width  * 0.5 - (x + width  * 0.5);
		var dy = _player.y + _player.height * 0.5 - (y + height * 0.5);
		if (Math.abs(dy) > 80.0) return 9999.0;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function npcUpdate(elapsed:Float):Void
	{
		if (_subBar == null) return;
		var dist = getDist();

		switch (_state)
		{
			case GIdle:
				var t = 1.0 - Math.min(Math.max((dist - 50.0) / (INTERACT_DIST - 50.0), 0.0), 1.0);
				if (_eButton != null)
				{
					if (t > 0)
					{
						_eButton.alpha = t * 0.55;
						_eButton.x = x + (width  - _eButton.width)  * 0.5;
						_eButton.y = y - _eButton.height - 6;
					}
					else _eButton.alpha = 0;
				}

				if (FlxG.keys.justPressed.E && dist <= 50.0)
				{
					if (_eButton != null) _eButton.alpha = 0;
					_state     = GTalking;
					_lineIdx   = 0;
					_lineTimer = 0;
					_player.cinematic = true;
					_startLine(0);
				}

			case GTalking:
				if (_eButton != null) _eButton.alpha = 0;
				_lineTimer += elapsed;

				var barTargetY = 896.0 - _subBar.height;

				if (_slideOut)
				{
					_slideTimer += elapsed;
					var t2 = Math.min(_slideTimer / 0.35, 1.0);
					t2 = t2 * t2;
					_subBar.y = _lerp(barTargetY, 896.0, t2);
					_subTxt.y = _subBar.y + (_subBar.height - _subTxt.height) * 0.5;
					if (_slideTimer >= 0.35)
					{
						_subTxt.visible = false;
						_state = GDone;
						_player.cinematic = false;
					}
					return;
				}

				var barT = Math.min(_lineTimer / 0.25, 1.0);
				barT = 1.0 - (1.0 - barT) * (1.0 - barT);
				_subBar.y = _lerp(896.0, barTargetY, barT);
				_subTxt.y = _subBar.y + (_subBar.height - _subTxt.height) * 0.5;

				if (_typing)
				{
					_charTimer -= elapsed;
					if (_charTimer <= 0)
					{
						_charIdx++;
						var full = LINES[_lineIdx];
						if (_charIdx >= full.length)
						{
							_subTxt.text = full;
							_typing = false;
							_holdTimer = 0;
						}
						else
						{
							_subTxt.text = full.substr(0, _charIdx);
							var ch = full.charAt(_charIdx - 1);
							// uuuuu hit that shi fat boy. 
							if (ch != " ") FlxG.sound.play("assets/shared/sounds/minigame/thevalley/eggman.ogg", 0.35);
							_charTimer = CHAR_DELAY;
						}
					}
				}
				else
				{
					_holdTimer += elapsed;
					if (_holdTimer >= LINE_HOLD[_lineIdx])
					{
						_lineIdx++;
						if (_lineIdx >= LINES.length)
							_endTalking();
						else
							_startLine(_lineIdx);
					}
				}

			case GDone:
				if (_eButton != null) _eButton.alpha = 0;
		}
	}

	function _startLine(idx:Int):Void
	{
		_subTxt.text    = "";
		_subTxt.visible = true;
		_charIdx   = 0;
		_charTimer = CHAR_DELAY;
		_typing    = true;
		_holdTimer = 0;
	}

	function _endTalking():Void
	{
		_subTxt.visible = false;
		_slideOut  = true;
		_slideTimer = 0;
	}

	inline function _lerp(a:Float, b:Float, t:Float):Float return a + (b - a) * t;
}

// jajajaja pinshe treno se te murio la pendeja
class AmyNPC extends FlxSprite
{
	public function new(wx:Float, wy:Float)
	{
		super(wx, wy);
		frames = Paths.getSparrowAtlas("minigame/thevalley/characters/dead/amy");
		animation.addByPrefix("dead", "amy dead", 8, true);
		animation.play("dead"); 
		scrollFactor.set(1, 1);
		moves = false; // bro wasnt gon move anyway lol
	}
}

// i dont think he chuckles anymore
class KnucklesNPC extends FlxSprite
{
	public function new(wx:Float, wy:Float)
	{
		super(wx, wy);
		frames = Paths.getSparrowAtlas("minigame/thevalley/characters/dead/knuckles");
		animation.addByPrefix("dead", "knuckles dead", 8, true);
		animation.play("dead");
		scrollFactor.set(1, 1);
		moves = false; // he dead too :c my goat
	}
}
