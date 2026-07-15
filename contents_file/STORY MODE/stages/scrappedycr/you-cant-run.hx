import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

using StringTools;

var canShake:Bool = false;
var shakeIntensity:Float = 0.005;
var vignetteMode:String = 'none'; //none, slow, 1beat, 2beat
var ogGFPosition:Array<Float> = [0, 0];
var floatGFPosition:Array<Float> = [0, 0]; 

typedef StageDef = {
    var name                 :String;
    var path                 :String;
    var position             :Array<Float>;
    @:optional var scale     :Float;
    @:optional var scales    :Array<Float>;
    @:optional var scroll    :Array<Float>;
    @:optional var animated  :Bool;
    @:optional var fps       :Int;
    @:optional var animName  :String;
    @:optional var animPrefix:String;
    @:optional var loop      :Bool;
    @:optional var alpha     :Float;
    @:optional var front     :Bool;
    @:optional var centered  :Bool;
    @:optional var behind    :Dynamic;
    @:optional var camera    :Dynamic;
}

final game:PlayState = PlayState.instance;
final lq:Bool = ClientPrefs.data.lowQuality;
final prefs = ClientPrefs.data;

var spriteGroupNames:Array<String> = [];
var spriteGroupSprites:Array<FlxSprite> = [];


var ycrBG:Array<StageDef> = {
    Vignette: [ {name: "redVG", path: "VG", centered: true, alpha: 0, front: true} ],
    GeneralBG: [
        {name: "backBackRocks", path: "yrc/backBackRocks", position: [-1050, -520]},
        {name:   "middleRocks", path:   "yrc/middleRocks", position: [-1050, -520]},
        {name:     "backRocks", path:     "yrc/backRocks", position: [-1050, -520]},
    ],
    RegularBG: [
        {name:      "floor", path:      "yrc/floor", position: [-1050, -520]},
        {name: "frontRocks", path: "yrc/frontRocks", position: [-1050, -520], scroll: [0.8, 1]},
    ],
    PixelBG: [
        {name:       "pixelCave", path:      "ycr/caverna", position:  [520, 20], animated: true, animName: "idle", animPrefix: "caverna_gif", fps: 24, loop: true, scale: 2},
        {name:     "pixelCaveBG", path: "ycr/fondocaberna", position:  [0, -260],                                                                                   scale: 2, scroll: [0.9, 0.9]},
        {name: "pixelFloorRight", path:        "ycr/piso2", position: [790, 130],                                                                                   scale: 2},
        {name:      "pixelFloor", path:         "ycr/piso", position:   [0, 130], animated: true, animName: "idle", animPrefix: "piso_gif", fps: 24, loop: true, scale: 2},
    ],
    CrystalBG: [
        {name:  "backRocksCrystal", path:  "yrc/backRocksCrystal", position: [ -520, -520], behind: "backRocks"},
        {name:      "frontCrystal", path:      "yrc/frontCrystal", position: [-1050, -520]},
        {name: "frontRocksCrystal", path: "yrc/frontRocksCrystal", position: [-1050, -520], front: true},
        {name:              "glow", path:              "yrc/glow", position:   [-700, 500], scales: [2.5, 1.5], scroll: [1.2, 1.2], front: true},
    ],
};


function makeSprite(spr){
    var sprVar:FlxSprite;
    if (spr.animated) {
        sprVar = new FlxSprite(spr.position[0], spr.position[1]);
        sprVar.frames     = Paths.getSparrowAtlas(spr.path);
        var name:String   = spr.animName != null ? spr.animName : 'idle';
        var prefix:String = spr.animPrefix;
        var fps:Int       = spr.fps  != null ? spr.fps  : 24;
        var loop:Bool     = spr.loop != null ? spr.loop : true;
        spr.animation.addByPrefix(name, prefix, fps, loop);
        spr.animation.play(name, true);
    } else {
        sprVar = new FlxSprite(spr.position[0], spr.position[1]);
        sprVar.loadGraphic(Paths.image(spr.path));
    }
    
    var scaleX:Float = if (spr.scales != null && spr.scales.length > 0 && spr.scales[0] != null) spr.scales[0] else (spr.scale != null ? spr.scale : 1);
    var scaleY:Float = if (spr.scales != null && spr.scales.length > 1 && spr.scales[1] != null) spr.scales[1] else (spr.scale != null ? spr.scale : 1);
    sprVar.scale.set(scaleX, scaleY);
    sprVar.updateHitbox();

    if (spr.scroll != null) sprVar.scrollFactor.set(spr.scroll[0], spr.scroll[1]);
    if (spr.alpha != null)  sprVar.alpha = spr.alpha;

    if (spr.camera != null)   sprVar.camera = spr.camera;
    if (spr.centered)         sprVar.screenCenter();

    spriteGroupNames.push(spr.name);
    spriteGroupSprites.push(sprVar);
    
    if (spr.front) game.add(sprVar);
    else if (spr.behind != null) {
        var behindTarget:FlxSprite = null;
        if (Std.isOfType(spr.behind, String)) behindTarget = getSpr(cast spr.behind);
        else behindTarget = cast(spr.behind, FlxSprite);

        if (behindTarget != null) game.insert(game.members.indexOf(behindTarget), sprVar);
        else game.insert(game.members.indexOf(getLowestGroup()), sprVar);
    } else game.insert(game.members.indexOf(getLowestGroup()), sprVar);
}

function onCreate(){
    for (vig in ycrBG.Vignette)  makeSprite(vig);
    for (bg1 in ycrBG.GeneralBG) makeSprite(bg1);
    for (bg2 in ycrBG.RegularBG) makeSprite(bg2);
    for (bg3 in ycrBG.PixelBG)   makeSprite(bg3);
    for (bg4 in ycrBG.CrystalBG) makeSprite(bg4);

    game.gfGroup.scrollFactor.set(1, 1);
}

function getLowestGroup()
{
	var g = game.gfGroup;
	var pos = game.members.indexOf(g);
	var p2 = game.members.indexOf(game.boyfriendGroup);
	if (p2 < pos) { g = game.boyfriendGroup; pos = p2; }
	var p3 = game.members.indexOf(game.dadGroup);
	if (p3 < pos) g = game.dadGroup;
	return g;
}

function getSpr(name)
{
	for (i in 0...spriteGroupNames.length)
		if (spriteGroupNames[i] == name) return spriteGroupSprites[i];
	return null;
}