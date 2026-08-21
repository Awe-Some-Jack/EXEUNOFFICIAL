import psychlua.LuaUtils;
import flixel.tweens.FlxTween.FlxTweenType;
import backend.CoolUtil;
import flixel.math.FlxMath;

using StringTools;

final game:PlayState = PlayState.instance;

typedef BackGroundSprite = 
{
    var name:String;
    var path:String;
    var spr:FlxSprite;
    @:optional var position:Array<Float>;
    @:optional var scale:Array<Dynamic>;
    @:optional var scroll:Array<Float>;
    @:optional var front:Bool;
    @:optional var visible:Bool;
    @:optional var alpha:Float;
    @:optional var color:String;
    @:optional var antialiasing:Bool;
    @:optional var animation:Array<Dynamic>;
}

var vignette:Array<BackGroundSprite> = 
[
    {name: "vg", path: 'VG', alpha: 0, color: "FF0000", front: true},
];

var generalBG:Array<BackGroundSprite> = [
    {name:            "vc", path:            'yrc/vc', position: [-420,  -745], scale: [1.2, 1.2], scroll: [0.85,   0.85]},
    {name:           "sky", path:           'yrc/sky', position: [-650,  -520],                    scroll: [0.87,   0.87]},
    {name: "backBackRocks", path: 'yrc/backBackRocks', position: [-754,  -644], scale: [1,   1.6], scroll: [0.9,     0.9]},
    {name:   "middleRocks", path:   'yrc/middleRocks', position: [-1120, -740], scale: [1,  1.05], scroll: [0.92,   0.92]},
    {name:  "middleRocks2", path:   'yrc/middleRocks', position: [-1650, -740],                    scroll: [0.95,   0.95]},
    {name:  "middleRocks3", path:   'yrc/middleRocks', position: [-650,  -740],                    scroll: [0.965, 0.965]}
];

var normalBG:Array<BackGroundSprite> = 
[
    {name:     "backRocks", path:     'yrc/backRocks', position: [-900,   -520], scale: [0.9,  1], scroll: [0.98, 0.98]},
    {name:         "floor", path:         'yrc/floor', position: [-850,   -520]},
    {name:    "frontRocks", path:    'yrc/frontRocks', position: [ -850,  -680], scroll: [0.8, 1], front: true}
];

var pixelBG:Array<BackGroundSprite> = [
	{name:       'pixelCave', path: 'yrc/caverna',      position: [520,  50], animation: [{name: 'idle', prefix: 'caverna_gif', fps: 24, loop: true}], scale: [2, 2],                     visible: false, antialiasing: false},
	{name:     'pixelCaveBG', path: 'yrc/fondocaberna', position: [0,  -260],                                                                          scale: [2, 2], scroll: [0.9, 0.9], visible: false, antialiasing: false},
	{name: 'pixelFloorRight', path: 'yrc/piso2',        position: [790, 130],                                                                          scale: [2, 2], scroll: [1,     1], visible: false, antialiasing: false},
	{name:      'pixelFloor', path: 'yrc/piso',         position: [0,   130], animation: [{name: 'idle', prefix:    'piso_gif', fps: 24, loop: true}], scale: [2, 2],                     visible: false, antialiasing: false}
];

var crystalBG:Array<BackGroundSprite> = 
[
    {name:     "backRocksCrystal", path:     'yrc/backRocksCrystal', position: [-900,   -520],  scale:  [0.9, 1],  scroll: [0.98, 0.98], visible: false,},
    {name:         "floorCrystal", path:         'yrc/floorCrystal', position: [-850,   -520],                                           visible: false},  
    {name:    "frontRocksCrystal", path:    'yrc/frontRocksCrystal', position: [-850,   -680],                     scroll: [0.8,     1], visible: false, front: true},
    {name:                 'glow', path:                 'yrc/glow', position: [ 100,    500],  scale: [2.5, 1.5], scroll: [1.2,   1.2], visible: false, front: true}
];

var spriteNames:Array<String> = [];
var spriteObjs:Array<String> = [];


function getSpr(name)
{
	for (i in 0...spriteNames.length)
		if (spriteNames[i] == name) return spriteObjs[i];
	return null;
}

//Song variables
var savedGFPos:Array<Float> = [];
var savedGFFloatingPos:Array<Float> = [];
var canGFFloat:Bool = false;
var shakeIntensity:Float = 0.005;
var vignetteMode:String = 'none';
final isKostyaPuta:Bool = true;

