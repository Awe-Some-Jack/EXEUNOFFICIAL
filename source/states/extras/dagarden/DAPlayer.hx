package states.extras.dagarden;

import backend.Paths;
import backend.Mods;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import sys.FileSystem;

class DAPlayer extends FlxGroup
{
	public static inline final SEEK_SECONDS:Float = 5.0;
	
	static inline final VOCALS_VOL:Float = 1.0;
	static inline final VOCALS_OPP_VOL:Float = 1.0;
	static inline final DISK_MAX_SPEED:Float = 45.0;
	static inline final DISK_ACCEL:Float = 6.0;
	static inline final DISK_DECEL:Float = 22.0;
	static inline final DISK_DRAG_SEEK_RATE:Float = 0.12;
	static inline final COMPOSER_CYCLE_TIME:Float = 10.0;
	static inline final SCRATCH_VEL_MAX:Float = 0.25;
	static inline final SCRATCH_PITCH_MIN:Float = 0.30;
	static inline final SCRATCH_PITCH_LERP:Float = 18.0;
	static inline final SCRATCH_RECOVER_SPEED:Float = 6.0;

	public var box:FlxSprite;
	public var disk:FlxSprite;
	public var bar:FlxSprite;
	public var play:FlxSprite;

	private var barProgress:FlxSprite;
	private var barKnob:FlxSprite;
	private var barInnerX:Float;
	private var barInnerY:Float;
	private var barInnerW:Float;
	private var barInnerH:Float;
	private var _barClipRect:flixel.math.FlxRect;

	private var timeTxt:FlxText;
	private var songNameTxt:FlxText;
	private var composerTxt:FlxText;

	public var sub:DASub = null;
	
	private var diskSpeed:Float = 0.0;
	private var diskDragging:Bool = false;
	private var diskDragAngle:Float = 0.0;
	private var _diskDragVel:Float = 0.0;

	private var _barDragging:Bool = false;
	private var _barLastRatio:Float = 0.0;
	private var _barDragVel:Float = 0.0;
	
	private var instSound:FlxSound = null;
	private var vocalsSounds:Array<FlxSound> = [];
	private var oppVocalsSounds:Array<FlxSound> = [];

	private var _loadedSong:String = '';
	private var _loadedMod:String = '';

	public var vocalsEnabled:Bool = true;
	public var isPlaying:Bool = false;
	public var isLoading:Bool = false;
	public var loopEnabled:Bool = false;

	private var audioFadeTarget:Float = 1.0;
	private var audioFadeSpeed:Float = 0.0;

	private var pitchDown:Bool = false;
	private var pitchUp:Bool = false;
	private var pitchCurrent:Float = 1.0;
	private var pitchSpeed:Float = 0.0;
	private var onPitchDone:Void->Void = null;

	private var _scratchPitch:Float = 1.0;
	private var _isScratchActive:Bool = false;
	
	private var _seekPending:Bool = false;
	private var _seekTargetMs:Float = 0.0;
	private var _seekWasPlaying:Bool = false;
	
	private var _pendingLoad:Bool = false;
	private var _loadGeneration:Int = 0;

	private var currentCredits:Array<String> = [];
	private var composerIndex:Int = 0;
	private var composerTimer:Float = 0.0;

	private var _originalTitle:String = '';
	private var _lastTitleSec:Int = -1;

	public function new()
	{
		super();
		_originalTitle = lime.app.Application.current.window.title;
		_buildUI();
	}

	public function restoreWindowTitle():Void
	{
		lime.app.Application.current.window.title = _originalTitle;
	}

