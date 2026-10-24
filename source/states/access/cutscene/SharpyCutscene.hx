package states.access.cutscene;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;
import openfl.utils.Assets;

import states.LoadingState;
import states.PlayState;

typedef SharpyCamKey = {
	from:Float,
	to:Float,
	x:Float,
	y:Float,
	zoom:Float,
	angle:Float,
	ease:EaseFunction,
	?pivotX:Float,
	?pivotY:Float
}

class SharpyActor
{
	public final spr:FlxSprite;
	public var frames:Array<Int> = [0];
	public var fps:Float = 10;
	public var start:Float = 0;
	public var loop:Bool = false;
	public var fromX:Float = 0;
	public var fromY:Float = 0;
	public var toX:Float = 0;
	public var toY:Float = 0;
	public var moveStart:Float = 0;
	public var moveLength:Float = 0;
	public var height:Float = 0;
	public var crouchAmount:Float = 0;
	public var crouchStart:Float = 0;
	public var crouchHold:Float = 0;
	public var crouchRise:Float = 0;

	public function new(spr:FlxSprite)
	{
		this.spr = spr;
		spr.visible = false;
	}

	public function update(t:Float):Void
	{
		if (!spr.visible) return;
		var i = Std.int(Math.max(0, (t - start) * fps));
		i = loop ? i % frames.length : Std.int(Math.min(i, frames.length - 1));
		spr.animation.frameIndex = frames[i];
		final p = moveLength > 0 ? Math.max(0, Math.min(1, (t - moveStart) / moveLength)) : 1;
		spr.setPosition(Math.round(fromX + (toX - fromX) * p), Math.round(fromY + (toY - fromY) * p - height * 4 * p * (1 - p)));
		final c = crouchAmount <= 0 ? 0 : t < crouchStart + crouchHold ? crouchAmount
			: crouchAmount * (1 - FlxEase.backOut(Math.min(1, (t - crouchStart - crouchHold) / crouchRise)));
		spr.origin.set(spr.frameWidth * 0.5, spr.frame.offset.y + spr.frame.frame.height);
		spr.scale.set(1 + c * 0.5, 1 - c);
	}
}

class SharpyCutscene extends MusicBeatState
{
	var _cam:FlxCamera;
	var _top:FlxCamera;
	var _music:FlxSound;
	var _time:Float = 0;
	var _eventTime:Float = 0;
	var _finished:Bool = false;
	var _canSkip:Bool = false;

	final _events:Array<{ t:Float, run:Void->Void }> = [];
	var _next:Int = 0;
	final _keys:Array<SharpyCamKey> = [];
	final _fades:Array<{ t:Float, length:Float, from:Float, to:Float }> = [];
	final _flashes:Array<{ t:Float, length:Float }> = [];
	final _shakes:Array<{ t:Float, dy:Array<Int> }> = [];
	final _actors:Array<SharpyActor> = [];

	var _bg1:FlxSprite;
	var _bgZoom:FlxSprite;
	var _bg2:FlxSprite;
	var _floor:FlxSprite;
	var _dialogBox:FlxSprite;
	var _dialogFace:FlxSprite;
	var _dialogText:FlxText;
	final _lines:Array<{ from:Float, to:Float, box:String, face:String, text:String, place:String }> = [];
	var _shownLine:{ from:Float, to:Float, box:String, face:String, text:String, place:String } = null;
	var _black:FlxSprite;
	var _white:FlxSprite;

	var _box:SharpyActor;
	var _eggman:SharpyActor;
	var _exetior:SharpyActor;
	var _jina:SharpyActor;
	var _flashExetior:SharpyActor;
	var _flashExetiorFlip:SharpyActor;
	var _flashEggman:SharpyActor;
	var _bf:SharpyActor;
	var _knuckles:SharpyActor;
	var _tails:SharpyActor;

