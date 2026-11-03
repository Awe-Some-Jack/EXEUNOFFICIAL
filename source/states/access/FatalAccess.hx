package states.access;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.sound.FlxSound;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.utils.Assets;
import haxe.io.Path;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import backend.Song;
import shaders.ErrorHandledShader.ErrorHandledRuntimeShader;
import states.LoadingState;
import states.PlayState;
import states.EXEMenu;
import states.EXEFreeplay;
import states.EXETitle;
import states.StoryModeState;

enum abstract FatalScene(Int) from Int to Int
{
	var TRANSMISSION = 0;
	var GRANTED = 1;
	var DENIED = 2;
	var REMINDER = 3;
}

typedef FatalLine = {
	text:String,
	sound:String,
	dur:Float,
	style:Int,
	x:Float,
	y:Float,
	w:Float,
	h:Float,
	bg:Int,
	file:Int,
	noise:Int,
	star:Bool,
	face:Bool
}

typedef FatalKey = { at:Float, run:Void->Void }

class FatalAccess extends MusicBeatState
{
	static var _watching:Bool = false;
	static var _pollTimer:Float = 0;

	var _scene:FatalScene;
	var _keys:Array<FatalKey> = [];
	var _keyIndex:Int = 0;
	var _clock:Float = 0;
	var _trackStarted:Bool = false;
	var _trackWait:Float = 0;
	var _time:Float = 0;
	var _track:FlxSound;
	var _voice:FlxSound;
	var _fall:FatalFall;
	final _errors:Array<FlxSprite> = [];
	var _errorArt:Array<BitmapData> = null;
	var _launched:Bool = false;
	var _off:Float = -1;
	var _boxStyle:Int = 0;

	var _matrix:FlxSprite;
	var _white:FlxSprite;
	var _face:FlxSprite;
	var _whiteEyes:FlxSprite;
	var _star:FlxSprite;
	var _starSplit:Array<FlxSprite> = [];
	var _fileIcon:FlxSprite;
	var _fileText:FlxText;
	var _redNoise:FlxSprite;
	var _grayNoise:FlxSprite;
	var _box:FlxSprite;
	var _boxText:FlxSprite;

	var _noiseKind:Int = 0;
	var _starCX:Float = 0;
	var _starCY:Float = 0;
	var _starGrow:Float = 1;
	var _redLine:Bool = false;
	var _reveal:Float = -1;
	var _flash:Float = 0;

	var _matrixShader:ErrorHandledRuntimeShader;
	var _decimate:ErrorHandledRuntimeShader;
	var _smear:ErrorHandledRuntimeShader;
	var _pseudo:ErrorHandledRuntimeShader;
	var _dec:Float = 0;
	var _smearAmt:Float = 0;
	var _bright:Float = 0.15;
	var _melt:Float = -1;
	var _meltSpeed:Float = 1;

	var _winMoved:Bool = false;
	var _winHomeX:Int = 0;
	var _winHomeY:Int = 0;
	var _winTimer:Float = 0;

	public function new(scene:FatalScene)
	{
		super();
		_scene = scene;
	}

	public static function folderPath():String
		return Path.join([Path.directory(Sys.programPath()), 'assets', 'exe', 'OPEN ME PLAYER']);

	public static function filePath():String
		return Path.join([folderPath(), 'ContainFatalError.cnt']);

	public static function granted():Bool
		return FlxG.save.data.fatalGranted == true;

	public static function denied():Bool
		return FlxG.save.data.fatalDenied == true;

	// Story progress is tracked through lastCoverPlay (0-4 = covers, 5 = final song beaten).
	// weekCompleted is kept as a fallback, but nothing in StoryModeState writes to it.
	public static function storyBeaten():Bool
	{
		if (FlxG.save.data.storyModeDone == true) return true;
		final cover:Null<Int> = FlxG.save.data.lastCoverPlay;
		if (cover != null && cover >= 5) return true;
		return StoryModeState.weekCompleted.get('exe') == true;
	}

	public static function fatalityUnlocked():Bool
		return backend.SongProgress.beatenSongs().contains('fatality') || backend.SongProgress.openedSongs().contains('fatality');

	public static function menuScene():Null<FatalScene>
	{
		if (fatalityUnlocked()) return null;
		#if (mobile || mac)
		if (granted() || !storyBeaten()) return null;
		return FlxG.save.data.fatalMobileSeen == true ? REMINDER : TRANSMISSION;
		#elseif sys
		if (granted() || !storyBeaten()) return null;
		if (!FileSystem.exists(folderPath())) return TRANSMISSION;
		if (FileSystem.exists(filePath())) return REMINDER;
		_createFile();
		return null;
		#else
		return null;
		#end
	}

	public static function reopen():Void
	{
		if (!denied()) return;
		FlxG.save.data.fatalDenied = false;
		FlxG.save.flush();
		_createFile();
	}

