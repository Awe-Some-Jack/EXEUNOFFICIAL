package states.extras.dagarden;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
class DASub extends FlxGroup
{
	static inline final BOX_SCALE:Float = 0.34;
	static inline final BOX_X:Float = 565.0;
	static inline final BOX_Y:Float = 100.0;
	static inline final BOX_CONTENT_X:Float = 98.0;
	static inline final BOX_CONTENT_Y:Float = 1.0;
	static inline final BOX_CONTENT_W:Float = 1785.0;
	static inline final SUB_IMG_W:Float = 1833.0;
	static inline final SUB_IMG_H:Float = 247.0;
	static inline final SUB_OFFSET_Y:Float = -10.0;
	static inline final INNER_PAD:Float = 6.0;
	static inline final TEXT_OFFSET_Y:Float = -5.0;
	static inline final FONT:String = 'assets/fonts/vcr.ttf';
	static inline final FONT_SIZE:Int = 25;
	static inline final WORD_SPACING:Float = 4.0;
	static inline final LIFT_AMOUNT:Float = 4.0;
	static inline final BG_ALPHA:Float = 0.60;
	static inline final BG_PAD_X:Float = 10.0;
	static inline final BG_PAD_Y:Float = 4.0;
	static inline final SLIDE_LEAD_MS:Float = 1500.0;
	static inline final SLIDE_IN_TIME:Float = 0.45;
	static inline final SLIDE_OUT_TIME:Float = 0.35;
	static inline final HIDDEN_OFFSET:Float = -120.0;
	static inline final LINGER_MS:Float = 1500.0;

	public var sprite:FlxSprite;

	private var _subX:Float;
	private var _subY:Float;
	private var _subW:Float;
	private var _subH:Float;
	private var _innerX:Float;
	private var _innerY:Float;
	private var _innerW:Float;
	private var _innerH:Float;
	private var _bg:FlxSprite;
	private var _words:Array<FlxText> = [];
	private var _baseY:Float = 0.0;
	private var _events:Array<{time:Float, text:String, wordIndex:Int, color:FlxColor, mode:Int}> = [];
	private var _lastMs:Float = -1.0;
	private var _eventIndex:Int = 0;
	private var _currentWords:Array<String> = [];
	private var _activeWord:Int = -1;
	private var _firstEventTime:Float = -1.0;
	private var _lastEventTime:Float = -1.0;
	private var _lastActiveEventMs:Float = -1.0;
	private var _hasLyrics:Bool = false;
	private var _slideOffset:Float = HIDDEN_OFFSET;
	private var _slideTarget:Float = HIDDEN_OFFSET;
	private var _shouldShow:Bool = false;

