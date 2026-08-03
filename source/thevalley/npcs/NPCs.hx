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
	static final LINES:Array<String> = [
		"Your beloved dear isn't just asleep, girl.",
		"Whatever put him under.....",
		"it knew what it was doing.",
	];

	static final LINE_START:Array<Float> = [0.0,  7.62,  10.70];
	static final LINE_END:Array<Float>   = [5.92, 9.64,  14.71];

	static final RED_LEN:Array<Int> = [0, 0, 2];

	public var isTalking(get, never):Bool;
	inline function get_isTalking() return _state == GTalking;

	var _player:Player;
	var _eButton:FlxSprite;
	var _cam:FlxCamera;
	var _state:GaryState = GIdle;

	var _subBar:FlxSprite;
	var _subTxt:FlxText;
	var _subTxtRed:FlxText;

	var _lineIdx:Int      = 0;
	var _lineTimer:Float  = 0;
	var _charIdx:Int      = 0;
	var _charTimer:Float  = 0;
	var _typing:Bool      = false;
	var _slideOut:Bool    = false;
	var _slideTimer:Float = 0;

	var _zoomFrom:Float  = 0;
	var _hasTalked:Bool  = false;

	public function new(wx:Float, wy:Float, player:Player, cutscene:TVCutscene, uiCam:FlxCamera, flxState:flixel.FlxState, cam:FlxCamera)
	{
		super(wx, wy);
		_player  = player;
		_eButton = cutscene?.eButton ?? null;
		_cam     = cam;

		frames = Paths.getSparrowAtlas("minigame/thevalley/characters/dead/gary");
		animation.addByPrefix("aura", "gary aura", 8, true);
		animation.play("aura");
		scrollFactor.set(1, 1);
		moves = false;

		if (uiCam == null) return;

		_subBar = new FlxSprite(0, FlxG.height);
		_subBar.makeGraphic(FlxG.width, 54, 0xFF000000);
		_subBar.scrollFactor.set(0, 0);
		_subBar.cameras = [uiCam];
		_subBar.alpha = 0.82;
		flxState.add(_subBar);

		_subTxtRed = new FlxText(0, 0, 0, "", 18);
		_subTxtRed.font = "assets/fonts/SonicFont.ttf";
		_subTxtRed.color = FlxColor.RED;
		_subTxtRed.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_subTxtRed.scrollFactor.set(0, 0);
		_subTxtRed.cameras = [uiCam];
		_subTxtRed.visible = false;
		flxState.add(_subTxtRed);

		_subTxt = new FlxText(0, 0, 0, "", 18);
		_subTxt.font = "assets/fonts/SonicFont.ttf";
		_subTxt.color = FlxColor.WHITE;
		_subTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		_subTxt.scrollFactor.set(0, 0);
		_subTxt.cameras = [uiCam];
		_subTxt.visible = false;
		flxState.add(_subTxt);
	}

	public function getDist():Float
	{
		var dx = _player.x + _player.width  * 0.5 - (x + width  * 0.5);
		var dy = _player.y + _player.height * 0.5 - (y + height * 0.5);

		if (Math.abs(dy) > 40.0) return 9999.0;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function npcUpdate(elapsed:Float):Void
	{
		if (_subBar == null) return;
		var dist = getDist();

		switch (_state)
		{
			case GIdle:
				var t = 1.0 - Math.min(Math.max((dist - 50.0) / (90.0 - 50.0), 0.0), 1.0);
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
					_hasTalked = true;
					if (_cam != null) _zoomFrom = _cam.zoom;
					_startLine(0);
					FlxG.sound.play(Paths.sound("minigame/thevalley/gary"), 0.8);
				}

			case GTalking:
				if (_eButton != null) _eButton.alpha = 0;
				_lineTimer += elapsed;

				var barTargetY = FlxG.height - _subBar.height;

				if (_slideOut)
				{
					_slideTimer += elapsed;
					var t2 = Math.min(_slideTimer / 0.35, 1.0);
					t2 = t2 * t2;
					_subBar.y = _lerp(barTargetY, FlxG.height, t2);
					_subTxt.y    = _subBar.y + (_subBar.height - _subTxt.height) * 0.5;
					_subTxtRed.y = _subTxt.y;
					if (_slideTimer >= 0.35)
					{
						_subTxt.visible    = false;
						_subTxtRed.visible = false;
						_state = GDone;
						_player.cinematic = false;
					}
					return;
				}

				var barT = Math.min(_lineTimer / 0.25, 1.0);
				barT = 1.0 - (1.0 - barT) * (1.0 - barT);
				_subBar.y = _lerp(FlxG.height, barTargetY, barT);
				_subTxt.y    = _subBar.y + (_subBar.height - _subTxt.height) * 0.5;
				_subTxtRed.y = _subTxt.y;

				if (_typing)
				{
					_charTimer -= elapsed;
					if (_charTimer <= 0)
					{
						_charIdx++;
						if (_charIdx >= LINES[_lineIdx].length)
							_typing = false;
						else
							_charTimer = 0.045;
						_updateLineDisplay();
					}
				}
				else if (_lineIdx < LINES.length)
				{
					if (_lineTimer >= LINE_END[_lineIdx])
					{

						_subTxt.text    = "";
						_subTxtRed.text = "";
						_lineIdx++;
					}
					else if (_subTxt.text == "" && _lineTimer >= LINE_START[_lineIdx])
					{
						_startLine(_lineIdx);
					}
				}

				if (_lineIdx >= LINES.length && _lineTimer >= 16.19)
					_endTalking();

			case GDone:
				if (_eButton != null) _eButton.alpha = 0;
		}

		_updateTalkZoom(elapsed);
	}

	function _updateTalkZoom(elapsed:Float):Void
	{
		if (_cam == null || !_hasTalked) return;
		var target = isTalking ? (_zoomFrom + 0.3) : _zoomFrom;
		if (!isTalking && Math.abs(_cam.zoom - target) < 0.01) return;
		_cam.zoom += (target - _cam.zoom) * (1.0 - Math.pow(0.01, elapsed * 2.0));
	}

	function _startLine(idx:Int):Void
	{
		_subTxt.text       = "";
		_subTxt.visible    = true;
		_subTxtRed.text    = "";
		_subTxtRed.visible = true;
		_charIdx   = 0;
		_charTimer = 0.045;
		_typing    = true;
	}

	function _updateLineDisplay():Void
	{
		var full   = LINES[_lineIdx];
		var shown  = full.substr(0, _charIdx);
		var redLen = RED_LEN[_lineIdx];
		var redPart   = shown.length <= redLen ? shown : shown.substr(0, redLen);
		var whitePart = shown.length <= redLen ? "" : shown.substr(redLen);

		_subTxtRed.text = redPart;
		_subTxt.text    = whitePart;

		var totalW = _subTxtRed.width + _subTxt.width;
		_subTxtRed.x = (FlxG.width - totalW) * 0.5;
		_subTxt.x    = _subTxtRed.x + _subTxtRed.width;
	}

	function _endTalking():Void
	{
		_subTxt.visible    = false;
		_subTxtRed.visible = false;
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