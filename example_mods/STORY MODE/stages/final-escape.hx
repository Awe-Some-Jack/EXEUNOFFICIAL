import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;
import objects.Character;
import openfl.display.BlendMode;
import backend.Controls;

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
	{path: 'final/escape/bg3', position: [-950, -480], scroll: [0.35, 0.35], visible: false, backdrop: [0x01, [-750, 0]]},
	{path: 'final/escape/clouds1', position: [0, -480], scroll: [0.35, 0.35], visible: false, backdrop: [0x01, [20, 0]], alpha: 0.35},
	{path: 'final/escape/clouds2', position: [0, -480], scroll: [0.35, 0.35], visible: false, backdrop: [0x01, [40, 0]], alpha: 0.5},
	{path: 'final/escape/water', position: [-1200, -500], scroll: [0.7, 0.7], scale: [0.7, 0.7, true], animation: [{name: "idle", fps: 9, looped: true}], visible: false},
	{path: 'final/escape/bg2', position: [-1100, -600], scroll: [0.5, 0.5], visible: false, backdrop: [0x01, [-1250, 0]]},
	{path: 'final/escape/bg1', position: [-1200, -550], scroll: [0.7, 0.7], visible: false, backdrop: [0x01, [-2000, 0]]},
	{path: 'final/escape/objects3', position: [-1210, -745], visible: false},
	{path: 'final/escape/objects2', position: [-1210, -745], visible: false, front: true},
	{path: 'final/escape/objects1', position: [-1210, -745], visible: false, front: true},
	{path: 'final/escape/floor', position: [-1210, -665], scale: [0.7, 0.7, true], animation: [{name: "idle", looped: true}], visible: false},
	{path: 'final/escape/overlay', position: [-1210, -705], visible: false, front: true},
	{path: 'final/escape/multiply', position: [-1210, -705], visible: false, front: true},
	{path: 'final/escape/edge', position: [-1210, -705], visible: false, front: true}
];

var bgThird:Array<BackgroundSprite> = [
	{path: 'final/third/floorp3', position: [-950, -400], scale: [0.5, 0.5, true], animation: [{name: "idle", looped: true}], visible: false},
	{path: 'final/third/objects1', position: [-600, -150], scale: [0.65, 0.65, true], visible: false, front: true},
	{path: 'final/third/objects2', position: [-450, -150], scale: [0.65, 0.65, true], visible: false, front: true}
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
var fourthFloor:FlxSprite;

//legsList
var bfLegsFramerate:Character;
var bfLegs2back:Character;
var bfLegs2:Character;
var bfLegs3:Character;
var bfLegs4:Character;

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
	game.remove(dadGroup, true);
	game.insert(game.members.indexOf(bgIntro[bgIntro.length - 1].sprite), dadGroup);
	bgIntro[bgIntro.length - 1].sprite.color = 0xFF000000;

	makeBackground(bgSecond);
	bgSecond[bgSecond.length - 2].sprite.blend = BlendMode.MULTIPLY;
	makeBackground(bgThird);
	
	fourthFloor = new FlxSprite(-1300, -900);
	fourthFloor.frames = Paths.getSparrowAtlas('final/floor4');
	fourthFloor.scale.set(0.8, 0.8); fourthFloor.updateHitbox();
	fourthFloor.animation.addByPrefix('idle', 'floor4 idle', 24, true); fourthFloor.animation.play('idle', true);
	fourthFloor.visible = false;
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), fourthFloor);

	fifthFloor = new FlxSprite(-2500, -1150);
	fifthFloor.frames = Paths.getSparrowAtlas('final/floor5fe');
	fifthFloor.scale.set(1.5,1.5); fifthFloor.updateHitbox();
	fifthFloor.animation.addByPrefix('idle', 'idle', 24, true); fifthFloor.animation.play('idle', true);
	fifthFloor.visible = false;
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), fifthFloor);

	// preload chars

	preloadCharacter(1, 'xeno-fe2');
	preloadCharacter(0, 'bf-fe2');

	preloadCharacter(1, 'xeno-fe3');
	preloadCharacter(0, 'bf-fe3');

	preloadCharacter(1, 'xeno-handfe');
	preloadCharacter(0, 'bf-fe4');

	preloadCharacter(0, 'bf-ferunning');

	xenoRing = new FlxSprite(dad.x, dad.y).loadGraphic(Paths.image('characters/FINAL-ESCAPE-HD'));
	xenoRing.scale.set(1.3, 1.3); xenoRing.updateHitbox();
	game.insert(game.members.indexOf(bgSecond[bgSecond.length - 4].sprite), xenoRing);
	xenoRing.visible = false;

	//legs making
	bfLegsFramerate = new Character(0, 0, 'bf-fe2legs');
	bfLegsFramerate.visible = false;
	game.add(bfLegsFramerate);

	bfLegs2 = new Character(boyfriend.x + 435, boyfriend.y - 55, 'bf-fe2legs', true);
	bfLegs2.visible = false;
	game.insert(game.members.indexOf(boyfriendGroup) + 1, bfLegs2);

	bfLegs2back = new Character(boyfriend.x + 410, boyfriend.y - 55, 'bf-fe2legsback', true);
	bfLegs2back.visible = false;
	game.insert(game.members.indexOf(boyfriendGroup), bfLegs2back);

	bfLegs3 = new Character(boyfriend.x - 8, boyfriend.y + 110, 'bf-fe3legs', true);
	bfLegs3.visible = false;
	game.insert(game.members.indexOf(boyfriendGroup) + 1, bfLegs3);

	bfLegs4 = new Character(boyfriend.x + 330, boyfriend.y - 230, 'bf-fe4back', true);
	bfLegs4.visible = false;
	game.insert(game.members.indexOf(boyfriendGroup), bfLegs4);
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