	override function create()
	{
		super.create();

		_cam = new FlxCamera();
		_cam.bgColor = 0xFF000000;
		FlxG.cameras.reset(_cam);
		_top = new FlxCamera();
		_top.bgColor = 0x00000000;
		FlxG.cameras.add(_top, false);

		_bg1 = _sprite('bg1');
		_bgZoom = _sprite('bgzoom');
		_bg2 = _sprite('bg2');
		_box = _actor('box');
		_eggman = _actor('eggman');
		_exetior = _actor('exetior');
		_jina = _actor('jina');
		_flashExetior = _actor('exetior');
		_flashExetiorFlip = _actor('exetior');
		_flashExetiorFlip.spr.flipX = true;
		_flashEggman = _actor('eggman');
		_flashEggman.spr.color = 0xFFB4B4B4;
		_bf = _actor('bf');
		_knuckles = _actor('knuckles');
		_tails = _actor('tails');
		_floor = _sprite('bg2');
		_floor.clipRect = new FlxRect(0, 204, _floor.frameWidth, _floor.frameHeight - 204);

		final s = 4;
		_dialogBox = new FlxSprite((FlxG.width - 235 * s) * 0.5, 8);
		_dialogBox.antialiasing = false;
		_dialogBox.cameras = [_top];
		_dialogBox.visible = false;
		add(_dialogBox);
		_dialogFace = new FlxSprite();
		_dialogFace.cameras = [_top];
		_dialogFace.visible = false;
		add(_dialogFace);
		_dialogText = new FlxText(_dialogBox.x + 60 * s + 12, _dialogBox.y + 5 * s + 8, 171 * s - 24, '', Language.cjkSize(26));
		_dialogText.font = Language.needsCustomFont() ? Paths.font(Language.getFontForLanguage()) : 'assets/exe/access/sharpy/box/ballot.ttf';
		_dialogText.color = 0xFFFFFFFF;
		_dialogText.cameras = [_top];
		_dialogText.visible = false;
		add(_dialogText);

		_white = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		_white.cameras = [_top];
		_white.visible = false;
		add(_white);
		_black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		_black.cameras = [_top];
		add(_black);

		_camCut(1.0, 183.03, 123.45, 1.2858, -3.947);
		_camMove(1.0, 4.75, 191.5, 135.0, 1, 0, FlxEase.linear);
		_camMove(5.125, 6.542, 250.5, 143.42, 1, 0, FlxEase.quadInOut);
		_camMove(12.5, 14.917, 218.5, 143.42, 1, 0, FlxEase.linear);
		_camMove(16.375, 17.875, 190.5, 122.42, 1, 0, FlxEase.quadInOut);
		_camCut(23.5, 185.55, 115.87, 1.2379, 0);
		_camZoomAround(23.5, 43.5, 0.6474, 189.96, 132.14, FlxEase.linear);
		_camCut(46.042, 191.5, 135.0, 1, 0);
		_camMove(47.0, 48.292, 235.5, 158.0, 1, 0, FlxEase.quadInOut);
		_camMove(57.042, 58.562, 251.5, 158.0, 1, 0, FlxEase.linear);
		_camCut(67.708, 276.5, 68.0, 1, 0);
		_camMove(68.917, 70.333, 276.5, 150.0, 1, 0, FlxEase.quadInOut);
		_camMove(75.208, 76.562, 276.5, 122.0, 1, 0, FlxEase.quadInOut);
		_camCut(80.625, 414.5, 66.0, 1, 0);
		_camMove(80.75, 84.396, 435.5, 66.0, 1, 0, FlxEase.linear);
		_camCut(84.375, 139.5, 66.0, 1, 0);
		_camMove(84.375, 88.375, 118.5, 66.0, 1, 0, FlxEase.linear);
		_camCut(88.375, 276.5, 150.0, 1, 0);
		_camCut(99.792, 131.5, 166.0, 1, 0);
		_camMove(99.792, 102.438, 117.5, 166.0, 1, 0, FlxEase.linear);
		_camCut(105.042, 277.5, 146.0, 1, 0);
		_camMove(107.417, 110.417, 185.5, 151.0, 1, 0, FlxEase.quadInOut);
		_camCut(112.917, 282.48, 172.99, 1, 0);
		_camMove(112.917, 122.875, 279.32, 171.73, 1.2876, -5.012, FlxEase.linear);
		_camCut(122.917, 185.5, 151.0, 1, 0);
		_camMove(124.146, 125.583, 273.5, 151.0, 1, 0, FlxEase.quadInOut);
		_camMove(131.5, 133.958, 184.5, 151.0, 1, 0, FlxEase.quadInOut);
		_camMove(137.0, 138.75, 280.5, 151.0, 1, 0, FlxEase.quadInOut);
		_camMove(139.146, 139.938, 309.5, 151.0, 1, 0, FlxEase.cubeInOut);
		_camMove(143.083, 144.979, 205.5, 151.0, 1, 0, FlxEase.quadInOut);

		_fade(0, 0, 1, 1);
		_fade(1.0, 0.25, 1, 0);
		_fade(63.542, 0.208, 0, 1);
		_fade(67.708, 0.208, 1, 0);
		_fade(149.083, 0, 1, 1);

		_flash(6.833, 1);
		_flash(60.375, 2);
		_flash(138.792, 2);

		_shake(6.875, [2, 0, 2, 0, 0, 2, 0, 1, 0]);
		_shake(139.583, [2, 0, 2, 2, 0, 2, 0, 1, 0, 0, 1]);

		_at(1.0, () -> _show(_eggman, 167, 141, 0));
		_at(5.1, () -> _play(_exetior, 168, 63, _range(20, 74), 20));
		_at(14.5, () -> _play(_exetior, 168, 63, [4, 3, 2, 6], 10));
		_at(16.667, () -> _play(_exetior, 168, 63, _range(7, 10), 10));
		_at(23.5, () -> {
			_hide(_eggman);
			_hide(_exetior);
		});
		_at(46.042, () -> {
			_show(_eggman, 167, 141, 0);
			_show(_exetior, 168, 63, 10);
		});
		_at(49.0, () -> _play(_exetior, 168, 63, [9, 8, 7, 6], 10));
		_at(50.0, () -> _play(_eggman, 167, 141, _range(1, 5), 10));
		_at(56.708, () -> _play(_exetior, 168, 63, _range(2, 5), 10));
		_at(59.5, () -> {
			_play(_eggman, 167, 141, _range(6, 23), 20);
			_play(_exetior, 168, 63, _range(77, 94), 20);
		});
		_at(60.375, () -> {
			_hide(_eggman);
			_hide(_exetior);
		});
		_at(60.458, () -> {
			_play(_flashExetior, 168, 63, [97, 98], 20);
			_play(_flashExetiorFlip, 130, 63, [97, 98], 20);
		});
		_at(60.583, () -> {
			_hide(_flashExetior);
			_hide(_flashExetiorFlip);
		});

		_at(67.708, () -> {
			_show(_box, 263, 173, 0);
			_show(_jina, 233, 128, 14);
		});
		_at(70.833, () -> _play(_jina, 233, 128, _range(15, 26), 10));
		_at(72.958, () -> _play(_jina, 233, 128, _range(27, 29), 10));
		_at(75.167, () -> _play(_jina, 233, 128, [30, 31], 8));
		_at(76.333, () -> _play(_jina, 233, 128, [32, 33], 10));
		_at(80.625, () -> _loop(_tails, 476, 71, _range(0, 5), 10));
		_at(84.375, () -> {
			_hide(_tails);
			_show(_knuckles, 28, 75, 0);
		});
		_at(88.375, () -> {
			_hide(_knuckles);
			_show(_jina, 240, 130, 40);
		});
		_at(88.875, () -> _play(_jina, 240, 130, _range(39, 44), 12));
		_at(90.208, () -> _play(_jina, 240, 130, [45, 46], 8));
		_at(91.875, () -> _play(_jina, 240, 130, _range(47, 49), 10));
		_at(96.208, () -> _play(_jina, 240, 130, [50, 51], 8));
		_at(96.708, () -> _play(_jina, 229, 129, _range(54, 56), 5));
		_at(99.792, () -> {
			_show(_eggman, 65, 141, 5);
			_show(_exetior, 33, 63, 15);
		});
		_at(100.833, () -> _play(_exetior, 33, 63, [16, 19], 8));
		_at(107.25, () -> {
			_show(_jina, 230, 110, 0);
			_jump(_jina, 188, 154, 0.5, 14);
		});
		_at(108.0, () -> {
			_show(_jina, 187, 142, 57);
			_crouch(_jina, 0.15, 1.54, 0.35);
		});
		_at(108.625, () -> _show(_exetior, 33, 63, 15));
		_at(112.917, () -> _hide(_jina));
		_at(122.917, () -> {
			_show(_jina, 187, 142, 57);
			_show(_eggman, 127, 141, 5);
		});
		_at(123.75, () -> {
			_loop(_eggman, 127, 141, [29, 30, 31, 32, 33, 34, 35, 36, 28], 10);
			_slide(_eggman, 212, 141, 1.7);
		});
		_at(123.875, () -> _play(_jina, 187, 142, [58, 59], 20));
		_at(124.917, () -> _play(_jina, 187, 142, _range(61, 65), 16));
		_at(125.5, () -> _show(_eggman, 212, 141, 5));
		_at(131.583, () -> _play(_jina, 187, 142, _range(66, 70), 20));
		_at(132.542, () -> _play(_exetior, 33, 63, [16, 19], 8));
		_at(133.375, () -> _play(_jina, 202, 147, _range(71, 78), 10));
		_at(134.175, () -> _play(_jina, 202, 147, _range(71, 78), 10));
		_at(138.875, () -> {
			_play(_jina, 191, 145, _range(79, 86), 12);
			_show(_flashEggman, 265, 99, 26);
		});
		_at(139.0, () -> {
			_hide(_flashEggman);
			_play(_flashExetior, 196, 21, _range(94, 98), 20);
		});
		_at(139.125, () -> {
			_show(_bf, 270, 106, 0);
			_slide(_bf, 316, 177, 0.417);
		});
		_at(139.25, () -> _show(_eggman, 212, 141, 6));
		_at(139.292, () -> _hide(_flashExetior));
		_at(139.583, () -> {
			_show(_bf, 323, 179, 1);
			_slide(_bf, 331, 178, 0.292);
		});
		_at(139.75, () -> _show(_eggman, 212, 141, 5));
		_at(142.875, () -> _play(_jina, 191, 145, _range(87, 90), 12));
		_at(143.167, () -> _show(_jina, 189, 145, 4));
		_at(143.333, () -> _loop(_eggman, 212, 141, [6, 5], 5));
		_at(144.0, () -> _show(_exetior, 49, 63, 15));
		_at(144.833, () -> _show(_eggman, 212, 141, 6));
		_at(146.083, () -> _play(_exetior, 49, 63, [11, 12, 14], 8));

		_line(6.875, 9.75, 'Exetior', 'exetior_serio1', 'sharpy.line.01', "Why did you call me here Ivo?");
		_line(10.542, 14.375, 'Eggman', 'eggman', 'sharpy.line.02', "Sorry for disturbing your plans Exetior. But this may need your attention.");
		_line(17.583, 20.458, 'Exetior', 'exetior_confuso', 'sharpy.line.03', "What's that?");
		_line(21.042, 28.875, 'Eggman', 'eggman', 'sharpy.line.04', "According to my machine, someone is trying to... invade this domain from an unknown place!");
		_line(29.375, 37.208, 'Eggman', 'eggman', 'sharpy.line.05', "Big rings have been sending objects to this place for a while and the last report was 10 minutes ago.");
		_line(37.417, 45.25, 'Eggman', 'eggman', 'sharpy.line.06', "Now, the energy lectures are on another level... this time maybe something else will come out of this.");
		_line(49.125, 56.417, 'Exetior', 'exetior_serio2', 'sharpy.line.07', "Hmm... I didn't think there would be someone so cocky that would try to enter here without my permission.");
		_line(56.75, 62.542, 'Exetior', 'exetior_serio1', 'sharpy.line.08', "Come with me Ivo, I need you to figure out what exactly is happening.");
		_line(76.333, 80.5, 'Jina', 'jina_Normal1', 'sharpy.line.09', "Oh C'mon guys, sing with me! It will be fun!");
		_line(80.958, 84.375, 'DemonTails', 'tails_normal', 'sharpy.line.10', "I'll pass.");
		_line(84.542, 87.958, 'DemonKnuckles', 'knuckles_normal', 'sharpy.line.11', "Not a chance.");
		_line(90.042, 93.542, 'Jina', 'jina_molesta', 'sharpy.line.12', "URGH! You guys are reaaaally boring!");
		_line(93.958, 97.75, 'Jina', 'jina_Normal2', 'sharpy.line.13', "Perhaps Exetior will have some-");
		_line(99.792, 103.583, 'Jina', 'jina_enamorada', 'sharpy.line.14', "Exetior!");
		_line(107.292, 111.083, 'Jina', 'jina_Normal1', 'sharpy.line.15', "You arrived at the right time! Look what just appeared here!");
		_line(113.667, 117.458, 'Exetior', 'exetior_confuso', 'sharpy.line.16', "A speaker?");
		_line(117.792, 122.75, 'Jina', 'jina_Normal2', 'sharpy.line.17', "It just came out from a big ring some minutes ago.");
		_line(124.458, 130.583, 'Eggman', 'eggman', 'sharpy.line.18', "Looks like there is some sort of energy attached on this box... maybe I can track where it comes from...");
		_line(130.708, 131.75, 'Exetior', 'exetior_serio2', 'sharpy.line.19', "Hmm...");
		_line(132.292, 138.792, 'Jina', 'jina_enamorada', 'sharpy.line.20', "H-Hey, should we test it? You know... singing and stuff. Just you and me-");
		_line(146.167, 149.083, 'Exetior', 'exetior_confuso', 'sharpy.line.21', "What?");

		_events.sort((a, b) -> Reflect.compare(a.t, b.t));
		_canSkip = FlxG.save.data.sharpyCutsceneSeen == true;
		_music = FlxG.sound.play(Assets.getSound('assets/exe/access/sharpy/cutscene.ogg'), 1);
		_apply();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (_finished) return;
		_time = _music != null && _music.playing ? _music.time / 1000 : _time + elapsed;
		if (_canSkip && _time > 0.5 && (controls.ACCEPT || controls.BACK)) _time = 149.6;
		_apply();
		if (_time >= 149.6) _finish();
	}

