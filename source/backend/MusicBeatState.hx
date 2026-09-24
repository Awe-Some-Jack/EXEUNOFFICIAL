package backend;

import flixel.FlxState;
import backend.PsychCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.touch.FlxTouch;

class MusicBeatState extends FlxTransitionableState
{
	public var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	#if mobile
	public var mouseX:Float = 0;
	public var deltaMouseX:Float = 0;
	public var mouseY:Float = 0;
	public var deltaMouseY:Float = 0;
	public var touchLength:Float = 0;
	public var shortPress:Bool = false;
	public var pressHolding:Bool = false;
	public var backPressed:Bool = false;
	public var buttonOverlaps:Bool = false;
	public var swipeUP:Bool = false;
	public var swipeDOWN:Bool = false;
	public var swipeLEFT:Bool = false;
	public var swipeRIGHT:Bool = false;

	public var backButton:FlxSprite;
	var tweenScale:FlxTween;
	#end

	public var curDecStep:Float = 0;
	public var curDecBeat:Float = 0;
	public var controls(get, never):Controls;
	private function get_controls()
	{
		return Controls.instance;
	}

	var _psychCameraInitialized:Bool = false;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables()
		return getState().variables;

	override function create() 
	{
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		persistentUpdate = persistentDraw = true;

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		timePassedOnState = 0;
	}

	#if mobile
	public function createBackButton(x:Float, y:Float) {
		backButton = new FlxSprite(0, 0);
		backButton.frames = FlxAtlasFrames.fromSparrow('assets/exe/backButton.webp', 'assets/exe/backButton.xml');
		backButton.animation.addByPrefix('idle', 'idle', 24, false);
		backButton.animation.addByPrefix('press', 'press', 24, false);
		backButton.animation.play('idle', true);
		backButton.scale.set(0.17, 0.17);
		backButton.alpha = 0.6;
		backButton.updateHitbox();
		backButton.x = x;
		backButton.y = y;
		add(backButton);
	}
	#end

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		#if mobile
		mouseX = FlxG.mouse.x;
		mouseY = FlxG.mouse.y;

		deltaMouseX = FlxG.mouse.deltaScreenX;
		deltaMouseY = FlxG.mouse.deltaScreenY;

		if(FlxG.touches.list.length == 0) touchLength = 0;

		for(touch in FlxG.touches.list) {
			touchLength = FlxG.game.ticks - touch.justPressedTimeInTicks;
			shortPress = (touch.justReleased && touchLength <= 100);
			pressHolding = (touch.pressed && touchLength > 10);
		}

		swipeUP = deltaMouseY <= -5 && pressHolding && Math.abs(deltaMouseY) > Math.abs(deltaMouseX);
		swipeDOWN = deltaMouseY >= 5 && pressHolding && Math.abs(deltaMouseY) > Math.abs(deltaMouseX);
		swipeLEFT = deltaMouseX <= -5 && pressHolding && Math.abs(deltaMouseY) < Math.abs(deltaMouseX);
		swipeRIGHT = deltaMouseX >= 5 && pressHolding && Math.abs(deltaMouseY) < Math.abs(deltaMouseX);
		#end

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});

		#if mobile
		if(backButton != null) {
			if(FlxG.mouse.pressedRight) {
				backButton.x += deltaMouseX;
				backButton.y += deltaMouseY;
				trace(backButton.x + ' ' + backButton.y);
			}

			buttonOverlaps = FlxG.mouse.overlaps(backButton);

			if(buttonOverlaps) {
				backButton.animation.play('press', true);

				backPressed = shortPress;

				if(backButton.scale.x != 0.19 && tweenScale == null) {
					FlxTween.cancelTweensOf(backButton);
					FlxTween.cancelTweensOf(backButton.scale);
					tweenScale = FlxTween.tween(backButton.scale, {x: 0.19, y: 0.19}, 0.2, {ease: FlxEase.backOut, onComplete: function(_) tweenScale = null});
					FlxTween.tween(backButton, {alpha: 1}, 0.2, {ease: FlxEase.smootherStepOut});
				}
			} else {
				backButton.animation.play('idle', true);
				if(backButton.scale.x != 0.17 && tweenScale == null) {
					FlxTween.cancelTweensOf(backButton);
					FlxTween.cancelTweensOf(backButton.scale);
					tweenScale = FlxTween.tween(backButton.scale, {x: 0.17, y: 0.17}, 0.2, {ease: FlxEase.backOut, onComplete: function(_) tweenScale = null});
					FlxTween.tween(backButton, {alpha: 0.6}, 0.2, {ease: FlxEase.smootherStepOut});
				}
			}
		}
		#end

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	override public function transitionIn():Void
    {
        if (FlxTransitionableState.skipNextTransIn)
        {
            FlxTransitionableState.skipNextTransIn = false;
            finishTransIn();
            return;
        }

        final trans = new CustomShapeTransition(0.5, true);
        CustomShapeTransition.finishCallback = finishTransIn;
        openSubState(trans);
    }

    override function startOutro(onOutroComplete:() -> Void)
    {
        _exiting = true;
        _onExit = onOutroComplete;

        if (FlxTransitionableState.skipNextTransOut)
        {
            FlxTransitionableState.skipNextTransOut = false;
            finishTransOut();
            return;
        }

        final trans = new CustomShapeTransition(0.5, false);
        CustomShapeTransition.finishCallback = finishTransOut;
        openSubState(trans);
    }

	@:deprecated("MusicBeatState.resetState() is deprecated, use FlxG.resetState() instead PLZ")
	public static function resetState() {
		FlxG.resetState();
	}

	public static function getState():MusicBeatState {
		return cast (FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0)
			beatHit();
	}

	public var stages:Array<BaseStage> = [];
	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if(stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
