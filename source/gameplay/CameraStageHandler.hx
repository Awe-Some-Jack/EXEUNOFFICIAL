package gameplay;

import states.PlayState;

typedef CameraCallbacks = {
	?onSongStart:       (cam:GameplayCamera) -> Void,
	?onCreatePost:      (cam:GameplayCamera) -> Void,
	?onSectionHit:      (cam:GameplayCamera, mustHit:Bool, curBeat:Int) -> Void,
	?onBeatHit:         (cam:GameplayCamera, curBeat:Int, songName:String) -> Void,
	?onStepHit:         (cam:GameplayCamera, curStep:Int) -> Void,
	?onOpponentNoteHit: (cam:GameplayCamera) -> Void,
	?onEvent:           (cam:GameplayCamera, v1:String, v2:String) -> Void,
}

class CameraStageHandler
{
	static var _handlers:Map<String, CameraCallbacks> = null;

	static function init()
	{
		if (_handlers != null) return;
		_handlers = new Map();

		// ---- tooslow ----
		_handlers['tooslow'] = {
			onSongStart: function(cam:GameplayCamera) {
				PlayState.instance.cameraSpeed     = 10000;
				cam.settings.OffsetsBF  = 0;
				cam.settings.OffsetsDAD = 0;
				cam.settings.OffsetsGF  = 0;
				cam.settings.Angle      = 0;
			},
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				PlayState.instance.cameraSpeed = (curStep == 1) ? 10000 : 1;
				if (curStep == 256) PlayState.instance.camZooming = false;
				if (curStep == 796)
				{
					cam.settings.MiddleCamera  = false; cam.settings.OverrideZoom = false;
					cam.settings.OffsetsBF     = 25;    cam.settings.OffsetsDAD   = 25;
					cam.settings.OffsetsGF     = 25;
				}
				for (s in [1184, 1472, 1536, 2112, 2176])
					if (curStep == s) { cam.settings.MiddleCamera = true;  cam.settings.OverrideZoom = false; }
				for (s in [796, 1248, 1504, 1568, 2144, 2208])
					if (curStep == s) { cam.settings.MiddleCamera = false; cam.settings.OverrideZoom = false; }
				if (curStep == 1952) { cam.settings.BFx = 2070;  cam.settings.BFy  = 1390; cam.settings.DADx = 1050; cam.settings.DADy = 1340; }
				if (curStep == 2080) { cam.settings.BFx = 1970;  cam.settings.BFy  = 1290; cam.settings.DADx = 1250; cam.settings.DADy = 1290; }
			},
		};