var inFront:Bool = true;
var floatSine:Float = 0;
var floatIntensity:Float = 1;
var introYPos:Float = -410;
var offsetScale:Float = 1;
var legsFrame:Int = 0;
var bfAction:String = '';
var bfPressAction:String = '';
function onUpdatePost(elapsed:Float)
{
	blackBG.scale.set((1 / camGame.zoom) * offsetScale, (1 / camGame.zoom) * offsetScale);
	floatSine += elapsed * floatIntensity;

	bfLegsFramerate?.update();
	legsFrame = bfLegsFramerate.animation.curAnim.curFrame ?? 0;
	switch(curBG)
	{
		case 'intro':
			for (i in 5...8) {
				if (bgIntro[i].sprite.visible)
				{
					bgIntro[i].sprite.setPosition(
						bgIntro[i].position[0] + Math.sin(floatSine + i) * 3,
						bgIntro[i].position[1] + Math.cos(floatSine + i) * 10
					);
					bgIntro[i].sprite.angle = Math.cos(floatSine + i * 0.5) * 2;
				}
			}

			dad.setPosition(
				-442 + Math.sin(floatSine * 0.75) * 7,
				introYPos + Math.cos(floatSine * 0.75) * 25
			);
			if (eyes != null) eyes.setPosition(dad.x + 400, dad.y + 440);
		case 'second':
			for (i in 6...9) {
				if (bgSecond[i].sprite.visible)
				{
					bgSecond[i].sprite.setPosition(
						bgSecond[i].position[0] + Math.sin(floatSine + (i * 2)) * 3,
						bgSecond[i].position[1] + Math.cos(floatSine + (i * 2)) * 10
					);
					bgSecond[i].sprite.angle = Math.cos(floatSine + (i * 2)) * 2;
				}
			}

			if (bgSecond[9].sprite.visible)
			{
				boyfriend.y = 149 + Math.cos(floatSine) * 15;
				bfLegs2.y = boyfriend.y + 115;
				bfLegs2back.y = boyfriend.y + 100;
				bgSecond[9].sprite.y = bgSecond[9].position[1] + Math.cos(floatSine) * 15;
			}

			dad.setPosition(
				-442 + Math.sin(floatSine * 0.75) * 10,
				-280 + Math.cos(floatSine * 0.75) * 50
			);

			if (xenoRing.visible) xenoRing.setPosition(dad.x - 680, dad.y - 200);

			if (dad.animation.curAnim.name == 'singLEFT' && !inFront)
			{
				inFront = true;
				game.remove(dadGroup, true);
				game.insert(game.members.indexOf(boyfriendGroup) - 1, dadGroup);
			}
			else if (dad.animation.curAnim.name != 'singLEFT' && inFront)
			{
				inFront = false;
				game.remove(dadGroup, true);
				game.insert(game.members.indexOf(xenoRing) + 1, dadGroup);
			}

			bfLegs2?.update();
			bfLegs2back?.update();
			bfLegs2?.animation.curAnim.curFrame = legsFrame;
			bfLegs2back?.animation.curAnim.curFrame = legsFrame;
			if (boyfriend?.animation.curAnim.name == 'idle') boyfriend.animation.curAnim.curFrame = legsFrame;
		case 'third':
			for (i in 1...3) {
				if (bgThird[i].sprite.visible)
				{
					bgThird[i].sprite.setPosition(
						bgThird[i].position[0] + Math.sin(floatSine + i) * 3,
						bgThird[i].position[1] + Math.cos(floatSine + i) * 10
					);
					bgThird[i].sprite.angle = Math.cos(floatSine + i * 0.5) * 2;
				}
			}

			dad.setPosition(
				-750 + Math.sin(floatSine * 0.75) * 10,
				-170 + Math.cos(floatSine * 0.75) * 50
			);

			bfLegs3?.update();
			bfLegs3?.animation.curAnim.curFrame = legsFrame;
			if (boyfriend?.animation.curAnim.name == 'idle') boyfriend.animation.curAnim.curFrame = legsFrame;
		case 'fourth':
			for (i in 6...9) {
				if (bgSecond[i].sprite.visible)
				{
					bgSecond[i].sprite.setPosition(
						bgSecond[i].position[0] - 200 + Math.sin(floatSine + (i * 2)) * 3,
						bgSecond[i].position[1] - 150 + Math.cos(floatSine + (i * 2)) * 10
					);
					bgSecond[i].sprite.angle = Math.cos(floatSine + (i * 2)) * 2;
				}
			}

			bfLegs4?.update();
			bfLegs4?.animation.curAnim.curFrame = legsFrame;
			if (boyfriend?.animation.curAnim.name == 'idle') boyfriend.animation.curAnim.curFrame = legsFrame;
		case 'fifth':
			var slide:Bool = Controls.instance.UI_DOWN || Controls.instance.NOTE_DOWN;
			var jump:Bool = Controls.instance.UI_UP || Controls.instance.NOTE_UP;

			if (slide && bfAction == '' && bfPressAction != 'slide')
			{
				bfAction = bfPressAction = 'slide';
				boyfriend.playAnim('slide', true); boyfriend.specialAnim = true;
			}
			if (jump && bfAction == '' && bfPressAction != 'jump')
			{
				bfAction = bfPressAction = 'jump';
				boyfriend.playAnim('jump', true); boyfriend.specialAnim = true;
			}
			if (bfPressAction == 'jump' && !jump) bfPressAction = '';
			if (bfPressAction == 'slide' && !slide) bfPressAction = '';
	}
}

