package states;

import Main;
import flixel.input.keyboard.FlxKey;
import states.Exetitle;
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
		});
		add(video);
    }
}