package states.substates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import backend.Language;

class SunkySubstate extends MusicBeatSubstate
{
	final _onChoice:Bool->Void;
	final _cam:FlxCamera;
	final _cardCam:FlxCamera;
	final _k:Float;
	final _cs:Float;
	final _ox:Float;
	final _oy:Float;
	final _cardX:Float;
	final _cardY:Float;
	final _boxes:Array<FlxSprite> = [];
	final _labels:Array<FlxText> = [];
	final _homes:Array<Float> = [];

	var _bg:FlxSprite;
	var _sunky:FlxSprite;
	var _title:FlxSprite;
	var _subtitle:FlxSprite;
	var _message:FlxSprite;
	var _messageText:FlxText;
	var _shadow:FlxSprite;
	var _shadowTween:FlxTween;
	var _shadowShift:Float = 0;
	var _drama:FlxSound;
	var _theme:FlxSound;
	var _selected:Int = 0;
	var _ready:Bool = false;
	var _chosen:Bool = false;
	var _revealed:Bool = false;
	var _blinks:Int = 0;
	var _blinkTimer:Float = 0;
	var _time:Float = 0;
	var _clock:Float = 0;
	var _zoom:Float = 1.35;
	var _out:Float = 0;
	var _slide:Float = 0;
	var _sunkyX:Float = 0;
	var _titleX:Float = 0;
	var _mouseWasVisible:Bool = false;

	public function new(onChoice:Bool->Void)
	{
		super();
		_onChoice = onChoice;
		_k = Math.min(FlxG.width / 1280, FlxG.height / 720);
		_ox = (FlxG.width - 1280 * _k) / 2;
		_oy = (FlxG.height - 720 * _k) / 2;

		_cam = new FlxCamera();
		_cam.bgColor = 0;
		FlxG.cameras.add(_cam, false);

		final cardW = Std.int(722 * _k);
		final cardH = Std.int(535 * _k);
		_cs = cardH / 1080;
		_cardX = _ox + 528 * _k;
		_cardY = _oy + 85 * _k;
		_cardCam = new FlxCamera(0, 0, cardW, cardH);
		_cardCam.bgColor = 0;
		FlxG.cameras.add(_cardCam, false);
	}

