package states;

import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.FlxBasic;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.utils.Assets as AssetPaths;

typedef RollItem = { spr:FlxSprite, mid:Float, alpha:Float }
typedef RollCard = { parts:Array<FlxSprite>, alphas:Array<Float>, vid:VideoSprite, cx:Float, top:Float, h:Float, angle:Float, age:Float, ready:Bool, pin:Bool, vel:Float }
typedef RollEmber = { spr:FlxSprite, vy:Float, phase:Float, sway:Float, base:Float }

class CreditsRollState extends MusicBeatState
{
	var credits:String = 'Not Found';
	var canLeave:Bool = false;

	var ring:FlxSprite;
	var bandana:FlxSprite;
	var logotxt:FlxSprite;
	var eyes:FlxSprite;
	var savedRingY:Float = 0;

	var _rolling:Array<RollItem> = [];
	var _cards:Array<RollCard> = [];
	var _embers:Array<RollEmber> = [];
	var _mediaLayer:FlxTypedGroup<FlxBasic>;
	var _glow:FlxSprite;
	var _speedTxt:FlxText;
	var _hintTxt:FlxText;
	var _pulse:Float = 0;
	var _section:Int = 0;
	var _bar:Int = 0;
	final _tempo:Array<{start:Float, bpm:Float, bars:Int}> = [
		{start: 1.65,   bpm: 89,  bars: 27},
		{start: 74.07,  bpm: 134, bars: 15},
		{start: 102.33, bpm: 89,  bars: 1},
		{start: 105.65, bpm: 110, bars: 19},
		{start: 147.33, bpm: 134, bars: 16},
		{start: 176.19, bpm: 120, bars: 6}
	];
	var _intro:Float = 0;
	var _hintTime:Float = 0;
	var _cardCount:Int = 0;
	var _vig:FlxSprite;
	var _songTime:Float = 0;
	var _songDone:Bool = false;
	var _leaving:Bool = false;
	var _finished:Bool = false;
	var _scrolled:Float = 0;
	var _v:Float = 106;
	var _ramp:Float = 1.5;
	var _tA:Float = 2.8;
	var _tP:Float = 0;
	var _tQ:Float = 0;
	var _tE:Float = 0;
	var _dLetter:Float = 0;
	var _dEnd:Float = 0;
	var _pauseLen:Float = 0;
	var _reading:Float = 0;
	var _finalAt:Float = -1;
	var _finalShown:Bool = false;

	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;
		super.create();

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000));
		_glow = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0x00000000, 0x33400008, 0xAA7A0A12], 1, 90);
		_glow.alpha = 0.55;
		add(_glow);

		for (i in 0...46)
		{
			final big = FlxG.random.bool(30);
			final e = new FlxSprite().makeGraphic(big ? 3 : 2, big ? 3 : 2, FlxG.random.bool(70) ? 0xFFFF5530 : 0xFFFFB070);
			e.blend = BlendMode.ADD;
			e.active = false;
			e.setPosition(FlxG.random.float(0, FlxG.width), FlxG.random.float(0, FlxG.height));
			add(e);
			_embers.push({ spr: e, vy: FlxG.random.float(big ? 30 : 12, big ? 60 : 30), phase: FlxG.random.float(0, Math.PI * 2), sway: FlxG.random.float(6, 22), base: e.x });
		}

		final path:String = 'assets/exe/title/logo/';
		ring = new FlxSprite().loadGraphic(Paths.getBitmapData(path + 'ring.webp'));
		ring.scale.set(0.3, 0.3);
		ring.updateHitbox();
		ring.screenCenter();
		ring.y -= 30;
		add(ring);

		savedRingY = ring.y;
		bandana = new FlxSprite(ring.x + (329 * 0.3)).loadGraphic(Paths.getBitmapData(path + 'bandana.webp'));
		bandana.scale.set(0.3, 0.3);
		bandana.updateHitbox();
		add(bandana);

		logotxt = new FlxSprite(ring.x + (711 * 0.3)).loadGraphic(Paths.getBitmapData(path + 'sonic.webp'));
		logotxt.scale.set(0.3, 0.3);
		logotxt.updateHitbox();
		add(logotxt);

		eyes = new FlxSprite(ring.x + (1074 * 0.3)).loadGraphic(Paths.getBitmapData(path + 'eyes.webp'));
		eyes.scale.set(0.3, 0.3);
		eyes.updateHitbox();
		add(eyes);

		ring.alpha = bandana.alpha = logotxt.alpha = eyes.alpha = 0;

		_mediaLayer = new FlxTypedGroup<FlxBasic>();
		add(_mediaLayer);

		credits = AssetPaths.getText("assets/exe/credits.txt");

		final colW:Int = Std.int(FlxG.width * 0.6);
		final lines = credits.split('\n');
		final playerName = _playerName();
		var letterTop:Float = -1;
		var letterBottom:Float = -1;
		var letterChars:Int = 0;
		var lastMid:Float = 0;
		var y:Float = FlxG.height / 2;
		for (idx in 0...lines.length)
		{
			final line = lines[idx];
			if (line.trim() == '') { y += 30; continue; }
			var text = line;
			var size = 22;
			var kind = _isLetter(line) ? 3 : 0;
			if (line.startsWith('=='))
			{
				text = line.substr(2);
				size = 36;
				kind = 2;
			}
			else if (line.startsWith('='))
			{
				text = line.substr(1);
				size = 28;
				kind = 1;
			}

			text = StringTools.replace(text, "{user}", playerName);

			var wide = kind >= 2;
			var letter = kind == 3;
			if (kind == 1)
			{
				var next = idx + 1;
				while (next < lines.length && lines[next].trim() == '') next++;
				if (next < lines.length && _isLetter(lines[next]))
				{
					letter = true;
					letterTop = y;
				}
			}
			final boxX:Float = letter ? FlxG.width * 0.125 : (wide ? 0 : 15);
			final boxW:Int = letter ? Std.int(FlxG.width * 0.75) : (wide ? FlxG.width : colW);
			var creditsTxt:FlxText = new FlxText(boxX, y, boxW, text);
			creditsTxt.setFormat(Paths.font("sonic4.ttf"), size, kind == 1 ? 0xFFE8454A : (kind == 2 ? 0xFFFFFFFF : (kind == 3 ? 0xFFF2E8DC : 0xFFE4E4E4)), letter ? "left" : "center");
			creditsTxt.antialiasing = ClientPrefs.data.antialiasing;
			creditsTxt.active = false;
			final advance = creditsTxt.height + 4;
			final metrics = creditsTxt.textField.getLineMetrics(0);

			switch (kind)
			{
				case 2:
					creditsTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF7A0A12, 3);
				case 1:
					creditsTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 2);
					final bar = new FlxSprite().makeGraphic(1, 1, 0xFFE8454A);
					bar.setGraphicSize(Std.int(Math.min(metrics.width + 70, boxW * 0.8)), 2);
					bar.updateHitbox();
					bar.setPosition(letter ? boxX : boxX + (boxW - bar.width) / 2, y + metrics.height + 6);
					bar.active = false;
					add(bar);
					_rolling.push({ spr: bar, mid: 0, alpha: 0.55 });
				default:
					creditsTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1.5);
			}

			add(creditsTxt);
			_rolling.push({ spr: creditsTxt, mid: metrics.height * 0.5, alpha: 1 });
			lastTxt = creditsTxt;
			lastMid = metrics.height * 0.5;
			if (kind == 3)
			{
				letterBottom = y + advance;
				letterChars += text.length;
				y += 10;
			}
			y += advance;
		}

		_dEnd = lastTxt.y + lastMid - FlxG.height / 2;
		if (letterTop >= 0 && letterBottom > letterTop)
		{
			final h = letterBottom - letterTop;
			_dLetter = Math.max(0, h < FlxG.height * 0.84 ? letterTop + h * 0.5 - FlxG.height / 2 : letterTop - FlxG.height * 0.08);
			_pauseLen = FlxMath.bound(letterChars / 30, 8, 30);
		}

		_vig = new FlxSprite().loadGraphic(_vignette());
		_vig.setGraphicSize(FlxG.width, FlxG.height);
		_vig.updateHitbox();
		_vig.antialiasing = true;
		_vig.active = false;
		add(_vig);

		_speedTxt = new FlxText(0, FlxG.height - 46, FlxG.width - 24, '');
		_speedTxt.setFormat(Paths.font("sonic4.ttf"), 20, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		_speedTxt.antialiasing = ClientPrefs.data.antialiasing;
		_speedTxt.alpha = 0;
		add(_speedTxt);

		_hintTxt = new FlxText(24, FlxG.height - 46, 0, #if mobile 'TAP TO LEAVE' #else 'PRESS ENTER TO LEAVE' #end);
		_hintTxt.setFormat(Paths.font("sonic4.ttf"), 18, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);
		_hintTxt.antialiasing = ClientPrefs.data.antialiasing;
		_hintTxt.alpha = 0;
		add(_hintTxt);

		Conductor.bpmChangeMap = [];
		Conductor.bpm = 89;
		Conductor.songPosition = 0;

		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/creditsroll.ogg'), 1, false);
		FlxG.sound.music.pause();
		FlxG.sound.music.onComplete = () -> {
			_songDone = true;
			_exitRoll(3);
		};

		final songLen:Float = FlxG.sound.music.length > 0 ? FlxG.sound.music.length / 1000 : 192;
		_tE = songLen - 8;
		_v = _dEnd / Math.max(10, _tE - _tA - _pauseLen - (_pauseLen > 0 ? 2 : 1) * _ramp);
		if (_pauseLen > 0)
		{
			_tP = _tA + _ramp + _dLetter / _v;
			_tQ = _tP + _pauseLen;
			_finalAt = _tQ;
		}
		else _finalAt = Math.max(_tA, _tE - 10);

		new FlxTimer().start(0.1, _ -> {
			FlxG.sound.music.resume();
			Conductor.bpm = 89;
		});
		if (backend.EXEAchievements.isUnlocked('credits')) canLeave = true;

		FlxG.camera.fade(0xFF000000, 1.6, true);
	}

	public var speed(default, set):Float = 1;
	var activateOnce:Bool = true;
	var lastTxt:FlxText;

	function set_speed(value:Float):Float
	{
		FlxG.sound.music.pitch = value;
		speed = value;
		return value;
	}

	var logoSine:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		final target:Float = (FlxG.keys.pressed.SHIFT #if mobile || pressHolding #end) ? 3 : (FlxG.keys.pressed.CONTROL ? 0.4 : 1);
		if (speed != target) speed = Math.abs(target - speed) < 0.01 ? target : FlxMath.lerp(speed, target, 1 - Math.exp(-elapsed * 6));

		if (((controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end) || (controls.BACK #if mobile || backPressed #end)) && canLeave)
			_exitRoll(5);

		final music = FlxG.sound.music;
		if (music != null && music.playing)
		{
			_songTime += elapsed * 1000 * speed;
			if (Math.abs(music.time - _songTime) > 60) _songTime = music.time;
		}
		else if (_songDone) _songTime += elapsed * 1000 * speed;
		Conductor.songPosition = _songTime;

		final t = _songTime / 1000;
		while (_section < _tempo.length && t >= _tempo[_section].start + _bar * 240 / _tempo[_section].bpm)
		{
			_pulse = 1;
			if (++_bar >= _tempo[_section].bars)
			{
				_bar = 0;
				_section++;
			}
		}
		final offset = _finished ? _dEnd : Math.max(_scrolled, _offsetAt(t));
		final amount = offset - _scrolled;
		_scrolled = offset;

		if (!_finished && t >= _tE)
		{
			_finished = true;
			if (activateOnce) {
				activateOnce = false;
				FlxTween.tween(lastTxt.scale, {x: 1.15, y: 1.15}, 8, {ease: FlxEase.sineOut});
			}
		}

		if (!_finalShown && _finalAt >= 0 && t >= _finalAt)
		{
			_finalShown = true;
			addImage('assets/exe/creditsroll/everyone.webp', 2.1, true);
		}

		_reading = FlxMath.lerp(_reading, _pauseLen > 0 && t >= _tP - _ramp && t < _tQ ? 1 : 0, 1 - Math.exp(-elapsed * 3));
		_vig.alpha = 1 - 0.55 * _reading;

		for (item in _rolling)
		{
			item.spr.y -= amount;
			item.spr.alpha = item.alpha * _edgeFade(item.spr.y + item.mid);
		}

		var i = _cards.length;
		while (i-- > 0)
		{
			final c = _cards[i];
			var mv = amount * 0.75;
			if (c.pin && c.ready)
			{
				final dist = Math.max(0, c.top - (FlxG.height - c.h) / 2);
				c.vel = FlxMath.lerp(c.vel, Math.min(_v * speed, dist * 2), 1 - Math.exp(-elapsed * 4));
				mv = Math.min(dist, c.vel * elapsed);
			}
			c.top -= mv;
			for (p in c.parts) p.y -= mv;
			if (!c.ready)
			{
				if (c.top < -FlxG.height) _killCard(c);
				continue;
			}

			c.age += elapsed;
			final settle = FlxEase.quartOut(Math.min(1, c.age / 1.1));
			final a = Math.min(1, settle * 1.4) * FlxMath.bound((c.top + c.h) / (FlxG.height * 0.22), 0, 1);
			final ang = c.angle + (1 - settle) * (c.angle >= 0 ? 6 : -6);
			for (j in 0...c.parts.length)
			{
				c.parts[j].alpha = a * c.alphas[j];
				c.parts[j].angle = ang;
			}
			if (c.top + c.h < -80) _killCard(c);
		}

		_pulse = Math.max(0, _pulse - elapsed * 1.6);
		_glow.alpha = 0.55 + _pulse * 0.25;

		for (e in _embers)
		{
			e.phase += elapsed;
			e.spr.y -= e.vy * elapsed * speed + amount * 0.3;
			e.spr.x = e.base + Math.sin(e.phase * 0.9) * e.sway;
			e.spr.alpha = 0.35 + 0.3 * Math.sin(e.phase * 2.3);
			if (e.spr.y < -10)
			{
				e.spr.y = FlxG.height + FlxG.random.float(5, 60);
				e.base = FlxG.random.float(0, FlxG.width);
			}
		}

		_intro = Math.min(1, _intro + elapsed / 2.2);
		savedRingY -= amount;
		logoSine += elapsed;
		final logoAlpha = FlxEase.sineInOut(_intro) * FlxMath.bound((savedRingY + ring.height * 0.5) / (FlxG.height * 0.3), 0, 1);
		ring.y = savedRingY + Math.sin(logoSine) * 5 + (1 - FlxEase.quartOut(_intro)) * 24;
		bandana.y = ring.y + (873 * 0.3) + Math.sin(logoSine - 0.02) * 4;
		logotxt.y = ring.y + (777 * 0.3) + Math.sin(logoSine - 0.025) * 4;
		eyes.y = ring.y + (517 * 0.3) + Math.sin(logoSine - 0.5) * 2.5;
		ring.alpha = bandana.alpha = logotxt.alpha = eyes.alpha = logoAlpha;

		final showSpeed = target != 1;
		if (showSpeed) _speedTxt.text = target > 1 ? '>> x3' : '<< x0.4';
		_speedTxt.alpha = FlxMath.lerp(_speedTxt.alpha, showSpeed ? 0.85 : 0, 1 - Math.exp(-elapsed * 10));

		_hintTime += elapsed;
		_hintTxt.alpha = canLeave ? 0.55 * FlxMath.bound(Math.min(_hintTime - 1.5, (7.5 - _hintTime) / 1.5), 0, 1) : 0;
	}

	function _edgeFade(cy:Float):Float
	{
		final k = 1 - 0.8 * _reading;
		return FlxMath.bound(Math.min((cy - FlxG.height * 0.03 * k) / (FlxG.height * 0.17 * k), (FlxG.height * (1 - 0.01 * k) - cy) / (FlxG.height * 0.12 * k)), 0, 1);
	}

	function _playerName():String
	{
		#if DISCORD_ALLOWED
		if (DiscordClient.username != null && DiscordClient.username.trim() != '') return DiscordClient.username;
		#end
		#if sys
		final sysName = Sys.getEnv(#if windows "USERNAME" #else "USER" #end);
		if (sysName != null && sysName.trim() != '') return sysName;
		#end
		return 'boyfriend';
	}

	inline function _isLetter(s:String):Bool
		return !s.startsWith('=') && s.trim().length > 75;

	function _seg(t:Float, start:Float, end:Float):Float
	{
		if (t <= start) return 0;
		final total = _v * (end - start - _ramp);
		if (t >= end) return total;
		final u = t - start;
		final w = end - t;
		if (u < _ramp && u <= w) return _v * u * u / (2 * _ramp);
		if (w < _ramp) return total - _v * w * w / (2 * _ramp);
		return _v * (u - _ramp * 0.5);
	}

	function _offsetAt(t:Float):Float
	{
		if (_pauseLen > 0) return _seg(t, _tA, _tP) + _seg(t, _tQ, _tE);
		return _seg(t, _tA, _tE);
	}

	function _exitRoll(fade:Float):Void
	{
		if (_leaving) return;
		_leaving = true;
		canLeave = false;
		FlxG.camera.fade(0xFF000000, fade, false, () -> { FlxG.switchState(() -> new states.EXEMenu()); }, true);
		FlxG.sound.music?.fadeOut(fade);
	}

	override function beatHit():Void
	{
		super.beatHit();
		switch(curBeat)
		{
			case 4: playVideo('assets/videos/introcutscene.mp4');
			case 12: playVideo('assets/videos/postIntro.mp4');
			case 20: playVideo('contents/STORY MODE/videos/tooslow.mp4');
            case 28: playVideo('contents/STORY MODE/videos/YRC.mp4');
            case 36: playVideo('contents/STORY MODE/videos/tripletrouble.mp4');
            case 44: playVideo('contents/STORY MODE/videos/fake intro.mp4');
            case 52: playVideo('contents/STORY MODE/videos/EYE_TO_EYE intro.mp4');
            case 60: addImage('assets/exe/creditsroll/ts.webp');
            case 64: addImage('assets/exe/creditsroll/ycr.webp');
            case 68: addImage('assets/exe/creditsroll/tt.webp');
            case 72: addImage('contents/STORY MODE/images/final/finale.webp');
            case 76: addImage('assets/exe/creditsroll/y.webp');
            case 80: addImage('assets/exe/creditsroll/1.webp');
            case 84: addImage('assets/exe/creditsroll/2.webp');
            case 88: addImage('assets/exe/creditsroll/16.webp');
            case 92: addImage('assets/exe/creditsroll/3.webp');
            case 96: addImage('assets/exe/creditsroll/4.webp');
            case 100: addImage('assets/exe/creditsroll/5.webp');
            case 104: addImage('assets/exe/creditsroll/18.webp');
            case 108: addImage('assets/exe/creditsroll/6.webp');
            case 112: addImage('assets/exe/creditsroll/19.webp');
            case 116: addImage('assets/exe/creditsroll/7.webp');
            case 120: addImage('assets/exe/creditsroll/8.webp');
            case 124: addImage('assets/exe/creditsroll/20.webp');
            case 128: addImage('assets/exe/creditsroll/21.webp');
            case 132: addImage('assets/exe/creditsroll/9.webp');
            case 136: addImage('assets/exe/creditsroll/10.webp');
            case 140: addImage('assets/exe/creditsroll/22.webp');
            case 144: addImage('assets/exe/creditsroll/32.webp');
            case 148: addImage('assets/exe/creditsroll/11.webp');
            case 152: addImage('assets/exe/creditsroll/12.webp');
            case 156: addImage('assets/exe/creditsroll/13.webp');
            case 160: addImage('assets/exe/creditsroll/23.webp');
            case 164: addImage('assets/exe/creditsroll/14.webp');
            case 168: addImage('contents/REQUITAL/images/finale.webp');
            case 172: addImage('assets/exe/creditsroll/24.webp');
            case 176: addImage('assets/exe/creditsroll/25.webp');
            case 180: addImage('assets/exe/creditsroll/26.webp'); //needs new screenshot
            case 184: addImage('assets/exe/creditsroll/27.webp');
            case 188: addImage('assets/exe/creditsroll/17.webp');
            case 192: addImage('assets/exe/creditsroll/28.webp');
            case 196: addImage('assets/exe/creditsroll/15.webp');
            case 200: addImage('assets/exe/creditsroll/29.webp');
            case 204: addImage('assets/exe/creditsroll/31.webp');
            case 208: addImage('assets/exe/creditsroll/30.webp');
		}
	}

	function playVideo(path:String)
	{
		final c = _newCard(false);
		final vid = new VideoSprite(0, 0, false);
		c.vid = vid;
		vid.loadVideo(path, [VideoSprite.ARG_MUTED, VideoSprite.ARG_LOOPING]);
		vid.video.alpha = 0;
		vid.onFormat(() -> {
			if (c.ready || !_cards.contains(c)) return;
			final fit:Float = Math.min((FlxG.width * 0.4) / vid.video.width, (FlxG.height * 0.4) / vid.video.height);
			vid.setGraphicSize(Std.int(vid.video.width * fit), Std.int(vid.video.height * fit));
			vid.video.antialiasing = ClientPrefs.data.antialiasing;
			_frameCard(c, vid.video);
		});
		vid.playDelayed();
		_mediaLayer.add(vid);
	}

	function addImage(path:String, ?scale:Float = 1, ?centered:Bool = false)
	{
		final c = _newCard(centered);
		final spr = new FlxSprite().loadGraphic(path);
		final fit:Float = Math.min((FlxG.width * 0.4) / spr.width, (FlxG.height * 0.4) / spr.height);
		spr.setGraphicSize(Std.int(spr.width * fit * scale), Std.int(spr.height * fit * scale));
		spr.updateHitbox();
		spr.antialiasing = ClientPrefs.data.antialiasing;
		spr.alpha = 0;
		spr.active = false;
		_mediaLayer.add(spr);
		_frameCard(c, spr);
	}

	function _newCard(centered:Bool):RollCard
	{
		final first = _cardCount == 0;
		final side = _cardCount++ % 2 == 0 ? -1 : 1;
		final shadow = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		final border = new FlxSprite().makeGraphic(1, 1, 0xFFEDE6DA);
		shadow.alpha = border.alpha = 0;
		shadow.active = border.active = false;
		_mediaLayer.add(shadow);
		_mediaLayer.add(border);

		final c:RollCard = {
			parts: [shadow, border],
			alphas: [0.45, 0.95],
			vid: null,
			cx: centered ? FlxG.width / 2 : FlxG.width * 0.73 + side * 34,
			top: FlxG.height + (first ? 300 : 50),
			h: 0,
			angle: centered ? 0 : side * FlxG.random.float(2, 4.5),
			age: 0,
			ready: false,
			pin: centered,
			vel: 0
		};
		_cards.push(c);
		return c;
	}

	function _frameCard(c:RollCard, media:FlxSprite):Void
	{
		final w = media.width;
		final h = media.height;
		final shadow = c.parts[0];
		final border = c.parts[1];
		shadow.setGraphicSize(Std.int(w + 10), Std.int(h + 10));
		shadow.updateHitbox();
		border.setGraphicSize(Std.int(w + 10), Std.int(h + 10));
		border.updateHitbox();

		c.h = h + 10;
		final cy = c.top + c.h * 0.5;
		shadow.setPosition(c.cx - shadow.width * 0.5 + 10, cy - shadow.height * 0.5 + 12);
		border.setPosition(c.cx - border.width * 0.5, cy - border.height * 0.5);
		media.setPosition(c.cx - w * 0.5, cy - h * 0.5);

		c.parts.push(media);
		c.alphas.push(1);
		c.age = 0;
		c.ready = true;
	}

	function _killCard(c:RollCard):Void
	{
		_cards.remove(c);
		for (j in 0...2)
		{
			_mediaLayer.remove(c.parts[j], true);
			c.parts[j].destroy();
		}
		if (c.vid != null)
		{
			c.vid.stop();
			_mediaLayer.remove(c.vid, true);
			c.vid.destroy();
		}
		else if (c.parts.length > 2)
		{
			_mediaLayer.remove(c.parts[2], true);
			c.parts[2].destroy();
		}
	}

	function _vignette():BitmapData
	{
		final w = 256;
		final h = 144;
		final bmd = new BitmapData(w, h, true, 0);
		for (py in 0...h)
			for (px in 0...w)
			{
				final nx = (px + 0.5) / w * 2 - 1;
				final ny = (py + 0.5) / h * 2 - 1;
				final t = FlxMath.bound((Math.sqrt(nx * nx + ny * ny) - 0.55) / 0.8, 0, 1);
				bmd.setPixel32(px, py, Std.int(t * t * (3 - 2 * t) * 235) << 24);
			}
		return bmd;
	}

	override function destroy()
	{
		if (FlxG.sound.music != null) FlxG.sound.music.onComplete = null;
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		super.destroy();
	}
}