	private function _buildUI():Void
	{
		final SCALE = 0.34;
		final BX:Float = 620;
		final BY:Float = 620;
		
		box = _makeSprite(565, 100, "box.png", SCALE);
		disk = _makeSprite(743, 245, "disk.png", 0.32);

		final barBmp = openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/bar.png");
		final bW = barBmp.width * SCALE;
		final bH = barBmp.height * SCALE;
		
		barInnerX = BX + (15 / 1642) * bW;
		barInnerY = BY + (15 / 96) * bH;
		barInnerW = ((1642 - 32) / 1642) * bW;
		barInnerH = ((96 - 29) / 96) * bH;
		
		barProgress = new FlxSprite(barInnerX, barInnerY);
		barProgress.makeGraphic(Math.ceil(barInnerW), Math.ceil(barInnerH), 0xFFCC0000);
		barProgress.antialiasing = false;
		
		_barClipRect = new flixel.math.FlxRect(0, 0, 0, barInnerH);
		barProgress.clipRect = _barClipRect;
		add(barProgress);

		bar = _makeSprite(BX, BY, "bar.png", SCALE);
		play = _makeSprite(616, 478, "play.png", SCALE);

		final knobR = Std.int(barInnerH * 0.9);
		barKnob = new FlxSprite(0, 0);
		barKnob.makeGraphic(knobR * 2, knobR * 2, 0x00000000);
		_drawCircle(barKnob, knobR, 0xFFCC0000);
		barKnob.alpha = 0;
		add(barKnob);
		
		timeTxt = new FlxText(BX + 10, BY + bH + 7, Std.int(bW), '0:00', 44);
		timeTxt.setFormat('assets/fonts/NiseSegaSonic.TTF', 44, FlxColor.BLACK, CENTER);
		timeTxt.scale.set(0.5, 0.5);
		timeTxt.updateHitbox();
		timeTxt.antialiasing = ClientPrefs.data.antialiasing;
		add(timeTxt);

		songNameTxt = new FlxText(625, 132, 1120, '', 120);
		songNameTxt.setFormat('assets/fonts/NiseSegaSonic.TTF', 120, FlxColor.BLACK, CENTER);
		songNameTxt.letterSpacing = 2;
		songNameTxt.wordWrap = false;
		songNameTxt.scale.set(0.5, 0.5);
		songNameTxt.updateHitbox();
		songNameTxt.antialiasing = ClientPrefs.data.antialiasing;
		add(songNameTxt);

		composerTxt = new FlxText(625, 196, 1120, '', 36);
		composerTxt.setFormat('assets/fonts/NiseSegaSonic.TTF', 36, FlxColor.BLACK, CENTER);
		composerTxt.letterSpacing = 6;
		composerTxt.wordWrap = false;
		composerTxt.scale.set(0.5, 0.5);
		composerTxt.updateHitbox();
		composerTxt.antialiasing = ClientPrefs.data.antialiasing;
		add(composerTxt);

	}

	private function _drawCircle(s:FlxSprite, r:Int, color:FlxColor):Void
	{
		final size = r * 2;
		final bmp = new openfl.display.BitmapData(size, size, true, 0x00000000);
		final shape = new openfl.display.Shape();
		shape.graphics.beginFill(color, 1.0);
		shape.graphics.drawCircle(r, r, r - 1);
		shape.graphics.endFill();

		final m = new openfl.geom.Matrix();
		bmp.draw(shape, m, null, null, null, true);
		s.pixels = bmp;
	}