var savedScale:Array<Float> = [1, 1];
var stageEvents:Map<String, Void->Void> = [
    "PixelMode" => () -> {
        destroyStage(normalBG);
        showStage(pixelBG);

        shakeIntensity = 0.001;

        game.boyfriend.setPosition(game.boyfriend.x - 780, game.boyfriend.y - 420);
        game.dad.setPosition(game.dad.x - 343, game.dad.y - 456);
        game.gf.setPosition(game.gf.x - 105, game.gf.y - 280);

        savedGFFloatingPos = [game.gf.x, game.gf.y];

        canGFFloat = true;

        game.triggerEvent('Set customCamera Position',     'bf', '900, 120');
		game.triggerEvent('Set customCamera Position',    'dad', '800, 120');
		game.triggerEvent('Set customCamera Position', 'middle', '850, 110');

        game.triggerEvent('Set customCamera Zoom',     'OGZoom', '2.2');
		game.triggerEvent('Set customCamera Zoom', 'MiddleZoom', '1.8');

		game.triggerEvent('Set Character Offset',  'bf', '5');
		game.triggerEvent('Set Character Offset', 'dad', '5');

        game.gameplayCam.settings.OverrideZoom = false;

        for (chars in [boyfriend, dad, gf]) chars.scale.set(2, 2);

        PlayState.stageUI = "pixel"; 

        for (i in 0...notes.length - 1)
        {
            if (notes.members[i].isSustainNote)
            {
                if (notes.members[i].animation.curAnim.name.endsWith('end'))
                    notes.members[i].scale.set(notes.members[i].scale.x, ((Conductor.stepCrochet / 100 * 1.05) * 1.19) * 18.6);
                else
                    notes.members[i].scale.set(notes.members[i].scale.x, 6);

                notes.members[i].offset.set(notes.members[i].offset.x - 10, notes.members[i].offset.y - 10);
            }
        }
        
        reloadNotes();
    },
    "CrystalMode" => () -> {
        destroyStage(pixelBG);
        showStage(crystalBG);

        canGFFloat = false;

        game.triggerEvent('Set customCamera Position',     'bf', '1200, 590');
		game.triggerEvent('Set customCamera Position',    'dad', '650, 590');
		game.triggerEvent('Set customCamera Position', 'middle', '930, 530');

		game.triggerEvent('Set customCamera Zoom',     'OGZoom',  '0.7');
		game.triggerEvent('Set customCamera Zoom', 'MiddleZoom', '0.65');

		game.triggerEvent('Set Character Offset',  'bf', '25');
		game.triggerEvent('Set Character Offset', 'dad', '25');

		game.gameplayCam.settings.OverrideZoom = false;

        if (!ClientPrefs.lowQuality) crystalBG[3].spr.alpha = 0.5;

        PlayState.stageUI = "normal"; 

        for (i in 0...notes.length - 1)
        {
            if (notes.members[i].isSustainNote)
            {
                if (notes.members[i].animation.curAnim.name.endsWith('end'))
                    notes.members[i].scale.set(notes.members[i].scale.x, 1);
                else
                    notes.members[i].scale.set(notes.members[i].scale.x, 1);
            }
        }
        reloadNotes();
    }
];

function onCreate()
{
    for (vig     in  vignette)     precacheSprite(vig);
    for (general in generalBG) precacheSprite(general);
    for (bg1     in  normalBG)     precacheSprite(bg1);
    for (bg2     in   pixelBG)     precacheSprite(bg2);
    for (bg3     in crystalBG)     precacheSprite(bg3);
    
    for (vig     in    vignette)     createSprite(vig);
    for (general in   generalBG) createSprite(general);
    for (bg1     in    normalBG)     createSprite(bg1);
    for (bg2     in     pixelBG)     createSprite(bg2);
    for (bg3     in   crystalBG)     createSprite(bg3);

    vignette[0].spr.camera = camOther;
}

function onEvent(e, v1, v2){
    if (e == 'ycrEvents'){
        var split = v2.split(',');

        if (v1 == 'stageMode') {
            var stageEvent = stageEvents.get(split[0]);
            if (stageEvent != null)
                stageEvent();
        }
        if (v1 == 'vignetteMode') {
            setVignetteMode(split[0]);
            trace(split[0]);
        }
        if (v1 == 'tweenObjectAlpha') 
            FlxTween.tween(getSpr(split[0]), {alpha: split[1]}, split[2]);
    }
}

function setVignetteMode(mode:String){
    vignetteMode = mode != null ? mode : "none";
    FlxTween.cancelTweensOf(vignette[0].spr);

    switch(mode){
        case "slow":
            FlxTween.tween(vignette[0].spr, {alpha: 1}, 1, {type: FlxTweenType.PINGPONG});
        case "none":
            FlxTween.tween(vignette[0].spr, {alpha: 0}, 0.7);
    }
}

