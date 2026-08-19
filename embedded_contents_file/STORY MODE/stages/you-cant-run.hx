import psychlua.LuaUtils;

typedef BackGroundSprite = 
{
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

var generalBG:Array<BackGroundSprite> = 
[
    {path:            'yrc/vc', position: [ -650, -520]},
    {path:           'yrc/sky', position: [ -650, -520]},
    {path: 'yrc/backBackRocks', position: [-2600, -520], scale: [1.4, 1.4]},
    //{path:     'yrc/backRocks', position: [ -850, -520]},
    {path:   'yrc/middleRocks', position: [-1200, -600], scale: [0.8, 0.8]},
    //{path:         'yrc/floor', position: [ -850, -520]},
    //{path:    'yrc/frontRocks', position: [ -850, -680], scroll: [0.8, 1], front: true},
    //{name: 'middleRocks2', path: 'yrc/middleRocks', position: [-1450, -520]},
];

var isKostyaPuta:Bool = true;

function onCreate() 
    for (bg1 in generalBG) createSprite(bg1);

function createSprite(sprite:Array<BackGroundSprite>)
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
            spriteShit.animation.addByPrefix(anim.name, anim.prefix, anim.fps ?? 24, anim.loop ?? true);
            spriteShit.animation.play(anim.name, true);
        }
    }
    else spriteShit.loadGraphic(Paths.image(sprite.path));
    if (sprite.visible != null) spriteShit.visible = sprite.visible;
    if (sprite.scale != null) spriteShit.scale.set(sprite.scale[0], sprite.scale[1]);
    if (sprite.alpha != null) spriteShit.alpha = sprite.alpha;
	if (sprite.front) game.add(spriteShit);
	else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), spriteShit);
    sprite.spr = spriteShit;
}