	public static function resetForTesting():Void
	{
		FlxG.save.data.fatalGranted = false;
		FlxG.save.data.fatalDenied = false;
		FlxG.save.flush();
		#if (sys && !mobile && !mac)
		try
		{
			if (FileSystem.exists(filePath())) FileSystem.deleteFile(filePath());
			if (FileSystem.exists(folderPath())) FileSystem.deleteDirectory(folderPath());
		}
		catch (e:Dynamic) {}
		#end
	}

	public static function startWatching():Void
	{
		#if (sys && !mobile && !mac)
		if (_watching) return;
		_watching = true;
		FlxG.signals.postUpdate.add(_poll);
		#end
	}

	static function _poll():Void
	{
		#if (sys && !mobile && !mac)
		_pollTimer -= FlxG.elapsed;
		if (_pollTimer > 0) return;
		_pollTimer = 0.5;
		if (granted() || denied()) return;

		final state = FlxG.state;
		if (state == null || state.subState != null) return;
		if (!(state is EXEMenu || state is EXEFreeplay || state is StoryModeState || state is EXETitle)) return;

		final scene = bootScene();
		if (scene == null) return;
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		FlxG.sound.music?.stop();
		FlxG.switchState(() -> new FatalAccess(scene));
		#end
	}

	public static function bootScene():Null<FatalScene>
	{
		#if (sys && !mobile && !mac)
		final path = filePath();
		if (granted() || denied() || !FileSystem.exists(path)) return null;
		try
		{
			final answer = _readAnswer(File.getContent(path));
			if (answer == null) return null;
			if (!answer)
			{
				FlxG.save.data.fatalDenied = true;
				FlxG.save.flush();
				return DENIED;
			}
			FlxG.save.data.fatalGranted = true;
			FlxG.save.flush();
			backend.EXEAchievements.unlock('fatal');
			backend.EXEAchievements.save();
			File.saveContent(path, 'ACCESS GRANTED.\r\n\r\nThank you, player.\r\n\r\n- F\r\n');
			return GRANTED;
		}
		catch (e:Dynamic) {}
		#end
		return null;
	}

	public static function parseAnswer(text:String):Null<Bool>
		return _readAnswer('>' + text);

	static function _readAnswer(content:String):Null<Bool>
	{
		final mark = content.lastIndexOf('>');
		final answer = StringTools.trim(mark >= 0 ? content.substr(mark + 1) : '').toUpperCase();
		if (StringTools.startsWith(answer, 'YES') || StringTools.startsWith(answer, 'SI') || answer == 'Y') return true;
		if (StringTools.startsWith(answer, 'NO') || answer == 'N') return false;
		return null;
	}

	static function _createFile():Void
	{
		#if (sys && !mobile && !mac)
		try
		{
			FileSystem.createDirectory(folderPath());
			File.saveContent(filePath(), [
				'================================================================',
				'                     ContainFatalError.cnt',
				'================================================================',
				'',
				'Y̸̺͐͊O̸̱̟͑́͛U̸͓̼̳͗Ṛ̵̛̘ ̵̼̆̇̾Ȃ̸͙̂̕N̸̨̎S̷̩̯̩̏̏͗W̴͒̈͜͝E̸̛͎̓R̶͒͐͜ ̵̨͎̱̌N̴̘̬̑̋O̷̺͒̑̕W̶̬̦͍͛.̶͚̿͑ ̴̬̆̚',
				'̴̨̟͈́͘͠',
				'̶̫͍̈́́Y̶̱̖̞͂E̶̯͂̈́͑S̷̫͛̅ ̷̺̐̿̔Ö̷̧̤͕́Ṟ̸͚̭͛ ̶̨̓N̸O̵̼͓͝?̷͚̰̾͝',
				'',
				'>' 
			].join('\r\n'));
		}
		catch (e:Dynamic) {}
		#end
	}

	static function _line(text:String, sound:String, dur:Float, style:Int, x:Float, y:Float, w:Float, h:Float, bg:Int = 0, file:Int = 0, noise:Int = 0, star:Bool = true, face:Bool = false):FatalLine
		return {text: text, sound: sound, dur: dur, style: style, x: x, y: y, w: w, h: h, bg: bg, file: file, noise: noise, star: star, face: face};

