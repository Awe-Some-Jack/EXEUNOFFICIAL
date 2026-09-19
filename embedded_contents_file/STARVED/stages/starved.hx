import psychlua.LuaUtils;
typedef BackgroundSpriteAlt =
{
	var path:String;
	var sprite:FlxSprite;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool;
	@:optional var visible:Bool;
	@:optional var alpha:Float;
	@:optional var angle:Float;
	@:optional var animation:Array<Dynamic>;
}

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var starv:Array<BackgroundSpriteAlt> = [
	{path: 'new bg/sky', position: [-1220, -1250], scroll: [0.4, 0.4], scale: [0.8, 0.8]},
	{path: 'new bg/bg', position: [-1350, -1300], scroll: [0.6, 0.6], scale: [0.8, 0.8]},
	{path: 'new bg/tv', position: [40, -680], tag: 'tv', scale: [1.5, 1.35], animation: [{name: 'idle', looped: true}], angle: -6, hide: false},
	{path: 'new bg/floor', position: [-1610, -1450], scale: [0.8, 0.8]},
	{path: 'new bg/metal', position: [-650, -500], scale: [0.38, 0.38], animation: [{name: 'idle', looped: true}], blend: 'add', hide: false},
	{path: 'new bg/tails', position: [-290, -410], scale: [0.45, 0.45], animation: [{name: 'idle', looped: true}], blend: 'add', hide: false},
	{path: 'new bg/starv', tag: 'starvTV', position: [150, -480], scale: [0.4, 0.4], animation: [{name: 'idle', looped: true}], blend: 'add', hide: false},
	{path: 'bee', position: [-520, -150], scale: [0.7, 0.7], darkVariant: true},
	{path: 'moto', position: [-1000, 120], scale: [0.9, 0.9], darkVariant: true},
	{path: 'sonic', position: [-550, 240], scale: [1.15, 1.15], darkVariant: true},
	{path: 'shoe', position: [300, 320], scale: [0.8, 0.8], darkVariant: true},
	{path: 'picky', position: [-870, 400], darkVariant: true},
	{path: 'mrcrabs', position: [200, -60], scale: [1.3, 1.3], darkVariant: true},
	{path: 'pocky', position: [400, 230], scale: [0.7, 0.7], darkVariant: true},
	{path: 'ricky', position: [-1300, -1000], scale: [0.6, 0.6], scroll: [1.7, 1.7], darkVariant: true},
	{path: 'cucky', position: [-50, -900], scale: [0.5, 0.5], scroll: [1.5, 1.5], front: true, darkVariant: true},
	{path: 'flicky', position: [-300, -1100], scale: [0.8, 0.8], scroll: [2.2, 2.2], darkVariant: true},
	{path: 'fish', position: [-1500, 250], scale: [1.2, 1.2], scroll: [2, 2], darkVariant: true},
	{path: 'new bg/light', position: [-1350, -1300], front: true, scale: [0.8, 0.8]}
];

var vg:FlxSprite;
function onCreate()
{
	makeBackgroundAlt(starv);
	boyfriend.scrollFactor.set(2, 2);

	vg = new FlxSprite().loadGraphic(Paths.image('starved/vinevrom'));
	vg.camera = camHUD;
	add(vg);

	game.gameplayCam._targetAlpha = 0.5;
}

var _inTrans:Bool = false;
function onSectionHit(x)
{
	if (_inTrans) return;
	if (x.mustHitSection == false) cam.OGZoom = 0.8;
	else cam.OGZoom = 0.65;
}

