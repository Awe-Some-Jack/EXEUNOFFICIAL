import flixel.FlxSprite;
import flixel.FlxG;
import states.PlayState as PS;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;

using StringTools;

var wallpaper:FlxSprite;
var adobe1:FlxSprite;
var adobe2:FlxSprite;

var tweenX:FlxTween;
var tweenY:FlxTween;
var tweenBFX:FlxTween;
var tweenBFY:FlxTween;
var tweenDADX:FlxTween;
var tweenDADY:FlxTween;

var mustHitSection:Bool = false;

var xOfs:Int = 0;
var yOfs:Int = 0;
var positionsArray:Array<Float> = [];
// start zoom: 0.2755
// start cams:
    // "BFx": 3635,
    // "BFy": 2048,

    // "DADx": 3635,
    // "DADy": 2048,
// start positions:
	// "boyfriend": [3578, 1700],
	// "girlfriend": [0, 0],
	// "opponent": [2075, 2030],

// fullscreen zoom: 0.325
// fullscreen cams:
    // "BFx": 3635,
    // "BFy": 2098,

    // "DADx": 3635,
    // "DADy": 2098,
// fullscreen positions:
	// "boyfriend": [3529, 1735],
	// "girlfriend": [0, 0],
	// "opponent": [2020, 2066],

function onCreate() {
    wallpaper = new FlxSprite(0, 0, Paths.image('bg/desktop'), 'SOINK');
    wallpaper.antialiasing = true;
    wallpaper.scale.set(.44, .44);
    wallpaper.updateHitbox();
    wallpaper.cameras = [camBack];
    add(wallpaper);

    adobe1 = new FlxSprite(0, 0, Paths.image('bg/adobe'), 'SOINK');
    adobe1.antialiasing = true;
    adobe1.scale.set(1.6, 1.6);
    adobe1.updateHitbox();
    adobe1.x = 1771;
    adobe1.y = 1067;
    // adobe1.alpha = 0;
    addBehindDad(adobe1);

    adobe2 = new FlxSprite(0, 0, Paths.image('bg/adobe2'), 'SOINK');
    adobe2.antialiasing = true;
    adobe2.scale.set(1.6, 1.6);
    adobe2.updateHitbox();
    adobe2.x = 1771;
    adobe2.y = 1063;
    adobe2.alpha = 0;
    addBehindDad(adobe2);

    trace("Stage created");
}
function onCreatePost() {
    positionsArray.push(boyfriend.x);
    positionsArray.push(boyfriend.y);
    positionsArray.push(dad.x);
    positionsArray.push(dad.y);
    positionsArray.push(adobe1.x);
    positionsArray.push(adobe1.y);
}
function onUpdate(elapsed:Float) {
    if(curStep < 248) {
        if(tweenX != null) tweenX.cancel();
        if(tweenY != null) tweenY.cancel();
        if(tweenBFX != null) tweenBFX.cancel();
        if(tweenBFY != null) tweenBFY.cancel();
        if(tweenDADX != null) tweenDADX.cancel();
        if(tweenDADY != null) tweenDADY.cancel();
        
        if(mustHitSection)
            currentAnim = boyfriend.getAnimationName();
        else
            currentAnim = dad.getAnimationName();

        if(currentAnim.startsWith("singLEFT")) {
            xOfs = -30;
            yOfs = 0;
        } else if(currentAnim.startsWith("singDOWN")) {
            xOfs = 0;
            yOfs = 30;
        } else if(currentAnim.startsWith("singUP")) {
            xOfs = 0;
            yOfs = -30;
        } else if(currentAnim.startsWith("singRIGHT")) {
            xOfs = 30;
            yOfs = 0;
        } else if(currentAnim.startsWith("idle")) {
            xOfs = 0;
            yOfs = 0;
        }

        tweenX = FlxTween.tween(adobe1, {x: positionsArray[4]+xOfs}, 0.3, {ease: FlxEase.smoothStepOut});
        tweenY = FlxTween.tween(adobe1, {y: positionsArray[5]+yOfs}, 0.3, {ease: FlxEase.smoothStepOut});
        tweenBFX = FlxTween.tween(boyfriend, {x: positionsArray[0]+xOfs}, 0.3, {ease: FlxEase.smoothStepOut});
        tweenBFY = FlxTween.tween(boyfriend, {y: positionsArray[1]+yOfs}, 0.3, {ease: FlxEase.smoothStepOut});
        tweenDADX = FlxTween.tween(dad, {x: positionsArray[2]+xOfs}, 0.3, {ease: FlxEase.smoothStepOut});
        tweenDADY = FlxTween.tween(dad, {y: positionsArray[3]+yOfs}, 0.3, {ease: FlxEase.smoothStepOut});
    }
}
function onStepHit() {
    switch(curStep) {
        case 248:
            if(tweenX != null) tweenX.cancel();
            if(tweenY != null) tweenY.cancel();
            if(tweenBFX != null) tweenBFX.cancel();
            if(tweenBFY != null) tweenBFY.cancel();
            if(tweenDADX != null) tweenDADX.cancel();
            if(tweenDADY != null) tweenDADY.cancel();

            xOfs = 0;
            yOfs = 0;

            tweenX = FlxTween.tween(adobe1, {x: positionsArray[4]+xOfs}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenY = FlxTween.tween(adobe1, {y: positionsArray[5]+yOfs}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenBFX = FlxTween.tween(boyfriend, {x: positionsArray[0]+xOfs}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenBFY = FlxTween.tween(boyfriend, {y: positionsArray[1]+yOfs}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenDADX = FlxTween.tween(dad, {x: positionsArray[2]+xOfs}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenDADY = FlxTween.tween(dad, {y: positionsArray[3]+yOfs}, 0.3, {ease: FlxEase.smoothStepOut});
        case 252: // fullscreen
            // wallpaper.scale.set(1.2835,1.2835);
            // wallpaper.y = 781;
            adobe2.scale.y = 1.62;
            // game.cameraSpeed = 12000;
            // var mid:FlxTween = FlxTween.tween(wallpaper.scale, {x: 1.2835, y: 1.2835}, 0.35, {ease: FlxEase.linear});
            // FlxTween.tween(wallpaper, {y: 781}, 0.35, {ease: FlxEase.linear});
            FlxTween.tween(camGame.targetOffset, {y: 45}, 0.35, {ease: FlxEase.linear});
            tweenCamZoom = true;
            FlxTween.tween(camGame, {zoom: 0.345}, 0.35, {ease: FlxEase.linear,
                onComplete: function(twn:FlxTween) {
                    trace("mid");
                    tweenCamZoom = false;
                    gameplayCam.settings.OverrideZoom = true;
                    gameplayCam.overrideZoomValue = 0.345;
                    defaultCamZoom = 0.345;
                    camGame.zoom = 0.345;
                },
                onUpdate: function(twn:FlxTween) {
        
                }
            });
        case 256: // literally right after fullscreen
            adobe1.alpha = 0;
            adobe2.alpha = 1;
            dadGroup.x = 2020;
            dadGroup.y = 2066;
            boyfriendGroup.x = 3529;
            boyfriendGroup.y = 1735;
        case 768: // bubbles
            dad.idleSuffix = '-alt';
            dad.recalculateDanceIdle();
        case 1280:
            dad.idleSuffix = '';
            dad.recalculateDanceIdle();
    }
}
function onSectionHit(section:Dynamic) {
    mustHitSection = section.mustHitSection;
}