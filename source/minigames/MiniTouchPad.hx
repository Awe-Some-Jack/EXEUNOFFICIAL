package minigames;

#if mobile
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class MiniTouchPad extends FlxSpriteGroup
{
	static final DIR:String = 'assets/exe/mobile/gamepad/';
	static final DPAD_SCALE:Float = 9;
	static final BUTTON_SCALE:Float = 6;
	static final MARGIN:Float = 40;
	static final PAD_ALPHA:Float = 0.8;
	static final STALE_MS:Float = 100;
	static final HOLD_TIME:Float = 0.3;
	static final DOUBLE_TAP_MS:Float = 300;
	static final SKIP_HOLD:Float = 0.8;
	static final PAUSE_TAP_TIME:Float = 0.35;

	static var current:Map<String, Bool> = [];
	static var previous:Map<String, Bool> = [];
	static var lastTick:Float = -1;
	static var padAlive:Bool = false;

	static function resolve(name:String):String
	{
		return switch (name)
		{
			case 'ui_left' | 'left': 'left';
			case 'ui_right' | 'right': 'right';
			case 'ui_up' | 'up': 'up';
			case 'ui_down' | 'down': 'down';
			case 'jump': 'jump';
			case 'accept': 'accept';
			case 'shards': 'shards';
			case 'skip': 'skip';
			case 'run': 'run';
			case 'pause': 'pause';
			default: null;
		}
	}

	static function fresh():Bool
		return padAlive && FlxG.game.ticks - lastTick < STALE_MS;

	public static function pressed(name:String):Bool
	{
		final key = resolve(name);
		return key != null && fresh() && current.get(key) == true;
	}

	public static function justPressed(name:String):Bool
	{
		final key = resolve(name);
		return key != null && fresh() && current.get(key) == true && previous.get(key) != true;
	}

	public static function justReleased(name:String):Bool
	{
		final key = resolve(name);
		return key != null && fresh() && current.get(key) != true && previous.get(key) == true;
	}

	public static function anyHeld():Bool
	{
		if (!fresh()) return false;
		for (value in current) if (value) return true;
		return false;
	}

	var dpadIdle:FlxSprite;
	var dpadLeft:FlxSprite;
	var dpadRight:FlxSprite;
	var dpadUp:FlxSprite;
	var dpadDown:FlxSprite;
	var jumpIdle:FlxSprite;
	var jumpPressed:FlxSprite;
	var acceptIdle:FlxSprite;
	var acceptPressed:FlxSprite;

	var dpadCX:Float = 0;
	var dpadCY:Float = 0;
	var jumpCX:Float = 0;
	var jumpCY:Float = 0;
	var acceptCX:Float = 0;
	var acceptCY:Float = 0;
	var dpadRadius:Float = 0;
	var buttonRadius:Float = 0;

	var pauseBtn:FlxSprite;
	var acceptDown:Bool = false;
	var acceptWasDown:Bool = false;
	var acceptHeld:Float = 0;
	var jumpHeld:Float = 0;
	var skipFired:Bool = false;
	var pauseWasDown:Bool = false;
	var pauseHeld:Float = 0;
	var runDir:String = null;
	var lastDown:Map<String, Float> = [];

	public function new(cam:FlxCamera)
	{
		super();
		current = [];
		previous = [];
		lastTick = -1;
		padAlive = true;

		scrollFactor.set(0, 0);

		dpadIdle = piece('dpad', DPAD_SCALE);
		dpadLeft = piece('dpad-l', DPAD_SCALE);
		dpadRight = piece('dpad-r', DPAD_SCALE);
		dpadUp = piece('dpad-u', DPAD_SCALE);
		dpadDown = piece('dpad-d', DPAD_SCALE);
		jumpIdle = piece('jump', BUTTON_SCALE);
		jumpPressed = piece('jump-p', BUTTON_SCALE);
		acceptIdle = piece('accept', BUTTON_SCALE);
		acceptPressed = piece('accept-p', BUTTON_SCALE);

		final dpadSize = dpadIdle.width;
		final buttonSize = jumpIdle.width;
		dpadRadius = dpadSize / 2;
		buttonRadius = buttonSize / 2;

		final dpadX = MARGIN;
		final dpadY = FlxG.height - dpadSize - MARGIN;
		for (s in [dpadIdle, dpadLeft, dpadRight, dpadUp, dpadDown])
			s.setPosition(dpadX, dpadY);
		dpadCX = dpadX + dpadRadius;
		dpadCY = dpadY + dpadRadius;

		final jumpX = FlxG.width - buttonSize - MARGIN;
		final jumpY = FlxG.height - buttonSize - MARGIN;
		for (s in [jumpIdle, jumpPressed])
			s.setPosition(jumpX, jumpY);
		jumpCX = jumpX + buttonRadius;
		jumpCY = jumpY + buttonRadius;

		final acceptX = jumpX - buttonSize - MARGIN * 0.5;
		final acceptY = jumpY;
		for (s in [acceptIdle, acceptPressed])
			s.setPosition(acceptX, acceptY);
		acceptCX = acceptX + buttonRadius;
		acceptCY = acceptY + buttonRadius;

		pauseBtn = new FlxSprite();
		pauseBtn.loadGraphic(Paths.getBitmapData('assets/exe/pause/pauseButton.webp'));
		pauseBtn.scale.set(0.35, 0.35);
		pauseBtn.updateHitbox();
		pauseBtn.scrollFactor.set(0, 0);
		pauseBtn.x = FlxG.width - pauseBtn.width - 10;
		pauseBtn.y = 10;
		pauseBtn.alpha = 0.7;
		#if mobile
		pauseBtn.visible = ClientPrefs.data.visiblePauseButton;
		#end
		add(pauseBtn);

		cameras = [cam];
		refreshVisuals();
	}

	function piece(file:String, scale:Float):FlxSprite
	{
		final spr = new FlxSprite();
		spr.loadGraphic(Paths.getBitmapData(DIR + file + '.png'));
		spr.antialiasing = false;
		spr.alpha = PAD_ALPHA;
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		spr.scrollFactor.set(0, 0);
		add(spr);
		return spr;
	}

	function refreshVisuals():Void
	{
		final l = current.get('left') == true;
		final r = current.get('right') == true;
		final u = current.get('up') == true;
		final d = current.get('down') == true;

		dpadLeft.visible = l;
		dpadRight.visible = r && !l;
		dpadUp.visible = u && !l && !r;
		dpadDown.visible = d && !l && !r && !u;
		dpadIdle.visible = !(l || r || u || d);

		final j = current.get('jump') == true;
		jumpPressed.visible = j;
		jumpIdle.visible = !j;

		acceptPressed.visible = acceptDown;
		acceptIdle.visible = !acceptDown;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var l = false, r = false, u = false, d = false, j = false, a = false;

		final xs:Array<Float> = [];
		final ys:Array<Float> = [];
		for (t in FlxG.touches.list)
		{
			if (!t.pressed) continue;
			xs.push(t.gameX);
			ys.push(t.gameY);
		}
		if (xs.length == 0 && FlxG.mouse.pressed)
		{
			xs.push(FlxG.mouse.gameX);
			ys.push(FlxG.mouse.gameY);
		}

		final dead = dpadRadius * 0.25;
		for (i in 0...xs.length)
		{
			final px = xs[i];
			final py = ys[i];

			final dx = px - dpadCX;
			final dy = py - dpadCY;
			if (Math.sqrt(dx * dx + dy * dy) < dpadRadius * 1.35)
			{
				if (dx < -dead) l = true;
				if (dx > dead) r = true;
				if (dy < -dead) u = true;
				if (dy > dead) d = true;
			}

			if (dist(px, py, jumpCX, jumpCY) < buttonRadius * 1.1) j = true;
			if (dist(px, py, acceptCX, acceptCY) < buttonRadius * 1.1) a = true;
		}

		var p = false;
		final pad = 15;
		for (i in 0...xs.length)
		{
			if (xs[i] >= pauseBtn.x - pad && xs[i] <= pauseBtn.x + pauseBtn.width + pad
				&& ys[i] >= pauseBtn.y - pad && ys[i] <= pauseBtn.y + pauseBtn.height + pad)
				p = true;
		}

		var pauseTap = false;
		if (p) pauseHeld += elapsed;
		else
		{
			if (pauseWasDown && pauseHeld <= PAUSE_TAP_TIME) pauseTap = true;
			pauseHeld = 0;
		}
		pauseWasDown = p;

		var acceptTap = false;
		if (a) acceptHeld += elapsed;
		else
		{
			if (acceptWasDown && acceptHeld < HOLD_TIME) acceptTap = true;
			acceptHeld = 0;
		}
		acceptWasDown = a;
		acceptDown = a;
		final shards = a && acceptHeld >= HOLD_TIME;

		var skipPulse = false;
		if (j)
		{
			jumpHeld += elapsed;
			if (jumpHeld >= SKIP_HOLD && !skipFired)
			{
				skipFired = true;
				skipPulse = true;
			}
		}
		else
		{
			jumpHeld = 0;
			skipFired = false;
		}

		final now:Float = FlxG.game.ticks;
		for (dir in ['left', 'right', 'up', 'down'])
		{
			final isDown = switch (dir)
			{
				case 'left': l;
				case 'right': r;
				case 'up': u;
				default: d;
			}
			final wasDown = current.get(dir) == true;
			if (isDown && !wasDown)
			{
				final last = lastDown.exists(dir) ? lastDown.get(dir) : -99999.0;
				runDir = now - last < DOUBLE_TAP_MS ? dir : null;
				lastDown.set(dir, now);
			}
			if (!isDown && runDir == dir) runDir = null;
		}

		previous = current;
		current = [
			'left' => l, 'right' => r, 'up' => u, 'down' => d,
			'jump' => j, 'accept' => acceptTap, 'shards' => shards,
			'run' => runDir != null, 'pause' => pauseTap, 'skip' => skipPulse
		];
		lastTick = FlxG.game.ticks;

		refreshVisuals();
	}

	inline function dist(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		final dx = ax - bx;
		final dy = ay - by;
		return Math.sqrt(dx * dx + dy * dy);
	}

	override function destroy():Void
	{
		padAlive = false;
		current = [];
		previous = [];
		super.destroy();
	}
}
#end