var _isDark:Bool = false;
var notesPosition:Array<Array<Array<Float>>> = [[[0,0],[0,0],[0,0],[0,0]],[[0,0],[0,0],[0,0],[0,0]]];
function onEvent(n,v1)
{
	if (n == 'Hide') FlxTween.tween(camHUD, {alpha: Std.int(v1)}, 0.3);
	if (n == 'secondPhase')
	{
		switch(v1)
		{
			case 'fadeout':
				_inTrans = true;
				for (spr in starv) if (spr.hide == null || spr.hide == true) FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(vg, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 3);
				for (i in 0...4)
				{
					notesPosition[0][i][0] = opponentStrums.members[i].x; notesPosition[1][i][0] = playerStrums.members[i].x;
					notesPosition[0][i][1] = opponentStrums.members[i].y; notesPosition[1][i][1] = playerStrums.members[i].y;
				}
			case 'fight':
				_inTrans = false;
				for (spr in starv)
				{
					if (spr.tag == 'starvTV' || spr.tag == 'tv') FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFFFF0000);
					if (spr.darkVariant != null && spr.spriteDark != null && (spr.hide == null || spr.hide == true) && (spr.tag != 'starvTV' || spr.tag != 'tv'))
					{
						spr.spriteDark.alpha = 1;
						FlxTween.color(spr.spriteDark, 1, 0xFF000000, 0xFFFFFFFF);
					}
				}
				FlxTween.color(boyfriend, 1, 0xFF000000, 0xFFFF0000);
				FlxTween.color(vg, 1, 0xFF000000, 0xFFFF0000);
				FlxTween.color(dad, 1, 0xFFFFFFFF, 0xFFFF0000);
				FlxTween.tween(camHUD, {alpha: 1}, 1);
				_isDark = true;
			case 'starved':
				_inTrans = true;
				for (spr in starv) if (spr.darkVariant != null && spr.spriteDark != null && (spr.hide == null || spr.hide == true) && (spr.tag != 'starvTV' || spr.tag != 'tv')) FlxTween.color(spr.spriteDark, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 1, 0xFFFF0000, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 1);
				FlxTween.color(vg, 3, 0xFFFF0000, 0xFF000000);
			case 'fadein':
				_inTrans = false;
				_isDark = false;
				for (i in 0...4)
				{
					opponentStrums.members[i].setPosition(notesPosition[0][i][0], notesPosition[0][i][1]);
					playerStrums.members[i].setPosition(notesPosition[1][i][0], notesPosition[1][i][1]);
					opponentStrums.members[i].angle = 0;
					playerStrums.members[i].angle = 0;
				}
				for (spr in starv)
				{
					if (spr.tag == 'starvTV' || spr.tag == 'tv') FlxTween.color(spr.sprite, 1, 0xFFFF0000, 0xFFFFFFFF);
					if (spr.hide == false) continue;
					if (spr.darkVariant != null && spr.spriteDark != null) spr.spriteDark.alpha = 0;
					FlxTween.color(spr.sprite, 1, 0xFF000000, 0xFFFFFFFF);
				}
				FlxTween.tween(camHUD, {alpha: 1}, 4);
				FlxTween.color(boyfriend, 1, 0xFF000000, 0xFFFFFFFF);
				FlxTween.color(vg, 1, 0xFF000000, 0xFFFFFFFF);
				FlxTween.color(dad, 1, 0xFFFF0000, 0xFFFFFFFF);
			case 'fadefinalxd':
				for (spr in starv) FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(dad, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(vg, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 3);
		}
	}
}

function onUpdatePost()
{
	if (_isDark)
	{
		for (i in 0...4)
		{
			opponentStrums.members[i].setPosition(notesPosition[0][i][0] + FlxG.random.float(-1, 1), notesPosition[0][i][1] + FlxG.random.float(-1, 1));
			playerStrums.members[i].setPosition(notesPosition[1][i][0] + FlxG.random.float(-1, 1), notesPosition[1][i][1] + FlxG.random.float(-1, 1));
			opponentStrums.members[i].angle = FlxG.random.float(-1, 1);
			playerStrums.members[i].angle = FlxG.random.float(-1, 1);
		}
	}
}

function makeBackgroundAlt(background:Array<BackgroundSpriteAlt>)
{
	for (spriteDef in background)
	{
		var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		if (spriteDef.animation != null)
		{
			sprite.frames = Paths.getSparrowAtlas('starved/' + spriteDef.path);
			for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
		}
		else sprite.loadGraphic(Paths.image('starved/' + spriteDef.path));
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.angle != null) sprite.angle = spriteDef.angle;
		if (spriteDef.blend != null) sprite.blend = LuaUtils.blendModeFromString(spriteDef.blend);
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;

		if (spriteDef.darkVariant != null) {
			var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas('starved/dark/' + spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
			else sprite.loadGraphic(Paths.image('starved/dark/' + spriteDef.path));
			sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
			sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
			sprite.alpha = 0;
			if (spriteDef.blend != null) sprite.blend = LuaUtils.blendModeFromString(spriteDef.blend);
			if (spriteDef.front) game.add(sprite);
			else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
			spriteDef.spriteDark = sprite;
		}
	}
}