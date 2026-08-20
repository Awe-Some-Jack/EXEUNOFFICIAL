import psychlua.LuaUtils;

typedef BackGroundSprite = 
{
    var name:String;
    var path:String;
    var spr:FlxSprite;
    @:optional var position:Array<Float>;
    @:optional var scale:Array<Dynamic>;
    @:optional var scroll:Array<Float>;
    @:optional var front:Bool;
    @:optional var camera:String;
    @:optional var visible:Bool;
    @:optional var alpha:Float;
    @:optional var flipX:Bool;
    @:optional var lq:Bool;
    @:optional var color:FlxColor;
    @:optional var animation:Array<Dynamic>;
}

var generalBG:Array<BackGroundSprite> = [
    {name:  "vc", path:  'yrc/vc', position: [-420,  -745], scale: [1.2, 1.2], scroll: [0.85,   0.85]},
    {name: "sky", path: 'yrc/sky', position: [-650,  -520],                    scroll: [0.87, 0.87]},
    {name: "backBackRocks", path: 'yrc/backBackRocks', position:    [-754, -644], scale: [1,  1.6], scroll: [0.9, 0.9]},
    {name:   "middleRocks", path:   'yrc/middleRocks', position:   [-1120, -740], scale: [1, 1.05], scroll: [0.92,   0.92]},
    {name:  "middleRocks2", path:   'yrc/middleRocks', position:   [-1650, -740],                   scroll: [0.95, 0.95]},
    {name:  "middleRocks3", path:   'yrc/middleRocks', position:    [-650, -740],                   scroll: [0.965, 0.965]}
];

var normalBG:Array<BackGroundSprite> = 
[
    {name:     "backRocks", path:     'yrc/backRocks', position:   [-900,  -520], scale: [0.9,  1], scroll: [0.98, 0.98]},
    {name:         "floor", path:         'yrc/floor', position:  [-850,  -520]},
    {name:    "frontRocks", path:    'yrc/frontRocks', position:  [ -850,  -680], scroll: [0.8, 1], front: true}
];

var pixelBG:Array<BackGroundSprite> = [
	{name:       'pixelCave', path: 'yrc/caverna',      x: 520, y:   50, animation: [{name: 'idle', prefix: 'caverna_gif', fps: 24, loop: true}], scale: [2, 2]},
	{name:     'pixelCaveBG', path: 'yrc/fondocaberna', x:   0, y: -260, scale: [2, 2], scroll: [0.9, 0.9]},
	{name: 'pixelFloorRight', path: 'yrc/piso2',        x: 790, y:  130, scale: [2, 2], scroll: [1, 1]},
	{name:      'pixelFloor', path: 'yrc/piso',         x:   0, y:  130, animation: [{name: 'idle', prefix: 'piso_gif', fps: 24, loop: true}], scale: [2, 2]}
];

var crystalBG:Array<BackGroundSprite> = 
[
    {name:     "backRocksCrystal", path:     'yrc/backRocksCrystal', position: [-900,   -520],  scale:  [0.9, 1],  scroll: [0.98, 0.98]},
    {name:         "floorCrystal", path:         'yrc/floorCrystal', position: [-850,   -520]},  
    {name:    "frontRocksCrystal", path:    'yrc/frontRocksCrystal', position: [-850,   -680],                     scroll: [0.8, 1], front: true},
    {name:                 'glow', path:                 'yrc/glow', position: [ 100,    500],  scale: [2.5, 1.5], scroll: [1.2, 1.2], front: true}
];


var isKostyaPuta:Bool = true;

function onCreate()
{
    for (general in  generalBG) createSprite(general);
    //for (bg1   in  normalBG)   createSprite(bg1);
    //for (bg2   in  pixelBG)   createSprite(bg2);
    for (bg3     in crystalBG)   createSprite(bg3);
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

    if (sprite.visible != null) spriteShit.visible = sprite.visible;
    if (sprite.scale != null) spriteShit.scale.set(sprite.scale[0], sprite.scale[1]);
    if (sprite.scroll != null) spriteShit.scrollFactor.set(sprite.scroll[0], sprite.scroll[1]);
    if (sprite.alpha != null) spriteShit.alpha = sprite.alpha;
    if (sprite.front) game.add(spriteShit);
    else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), spriteShit);
    sprite.spr = spriteShit;
}