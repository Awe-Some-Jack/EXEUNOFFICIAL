package objects;

import backend.animation.PsychAnimationController;
import backend.NoteTypesConfig;

import objects.StrumNote;

import flixel.math.FlxRect;

using StringTools;

typedef EventNote = {
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

/**
 * The note object used as a data structure to spawn and manage notes during gameplay.
 *
 * To add a custom note type, see `set_noteType`.
 * All public fields are accessible from Lua and HScript via `setPropertyFromClass`
 * or direct property access on note references.
**/
class Note extends FlxSprite
{
	// Hard-coded note types; also used for backwards-compatibility with 0.1–0.3.2 charts.
	public static final defaultNoteTypes:Array<String> = [
		'',              // Always leave this one empty.
		'Alt Animation',
		'Hey!',
		'Hurt Note',
		'GF Sing',
		'No Animation',
		'Sustain Animation',
		'BF and GF Sing'
	];

	/** General-purpose key–value store; read/write from Lua and HScript. **/
	public var extraData:Map<String, Dynamic> = new Map();

	public var strumTime:Float = 0;
	public var noteData:Int = 0;

	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;

	public var wasGoodHit:Bool = false;
	public var missed:Bool = false;

	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;

	public var comboBreak:Bool = false;

	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	/** Sustain child notes. **/
	public var tail:Array<Note> = [];
	/** The head note this sustain belongs to, if any. **/
	public var parent:Note;

	/** When `true`, the player cannot hit this note (does not affect opponent). **/
	public var blockHit:Bool = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var inEditor:Bool = false;

	/** Appended to sing-animation names, e.g. `'-alt'` for alt-anim sections. **/
	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var SUSTAIN_SIZE:Int = 44;
	public static var swagWidth:Float = 160 * 0.7;
	public static var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var defaultNoteSkin(default, never):String = 'noteSkins/NOTE_assets';
	public var adjustColor:shaders.AdjustColorShader;

	public var noteSplashDisabled:Bool = false;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var multSpeed(default, set):Float = 1;
	private function set_multSpeed(value:Float):Float
	{
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		return value;
	}

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.02;
	public var missHealth:Float = 0.1;
	public var rating:String = 'unknown';
	/** 0 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick **/
	public var ratingMod:Float = 0;
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	var baseScaleX:Float = 0;
	var baseScaleY:Float = 0;
	private function set_texture(value:String):String
	{
		if (texture != value) reloadNote(value);
		texture = value;
		return value;
	}

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	/** Maximum distance from the strum line before the note is culled (scroll-direction use). **/
	public var distance:Float = 2000;

	public var hitsoundDisabled:Bool = false;
	public var hitsoundChartEditor:Bool = true;
	/**
	 * When `true`, the hitsound plays even if the user's hitsound volume is 0.
	 * Useful for special note types that always need audio feedback.
	**/
	public var hitsoundForce:Bool = false;

	public var hitsoundVolume(get, default):Float = 1.0;
	private function get_hitsoundVolume():Float
	{
		if (ClientPrefs.data.hitsoundVolume > 0) return ClientPrefs.data.hitsoundVolume;
		return hitsoundForce ? hitsoundVolume : 0.0;
	}

	public var hitsound:String = 'noteHitPlayer';

	// -- Internal --
	var _lastNoteOffX:Float = 0;
	static var _lastValidChecked:String;

	public var originalHeight:Float = 6;
	/** Internal correction used by the sustain-clipping system; do not modify. **/
	public var correctionOffset:Float = 0;

	// -------------------------------------------------------------------------

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, sustainNote:Bool = false, inEditor:Bool = false, ?createdFrom:Dynamic)
	{
		super();

		animation = new PsychAnimationController(this);

		if (createdFrom == null) createdFrom = PlayState.instance;
		if (prevNote == null)    prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.moves = false;

		x += (ClientPrefs.data.middleScroll ? -278 : 42) + 50;
		y -= 2000;

		this.strumTime = strumTime + (inEditor ? 0 : ClientPrefs.data.noteOffset);
		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = '';
			x += swagWidth * noteData;

			if (!isSustainNote && noteData < colArray.length)
				animation.play(colArray[noteData % colArray.length] + 'Scroll');
		}

		if (prevNote != null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			hitsoundDisabled = true;

			if (ClientPrefs.data.downScroll) flipY = true;

			copyAngle = false;

			if (PlayState.isPixelStage)
			{
				animation.play(colArray[noteData % colArray.length] + 'holdend');
				updateHitbox();
			}
			else
			{
				animation.play(colArray[noteData % colArray.length] + 'holdend');
				updateHitbox();
			}

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colArray[prevNote.noteData % colArray.length] + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.0625;
				if (createdFrom?.songSpeed != null)
					prevNote.scale.y *= createdFrom.songSpeed;

				if (PlayState.isPixelStage)
				{
					prevNote.scale.y *= 1.19; 
					prevNote.scale.y *= 6 / height;
				}
				prevNote.updateHitbox();

				var headNote:Note = (prevNote.parent != null) ? prevNote.parent : prevNote;
				var headWidth:Float = headNote.frameWidth * headNote.scale.x;
				var prevWidth:Float = prevNote.frameWidth * prevNote.scale.x;

				prevNote.offsetX = (headWidth - prevWidth) / 2;
			}

			if (PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
			earlyHitMult = 0;

			var mainHead:Note = (parent != null) ? parent : (prevNote.isSustainNote ? prevNote.parent : prevNote);
			if (mainHead != null)
			{
				var mainHeadWidth:Float = mainHead.frameWidth * mainHead.scale.x;
				var myWidth:Float = frameWidth * scale.x;

				offsetX = (mainHeadWidth - myWidth) / 2;
			}
			else
			{
				offsetX = (Note.swagWidth - (frameWidth * scale.x)) / 2;
			}
		}
		else if (!isSustainNote)
		{
			centerOffsets();
			centerOrigin();
		}
		x += offsetX;

		adjustColor = new shaders.AdjustColorShader();
		shader = adjustColor;
	}

	private function set_noteType(value:String):String
	{
		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Hurt Note':
					ignoreNote = mustPress;
					lowPriority = true;
					missHealth = isSustainNote ? 0.25 : 0.1;
					hitCausesMiss = true;
					hitsound = 'cancelMenu';
					hitsoundChartEditor = false;

				case 'Alt Animation':
					animSuffix = '-alt';

				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;

				case 'GF Sing':
					gfNote = true;
			}

			if (value != null && value.length > 1)
				NoteTypesConfig.applyNoteTypeData(this, value);

			// Pre-cache the hitsound so it is ready on first use.
			if (hitsound != 'noteHitPlayer' && hitsoundVolume > 0)
				Paths.sound(hitsound);

			noteType = value;
		}
		return value;
	}

	public function reloadNote(texture:String = '', postfix:String = ''):Void
	{
		if (texture == null) texture = '';
		if (postfix == null) postfix = '';

		var skin:String = texture + postfix;
		if (texture.length < 1)
		{
			skin = PlayState.SONG?.arrowSkin ?? null;
			if (skin == null || skin.length < 1)
				skin = defaultNoteSkin + postfix;
		}

		final animName:Null<String> = animation.curAnim?.name;
		final skinPixel:String = skin;
		final lastScaleY:Float = scale.y;
		final lastScaleX:Float = scale.x;
		final hadFrames:Bool = frames != null;
		final skinPostfix:String = getNoteSkinPostfix();
		final customSkin:String = skin + skinPostfix;
		final path:String = PlayState.isPixelStage ? 'pixelUI/' : '';

		for (exts in Paths.IMAGE_EXTS)
		{
			if (customSkin == _lastValidChecked || Paths.fileExists('images/$path$customSkin.$exts', IMAGE))
			{
				skin = customSkin;
				_lastValidChecked = customSkin;
				break;
			}
		}

		if (PlayState.isPixelStage)
		{
			if (isSustainNote)
			{
				final graphic = Paths.image('pixelUI/' + skinPixel + 'ENDS' + skinPostfix);
				loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 2));
				originalHeight = graphic.height / 2;
			}
			else
			{
				final graphic = Paths.image('pixelUI/' + skinPixel + skinPostfix);
				loadGraphic(graphic, true, Math.floor(graphic.width / 4), Math.floor(graphic.height / 5));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if (isSustainNote)
			{
				offsetX += _lastNoteOffX;
				_lastNoteOffX = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= _lastNoteOffX;
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(skin);
			loadNoteAnims();
			if (!isSustainNote)
			{
				centerOffsets();
				centerOrigin();
			}
		}

		final newBaseX:Float = scale.x;
		final newBaseY:Float = scale.y;
		if (hadFrames && baseScaleX > 0 && baseScaleY > 0)
		{
			scale.x = newBaseX * (lastScaleX / baseScaleX);
			scale.y = isSustainNote ? lastScaleY : newBaseY * (lastScaleY / baseScaleY);
		}
		else if (isSustainNote) scale.y = lastScaleY;
		baseScaleX = newBaseX;
		baseScaleY = newBaseY;
		updateHitbox();

		if (animName != null)
			animation.play(animName, true);
	}

	public static function getNoteSkinPostfix():String
	{
		if (ClientPrefs.data.noteSkin == ClientPrefs.defaultData.noteSkin) return '';
		return '-' + ClientPrefs.data.noteSkin.trim().toLowerCase().replace(' ', '_');
	}

	/** Scales a sustain note's height by `ratio`. No-op on head notes or during end-cap frames. **/
	public function resizeByRatio(ratio:Float):Void
	{
		if (isSustainNote && animation.curAnim != null && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function loadNoteAnims():Void
	{
		if (colArray[noteData] == null) return;

		final col:String = colArray[noteData];
		if (isSustainNote)
		{
			// Fixes a legacy typo in the original note FLA source.
			attemptToAddAnimationByPrefix('purpleholdend', 'pruple end hold', 24, true);
			animation.addByPrefix(col + 'holdend', col + ' hold end',   24, true);
			animation.addByPrefix(col + 'hold',    col + ' hold piece', 24, true);
		}
		else
		{
			animation.addByPrefix(col + 'Scroll', col + '0');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	private function loadPixelNoteAnims():Void
	{
		if (colArray[noteData] == null) return;

		final col:String = colArray[noteData];
		if (isSustainNote)
		{
			animation.add(col + 'holdend', [noteData + 4], 24, true);
			animation.add(col + 'hold',    [noteData],     24, true);
		}
		else
		{
			animation.add(col + 'Scroll', [noteData + 4], 24, true);
		}
	}

	private function attemptToAddAnimationByPrefix(name:String, prefix:String, framerate:Float = 24, doLoop:Bool = true):Void
	{
		final animFrames:Array<flixel.graphics.frames.FlxFrame> = [];
		@:privateAccess animation.findByPrefix(animFrames, prefix);
		if (animFrames.length < 1) return;
		animation.addByPrefix(name, prefix, framerate, doLoop);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (mustPress)
		{
			canBeHit = strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
			        && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult);

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;
			if (!wasGoodHit && strumTime <= Conductor.songPosition)
				if (!isSustainNote || (prevNote.wasGoodHit && !ignoreNote))
					wasGoodHit = true;
		}

		if (tooLate && !inEditor && alpha > 0.3)
			alpha = 0.3;
	}

	override public function destroy():Void
	{
		super.destroy();
		_lastValidChecked = '';
	}

	public function followStrumNote(myStrum:StrumNote, fakeCrochet:Float, songSpeed:Float = 1):Void
	{
		distance = 0.45 * (Conductor.songPosition - strumTime) * songSpeed * multSpeed;
		if (!myStrum.downScroll) distance *= -1;

		final angleDir:Float = myStrum.direction * Math.PI / 180;
		if (copyAngle) angle = myStrum.direction - 90 + myStrum.angle + offsetAngle;
		if (copyAlpha) alpha = myStrum.alpha * multAlpha;
		if (copyX){
			if (!isSustainNote){
				//maybe good¿
				x = myStrum.x + (((myStrum.width - width)/2)+offsetX) + Math.cos(angleDir) * distance;
			}else{
				x = myStrum.x + offsetX + Math.cos(angleDir) * distance;
			}
		}

		if (copyY)
		{
			y = myStrum.y + offsetY + correctionOffset + Math.sin(angleDir) * distance;
			if (myStrum.downScroll && isSustainNote)
			{
				if (PlayState.isPixelStage) y -= PlayState.daPixelZoom * 9.5;
				y -= (frameHeight * scale.y) - (Note.swagWidth / 2);
			}
		}
	}

	public function clipToStrumNote(myStrum:StrumNote):Void
	{
		final center:Float = myStrum.y + offsetY + Note.swagWidth / 2;
		if ((mustPress || !ignoreNote) && (wasGoodHit || (prevNote.wasGoodHit && !canBeHit)))
		{
			var swagRect:FlxRect = clipRect ?? new FlxRect(0, 0, frameWidth, frameHeight);

			if (myStrum.downScroll)
			{
				if (y - offset.y * scale.y + height >= center)
				{
					swagRect.width = frameWidth;
					swagRect.height = (center - y) / scale.y;
					swagRect.y = frameHeight - swagRect.height;
				}
			}
			else if (y + offset.y * scale.y <= center)
			{
				swagRect.y = (center - y) / scale.y;
				swagRect.width = width / scale.x;
				swagRect.height = (height / scale.y) - swagRect.y;
			}
			clipRect = swagRect;
		}
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;
		if (frames != null)
			frame = frames.frames[animation.frameIndex];
		return rect;
	}

	public function desat(){
		alpha = 0.7;
		multAlpha = 0.7;
		if (adjustColor != null) {
			adjustColor.brightness = 30;
			adjustColor.contrast = 25;
			adjustColor.saturation = -100;
		}
	}
}