	static function _script(scene:FatalScene):Array<FatalLine>
	{
		return switch (scene)
		{
			case GRANTED: [
				_line("VERY WELL THEN.", '', 1.9, 0, 0.56, 0.63, 0.41, 0.23),
				_line("LET'S.", '', 1.1, 0, 0.03, 0.61, 0.46, 0.25),
				_line("BEGINNNN!!", '', 5.0, 1, 0.18, 0.06, 0.65, 0.36)
			];
			case DENIED: [
				_line("hmm...", '', 0.6, 0, 0.6, 0.63, 0.3, 0.2),
				_line("what a shame.", '', 1.3, 0, 0.05, 0.6, 0.42, 0.23),
				_line("and i thought we were gonna have fun...", '', 4.5, 0, 0.28, 0.67, 0.48, 0.26),
				_line("GOOD", '', 3.1, 1, 0.12, 0.06, 0.76, 0.3, 0, 0, 0, true, true)
			];
			case REMINDER: [
				_line("you have your task...", 'reminder1', 2.2, 2, 0.06, 0.26, 0.88, 0.48, 0, 0, 0, false),
				_line("DO NOT MAKE ME REMIND YOU AGAIN!!", 'reminder2', 3.4, 1, 0.26, 0.06, 0.47, 0.26, 0, 0, 0, true, true)
			];
			default: [
				_line("I didnt think you would even show up", '', 3.8, 0, 0.56, 0.63, 0.41, 0.23),
				_line("If that would have been the case...", '', 2.3, 0, 0.03, 0.61, 0.46, 0.25),
				_line("i would have come straight to you instead!!", '', 3.6, 1, 0.18, 0.06, 0.65, 0.36),
				_line("but that is not important", '', 2.6, 0, 0.31, 0.67, 0.44, 0.24),
				_line("you have a task to complete", '', 3.0, 0, 0.28, 0.67, 0.48, 0.24),
				_line("once this message completes...", '', 3.0, 0, 0.28, 0.67, 0.46, 0.24),
				_line("close the game...", '', 1.4, 0, 0.03, 0.53, 0.46, 0.24),
				_line("and follow the instructions I give!", '', 4.4, 0, 0.49, 0.67, 0.48, 0.26),
				_line("go into the files...", '', 2.2, 2, 0.06, 0.26, 0.88, 0.48, 1, 0, 0, false),
				_line("find a file marked as containment...", '', 3.9, 0, 0.18, 0.62, 0.64, 0.36, 1, 1, 0, false),
				_line("and grant me access!", '', 1.1, 0, 0.2, 0.62, 0.6, 0.33, 1, 2, 0, false),
				_line("and grant me access!", '', 0.6, 0, 0.1, 0.6, 0.3, 0.17),
				_line("you have your task...", '', 1.9, 2, 0.06, 0.26, 0.88, 0.48, 0, 0, 0, false),
				_line("DO NOT MAKE ME REMIND YOU AGAIN!!", '', 4.2, 1, 0.26, 0.06, 0.47, 0.26, 0, 0, 0, true, true)
			];
		}
	}

	static function _sound(path:String):Sound
	{
		#if (sys && !mobile)
		if (FileSystem.exists(path))
		{
			try return Sound.fromFile(path) catch (e:Dynamic) {}
		}
		#end
		if (Assets.exists(path))
		{
			try return Assets.getSound(path) catch (e:Dynamic) {}
		}
		return null;
	}

	static function _fontPath():String
	{
		#if sys
		if (FileSystem.exists('assets/fonts/ArchivoBlack-Regular.ttf')) return Paths.font('ArchivoBlack-Regular.ttf');
		#end
		return Paths.font('bigass.otf');
	}

	public static function barHeight(style:Int):Int
		return style == 1 ? 26 : (style == 2 ? 55 : 24);

	public static function window(w:Int, h:Int, style:Int):BitmapData
	{
		final src = Paths.getBitmapData('assets/exe/access/fatal/' + ['box', 'boxred', 'boxbig'][style] + '.png');
		final bar = barHeight(style);
		final out = new BitmapData(w, h, true, 0);
		for (y in 0...h)
		{
			final sy = y < bar ? y : (y < h - 3 ? bar : y - h + src.height);
			out.fillRect(new Rectangle(0, y, w, 1), src.getPixel32(3, sy));
			out.copyPixels(src, new Rectangle(0, sy, 3, 1), new Point(0, y));
			out.copyPixels(src, new Rectangle(src.width - 3, sy, 3, 1), new Point(w - 3, y));
		}
		src.dispose();
		return out;
	}

	public static function glitchStrip(src:BitmapData):BitmapData
	{
		final w = src.width;
		final h = src.height;
		final k = w / 920;
		final strip = new BitmapData(w * 4, h, true, 0);
		final shifts = [26, 12, 5];
		final keeps = [70, 85, 95];
		final chunks = [10, 6, 2];
		strip.copyPixels(src, src.rect, new Point(w * 3, 0));
		for (i in 0...3)
		{
			final ox = i * w;
			var by = 0;
			while (by < h)
			{
				final band = Std.int(Math.max(1, Math.min(FlxG.random.int(Std.int(h * 0.017) + 1, Std.int(h * 0.075) + 2), h - by)));
				final shift = Std.int(FlxG.random.int(-shifts[i], shifts[i]) * k);
				if (FlxG.random.bool(keeps[i]))
					strip.copyPixels(src, new Rectangle(shift < 0 ? -shift : 0, by, w - Math.abs(shift), band), new Point(ox + (shift > 0 ? shift : 0), by));
				by += band;
			}
			for (c in 0...chunks[i])
			{
				final cw = FlxG.random.float(w * 0.013, w * 0.076);
				final ch = FlxG.random.float(h * 0.017, h * 0.083);
				strip.fillRect(new Rectangle(ox + FlxG.random.float(0, w - cw), FlxG.random.float(0, h - ch), cw, ch), i == 0 ? 0xFF000000 : 0xFFC0C0C0);
			}
		}
		strip.colorTransform(new Rectangle(0, 0, w, h), new ColorTransform(1.3, 0, 0, 1, 0, 0, 0, 0));
		return strip;
	}

