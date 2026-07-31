import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
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
	@:optional var animation:Array<Dynamic>;
	@:optional var backdrop:Array<Dynamic>;
}

var faker:Array<BackgroundSprite> = [
	{path: 'faker/newBG/sky', position: [-300, -400], scale: [1.8, 1.8], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/sun', position: [-1050 + 250, -450], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/sunshine', position: [-1050 + 250, -450], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/moon', position: [-1008, -450], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/clouds', position: [-300, -400], scale: [1.8, 1.8], scroll: [0.2, 0.2], backdrop: [0x01, [50, 0]]},
	{path: 'faker/newBG/mountainsback', position: [-300, -400], scale: [1.8, 1.8], scroll: [0.5, 0.5]},
	{path: 'faker/newBG/mountaints', position: [-100, -400], scale: [1.8, 1.8], scroll: [0.65, 0.65]},
	{path: 'faker/newBG/mountaints2', position: [-100, -200], scale: [1.8, 1.8], scroll: [0.8, 0.8]},
	{path: 'faker/newBG/water', position: [-100, 400], scale: [1.8, 1.8], scroll: [0.8, 0.8]},
	{path: 'faker/newBG/totems', position: [150, -450], scale: [1.8, 1.8], scroll: [0.9, 0.9]},
	{path: 'faker/newBG/floor', position: [-60, 310], scale: [1.8, 1.8]},
	{path: 'faker/newBG/foreground', position: [100, 310], scale: [1.6, 1.6], scroll: [1.3, 1.3]},
	{path: 'faker/newBG/glow', position: [0, -200], scale: [2.8, 1.3], front: true, alpha: 0.4}
];

final game:PlayState = PlayState.instance;

var overlay:FlxSprite;
var blackbgxd:FlxSprite;
function onCreate()
{
	makeBackground(faker);
	faker[faker.length - 1].sprite.color = 0xFFA81000;
	faker[faker.length - 1].sprite.blend = BlendMode.ADD;
	
	overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFAAAAFF);
	overlay.blend = BlendMode.MULTIPLY;
	overlay.alpha = 0.5;
	overlay.screenCenter();
	overlay.scrollFactor.set();
	game.add(overlay);

	blackbgxd = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackbgxd.screenCenter();
	blackbgxd.alpha = 0;
	blackbgxd.scrollFactor.set();
	game.insert(game.members.indexOf(game.boyfriendGroup), blackbgxd);
}

function onUpdatePost(elapsed)
{
	overlay.scale.set(1 / camGame.zoom, 1 / camGame.zoom);
	blackbgxd.scale.set(1 / camGame.zoom, 1 / camGame.zoom);

	var progress = Math.min(Conductor.songPosition / (109.71 * 1000), 1);

	faker[3].sprite.x = Math.min(FlxMath.lerp(-1300, -1008, progress), -1008) - 7 + 250;
	faker[3].sprite.y = FlxMath.lerp(-300, -450, Math.sin(progress * Math.PI * 0.5)) - 1;

	faker[2].sprite.alpha = Math.min(FlxMath.lerp(0.5, 1, progress), 1);
	var scale = Math.min(FlxMath.lerp(1.2, 2, progress), 2);
	faker[2].sprite.scale.set(scale, scale);
	faker[2].sprite.y = Math.min(FlxMath.lerp(-450, -65, progress), -65) + 100;
}

function onEvent(n)
{
	if (n == 'blackdbg')
	{
		FlxTween.cancelTweensOf(blackbgxd);
		FlxTween.tween(blackbgxd, {alpha: (blackbgxd.alpha != 0 ? 0 : 1)}, 0.6);
		FlxTween.tween(faker[11].sprite, {alpha: (faker[11].sprite.alpha != 1 ? 1 : 0.5)}, 0.6);
		FlxTween.tween(faker[12].sprite, {alpha: (faker[12].sprite.alpha != 0.4 ? 0.4 : 0.06)}, 0.6);
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
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}