	public function new()
	{
		super();

		final subScale = (BOX_CONTENT_W * BOX_SCALE) / SUB_IMG_W;
		_subW = SUB_IMG_W * subScale;
		_subH = SUB_IMG_H * subScale;
		_subX = BOX_X + BOX_CONTENT_X * BOX_SCALE;
		_subY = BOX_Y + BOX_CONTENT_Y * BOX_SCALE - _subH + SUB_OFFSET_Y;
		
		_innerX = _subX + INNER_PAD;
		_innerY = _subY + INNER_PAD;
		_innerW = _subW - INNER_PAD * 2;
		_innerH = _subH - INNER_PAD * 2;

		sprite = new FlxSprite(_subX, _subY + HIDDEN_OFFSET);
		sprite.loadGraphic(openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/subtitlebox.png"));
		sprite.scale.set(subScale, subScale);
		sprite.updateHitbox();
		add(sprite);

		_bg = new FlxSprite(0, 0);
		_bg.makeGraphic(1, 1, FlxColor.BLACK);
		_bg.alpha = 0;
		_bg.visible = false;
		add(_bg);
	}

	public function loadLyrics(song:String, mod:String):Void
	{
		_events = [];
		_hasLyrics = false;
		_firstEventTime = -1.0;
		_lastEventTime = -1.0;
		FlxTween.cancelTweensOf(this);
		_shouldShow = false;
		_lastActiveEventMs = -1.0;
		_slideOffset = HIDDEN_OFFSET;
		_slideTarget = HIDDEN_OFFSET;
		_applySlide();
		_clearWords();
	}

	public function applyLyricsEvents(evs:Array<Dynamic>, song:String, mod:String):Void
	{
		_events = [];
		_hasLyrics = false;
		_firstEventTime = -1.0;
		_lastEventTime = -1.0;

		if (evs == null) return;

		try
		{
			for (ev in evs)
			{
				final t:Float = cast ev[0];
				final evList:Array<Dynamic> = cast ev[1];
				if (evList == null) continue;
				for (e in evList)
				{
					final evName = Std.string(e[0]);
					if (evName == 'Normal Lyrics')
					{
						final text:String = Std.string(e[1]);
						final param:String = Std.string(e[2]);
						var wordIdx:Int = -1;
						var color = FlxColor.WHITE;
						if (param != '' && param != 'null')
						{
							final parts = param.split(',');
							wordIdx = Std.parseInt(parts[0]);
							if (parts.length > 1)
								color = FlxColor.fromString('#' + StringTools.trim(parts[1]));
						}
						_events.push({time: t, text: text, wordIndex: wordIdx, color: color, mode: 0});
					}
					else if (evName == 'Lyrics')
					{
						final text:String = Std.string(e[1]);
						final param:String = Std.string(e[2]);
						var color = FlxColor.WHITE;
						if (param != '' && param != 'null')
						{
							var hex = StringTools.trim(param);
							if (!hex.startsWith('#')) hex = '#' + hex;
							color = FlxColor.fromString(hex);
						}
						_events.push({time: t, text: text, wordIndex: -1, color: color, mode: 1});
					}
				}
			}
			_events.sort((a, b) -> a.time < b.time ? -1 : 1);
			if (_events.length > 0)
			{
				_hasLyrics = true;
				_firstEventTime = _events[0].time;
				_lastEventTime = _events[_events.length - 1].time;
			}
		}
		catch(_:Dynamic) {}
	}

	public function updateTime(ms:Float):Void
	{
		if (!_hasLyrics) return;

		final jumped = _lastMs >= 0 && ((ms < _lastMs - 50) || (ms > _lastMs + 300));
		_lastMs = ms;

		if (jumped) _rebuildFromTime(ms);
		else        _advanceEvents(ms);
		
		var wantShow = _lastActiveEventMs >= 0 && ms <= _lastActiveEventMs + LINGER_MS;
		if (!wantShow && ms >= _firstEventTime - SLIDE_LEAD_MS && ms < _firstEventTime)
			wantShow = true;

		if (wantShow != _shouldShow)
		{
			_shouldShow = wantShow;
			if (!wantShow) _clearWords();
			_slideTarget = wantShow ? 0.0 : HIDDEN_OFFSET;
			FlxTween.cancelTweensOf(this);
			
			if (wantShow)
				FlxTween.num(_slideOffset, 0.0, SLIDE_IN_TIME, {ease: FlxEase.elasticOut}, v -> { _slideOffset = v; _applySlide(); });
			else
				FlxTween.num(_slideOffset, HIDDEN_OFFSET, SLIDE_OUT_TIME, {ease: FlxEase.backIn}, v -> { _slideOffset = v; _applySlide(); });
		}
	}

	public function reset():Void
	{
		FlxTween.cancelTweensOf(this);
		_lastMs = -1.0;
		_eventIndex = 0;
		_shouldShow = false;
		_lastActiveEventMs = -1.0;
		_slideOffset = HIDDEN_OFFSET;
		_slideTarget = HIDDEN_OFFSET;
		_applySlide();
		_clearWords();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	override public function destroy():Void
	{
		FlxTween.cancelTweensOf(this);
		_clearWords();
		sprite = null;
		_bg = null;
		_events = null;
		super.destroy();
	}

	private function _rebuildFromTime(ms:Float):Void
	{
		_eventIndex = 0;
		while (_eventIndex < _events.length && _events[_eventIndex].time <= ms)
			_eventIndex++;

		if (_eventIndex == 0)
		{
			_clearWords();
			return;
		}

		final activeEv = _events[_eventIndex - 1];
		if (activeEv.text == '' || activeEv.text == 'null')
		{
			if (_lastActiveEventMs >= 0) _lastActiveEventMs = activeEv.time - LINGER_MS;
			_clearWords();
			return;
		}

		_lastActiveEventMs = activeEv.time;

		if (activeEv.mode == 1)
		{
			_buildWords(activeEv.text.split(' '));
			_colorAllWords(activeEv.color);
		}
		else
		{
			_buildWords(activeEv.text.split(';'));
			_highlightWord(activeEv.wordIndex, activeEv.color);
		}
	}

	private function _advanceEvents(ms:Float):Void
	{
		while (_eventIndex < _events.length && ms >= _events[_eventIndex].time)
		{
			final ev = _events[_eventIndex];
			_eventIndex++;
			
			if (ev.text == '' || ev.text == 'null')
			{
				if (_lastActiveEventMs >= 0) _lastActiveEventMs = ev.time - LINGER_MS;
				_clearWords();
				continue;
			}

			_lastActiveEventMs = ev.time;

			if (ev.mode == 1)
			{
				final words = ev.text.split(' ');
				if (_wordsChanged(words)) _buildWords(words);
				_colorAllWords(ev.color);
			}
			else
			{
				final words = ev.text.split(';');
				if (_wordsChanged(words)) _buildWords(words);
				_highlightWord(ev.wordIndex, ev.color);
			}
		}
	}

	private function _applySlide():Void
	{
		sprite.y = _subY + _slideOffset;
		_repositionContent();
	}

	private function _repositionContent():Void
	{
		final iy = _innerY + _slideOffset;
		final textY = iy + (_innerH - FONT_SIZE) * 0.5 + TEXT_OFFSET_Y;
		_baseY = textY;
		
		if (_bg.visible)
			_bg.y = textY - BG_PAD_Y;

		for (i in 0..._words.length)
			if (i != _activeWord - 1)
				_words[i].y = textY;
	}

	private function _wordsChanged(words:Array<String>):Bool
	{
		if (words.length != _currentWords.length) return true;
		for (i in 0...words.length)
			if (words[i] != _currentWords[i]) return true;
		return false;
	}

	private function _buildWords(words:Array<String>):Void
	{
		_clearWords();
		_currentWords = words.copy();

		final dummy = new FlxText(0, 0, 0, '', FONT_SIZE);
		dummy.setFormat(FONT, FONT_SIZE);
		var fontSize = FONT_SIZE;
		var widths:Array<Float> = [];
		var totalW:Float = 0;

		final measure = function():Void
		{
			widths = [];
			totalW = 0;
			dummy.size = fontSize;
			for (w in words)
			{
				dummy.text = w;
				final ww = dummy.textField.textWidth + 2;
				widths.push(ww);
				totalW += ww;
			}
			totalW += WORD_SPACING * (words.length - 1);
		};

		measure();
		final maxW = _innerW - BG_PAD_X * 2;
		
		while (totalW > maxW && fontSize > 8)
		{
			fontSize--;
			measure();
		}
		dummy.destroy();

		final iy = _innerY + _slideOffset;
		final textY = iy + (_innerH - fontSize) * 0.5 + TEXT_OFFSET_Y;
		_baseY = textY;
		final cx = _innerX + _innerW * 0.5;

		final bgW = Math.min(totalW + BG_PAD_X * 2, _innerW);
		final bgH = fontSize + BG_PAD_Y * 2 + LIFT_AMOUNT;
		_bg.makeGraphic(Math.ceil(bgW), Math.ceil(bgH), FlxColor.BLACK);
		_bg.setPosition(cx - bgW * 0.5, textY - BG_PAD_Y);
		_bg.alpha = BG_ALPHA;
		_bg.visible = true;
		
		var curX = cx - totalW * 0.5;
		for (i in 0...words.length)
		{
			final lbl = new FlxText(curX, textY, 0, words[i], fontSize);
			lbl.setFormat(FONT, fontSize, FlxColor.WHITE, LEFT);
			lbl.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			lbl.antialiasing = false;
			add(lbl);
			_words.push(lbl);
			curX += widths[i] + WORD_SPACING;
		}
	}

	private function _highlightWord(index:Int, color:FlxColor):Void
	{
		final baseSize = _words.length > 0 ? _words[0].size : FONT_SIZE;
		for (i in 0..._words.length)
		{
			final w = _words[i];
			FlxTween.cancelTweensOf(w);
			if (i == index - 1)
			{
				w.color = color;
				w.size = baseSize + 2;
				FlxTween.tween(w, {y: _baseY - LIFT_AMOUNT}, 0.08, {ease: FlxEase.quadOut});
			}
			else
			{
				w.color = FlxColor.WHITE;
				w.size = baseSize;
				FlxTween.tween(w, {y: _baseY}, 0.12, {ease: FlxEase.quadOut});
			}
		}
		_activeWord = index;
	}

	private function _colorAllWords(color:FlxColor):Void
	{
		for (w in _words)
		{
			FlxTween.cancelTweensOf(w);
			w.color = color;
			w.size = FONT_SIZE;
			w.y = _baseY;
		}
		_activeWord = -1;
	}

	private function _clearWords():Void
	{
		for (w in _words)
		{
			FlxTween.cancelTweensOf(w);
			remove(w, true);
			w.destroy();
		}
		_words = [];
		_currentWords = [];
		_activeWord = -1;
		_bg.visible = false;
		_bg.alpha = 0;
	}
}