	public static function glitchBox(w:Int, h:Int, x:Float, y:Float, style:Int):FlxSprite
	{
		final src = window(w, h, style);
		final box = new FlxSprite(x, y).loadGraphic(glitchStrip(src), true, w, h);
		src.dispose();
		box.animation.add('in', [0, 1, 2, 3], 12, false);
		box.animation.play('in');
		box.antialiasing = false;
		return box;
	}

	public static function textSprite(text:String, size:Int, width:Int, red:Bool):FlxSprite
	{
		final label = new FlxText(0, 0, width, text, size);
		label.setFormat(_fontPath(), size, 0xFFFFFFFF, CENTER);
		label.drawFrame(true);
		final spr = new FlxSprite().makeGraphic(label.frameWidth + 3, label.frameHeight + 3, 0, true);
		final layers = red ? [[3, 0x280000], [2, 0x280000], [1, 0xFFFFFF]] : [[3, 0x4E0000], [2, 0x4E0000], [0, 0xFF9696], [1, 0xE41414]];
		for (layer in layers)
		{
			label.color = layer[1];
			spr.stamp(label, layer[0], layer[0]);
		}
		label.destroy();
		spr.antialiasing = false;
		spr.scale.set(2, 2);
		spr.updateHitbox();
		return spr;
	}

	static function _vignette():BitmapData
	{
		final bmd = new BitmapData(160, 90, false, 0xFFFFFFFF);
		for (py in 0...90)
			for (px in 0...160)
			{
				final dx = (px + 0.5) / 80 - 1;
				final dy = (py + 0.5) / 45 - 1;
				final v = Std.int(243 - 58 * Math.min(1, Math.pow(Math.sqrt(dx * dx * 0.8 + dy * dy), 2.2)));
				bmd.setPixel(px, py, (v << 16) | (v << 8) | v);
			}
		return bmd;
	}

	static function _grayStatix():BitmapData
	{
		final atlas = Paths.getBitmapData(Paths.modFolders('images/statix.webp'));
		final pixels = atlas.getVector(atlas.rect);
		for (i in 0...pixels.length)
		{
			final c = pixels[i];
			final v = Std.int(Math.min(255, ((c >> 16) & 0xFF) * 3.5 + ((c >> 8) & 0xFF) * 1.5 + (c & 0xFF) + 10));
			pixels[i] = (c & 0xFF000000) | (v << 16) | (v << 8) | v;
		}
		atlas.setVector(atlas.rect, pixels);
		return atlas;
	}

	static function _fadedFace():BitmapData
	{
		final face = Paths.getBitmapData('assets/exe/access/fatal/face.png');
		final w = face.width;
		final h = face.height;
		final pixels = face.getVector(face.rect);
		for (py in 0...h)
		{
			for (px in 0...w)
			{
				final dx = (px + 0.5) / (w * 0.5) - 1;
				final dy = (py + 0.5) / (h * 0.5) - 1;
				final f = Math.max(0, Math.min(1, (1.05 - Math.sqrt(dx * dx + dy * dy)) / 0.55));
				final i = py * w + px;
				pixels[i] = (Std.int(((pixels[i] >> 24) & 0xFF) * f * f * (3 - 2 * f)) << 24) | (pixels[i] & 0xFFFFFF);
			}
		}
		face.setVector(face.rect, pixels);
		return face;
	}

	static function _shader(name:String):ErrorHandledRuntimeShader
	{
		if (!ClientPrefs.data.shaders) return null;
		final code = Paths.getTextFromFile('shaders/$name.frag');
		return code != null ? new ErrorHandledRuntimeShader(name, code) : null;
	}

	function _sprite(?bmd:BitmapData, scale:Float = 1, visible:Bool = false):FlxSprite
	{
		final spr = new FlxSprite();
		if (bmd != null) spr.loadGraphic(bmd);
		spr.antialiasing = false;
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		spr.visible = visible;
		add(spr);
		return spr;
	}

	function _statix(bmd:BitmapData):FlxSprite
	{
		final spr = _sprite();
		spr.frames = bmd != null ? FlxAtlasFrames.fromSparrow(bmd, Paths.getTextFromFile('images/statix.xml')) : Paths.getSparrowAtlas('statix');
		spr.animation.addByPrefix('idle', 'idle', 44, true);
		spr.animation.play('idle');
		spr.setGraphicSize(FlxG.width, FlxG.height);
		spr.updateHitbox();
		return spr;
	}

	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;
		super.create();
		persistentUpdate = true;
		Mods.currentModDirectory = 'FATAL';
		FlxG.sound.music?.stop();
		FlxG.mouse.visible = false;
		if (_scene == TRANSMISSION) _createFile();

