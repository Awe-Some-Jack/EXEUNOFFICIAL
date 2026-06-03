import flixel.FlxSprite;
import flixel.FlxG;
import states.PlayState as PS;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import flixel.FlxObject;
import flixel.util.FlxCollision;
import objects.VideoSprite;

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

var bubbleArray:Array<FlxSprite> = [];
var hues:Array<Float> = [];

var xOfs:Int = 0;
var yOfs:Int = 0;
var positionsArray:Array<Float> = [];
var bubbleCount:Int = 0;

var ribbons:VideoSprite;

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

// freecam zoom: .6
// freecam cams:
    // "BFx": 3335,
    // "BFy": 2098,

    // "DADx": 2965,
    // "DADy": 2098,

    // ofs 25

function onCreate() {
    wallpaper = new FlxSprite(0, 0, Paths.image('bg/desktop', 'SOINK'));
    wallpaper.antialiasing = true;
    wallpaper.scale.set(.44, .44);
    wallpaper.updateHitbox();
    wallpaper.cameras = [camBack];
    add(wallpaper);

    adobe1 = new FlxSprite(0, 0, Paths.image('bg/adobe', 'SOINK'));
    adobe1.antialiasing = true;
    adobe1.scale.set(1.6, 1.6);
    adobe1.updateHitbox();
    adobe1.x = 1771;
    adobe1.y = 1067;
    // adobe1.alpha = 0;
    addBehindDad(adobe1);

    adobe2 = new FlxSprite(0, 0, Paths.image('bg/adobe2', 'SOINK'));
    adobe2.antialiasing = true;
    adobe2.scale.set(1.6, 1.6);
    adobe2.updateHitbox();
    adobe2.x = 1771;
    adobe2.y = 1063;
    adobe2.alpha = 0;
    addBehindDad(adobe2);

    ribbons = new VideoSprite(-950, -450);
    ribbons.loadVideo(Paths.video('ribbons', 'SOINK'), true);
    ribbons.scale.set(1.5, 1.5);
    ribbons.scrollFactor.set(0, 0);
    ribbons.antialiasing = true;
    ribbons.updateHitbox();
    ribbons.cameras = [camGame];
    ribbons.pause();
    ribbons.alpha = 0.00001;
    addBehindDad(ribbons);

    trace("Stage created");
}
function onCreatePost() {
    positionsArray.push(boyfriend.x);
    positionsArray.push(boyfriend.y);
    positionsArray.push(dad.x);
    positionsArray.push(dad.y);
    positionsArray.push(adobe1.x);
    positionsArray.push(adobe1.y);

    for (i in 0...32) {
        var hue:Float = FlxG.random.float(0,360);
        hues.push(hue);
        
        var bubble = new FlxSprite(0, 720, Paths.image('bg/bubble', 'SOINK'));
        bubble.antialiasing = true;
        bubble.scale.set(0.45, 0.45);
        bubble.updateHitbox();

        bubble.x = -10-bubble.width;
        bubble.cameras = [camHUD];
        bubble.velocity.x = 100 + FlxG.random.float(0, 50);
        bubble.velocity.y = -(100 + FlxG.random.float(0, 50));
        bubble.elasticity = 1;
        bubble.ID = i;
        bubble.active = false;

        add(bubble);
        bubbleArray.push(bubble);
    }
}
function onUpdate(elapsed:Float) {
    for(i in 0...bubbleArray.length) {
        if(bubbleArray[i].active) {
            var b1 = bubbleArray[i];
            if(b1.ID < 32 && b1.x > 400) {
                b1.ID += 32;
            }
            hues[i]+=elapsed*40;
            // trace(hues[i]);
            b1.color = FlxColor.fromHSB(hues[i],1,1);

            if(b1.velocity.x >= 0) {
                b1.acceleration.x = 100;
            } else {
                b1.acceleration.x = -100;
            }

            if(b1.velocity.y < 0) {
                b1.acceleration.y = -100;
            } else {
                b1.acceleration.y = 100;
            }
            if(b1 == null || !b1.exists) continue;

            var minX:Float = -100;
            var maxX:Float = 1380 - b1.width;
            var minY:Float = -100;
            var maxY:Float = 820 - b1.height;

            if(b1.x < minX) {
                b1.x = minX;
                b1.velocity.x = Math.abs(b1.velocity.x);
            } else if(b1.x > maxX) {
                b1.x = maxX;
                b1.velocity.x = -Math.abs(b1.velocity.x);
            }

            if(b1.y < minY) {
                b1.y = minY;
                b1.velocity.y = Math.abs(b1.velocity.y);
            } else if(b1.y > maxY) {
                b1.y = maxY;
                b1.velocity.y = -Math.abs(b1.velocity.y);
            }

            for(j in (i + 1)...bubbleArray.length) {
                var b2 = bubbleArray[j];
                if(b2 == null || !b2.exists) continue;

                if(FlxG.overlap(b1, b2) && b1.ID > 31) {
                    if(FlxCollision.pixelPerfectCheck(b1, b2)) {
                        var center1X:Float = b1.x + (b1.width / 2);
                        var center1Y:Float = b1.y + (b1.height / 2);
                        
                        var center2X:Float = b2.x + (b2.width / 2);
                        var center2Y:Float = b2.y + (b2.height / 2);
                        
                        var diffX:Float = center2X - center1X;
                        var diffY:Float = center2Y - center1Y;

                        var oldB1X:Float = b1.velocity.x;
                        var oldB1Y:Float = b1.velocity.y;
                        var oldB2X:Float = b2.velocity.x;
                        var oldB2Y:Float = b2.velocity.y;
                        var transferFactor:Float = 0.4; 

                        if(Math.abs(diffX) > Math.abs(diffY)) {
                            if(oldB1X * oldB2X > 0) {
                                var avgX:Float = (oldB1X + oldB2X) / 2;
                                
                                b1.velocity.x = oldB1X + (avgX - oldB1X) * (transferFactor * 2);
                                b2.velocity.x = oldB2X + (avgX - oldB2X) * (transferFactor * 2);
                            } else {
                                var randomMult:Float = FlxG.random.float(0.1, 0.9);
                                var remainderMult:Float = 1.0 - randomMult;
                                
                                if(diffX > 0) {
                                    b1.velocity.x = -Math.abs(oldB2X) * randomMult;
                                    b2.velocity.x = Math.abs(oldB1X) * remainderMult;
                                } else {
                                    b1.velocity.x = Math.abs(oldB2X) * randomMult;
                                    b2.velocity.x = -Math.abs(oldB1X) * remainderMult;
                                }
                            }
                            
                            b1.velocity.y = oldB2Y * 0.5;
                            b2.velocity.y = oldB1Y * 0.5;
                        } else {
                            if(oldB1Y * oldB2Y > 0) {
                                var avgY:Float = (oldB1Y + oldB2Y) / 2;
                                
                                b1.velocity.y = oldB1Y + (avgY - oldB1Y) * (transferFactor * 2);
                                b2.velocity.y = oldB2Y + (avgY - oldB2Y) * (transferFactor * 2);
                            } 
                            else {
                                var randomMult:Float = FlxG.random.float(0.1, 0.9);
                                var remainderMult:Float = 1.0 - randomMult;
                                
                                if(diffY > 0) {
                                    b1.velocity.y = -Math.abs(oldB2Y) * randomMult;
                                    b2.velocity.y = Math.abs(oldB1Y) * remainderMult;
                                } else {
                                    b1.velocity.y = Math.abs(oldB2Y) * randomMult;
                                    b2.velocity.y = -Math.abs(oldB1Y) * remainderMult;
                                }
                            }
                            
                            b1.velocity.x = oldB2X * 0.5;
                            b2.velocity.x = oldB1X * 0.5;
                        }

                        if(diffX > 0) {
                            b1.x -= 2;
                            b2.x += 2;
                        } else {
                            b1.x += 2;
                            b2.x -= 2;
                        }
                    }
                }
            }
        }
    }

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
    if(curStep >= 768 && curStep % 5 == 0 && bubbleCount < 32) {
        bubbleArray[bubbleCount].active = true;
        bubbleArray[bubbleCount].velocity.x = 100 + FlxG.random.float(0, 200);
        bubbleArray[bubbleCount].velocity.y = -(100 + FlxG.random.float(0, 500));
        bubbleCount+=1;
    }
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

        case 256: // literally right after fullscreen
            adobe1.alpha = 0;
            adobe2.alpha = 1;
            dadGroup.x = 2020;
            dadGroup.y = 2066;
            boyfriendGroup.x = 3529;
            boyfriendGroup.y = 1735;
        case 512:
            ribbons.play();
        case 768: // bubbles
            dad.idleSuffix = '-alt';
            dad.recalculateDanceIdle();
        case 1024:
            for(bubble in bubbleArray) {
                FlxTween.tween(bubble, {alpha: 0}, 0.6, {ease: FlxEase.smoothStepOut, onComplete: function() {
                    bubble.active = false;
                }});
            }

            FlxTween.tween(ribbons, {alpha: 1}, 0.6, {ease: FlxEase.smoothStepOut});
            
        case 1280:
            dad.idleSuffix = '';
            dad.recalculateDanceIdle();
            FlxTween.tween(ribbons, {alpha: 0}, 0.6, {ease: FlxEase.smoothStepIn, onComplete: function() {
                ribbons.destroy();
            }});
    }
}
function onSectionHit(section:Dynamic) {
    mustHitSection = section.mustHitSection;
}