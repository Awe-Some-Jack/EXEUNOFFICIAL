import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;

import psychlua.LuaUtils as LuaUtils;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import openfl.display.BitmapData;

import objects.VideoSprite;
import states.PlayState as PS;
import haxe.Timer as Timer;

using StringTools;

var wallpaper:FlxSprite;
var lockscreen:FlxSprite;
var adobe1:FlxSprite;
var adobe2:FlxSprite;
var error:FlxSprite;
var cracker:FlxSprite;
var black:FlxSprite;
var cursorLoad:FlxSprite;
var ribbons:VideoSprite;
var intro:VideoSprite;
var matrix:FlxBackdrop;
var speedLines:FlxBackdrop;

var tweenX:FlxTween;
var tweenY:FlxTween;
var tweenBFX:FlxTween;
var tweenBFY:FlxTween;
var tweenDADX:FlxTween;
var tweenDADY:FlxTween;
var tweenHUDX:FlxTween;
var tweenHUDY:FlxTween;

var mustHitSection:Bool = false;
final debugMode = false;
var alreadyPlayed:Bool = false;
var alreadyPlayed2:Bool = false;

var bubbleArray:Array<FlxSprite> = [];
var hues:Array<Float> = [];

var xOfs:Int = 0;
var yOfs:Int = 0;
var positionsArray:Array<Float> = [];
var luaObjects:Array<String> = ['hbBG', 'iconOpp', 'iconBF', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];
var bubbleCount:Int = 0;

// todo:
// gameover

function onCreate() {
    wallpaper = new FlxSprite(0, 0, Paths.image('bg/desktop', 'SOINK'));
    wallpaper.scale.set(.44, .44);
    wallpaper.updateHitbox();
    wallpaper.cameras = [camBack];
    add(wallpaper);

    lockscreen = new FlxSprite(-3000, -1500, Paths.image('bg/lockscreen', 'SOINK'));
    lockscreen.scale.set(1.6, 1.6);
    lockscreen.updateHitbox();
    lockscreen.alpha = 0.00001;
    lockscreen.cameras = [camBack];
    add(lockscreen);

    adobe1 = new FlxSprite(0, 0, Paths.image('bg/adobe', 'SOINK'));
    adobe1.scale.set(1.6, 1.6);
    adobe1.updateHitbox();
    adobe1.x = 1771;
    adobe1.y = 1067;
    addBehindDad(adobe1);

    adobe2 = new FlxSprite(0, 0, Paths.image('bg/adobe2', 'SOINK'));
    adobe2.scale.set(1.6, 1.6);
    adobe2.updateHitbox();
    adobe2.x = 1771;
    adobe2.y = 1063;
    adobe2.alpha = 0.00001;
    addBehindDad(adobe2);

    ribbons = new VideoSprite(-350, -450);
    ribbons.loadVideo(Paths.video('ribbons', 'SOINK'), true);
    ribbons.scale.set(1.5, 1.5);
    ribbons.scrollFactor.set(0, 0);
    ribbons.updateHitbox();
    ribbons.cameras = [camGame];
    ribbons.pause();
    ribbons.alpha = 0.00001;
    addBehindDad(ribbons);

    bluescreen = new FlxSprite(0, 0, Paths.image('bg/bluescreen', 'SOINK'));
    bluescreen.updateHitbox();
    bluescreen.scrollFactor.set(0, 0);
    bluescreen.scale.set(0.4, 0.4);
    bluescreen.cameras = [camGame];
    bluescreen.screenCenter();
    bluescreen.x += 170;
    bluescreen.y += 20;
    bluescreen.alpha = 0.00001;
    addBehindDad(bluescreen);

    matrix = new FlxBackdrop(0x11);
    matrix.frames = Paths.getSparrowAtlas('bg/matrix', 'SOINK');
    matrix.animation.addByPrefix('idle', 'idle', 96);
    matrix.animation.play('idle',true,true);
    matrix.scale.x = 2;
    matrix.scale.y = 2;
    matrix.antialiasing = false;
    matrix.scrollFactor.set(0.2, 0.2);
    matrix.alpha = 0.00001;
    addBehindDad(matrix);

    intro = new VideoSprite(0, 0);
    intro.loadVideo(Paths.video('startup', 'SOINK'), true);
    intro.cameras = [camOther];
    intro.pause();
    intro.alpha = 1;
    add(intro);

    cracker = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    cracker.alpha = 0.00001;
    cracker.scale.set(2, 2);
    cracker.screenCenter();
    cracker.scrollFactor.set();
    cracker.blend = LuaUtils.blendModeFromString('add');
    cracker.cameras = [camVideo];
    add(cracker);

    black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    black.alpha = 1;
    black.scale.set(2, 2);
    black.screenCenter();
    black.scrollFactor.set();
    black.cameras = [camVideo];
    add(black);

    error = new FlxSprite(0, 0, Paths.image('bg/fatal-error', 'SOINK'));
    error.scale.set(0, 0);
    error.updateHitbox();
    error.cameras = [camOther];
    error.screenCenter();
    error.antialiasing = false;
    add(error);

    cursorLoad = new FlxSprite(300, 400);
    cursorLoad.frames = Paths.getSparrowAtlas('bg/load', 'SOINK');
    cursorLoad.animation.addByPrefix('idle', 'idle', 24);
    cursorLoad.animation.play('idle',true);
    cursorLoad.scale.set(0.8, 0.8);
    cursorLoad.cameras = [camOther];
    cursorLoad.alpha = 0.00001;
    add(cursorLoad);
}

