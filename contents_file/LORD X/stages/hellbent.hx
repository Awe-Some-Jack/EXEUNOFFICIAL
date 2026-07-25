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
	{path: 'hellbent/bgnew/hellbentnew', position: [-2450, -1310], visible: false, scroll: [0.2, 0.2], animation: [{name: "4"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2520, -1310], visible: false, scale: [0.9, 0.9], scroll: [0.5, 0.5], animation: [{name: "3"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2600, -1310], visible: false, scale: [0.9, 0.9], scroll: [0.7, 0.7], animation: [{name: "2"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2745, -1310], visible: false, scale: [0.9, 0.9], animation: [{name: "1"}]}
];

var bgHell:Array<BackgroundSprite> = [
	{path: 'hellbent/hell', position: [-2500, -800], visible: false, scale: [3, 3], animation: [{name: "hell"}]},
	{path: 'hellbent/anillo', position: [-650, -450], visible: false, scale: [1.25, 1.25], animation: [{name: "ring"}]},
	{path: 'hellbent/almas', position: [-2150, -1420], visible: false, scale: [6, 6], animation: [{name: "soul", fps: 18}]},
	{path: 'hellbent/plataformna', position: [440, 1250], visible: false, scale: [0.55, 0.55]},
	{path: 'hellbent/plataformna', position: [-950, 1200], visible: false, scale: [0.55, 0.55], flipX: true}
];

final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];
final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var eyes:FlxSprite;
function onCreate()
{
	boyfriend.alpha = 0;
	makeBackground(bgDark);
	makeBackground(bgFirst);
	makeBackground(bgHell);

	eyes = new FlxSprite();
	eyes.frames = Paths.getSparrowAtlas('characters/ojos');
	eyes.animation.addByPrefix('idle', 'idle', 0, false);
	eyes.camera = camOther;
	game.add(eyes);
}

var _phase2Active:Bool = false;
function onEvent(n,v1)
{
	if (n == 'hellbentEvents')
	{
		switch(v1)
		{
			case 'startwhite':
				camGame.zoom = 0.25;
				cam.OGZoom = 0.25;
				bgDark[0].sprite.destroy(); bgDark[1].sprite.destroy();
				for (spr in bgFirst) spr.sprite.visible = true;
				bgDark[2].sprite.y -= 750; bgDark[3].sprite.y -= 750;
				bgDark[2].sprite.x += 350; bgDark[3].sprite.x -= 350;
				game.remove(bgDark[2].sprite, true); game.insert(game.members.indexOf(bgFirst[3].sprite) - 1, bgDark[2].sprite);
				game.remove(bgDark[3].sprite, true); game.insert(game.members.indexOf(bgFirst[3].sprite) - 1, bgDark[3].sprite);
			case 'changeBG':
				_phase2Active = true;
				eyes?.destroy();
				bgDark[2].sprite.destroy(); bgDark[3].sprite.destroy();
				for (spr in bgFirst) spr.sprite.destroy();
				for (spr in bgHell) spr.sprite.visible = true;

				boyfriend.alpha = 1;
				changeCharacter('dad', 'hellbemnt');
				changeCharacter('bf', 'bf hellbent');
				dad.setPosition(-700, 960);
				boyfriend.setPosition(650, 1100);
				/**
					removeLuaSprite('glow', true)
					removeLuaSprite('vignette', true)
				**/
		}
	}
}

var _floatTime:Float = 0;
function onUpdatePost(elapsed:Float)
{
	if (!_phase2Active)
	{
		if (eyes.alpha != game.getLuaObject('BlackGraphicHUD').alpha) eyes.alpha = game.getLuaObject('BlackGraphicHUD').alpha;
		if (eyes != null && dad?.getAnimationName() == 'idle')
		{
			eyes.scale.set(camGame.zoom * 0.5, camGame.zoom * 0.5);
			eyes.animation.curAnim.curFrame = dad.animation.curAnim.curFrame ?? 0;
			eyes.setPosition(
				((dad.x - 54 - camGame.scroll.x) * camGame.zoom) + (FlxG.width / 2) * (1 - camGame.zoom),
				((dad.y + 4 - camGame.scroll.y) * camGame.zoom) + (FlxG.height / 2) * (1 - camGame.zoom)
			);
		}
	}
	else
	{
		_floatTime += elapsed * 1.5;
		dad.setPosition(
			-700 + Math.cos(_floatTime + 0.5) * 25,
			960 + Math.sin(_floatTime + 0.5) * 50
		);
		bgHell[4].sprite.setPosition(
			-950 + Math.cos(_floatTime + 0.5) * 25,
			1200 + Math.sin(_floatTime + 0.5) * 50
		);

		boyfriend.setPosition(
			650 + Math.cos(_floatTime) * 25,
			1100 + Math.sin(_floatTime) * 50
		);
		bgHell[3].sprite.setPosition(
			440 + Math.cos(_floatTime) * 25,
			1250 + Math.sin(_floatTime) * 50
		);
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);
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