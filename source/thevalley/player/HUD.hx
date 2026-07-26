package thevalley.player;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.graphics.frames.FlxAtlasFrames;

typedef HudItem = {
	var id:String;
	var sprite:FlxSprite;
	var scale:Float;
}

// no bitmap font tech here, its literally just a row of individual digit sprites
class NumberDisplay
{
	public var alpha(get, set):Float;
	public var scale:Float = 1.0;

	public var digitSprites(get, never):Array<FlxSprite>;
	inline function get_digitSprites() return _digits;

	var _digits:Array<FlxSprite> = [];
	var _group:FlxGroup;
	var _cam:FlxCamera;
	var _alpha:Float    = 1.0;
	var _lastStr:String = "";
	var _maxDigits:Int;

	public function new(group:FlxGroup, cam:FlxCamera, maxDigits:Int, sc:Float = 1.0)
	{
		_group     = group;
		_cam       = cam;
		_maxDigits = maxDigits;
		scale      = sc;

		var frames = FlxAtlasFrames.fromSparrow(
			"assets/shared/images/minigame/thevalley/objects/hud/numbers.png",
			"assets/shared/images/minigame/thevalley/objects/hud/numbers.xml"
		);
		for (_ in 0..._maxDigits)
		{
			var spr = new FlxSprite(0, 0);
			spr.frames = frames;
			for (d in 0...10)
				spr.animation.addByPrefix('$d', 'numbers ${d}0000', 1, false);
			spr.animation.play("0");
			spr.scale.set(scale, scale);
			spr.updateHitbox();
			spr.scrollFactor.set(0, 0);
			spr.cameras = [cam];
			spr.alpha   = _alpha;
			spr.visible = false;
			group.add(spr);
			_digits.push(spr);
		}
	}

	public function setValue(str:String):Void
	{
		if (str == _lastStr) return;
		_lastStr = str;

		var len = str.length;
		for (i in 0..._digits.length)
		{
			var spr    = _digits[i];
			var charIdx = i - (_maxDigits - len);
			if (charIdx < 0 || charIdx >= len) { spr.visible = false; continue; }
			var ch = str.charAt(charIdx);
			var d  = Std.parseInt(ch);
			if (d == null) { spr.visible = false; continue; }
			spr.animation.play('$d');
			spr.visible = true;
		}
	}

	public function setTimeValue(mins:Int, secs:Int):Void
	{
		setValue('${mins}${secs < 10 ? "0" + secs : "" + secs}');
	}

	function get_alpha() return _alpha;
	function set_alpha(v:Float)
	{
		_alpha = v;
		for (spr in _digits) spr.alpha = v;
		return v;
	}
}

class HUD
{
	static final SPR_DEFAULTS:Array<{ id:String, x:Float, y:Float, sc:Float }> = [
		{ id: "life",  x: 38,  y: 735, sc: 3.71 },
		{ id: "score", x: 37,  y: 37,  sc: 3.52 },
		{ id: "time",  x: 39,  y: 130, sc: 3.52 },
	];

	var _cam:FlxCamera;
	var _group:FlxGroup;
	var _items:Array<HudItem>        = [];
	var _sprMap:Map<String, HudItem> = new Map();

	var _timeDisp:NumberDisplay;
	var _scoreDisp:NumberDisplay;
	var _lifeDisp:NumberDisplay;
	var _timeSep:FlxSprite;
	var _shardsHud:FlxSprite;
	var _shards:Array<FlxSprite> = [];
	var _staminaBg:FlxSprite;
	var _staminaFill:FlxSprite;
	var _staminaRatio:Float = 1.0;

	var _targetAlpha:Float = 0.0;
	var _alpha:Float       = 0.0;

	var _lastTime:Int  = -1;
	var _lastScore:Int = -1;
	var _lastLives:Int = -1;

	public var lives:Int         = 3;
	public var score:Int         = 0;
	public var timeElapsed:Float = 0;
	public var timerRunning:Bool = false;
	public var shards:Int        = 0;

	public var onDeath:Void->Void = null;
	public var onShardsComplete:Void->Void = null;

	var _shardPop:Array<Float>  = [0, 0, 0, 0, 0, 0];
	var _shardPopSc:Float       = 2.2;

