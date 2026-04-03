package gameplay;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import backend.ClientPrefs;
import backend.Conductor;
import backend.StageData;
import objects.Character;
import states.PlayState;
import gameplay.CameraStageHandler;
import psychlua.FunkinLua;

typedef CameraSettings = {
	var mustHitSection:Bool;
	var BFx:Float;
	var BFy:Float;
	var DADx:Float;
	var DADy:Float;
	var GFx:Float;
	var GFy:Float;
	var MiddleCamera:Bool;
	var MiddleX:Float;
	var MiddleY:Float;
	var OverrideZoom:Bool;
	var OGZoom:Float;
	var MiddleZoom:Float;
	var OffsetsBF:Float;
	var OffsetsDAD:Float;
	var OffsetsGF:Float;
	var Angle:Float;
	var DADAngle:Float;
}

class GameplayCamera
{
	public var camFollow:FlxObject;
	public var defaultCamZoom:Float = 1.05;
	public var cameraSpeed:Float = 1;
	public var freezeCamera:Bool = false;
	public var isCameraOnForcedPos:Bool = false;

	public var boyfriendCameraOffset:Array<Float> = [0, 0];
	public var opponentCameraOffset:Array<Float> = [0, 0];
	public var girlfriendCameraOffset:Array<Float> = [0, 0];

	public var customCameraEnabled:Bool = true;

	public var settings:CameraSettings = {
		mustHitSection: true,
		BFx:        0, BFy:        0,
		DADx:       0, DADy:       0,
		GFx:        0, GFy:        0,
		MiddleCamera: false,
		MiddleX:    0, MiddleY:    0,
		OverrideZoom: false,
		OGZoom:     0.7,
		MiddleZoom: 0.6,
		OffsetsBF:  25,
		OffsetsDAD: 25,
		OffsetsGF:  25,
		Angle:      0,
		DADAngle:   0
	};

	public var overrideZoomValue:Float = 1.0;

	private var cameraTwn:FlxTween;
	private var playState:PlayState;

	public var _xeno:Bool          = false;
	public var _sectionZoom:Bool   = false;
	public var _oldHitSection:Bool = false;
	public var _firstone:Bool      = true;
	public var _sexogratisputocom:Bool = false;
	public var _sexitosxd2:Bool    = false;
	public var _targetAlpha:Float  = 1;

	public function new(state:PlayState)
	{
		playState = state;
		camFollow = new FlxObject();
	}

	public function applyStageData(stageData:StageFile)
	{
		defaultCamZoom = stageData.defaultZoom;

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset  = stageData.camera_boyfriend  != null ? stageData.camera_boyfriend  : [0, 0];
		opponentCameraOffset   = stageData.camera_opponent   != null ? stageData.camera_opponent   : [0, 0];
		girlfriendCameraOffset = stageData.camera_girlfriend != null ? stageData.camera_girlfriend : [0, 0];
	}

	public function loadSongSettings()
	{
		var songPath:String = PlayState.instance.songName;
		var curStage:String = PlayState.curStage;

		var jsonPath:String = Paths.json('$songPath/cameraSettings');
		if (FileSystem.exists(jsonPath))
		{
			try
			{
				var parsed:Dynamic = haxe.Json.parse(sys.io.File.getContent(jsonPath));
				if (parsed != null)
				{
					if (parsed.BFx          != null) settings.BFx          = parsed.BFx;
					if (parsed.BFy          != null) settings.BFy          = parsed.BFy;
					if (parsed.DADx         != null) settings.DADx         = parsed.DADx;
					if (parsed.DADy         != null) settings.DADy         = parsed.DADy;
					if (parsed.GFx          != null) settings.GFx          = parsed.GFx;
					if (parsed.GFy          != null) settings.GFy          = parsed.GFy;
					if (parsed.MiddleCamera != null) settings.MiddleCamera = parsed.MiddleCamera;
					if (parsed.MiddleX      != null) settings.MiddleX      = parsed.MiddleX;
					if (parsed.MiddleY      != null) settings.MiddleY      = parsed.MiddleY;
					if (parsed.OverrideZoom != null) settings.OverrideZoom = parsed.OverrideZoom;
					if (parsed.OGZoom       != null) settings.OGZoom       = parsed.OGZoom;
					if (parsed.MiddleZoom   != null) settings.MiddleZoom   = parsed.MiddleZoom;
					if (parsed.OffsetsBF    != null) settings.OffsetsBF    = parsed.OffsetsBF;
					if (parsed.OffsetsDAD   != null) settings.OffsetsDAD   = parsed.OffsetsDAD;
					if (parsed.OffsetsGF    != null) settings.OffsetsGF    = parsed.OffsetsGF;
					if (parsed.Angle        != null) settings.Angle        = parsed.Angle;
					if (parsed.DADAngle     != null) settings.DADAngle     = parsed.DADAngle;
				}
			}
			catch (e:Dynamic) {}
		}

		if (songPath == 'prey')
		{
			customCameraEnabled = false;
			return;
		}

		if (curStage == 'stage') _applyStagePreset();
	}