	private function _makeSprite(x:Float, y:Float, file:String, scale:Float):FlxSprite
	{
		final s = new FlxSprite(x, y);
		s.loadGraphic(openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/" + file));
		s.scale.set(scale, scale);
		s.updateHitbox();
		s.antialiasing = ClientPrefs.data.antialiasing;
		add(s);
		return s;
	}

	public function setSongInfo(songName:String, credits:Array<String>):Void
	{
		final display = songName.replace('-', ' ').toUpperCase();
		songNameTxt.text = display;
		var size = 120;
		songNameTxt.size = size;

		while (songNameTxt.textField.textWidth > 1080 && size > 20)
			songNameTxt.size = --size;

		currentCredits = credits != null ? credits : [];
		composerIndex = 0;
		composerTimer = 0.0;
		
		if (composerTxt != null)
		{
			composerTxt.alpha = 1;
			composerTxt.text = currentCredits.length > 0 ? 'BY ' + currentCredits[0].toUpperCase() : '';
		}
	}

	public function playAudio(song:String, mod:String):Void
	{
		if (isLoading && _loadedSong == song && _loadedMod == mod) return;
		
		if (instSound != null && _loadedSong == song && _loadedMod == mod)
		{
			instSound.resume();
			for (v in vocalsSounds) v.resume();
			
			_startPitchUp();

			audioFadeTarget = 1.0;
			audioFadeSpeed = 12.0;
			
			isPlaying = true;
			
			#if DISCORD_ALLOWED
			DiscordClient.changePresence("In the DA Garden", 'Listening to ${songNameTxt.text}', null, true, FlxMath.bound(instSound.time, 0, instSound.length));
			#end

			return;
		}

		stop();
		_loadAsync(song, mod);
	}

	public function pause():Void
	{
		isPlaying = false;
		_startPitchDown(() -> {
			instSound?.pause();
			for (v in vocalsSounds) v.pause();
		});
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the DA Garden", 'Listening to ${songNameTxt.text} (Paused)', null, true, FlxMath.bound(instSound?.time ?? 0, 0, instSound?.length ?? 0));
		#end
	}

	public function detachSounds():Void
	{
		if (instSound != null) FlxG.sound.list.remove(instSound, false);
		for (v in vocalsSounds) FlxG.sound.list.remove(v, false);
	}

	public function reattachSounds():Void
	{
		if (instSound != null && !FlxG.sound.list.members.contains(instSound))
			FlxG.sound.list.add(instSound);
		for (v in vocalsSounds)
			if (!FlxG.sound.list.members.contains(v)) FlxG.sound.list.add(v);
	}

	public function stop():Void
	{
		audioFadeSpeed = 0;
		_seekPending = false;
		_scratchPitch = 1.0;
		_isScratchActive = false;
		++_loadGeneration;
		_pendingLoad = false;
		isLoading = false;
		_destroyAudio();
	}

	public function fadeOutAndStop():Void
	{
		if (instSound == null) return;
		isPlaying = false;
		_startPitchDown(() -> {
			audioFadeTarget = 0.0;
			audioFadeSpeed = 12.0;
		});
	}

	public function setVolume(vol:Float):Void
	{
		audioFadeTarget = vol;
		audioFadeSpeed = 8.0;
	}

	public function seek(deltaSec:Float):Void
	{
		if (instSound == null || instSound.length <= 0) return;
		_doCleanSeek(FlxMath.bound(instSound.time + deltaSec * 1000, 0, instSound.length - 100));
	}

	public function seekTo(ms:Float):Void
	{
		if (instSound == null || instSound.length <= 0) return;
		_doCleanSeek(FlxMath.bound(ms, 0, instSound.length - 100));
	}

	public function toggleVocals():Void
	{
		vocalsEnabled = !vocalsEnabled;
		_applyVocalVolume(instSound?.volume ?? 1.0);
	}

	public function toggleLoop():Void
	{
		loopEnabled = !loopEnabled;
		if (instSound != null)
		{
			instSound.looped = loopEnabled;
		}
	}

	public inline function hasAudio():Bool return instSound != null;
	public inline function currentTime():Float return instSound != null ? instSound.time : -1.0;
	public inline function totalTime():Float return instSound != null ? instSound.length : 0.0;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		_updateComposerCycle(elapsed);
		_updateDiskSpin(elapsed);
		_updateAudioFade(elapsed);
		_updatePitchAnimation(elapsed);
		_updateScratchPitch(elapsed);
		_checkPendingLoad();
		_applyPendingSeek();
		_checkSongEnd();
		_updateProgressBar();
		_handleDiskMouse(elapsed);
		_handleBarMouse(elapsed);
		_updateWindowTitle();
		_resyncVocals();
	}