	override function create()
	{
		super.create();
		_mouseWasVisible = FlxG.mouse.visible;
		FlxG.mouse.visible = true;

		_bg = place(new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK));
		_bg.scale.set(FlxG.width, FlxG.height);
		_bg.updateHitbox();
		_bg.alpha = 0;
		FlxTween.tween(_bg, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});

		stretch('bg.png');

		_sunky = layer('Sunky.png', 726, 62);
		_sunkyX = _sunky.x;
		_sunky.x = _sunkyX + 220 * _cs;
		_sunky.setColorTransform(0, 0, 0, 1);

		layer('Mancha.png', -85, 45, 0.76);

		_title = layer('letras1.png', 75, 111, 0.76);
		_titleX = _title.x;
		_title.x = _titleX - 220 * _cs;
		_title.setColorTransform(0, 0, 0, 1);

		_subtitle = layer('letras 2.png', 85, 525);
		_subtitle.setGraphicSize(Std.int(654 * _cs));
		_subtitle.updateHitbox();
		_subtitle.setPosition(85 * _cs, 525 * _cs);
		_subtitle.visible = false;

		stretch('marco.png');

		_cardCam.alpha = 0;
		FlxTween.tween(_cardCam, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});
		updateCard();

		_message = place(new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/botplay/sunkybot/message.png')));
		_message.setGraphicSize(Std.int(508 * _k));
		_message.updateHitbox();
		_message.setPosition(-_message.width - 20, _oy + 128 * _k);

		_messageText = place(new FlxText(0, 0, _message.width * 0.72, Language.getPhrase('sunky_offer_message',
			"Sunky has noticed that you're having a hard time with this song, so he's offering to help you!\nDo you want to accept his offer?")));
		_messageText.setFormat(Language.isCJK() ? Paths.font(Language.getFontForLanguage()) : Paths.font('UbuntuSans.ttf'), Std.int(32 * _k), FlxColor.BLACK, CENTER);
		while (_messageText.height > _message.height * 0.62 && _messageText.size > 12) _messageText.size -= 2;

		_shadow = place(new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/mainmenu/options/shadow.webp')));
		_shadow.scale.set(0.18 * _k, 0.18 * _k);
		_shadow.updateHitbox();
		_shadow.alpha = 0;

		final font = Language.needsCustomFont() ? Paths.font(Language.getFontForLanguage()) : Paths.font('SonicFont.ttf');
		final names = [Language.getPhrase('sunky_offer_yes', 'YEAH PLEASE'), Language.getPhrase('sunky_offer_no', 'NO THANKS')];
		final boxBitmap = Paths.getBitmapData('assets/exe/mainmenu/options/box.webp');
		for (i in 0...2)
		{
			final box = place(new FlxSprite().loadGraphic(boxBitmap));
			box.scale.set(0.2 * _k, 0.2 * _k);
			box.updateHitbox();
			box.setPosition(-box.width - 40, _oy + (452 + i * 100) * _k);
			_boxes.push(box);
			_homes.push(_ox + (95 + i * 8) * _k);

			final label = place(new FlxText(0, 0, 0, names[i]));
			label.setFormat(font, Std.int(40 * _k), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			label.borderSize = 2;
			while (label.width > box.width * 0.8 && label.size > 12) label.size -= 2;
			_labels.push(label);
		}

		_drama = FlxG.sound.play(Paths.returnSound('botplay/sunkybot/dramaticeffect', 'exe'), 1, false, null, true, () -> {
			_drama = null;
			playTheme();
		});
	}

	function playTheme()
	{
		if (_theme == null) _theme = FlxG.sound.play(Paths.returnSound('music/sunky', 'exe'), 0.8, true);
	}

	function layer(file:String, x:Float, y:Float, size:Float = 1):FlxSprite
	{
		final sprite = place(new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/botplay/sunkybot/$file')));
		sprite.cameras = [_cardCam];
		sprite.scale.set(_cs * size, _cs * size);
		sprite.updateHitbox();
		sprite.setPosition(x * _cs, y * _cs);
		return sprite;
	}

	function stretch(file:String):FlxSprite
	{
		final sprite = layer(file, 0, 0);
		sprite.setGraphicSize(_cardCam.width, _cardCam.height);
		sprite.updateHitbox();
		sprite.setPosition(0, 0);
		return sprite;
	}

	function place<T:FlxSprite>(sprite:T):T
	{
		sprite.cameras = [_cam];
		sprite.scrollFactor.set();
		sprite.antialiasing = ClientPrefs.data.antialiasing;
		add(sprite);
		return sprite;
	}

	function updateCard()
	{
		final cx = FlxMath.lerp(FlxG.width / 2, _cardX + _cardCam.width / 2, _out) + _slide;
		final cy = FlxMath.lerp(FlxG.height / 2, _cardY + _cardCam.height / 2, _out) + Math.sin(_time * 2.2) * 4 * _k * _out;
		_cardCam.flashSprite.scaleX = _cardCam.flashSprite.scaleY = FlxMath.lerp(_zoom, 1, _out);
		_cardCam.x = cx - _cardCam.width / 2;
		_cardCam.y = cy - _cardCam.height / 2;
	}

	function reveal()
	{
		_revealed = true;
		_sunky.x = _sunkyX;
		_title.x = _titleX;
		_sunky.setColorTransform();
		_title.setColorTransform();
		_cardCam.flash(FlxColor.WHITE, 0.6);
		FlxTween.num(0, 1, 0.8, {ease: FlxEase.expoOut}, v -> _out = v);

		_subtitle.visible = true;
		_subtitle.alpha = 0;
		final subtitleScale = _subtitle.scale.x;
		_subtitle.scale.set(subtitleScale * 1.6, subtitleScale * 1.6);
		FlxTween.tween(_subtitle, {alpha: 1}, 0.2, {startDelay: 0.35});
		FlxTween.tween(_subtitle.scale, {x: subtitleScale, y: subtitleScale}, 0.4, {ease: FlxEase.backOut, startDelay: 0.35});

		FlxTween.tween(_message, {x: _ox + 16 * _k}, 0.7, {ease: FlxEase.backOut, startDelay: 0.4});
		for (i in 0..._boxes.length)
			FlxTween.tween(_boxes[i], {x: _homes[i]}, 0.55, {ease: FlxEase.quintOut, startDelay: 0.6 + i * 0.1});

		new FlxTimer().start(1.2, _ -> {
			_ready = true;
			select(0, false);
		});
	}

	function select(index:Int, sound:Bool = true)
	{
		if (sound && index != _selected) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		_selected = index;
		for (i in 0..._boxes.length)
		{
			FlxTween.cancelTweensOf(_boxes[i]);
			FlxTween.tween(_boxes[i], {x: _homes[i] + (i == index ? 14 * _k : 0)}, 0.18, {ease: FlxEase.quintOut});
			_boxes[i].alpha = i == index ? 1 : 0.75;
			_labels[i].alpha = _boxes[i].alpha;
		}
		_shadow.alpha = 0;
		_shadowShift = 0;
		_shadowTween?.cancel();
		_shadowTween = FlxTween.num(0, 1, 0.1, {ease: FlxEase.quintOut, startDelay: 0.15, onStart: _ -> _shadow.alpha = 1}, v -> _shadowShift = v);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		_time += elapsed;

		if (!_revealed)
		{
			_clock = _drama != null && _drama.playing ? _drama.time / 1000 : _clock + elapsed / FlxG.timeScale;
			final slide = 220 * _cs * (1 - FlxEase.sineOut(Math.min(_clock / 5, 1)));
			_sunky.x = _sunkyX + slide;
			_title.x = _titleX - slide;
			_zoom = 1.35 + 0.1 * Math.min(_clock / 6.2, 1);
			if (_clock >= 6.2) reveal();
		}
		if (_drama != null && _drama.time >= _drama.length - 1000) playTheme();
		updateCard();

		for (i in 0..._boxes.length)
		{
			final box = _boxes[i];
			final label = _labels[i];
			label.setPosition(box.x + (box.width - label.width) * 0.5 - 4 * _k, box.y + (box.height - label.height) * 0.5 + 2 * _k);
		}
		_messageText.setPosition(_message.x + (_message.width - _messageText.width) * 0.5, _message.y + (_message.height - _messageText.height) * 0.5);
		final picked = _boxes[_selected];
		_shadow.setPosition(picked.x + FlxMath.lerp(22, 89, _shadowShift) * 0.2 * _k, picked.y + FlxMath.lerp(50, 72, _shadowShift) * 0.2 * _k);

		if (_chosen)
		{
			updateBlink(elapsed);
			return;
		}
		if (!_ready) return;

		if (controls.UI_UP_P || controls.UI_DOWN_P) select(1 - _selected);

		var hovered:Int = -1;
		for (i in 0..._boxes.length) if (FlxG.mouse.overlaps(_boxes[i], _cam)) hovered = i;
		if (hovered >= 0 && FlxG.mouse.justMoved && hovered != _selected) select(hovered);

		if (controls.ACCEPT || (FlxG.mouse.justPressed && hovered >= 0))
		{
			if (hovered >= 0 && hovered != _selected) select(hovered, false);
			choose();
		}
		else if (controls.BACK)
		{
			select(1, false);
			choose();
		}
	}

	function choose()
	{
		_chosen = true;
		FlxG.sound.play(Paths.sound(_selected == 0 ? 'confirmMenu' : 'cancelMenu'));
		if (_selected == 0)
		{
			FlxTween.cancelTweensOf(_sunky.scale);
			_sunky.scale.set(_cs * 1.06, _cs * 1.06);
			FlxTween.tween(_sunky.scale, {x: _cs, y: _cs}, 0.35, {ease: FlxEase.elasticOut});
		}
	}

	function updateBlink(elapsed:Float)
	{
		if (_blinks < 0) return;
		_blinkTimer += elapsed;
		if (_blinkTimer < 0.05) return;
		_blinkTimer = 0;
		_blinks++;
		final on = _blinks % 2 == 0;
		_boxes[_selected].visible = _labels[_selected].visible = _shadow.visible = on;
		if (_blinks < 12) return;

		_blinks = -1;
		_boxes[_selected].visible = _labels[_selected].visible = _shadow.visible = true;
		FlxTween.num(0, FlxG.width, 0.45, {ease: FlxEase.backIn}, v -> _slide = v);
		FlxTween.tween(_message, {x: -_message.width - 20}, 0.45, {ease: FlxEase.backIn, startDelay: 0.05});
		for (i in 0..._boxes.length)
		{
			FlxTween.cancelTweensOf(_boxes[i]);
			FlxTween.tween(_boxes[i], {x: -_boxes[i].width - 40}, 0.4, {ease: FlxEase.backIn, startDelay: 0.08 + i * 0.05});
		}
		FlxTween.tween(_shadow, {alpha: 0}, 0.2);
		_theme?.fadeOut(0.6, 0);
		FlxTween.tween(_bg, {alpha: 0}, 0.35, {startDelay: 0.35, onComplete: _ -> finish()});
	}

	function finish()
	{
		final accepted = _selected == 0;
		FlxG.mouse.visible = _mouseWasVisible;
		_drama?.stop();
		_theme?.stop();
		close();
		_onChoice(accepted);
	}

	override function destroy()
	{
		if (FlxG.cameras.list.contains(_cam)) FlxG.cameras.remove(_cam);
		if (FlxG.cameras.list.contains(_cardCam)) FlxG.cameras.remove(_cardCam);
		super.destroy();
	}
}
