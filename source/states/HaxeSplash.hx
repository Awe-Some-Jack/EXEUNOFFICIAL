package states;

import Main;
import flixel.input.keyboard.FlxKey;
import states.Exetitle;
import backend.GifDecoder;
#if hxvlc
import hxvlc.flixel.FlxVideoSprite;
#elseif hxCodec
import hxcodec.flixel.FlxVideoSprite;
#end

class HaxeSplash extends MusicBeatState
{
    var video:FlxVideoSprite;
    override function create() 
    {
		FlxG.mouse.visible = false;
        Main.fpsVar.visible = false;
		video = new FlxVideoSprite();
		#if hxvlc video.load(Paths.video('HaxeFlixelIntro')); #end
		video.bitmap.onEndReached.add(function() {
			FlxG.switchState(() -> new Exetitle());
		});
		video.play(#if hxCodec Paths.video('HaxeFlixelIntro') #end);
		video.bitmap.onFormatSetup.add(()->{
			video.setGraphicSize(FlxG.width, FlxG.height);
			video.screenCenter();
			var logoPath:String = 'assets/exe/title/logo/';
			Assets.getBitmapData(logoPath + 'ring.png');
			Assets.getBitmapData(logoPath + 'bandana.png');
			Assets.getBitmapData(logoPath + 'sonic.png');
			Assets.getBitmapData(logoPath + 'eyes.png');
			Assets.getBitmapData('assets/exe/title/spikesdown.png');
			Assets.getBitmapData('assets/exe/parallax/parallaxarrow.png');
			Assets.getSound('assets/exe/music/menu.ogg');
		});
		add(video);
    }
}