	private function _updateScratchPitch(elapsed:Float):Void
	{
		if (instSound == null) return;
		final dragging = diskDragging || _barDragging;

		if (dragging)
		{
			_isScratchActive = true;
			var velNorm:Float;
			
			if (diskDragging)
			{
				velNorm = FlxMath.bound(Math.abs(_diskDragVel) / elapsed / SCRATCH_VEL_MAX, 0, 1);
			}
			else
			{
				velNorm = FlxMath.bound(Math.abs(_barDragVel) / elapsed / 0.5, 0, 1);
			}

			final targetPitch = FlxMath.lerp(1.0, SCRATCH_PITCH_MIN, velNorm);
			_scratchPitch += (targetPitch - _scratchPitch) * SCRATCH_PITCH_LERP * elapsed;
		}
		else if (_isScratchActive)
		{
			_scratchPitch += (1.0 - _scratchPitch) * SCRATCH_RECOVER_SPEED * elapsed;
			if (Math.abs(_scratchPitch - 1.0) < 0.01)
			{
				_scratchPitch = 1.0;
				_isScratchActive = false;
			}
		}

		if (_isScratchActive || _scratchPitch != 1.0)
			_applyPitch(pitchCurrent * _scratchPitch);
	}

	private function _doCleanSeek(targetMs:Float):Void
	{
		if (instSound == null) return;
		_seekWasPlaying = instSound.playing;
		_seekTargetMs = targetMs;
		_seekPending = true;
		
		if (_seekWasPlaying) instSound.pause();
		for (v in vocalsSounds) if (v.playing) v.pause();
	}

	private function _applyPendingSeek():Void
	{
		if (!_seekPending || instSound == null) return;
		_seekPending = false;
		
		try { instSound.time = _seekTargetMs; } catch(_:Dynamic) {}
		
		for (v in vocalsSounds) 
		{ 
			try { v.time = _seekTargetMs; } catch(_:Dynamic) {} 
		}
		
		if (_seekWasPlaying)
		{
			instSound.resume();
			for (v in vocalsSounds) v.resume();
		}
	}

	private function _updateComposerCycle(elapsed:Float):Void
	{
		if (currentCredits.length <= 1 || composerTxt == null) return;
		
		composerTimer += elapsed;
		if (composerTimer < COMPOSER_CYCLE_TIME) return;
		
		composerTimer = 0;
		composerIndex = (composerIndex + 1) % currentCredits.length;
		final next = 'BY ' + currentCredits[composerIndex].toUpperCase();

		FlxTween.cancelTweensOf(composerTxt);
		FlxTween.tween(composerTxt, {alpha: 0.0}, 0.3, {
			ease: FlxEase.quadOut, 
			onComplete: (_) -> {
				composerTxt.text = next;
				FlxTween.tween(composerTxt, {alpha: 1.0}, 0.4, {ease: FlxEase.quadIn});
			}
		});
	}

	private function _updateDiskSpin(elapsed:Float):Void
	{
		if (diskDragging || disk == null) return;

		final target = isPlaying ? DISK_MAX_SPEED : 0.0;
		final rate = isPlaying ? DISK_ACCEL : DISK_DECEL;
		diskSpeed += (target - diskSpeed) * rate * elapsed;
		disk.angle += elapsed * diskSpeed;
	}

	private function _handleDiskMouse(elapsed:Float):Void
	{
		if (disk == null) return;

		final mx = FlxG.mouse.x;
		final my = FlxG.mouse.y;
		final cx = disk.x + disk.width * 0.5;
		final cy = disk.y + disk.height * 0.5;
		
		if (FlxG.mouse.justPressed)
		{
			final dist = Math.sqrt((mx - cx) * (mx - cx) + (my - cy) * (my - cy));
			if (dist <= disk.width * 0.5)
			{
				diskDragging = true;
				diskDragAngle = Math.atan2(my - cy, mx - cx);
				_diskDragVel = 0.0;
			}
		}
		
		final wasDragging = diskDragging;
		if (!FlxG.mouse.pressed) diskDragging = false;
		
		if (wasDragging && !diskDragging)
			diskSpeed = (_diskDragVel / elapsed) * (180 / Math.PI);

		if (!diskDragging) 
		{ 
			_diskDragVel = 0.0; 
			return;
		}
		
		if (instSound == null || instSound.length <= 0) return;

		var angle = Math.atan2(my - cy, mx - cx);
		var da = angle - diskDragAngle;
		
		if (da > Math.PI) da -= Math.PI * 2;
		if (da < -Math.PI) da += Math.PI * 2;
		
		diskDragAngle = angle;
		_diskDragVel = da;
		
		if (da == 0) return;

		disk.angle += da * (180 / Math.PI);
		_doCleanSeek(FlxMath.bound(instSound.time + da * DISK_DRAG_SEEK_RATE * 1000, 0, instSound.length - 100));
	}

