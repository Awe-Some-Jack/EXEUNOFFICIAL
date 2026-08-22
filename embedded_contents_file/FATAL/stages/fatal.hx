import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import objects.Character;

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
	@:optional var flip:Array<Bool>;
	@:optional var animation:Array<Dynamic>;
	@:optional var backdrop:Array<Dynamic>;
	@:optional var boopable:Bool;
	@:optional var bopInt:Int;
}

var bgIntro:Array<BackgroundSprite> = [
	{path: "fatality/new/launchbase/fondo1", scale: [4, 4], animation: [{name: "fondo_gif", looped: true}], scroll: [0.2, 0.2]},
	{path: "fatality/new/launchbase/agua1", position: [0, 700], scale: [4, 4], animation: [{name: "agua", looped: true}], scroll: [0.4, 0.4]},
	{path: "fatality/new/launchbase/montanas", position: [-1, 462], scale: [4, 4], scroll: [0.4, 0.4]},
	{path: "fatality/new/launchbase/agua2", position: [0, 800], scale: [4, 4], animation: [{name: "agua2", looped: true}], scroll: [0.5, 0.5]},
	{path: "fatality/new/launchbase/pla", position: [2, -49], scale: [4, 4], scroll: [0.5, 0.5]},
	{path: "fatality/new/launchbase/planta", position: [0, 1000], scale: [4, 4], scroll: [0.8, 0.8]},
	{path: "fatality/new/launchbase/piso", position: [0, 1120], scale: [4, 4]}
];

var bgGlitch:Array<BackgroundSprite> = [
	{path: "fatality/new/domain/bgmask", scale: [4, 4], scroll: [0.2, 0.2]},
	{path: "fatality/new/domain/popupsbg", position: [0, -400], scale: [3, 3], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.2, 0.2], backdrop: [0x01, [-200, 0], [80, 0]]},
	{path: "fatality/new/domain/montañas", position: [73.5, 56], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.4, 0.4]},
	{path: "fatality/new/domain/popupsbg", position: [0, 100], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.4, 0.4], backdrop: [0x01, [-400, 0], [80, 0]]},
	{path: "fatality/new/domain/edificios", position: [30, 70], scale: [4, 4], animation: [{name: "idle", looped: true, fps: 12}], scroll: [0.5, 0.5]},
	{path: "fatality/new/domain/planta2", position: [0, 1000], scale: [4, 4], scroll: [0.8, 0.8]},
	{path: "fatality/new/domain/piso2", position: [0, 1120], scale: [4, 4]},
	{path: "fatality/new/domain/piso2fatal", position: [0, 1120], scale: [4, 4], backdrop: [0x01, [-100, 0], [40, 0]]},
	//victims
	{path: "fatality/new/domain/Bot", position: [-1800, 20], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 4},
	{path: "fatality/new/domain/tails", position: [-800, 20], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 2},
	{path: "fatality/new/domain/mecha-and-egg", position: [1700, -80], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 4, flip: [true, false]},
	{path: "fatality/new/domain/knux", position: [300, 20], scale: [4, 4], animation: [{name: "dance", looped: false}], boopable: true, bopInt: 2, flip: [false, false]}
];

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

function onCreatePost()
{
	FlxG.camera.pixelPerfectRender = true;
	camHUD.pixelPerfectRender = true;
	makeBackground(bgIntro);
	makeBackground(bgGlitch);
	for (spr in bgGlitch) spr.sprite.visible = false;
	bgGlitch[1].sprite.color = 0xFF474747;
	bgGlitch[3].sprite.color = 0xFFBBBBBB;

	for (i in 0...8)
	{
		var strum:StrumNote = game.strumLineNotes.members[i];
		if (i < 4)
		{
			strum.texture = 'noteSkins/NOTEFATAL_assets';
			strum.x = 10 + (strum.width * i);
		}
		else strum.x = (FlxG.width - 10 - (strum.width * 4)) + (strum.width * (i - 4));
	}
	for (i in 0...unspawnNotes.length-1)
	{
		var note:Note = game.unspawnNotes[i];
		if (note.mustPress) continue;
		note.texture = 'noteSkins/NOTEFATAL_assets';
	}
}

var oldMHS:Bool = false;
function onSectionHit()
{
	if (oldMHS != mustHitSection)
	{
		cam.OGZoom = mustHitSection ? 1 : 0.4;
	}
	oldMHS = mustHitSection;
}

var curBG:String = 'intro';
var bgMatrix:ErrorHandledRuntimeShader;
var pseudo:ErrorHandledRuntimeShader;
function onBeatHit()
{
	for (spr in bgGlitch) if (curBeat % spr.bopInt == 0) spr.sprite.animation.play('dance', true);

	if (curBG == 'fatal' && curBeat % 4 == 0) bgMatrix.setFloat('brightint', 1);
}

function onEvent(n,v1)
{
	if (n == 'FatalityFlashin')
	{
		switch(v1)
		{
			case 'xd':
				pseudo = new ErrorHandledRuntimeShader('pseudo', File.getContent('contents/FATAL/shaders/pseudo.frag'));
				FlxTween.num(0, 1, Conductor.crochet / 500, null, v -> {
					pseudo.setFloat('sort', v);
				});
				camGame.filters = [new ShaderFilter(pseudo)]; camHUD.filters = [new ShaderFilter(pseudo)];
			case 'flash':
				game.cameraSpeed = 9999;
				new FlxTimer().start(0.1, (_) -> {game.cameraSpeed = 1;});
				camGame.filters = []; camHUD.filters = [];
				for (spr in bgIntro) spr.sprite.destroy();
				for (spr in bgGlitch) spr.sprite.visible = true;

				bgMatrix = new ErrorHandledRuntimeShader('fatal', File.getContent('contents/FATAL/shaders/fatal.frag'));
				bgGlitch[0].sprite.shader = bgMatrix;
				bgMatrix.setFloat('brightint', 0.2);
				curBG = 'fatal';
		}
	}
}

var iT:Float = 0;
var moveTimers:Map<FlxSprite, Array<Float>> = [];
function onUpdatePost(e)
{
	if (curBG == 'fatal')
	{
		iT += e * (bgMatrix.getFloat('brightint') * 5);
		bgMatrix.setFloat('iTime', iT);
		bgMatrix.setFloat('brightint', FlxMath.lerp(bgMatrix.getFloat('brightint'), 0.2, e * 3));
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
			sprite = new FlxBackdrop(Paths.image(spriteDef.path), spriteDef.backdrop[0] ?? 0x11, (spriteDef.backdrop[2] ?? [0, 0])[0], (spriteDef.backdrop[2] ?? [0, 0])[1]);
			sprite.setPosition((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			sprite.velocity.set((spriteDef.backdrop[1] ?? [0, 0])[0], (spriteDef.backdrop[1] ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
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
		sprite.antialiasing = false;
		if (spriteDef.flip != null) {sprite.flipX = (spriteDef.flip ?? [false, false])[0]; sprite.flipY = (spriteDef.flip ?? [false, false])[1]; }
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}