function onCreatePost() {
    for(objs in [boyfriend.x, boyfriend.y, dad.x, dad.y, adobe1.x, adobe1.y, camHUD.x, camHUD.y]) {
        positionsArray.push(objs);
    }

    for(i in 0...32) {
        var hue:Float = FlxG.random.float(0,360);
        hues.push(hue);
        
        var bubble = new FlxSprite(0, FlxG.height, Paths.image('bg/bubble', 'SOINK'));
        bubble.scale.set(0.45, 0.45);
        bubble.updateHitbox();

        bubble.x = -10-bubble.width;
        bubble.cameras = [camOther];
        bubble.velocity.x = 100 + FlxG.random.float(0, 50);
        bubble.velocity.y = -(100 + FlxG.random.float(0, 50));
        bubble.elasticity = 1;
        bubble.ID = i;
        bubble.active = false;
        add(bubble);
        bubbleArray.push(bubble);
    }

    speedLines = new FlxBackdrop(Paths.image('bg/speedLines'), 0x11);
    speedLines.scale.x = 1;
    speedLines.scale.y = 1;
    speedLines.velocity.y = -1475;
    speedLines.scrollFactor.set(.2, .2);
    speedLines.cameras = [camGame];
    speedLines.alpha = 0.00001;
    add(speedLines);

    camHUD.alpha = 0.00001;
}

function onSongStart() {
    intro.play();
    alreadyPlayed = true;
    intro.width = FlxG.width;
}

function onPause() {
    intro.pause();
    ribbons.pause();
}

function onResume() {
    if(alreadyPlayed) intro.play();
    if(alreadyPlayed2) ribbons.play();
}

function goodNoteHitPre(note:Note):Void {
	boyfriend.idleSuffix = note.noteType == 'Alt Animation' ? '-alt' : '';
	boyfriend.recalculateDanceIdle();
}