	private function _handleBarMouse(elapsed:Float):Void
	{
		if (instSound == null || diskDragging) return;
		
		final mx = FlxG.mouse.x;
		final my = FlxG.mouse.y;
		final overBar = mx >= barInnerX && mx <= barInnerX + barInnerW
					 && my >= barInnerY && my <= barInnerY + barInnerH;
					 
		if (FlxG.mouse.justPressed && overBar)
		{
			_barDragging = true;
			_barLastRatio = FlxMath.bound((mx - barInnerX) / barInnerW, 0, 1);
			_barDragVel = 0.0;
			_doCleanSeek(_barLastRatio * instSound.length);
		}

		if (!FlxG.mouse.pressed) 
		{ 
			_barDragging = false; 
			_barDragVel = 0.0; 
			return;
		}
		
		if (!_barDragging) return;

		final ratio = FlxMath.bound((mx - barInnerX) / barInnerW, 0, 1);
		final dRatio = ratio - _barLastRatio;
		_barDragVel = dRatio;
		_barLastRatio = ratio;

		if (Math.abs(dRatio) < 0.0005) return;
		_doCleanSeek(ratio * instSound.length);
	}

	private function _updateProgressBar():Void
	{
		if (barProgress == null) return;

		final total = instSound != null ? instSound.length : 0.0;
		final elapsed = instSound != null ? instSound.time : 0.0;
		final progress = total > 0 ? FlxMath.bound(elapsed / total, 0, 1) : 0.0;

		_barClipRect.width = barInnerW * progress;
		barProgress.clipRect = _barClipRect;
		
		if (barKnob != null)
		{
			final knobX = barInnerX + barInnerW * progress - barKnob.width * 0.5;
			final knobY = barInnerY + barInnerH * 0.5 - barKnob.height * 0.5;
			barKnob.setPosition(knobX, knobY);
			
			final targetAlpha:Float = _barDragging ? 1.0 : 0.0;
			barKnob.alpha += (targetAlpha - barKnob.alpha) * 0.25;
		}

		if (timeTxt != null)
		{
			var remaining = Std.int((total - elapsed) / 1000);
			if (remaining < 0) remaining = 0;
			timeTxt.text = Std.int(remaining / 60) + ':' + (remaining % 60 < 10 ? '0' : '') + remaining % 60;
		}
	}

	private function _updateWindowTitle():Void
	{
		if (instSound == null)
		{
			if (_lastTitleSec != -1)
			{
				_lastTitleSec = -1;
				lime.app.Application.current.window.title = _originalTitle;
			}
			return;
		}

		final ms = Std.int(instSound.time);
		final secs = Std.int(ms / 1000);
		if (secs == _lastTitleSec) return;
		
		_lastTitleSec = secs;

		final song = _loadedSong.replace('-', ' ').toUpperCase();
		final state = isPlaying ? 'PLAY' : 'PAUSE';
		final mode = vocalsEnabled ? 'NORMAL' : 'INST';
		final mins = Std.int(secs / 60);
		final s = secs % 60;
		
		lime.app.Application.current.window.title = '[$state] $song | $mode | $mins:${s < 10 ? "0" : ""}$s';
	}

	private function _updateAudioFade(elapsed:Float):Void
	{
		if (audioFadeSpeed == 0) return;
		
		final cur = instSound != null ? instSound.volume : 0.0;
		final next = cur + (audioFadeTarget - cur) * audioFadeSpeed * elapsed;

		if (instSound != null) instSound.volume = next;
		_applyVocalVolume(next);
		
		if (Math.abs(next - audioFadeTarget) < 0.01)
		{
			if (instSound != null) instSound.volume = audioFadeTarget;
			_applyVocalVolume(audioFadeTarget);
			if (audioFadeTarget <= 0) _destroyAudio();
			audioFadeSpeed = 0;
		}
	}

