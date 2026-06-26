import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;

typedef BackgroundSprite =
{
	var path:String;
	var sprite:FlxSprite;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool;
	@:optional var animation:Array<Dynamic>;
	@:optional var backdrop:Array<Dynamic>;
}

var bgIntro:Array<BackgroundSprite> = [
	{path: 'final/intro/sky', position: [-500, -220], scroll: [0.3, 0.3]},
	{path: 'final/intro/lightnings', position: [-500, -220], scroll: [0.4, 0.4], scale: [0.5, 0.5, true], animation: [{name: "variant1"}, {name: "variant2"}, {name: "variant3"}]},
	{path: 'final/intro/cloudsbg', position: [-560, -250], scroll: [0.4, 0.4]},
	{path: 'final/intro/clouds2', position: [-625, -250], scroll: [0.5, 0.5]},
	{path: 'final/intro/clouds1', position: [-690, -250], scroll: [0.6, 0.6]},
	{path: 'final/intro/objects3', position: [-300, -140], scroll: [0.6, 0.6]},
	{path: 'final/intro/objects2', position: [-130, -240], scroll: [0.6, 0.6]},
	{path: 'final/intro/objects1', position: [-360, -150], scroll: [0.6, 0.6]},
	{path: 'final/intro/lake', position: [-755, -280], scroll: [0.7, 0.7]},
	{path: 'final/intro/floor', position: [-948, 230]}
];

var bgSecond:Array<BackgroundSprite> = [
	{path: 'final/escape/bg3', position: [-950, -480], scroll: [0.35, 0.35], visible: false},
	{path: 'final/escape/clouds1', position: [0, -480], scroll: [0.35, 0.35], visible: false, backdrop: [0x01, [20, 0]], alpha: 0.35},
	{path: 'final/escape/clouds2', position: [0, -480], scroll: [0.35, 0.35], visible: false, backdrop: [0x01, [40, 0]], alpha: 0.5},
	{path: 'final/escape/water', position: [-1200, -500], scroll: [0.7, 0.7], scale: [0.7, 0.7, true], animation: [{name: "idle", fps: 9, looped: true}], visible: false},
	{path: 'final/escape/bg2', position: [-1100, -600], scroll: [0.5, 0.5], visible: false},
	{path: 'final/escape/bg1', position: [-1200, -550], scroll: [0.7, 0.7], visible: false},
	{path: 'final/escape/objects3', position: [-1210, -705], visible: false},
	{path: 'final/escape/objects2', position: [-1210, -705], visible: false},
	{path: 'final/escape/objects1', position: [-1210, -705], visible: false, front: true},
	{path: 'final/escape/floor', position: [-1210, -705], scale: [0.7, 0.7, true], animation: [{name: "idle", looped: true}], visible: false}
];

final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];

var introCutscene:hxvlc.flixel.FlxVideoSprite;
final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var blackBG:FlxSprite;
var eyes:FlxSprite;
var bfYeah:FlxSprite;
var xenoRing:FlxSprite;

var curBG:String = 'intro';
function onCreate()
{
	//intro
	camGame.alpha = 0;
	introCutscene = new hxvlc.flixel.FlxVideoSprite();
	introCutscene.bitmap.onFormatSetup.add(() -> {
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.updateHitbox();
		introCutscene.screenCenter();
	});
	introCutscene.camera = camVideo;
	introCutscene.bitmap.onEndReached.add(() -> introCutscene.destroy());
	game.add(introCutscene);

	//da bgs

	makeBackground(bgIntro);
	bgIntro[1].sprite.alpha = 0;
	bgIntro[1].sprite.animation.finishCallback = function(name:String){ bgIntro[1].sprite.alpha = 0; };

	makeBackground(bgSecond);

	// preload chars
	preloadCharacter(1, 'xeno-fe2');
	preloadCharacter(0, 'bf-fe2');

	xenoRing = new FlxSprite(dad.x, dad.y).loadGraphic(Paths.image('characters/FINAL-ESCAPE-HD'));
	game.insert(game.members.indexOf(bgSecond[bgSecond.length - 1].sprite), xenoRing);
	xenoRing.visible = false;
}

var notesPosition:Array<Array<Float>> = [[0,0,0,0], [0,0,0,0]];
final separation:Float = 50;
function onCreatePost()
{
	for (i in 0...4)
	{
		notesPosition[0][i] = opponentStrums.members[i].x; notesPosition[1][i] = playerStrums.members[i].x;
		opponentStrums.members[i].x = -1000;
		playerStrums.members[i].alpha = 0;
		playerStrums.members[i].y += (prefs.downScroll ? 10 : -10);
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width) + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i;
	}
	for (spr in hudSprites) game.getLuaObject(spr).alpha = 0;

	blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackBG.scrollFactor.set();
	blackBG.screenCenter();
	game.addBehindDad(blackBG);

	eyes = new FlxSprite().loadGraphic(Paths.image('final/intro/eyes'));
	eyes.scale.set(0.5, 0.5); eyes.updateHitbox();
	game.add(eyes);

	bfYeah = new FlxSprite(FlxG.width);
	bfYeah.frames = Paths.getSparrowAtlas('characters/bfyeahfe');
	bfYeah.animation.addByPrefix('yeah', 'yeah', 24, false);
	bfYeah.screenCenter(0x10);
	bfYeah.camera = camVideo;
	bfYeah.visible = false;
	game.add(bfYeah);
}

