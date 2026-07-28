import psychlua.LuaUtils;
typedef BackgroundSprite =
{
	var path:String;
	var sprite:FlxSprite;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool;
	@:optional var visible:Bool;
	@:optional var alpha:Float;
	@:optional var animation:Array<Dynamic>;
}

var bgNeedle:Array<BackgroundSprite> = [
	{path: 'roundabout/sky', position: [-750, -900], scroll: [0.3, 0.3]},
	{path: 'roundabout/bg3', position: [-500, -700], scroll: [0.5, 0.5]},
	{path: 'roundabout/bg2', position: [-600, -550], scroll: [0.65, 0.65]},
	{path: 'roundabout/lava', position: [0, 1080], scale: [1.2, 1.2], scroll: [0.8, 0.8], animation: [{name: 'Dance', looped: true}]},
	{path: 'roundabout/lava', position: [0, 1300], scale: [1.2, 1.2], scroll: [0.8, 0.8], animation: [{name: 'Dance', looped: true}]},
	{path: 'roundabout/lava', position: [0, 1520], scale: [1.2, 1.2], scroll: [0.8, 0.8], animation: [{name: 'Dance', looped: true}]},
	{path: 'roundabout/bg1', position: [-350, -150], scroll: [0.8, 0.8]},
	{path: 'roundabout/floor', position: [-200, 1080]},
	{path: 'roundabout/foreground', position: [100, 450], scroll: [1.2, 1.2], front: true}
];

function onCreatePost()
{
	makeBackground(bgNeedle);
}

function makeBackground(background:Array<BackgroundSprite>)
{
	for (spriteDef in background)
	{
		var sprite:FlxSprite;

		if (spriteDef.backdrop != null)
		{
			sprite = new FlxBackdrop(Paths.image(spriteDef.path), spriteDef.backdrop[0] ?? 0x11);
			sprite.velocity.set((spriteDef.backdrop[1] ?? [0, 0])[0], (spriteDef.backdrop[1] ?? [0, 0])[1]);
			sprite.setPosition((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		}
		else
		{
			sprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
			else sprite.loadGraphic(Paths.image(spriteDef.path));
		}
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}