var _bruh:Bool = false;
function onEvent(n,v1,v2)
{
	if (n == 'finalescapeEvent')
	{
		switch(v1)
		{
			//lightning wow amazing
			case 'lightning':
				var lightning:FlxSprite = bgIntro[1].sprite;
				lightning.animation.play('variant' + FlxG.random.int(1,3), true);
				lightning.alpha = 1;
				game.triggerEvent('bloomFlash', '0.15, 0', '0.5', Conductor.songPosition);
				
			case 'fuckYouVideo':
				if (introCutscene != null) introCutscene.destroy();
				camGame.alpha = 1;
				FlxG.camera.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				camGame.targetOffset.y = -100;
				camGame.zoom = 1.4;
				camGame.snapToTarget();
				FlxTween.tween(camGame, {zoom: 0.8}, Conductor.crochet / (1000 / 20), {ease: FlxEase.expoInOut});
				FlxTween.tween(camGame.targetOffset, {y: 0}, Conductor.crochet / (1000 / 12), {ease: FlxEase.cubeOut});
				dad.alpha = 0; eyes.alpha = 0; boyfriend.alpha = 0;
				var t = {v: (-410 - 1000)};
				FlxTween.tween(t, {v: -410}, Conductor.crochet / (1000 / 20), {ease: FlxEase.cubeOut, onUpdate: function(_) {introYPos = t.v;}});
			case 'fadeEyes':
				FlxTween.tween(eyes, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
			case 'fadeDad':
				FlxTween.cancelTweensOf(eyes);
				FlxTween.tween(eyes, {alpha: 0}, Conductor.crochet / (1000 / 2), {ease: FlxEase.cubeInOut});
				FlxTween.tween(dad, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
			case 'intro':
				FlxTween.tween(blackBG, {alpha: 0}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
				FlxTween.tween(boyfriend, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.cubeInOut});
				FlxTween.color(bgIntro[bgIntro.length - 1].sprite, Conductor.crochet / (1000 / 4), 0xFF000000, 0xFFFFFFFF, {ease: FlxEase.cubeInOut});
				eyes.destroy();
			case 'fadeNotes':
				for (i in 0...4) FlxTween.tween(playerStrums.members[i], {alpha: 1, y: (playerStrums.members[i].y + (prefs.downScroll ? -10 : 10))}, Conductor.crochet / 250, {ease: FlxEase.cubeInOut, startDelay: i / 4});
			case 'yeahbf':
				bfYeah.visible = true;
				FlxTween.tween(bfYeah, {x: (FlxG.width - bfYeah.width) / 2}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
				bfYeah.animation.play('yeah', true);
			case 'secondsection':
				floatIntensity = 3;
				bfYeah.destroy();
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				for (spr in bgIntro) spr.sprite.visible = false; bgIntro[1].sprite.visible = true;
				for (spr in bgSecond) spr.sprite.visible = true;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgSecond[4].sprite), bgIntro[1].sprite);
				bgIntro[1].sprite.y -= 400;
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
				boyfriend.y -= 100;
				bfLegs2.visible = true;
				bfLegs2back.visible = true;
				xenoRing.visible = true;
				curBG = 'second';
				cam.MiddleX = 100;
				cam.OGZoom = 0.8;
				cam.BFx = 350;
				cam.BFy = 200;
			case 'thirdsection':
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				changeCharacter('dad', 'xeno-fe3');
				changeCharacter('bf', 'bf-fe3');
				bgIntro[1].sprite.y += 400;
				boyfriend.x -= 10;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgIntro[0].sprite) + 1, bgIntro[1].sprite);
				for (spr in bgSecond) spr.sprite.visible = false; bgSecond[bgSecond.length - 2].sprite.visible = true; bgSecond[bgSecond.length - 1].sprite.visible = true;
				for (spr in bgIntro) spr.sprite.visible = true;
				bgIntro[5].sprite.visible = false; bgIntro[6].sprite.visible = false; bgIntro[7].sprite.visible = false; bgIntro[9].sprite.visible = false;
				for (spr in bgThird) spr.sprite.visible = true;
				xenoRing.visible = false;
				curBG = 'third';
				cam.DADy = 150;
				cam.BFx = 0;
				cam.BFy = 300;
				bfLegs3.visible = true;
				bfLegs2.visible = false;
				bfLegs2back.visible = false;
			case 'fadecam':
				FlxTween.tween(blackBG, {alpha: 1}, Conductor.crochet / (1000 / 2.5));
				blackBG.camera = camOther;
				offsetScale = 2;
			case 'backsecondsection':
				FlxTween.cancelTweensOf(blackBG);
				blackBG.alpha = 1;
				FlxTween.tween(blackBG, {alpha: 0}, Conductor.crochet / 1000);
				changeCharacter('dad', 'xeno-fe2');
				changeCharacter('bf', 'bf-fe2');
				for (spr in bgIntro) spr.sprite.visible = false; bgIntro[1].sprite.visible = true;
				for (spr in bgSecond) spr.sprite.visible = true;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgSecond[4].sprite), bgIntro[1].sprite);
				for (spr in bgThird) spr.sprite.destroy();
				bgIntro[1].sprite.y -= 400;
				xenoRing.visible = true;
				curBG = 'second';
				cam.BFx = 250;
				cam.BFy = 120;
				cam.DADy = 0;
				bfLegs2.visible = true;
				bfLegs2back.visible = true;
				bfLegs3.destroy();
			case 'cinematicbars':
				lua('topbar').setGraphicSize(lua('topbar').width, FlxG.height / 2 + 50); lua('topbar').updateHitbox();
				FlxTween.cancelTweensOf(lua('topbar'));
				lua('topbar').y += 150 - (FlxG.height / 2 + 50);
				FlxTween.tween(lua('topbar'), {y: (FlxG.height / 2) - lua('topbar').height}, Conductor.crochet / 500, {ease: FlxEase.cubeIn});

				lua('botbar').setGraphicSize(lua('botbar').width, FlxG.height / 2 + 50); lua('botbar').updateHitbox();
				FlxTween.cancelTweensOf(lua('botbar'));
				FlxTween.tween(lua('botbar'), {y: (FlxG.height / 2)}, Conductor.crochet / 500, {ease: FlxEase.cubeIn});
			case 'fourthsection':
				_bruh = true;
				changeCharacter('dad', 'xeno-handfe');
				changeCharacter('bf', 'bf-fe4');
				game.remove(dadGroup, true);
				game.insert(game.members.indexOf(boyfriendGroup) - 1, dadGroup);
				boyfriend.setPosition(250, 150);
				dad.setPosition(-1000, -600);
				fourthFloor.visible = true;
				bgSecond[9].sprite.visible = false;
				bfLegs2.visible = false;
				bfLegs2back.visible = false;
				bfLegs4.visible = true;
				xenoRing.visible = false;
				curBG = 'fourth';
				cam.DADx = 50;
				cam.DADy = 50;
				cam.BFx = 350;
				cam.BFy = 250;
				FlxTween.tween(dad, {x: dad.x + 650, y: dad.y + 400}, 20);

				bgSecond[0].sprite.y -= 300;
				bgSecond[1].sprite.y -= 300;
				bgSecond[2].sprite.y -= 300;
				bgSecond[3].sprite.y -= 300;
				bgSecond[4].sprite.y -= 300;
				bgSecond[5].sprite.y -= 300;
			case 'adjustdadcam':
				cam.DADx = 150;
				cam.DADy = 150;
			case 'startingrun':
				FlxTween.tween(blackBG, {alpha: 1}, Conductor.crochet / (1000 / 4));
			case 'startfifthsection':
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				FlxTween.cancelTweensOf(blackBG);
				blackBG.alpha = 0;
				changeCharacter('bf', 'bf-ferunning');
				boyfriend.playAnim('intro', true); boyfriend.specialAnim = true;
				boyfriend.animation.finishCallback = function(name:String){if (name != 'run' && curBG == 'fifth'){boyfriend.playAnim('run', true); boyfriend.specialAnim = true; bfAction = '';}};
				boyfriend.y += 50;
				dad.alpha = 0;
				bfLegs4.destroy();
				fourthFloor.destroy();
				fifthFloor.visible = true;
				bgSecond[0].sprite.y += 400;
				bgSecond[1].sprite.y += 400;
				bgSecond[2].sprite.y += 400;
				bgSecond[3].sprite.y += 400; bgSecond[3].sprite.x += 150;
				bgSecond[4].sprite.y += 400;
				bgSecond[5].sprite.y += 400;
				bgSecond[6].sprite.visible = false;
				bgSecond[7].sprite.visible = false;
				bgSecond[8].sprite.visible = false;
				cam.MiddleX = -100;
				cam.MiddleY = 450;
				cam.MiddleZoom = 1;
				curBG = 'fifth';
			case 'attack':
				var obstacle:FlxSprite = new FlxSprite(1500, v2 == 'bot' ? 600 : 300).loadGraphic(Paths.image('final/obstacle'));
				obstacle.angularVelocity = FlxG.random.float(-25, 25);
				obstacle.scale.set(1.5, 1.5); obstacle.updateHitbox();
				obstacle.velocity.x = -2000;
				game.insert(game.members.indexOf(boyfriendGroup) + 1, obstacle);

				var warning:FlxSprite = new FlxSprite(900, v2 == 'bot' ? 500 : 200).loadGraphic(Paths.image('final/warning'));
				warning.scrollFactor.set(0.1, 0.1);
				game.insert(game.members.indexOf(boyfriendGroup) + 2, warning);

				FlxG.sound.play(Paths.sound('warnin'), 0.9);
				warning.scale.set(1.1, 1.1);
				warning.angle = 5 * (v2 == 'bot' ? 1 : -1);
				FlxTween.tween(warning, {alpha: 0, angle: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
				FlxTween.tween(warning.scale, {x: 1, y: 1}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
				new FlxTimer().start(Conductor.crochet / 1000, function(tmr)
				{
					if (tmr.loopsLeft == 1)
					{
						FlxTween.cancelTweensOf(warning); FlxTween.cancelTweensOf(warning.scale);
						warning.destroy();
						//reaction time
						new FlxTimer().start(0.1, function(_)
						{
							if (v2 == 'bot' && bfAction != 'jump')
							{
								FlxG.camera.shake(0.01, 0.1);
								camHUD.shake(0.005, 0.1);
								game.health -= 0.3;
								obstacle?.destroy();
								FlxG.sound.play(Paths.sound('hit'));
							}
							else if (v2 == 'top' && bfAction != 'slide')
							{
								FlxG.camera.shake(0.01, 0.1);
								camHUD.shake(0.005, 0.1);
								game.health -= 0.3;
								obstacle?.destroy();
								FlxG.sound.play(Paths.sound('hit'));
							}
						});
					}
					else if (tmr.loopsLeft > 1)
					{
						//warnings
						FlxG.sound.play(Paths.sound('warnin'), 0.9);
						FlxTween.cancelTweensOf(warning); FlxTween.cancelTweensOf(warning.scale);
						warning.alpha = 1;
						warning.scale.set(1.1, 1.1);
						warning.angle = 5 * (v2 == 'bot' ? -1 : 1);
						FlxTween.tween(warning, {alpha: 0, angle: 0, y: warning.y + (v2 == 'bot' ? 10 : -10)}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
						FlxTween.tween(warning.scale, {x: 1, y: 1}, Conductor.crochet / 1000, {ease: FlxEase.cubeOut});
					}
					else obstacle?.destroy();
				}, 3);
		}
	}
	if (n == 'ScreenBorders' && _bruh)
	{
		FlxTween.cancelTweensOf(lua('topbar'));
		FlxTween.tween(lua('topbar'), {y: -lua('topbar').height}, 1, {ease: FlxEase.cubeOut});
	}
}

function opponentNoteHit(note)
{
	if (curBG == 'second' || curBG == 'third')
	{
		FlxG.camera.shake(0.005, 0.1);
		camHUD.shake(0.0025, 0.1);
	}
}

function lua(obj:String) return game.getLuaObject(obj); 

function goodNoteHit(note)
{
	if (curBG == 'third' && bfLegs3 != null)
	{
		bfLegs3.playAnim(game.singAnimations[note.noteData], true);
		bfLegs3.holdTimer = 0;
	}

	if (curBG == 'second' && bfLegs2 != null && bfLegs2back != null)
	{
		bfLegs2.playAnim(game.singAnimations[note.noteData], true);
		bfLegs2.holdTimer = 0;
		bfLegs2?.animation.curAnim.curFrame = legsFrame;
		bfLegs2back.playAnim(game.singAnimations[note.noteData], true);
		bfLegs2back.holdTimer = 0;
		bfLegs2back?.animation.curAnim.curFrame = legsFrame;
	}

	if (curBG == 'fourth' && bfLegs4 != null)
	{
		bfLegs4.playAnim(game.singAnimations[note.noteData], true);
		bfLegs4.holdTimer = 0;
	}
}

function noteMiss(note)
{
	if (curBG == 'second' && bfLegs2 != null && bfLegs2back != null) bfLegs2.playAnim(game.singAnimations[note.noteData] + 'miss', true);
	if (curBG == 'third' && bfLegs3 != null) bfLegs3.playAnim(game.singAnimations[note.noteData] + 'miss', true);
	if (curBG == 'fourth' && bfLegs4 != null) bfLegs4.playAnim(game.singAnimations[note.noteData] + 'miss', true);
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