		_sprite(new BitmapData(FlxG.width, FlxG.height, false, 0xFF000000), 1, true);
		_matrixShader = _shader('fatal');
		_matrix = _sprite(new BitmapData(FlxG.width, FlxG.height, false, 0xFF000000));
		_matrix.shader = _matrixShader;
		_white = _sprite(_vignette());
		_white.setGraphicSize(FlxG.width, FlxG.height);
		_white.updateHitbox();
		_white.antialiasing = true;

		_face = _sprite(_fadedFace(), 2);
		_face.color = 0xFF000000;
		_whiteEyes = _sprite(Paths.getBitmapData('assets/exe/access/fatal/whiteeyes.png'), 2);
		final eye = Paths.getBitmapData('assets/exe/access/fatal/eye.png');
		for (tint in [0xFF30FF60, 0xFFFF3030])
		{
			final split = _sprite(eye);
			split.color = tint;
			split.blend = BlendMode.ADD;
			split.alpha = 0.55;
			_starSplit.push(split);
		}
		_star = _sprite(eye);

		_fileIcon = _sprite(Paths.getBitmapData('assets/exe/access/fatal/fileicon.png'));
		_fileText = new FlxText(0, 0, 0, 'ContainFatalError.cnt', 26);
		_fileText.setFormat(Paths.font('Windows Regular.ttf'), 26, 0xFF333333, LEFT);
		_fileText.visible = false;
		add(_fileText);

		_redNoise = _statix(null);
		_grayNoise = _statix(_grayStatix());

		_decimate = _shader('decimate');
		_smear = _shader('smear');
		_pseudo = _shader('pseudo');
		_decimate?.setFloat('colorize', 0.3);
		_decimate?.setFloat('speed', 1);
		_decimate?.setFloat('scale', 1);
		final filters:Array<BitmapFilter> = [for (sh in [_smear, _decimate, _pseudo]) if (sh != null) new ShaderFilter(sh)];
		FlxG.camera.filters = filters;

