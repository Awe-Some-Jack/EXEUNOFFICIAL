package minigames.preymini.character.player;

import flixel.group.FlxGroup.FlxTypedGroup;

class HUD extends FlxTypedGroup<FlxSprite>
{
	public var score(default, set):Int;
	public var rings(default, set):Int;
	public var time(default, set):Float;
	public var lives(default, set):Int;
	public var timing:Bool = true;

	final _cam:FlxCamera;
	final _ringsLabel:FlxSprite;
	final _ringsAlt:FlxSprite;
	final _cardBar:FlxSprite;
	final _cardText:FlxSprite;
	final _score:Array<FlxSprite> = [];
	final _rings:Array<FlxSprite> = [];
	final _time:Array<FlxSprite> = [];
	final _lives:Array<FlxSprite> = [];
	final _lifeIcon:FlxSprite;
	final _game:FlxSprite;
	final _over:FlxSprite;

	var _timeText:String = null;
	var _beatClock:Float = 0;
	var _cardTweens:Array<FlxTween> = [];
	var _cardTimer:FlxTimer = null;

	public function new(cam:FlxCamera)
	{
		super();
		_cam = cam;

		add(_label("score", 0));
		add(_label("time", 1));
		_ringsLabel = add(_label("rings-normal", 2));
		_ringsAlt = add(_label("rings-alt", 2));

		_cardBar = add(_sprite("card/cardBar"));
		_cardText = add(_sprite("card/cardText"));
		_cardBar.visible = _cardText.visible = false;

		_lifeIcon = add(_sprite("life/lifecounter"));
		_lifeIcon.setPosition(16 * 3, (FlxG.height / 3 - 24) * 3);

		_game = add(_sprite("gameover/game"));
		_over = add(_sprite("gameover/over"));
		_game.visible = _over.visible = false;

		score = 0;
		rings = 0;
		time = 0;
		lives = 3;
		_blink();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		_beatClock += elapsed;
		if (timing) time += elapsed;
		_blink();
	}

	public function showCard():Void
	{
		_stopCard();
		final textX = 24;
		_cardBar.x = FlxG.width - 20 - _cardText.width - textX;
		_cardBar.y = -_cardBar.height;
		_cardText.setPosition(FlxG.width, 216);
		_cardBar.visible = _cardText.visible = true;

		_cardTweens = [
			FlxTween.tween(_cardBar, {y: 0}, 60 / 176),
			FlxTween.tween(_cardText, {x: _cardBar.x + textX}, 0.375)
		];
		_cardTimer = new FlxTimer().start((60 / 176) * 6, _ ->
		{
			_cardTweens = [
				FlxTween.tween(_cardBar, {y: -_cardBar.height}, (60 / 176) * 0.5),
				FlxTween.tween(_cardText, {x: FlxG.width}, (60 / 176) * 1.1 * 0.5, {onComplete: _ -> _cardBar.visible = _cardText.visible = false})
			];
		});
	}

	public function showGameOver():Void
	{
		_stopCard();
		_cardBar.visible = _cardText.visible = false;
		final top = Math.round(FlxG.height / 3 / 2 - 8) * 3;
		final gameX = Math.round((FlxG.width / 3 - 140) / 2) * 3;
		final overX = gameX + 79 * 3;
		_game.setPosition(-_game.width, top);
		_over.setPosition(FlxG.width, top);
		_game.visible = _over.visible = true;
		_cardTweens = [
			FlxTween.tween(_game, {x: gameX}, 0.5),
			FlxTween.tween(_over, {x: overX}, 0.5)
		];
	}

	function set_lives(value:Int):Int
	{
		lives = Std.int(Math.max(0, value));
		final text = Std.string(Math.min(lives, 99));
		while (_lives.length < text.length)
		{
			final digit = _sprite();
			insert(members.indexOf(_cardBar), digit);
			_lives.push(digit);
		}
		for (i in 0..._lives.length)
		{
			final digit = _lives[i];
			digit.visible = i < text.length;
			if (!digit.visible) continue;
			digit.animation.frameIndex = _frame(text.charAt(i));
			digit.setPosition((41 + i * 8) * 3, (FlxG.height / 3 - 19) * 3);
		}
		return lives;
	}

	function set_score(value:Int):Int
	{
		score = value;
		_write(_score, Std.string(value), 89, 0);
		return value;
	}

	function set_rings(value:Int):Int
	{
		rings = value;
		_write(_rings, Std.string(value), 65, 2);
		return value;
	}

	function set_time(value:Float):Float
	{
		time = Math.max(0, value);
		final ms = Std.int(time * 1000);
		final s = Std.int(ms / 1000);
		final text = '${Std.int(s / 60) % 60}:${_two(s % 60)};${_two(Std.int(ms / 10) % 100)}';
		if (text != _timeText)
		{
			_timeText = text;
			_write(_time, text, 89, 1);
		}
		return time;
	}

	function _blink():Void
	{
		final red = rings == 0 && Std.int(_beatClock / (60 / 176)) % 2 == 0;
		_ringsAlt.visible = red;
		_ringsLabel.visible = !red;
	}

	function _write(digits:Array<FlxSprite>, text:String, last:Float, row:Int):Void
	{
		while (digits.length < text.length)
		{
			final digit = _sprite();
			insert(members.indexOf(_cardBar), digit);
			digits.push(digit);
		}
		final first = 16 + last - (text.length - 1) * 8;
		for (i in 0...digits.length)
		{
			final digit = digits[i];
			digit.visible = i < text.length;
			if (!digit.visible) continue;
			digit.animation.frameIndex = _frame(text.charAt(i));
			digit.setPosition((first + i * 8) * 3, (8 + 16 * row) * 3);
		}
	}

	static function _frame(char:String):Int
	{
		return switch (char)
		{
			case ":": 10;
			case ";": 11;
			case "-": 12;
			default: Std.parseInt(char);
		}
	}

	static inline function _two(n:Int):String
	{
		return n < 10 ? '0$n' : '$n';
	}

	function _label(image:String, row:Int):FlxSprite
	{
		final label = _sprite(image);
		label.setPosition(48, (8 + 16 * row) * 3);
		return label;
	}

	function _sprite(?image:String):FlxSprite
	{
		final sprite = new FlxSprite();
		if (image == null)
			sprite.loadGraphic(Paths.image("minigame/preymini/hud/numbers"), true, 7, 11);
		else
			sprite.loadGraphic(Paths.image("minigame/preymini/hud/" + image));
		sprite.antialiasing = false;
		sprite.scale.set(3, 3);
		sprite.updateHitbox();
		sprite.scrollFactor.set(0, 0);
		sprite.moves = false;
		sprite.cameras = [_cam];
		return sprite;
	}

	function _stopCard():Void
	{
		for (tween in _cardTweens) tween.cancel();
		_cardTweens = [];
		if (_cardTimer != null) _cardTimer.cancel();
		_cardTimer = null;
	}

	override public function destroy():Void
	{
		_stopCard();
		super.destroy();
	}
}
