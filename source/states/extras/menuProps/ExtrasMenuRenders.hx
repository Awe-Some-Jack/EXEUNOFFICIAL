package states.extras.menuProps;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;

typedef RenderEntry = {
    var src:String;
    var animName:String;
    var type:String; 
}

class ExtrasMenuRenders extends FlxSpriteGroup{
    public var selectionIndex:Int = 0;
    private var rendersEntry:Array<RenderEntry> = [
        {
            src: "4",
            animName: "sunki",
            type: "atlas" 
        },
        {
            src: "3",
            animName: "characters",
            type: "sparrow"
        },
        {
            src: "2",
            animName: "garden",
            type: "atlas"
        },
        {
            src: "1",
            animName: "cutscene",
            type: "sparrow"
        },
        {
            src: "5",
            animName: "oro",
            type: "sparrow"
        },
        {
            src: "6",
            animName: "quien",
            type: "sparrow"
        }
    ];
    private var rendersList:Array<FlxSprite> = [];

    public function new (xX:Float = 0.0, yY:Float = 0.0){
        super(xX, yY);
     

        for (i in 0...rendersEntry.length){
            var entry = rendersEntry[i];
            if (entry == null) return;
            var isAtlasRender = entry.type == "atlas";
            trace("Index "+i+" is "+isAtlasRender);
            if (isAtlasRender){
            }else{
                var render = new FlxSprite(x,y);
                render.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(
                    Paths.getBitmapData('assets/exe/extras/EXTRAS RENDERS/'+entry.src+'.webp'),
                    openfl.utils.Assets.getText('assets/exe/extras/EXTRAS RENDERS/'+entry.src+'.xml')
                );
                render.animation.addByPrefix("render", entry.animName, 24, true);
                render.animation.play("render", true);
                render.ID = i;
                render.antialiasing = ClientPrefs.data.antialiasing;
                render.scale.set(0.5,0.5);
                render.visible = false;
                render.updateHitbox();
                add(render);
                rendersList.push(render);
            }
        }
    }

    public function swapRender(idx){
        var render = rendersList[idx];
        if (render == null) return;
     
        for (renders in rendersList){
            if (renders != null)
                if (renders != render) 
                    render.visible = false;
        }

        render.visible = true;
        FlxTween.cancelTweensOf(render);
        FlxTween.cancelTweensOf(render.scale);
        render.scale.set(0.5, 0.5);
        render.updateHitbox();
        render.x     = 200;
        render.y     = 120;
        render.alpha = 0;

        FlxTween.tween(render, {x: 750}, 0.5, {ease: FlxEase.expoOut});
        FlxTween.tween(render, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

        FlxTween.tween(render.scale, {x: 0.3, y: 0.3}, 0.5, {ease: FlxEase.expoOut, onUpdate: (_) -> {
            final cx = render.x;
            final cy = render.y;
            render.updateHitbox();
            render.x = cx;
            render.y = cy;
        }});
    }

    public function updateRender(elapsed:Float, selectionIndex:Int){
        this.selectionIndex = selectionIndex;
    }
}