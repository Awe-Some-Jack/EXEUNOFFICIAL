package minigames.thevalley.character.player;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

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

	var _alpha:Float    = 0.0;
	var _lastStr:String = "";
	var _maxDigits:Int;

	public function new(group:FlxGroup, cam:FlxCamera, maxDigits:Int, sc:Float = 1.0)
	{
		_group     = group;
		_cam       = cam;
		_maxDigits = maxDigits;
		scale      = sc;

		var frames = Paths.getSparrowAtlas("minigame/thevalley/objects/hud/numbers");

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
		{ id: "life",  x: 38, y: 576, sc: 3.21 },
		{ id: "score", x: 32, y: 29,  sc: 3.0  },
		{ id: "time",  x: 34, y: 112, sc: 3.0  },
	];

	static inline var SHARD_SCALE:Float   = 2.8864;

	var _cam:FlxCamera;
	var _group:FlxGroup;
	var _items:Array<HudItem>        = [];
	var _sprMap:Map<String, HudItem> = new Map();

	var _timeDisp:NumberDisplay;
	var _scoreDisp:NumberDisplay;
	var _lifeDisp:NumberDisplay;
	var _shardsDisp:NumberDisplay;
	var _timeSep:FlxSprite;
	var _shardsHud:FlxSprite;
	var _shards:Array<FlxSprite> = [];

	var _radarCenter:FlxSprite;
	var _radarDot:FlxSprite;
	var _radarAlpha:Float = 0;
	var _radarTarget:Float = 0;
	var _radarPulse:Float = 0;

	public var radarHidden:Bool = false;

	var _targetAlpha:Float = 0.0;
	var _alpha:Float       = 0.0;

	var _lastTime:Int   = -1;
	var _lastScore:Int  = -1;
	var _lastLives:Int  = -1;
	var _lastShards:Int = -1;

	public var lives:Int         = 3;
	public var score:Int         = 0;
	public var timeElapsed:Float = 0;
	public var timerRunning:Bool = false;
	public var shards:Int        = 0;

	var _shownScore:Float = 0;

	final _popups:Array<{ text:FlxText, age:Float }> = [];

	public var onDeath:Void->Void = null;
	public var onShardsComplete:Void->Void = null;
	public var forceShardsVisible:Bool = false;

	var _shardPop:Array<Float>  = [0, 0, 0, 0, 0, 0];
	var _shardPopSc:Float       = 2.2;

	static inline var SHARD_NOTIFY_DUR:Float = 3.0;
	var _shardNotifyTimer:Float = 0;
	var _shardAlpha:Float       = 0;

	public function new(state:flixel.FlxState, cam:FlxCamera)
	{
		_cam   = cam;
		_group = new FlxGroup();
		state.add(_group);

		for (d in SPR_DEFAULTS)
		{
			var spr = new FlxSprite(d.x, d.y);
			spr.loadGraphic(Paths.image('minigame/thevalley/objects/hud/${d.id}'));
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
		_lifeDisp  = new NumberDisplay(_group, cam, 2, 2.87);

		var timeDigitX  = [203.0, 219.0, 265.0, 300.0];
		var timeDigitY  = 122.0;
		for (i in 0...4) {
			_timeDisp.digitSprites[i].x = timeDigitX[i];
			_timeDisp.digitSprites[i].y = timeDigitY;
		}

		var scoreDigitX = [176.0, 204.0, 232.0, 260.0, 288.0, 316.0];
		var scoreDigitY = 38.0;
		for (i in 0...6) {
			_scoreDisp.digitSprites[i].x = scoreDigitX[i];
			_scoreDisp.digitSprites[i].y = scoreDigitY;
		}

		var lifeDigitX = [155.0, 173.0];
		var lifeDigitY = 629.0;
		for (i in 0...2) {
			_lifeDisp.digitSprites[i].x = lifeDigitX[i];
			_lifeDisp.digitSprites[i].y = lifeDigitY;
		}

		_shardsHud = new FlxSprite(587.0, 18.0);
		_shardsHud.loadGraphic(Paths.image("minigame/thevalley/objects/hud/shards/shardstypeshi"));
		_shardsHud.scale.set(3.12, 3.12);
		_shardsHud.updateHitbox();
		_shardsHud.scrollFactor.set(0, 0);
		_shardsHud.cameras = [cam];
		_shardsHud.alpha = 0;
		_group.add(_shardsHud);

		var shardXs = [618.0, 648.0, 681.0, 713.0, 745.0, 775.0];
		for (i in 0...6)
		{
			var sh = new FlxSprite(shardXs[i], 16.0);
			sh.loadGraphic(Paths.image("minigame/thevalley/objects/hud/shards/shard"));
			sh.scale.set(SHARD_SCALE, SHARD_SCALE);
			sh.updateHitbox();
			sh.scrollFactor.set(0, 0);
			sh.cameras = [cam];
			sh.alpha = 0;
			_group.add(sh);
			_shards.push(sh);
		}

		_shardsDisp = new NumberDisplay(_group, cam, 1, 3.15);
		_shardsDisp.digitSprites[0].x = 820.0;
		_shardsDisp.digitSprites[0].y = 30.0;

		_timeSep = new FlxSprite(248.0, 123.0);
		_timeSep.loadGraphic(Paths.image("minigame/thevalley/objects/hud/signo"));
		_timeSep.scale.set(3.5, 3.5);
		_timeSep.updateHitbox();
		_timeSep.scrollFactor.set(0, 0);
		_timeSep.cameras = [cam];
		_timeSep.alpha = 0;
		_timeSep.visible = false;
		_group.add(_timeSep);

		_radarCenter = new FlxSprite(900.0 - 3, 660.0 - 3);
		_radarCenter.makeGraphic(6, 6, 0xFF555555);
		_radarCenter.scrollFactor.set(0, 0);
		_radarCenter.cameras = [cam];
		_radarCenter.alpha = 0;
		_group.add(_radarCenter);

		_radarDot = new FlxSprite(900.0 - 5, 660.0 - 5);
		_radarDot.makeGraphic(10, 10, 0xFFFF3030);
		_radarDot.scrollFactor.set(0, 0);
		_radarDot.cameras = [cam];
		_radarDot.alpha = 0;
		_group.add(_radarDot);

		for (_ in 0...3)
		{
			final t = new FlxText(40.0, 84.0, 0, "", 18);
			t.font = "assets/fonts/SonicFont.ttf";
			t.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
			t.scrollFactor.set(0, 0);
			t.cameras = [cam];
			t.alpha = 0;
			state.add(t);
			_popups.push({ text: t, age: 2.4 });
		}
	}

	public function setVisible(show:Bool):Void
		_targetAlpha = show ? 1.0 : 0.0;

	public function addShard():Void
	{
		if (shards >= 6) return;
		_shardPop[shards] = 0.35;
		shards++;
		_shardNotifyTimer = SHARD_NOTIFY_DUR;

		FlxG.sound.play(Paths.sound("minigame/thevalley/crystal"), 0.5);
		if (shards >= 6 && onShardsComplete != null)
			onShardsComplete();
	}

	public function flashShards():Void
	{
		_shardNotifyTimer = SHARD_NOTIFY_DUR;
	}

	public function addPoints(amount:Int, label:String):Void
	{
		final before = score;
		score = Std.int(Math.max(0, score + amount));
		final change = score - before;

		var slot = _popups[0];
		for (p in _popups) if (p.age > slot.age) slot = p;
		slot.age = 0;
		slot.text.text = change > 0 ? '+$change $label' : change < 0 ? '$change $label' : label;
		slot.text.color = amount >= 0 ? 0xFFFFE070 : 0xFFFF4040;
	}

	function _updatePopups(elapsed:Float):Void
	{
		final order = _popups.copy();
		order.sort((a, b) -> a.age < b.age ? -1 : (a.age > b.age ? 1 : 0));
		var row = 0;
		for (p in order)
		{
			if (p.age >= 2.4)
			{
				p.text.alpha = 0;
				continue;
			}
			p.age += elapsed;
			final t = Math.min(p.age / 2.4, 1.0);
			p.text.y = 84.0 + row * 24 - 10 * t;
			p.text.alpha = t < 0.7 ? 1.0 : 1.0 - (t - 0.7) / 0.3;
			row++;
		}
	}

	public function setMonsterDirection(dx:Float, dy:Float, active:Bool):Void
	{
		_radarTarget = active ? 1.0 : 0.0;
		if (!active) return;

		var angle = Math.atan2(dy, dx);
		var cx = 900.0;
		var cy = 660.0;
		_radarDot.x = cx + Math.cos(angle) * 22.0 - 5;
		_radarDot.y = cy + Math.sin(angle) * 22.0 - 5;
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

		_refreshDisplays(elapsed);
		_updatePopups(elapsed);
	}

	function _refreshDisplays(elapsed:Float):Void
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
		_shownScore += (score - _shownScore) * (1.0 - Math.pow(0.01, elapsed * 6.0));
		if (Math.abs(score - _shownScore) < 0.5) _shownScore = score;
		final shown = Math.round(_shownScore);
		if (shown != _lastScore)
		{
			_lastScore = shown;
			_scoreDisp.setValue('${shown}');
		}
		if (lives != _lastLives)
		{
			_lastLives = lives;
			_lifeDisp.setValue('${lives}');
		}
		if (shards != _lastShards)
		{
			_lastShards = shards;
			_shardsDisp.setValue('${shards}');
		}

		if (_shardNotifyTimer > 0)
		{
			_shardNotifyTimer -= elapsed;
			if (_shardNotifyTimer < 0) _shardNotifyTimer = 0;
		}
		var shardTarget = (_shardNotifyTimer > 0 || forceShardsVisible) ? 1.0 : 0.0;
		if (_shardAlpha != shardTarget)
		{
			var spd = 1.0 - Math.pow(1.0 / 4.0, elapsed);
			_shardAlpha += (shardTarget - _shardAlpha) * spd;
			if (Math.abs(_shardAlpha - shardTarget) < 0.01) _shardAlpha = shardTarget;
		}
		_shardsHud.alpha  = _shardAlpha;
		_shardsDisp.alpha = _shardAlpha;

		if (_radarAlpha != _radarTarget)
		{
			var rspd = 1.0 - Math.pow(1.0 / 4.0, elapsed);
			_radarAlpha += (_radarTarget - _radarAlpha) * rspd;
			if (Math.abs(_radarAlpha - _radarTarget) < 0.01) _radarAlpha = _radarTarget;
		}
		_radarPulse = radarHidden ? _radarPulse + elapsed : 0;
		_radarCenter.alpha = _radarAlpha * 0.6;
		_radarDot.alpha    = _radarAlpha * (radarHidden ? 0.3 + 0.2 * Math.sin(_radarPulse * 2.5) : 1.0);

		var a = _shardAlpha;
		for (i in 0..._shards.length)
		{
			var sh = _shards[i];
			if (_shardPop[i] > 0)
			{
				_shardPop[i] -= FlxG.elapsed;
				var t = Math.max(0, _shardPop[i] / 0.35);
				var sc = SHARD_SCALE * (1.0 + (_shardPopSc - 1.0) * t * t);
				sh.scale.set(sc, sc);
				sh.updateHitbox();
				sh.alpha = a;
			}
			else
			{
				sh.scale.set(SHARD_SCALE, SHARD_SCALE);
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
	}
}