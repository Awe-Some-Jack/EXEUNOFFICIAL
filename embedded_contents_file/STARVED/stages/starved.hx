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

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var starv:Array<BackgroundSprite> = [
	{path: 'starved/new bg/sky', position: [-910, -900], scroll: [0.4, 0.4]},
	{path: 'starved/new bg/bg', position: [-910, -650], scroll: [0.6, 0.6]},
	{path: 'starved/new bg/floor', position: [-910, -500]},
	{path: 'starved/sonic', position: [100, 1350], scale: [1.3, 1.3], ID: 'sonic'},
	{path: 'starved/sonic-dark', position: [100, 1350], scale: [1.3, 1.3], alpha: 0, ID: 'sonicdark'},
	{path: 'starved/shoe', position: [900, 1000], scale: [0.6, 0.6]},
	{path: 'starved/picky', position: [-230, 1500], scale: [1.1, 1.1]},
	{path: 'starved/mrcrabs', position: [1100, 1100], scale: [1.7, 1.7]},
	{path: 'starved/pocky', position: [1300, 1300], scale: [0.7, 0.7]},
	{path: 'starved/ricky', position: [-200, 200], scale: [0.7, 0.7], scroll: [1.5, 1.5]},
	{path: 'starved/cucky', position: [1100, 100], scale: [0.7, 0.7], scroll: [1.3, 1.3]},
	{path: 'starved/flicky', position: [1300, 400], scale: [0.9, 0.9], scroll: [1.6, 1.6]},
	{path: 'starved/fishF1', position: [140, 1450], scale: [2.7, 2.7], scroll: [2, 2]},
	{path: 'starved/new bg/light', position: [-910, -400], front: true}
];

var vg:FlxSprite;
function onCreate()
{
	makeBackground(starv);

	boyfriend.scrollFactor.set(2, 2);

	vg = new FlxSprite().loadGraphic(Paths.image('starved/vinevrom'));
	vg.camera = camHUD;
	add(vg);
}

var _inTrans:Bool = false;
function onSectionHit(x)
{
	if (_inTrans) return;
	if (x.mustHitSection == false) cam.OGZoom = 0.5;
	else cam.OGZoom = 0.4;
}

function onEvent(n,v1)
{
	if (n == 'Hide') FlxTween.tween(camHUD, {alpha: Std.int(v1)}, 0.3);
	if (n == 'secondPhase')
	{
		switch(v1)
		{
			case 'fadeout':
				_inTrans = true;
				for (spr in starv) if (spr.ID == null) FlxTween.tween(spr.sprite, {alpha: 0}, 3);
				FlxTween.color(boyfriend, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(vg, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 3);
			case 'fight':
				_inTrans = false;
				for (spr in starv) if (spr.ID == 'sonicdark') FlxTween.tween(spr.sprite, {alpha: 1}, 1);
				FlxTween.color(boyfriend, 1, 0xFF000000, 0xFFFF0000);
				FlxTween.color(vg, 1, 0xFF000000, 0xFFFF0000);
				FlxTween.color(dad, 1, 0xFFFFFFFF, 0xFFFF0000);
				FlxTween.tween(camHUD, {alpha: 1}, 1);
			case 'starved':
				_inTrans = true;
				for (spr in starv) if (spr.ID == 'sonicdark') FlxTween.tween(spr.sprite, {alpha: 0}, 1);
				FlxTween.color(boyfriend, 1, 0xFFFF0000, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 1);
				FlxTween.color(vg, 3, 0xFFFF0000, 0xFF000000);
			case 'fadein':
				_inTrans = false;
				for (spr in starv)
				{
					if (spr.ID == null) FlxTween.tween(spr.sprite, {alpha: 1}, 4);
					if (spr.ID == 'sonic') FlxTween.color(spr.sprite, 4, 0xFF000000, 0xFFFFFFFF);
				}
				FlxTween.tween(camHUD, {alpha: 1}, 4);
				FlxTween.color(boyfriend, 1, 0xFF000000, 0xFFFFFFFF);
				FlxTween.color(vg, 1, 0xFF000000, 0xFFFFFFFF);
				FlxTween.color(dad, 1, 0xFFFF0000, 0xFFFFFFFF);
		}
	}
}

function makeBackground(background:Array<BackgroundSprite>)
{
	for (spriteDef in background)
	{
		var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		if (spriteDef.animation != null)
		{
			sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
			for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
		}
		else sprite.loadGraphic(Paths.image(spriteDef.path));
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}