	private function _applyVocalVolume(base:Float):Void
	{
		for (v in vocalsSounds)
			v.volume = vocalsEnabled ? (oppVocalsSounds.contains(v) ? base * VOCALS_OPP_VOL : base) : 0.0;
	}

	private function _updatePitchAnimation(elapsed:Float):Void
	{
		if (pitchDown && pitchSpeed != 0)
		{
			pitchCurrent += (0.0 - pitchCurrent) * pitchSpeed * elapsed;
			_applyPitch(pitchCurrent * _scratchPitch);
			
			if (pitchCurrent < 0.05)
			{
				pitchDown = false;
				pitchSpeed = 0;
				if (onPitchDone != null) 
				{ 
					onPitchDone();
					onPitchDone = null; 
				}
			}
		}
		else if (pitchUp && pitchSpeed != 0)
		{
			pitchCurrent += (1.0 - pitchCurrent) * pitchSpeed * elapsed;
			_applyPitch(pitchCurrent * _scratchPitch);
			
			if (pitchCurrent > 0.97)
			{
				pitchCurrent = 1.0;
				pitchUp = false;
				pitchSpeed = 0;
				_applyPitch(1.0 * _scratchPitch);
			}
		}
	}

	private inline function _applyPitch(p:Float):Void
	{
		if (instSound != null) instSound.pitch = p;
		for (v in vocalsSounds) v.pitch = p;
	}

	private function _startPitchDown(cb:Void->Void):Void
	{
		pitchUp = false;
		pitchCurrent = 1.0;
		_applyPitch(1.0);
		pitchDown = true;
		pitchSpeed = 4.5;
		onPitchDone = cb;
	}

	private function _startPitchUp():Void
	{
		pitchDown = false;
		onPitchDone = null;
		pitchCurrent = 0.2;
		_applyPitch(pitchCurrent);
		pitchUp = true;
		pitchSpeed = 8.0;
	}

	private function _loadAsync(song:String, mod:String):Void
	{
		_loadedSong = song;
		_loadedMod = mod;
		final prevMod = Mods.currentModDirectory;
		Mods.currentModDirectory = mod;

		final instPath = Paths.instPath(song);
		if (instPath == null || !FileSystem.exists(instPath))
		{
			Mods.currentModDirectory = prevMod;
			return;
		}

		final seen:Array<String> = [];
		final vocPaths:Array<{path:String, isOpp:Bool}> = [];

		for (postfix in [null, 'opponent', 'player'])
		{
			final vp = Paths.voicesPath(song, postfix);
			if (vp == null || !FileSystem.exists(vp)) continue;
			final vpLower = vp.toLowerCase();
			if (seen.contains(vpLower)) continue;
			seen.push(vpLower);
			vocPaths.push({path: vp, isOpp: postfix == 'opponent'});
		}

		final lyricsMod  = mod;
		final lyricsSong = song;
		final lyricsPaths:Array<String> = [];
		if (sub != null)
		{
			final base = lyricsMod != '' ? Paths.mods('$lyricsMod/data/$lyricsSong') : Paths.mods('data/$lyricsSong');
			for (p in ['$base/events.json', '$base/$lyricsSong.json'])
				lyricsPaths.push(p);
		}

		Mods.currentModDirectory = prevMod;
		isLoading = true;
		_pendingLoad = true;
		final gen = ++_loadGeneration;

		final mainThread = sys.thread.Thread.current();
		sys.thread.Thread.create(() -> {
			final inst = openfl.media.Sound.fromFile(instPath);
			final vocs:Array<{snd:openfl.media.Sound, isOpp:Bool}> = [];
			for (v in vocPaths)
			{
				final s = openfl.media.Sound.fromFile(v.path);
				if (s != null) vocs.push({snd: s, isOpp: v.isOpp});
			}

			var lyricsEvs:Array<Dynamic> = null;
			if (sub != null)
			{
				for (p in lyricsPaths)
				{
					if (!FileSystem.exists(p)) continue;
					try
					{
						final json:Dynamic = haxe.Json.parse(sys.io.File.getContent(p));
						final candidate:Array<Dynamic> = cast json.events;
						if (candidate != null && candidate.length > 0) { lyricsEvs = candidate; break; }
					}
					catch(_:Dynamic) {}
				}
			}

			mainThread.sendMessage({inst: inst, vocs: vocs, gen: gen,
				lyricsEvs: lyricsEvs, lyricsMod: lyricsMod, lyricsSong: lyricsSong});
		});
	}

