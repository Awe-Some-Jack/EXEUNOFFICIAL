package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

import openfl.display.BitmapData;

import shaders.BlueMaskShader;

enum ShapeTypes {
    CIRCLE;
    HEAD;
    KNUX;
    TAILS;
    EGG;
    OVAL;
    X;
    INFINITE;
    SANIC;
}

class CustomShapeTransition extends MusicBeatSubstate
{
    public static var finishCallback:Void->Void;
    public static var shape:ShapeTypes = HEAD;
    
    var time:Float;
    var maxScale:Float;
    var trans:FlxSprite;
    var top:FlxSprite;
    var bot:FlxSprite;
    var rig:FlxSprite;
    var lef:FlxSprite;
    var width:Int;
    var height:Int;
    var isTransIn:Bool;
    var fullBlackScreen:FlxSprite;
    var persistent:Bool = false;

    public function new(duration:Float, isTransIn:Bool)
    {
        this.time = duration;
        this.isTransIn = isTransIn;
        super();
    }

    override function create()
    {
        camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

        final zoom = Math.max(camera.zoom, 0.001);
        width = Math.ceil(FlxG.width / zoom);
        height = Math.ceil(FlxG.height / zoom);

        switch (shape) {
            case X, INFINITE:
                time = 0.8;
                maxScale = 20;

            case SANIC:
                maxScale = 8;

            case OVAL:
                time = 0.9;
                maxScale = 10;

            case _:
                maxScale = 6;
        }

        final head = Assets.getBitmapData('assets/exe/transitions/' + Std.string(shape).toLowerCase() + '.png');
        final black = new BitmapData(width, height, true, FlxColor.BLACK);
        final border = new BitmapData(width * 2, height * 2, true, FlxColor.BLACK);

        var shader = new BlueMaskShader();
        shader.mask.input = head;
        
        trans = new FlxSprite().loadGraphic(black);
        trans.setGraphicSize(width, height);
        trans.shader = shader;
        trans.screenCenter();
        trans.scrollFactor.set();
        trans.antialiasing = ClientPrefs.data.antialiasing;
        add(trans);

        top = new FlxSprite().loadGraphic(border);
        top.scrollFactor.set();
        top.antialiasing = ClientPrefs.data.antialiasing;
        add(top);

        bot = new FlxSprite().loadGraphic(border);
        bot.scrollFactor.set();
        bot.antialiasing = ClientPrefs.data.antialiasing;
        add(bot);

        lef = new FlxSprite().loadGraphic(border);
        lef.scrollFactor.set();
        lef.antialiasing = ClientPrefs.data.antialiasing;
        add(lef);

        rig = new FlxSprite().loadGraphic(border);
        rig.scrollFactor.set();
        rig.antialiasing = ClientPrefs.data.antialiasing;
        add(rig);

        fullBlackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        fullBlackScreen.scale.set(width, height);
        fullBlackScreen.updateHitbox();
        fullBlackScreen.screenCenter();
        fullBlackScreen.scrollFactor.set();
        fullBlackScreen.alpha = isTransIn ? 1 : 0;
        add(fullBlackScreen);

        updatePositions();
        
        if (!isTransIn) {
            trans.scale.set(maxScale, maxScale);
            FlxTween.tween(trans.scale, {x: 0, y: 0}, time, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    FlxTween.tween(fullBlackScreen, {alpha: 1}, 0.1, {
                        onComplete: finish
                    });
                }
            });
        } else {
            fullBlackScreen.alpha = 0;
            trans.scale.set(0, 0);
            FlxTween.tween(trans.scale, {x: maxScale, y: maxScale}, time, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    FlxTween.tween(fullBlackScreen, {alpha: 0}, 0.1, {
                        onComplete: finish
                    });
                }
            });
        }
        
        super.create();
    }

    function updatePositions()
    {
        trans.updateHitbox();
        trans.screenCenter();
        
        if (lef != null) {
            lef.x = trans.x - lef.width;
            lef.y = trans.y - (lef.height - trans.height) / 2;
        }
        if (rig != null) {
            rig.x = trans.x + trans.width;
            rig.y = trans.y - (rig.height - trans.height) / 2;
        }
        if (bot != null) {
            bot.y = trans.y + trans.height;
            bot.x = trans.x - (bot.width - trans.width) / 2;
        }
        if (top != null) {
            top.y = trans.y - top.height;
            top.x = trans.x - (top.width - trans.width) / 2;
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        updatePositions();
    }

    function finish(_)
    {
        if (finishCallback != null)
        {
            finishCallback();
            finishCallback = null;
        }
    }

    public static function getShapeByString(shapeString:String):ShapeTypes
    {
        var shit:String = shapeString.trim().toLowerCase();
        return switch(shit)
        {
            case 'x': X;
            case 'infinite': INFINITE;
            case 'circle': CIRCLE;
            case 'oval': OVAL;
            case 'egg' | 'eggman': EGG;
            case 'tails': TAILS;
            case 'knux' | 'knuckles': KNUX;
            case 'sanic': SANIC;
            default: HEAD;
        }
    }
    
    override function destroy()
    {
        super.destroy();
    }
}