function onUpdate(elapsed:Float) {
    // formatting 🗣️🗣️🗣️
    if(!debugMode) FlxG.fullscreen = true;

    for(i in 0...bubbleArray.length) {
        if(bubbleArray[i].active) {
            var b1 = bubbleArray[i];
            if(b1.ID < 32 && b1.x > 400) {
                b1.ID += 32;
            }

            hues[i] += elapsed * 40;
            b1.color = FlxColor.fromHSB(hues[i],1,1);

            b1.acceleration.x = b1.velocity.x >= 0 ? 100 : -100;
            b1.acceleration.y = b1.velocity.y >= 0 ? 100 : -100;

            if(b1 == null || !b1.exists) continue;

            var minX:Float = -100;
            var maxX:Float = FlxG.width + 100 - b1.width;
            var minY:Float = -100;
            var maxY:Float = FlxG.height + 100 - b1.height;
            
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
                    var center1X:Float = b1.x + (b1.width / 2);
                    var center1Y:Float = b1.y + (b1.height / 2);
                    
                    var center2X:Float = b2.x + (b2.width / 2);
                    var center2Y:Float = b2.y + (b2.height / 2);
                    
                    var diffX:Float = center2X - center1X;
                    var diffY:Float = center2Y - center1Y;
                    
                    var distanceSquared:Float = (diffX * diffX) + (diffY * diffY);
                    var radiusSum:Float = (b1.width / 2) + (b2.width / 2);
                    
                    if(distanceSquared <= radiusSum * radiusSum) {
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
                            } else {
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
        if(tweenHUDX != null) tweenHUDX.cancel();
        if(tweenHUDY != null) tweenHUDY.cancel();
        
        currentAnim = mustHitSection ? boyfriend.getAnimationName() : dad.getAnimationName();
            
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
        tweenHUDX = FlxTween.tween(camHUD, {x: positionsArray[6]+xOfs/4}, 0.3, {ease: FlxEase.smoothStepOut});
        tweenHUDY = FlxTween.tween(camHUD, {y: positionsArray[7]+yOfs/4}, 0.3, {ease: FlxEase.smoothStepOut});
    }

    if(curStep >= 1536 && curStep < 1792) camBack.zoom = camGame.zoom;

    if(curStep >= 1792) {
        matrix.animation.curAnim.frameRate += elapsed;
        speedLines.velocity.y -= elapsed;
    }

    if(curStep > 1792) {
        if(curStep < 2096) camHUD.y = Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * 1.0) * 15;
	    camHUD.angle = Math.sin((Conductor.songPosition / 1200) * (Conductor.bpm / 60) * -1.0) * 1.2;
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
        case 128:
            camHUD.alpha = 1;
            black.alpha = 0;
            crackerFlash(1.4, 1);
            if(intro != null) intro.alpha = 0;

        case 192:
            crackerFlash(2.1, 1);

        case 248:
            if(tweenX != null) tweenX.cancel();
            if(tweenY != null) tweenY.cancel();
            if(tweenBFX != null) tweenBFX.cancel();
            if(tweenBFY != null) tweenBFY.cancel();
            if(tweenDADX != null) tweenDADX.cancel();
            if(tweenDADY != null) tweenDADY.cancel();
            if(tweenHUDX != null) tweenHUDX.cancel();
            if(tweenHUDY != null) tweenHUDY.cancel();
            
            xOfs = 0;
            yOfs = 0;

            tweenX = FlxTween.tween(adobe1, {x: positionsArray[4]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenY = FlxTween.tween(adobe1, {y: positionsArray[5]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenBFX = FlxTween.tween(boyfriend, {x: positionsArray[0]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenBFY = FlxTween.tween(boyfriend, {y: positionsArray[1]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenDADX = FlxTween.tween(dad, {x: positionsArray[2]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenDADY = FlxTween.tween(dad, {y: positionsArray[3]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenHUDX = FlxTween.tween(camHUD, {x: positionsArray[6]}, 0.3, {ease: FlxEase.smoothStepOut});
            tweenHUDY = FlxTween.tween(camHUD, {y: positionsArray[7]}, 0.3, {ease: FlxEase.smoothStepOut});
            
        case 252:
            adobe2.scale.y = 1.62;

        case 256:
            crackerFlash(2.1, 1);
            adobe1.alpha = 0;
            adobe2.alpha = 1;
            dadGroup.x = 2020;
            dadGroup.y = 2066;
            boyfriendGroup.x = 3529;
            boyfriendGroup.y = 1735;
            
        case 512:
            crackerFlash(1.4, 0.6);
            
        case 768:
            dad.idleSuffix = '-alt';
            dad.recalculateDanceIdle();
            
        case 796:
            ribbons.play();
            alreadyPlayed2 = true;

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

        case 1404:
            triggerFreezeEffect(0.31);
            FlxTween.tween(error.scale, {x: 0.8, y: 0.8}, 0.035, {ease: FlxEase.linear});
            FlxTween.tween(cracker, {alpha: 0.6}, 0.035, {ease: FlxEase.linear});
            cracker.blend = LuaUtils.blendModeFromString('none');

        case 1408:
            cracker.alpha = 1;
            cracker.color = 0xFF0000ad;
            FlxTween.tween(cracker, {alpha: 0}, 0.5, {ease: FlxEase.smoothStepOut});
            remove(error);
            dad.x = 3035;
            boyfriend.x = 3735;
            boyfriend.y = 1860;
            dad.y = 1820;
            bluescreen.alpha = 1;
            adobe2.alpha = wallpaper.alpha = 0;

        case 1520:
            black.cameras = [camGame];
            FlxTween.tween(black, {alpha: 1}, 1.39, {ease: FlxEase.smoothStepIn});

        case 1532:
            FlxTween.tween(camHUD, {alpha: 0}, 0.3475, {ease: FlxEase.linear});

        case 1536:
            lockscreen.alpha = 1;
            bluescreen.alpha = 0;
            boyfriend.x = 3512;
            boyfriend.y = 2134;
            dad.x = 2687;
            dad.y = 2575;
            if(!ClientPrefs.data.middleScroll) comboGroup.x = -500;
            comboGroup.alpha = 0.7;
            for(i in 0...4) {
                opponentStrums.members[i].alpha = 0;
                playerStrums.members[i].alpha = 0.7;
                if(!ClientPrefs.data.middleScroll) playerStrums.members[i].x = i == 0 ? opponentStrums.members[3].x : playerStrums.members[i-1].x + 117;
            }
            for(obj in luaObjects) {
                game.getLuaObject(obj).alpha = 0;
            }
            black.cameras = [camGame];
            FlxTween.tween(lockscreen, {y: -100}, 32.48, {ease: FlxEase.linear});
            FlxTween.tween(black, {alpha: 0}, 5.6, {ease: FlxEase.smootherStepOut});
            FlxTween.tween(camHUD, {alpha: 1}, 2.78, {ease: FlxEase.linear});

        case 1632:
            FlxTween.tween(dad, {y: 2275}, 2.8, {ease: FlxEase.smootherStepOut});
            for(i in 0...4) {
                FlxTween.tween(opponentStrums.members[i], {alpha: 0.7}, 2.8, {ease: FlxEase.smootherStepInOut});
                if(!ClientPrefs.data.middleScroll) FlxTween.tween(playerStrums.members[i], {x: 740+(117*i), angle: 360}, 2.8, {ease: FlxEase.smootherStepInOut});
            }
            for(obj in luaObjects) {
                FlxTween.tween(game.getLuaObject(obj), {alpha: 1}, 2.8, {ease: FlxEase.smootherStepInOut});
            }
            if(!ClientPrefs.data.middleScroll) FlxTween.tween(comboGroup, {x: 0}, 2.8, {ease: FlxEase.smootherStepInOut});

        case 1656, 1688, 1720, 1784:
            cracker.alpha = 0;
            cracker.color = 0xFFFFFFFF;
            FlxTween.tween(cracker, {alpha: 0.6}, 0.69, {ease: FlxEase.linear});
            
        case 1660, 1722:
            triggerFreezeEffect(0.3);

        case 1664, 1696, 1728:
            crackerFlash(1.4, 1);

        case 1792:
            cracker.color = 0xFF0a6816;
            cracker.alpha = 1;
            cracker.blend = LuaUtils.blendModeFromString('none');
            FlxTween.tween(cracker, {alpha: 0}, 1.4, {ease: FlxEase.linear});
            boyfriend.x = 3615;
            boyfriend.y = 2190;
            dad.x = 2565;
            dad.y = 2190;
            matrix.alpha = 1;
            speedLines.alpha = 0.5;
            lockscreen.alpha = 0;
            for(i in 0...4) {
                FlxTween.tween(opponentStrums.members[i], {alpha: 1}, 0.00001, {ease: FlxEase.linear});
                FlxTween.tween(playerStrums.members[i], {alpha: 1}, 0.00001, {ease: FlxEase.linear});
            }
            comboGroup.alpha = 1;

        case 2096:
            black.cameras = [camOther];
            FlxTween.tween(black, {alpha: 1}, 2.8, {ease: FlxEase.smoothStepIn});
            FlxTween.tween(dad, {y: dad.y - 400}, 2.8, {ease: FlxEase.smootherStepInOut});
            FlxTween.tween(boyfriend, {y: boyfriend.y - 400}, 2.8, {ease: FlxEase.smootherStepInOut});
            FlxTween.tween(camHUD, {y: camHUD.y - 900}, 2.8, {ease: FlxEase.smootherStepInOut});
    }
}

function onSectionHit(section:Dynamic) {
    mustHitSection = section.mustHitSection;
}

function triggerFreezeEffect(freezeDuration:Float) {
    camGame.alive = camGame.exists = camHUD.alive = camHUD.exists = false;
    cursorLoad.alpha = 1;
    
    new FlxTimer().start(freezeDuration-.01, function(_)
    {
        camHUD.alive = camHUD.exists = true;
    });

    new FlxTimer().start(freezeDuration, function(_)
    {
        camGame.alive = camGame.exists = true;
        cursorLoad.alpha = 0.00001;
    });
}

function crackerFlash(time:Float, alpha:Float) {
    cracker.alpha = alpha;
    cracker.blend = LuaUtils.blendModeFromString('add');
    FlxTween.tween(cracker, {alpha: 0}, time, {ease: FlxEase.smoothStepOut});
}