	private function _applyStagePreset()
	{
		settings.mustHitSection = false;
		settings.BFx  = 850; settings.BFy  = 520;
		settings.DADx = 500; settings.DADy = 380;
		settings.GFx  = 0;   settings.GFy  = 0;
		settings.MiddleCamera = false;
		settings.MiddleX = 620; settings.MiddleY = 400;
		settings.OverrideZoom = false;
		settings.OGZoom = 0.9; settings.MiddleZoom = 0.7;
		settings.OffsetsBF = 25; settings.OffsetsDAD = 25; settings.OffsetsGF = 25;
		settings.Angle = 0; settings.DADAngle = 0;
	}

	public function initFollow(startX:Float, startY:Float, ?prevFollow:FlxObject)
	{
		camFollow.setPosition(startX, startY);
		if (prevFollow != null)
			camFollow.setPosition(prevFollow.x, prevFollow.y);

		playState.add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();
	}

	public function update(elapsed:Float)
	{
		if (PlayState.instance.camZooming)
		{
			var rate:Float = PlayState.instance.playbackRate;
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * (3.125 * 2) * PlayState.instance.camZoomingDecay * rate));
			PlayState.instance.camHUD.zoom = FlxMath.lerp(1, PlayState.instance.camHUD.zoom, Math.exp(-elapsed * (3.125 * 2) * PlayState.instance.camZoomingDecay * rate));
		}

		if (!customCameraEnabled) return;

		var ps:PlayState   = PlayState.instance;
		var gf:Character   = ps.gf;
		var dad:Character  = ps.dad;
		var bf:Character   = ps.boyfriend;
		var gfSection:Bool = (PlayState.SONG.notes[ps.curSection] != null && PlayState.SONG.notes[ps.curSection].gfSection);
		var mustHit:Bool   = (PlayState.SONG.notes[ps.curSection] != null && PlayState.SONG.notes[ps.curSection].mustHitSection);
		var s              = settings;

		camFollow.x = s.BFx;
		camFollow.y = s.BFy;

		function getAnim(char:Character):String
		{
			if (char == null) return '';
			return char.getAnimationName();
		}

		function tweenAngle(target:Float){
			return FunkinLua.oldTweenFunction('camGameAngleMovement', 'camGame', {angle: target}, 0.6, 'quadOut', 'doTweenAngle');
		}

		function setPos(x:Float, y:Float)
			setForcedPos(x, y);

		if (gfSection)
		{
			var anim:String   = getAnim(gf);
			var targetX:Float = s.MiddleCamera ? s.MiddleX : s.GFx;
			var targetY:Float = s.MiddleCamera ? s.MiddleY : s.GFy;
			var off:Float     = s.OffsetsGF;

			if      (anim == 'singLEFT')  { setPos(targetX - off, targetY); tweenAngle(-s.Angle); }
			else if (anim == 'singRIGHT') { setPos(targetX + off, targetY); tweenAngle(s.Angle); }
			else if (anim == 'singUP')    { setPos(targetX, targetY - off); tweenAngle(0); }
			else if (anim == 'singDOWN')  { setPos(targetX, targetY + off); tweenAngle(0); }
			else                           { setPos(targetX, targetY);       tweenAngle(0); }
		}
		else if (!mustHit)
		{
			var anim:String   = getAnim(dad);
			var targetX:Float = s.MiddleCamera ? s.MiddleX : s.DADx;
			var targetY:Float = s.MiddleCamera ? s.MiddleY : s.DADy;
			var off:Float     = s.OffsetsDAD;
			var ang:Float     = s.DADAngle;

			if      (anim.startsWith('singLEFT'))  { setPos(targetX - off, targetY); tweenAngle(-ang); }
			else if (anim.startsWith('singRIGHT')) { setPos(targetX + off, targetY); tweenAngle(ang); }
			else if (anim.startsWith('singUP'))    { setPos(targetX, targetY - off); tweenAngle(0); }
			else if (anim.startsWith('singDOWN'))  { setPos(targetX, targetY + off); tweenAngle(0); }
			else                                    { setPos(targetX, targetY);       tweenAngle(0); }
		}
		else
		{
			var anim:String   = getAnim(bf);
			var targetX:Float = s.MiddleCamera ? s.MiddleX : s.BFx;
			var targetY:Float = s.MiddleCamera ? s.MiddleY : s.BFy;
			var off:Float     = s.OffsetsBF;
			var ang:Float     = s.Angle;

			if      (anim.startsWith('singLEFT'))  { setPos(targetX - off, targetY); tweenAngle(-ang); }
			else if (anim.startsWith('singRIGHT')) { setPos(targetX + off, targetY); tweenAngle(ang); }
			else if (anim.startsWith('singUP'))    { setPos(targetX, targetY - off); tweenAngle(0); }
			else if (anim.startsWith('singDOWN'))  { setPos(targetX, targetY + off); tweenAngle(0); }
			else                                    { setPos(targetX, targetY);       tweenAngle(0); }
		}

		if (s.OverrideZoom)
			defaultCamZoom = overrideZoomValue;
		else
			defaultCamZoom = s.MiddleCamera ? s.MiddleZoom : s.OGZoom;

		if (PlayState.curStage == 'starved' && bf != null)
			bf.alpha = FlxMath.lerp(bf.alpha, _targetAlpha, 0.1 * PlayState.instance.playbackRate);
	}

	public function moveCameraSection(?sec:Null<Int>):Void
	{
		if (sec == null) sec = playState.curSection;
		if (sec < 0) sec = 0;
		if (PlayState.SONG.notes[sec] == null) return;

		var gf:Character = playState.gf;
		if (gf != null && PlayState.SONG.notes[sec].gfSection)
		{
			moveCameraToGirlfriend();
			playState.callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (PlayState.SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		playState.callOnScripts('onMoveCamera', [isDad ? 'dad' : 'boyfriend']);
	}

	public function moveCameraToGirlfriend()
	{
		var gf:Character = playState.gf;
		camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
		camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
		camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
		tweenCamIn();
	}

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			var dad:Character = playState.dad;
			if (dad == null) return;
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			var boyfriend:Character = playState.boyfriend;
			if (boyfriend == null) return;
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (playState.songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(_) { cameraTwn = null; }
				});
			}
		}
	}

	public function tweenCamIn()
	{
		if (playState.songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(_) { cameraTwn = null; }
			});
		}
	}

	public function onSectionZoomBump()
	{
		if (PlayState.instance.camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
		{
			FlxG.camera.zoom += 0.015 * PlayState.instance.camZoomingMult;
			PlayState.instance.camHUD.zoom += 0.03 * PlayState.instance.camZoomingMult;
		}
	}

	public function setForcedPos(?x:Null<Float>, ?y:Null<Float>)
	{
		isCameraOnForcedPos = false;
		if (x != null || y != null)
		{
			isCameraOnForcedPos = true;
			camFollow.x = x != null ? x : 0;
			camFollow.y = y != null ? y : 0;
		}
	}

	public function onCreatePost()
	{
		var h = CameraStageHandler.get(PlayState.curStage);
		if (h != null && h.onCreatePost != null) h.onCreatePost(this);
	}

	public function onSongStart()
	{
		var songName:String = PlayState.instance.songName;
		if (songName == 'chaos') settings.MiddleCamera = false;

		var h = CameraStageHandler.get(PlayState.curStage);
		if (h != null && h.onSongStart != null) h.onSongStart(this);
	}

	public function onSectionHit()
	{
		var mustHit:Bool = (PlayState.SONG.notes[playState.curSection] != null && PlayState.SONG.notes[playState.curSection].mustHitSection);
		var curBeat:Int  = playState.curBeat;

		if (_xeno) settings.OGZoom = mustHit ? 0.75 : 0.6;

		if (_sectionZoom)
		{
			settings.OGZoom = mustHit ? 0.7 : 0.9;
			settings.OverrideZoom = false;
		}

		var h = CameraStageHandler.get(PlayState.curStage);
		if (h != null && h.onSectionHit != null) h.onSectionHit(this, mustHit, curBeat);
	}

	public function onBeatHit()
	{
		var curBeat:Int     = playState.curBeat;
		var songPath:String = PlayState.instance.songName;

		var h = CameraStageHandler.get(PlayState.curStage);
		if (h != null && h.onBeatHit != null) h.onBeatHit(this, curBeat, songPath);
	}

	public function onStepHit()
	{
		var curStep:Int = playState.curStep;

		var h = CameraStageHandler.get(PlayState.curStage);
		if (h != null && h.onStepHit != null) h.onStepHit(this, curStep);
	}

	public function onOpponentNoteHit()
	{
		var h = CameraStageHandler.get(PlayState.curStage);
		if (h != null && h.onOpponentNoteHit != null) h.onOpponentNoteHit(this);
	}

	public function onEvent(name:String, ?v1:String, ?v2:String)
	{
		switch (name)
		{
			case 'Tween Camera Zoom':
				settings.OverrideZoom = true;
				overrideZoomValue = Std.parseFloat(v1);

			case 'Set customCamera Zoom':
				settings.OverrideZoom = false;

			case 'Set Camera Position':
				var split = v2.split(', ');
				var x:Float = Std.parseFloat(split[0]);
				var y:Float = split.length > 1 ? Std.parseFloat(split[1]) : 0;
				switch (v1.toLowerCase()) {
					case 'bf':  settings.BFx  = x; settings.BFy  = y;
					case 'dad': settings.DADx = x; settings.DADy = y;
					case 'gf':  settings.GFx  = x; settings.GFy  = y;
				}

			case 'cameracenter':
				settings.MiddleCamera = (v1 == 'true');
				settings.OverrideZoom = false;

			case 'tripletroublebgchange':
				settings.OverrideZoom = false;
				switch (v1) {
					case 'xeno':  _xeno = true;  settings.BFx=1250; settings.BFy=1000; settings.DADx=850;  settings.DADy=850;
					case 'xeno2': _xeno = true;  settings.BFx=650;  settings.BFy=1000; settings.DADx=1200; settings.DADy=850;
					case 'xeno3': _xeno = true;  settings.BFx=1250; settings.BFy=1000; settings.DADx=850;  settings.DADy=850;
					case 'knux':  _xeno = false; settings.BFx=650;  settings.BFy=850;  settings.DADx=1150; settings.DADy=850;
					case 'egg':   _xeno = false; settings.BFx=1200; settings.BFy=850;  settings.DADx=700;  settings.DADy=850;
				}

			case 'yourselfEvents':
				switch (v1) {
					case 'yourselfTime':
						settings.DADx=1350; settings.DADy=1000; settings.BFx=2200; settings.BFy=1150;
						settings.OffsetsBF=10; settings.OffsetsDAD=10;
					case 'showOffNewStage':
						settings.MiddleX=1730; settings.MiddleY=950;
						settings.DADx=1350; settings.DADy=890;
						settings.BFx=2090; settings.BFy=1200;
						settings.OGZoom=1.05;
					case 'changeMiddlePos':
						settings.MiddleX=1730; settings.MiddleY=1100;
						settings.DADx=1350; settings.DADy=1000;
						settings.BFx=2200; settings.BFy=1150;
						settings.OGZoom=1;
				}

			case 'sexxxxxx':
				if (v1 == 'newbg') { settings.DADy = 110; settings.MiddleY = 305; }

			case 'OverrideZoom':
				settings.OverrideZoom = false;

			case 'cameraZooming':
				PlayState.instance.camZooming = (v1 == 'true');

			case 'hellbentEvents':
				if (v1 == 'changeBG')
				{
					settings.BFx=-80;  settings.BFy=1100;
					settings.DADx=-80; settings.DADy=1100;
					settings.MiddleY=1000; settings.OGZoom=0.75;
					FlxTween.tween(PlayState.instance.camGame.targetOffset, {x: 350, y: 80}, 0.0001);
					setForcedPos(settings.BFx + 350, settings.BFy);
					PlayState.instance.camGame.zoom = 0.75;
					PlayState.instance.camGame.snapToTarget();
				}

			case 'fateEvents':
				switch (v1) {
					case 'part2' if (v2 == ''):
						settings.BFx=2100; settings.BFy=1300; settings.DADx=1650; settings.DADy=1300;
						settings.GFx=250; settings.GFy=590;
						settings.MiddleCamera=true; settings.MiddleX=1830; settings.MiddleY=1230;
						settings.OverrideZoom=false; settings.OGZoom=0.5; settings.MiddleZoom=0.45;
						settings.OffsetsBF=25; settings.OffsetsDAD=25; settings.OffsetsGF=25;
					case 'part2' if (v2 == 'sad'):
						settings.BFx=2250; settings.BFy=1450; settings.DADx=1450; settings.DADy=1250;
					case 'part4' if (v2 == ''):
						_sectionZoom=true;
						settings.BFx=1400; settings.BFy=800; settings.DADx=850; settings.DADy=500;
						settings.GFx=250; settings.GFy=590;
						settings.MiddleCamera=false; settings.MiddleX=1200; settings.MiddleY=720;
						settings.OverrideZoom=false; settings.OGZoom=0.7; settings.MiddleZoom=0.58;
						settings.OffsetsBF=25; settings.OffsetsDAD=25; settings.OffsetsGF=25;
				}

			case 'slashchangeBG':
				settings.BFx=330; settings.BFy=250; settings.DADx=330; settings.DADy=250;
				settings.OGZoom=0.71;
				PlayState.instance.camGame.zoom = 0.7;
				new flixel.util.FlxTimer().start(0.01, function(_) PlayState.instance.camGame.snapToTarget());

			case 'soullesEvents':
				if (v1 == 'startcam') { PlayState.instance.camZooming = true; settings.MiddleY = 600; }

			case 'BGchange':
				switch (v1) {
					case 'blackout':
						settings.BFx=1600; settings.BFy=1500; settings.DADx=1600; settings.DADy=1100;
						settings.GFx=1600; settings.GFy=1500;
						new flixel.util.FlxTimer().start(0.05, function(_) PlayState.instance.camGame.snapToTarget());
					case 'blackin':
						settings.BFx=1400; settings.BFy=1000; settings.DADx=2100; settings.DADy=650;
						settings.GFx=1400; settings.GFy=1000;
						new flixel.util.FlxTimer().start(0.05, function(_) PlayState.instance.camGame.snapToTarget());
					case 'jajaja':
						settings.OGZoom=0.83; settings.BFx=1300; settings.BFy=1300;
						settings.DADx=1630; settings.DADy=1200;
						setForcedPos(settings.DADx, settings.DADy);
						PlayState.instance.camGame.zoom = 1.25;
						PlayState.instance.camGame.snapToTarget();
				}

			case 'chaosEvent':
				if (v1 == 'bftransform') { settings.BFx = 2900; settings.BFy = 1400; }
		}
	}

	public function snapToTarget()
		FlxG.camera.snapToTarget();

	public function destroy()
	{
		if (cameraTwn != null)
		{
			cameraTwn.cancel();
			cameraTwn = null;
		}
	}
}
