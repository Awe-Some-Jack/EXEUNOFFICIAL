package states.substates;


import states.SoundTest;
#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#elseif hxCodec
import hxcodec.flixel.FlxVideoSprite;
#end

class SoundTestSubState extends MusicBeatSubstate
{
	var isVideo:Bool;
	var daPath:String;

	public function new(isVideo:Bool, daPath:String)
	{
		super();
		this.isVideo = isVideo;
		this.daPath = daPath;
	}

	var video:FlxVideoSprite;
	var image:FlxSprite;

	override function create()
	{
		super.create();

		var blackBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackBG.screenCenter();
		add(blackBG);

		if (isVideo) {
			video = new FlxVideoSprite();
			#if hxvlc video.load(daPath); #end
			video.bitmap.onEndReached.add(onVideoEnd);
			video.play(#if hxCodec daPath #end);
			video.bitmap.onFormatSetup.add(()->{
				//video.setGraphicSize(FlxG.width, FlxG.height);
				setImageSize(video, FlxG.width, FlxG.height, 1, false);
				video.screenCenter();
			});
			add(video);
		}
		else
		{
			image = new FlxSprite();
			image.loadGraphic(Assets.getBitmapData(daPath));
			setImageSize(image, FlxG.width, FlxG.height);
			image.screenCenter();
			add(image);
			//hi
		}
	}

	var transitioning:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (transitioning) return;

		if (isVideo)
		{
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.SPACE)
				onVideoEnd();
		}
		else
		{
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.SPACE)
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
			}
		}
	}

	function onVideoEnd():Void
	{
		video.bitmap.onEndReached.removeAll();
		remove(video);
		video.destroy();
		video = null;
		close();
	}

	function setImageSize(obj:FlxSprite, targetWidth:Float, targetHeight:Float, ?offset:Float = 1, ?updHitbox:Bool = true):Void
	{
		var scaleFactor:Float = Math.min(targetWidth / obj.width, targetHeight / obj.height);
		
		obj.setGraphicSize(Math.floor(obj.width * scaleFactor * offset), Math.floor(obj.height * scaleFactor * offset));
		if (updHitbox) obj.updateHitbox();
	}
}