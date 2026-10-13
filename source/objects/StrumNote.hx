package objects;

import backend.animation.PsychAnimationController;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;

class StrumNote extends FlxSprite
{
	public var resetAnim:Float = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;

	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	/** Extra data map for Lua/HScript access. **/
	public var extraData:Map<String, Dynamic> = new Map();

	private var noteData:Int = 0;
	private var player:Int = 0;

	public var isPlayer:Bool = false;
	public var inEditor:Bool = false;

	public var texture(default, set):String = null;

	public var baseScaleX:Float = 0;
	var baseScaleY:Float = 0;

	public var useVSliceReceptorFeature:Bool = true;

	public var holdTimer:Float = 0.0;
	public var confirmDuration:Float = 4.0;

	/**
     * set `shakeDuration` -1 to start a loop shake, set 0 to cancel it :3
    **/
    public var shakeDuration:Float = 0;
    public var shakeIntensity:Float = 0;

    private var baseOffset:FlxPoint = FlxPoint.get(0, 0);

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		super(x, y);

		animation = new PsychAnimationController(this);

		noteData = leData;
		this.player = player;
		this.ID = noteData;
		this.isPlayer = player == 1;

		var skin:String = (PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
			? PlayState.SONG.arrowSkin
			: Note.defaultNoteSkin;

		final customSkin:String = skin + Note.getNoteSkinPostfix();

		for (ext in Paths.IMAGE_EXTS) 
		{
			if (Paths.fileExists('images/$customSkin.$ext', IMAGE)) 
			{
				skin = customSkin;
				break;
			}
		}

		texture = skin;
		scrollFactor.set();
		playAnim('static');
	}

	public function reloadNote():Void
	{
		final lastAnim:Null<String> = animation.curAnim?.name;
		final hadFrames:Bool = frames != null;
		final prevScaleX:Float = scale.x;
		final prevScaleY:Float = scale.y;
		final prevWidth:Float = width;
		final prevHeight:Float = height;
		final prevOffsetX:Float = offset.x;
		final prevOffsetY:Float = offset.y;
		final hitboxStale:Bool = hadFrames && (Math.abs(width - Math.abs(scale.x) * frameWidth) > 1 || Math.abs(height - Math.abs(scale.y) * frameHeight) > 1);

		if (PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			final fw:Int = Math.floor(width / 4);
			final fh:Int = Math.floor(height / 5);
			loadGraphic(Paths.image('pixelUI/' + texture), true, fw, fh);

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green',  [6]);
			animation.add('red',    [7]);
			animation.add('blue',   [5]);
			animation.add('purple', [4]);

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static',  [0]);
					animation.add('pressed', [4, 8],   12, false);
					animation.add('confirm', [12, 16], 12, false);
				case 1:
					animation.add('static',  [1]);
					animation.add('pressed', [5, 9],   12, false);
					animation.add('confirm', [13, 17], 12, false);
				case 2:
					animation.add('static',  [2]);
					animation.add('pressed', [6, 10],  12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static',  [3]);
					animation.add('pressed', [7, 11],  12, false);
					animation.add('confirm', [15, 19], 12, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green',  'arrowUP');
			animation.addByPrefix('blue',   'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red',    'arrowRIGHT');

			setGraphicSize(Std.int(width * 0.7));

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static',  'arrowLEFT');
					animation.addByPrefix('pressed', 'left press',   24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static',  'arrowDOWN');
					animation.addByPrefix('pressed', 'down press',   24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static',  'arrowUP');
					animation.addByPrefix('pressed', 'up press',   24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static',  'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press',   24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}
		final newBaseX:Float = scale.x;
		final newBaseY:Float = scale.y;
		if (hadFrames && baseScaleX > 0 && baseScaleY > 0)
			scale.set(newBaseX * (prevScaleX / baseScaleX), newBaseY * (prevScaleY / baseScaleY));
		baseScaleX = newBaseX;
		baseScaleY = newBaseY;

		if (hitboxStale)
		{
			width = prevWidth;
			height = prevHeight;
			offset.set(prevOffsetX, prevOffsetY);
		}
		else updateHitbox();

		if (lastAnim != null)
			playAnim(lastAnim, true);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
	{
		animOffsets.set(name, [x, y]);
	}

	/** Positions this strum in the player lane. Call after construction if needed. **/
	public function playerPosition():Void
	{
		x += Note.swagWidth * noteData;
		x += 50;
		x += (FlxG.width / 2) * player;
	}

	public function centerStrums():Void
	{
		x = (FlxG.width / 2) + ((100 + (5 + Note.swagWidth) * (player == 1 ? noteData : (4 - noteData))) * (player == 1 ? 1 : -1));
	}

	override function update(elapsed:Float):Void
	{
		if (!inEditor){
			if (shakeDuration != 0) 
			{
				if (shakeDuration > 0)
					shakeDuration -= elapsed;

				offset.x = baseOffset.x + FlxG.random.float(-shakeIntensity, shakeIntensity);
				offset.y = baseOffset.y + FlxG.random.float(-shakeIntensity, shakeIntensity);

				if (shakeDuration <= 0 && shakeDuration != -1)
				{
					shakeDuration = 0;
					offset.set(baseOffset.x, baseOffset.y);
				}
			} 
			else 
			{
				offset.x = FlxMath.lerp(offset.x, baseOffset.x, FlxMath.bound(elapsed * 12, 0, 1));
				offset.y = FlxMath.lerp(offset.y, baseOffset.y, FlxMath.bound(elapsed * 12, 0, 1));
			}

			if (resetAnim > 0)
			{
				resetAnim -= elapsed;
				if (resetAnim <= 0)
				{
					playAnim('static');
					resetAnim = 0;
				}
			}
		}
		super.update(elapsed);

		if (!useVSliceReceptorFeature || inEditor) return;

		if (animation.curAnim != null && animation.curAnim.name.startsWith('confirm'))
		{
			holdTimer += elapsed;
		}

		if (holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * confirmDuration)
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('confirm')){
				if (isPlayer){
					playAnim("pressed");
				}
			}else{
				playAnim("static");
			}
			holdTimer = 0;
		}
	}

	public function playAnim(anim:String, force:Bool = false, ?note:Note=null):Void
	{
		animation.play(anim, force);
		if (animation.curAnim != null)
		{
			if (anim == "confirm"){
				holdTimer = 0;
				if (note != null)
				{
					confirmDuration = note.isSustainNote ? 1.3 : 4;
				}
			}

			if (PlayState.isPixelStage)
			{
				centerOffsets();
				centerOrigin();
			}
			else
			{
				if (animOffsets.exists(anim))
				{
					var daOffset:Array<Float> = animOffsets.get(anim);
					final staticOffset:Array<Float> = animOffsets.get('static');
					final scaleRatio:Float = baseScaleX > 0 ? scale.x / baseScaleX : 1;
					if (staticOffset != null && scaleRatio != 1)
						offset.set(staticOffset[0] + (daOffset[0] - staticOffset[0]) * scaleRatio, staticOffset[1] + (daOffset[1] - staticOffset[1]) * scaleRatio);
					else
						offset.set(daOffset[0], daOffset[1]);
				}
				else
				{
					centerOffsets();
					centerOrigin();
				}
			}

			baseOffset.set(offset.x, offset.y);
		}
	}

	/**
     * Call this fuction to active shaking
     * @param duration -1 to loop, 0 to force stop it
     * @param intensity displacement pixel force
    **/
    public function shakeStrum(intensity:Float, duration:Float) {
        this.shakeIntensity = intensity;
        this.shakeDuration = duration;
    }
}