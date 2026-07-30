package camera;

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
		//HAHA NO CODE I MADE IT ALL AN EVENT HAHAHAAHAHAHAHAHAHHA FUCK YOU HAHAHAHHAHAHHAHAHAHAHAHAHAH (pls help me)

		// ---- you-cant-run ----
		// HAHA NO CODE I MADE IT ALL AN EVENT HAHAHAAHAHAHAHAHAHHA FUCK YOU HAHAHAHHAHAHHAHAHAHAHAHAHAH (pls help me)

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
					cam.settings.OGZoom = mustHit ? 0.9 : 1.5;
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
				if (mustHit) { cam._targetAlpha = 1.0; }
				else         { cam._targetAlpha = 0.5; }
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