function onCreatePost() 
{
    camHUD.alpha = 0;
    game.triggerEvent('Tweening Camera', '-500, 0', '0.001, linear');
    game.triggerEvent('Tween Camera Zoom', '1.4, true', '0.001, linear');

    game.gf.scrollFactor.set(1, 1);

}


var floatTimer:Float = 0;
function onUpdatePost(e:Float) {
    floatTimer = floatTimer + e;

    var mathCos:Float = FlxMath.fastCos(floatTimer * 0.5) * 10;
    var mathSin:Float = FlxMath.fastSin(floatTimer) * 10;

    if (canGFFloat){
        pixelBG[2].spr.setPosition(790 + mathCos, -130 + mathSin);
        game.gf.setPosition(savedGFPos[0] + mathCos, savedGFPos[1] + mathSin);
    }

    if (PlayState.stageUI == "pixel")
    {
        for (i in 0...notes.length - 1)
        {
            if (notes.members[i].isSustainNote)
            {
                if (notes.members[i].animation.curAnim.name.endsWith('end'))
                    notes.members[i].scale.set(notes.members[i].scale.x, ((Conductor.stepCrochet / 100 * 1.05) * 1.19) * 18.6);
                else
                    notes.members[i].scale.set(notes.members[i].scale.x, 6);

                //notes.members[i].offset.set(notes.members[i].offset.x - 10, notes.members[i].offset.y - 10);
            }
        }
    }
}

function reloadNotes() 
{
    if (game.strumLineNotes != null)
        for (note in game.strumLineNotes.members)
            if (note != null) note.reloadNote();

    if (game.unspawnNotes != null)
        for (note in game.unspawnNotes)
            if (note != null) 
                for (i in 0...note.length - 1)
                    if (note.members[i].noteType == '')
                        note.reloadNote();

    if (game.notes != null)
        for (note in game.notes.members)
            if (note != null) note.reloadNote();
}

function opponentNoteHit()
    FlxG.camera.shake(shakeIntensity, 0.05);

function destroyStage(stage)
    for (stg in stage) stg.spr.destroy();

function showStage(stage)
    for (stg in stage) stg.spr.visible = true;

function onBeatHit()
{
    switch(vignetteMode){
        case '1beat':
            FlxTween.cancelTweensOf(vignette[0].spr);
            vignette[0].spr.alpha = 0.6;
            FlxTween.tween(vignette[0].spr, {alpha: 0}, 0.6);
        case '2beat':
            if (curBeat % 2 == 0)
            {
                FlxTween.cancelTweensOf(vignette[0].spr);
                vignette[0].spr.alpha = 0.6;
                FlxTween.tween(vignette[0].spr, {alpha: 0}, 0.6);
            }
    }
}

function createSprite(sprite:BackGroundSprite)
{
    var spriteShit = new FlxSprite(
        sprite.position != null ? sprite.position[0] : 0,
        sprite.position != null ? sprite.position[1] : 0
    );

    if (sprite.animation != null)
    {
        spriteShit.frames = Paths.getSparrowAtlas(sprite.path);
        for (anim in sprite.animation)
        {
            spriteShit.animation.addByPrefix(anim.name, anim.prefix, anim.fps != null ? anim.fps : 24, anim.loop != null ? anim.loop : true);
            spriteShit.animation.play(anim.name, true);
        }
    }
    else
    {
        spriteShit.loadGraphic(Paths.image(sprite.path));
    }

    if (sprite.visible      != null) spriteShit.visible = sprite.visible;
    if (sprite.camera       != null) spriteShit.camera = sprite.camera;
    if (sprite.scale        != null) spriteShit.scale.set(sprite.scale[0], sprite.scale[1]);
    if (sprite.color        != null) spriteShit.color = CoolUtil.colorFromString(sprite.color);
    if (sprite.scroll       != null) spriteShit.scrollFactor.set(sprite.scroll[0], sprite.scroll[1]);
    if (sprite.alpha        != null) spriteShit.alpha = sprite.alpha;
    if (sprite.antialiasing != null) spriteShit.antialiasing = sprite.antialiasing;
    if (sprite.front) game.add(spriteShit);
    else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), spriteShit);
    sprite.spr = spriteShit;

    spriteNames.push(sprite.name);
    spriteObjs.push(spriteShit);
}

function precacheSprite(sprite:BackGroundSprite)
{
    if (sprite.animation != null)
        Paths.getSparrowAtlas(sprite.path);
    else
        Paths.image(sprite.path);
}