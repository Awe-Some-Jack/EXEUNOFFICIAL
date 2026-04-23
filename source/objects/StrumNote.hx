package objects;

import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	public var useRGBShader:Bool = true;

	/** Extra data map for Lua/HScript access. **/
	public var extraData:Map<String, Dynamic> = new Map();

	private var noteData:Int = 0;
	private var player:Int = 0;

	public var texture(default, set):String = null;
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

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;

		if (PlayState.SONG != null && PlayState.SONG.disableNoteRGB)
			useRGBShader = false;

		final arr:Array<FlxColor> = PlayState.isPixelStage
			? ClientPrefs.data.arrowRGBPixel[leData]
			: ClientPrefs.data.arrowRGB[leData];

		if (arr != null && leData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		var skin:String = (PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
			? PlayState.SONG.arrowSkin
			: Note.defaultNoteSkin;

		final customSkin:String = skin + Note.getNoteSkinPostfix();
		if (Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		texture = skin;
		scrollFactor.set();
		playAnim('static');
	}

	public function reloadNote():Void
	{
		final lastAnim:Null<String> = animation.curAnim?.name;

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

			antialiasing = ClientPrefs.data.antialiasing;
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
		updateHitbox();

		if (lastAnim != null)
			playAnim(lastAnim, true);
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
		//lol
		x = (FlxG.width / 2) + ((100 + (5 + Note.swagWidth) * (player == 1 ? noteData : (4 - noteData))) * (player == 1 ? 1 : -1));
	}

	override function update(elapsed:Float):Void
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, force:Bool = false):Void
	{
		animation.play(anim, force);
		if (animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		rgbShader.enabled = useRGBShader && animation.curAnim != null && animation.curAnim.name != 'static';
	}
}