	function _apply():Void
	{
		final t = _time;
		while (_next < _events.length && _events[_next].t <= t)
		{
			_eventTime = _events[_next].t;
			_events[_next++].run();
		}

		final scene = t < 23.5 ? 0 : t < 46.042 ? 1 : t < 67 ? 0 : 2;
		final noise = Std.int(Math.floor((t - 0.092) * 20)) % 3;
		_bg1.visible = scene == 0;
		_bgZoom.visible = scene == 1;
		_bg2.visible = _floor.visible = scene == 2;
		_bg1.animation.frameIndex = _bgZoom.animation.frameIndex = noise < 0 ? noise + 3 : noise;

		for (a in _actors) a.update(t);

		var x = _keys[0].x, y = _keys[0].y, zoom = _keys[0].zoom, angle = _keys[0].angle;
		for (k in _keys)
		{
			if (t < k.from) break;
			final p = k.to > k.from ? Math.min(1, (t - k.from) / (k.to - k.from)) : 1;
			final e = k.ease(p);
			if (k.pivotX != null)
			{
				final z = zoom + (k.zoom - zoom) * e;
				x = k.pivotX + (x - k.pivotX) * zoom / z;
				y = k.pivotY + (y - k.pivotY) * zoom / z;
				zoom = z;
			}
			else
			{
				x += (k.x - x) * e;
				y += (k.y - y) * e;
				zoom += (k.zoom - zoom) * e;
				angle += (k.angle - angle) * e;
			}
			if (p < 1) break;
		}

		for (s in _shakes)
		{
			final step = Std.int((t - s.t) * 24);
			if (step >= 0 && step < s.dy.length) y += s.dy[step];
		}

		final scale = 1280 / 235;
		if (Math.abs(zoom - 1) < 0.0001 && Math.abs(angle) < 0.001)
		{
			final halfW = _cam.width / scale * 0.5;
			final halfH = _cam.height / scale * 0.5;
			x = Math.round(x - halfW) + halfW;
			y = Math.round(y - halfH) + halfH;
		}
		_cam.zoom = scale * zoom;
		_cam.angle = angle;
		_cam.scroll.set(x - _cam.width * 0.5, y - _cam.height * 0.5);

		var black = 1.0;
		for (f in _fades)
		{
			if (t < f.t) break;
			black = f.length > 0 ? f.from + (f.to - f.from) * Math.min(1, (t - f.t) / f.length) : f.to;
		}
		_black.alpha = black;

		var line = null;
		for (l in _lines) if (t >= l.from && t < l.to) line = l;
		_dialogBox.visible = _dialogFace.visible = _dialogText.visible = line != null;
		if (line != null)
		{
			if (line != _shownLine)
			{
				_shownLine = line;
				_dialogBox.loadGraphic(Paths.getBitmapData('assets/exe/access/sharpy/box/TextBox${line.box}.png'));
				final s = 4;
				_dialogBox.scale.set(s, s);
				_dialogBox.updateHitbox();
				_dialogBox.y = line.place == 'down' ? FlxG.height - 54 * s - 8 : 8;
				_dialogText.y = _dialogBox.y + 5 * s + 8;
				_dialogFace.loadGraphic(Paths.getBitmapData('assets/exe/access/sharpy/box/faces/${line.face}.png'));
				final fit = Math.min(51 * s / _dialogFace.frameWidth, 45 * s / _dialogFace.frameHeight);
				_dialogFace.scale.set(fit, fit);
				_dialogFace.updateHitbox();
				_dialogFace.setPosition(_dialogBox.x + 5 * s + (51 * s - _dialogFace.width) * 0.5, _dialogBox.y + 5 * s + (45 * s - _dialogFace.height) * 0.5);
			}
			final duration = line.to - line.from;
			final revealRate = Math.max(45, line.text.length / (duration * 0.95));
			final shown = line.text.substr(0, Std.int(Math.min(line.text.length, (t - line.from) * revealRate)));
			if (_dialogText.text != shown) _dialogText.text = shown;
		}

		_white.visible = false;
		for (f in _flashes) if (t >= f.t && t < f.t + f.length) _white.visible = true;
	}