	private function _checkPendingLoad():Void
	{
		if (!_pendingLoad) return;

		final msg = sys.thread.Thread.readMessage(false);
		if (msg == null) return;

		final data:{
			inst:openfl.media.Sound,
			vocs:Array<{snd:openfl.media.Sound, isOpp:Bool}>,
			gen:Int,
			lyricsEvs:Array<Dynamic>,
			lyricsMod:String,
			lyricsSong:String
		} = cast msg;

		if (data.gen != _loadGeneration)
		{
			data.inst?.close();
			for (v in data.vocs) v.snd?.close();
			return;
		}

		_pendingLoad = false;
		isLoading = false;
		if (data.inst == null) return;

		if (sub != null)
			sub.applyLyricsEvents(data.lyricsEvs, data.lyricsSong, data.lyricsMod);

		instSound = FlxG.sound.load(data.inst);
		instSound.looped = loopEnabled;
		instSound.volume = 0.0;

		for (v in data.vocs)
		{
			final snd = FlxG.sound.load(v.snd);
			if (snd == null) continue;
			snd.looped = false;
			vocalsSounds.push(snd);
			if (v.isOpp) oppVocalsSounds.push(snd);
		}

		instSound.play();
		for (v in vocalsSounds) v.play();

		_startPitchUp();
		audioFadeTarget = 1.0;
		audioFadeSpeed = 12.0;
		isPlaying = true;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the DA Garden", 'Listening to ${songNameTxt.text}', null, true, FlxMath.bound(instSound.time, 0, instSound.length));
		#end
	}

	public function onSongEnd():Void
	{
		if (instSound == null) return;
		isPlaying = false;

		instSound.pause();
		instSound.time = 0;
		
		for (v in vocalsSounds)
		{
			if (v == null) continue;
			v.play();
			v.pause();
			v.time = 0;
		}
	}

	private function _checkSongEnd():Void
	{
		if (!isPlaying || instSound == null || instSound.length <= 0) return;
		
		if (instSound.time >= instSound.length - 100 && instSound.playing)
		{
			if (loopEnabled)
			{
				_doCleanSeek(0);
				instSound.play();
				for (v in vocalsSounds) v.play();
			}
			else
			{
				onSongEnd();
			}
		}
	}

	private function _resyncVocals():Void
	{
		if (instSound == null || !instSound.playing || _seekPending) return;
		
		for (v in vocalsSounds)
		{
			if (v?.playing ?? false)
			{
				if (Math.abs(instSound.time - v.time) > 25)
					v.time = instSound.time;
			}
		}
	}

	private function _destroyAudio():Void
	{
		if (instSound != null)
		{
			instSound.stop();
			FlxG.sound.list.remove(instSound, true);
			instSound.destroy();
			instSound = null;
		}
		
		if (vocalsSounds != null)
		{
			for (v in vocalsSounds)
			{
				if (v != null)
				{
					v.stop();
					FlxG.sound.list.remove(v, true);
					v.destroy();
				}
			}
			vocalsSounds = [];
		}
		
		oppVocalsSounds = [];
		isPlaying = false;
		_loadedSong = '';
		_loadedMod = '';
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the DA Garden", null);
		#end
	}

	override public function destroy():Void
	{
		_destroyAudio();
		onPitchDone = null;
		if (composerTxt != null) FlxTween.cancelTweensOf(composerTxt);
		super.destroy();
	}
}