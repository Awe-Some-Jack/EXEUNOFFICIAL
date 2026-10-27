import openfl.display.BlendMode;
import shaders.ColorSwap;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

var luzbf:FlxSprite;
var luzther:FlxSprite;
var ignoreLuther:Bool = false;
var ignoreBf:Bool = false;

var bfColor;
var dadColor;
var gfColor;

var colorSettings = {
    hue: -0.04,
    brightness: -0.75,
    saturation: -0.3
};

final WAIT_THRESHOLD:Float = 0.5;

function onCreatePost() {
    luzbf = new FlxSprite(2150, 100, Paths.image('herworld/luz'));
    luzbf.blend = BlendMode.ADD;
    luzbf.scale.set(1.25, 1.5);
    luzbf.visible = false;
    luzbf.alpha = 0;
    add(luzbf);

    luzther = new FlxSprite(900, 100, Paths.image('herworld/luz'));
    luzther.blend = BlendMode.ADD;
    luzther.scale.set(1.25, 1.5);
    luzther.visible = false;
    luzther.alpha = 0;
    add(luzther);

    bfColor = new ColorSwap();
    dadColor = new ColorSwap();
    gfColor = new ColorSwap();
}

var bfIdleTime:Float = 0;
var dadIdleTime:Float = 0;
var prevBfAlpha:Float = 0;
var prevDadAlpha:Float = 0;
function onUpdate(e) {
    if(curStep < 816 || curStep > 1500) return;

    if(boyfriend.animation.name == 'danceLeft' || boyfriend.animation.name == 'danceRight') bfIdleTime += e;
    else bfIdleTime = 0;
    if(dad.animation.name == 'idle') dadIdleTime += e;
    else dadIdleTime = 0;

    if(bfIdleTime > WAIT_THRESHOLD && luzbf.alpha == 1 && !ignoreBf) {
        FlxTween.tween(luzbf, {alpha: 0}, 0.5);
    }
    if(bfIdleTime < WAIT_THRESHOLD && luzbf.alpha < 0.01) {
        FlxTween.tween(luzbf, {alpha: 1}, 0.5);
    }

    if(dadIdleTime > WAIT_THRESHOLD && luzther.alpha == 1 && !ignoreLuther) {
        FlxTween.tween(luzther, {alpha: 0}, 0.5);
    }
    if(dadIdleTime < WAIT_THRESHOLD && luzther.alpha < 0.01) {
        FlxTween.tween(luzther, {alpha: 1}, 0.5);
    }

    if(!ClientPrefs.data.shaders) return;
    if(boyfriend.shader == null) {
        boyfriend.shader = bfColor.shader;
        for(strum in playerStrums.members) {
            strum.shader = bfColor.shader;
        }
    }
    if(dad.shader == null) {
        dad.shader = dadColor.shader;
        for(strum in opponentStrums.members) {
            strum.shader = dadColor.shader;
        }
    }
    if(gf.shader == null) gf.shader = gfColor.shader;


    if(prevBfAlpha != (prevBfAlpha = luzbf.alpha)) {
        bfColor.hue = colorSettings.hue * (1 - luzbf.alpha);
        bfColor.saturation = colorSettings.saturation * (1 - luzbf.alpha);
        bfColor.brightness = colorSettings.brightness * (1 - luzbf.alpha);

        gfColor.hue = colorSettings.hue * Math.max(1 - luzbf.alpha, 0.4);
        gfColor.saturation = colorSettings.saturation * Math.max(1 - luzbf.alpha, 0.4);
        gfColor.brightness = colorSettings.brightness * Math.max(1 - luzbf.alpha, 0.4);
    }

    if(prevDadAlpha != (prevDadAlpha = luzther.alpha)) {
        dadColor.hue = colorSettings.hue * (1 - luzther.alpha);
        dadColor.saturation = colorSettings.saturation * (1 - luzther.alpha);
        dadColor.brightness = colorSettings.brightness * (1 - luzther.alpha);
    }
}

function onSpawnNote(note:Note) {
    if(!ClientPrefs.data.shaders || curStep < 816 || curStep > 1500) return;
    if(note.mustPress){
        note.shader = bfColor.shader;
    }
    else {
        note.shader = dadColor.shader;
    }
}

function onStepHit() {
    switch(curStep) {
        case 816: luzbf.visible = luzther.visible = true;
        case 896: 
            ignoreLuther = true;
            FlxTween.tween(luzther, {alpha: 1}, 1);
        case 960, 1023, 1316: ignoreLuther = false;
        case 1216: ignoreLuther = true;
        case 1440: 
            ignoreLuther = ignoreBf = true;
        case 3020: 
            luzbf.visible = luzther.visible = false;
            boyfriend.shader = dad.shader = gf.shader = null;
    }
}