	function _finish():Void
	{
		_finished = true;
		_music?.stop();
		FlxG.save.data.sharpyCutsceneSeen = true;
		FlxG.save.flush();
		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function _line(from:Float, to:Float, box:String, face:String, key:String, fallback:String, place:String = 'above'):Void
	{
		final text = Language.getPhrase(key, fallback);
		_lines.push({ from: from, to: to, box: box, face: face, text: text, place: place });
	}

	function _at(t:Float, run:Void->Void):Void
	{
		_events.push({ t: t, run: run });
	}

	function _show(a:SharpyActor, x:Float, y:Float, frame:Int):Void
	{
		_play(a, x, y, [frame], 1);
	}

	function _play(a:SharpyActor, x:Float, y:Float, frames:Array<Int>, fps:Float):Void
	{
		a.frames = frames;
		a.fps = fps;
		a.start = _eventTime;
		a.loop = false;
		a.fromX = a.toX = x;
		a.fromY = a.toY = y;
		a.moveLength = a.height = a.crouchAmount = 0;
		a.spr.visible = true;
	}

	function _crouch(a:SharpyActor, amount:Float, hold:Float, rise:Float):Void
	{
		a.crouchAmount = amount;
		a.crouchStart = _eventTime;
		a.crouchHold = hold;
		a.crouchRise = rise;
	}

	function _loop(a:SharpyActor, x:Float, y:Float, frames:Array<Int>, fps:Float):Void
	{
		_play(a, x, y, frames, fps);
		a.loop = true;
	}

	function _slide(a:SharpyActor, x:Float, y:Float, length:Float):Void
	{
		_jump(a, x, y, length, 0);
	}

	function _jump(a:SharpyActor, x:Float, y:Float, length:Float, height:Float):Void
	{
		a.fromX = a.toX;
		a.fromY = a.toY;
		a.toX = x;
		a.toY = y;
		a.moveStart = _eventTime;
		a.moveLength = length;
		a.height = height;
	}

	function _hide(a:SharpyActor):Void
	{
		a.spr.visible = false;
	}

	function _range(first:Int, last:Int):Array<Int>
	{
		return [for (i in first...last + 1) i];
	}

	function _sprite(name:String):FlxSprite
	{
		final spr = new FlxSprite();
		spr.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/access/sharpy/$name.webp'), 'assets/exe/access/sharpy/$name.xml');
		spr.antialiasing = false;
		spr.cameras = [_cam];
		add(spr);
		return spr;
	}

	function _actor(name:String):SharpyActor
	{
		final a = new SharpyActor(_sprite(name));
		_actors.push(a);
		return a;
	}

	function _camCut(t:Float, x:Float, y:Float, zoom:Float, angle:Float):Void
	{
		_keys.push({ from: t, to: t, x: x, y: y, zoom: zoom, angle: angle, ease: FlxEase.linear });
	}

	function _camMove(from:Float, to:Float, x:Float, y:Float, zoom:Float, angle:Float, ease:EaseFunction):Void
	{
		_keys.push({ from: from, to: to, x: x, y: y, zoom: zoom, angle: angle, ease: ease });
	}

	function _camZoomAround(from:Float, to:Float, zoom:Float, pivotX:Float, pivotY:Float, ease:EaseFunction):Void
	{
		_keys.push({ from: from, to: to, x: 0, y: 0, zoom: zoom, angle: 0, ease: ease, pivotX: pivotX, pivotY: pivotY });
	}

	function _fade(t:Float, length:Float, from:Float, to:Float):Void
	{
		_fades.push({ t: t, length: length, from: from, to: to });
	}

	function _flash(t:Float, frames:Int):Void
	{
		_flashes.push({ t: t, length: frames / 24 });
	}

	function _shake(t:Float, dy:Array<Int>):Void
	{
		_shakes.push({ t: t, dy: dy });
	}
}