		// ---- you-cant-run ----
		_handlers['you-cant-run'] = {
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				for (s in [0, 80, 528, 800, 1176])
					PlayState.instance.cameraSpeed = (curStep == s) ? 1000000 : 1;
				if (curStep == 128) cam.settings.MiddleCamera  = false;
				if (curStep == 144) cam.settings.OverrideZoom  = false;
				for (s in [432, 896, 1056, 1440])
					if (curStep == s) { cam.settings.MiddleCamera = true;  cam.settings.OverrideZoom = false; }
				for (s in [464, 928, 1120])
					if (curStep == s) { cam.settings.MiddleCamera = false; cam.settings.OverrideZoom = false; }
				if (curStep == 528)
				{
					cam.settings.DADx = 800;   cam.settings.DADy     = 120;
					cam.settings.BFx  = 900;   cam.settings.BFy      = 120;
					cam.settings.MiddleX      = 450;   cam.settings.MiddleY  = 100;
					cam.settings.OverrideZoom = false;
					cam.settings.OGZoom       = 2.2;   cam.settings.MiddleZoom = 2.0;
					cam.settings.OffsetsBF    = 5;     cam.settings.OffsetsDAD = 5;
				}
				if (curStep == 800)
				{
					cam.settings.BFx  = 1200;  cam.settings.BFy      = 590;
					cam.settings.DADx = 650;   cam.settings.DADy     = 590;
					cam.settings.MiddleX      = 930;   cam.settings.MiddleY  = 530;
					cam.settings.OverrideZoom = false;
					cam.settings.OGZoom       = 0.7;   cam.settings.MiddleZoom = 0.65;
					cam.settings.OffsetsBF    = 25;    cam.settings.OffsetsDAD = 25;
				}
			},
		};

		// ---- triple-trouble ----
		_handlers['triple-trouble'] = {
			onSongStart: function(cam:GameplayCamera) {
				cam.settings.OverrideZoom = false;
			},
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				PlayState.instance.cameraSpeed = (curStep >= 1168 && curStep < 1264) ? 10 : 1;
				for (s in [1296,2828,2912,2928,2944,3232,3236,3240,3244,3296,3300,3304,3308])
					if (curStep == s) PlayState.instance.cameraSpeed = 100000;
				if (curStep == 1296) { cam.settings.BFx  = 650;  cam.settings.BFy  = 850; cam.settings.DADx = 650;  cam.settings.DADy = 850; }
				if (curStep == 1360) { cam.settings.DADx = 1150; cam.settings.DADy = 850; }
				if (curStep == 448)    cam.settings.BFy  = 950;
			},
			onOpponentNoteHit: function(cam:GameplayCamera) {
				if (cam._firstone)
				{
					cam._firstone            = false;
					cam.settings.MiddleCamera = false;
				}
			},
		};

		// ---- yourself ----
		_handlers['yourself'] = {
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				PlayState.instance.cameraSpeed = (curStep == 768) ? 1000000 : 1;
				if (curStep == 768)  cam.settings.OGZoom = 0.65;
				if (curStep == 1344) { cam.settings.BFx = PlayState.instance.boyfriend.getMidpoint().x; cam.settings.BFy = 1250; }
				if (curStep == 1472) { cam.settings.BFx = 2090; cam.settings.BFy = 1190; }
				if (curStep == 1984) { cam.settings.DADx = PlayState.instance.dad.getMidpoint().x; cam.settings.DADy = PlayState.instance.dad.getMidpoint().y; }
				if (curStep == 2048) { cam.settings.DADx = 1350; cam.settings.DADy = 1150; }
			},
		};

		// ---- hollow ----
		_handlers['hollow'] = {
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				for (s in [1, 2096, 2104, 2112, 2128])
					if (curStep == s) PlayState.instance.cameraSpeed = 1000000;
				if (curStep != 1 && curStep != 2096 && curStep != 2104 && curStep != 2112 && curStep != 2128)
					PlayState.instance.cameraSpeed = 1;
				for (s in [1056, 2064, 2128])
					if (curStep == s) { cam.settings.MiddleCamera = true;  cam.settings.OverrideZoom = false; }
				for (s in [1312, 2096])
					if (curStep == s) { cam.settings.MiddleCamera = false; cam.settings.OverrideZoom = false; }
				if (curStep == 2104) { cam.settings.BFx  = 2270; cam.settings.BFy  = 1250; cam.settings.DADx = 2270; cam.settings.DADy = 1250; }
				if (curStep == 2112) { cam.settings.BFx  = 2270; cam.settings.BFy  = 1250; cam.settings.DADx = 1450; cam.settings.DADy = 1190; }
			},
		};

		// ---- fleetw ----
		_handlers['fleetw'] = {
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				var fleSteps = [192,198,204,536,544,552,560,568,576,592,600,608,616,624,632,
				                1624,1632,1640,1648,1656,1664,1680,1688,1696,1704,1712,1720];
				var isFle = false;
				for (s in fleSteps) if (curStep == s) { isFle = true; break; }
				PlayState.instance.cameraSpeed = isFle ? 10000 : 1;
			},
		};

		// ---- uh-oh ----
		_handlers['uh-oh'] = {
			onCreatePost: function(cam:GameplayCamera) {
				PlayState.instance.triggerEvent('Tweening Camera',    '-320, 0',    '0.001, linear', 0);
				PlayState.instance.triggerEvent('Tween Camera Zoom',  '1.4, true',  '0.001, linear', 0);
				PlayState.instance.cameraSpeed = 1000000;
			},
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				PlayState.instance.cameraSpeed = (curStep == 600) ? 1000000 : 1;
				if (curStep == 1312) PlayState.instance.cameraSpeed = 100;
				for (s in [408, 1176, 1704, 1960, 2088])
					if (curStep == s) { cam.settings.MiddleCamera = true;  cam.settings.OverrideZoom = false; }
				for (s in [504, 1240, 1800, 2024])
					if (curStep == s) { cam.settings.MiddleCamera = false; cam.settings.OverrideZoom = false; }
			},
		};

		// ---- majin ----
		_handlers['majin'] = {
			onStepHit: function(cam:GameplayCamera, curStep:Int) {
				for (s in [784, 1184, 1312, 2464, 2592, 2736])
					if (curStep == s) { cam.settings.MiddleCamera = true;  cam.settings.OverrideZoom = false; }
				for (s in [912, 1248, 1376, 2528, 2656])
					if (curStep == s) { cam.settings.MiddleCamera = false; cam.settings.OverrideZoom = false; }
			},
		};

		// ---- exe ----
		_handlers['exe'] = {
			onSectionHit: function(cam:GameplayCamera, mustHit:Bool, curBeat:Int) {
				cam.settings.OverrideZoom = false;
				if (mustHit) { if (cam.settings.MiddleCamera) cam.settings.MiddleZoom = 0.6;  else cam.settings.OGZoom = 0.65; }
				else         { if (cam.settings.MiddleCamera) cam.settings.MiddleZoom = 0.5;  else cam.settings.OGZoom = 0.45; }
			},
		};

		// ---- god ----
		_handlers['god'] = {
			onSectionHit: function(cam:GameplayCamera, mustHit:Bool, curBeat:Int) {
				if (cam._oldHitSection != mustHit) { cam.settings.OverrideZoom = false; cam._oldHitSection = mustHit; }
				cam.settings.OGZoom = mustHit ? 0.6 : 0.45;
			},
		};

		// ---- deception ----
		_handlers['deception'] = {
			onSectionHit: function(cam:GameplayCamera, mustHit:Bool, curBeat:Int) {
				if (curBeat >= 128)
				{
					if (cam._oldHitSection != mustHit) { cam.settings.OverrideZoom = false; cam._oldHitSection = mustHit; }
					cam.settings.OGZoom = mustHit ? 0.83 : 1.25;
				}
			},
		};

		// ---- ncd ----
		_handlers['ncd'] = {
			onBeatHit: function(cam:GameplayCamera, curBeat:Int, songName:String) {
				if (curBeat >= 40 && cam.settings.MiddleZoom != 0.75)
				{
					cam.settings.MiddleZoom = 0.75;
					cam.settings.MiddleX    = 950;
					cam.settings.MiddleY    = 570;
				}
			},
		};

		// ---- hog ----
		_handlers['hog'] = {
			onBeatHit: function(cam:GameplayCamera, curBeat:Int, songName:String) {
				if (curBeat >= 188 && songName == 'manual-blast' && !cam._sexitosxd2)
				{
					cam._sexitosxd2        = true;
					cam.settings.DADAngle  = 1.5;
				}
				if (curBeat >= 1040 && songName == 'manual-blast')
					cam.settings.MiddleZoom = 0.42;
				if (curBeat >= 1238 && !cam._sexogratisputocom && songName == 'manual-blast')
				{
					cam._sexogratisputocom = true;
					PlayState.instance.camZoomingMult     = 0;
				}
			},
		};

		// ---- forestall ----
		_handlers['forestall'] = {
			onSectionHit: function(cam:GameplayCamera, mustHit:Bool, curBeat:Int) {
				cam.settings.OGZoom = mustHit ? 0.55 : 0.67;
			},
		};

		// ---- starved ----
		_handlers['starved'] = {
			onSectionHit: function(cam:GameplayCamera, mustHit:Bool, curBeat:Int) {
				if (mustHit) { cam.settings.OGZoom = 0.83; cam._targetAlpha = 1.0; }
				else         { cam.settings.OGZoom = 1.0;  cam._targetAlpha = 0.5; }
			},
		};
	}

	public static function get(stage:String):Null<CameraCallbacks>
	{
		init();
		return _handlers.get(stage);
	}

	public static function register(stage:String, callbacks:CameraCallbacks)
	{
		init();
		_handlers.set(stage, callbacks);
	}
}
