package backend;

import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

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

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

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

	override function update(elapsed:Float)
	{
		//everyStep();
		if(!persistentUpdate) MusicBeatState.timePassedOnState += elapsed;
		var oldStep:Int = curStep;

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

		if(backButton != null) {
			if(FlxG.mouse.pressedRight) {
				backButton.x += deltaMouseX;
				backButton.y += deltaMouseY;
				trace(backButton.x + ' ' + backButton.y);
			}

			buttonOverlaps = FlxG.mouse.overlaps(backButton, backButton.cameras[0]);

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

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	public function sectionHit():Void
	{
		//yep, you guessed it, nothing again, dumbass
	}
	
	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
