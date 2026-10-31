package states;

import backend.Song;
import flixel.text.FlxText.FlxTextBorderStyle;

class SonichuUnlockState extends MusicBeatState
{
	public static var pending:Bool = false;

	var _lines:Array<String>;
	var _text:FlxText;
	var _static:FlxSound;
	var _line:Int = 0;
	var _typed:Int = 0;
	var _typeTimer:Float = 0;
	var _wait:Float = 1.6;
	var _busy:Bool = false;
	var _finale:Float = -1;
	var _beatTimer:Float = 0;
	var transitioning:Bool = false;

	override function create()
	{
		pending = false;
		FlxG.sound.music?.stop();
		FlxG.mouse.visible = false;

		_lines = [
			Language.get('sonichu_reveal_1', 'So you made it this far...'),
			Language.get('sonichu_reveal_2', 'Get ready, because this is the end.'),
			Language.get('sonichu_reveal_3', 'My final power...')
		];

		final font = Language.needsCustomFont() ? Paths.font(Language.getFontForLanguage()) : Paths.font('Times New Roman.ttf');
		_text = new FlxText(80, 0, FlxG.width - 160, '');
		_text.setFormat(font, 40, 0xFFB00000, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		_text.antialiasing = ClientPrefs.data.antialiasing;
		add(_text);

		_static = FlxG.sound.play(Paths.sound('static'), 0, true);

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (transitioning) return;

		if (_finale >= 0)
		{
			_finale += elapsed;
			final k = Math.min(1, _finale / 3.2);
			_static.volume = 0.15 + 0.55 * k;
			_text.offset.set(FlxG.random.float(-8, 8) * k, FlxG.random.float(-8, 8) * k);
			_text.scale.set(1 + 0.25 * k, 1 + 0.25 * k);

			_beatTimer -= elapsed;
			if (_beatTimer <= 0)
			{
				FlxG.sound.play(Paths.sound('minigame/thevalley/heartbeat'), 0.4 + 0.6 * k);
				FlxG.camera.shake(0.004 + 0.012 * k, 0.15);
				_beatTimer = 0.9 - 0.6 * k;
			}

			if (_finale >= 3.2) _cut();
			return;
		}

		_static.volume = Math.min(0.15, _static.volume + elapsed * 0.03);
		if (_busy) return;

		if (_wait > 0)
		{
			_wait -= elapsed;
			return;
		}

		final last = _line == _lines.length - 1;
		final line = _lines[_line];
		if (_typed < line.length)
		{
			_typeTimer -= elapsed;
			if (_typeTimer > 0) return;
			_typeTimer = last ? 0.14 : 0.06;
			_typed++;
			_text.text = line.substr(0, _typed);
			_text.screenCenter(Y);
			if (line.charAt(_typed - 1) != ' ') FlxG.sound.play(Paths.sound('clickText'), 0.35);
			return;
		}

		if (last)
		{
			_finale = 0;
			_text.centerOrigin();
			FlxG.sound.play(Paths.sound('exelaugh'), 0.8);
			return;
		}

		_busy = true;
		new FlxTimer().start(1.8, (_) -> FlxTween.tween(_text, {alpha: 0}, 0.5, {onComplete: (_) -> {
			_line++;
			_typed = 0;
			_text.text = '';
			_text.alpha = 1;
			if (_line == _lines.length - 1) _text.size = 64;
			_wait = 0.6;
			_busy = false;
		}}));
	}

	function _cut():Void
	{
		transitioning = true;
		FlxG.sound.list.forEach(s -> s?.stop());
		_text.visible = false;
		new FlxTimer().start(1.2, (_) -> _playShocker());
	}

	function _playShocker():Void
	{
		Mods.currentModDirectory = 'SONICHU';
		Song.loadFromJson('shocker', 'shocker');

		EXEMenu.secretSong = true;
		PlayState.storyPlaylist = ['shocker'];
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
		PlayState.storyWeek = 0;
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
	}
}
