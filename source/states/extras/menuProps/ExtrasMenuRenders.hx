package states.extras.menuProps;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import animate.FlxAnimate;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.AtlasSpriteSettings;

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
            animName: "sunkia",
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
            if (isAtlasRender){
                var render = new FlxAnimate(-446, 8);
                
                render.frames = getAtlasRender(entry.src);
                render.anim.addBySymbol('render', entry.animName, 24, true);
                render.anim.play('render', true);
                render.ID = i;
                render.antialiasing = ClientPrefs.data.antialiasing;
                render.scale.set(0.5,0.5);
                render.visible = false;
                render.updateHitbox();
                add(render);
                rendersList.push(render);
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

    // var A:Float;
    // var B:Float;
    // var C:Float;

    // public function calculateX(i:Float, j:Float, k:Float):Float{
    //     return j * Math.sin(A)*Math.sin(B)*Math.cos(C) - k * Math.cos(A) * Math.sin(B) * Math.cos(C) + k*Math.sin(A) * Math.sin(C)+ i * Math.cos(B)*Math.cos(C);
    // }

    // public function calculateY(i:Float, j:Float, k:Float):Float{
    //     return j * Math.cos(A)*Math.cos(C)+ k * Math.sin(A)*Math.cos(C) - j* Math.sin(A)*Math.sin(B)*Math.sin(C) + k*Math.cos(A)*Math.sin(B)*Math.sin(C) - i*Math.cos(B)*Math.sin(C);
    // }    

    public function getAtlasRender(key:String, ?settings:AtlasSpriteSettings){
        try{
        final validatedSettings:AtlasSpriteSettings =
        {
            swfMode: settings?.swfMode ?? false,
            cacheOnLoad: settings?.cacheOnLoad ?? ClientPrefs.data.cacheOnGPU,
            filterQuality: settings?.filterQuality ?? (!ClientPrefs.data.lowQuality ? MEDIUM : LOW),
            spritemaps: settings?.spritemaps ?? null,
            metadataJson: settings?.metadataJson ?? null,
            cacheKey: settings?.cacheKey ?? null,
            uniqueInCache: settings?.uniqueInCache ?? false,
            onSymbolCreate: settings?.onSymbolCreate ?? null,
            applyStageMatrix: settings?.applyStageMatrix ?? false,
            useRenderTexture: settings?.useRenderTexture ?? false
        };

        var path = 'assets/exe/extras/EXTRAS RENDERS/'+key;

        return FlxAnimateFrames.fromAnimate(path, validatedSettings.spritemaps, validatedSettings.metadataJson, validatedSettings.cacheKey,
            validatedSettings.uniqueInCache, {
                swfMode: validatedSettings.swfMode,
                cacheOnLoad: validatedSettings.cacheOnLoad,
                filterQuality: validatedSettings.filterQuality,
                onSymbolCreate: validatedSettings.onSymbolCreate
            }
        );
        }catch(e:Dynamic){ trace("Error loading Atlas Frames: "+e); return null; }
    }

    public function swapRender(idx){
        var render = rendersList[idx];
        if (render == null) return;
     
        for (renders in rendersList){
            if (renders != null)
                if (renders != render) 
                    renders.active = renders.visible = false;
        }

        render.visible = true;
        render.active = true;
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
}