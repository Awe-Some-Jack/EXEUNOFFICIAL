import psychlua.LuaUtils;
import openfl.display.BlendMode;

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
	@:optional var flipX:Bool;
	@:optional var lq:Bool;
	@:optional var animation:Array<Dynamic>;
	@:optional var backdrop:Array<Dynamic>;
}

var bgDark:Array<BackgroundSprite> = [
	{path: 'hellbent/GUARDIAN-N', position: [-1000, -430], scroll: [0.7, 0.7]},
	{path: 'hellbent/BG-N1', position: [-1080, -430]},
	{path: 'hellbent/bgnew/murofuego 3', position: [-1080, -500], animation: [{name: "Símbolo 21", looped: true}]},
	{path: 'hellbent/bgnew/murofuego 3', position: [900, -500], flipX: true, animation: [{name: "Símbolo 21", looped: true}]}
];

var bgFirst:Array<BackgroundSprite> = [
	{path: 'hellbent/bgnew/hellbentnew', position: [-2490, -1310], visible: false, scroll: [0.2, 0.2], animation: [{name: "4"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2590, -1310], visible: false, scroll: [0.5, 0.5], animation: [{name: "3"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2650, -1310], visible: false, scroll: [0.7, 0.7], animation: [{name: "2"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2760, -1310], visible: false, animation: [{name: "1"}]}
];

final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];
final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

function onCreate()
{
	boyfriend.alpha = 0;
	makeBackground(bgDark);
	makeBackground(bgFirst);
}

function onEvent(n,v1)
{
	if (n == 'hellbentEvents')
	{
		switch(v1)
		{
			case 'startwhite':
				bgDark[0].sprite.destroy(); bgDark[1].sprite.destroy();
				for (spr in bgFirst) spr.sprite.visible = true;
				bgDark[2].sprite.y -= 800; bgDark[3].sprite.y -= 800;
				bgDark[2].sprite.x += 265; bgDark[3].sprite.x -= 265;
				game.remove(bgDark[2].sprite, true); game.insert(game.members.indexOf(bgFirst[3].sprite) - 1, bgDark[2].sprite);
				game.remove(bgDark[3].sprite, true); game.insert(game.members.indexOf(bgFirst[3].sprite) - 1, bgDark[3].sprite);
		}
	}
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
		if (spriteDef.flipX != null) sprite.flipX = spriteDef.flipX;
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}