function onSongStart() if (introCutscene?.load(Paths.video('fake intro')) ?? false) introCutscene?.play();
function onGameOverStart() if (introCutscene != null) introCutscene.destroy();
function onPause() if (introCutscene != null) introCutscene.pause();
function onResume() if (introCutscene != null) introCutscene.resume();

var floatSine:Float = 0;
function onUpdatePost(elapsed:Float)
{
	blackBG.scale.set(1 / camGame.zoom, 1 / camGame.zoom);
	floatSine += elapsed;

	switch(curBG)
	{
		case 'intro':
			if (eyes != null) eyes.setPosition(dad.x + 400, dad.y + 280);
			for (i in 5...8) {
				if (bgIntro[i].sprite.visible)
				{
					bgIntro[i].sprite.setPosition(
						bgIntro[i].position[0] + Math.sin(floatSine + i) * 3,
						bgIntro[i].position[1] + Math.cos(floatSine + i) * 10
					);
					bgIntro[i].sprite.angle = Math.cos(floatSine + i) * 2;
				}
			}
		case 'second':
			for (i in 6...9) {
				if (bgSecond[i].sprite.visible)
				{
					bgSecond[i].sprite.setPosition(
						bgSecond[i].position[0] + Math.sin(floatSine + i) * 3,
						bgSecond[i].position[1] + Math.cos(floatSine + i) * 10
					);
					bgSecond[i].sprite.angle = Math.cos(floatSine + i) * 2;
				}
			}

			dad.setPosition(
				-442 + Math.sin(floatSine) * 3,
				-250 + Math.cos(floatSine) * 10
			);

			if (xenoRing.visible) xenoRing.setPosition(dad.x - 460, dad.y - 100);
	}
}

function onEvent(n,v1,v2)
{
	if (n == 'finalescapeEvent')
	{
		switch(v1)
		{
			case 'fuckYouVideo':
				if (introCutscene != null) introCutscene.destroy();
				camGame.alpha = 1;
				FlxG.camera.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				camGame.targetOffset.y = -100;
				camGame.zoom = 1.4;
				camGame.snapToTarget();
				FlxTween.tween(camGame, {zoom: 0.8}, Conductor.crochet / (1000 / 20), {ease: FlxEase.expoInOut});
				FlxTween.tween(camGame.targetOffset, {y: 0}, Conductor.crochet / (1000 / 12), {ease: FlxEase.cubeOut});
				dad.y -= 600; dad.alpha = 0; eyes.alpha = 0; boyfriend.alpha = 0;
				FlxTween.tween(dad, {y: dad.y + 600}, Conductor.crochet / (1000 / 20), {ease: FlxEase.cubeOut});
			case 'fadeEyes':
				FlxTween.tween(eyes, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
			case 'fadeDad':
				FlxTween.cancelTweensOf(eyes);
				FlxTween.tween(eyes, {alpha: 0}, Conductor.crochet / (1000 / 2), {ease: FlxEase.cubeInOut});
				FlxTween.tween(dad, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
			case 'intro':
				FlxTween.tween(blackBG, {alpha: 0}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
				FlxTween.tween(boyfriend, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
				eyes.destroy();
			case 'lightning':
				var lightning:FlxSprite = bgIntro[1].sprite;
				lightning.animation.play('variant' + FlxG.random.int(1,3), true);
				lightning.alpha = 1;
				game.triggerEvent('bloomFlash', '0.15, 0', '0.5', Conductor.songPosition);
			case 'fadeNotes':
				for (i in 0...4) FlxTween.tween(playerStrums.members[i], {alpha: 1, y: (playerStrums.members[i].y + (prefs.downScroll ? -10 : 10))}, Conductor.crochet / 250, {ease: FlxEase.cubeInOut, startDelay: i / 4});
			case 'yeahbf':
				bfYeah.visible = true;
				FlxTween.tween(bfYeah, {x: (FlxG.width - bfYeah.width) / 2}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
				bfYeah.animation.play('yeah', true);
			case 'secondsection':
				bfYeah.destroy();
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				for (spr in bgIntro) spr.sprite.visible = false;
				for (spr in bgSecond) spr.sprite.visible = true;
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 1;
				for (i in 0...4)
				{
					opponentStrums.members[i].x = notesPosition[0][i];
					playerStrums.members[i].x = notesPosition[1][i];
				}
				FlxTween.cancelTweensOf(boyfriend); FlxTween.cancelTweensOf(dad);
				boyfriend.alpha = 1; dad.alpha = 1;
				changeCharacter('dad', 'xeno-fe2');
				changeCharacter('bf', 'bf-fe2');
				boyfriend.x += 400;
				boyfriend.y -= 150;
				xenoRing.visible = true;
				curBG = 'second';
		}
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
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;
	}
}