		_buildTimeline();
	}

	function _at(time:Float, run:Void->Void):Void
		_keys.push({at: time, run: run});

	function _buildTimeline():Void
	{
		var end = 0.0;
		if (_scene == TRANSMISSION)
		{
			final track = _sound('assets/exe/access/fatal/fatalvoicelines.ogg');
			_track = track != null ? FlxG.sound.play(track) : null;
			end = 50.9;

			_at(0.75, () -> _showBox(_line("finally.", '', 0, 0, 0.26, 0.65, 0.48, 0.28)));
			_at(2.2, () -> _noise(1));
			_at(3.4, _showStar);
			final starts = [4.4, 8.1, 11.25, 16.8, 19.3, 22.3, 25.4, 27.3, 32.7, 34.8, 39.0, 40.7, 41.9, 43.8];
			final lines = _script(TRANSMISSION);
			for (i in 0...lines.length)
			{
				final line = lines[i];
				_at(starts[i], () -> _playLine(line, null));
			}
			for (time in [10.6, 15.5, 47.2]) _at(time, () -> _noise(1));
			for (time in [32.0, 40.4]) _at(time, () -> _noise(2));
			for (time in [31.4, 41.25]) _at(time, () -> {
				_clearBox();
				_setFile(0);
			});
			_at(end - 1.8, () -> _startMelt(1.8));
		}
		else if (_scene == GRANTED)
		{
			final track = _sound('assets/exe/access/fatal/granted.ogg');
			_track = track != null ? FlxG.sound.play(track) : null;
			_at(0, () -> _noise(1));
			_at(0.02, _showStar);
			final lines = _script(GRANTED);
			final starts = [0.05, 2.0, 3.1];
			for (i in 0...lines.length)
			{
				final line = lines[i];
				_at(starts[i], () -> _playLine(line, null));
			}
			var t = 3.35;
			while (t < 8.0)
			{
				_at(t, _errorBurst);
				t += 0.32 - 0.24 * (t - 3.35) / 4.65;
			}
			_at(6.6, () -> _startMelt(1.4));
			_at(8.0, () -> {
				_clearErrors();
				_noise(1);
			});
			_at(8.4, _descend);
			end = 10.2;
		}
		else if (_scene == DENIED)
		{
			final track = _sound('assets/exe/access/fatal/denied.ogg');
			_track = track != null ? FlxG.sound.play(track) : null;
			_at(0, () -> _noise(1));
			_at(0.02, _showStar);
			final lines = _script(DENIED);
			final starts = [0.03, 0.62, 1.97, 7.03];
			for (i in 0...lines.length)
			{
				final line = lines[i];
				_at(starts[i], () -> _playLine(line, null));
			}
			_at(6.5, () -> _noise(2));
			final bye = 'GOOD BYEEEEEEIJRIJEGJIEJGJGEGI';
			for (n in 8...bye.length + 1)
			{
				final text = bye.substr(0, n);
				final hard = n > 13;
				_at(hard ? 9.0 + (n - 13) * 0.065 : 7.68 + (n - 8) * 0.26, () -> _byeText(text, hard));
			}
			_at(9.2, () -> _startMelt(1));
			_at(10.16, _powerOff);
			end = 12.2;
		}
		else
		{
			_at(0, () -> _noise(1));
			_at(0.7, _showStar);
			end = 1.6;
			for (line in _script(_scene))
			{
				if (line.noise > 0)
				{
					final kind = line.noise;
					_at(end, () -> _noise(kind));
					end += 0.5;
				}
				final voice = _sound('assets/exe/access/fatal/voices/${line.sound}.ogg');
				_at(end, () -> _playLine(line, voice));
				end += voice != null ? voice.length / 1000 + 0.5 : line.dur;
			}
			_at(end, () -> {
				_voice?.stop();
				_noise(1);
				if (_scene != GRANTED) _startMelt(1);
			});
			end += 1;
		}
		_at(end, _end);
		_keys.sort((a, b) -> a.at < b.at ? -1 : (a.at > b.at ? 1 : 0));
	}

	function _errorBurst():Void
	{
		for (_ in 0...FlxG.random.int(1, 2)) _spawnError();
		_dec = Math.max(_dec, FlxG.random.float(0.5, 1));
		_smearAmt = Math.max(_smearAmt, FlxG.random.float(0.3, 0.8));
		_smear?.setFloat('angle', FlxG.random.float(0, 1));
		if (FlxG.random.bool(35)) _flash = FlxG.random.float(0.05, 0.12);
		FlxG.camera.shake(FlxG.random.float(0.004, 0.012), 0.15);
	}

	function _spawnError():Void
	{
		if (_errorArt == null)
			_errorArt = [for (n in ['errsorry', 'errok']) glitchStrip(Paths.getBitmapData('assets/exe/access/fatal/cutscene/$n.png'))];
		final art = _errorArt[FlxG.random.int(0, 1)];
		final spr = new FlxSprite().loadGraphic(art, true, Std.int(art.width / 4), art.height);
		spr.animation.add('in', [0, 1, 2, 3], 12, false);
		spr.animation.play('in');
		spr.antialiasing = false;
		final s = FlxG.random.float(1.5, 3);
		spr.scale.set(s, s);
		spr.updateHitbox();
		spr.setPosition(FlxG.random.float(-0.1, 0.85) * FlxG.width, FlxG.random.float(-0.05, 0.85) * FlxG.height);
		add(spr);
		_errors.push(spr);
	}

	function _clearErrors():Void
	{
		for (e in _errors)
		{
			remove(e, true);
			e.destroy();
		}
		_errors.resize(0);
	}

	function _descend():Void
	{
		_redLine = false;
		_restoreWindow();
		FlxTween.tween(FlxG.camera.scroll, { y: FlxG.height * 1.1 }, 1.6, { ease: FlxEase.quadIn });
	}

	function _byeText(text:String, hard:Bool):Void
	{
		if (_box == null) return;
		final chars = text.split('');
		if (hard) for (i in 5...chars.length) if (FlxG.random.bool(15)) chars[i] = String.fromCharCode(FlxG.random.int(65, 90));
		_setBoxText(chars.join(''));
		_boxText.offset.x = hard ? FlxG.random.int(-6, 6) : 0;
		_box.animation.frameIndex = hard ? FlxG.random.int(0, 2) : 3 - FlxG.random.int(0, 1);
		_dec = Math.max(_dec, hard ? 1 : 0.6);
		_smearAmt = Math.max(_smearAmt, hard ? 0.9 : 0.5);
		_smear?.setFloat('angle', FlxG.random.float(0, 1));
		FlxG.camera.shake(hard ? 0.015 : 0.007, 0.12);
		if (!hard) return;
		_flash = FlxG.random.float(0.03, 0.08);
		if (FlxG.random.bool(45)) _spawnError();
	}

	function _powerOff():Void
	{
		_restoreWindow();
		_redLine = false;
		FlxG.camera.stopFX();
		_off = 0;
		#if (sys && !mobile && !mac)
		try
		{
			if (FileSystem.exists(filePath())) FileSystem.deleteFile(filePath());
			FileSystem.deleteDirectory(folderPath());
		}
		catch (e:Dynamic) {}
		#end
	}

	function _updateOff(elapsed:Float):Void
	{
		_off += elapsed;
		final screen = FlxG.camera.flashSprite;
		screen.scaleY = _off < 0.09 ? 1 - 0.995 * FlxEase.quadIn(_off / 0.09) : 0.005;
		screen.scaleX = Math.max(0.004, 1 - FlxEase.quadIn(Math.max(0, Math.min(1, (_off - 0.09) / 0.2))));
		final glow = 255 * Math.min(1, _off / 0.06);
		screen.transform.colorTransform = new ColorTransform(1, 1, 1, Math.max(0, Math.min(1, 1 - (_off - 0.3) / 0.35)), glow, glow, glow, 0);
	}

	function _startMelt(time:Float):Void
	{
		_meltSpeed = 2.6 / time;
		_melt = 0;
	}

	function _showStar():Void
	{
		_setNoise(0);
		_starGrow = 0;
		_placeStar(false);
		_star.visible = true;
		_matrix.visible = _matrixShader != null;
	}

	function _noise(kind:Int):Void
	{
		_clearBox();
		_setFile(0);
		_setNoise(kind);
	}

	function _playLine(line:FatalLine, voice:Sound):Void
	{
		_setNoise(0);
		_redLine = line.style == 1;
		_matrix.visible = _matrixShader != null && line.bg == 0;
		_dec = Math.max(_dec, _redLine ? 0.9 : 0.45);
		_smearAmt = _redLine ? 0.7 : 0.4;
		_smear?.setFloat('angle', FlxG.random.float(0, 1));
		_bright = _redLine ? 0.9 : 0.6;
		if (_redLine) FlxG.camera.shake(0.006, 0.3);
		_white.visible = line.bg == 1;
		_star.visible = line.star;
		_placeStar(_redLine);
		if (line.face && _reveal < 0) _reveal = 0;
		_setFile(line.file);
		_showBox(line);

		_voice?.stop();
		_voice = voice != null ? FlxG.sound.play(voice) : null;
	}

	function _placeStar(red:Bool):Void
	{
		_starCX = FlxG.width * 0.5 - _face.width * 0.5 + 445;
		_starCY = FlxG.height * (red ? 0.62 : 0.48);
	}

	function _setNoise(kind:Int):Void
	{
		_noiseKind = kind;
		_grayNoise.visible = kind == 2;
		if (kind == 0) return;
		_redLine = false;
		_dec = Math.max(_dec, 0.6);
		_smearAmt = 0.5;
		_white.visible = _star.visible = false;
	}

	function _setFile(size:Int):Void
	{
		_fileIcon.visible = _fileText.visible = size > 0;
		if (size == 0) return;
		final big = size == 2;
		_fileText.size = big ? 34 : 26;
		_fileIcon.scale.set(big ? 2.2 : 1.6, big ? 2.2 : 1.6);
		_fileIcon.updateHitbox();
		final left = FlxG.width * (big ? 0.2 : 0.26);
		final midY = FlxG.height * (big ? 0.48 : 0.5);
		_fileIcon.setPosition(left, midY - _fileIcon.height * 0.5);
		_fileText.setPosition(left + _fileIcon.width + 12, midY - _fileText.height * 0.5);
	}

	function _showBox(line:FatalLine):Void
	{
		_clearBox();
		_boxStyle = line.style;
		_box = glitchBox(Std.int(FlxG.width * line.w), Std.int(FlxG.height * line.h), FlxG.width * line.x, FlxG.height * line.y, line.style);
		add(_box);
		_setBoxText(line.text);
	}

	function _setBoxText(text:String):Void
	{
		final red = _boxStyle == 1;
		final spr = textSprite(text, _boxStyle == 2 ? 22 : (red ? 15 : 12), Std.int((_box.width - 40) / 2), red);
		final bar = barHeight(_boxStyle);
		spr.setPosition(_box.x + (_box.width - spr.width) * 0.5, _box.y + bar + (_box.height - bar - spr.height) * 0.5);
		spr.visible = _boxText != null && _boxText.visible;
		if (_boxText != null)
		{
			remove(_boxText, true);
			_boxText.destroy();
		}
		_boxText = spr;
		add(spr);
	}

	function _clearBox():Void
	{
		for (spr in [_box, _boxText])
		{
			if (spr == null) continue;
			remove(spr, true);
			spr.destroy();
		}
		_box = _boxText = null;
	}

	function _updateFace(elapsed:Float):Void
	{
		if (_reveal >= 0) _reveal = Math.min(1, _reveal + elapsed / 0.8);
		final r = _reveal < 0 ? 0 : 1 - Math.pow(1 - _reveal, 3);
		final bob = Math.sin(_time * 1.1) * 6;
		final faceX = _starCX - 445;
		final faceY = _starCY + bob - 351;
		_face.setPosition(faceX, faceY);
		_whiteEyes.setPosition(faceX + 96, faceY + 202);
		_face.visible = _whiteEyes.visible = _star.visible;
		final shade = Std.int(122 * r);
		_face.color = 0xFF000000 | (shade << 16) | (Std.int(shade * 0.45) << 8) | Std.int(shade * 0.45);
		_whiteEyes.alpha = 0.75 + 0.25 * r;

		_starGrow = Math.min(1, _starGrow + elapsed * 1.6);
		final s = (1 - Math.pow(1 - _starGrow, 3)) * (1 + 0.035 * Math.sin(_time * 5)) * 2;
		_star.scale.set(s, s);
		_star.setPosition(_starCX - _star.width * 0.5, _starCY + bob - _star.height * 0.5);
		for (i in 0..._starSplit.length)
		{
			final split = _starSplit[i];
			split.visible = _star.visible && _redLine;
			split.scale.set(s, s);
			split.setPosition(_star.x + (i == 0 ? -4 : 4) + FlxG.random.float(-1, 1), _star.y);
		}
	}

	function _updateFx(elapsed:Float):Void
	{
		_dec = Math.max(_redLine ? 0.18 : 0, _dec - elapsed * 2.5);
		_smearAmt = Math.max(0, _smearAmt - elapsed * 4);
		_bright = Math.max(0.15, _bright - elapsed * 1.2);
		if (_melt >= 0) _melt += elapsed * _meltSpeed;
		_decimate?.setFloat('amount', _dec);
		_decimate?.setFloat('iTime', _time);
		_smear?.setFloat('amount', _smearAmt);
		_pseudo?.setFloat('sort', Math.max(0, _melt));
		_pseudo?.setFloat('iTime', _time);
		_matrixShader?.setFloat('brightint', _bright);
		_matrixShader?.setFloat('iTime', _time);

		_flash -= elapsed;
		if (_noiseKind == 0 && _star.visible && FlxG.random.bool(1.2)) _flash = 0.06;
		_redNoise.visible = _noiseKind == 1 || _flash > 0;
	}

	function _updateWindow(elapsed:Float):Void
	{
		final window = openfl.Lib.application.window;
		if (!_redLine || window.fullscreen || window.maximized)
		{
			_restoreWindow();
			return;
		}
		if (!_winMoved)
		{
			_winMoved = true;
			_winHomeX = window.x;
			_winHomeY = window.y;
		}
		_winTimer -= elapsed;
		if (_winTimer > 0) return;
		_winTimer = 0.05;
		window.move(_winHomeX + FlxG.random.int(-10, 10), _winHomeY + FlxG.random.int(-6, 6));
	}

	function _restoreWindow():Void
	{
		if (!_winMoved) return;
		_winMoved = false;
		openfl.Lib.application.window.move(_winHomeX, _winHomeY);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		_time += elapsed;
		_updateFace(elapsed);
		_updateFx(elapsed);
		_updateWindow(elapsed);
		if (_box != null) _boxText.visible = _box.animation.finished;
		for (e in _errors)
		{
			e.offset.x = FlxG.random.int(-3, 3);
			if (e.animation.finished && FlxG.random.bool(6)) e.animation.frameIndex = FlxG.random.int(0, 3);
		}

		if (_off >= 0) _updateOff(elapsed);
		if (_fall != null)
		{
			_fall.update(elapsed);
			return;
		}
		if (_track != null && !_trackStarted)
		{
			_trackWait += elapsed;
			_trackStarted = _track.time > 0 || _trackWait > 1;
		}
		if (_track == null || _trackStarted)
			_clock += elapsed;
		while (_keyIndex < _keys.length && _clock >= _keys[_keyIndex].at)
			_keys[_keyIndex++].run();
	}

	override function destroy()
	{
		_restoreWindow();
		super.destroy();
	}

	function _end():Void
	{
		switch (_scene)
		{
			case TRANSMISSION:
				#if (mobile || mac)
				_toMobileAccess(true);
				#elseif sys
				Sys.exit(0);
				#else
				Mods.loadTopMod();
				FlxG.switchState(() -> new EXETitle());
				#end
			case DENIED:
				Sys.exit(0);
			case GRANTED:
				_playCutscene();
			default:
				#if (mobile || mac)
				_toMobileAccess(false);
				#else
				_backToMenu();
				#end
		}
	}

	#if (mobile || mac)
	function _toMobileAccess(first:Bool):Void
	{
		if (first)
		{
			FlxG.save.data.fatalMobileSeen = true;
			FlxG.save.flush();
		}
		_restoreWindow();
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		FlxG.switchState(() -> new FatalAccessMobile());
	}
	#end

	function _backToMenu():Void
	{
		_restoreWindow();
		Mods.loadTopMod();
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
		FlxG.sound.music.pitch = 1;
		FlxG.switchState(() -> new EXEMenu());
	}

	function _playCutscene():Void
	{
		_restoreWindow();
		_melt = -1;
		_redLine = false;
		FlxG.camera.filters = [];
		FlxTween.cancelTweensOf(FlxG.camera.scroll);
		FlxG.camera.scroll.set(0, 0);
		_setNoise(0);
		_clearBox();
		_clearErrors();
		_track?.stop();
		forEach(b -> b.visible = false);
		final track = _sound('assets/exe/access/fatal/cutscene/fatalcutscene.ogg');
		_fall = new FatalFall(this, track != null ? FlxG.sound.play(track) : null, _launchSong);
	}

	function _launchSong():Void
	{
		if (_launched) return;
		_launched = true;
		try
		{
			Mods.currentModDirectory = 'FATAL';
			Song.loadFromJson('fatality', 'fatality');
			backend.SongProgress.markOpened('fatality');
			EXEMenu.secretSong = true;
			PlayState.storyPlaylist = ['fatality'];
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = 0;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
		}
		catch (e:Dynamic)
		{
			_backToMenu();
		}
	}
}
		
