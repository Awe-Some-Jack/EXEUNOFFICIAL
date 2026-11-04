package states.substates;

import openfl.utils.Assets as AssetPaths;
import states.SoundTest;
#if VIDEOS_ALLOWED
import objects.VideoSprite;
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

	var video:VideoSprite;
	var image:FlxSprite;

	override function create()
	{
		super.create();

		final blackBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackBG.screenCenter();
		add(blackBG);

		if (isVideo) {
			video = new VideoSprite(0, 0, true);
			
			video.onFormat(() -> {
				final scale:Float = Math.min(FlxG.width / video.video.frameWidth, FlxG.height / video.video.frameHeight);
				video.setGraphicSize(Math.floor(video.video.frameWidth * scale), Math.floor(video.video.frameHeight * scale));
				video.screenCenter();
			});
			video.onEnd(onVideoEnd, true);
			add(video);

            if (video.loadVideo(daPath))
                video.playDelayed();
		}
		else
		{
			image = new FlxSprite();
			image.loadGraphic(Paths.getBitmapData(daPath));
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
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.SPACE #if mobile || FlxG.mouse.justPressed #end)
			{
				transitioning = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
			}
		}
	}

	function onVideoEnd():Void
	{
		remove(video);
		video.destroy();
		video = null;
		close();
	}

	function setImageSize(obj:FlxSprite, targetWidth:Float, targetHeight:Float, ?offset:Float = 1, ?updHitbox:Bool = true):Void
	{
		final scaleFactor:Float = Math.min(targetWidth / obj.width, targetHeight / obj.height);
		
		obj.setGraphicSize(Math.floor(obj.width * scaleFactor * offset), Math.floor(obj.height * scaleFactor * offset));
		if (updHitbox) obj.updateHitbox();
	}
}