	public function new(state:flixel.FlxState, cam:FlxCamera)
	{
		_cam   = cam;
		_group = new FlxGroup();
		state.add(_group);

		for (d in SPR_DEFAULTS)
		{
			var spr = new FlxSprite(d.x, d.y);
			spr.loadGraphic('assets/shared/images/minigame/thevalley/objects/hud/${d.id}.png');
			spr.scale.set(d.sc, d.sc);
			spr.updateHitbox();
			spr.scrollFactor.set(0, 0);
			spr.cameras = [cam];
			spr.alpha = 0;
			_group.add(spr);
			var item:HudItem = { id: d.id, sprite: spr, scale: d.sc };
			_items.push(item);
			_sprMap[d.id] = item;
		}

		_timeDisp  = new NumberDisplay(_group, cam, 4, 3.5);
		_scoreDisp = new NumberDisplay(_group, cam, 6, 3.5);
		_lifeDisp  = new NumberDisplay(_group, cam, 2, 3.5);

		var timeDigitX  = [253.0, 269.0, 315.0, 350.0];
		var timeDigitY  = 144.0;
		for (i in 0...4) {
			_timeDisp.digitSprites[i].x = timeDigitX[i];
			_timeDisp.digitSprites[i].y = timeDigitY;
		}

		var scoreDigitX = [179.0, 197.0, 215.0, 233.0, 251.0, 269.0];
		var scoreDigitY = 50.0;
		for (i in 0...6) {
			_scoreDisp.digitSprites[i].x = scoreDigitX[i];
			_scoreDisp.digitSprites[i].y = scoreDigitY;
		}

		var lifeDigitX = [195.0, 213.0];
		var lifeDigitY = 795.0;
		for (i in 0...2) {
			_lifeDisp.digitSprites[i].x = lifeDigitX[i];
			_lifeDisp.digitSprites[i].y = lifeDigitY;
		}

		_shardsHud = new FlxSprite(852.0, 18.0);
		_shardsHud.loadGraphic("assets/shared/images/minigame/thevalley/objects/hud/shards/shardstypeshi.png");
		_shardsHud.scale.set(3.52, 3.52);
		_shardsHud.updateHitbox();
		_shardsHud.scrollFactor.set(0, 0);
		_shardsHud.cameras = [cam];
		_shardsHud.alpha = 0;
		_group.add(_shardsHud);

		var shardXs = [905.0, 935.0, 968.0, 1000.0, 1032.0, 1062.0];
		for (i in 0...6)
		{
			var sh = new FlxSprite(shardXs[i], 18.0);
			sh.loadGraphic("assets/shared/images/minigame/thevalley/objects/hud/shards/shard.png");
			sh.scale.set(3.52, 3.52);
			sh.updateHitbox();
			sh.scrollFactor.set(0, 0);
			sh.cameras = [cam];
			sh.alpha = 0;
			_group.add(sh);
			_shards.push(sh);
		}

		_timeSep = new FlxSprite(297.0, 144.0);
		_timeSep.loadGraphic("assets/shared/images/minigame/thevalley/objects/hud/signo.png");
		_timeSep.scale.set(3.5, 3.5);
		_timeSep.updateHitbox();
		_timeSep.scrollFactor.set(0, 0);
		_timeSep.cameras = [cam];
		_timeSep.alpha = 0;
		_timeSep.visible = false;
		_group.add(_timeSep);

		var staminaW = 120;
		var staminaH = 5;
		var staminaX = 38.0;
		var staminaY = 820.0;

		_staminaBg = new FlxSprite(staminaX, staminaY);
		_staminaBg.makeGraphic(staminaW, staminaH, 0xFF1A0505);
		_staminaBg.scrollFactor.set(0, 0);
		_staminaBg.cameras = [cam];
		_staminaBg.alpha = 0;
		_group.add(_staminaBg);

		_staminaFill = new FlxSprite(staminaX, staminaY);
		_staminaFill.makeGraphic(staminaW, staminaH, 0xFF8B0000);
		_staminaFill.scrollFactor.set(0, 0);
		_staminaFill.cameras = [cam];
		_staminaFill.alpha = 0;
		_group.add(_staminaFill);
	}

	public function setVisible(show:Bool):Void
		_targetAlpha = show ? 1.0 : 0.0;

	public function addShard():Void
	{
		if (shards >= 6) return;
		_shardPop[shards] = 0.35; // little "pop" timer so the shard icon does a lil scale-bounce when u get it, feels way more satisfyin than just poppin in flat
		shards++;
		if (shards >= 6 && onShardsComplete != null)
			onShardsComplete();
	}

	public function setStamina(ratio:Float):Void
	{
		_staminaRatio = Math.max(0, Math.min(1, ratio));
		_staminaFill.scale.x = _staminaRatio;
		_staminaFill.updateHitbox();
		_staminaFill.x = _staminaBg.x;
	}

	public function update(elapsed:Float):Void
	{
		if (timerRunning && timeElapsed < (9 * 60 + 59))
		{
			timeElapsed += elapsed;
			if (timeElapsed >= (9 * 60 + 59))
			{
				timeElapsed = (9 * 60 + 59);
				if (onDeath != null) onDeath();
			}
		}

		if (_alpha != _targetAlpha)
		{
			var spd = 1.0 - Math.pow(1.0 / 4.0, elapsed);
			_alpha += (_targetAlpha - _alpha) * spd;
			if (Math.abs(_alpha - _targetAlpha) < 0.01) _alpha = _targetAlpha;
			_applyAlpha(_alpha);
		}

		_refreshDisplays();
	}

	function _refreshDisplays():Void
	{
		var totalSec = Std.int(timeElapsed);
		if (totalSec != _lastTime)
		{
			_lastTime = totalSec;
			var mins = Std.int(totalSec / 60);
			var secs = totalSec % 60;
			_timeDisp.setTimeValue(mins, secs);
			_timeSep.visible = true;
		}
		if (score != _lastScore)
		{
			_lastScore = score;
			_scoreDisp.setValue('${score}');
		}
		if (lives != _lastLives)
		{
			_lastLives = lives;
			_lifeDisp.setValue('${lives}');
		}
		var a = _alpha;
		for (i in 0..._shards.length)
		{
			var sh = _shards[i];
			if (_shardPop[i] > 0)
			{
				_shardPop[i] -= FlxG.elapsed;
				var t = Math.max(0, _shardPop[i] / 0.35);
				var sc = 3.52 * (1.0 + (_shardPopSc - 1.0) * t * t);
				sh.scale.set(sc, sc);
				sh.updateHitbox();
				sh.alpha = a;
			}
			else
			{
				sh.scale.set(3.52, 3.52);
				sh.alpha = i < shards ? a : a * 0.2;
			}
		}
	}

	function _applyAlpha(a:Float):Void
	{
		for (item in _items) item.sprite.alpha = a;
		_timeDisp.alpha    = a;
		_scoreDisp.alpha   = a;
		_lifeDisp.alpha    = a;
		_timeSep.alpha     = a;
		_shardsHud.alpha   = a;
		_staminaBg.alpha   = a;
		_staminaFill.alpha = a * _staminaRatio > 0 ? a : 0;
	}

}
