import psychlua.LuaUtils;
import objects.Character;
import objects.VideoSprite;
import backend.Controls;

import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;

using StringTools;

var bgIntro:Array<BackgroundSprite> = [
	{path: 'final/intro/sky', position: [-500, -220], scroll: [0.3, 0.3]},
	{path: 'final/intro/lightnings', position: [-500, -220], scroll: [0.4, 0.4], scale: [0.5, 0.5, true], animation: [{name: "variant1"}, {name: "variant2"}, {name: "variant3"}], alpha: 0},
	{path: 'final/intro/cloudsbg', position: [-560, -250], scroll: [0.4, 0.4]},
	{path: 'final/intro/clouds2', position: [-625, -250], scroll: [0.5, 0.5]},
	{path: 'final/intro/clouds1', position: [-690, -250], scroll: [0.6, 0.6]},
	{path: 'final/intro/objects3', position: [-300, -140], scroll: [0.6, 0.6]},
	{path: 'final/intro/objects2', position: [-130, -240], scroll: [0.6, 0.6]},
	{path: 'final/intro/objects1', position: [-360, -150], scroll: [0.6, 0.6]},
	{path: 'final/intro/lake', position: [-755, -280], scroll: [0.7, 0.7]},
	{path: 'final/intro/floor', position: [-948, 230], color: 0xFF000000}
];

var bgSecond:Array<BackgroundSprite> = [
	{path: 'final/escape/bg3', position: [-950, -480], scroll: [0.35, 0.35], visible: false, backdrop: ['x', [-750, 0]]},
	{path: 'final/escape/clouds1', position: [0, -480], scroll: [0.35, 0.35], visible: false, backdrop: ['x', [20, 0]], alpha: 0.35},
	{path: 'final/escape/clouds2', position: [0, -480], scroll: [0.35, 0.35], visible: false, backdrop: ['x', [40, 0]], alpha: 0.5},
	{path: 'final/escape/water', position: [-1200, -500], scroll: [0.7, 0.7], scale: [0.7, 0.7, true], animation: [{name: "idle", fps: 9, looped: true}], visible: false},
	{path: 'final/escape/bg2', position: [-1100, -600], scroll: [0.5, 0.5], visible: false, backdrop: ['x', [-1250, 0]]},
	{path: 'final/escape/bg1', position: [-1200, -550], scroll: [0.7, 0.7], visible: false, backdrop: ['x', [-2000, 0]]},
	{path: 'final/escape/objects3', position: [-1210, -745], visible: false},
	{path: 'final/escape/objects2', position: [-1210, -745], visible: false, front: true},
	{path: 'final/escape/objects1', position: [-1210, -745], visible: false, front: true},
	{path: 'final/escape/floor', position: [-1210, -665], scale: [0.7, 0.7, true], animation: [{name: "idle", looped: true}], visible: false},
	{path: 'final/escape/overlay', position: [-1210, -705], visible: false, front: true},
	{path: 'final/escape/multiply', position: [-1210, -705], visible: false, front: true, blend: 'multiply'},
	{path: 'final/escape/edge', position: [-1210, -705], visible: false, front: true, color: 0xFF000000}
];

var bgThird:Array<BackgroundSprite> = [
	{path: 'final/third/floorp3', position: [-950, -400], scale: [0.5, 0.5, true], animation: [{name: "idle", looped: true}], visible: false},
	{path: 'final/third/objects1', position: [-600, -150], scale: [0.65, 0.65, true], visible: false, front: true},
	{path: 'final/third/objects2', position: [-450, -150], scale: [0.65, 0.65, true], visible: false, front: true}
];

var bgCarnival:Array<BackgroundSprite> = [
	{path: 'final/carnival/bg-lol', position: [0, -530], visible: false, backdrop: ['x', [-2000, 0]]},
	{path: 'final/carnival/carnivalbg', position: [0, -530], visible: false, backdrop: ['x', [-2000, 0]]},
	{path: 'final/carnival/pinchos', position: [0, -520], visible: false, backdrop: ['x', [4000, 0]], flip: [false, true]}
	{path: 'final/carnival/pinchos', position: [0, 430], visible: false, backdrop: ['x', [-4000, 0]]},
];

final hbvanilla:Array<String> = ['hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG'];
final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'exeScoreTxt'];

var introCutscene:VideoSprite;
var YWGA:VideoSprite;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var blackBG:FlxSprite;
var eyes:FlxSprite;
var bfYeah:FlxSprite;
var xenoRing:FlxSprite;
var fourthFloor:FlxSprite;
var drowningBf:FlxSprite;
var bfDrowningPlayable:Character;
var laughxeno:FlxSprite;
var xenoLaugh:Character;
var superBFAura:FlxSprite;

//legsList
var bfLegsFramerate:Character;
var bfLegs2back:Character;
var bfLegs2:Character;
var bfLegs3:Character;
var bfLegs4:Character;

//bf on hand section lol
var bfAtlas:FlxSpriteElement;
var bf:Character;

//ChromShader
var chrom:FlxRuntimeShader;

var cameraLeft:FlxCamera;
var cameraRight:FlxCamera;

var curBG:String = 'intro';

var oldGT:Bool = false;
function onCreate()
{
	oldGT = prefs.ghostTapping;
	//intro
	camGame.alpha = 0;

	introCutscene = new VideoSprite();
	introCutscene.onFormat(() -> {
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.screenCenter();
	});
	introCutscene.camera = camVideo;
	game.add(introCutscene);

	//You wont get away!
	YWGA = new VideoSprite();
	YWGA.onFormat(() -> {
		YWGA.setGraphicSize(FlxG.width, FlxG.height);
		YWGA.screenCenter();
		camHUD.visible = false;
		camOther.flash(0xFFFFFFFF, Conductor.crochet / 500, null, true);
	});
	YWGA.camera = camVideo;
	game.add(YWGA);

	//da bgs

	makeBackground(bgIntro);
	bgIntro[1].sprite.animation.finishCallback = function(name:String){ bgIntro[1].sprite.alpha = 0; };
	game.remove(dadGroup, true);
	game.insert(game.members.indexOf(bgIntro[bgIntro.length - 1].sprite), dadGroup);

	makeBackground(bgSecond);
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

	makeBackground(bgCarnival);

	// preload chars

	preloadCharacter(1, 'xeno-fe2');
	preloadCharacter(0, 'bf-fe2');

	preloadCharacter(1, 'xeno-fe3');
	preloadCharacter(0, 'bf-fe3');

	preloadCharacter(1, 'xeno-handfe');
	preloadCharacter(0, 'bf-fe4');
	preloadCharacter(0, 'bf-ferunning');
	preloadCharacter(0, 'bf-marionette');
	preloadCharacter(0, 'bf-superfe');
	
	preloadCharacter(1, 'xeno-rightfinale');
	preloadCharacter(0, 'bf-leftfinale');

	preloadCharacter(1, 'xeno-fefinale');
	preloadCharacter(0, 'bf-superfinale');

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

	//and the bf hand section

	bf = new Character(570, 17, 'bf-fegrand', true);
	bf.origin.set();
	bfAtlas = new animate.internal.elements.FlxSpriteElement(bf);
	bfAtlas.active = false;
	bf.visible = false;
}

var renderFinale:FlxSprite;

var shields:FlxSpriteGroup;
final ballList:Array<String> = ['water', 'electric', 'fire', 'rings', 'super'];
var notesPosition:Array<Array<Array<Float>>> = [[[0,0],[0,0],[0,0],[0,0]],[[0,0],[0,0],[0,0],[0,0]]];
final separation:Float = 50;
function onCreatePost()
{

	//shader
	chrom = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment('ChromaticAbberation')));
    chrom.setFloat('amount', 0.3);

	camGame.filters = [new ShaderFilter(game.getLuaObject('sexo').shader), new ShaderFilter(chrom)];

	for (i in 0...4)
	{
		notesPosition[0][i][0] = opponentStrums.members[i].x; notesPosition[1][i][0] = playerStrums.members[i].x;
		notesPosition[0][i][1] = opponentStrums.members[i].y; notesPosition[1][i][1] = playerStrums.members[i].y;
		opponentStrums.members[i].x = -1000;
		playerStrums.members[i].alpha = 0;
		playerStrums.members[i].y += (prefs.downScroll ? 10 : -10);
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width) + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i;
	}
	for (spr in hbvanilla) game.getLuaObject(spr).alpha = 0;
	for (spr in hudSprites) game.getLuaObject(spr).alpha = 0;

	blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
	blackBG.color = 0xFF000000;
	blackBG.scrollFactor.set();
	blackBG.screenCenter();
	game.addBehindDad(blackBG);

	eyes = new FlxSprite().loadGraphic(Paths.image('final/intro/eyes'));
	eyes.scale.set(0.5, 0.5); eyes.updateHitbox();
	game.add(eyes);

	bfYeah = new FlxSprite();
	bfYeah.frames = Paths.getSparrowAtlas('characters/bfyeahfe');
	bfYeah.animation.addByPrefix('yeah', 'yeah', 24, false);
	bfYeah.screenCenter();
	bfYeah.camera = camVideo;
	bfYeah.visible = false;
	game.add(bfYeah);

	jumpscare = new FlxSprite().loadGraphic(Paths.image('slow/simplejump'));
	jumpscare.setGraphicSize(Std.int(FlxG.width * 1.1), Std.int(FlxG.height * 1.1)); jumpscare.updateHitbox();
	jumpscare.screenCenter();
	jumpscare.camera = camHUD;
	jumpscare.alpha = 0.0001;
	game.add(jumpscare);

	drowningBf = new FlxSprite(100, -250);
	drowningBf.frames = Paths.getSparrowAtlas('characters/bfdrowningfe');
	drowningBf.animation.addByPrefix('idle', 'bfdrown', 24, true); drowningBf.animation.play('idle', true);
	drowningBf.alpha = 0;
	game.add(drowningBf);

	bfDrowningPlayable = new Character(2000, 0, 'bf-water', true);
	bfDrowningPlayable.visible = false;
	bfDrowningPlayable.camera = camVideo;
	bfDrowningPlayable.screenCenter(0x10);
	bfDrowningPlayable.y += 60;
	game.add(bfDrowningPlayable);

	laughxeno = new FlxSprite(70, -350);
	laughxeno.frames = Paths.getSparrowAtlas('characters/xenorisaoscuridadaguaxdxdpng');
	laughxeno.animation.addByPrefix('idle', 'laughxddxd', 24, false);
	game.add(laughxeno);
	laughxeno.color = 0x00FFFFFF;
	laughxeno.alpha = 0;

	xenoLaugh = new Character(0, 0, 'xeno-fegrandlaugh');
	xenoLaugh.visible = false;
	game.insert(game.members.indexOf(dadGroup), xenoLaugh);

	superBFAura = new FlxSprite();
	superBFAura.frames = Paths.getSparrowAtlas('characters/bfsuperbg');
	superBFAura.animation.addByPrefix('idle', 'Símbolo 306', 24, true); superBFAura.animation.play('idle', true);
	superBFAura.scale.set(0.65, 0.65); superBFAura.updateHitbox();
	game.insert(game.members.indexOf(boyfriendGroup), superBFAura);
	superBFAura.visible = false;

	shields = new FlxSpriteGroup();
	game.add(shields);
	for (ball in 0...ballList.length - 2)
	{
		var shield:FlxSprite = new FlxSprite(-330, -380);
		shield.frames = Paths.getSparrowAtlas('final/carnival/shields/${ballList[ball]}');
		shield.animation.addByPrefix('idle', 'idle', 24, true);
		shield.animation.play('idle', true);
		shield.alpha = 0.0001;
		shield.scale.set(0.7, 0.7); shield.updateHitbox();
		shields.add(shield);
	}
	
	renderFinale = new FlxSprite().loadGraphic(Paths.image('final/finale'));
	renderFinale.setGraphicSize(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2)); renderFinale.updateHitbox();
	renderFinale.screenCenter();
	renderFinale.camera = camVideo;
	renderFinale.alpha = 0.0001;
	game.add(renderFinale);

	cameraLeft = new FlxCamera();
	cameraLeft.width = FlxG.width / 2;
	cameraLeft.visible = false;

	cameraRight = new FlxCamera();
	cameraRight.x = FlxG.width / 2;
	cameraRight.width = FlxG.width / 2;
	cameraRight.visible = false;

	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.remove(camOther, false);
	FlxG.cameras.add(cameraLeft);
	FlxG.cameras.add(cameraRight);
	FlxG.cameras.add(camHUD, false);
	FlxG.cameras.add(camOther, false);
}

function onSongStart() if (introCutscene?.loadVideo(Paths.video('fake intro'))) introCutscene.playDelayed();
function onGameOverStart()  { 
	camGame.alpha = 1;
	cameraRight.visible = false;
	cameraLeft.visible = false;
	introCutscene?.destroy(); 
	YWGA?.destroy(); 
}

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
				-435 + Math.sin(floatSine * 2) * 2,
				introYPos + Math.cos(floatSine * 2) * 25
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
				-400 + Math.sin(floatSine * 0.75) * 10,
				100 + Math.cos(floatSine * 0.75) * 50
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
			var slide:Bool = Controls.instance.UI_DOWN || Controls.instance.NOTE_DOWN || game.swipeDOWN;
			var jump:Bool = Controls.instance.UI_UP || Controls.instance.NOTE_UP || game.swipeUP;

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

			if (jumpscare != null && jumpscare.alpha > 0.5)
				jumpscare.setPosition(((FlxG.width - jumpscare.width) / 2) + Math.sin(floatSine * 10) * 10, ((FlxG.height - jumpscare.height) / 2) - Math.cos(floatSine * 10) * 3);
		case 'hand':
			if (bf?.visible) bf?.update(elapsed);
			if (xenoLaugh?.visible)
			{
				xenoLaugh?.update();
				if (xenoLaugh.animation.curAnim.curFrame >= 9 && bf.visible) bf.visible = false;
			}
		case 'super':
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
				boyfriend.y = Math.cos(floatSine * 2) * 15;
				bgSecond[9].sprite.y = bgSecond[9].position[1] + Math.cos(floatSine) * 15;
				superBFAura.setPosition(boyfriend.x + 10, boyfriend.y - 10);
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

			for (i in 0...8) strumLineNotes.members[i].y = notesPosition[Std.int(i / 4)][i % 4][1] + Math.sin(floatSine * 1.5 + i) * 10;
		case 'sides':
			cameraLeft.zoom = camGame.zoom + 0.2;
			cameraRight.zoom = camGame.zoom + 0.2;
			for (i in 0...8) strumLineNotes.members[i].y = notesPosition[Std.int(i / 4)][i % 4][1] + Math.sin(floatSine * 1 + i) * 10;
		case 'finale':
			for (i in 0...8) strumLineNotes.members[i].y = notesPosition[Std.int(i / 4)][i % 4][1] + Math.sin(floatSine * 1.5 + i) * 10;
		case 'tvfinal':
			renderFinale.scale.y = FlxMath.lerp(renderFinale.scale.y, 0.0001, elapsed * 10);
	}
}

var xdringbg:FlxSprite;
var fade:FlxSprite;
var _fbc:Bool = 0;
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
				introCutscene?.destroy();
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
				eyes?.destroy();
			case 'fadeNotes':
				for (i in 0...4) FlxTween.tween(playerStrums.members[i], {alpha: 1, y: (playerStrums.members[i].y + (prefs.downScroll ? -10 : 10))}, Conductor.crochet / 250, {ease: FlxEase.cubeInOut, startDelay: i / 4});
			case 'yeahbf':
				dad.alpha = 0;
				bfYeah.visible = true;
				bfYeah.animation.play('yeah', true);
				bgIntro[5].sprite.visible = false;
				bgIntro[6].sprite.visible = false;
				bgIntro[7].sprite.visible = false;
				bgIntro[bgIntro.length - 1].sprite.visible = false;
				FlxG.camera.snapToTarget();
				FlxG.camera.zoom = 2;
				game.cameraSpeed = 9999;
				game.camZoomingDecay = 0;
			case 'secondsection':
				FlxTween.cancelTweensOf(camGame);
				game.cameraSpeed = 1;
				game.camZoomingDecay = 1;
				dad.alpha = 1;
				floatIntensity = 3;
				bfYeah?.destroy();
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				for (spr in bgIntro) spr.sprite.visible = false; bgIntro[1].sprite.visible = true;
				for (spr in bgSecond) spr.sprite.visible = true;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgSecond[4].sprite), bgIntro[1].sprite);
				bgIntro[1].sprite.y -= 400;
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 1;
				for (i in 0...4)
				{
					opponentStrums.members[i].x = notesPosition[0][i][0];
					playerStrums.members[i].x = notesPosition[1][i][0];
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
				for (spr in bgThird) spr.sprite?.destroy();
				bgIntro[1].sprite.y -= 400;
				xenoRing.visible = true;
				curBG = 'second';
				cam.BFx = 250;
				cam.BFy = 120;
				cam.DADy = 0;
				bfLegs2.visible = true;
				bfLegs2back.visible = true;
				bfLegs3?.destroy();
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
				bfLegs2?.destroy(); bfLegs2back?.destroy();
				bfLegs4.visible = true;
				xenoRing.visible = false;
				curBG = 'fourth';
				cam.DADx = 0;
				cam.DADy = 0;
				cam.BFx = 250;
				cam.BFy = 200;
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
				prefs.ghostTapping = true;
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				FlxTween.cancelTweensOf(blackBG);
				blackBG.alpha = 0;
				changeCharacter('bf', 'bf-ferunning');
				boyfriend.playAnim('intro', true); boyfriend.specialAnim = true;
				boyfriend.animation.finishCallback = function(name:String){if (name != 'run' && curBG == 'fifth'){boyfriend.playAnim('run', true); boyfriend.specialAnim = true; bfAction = '';}};
				boyfriend.y += 50;
				dad.alpha = 0;
				bfLegs4?.destroy();
				fourthFloor?.destroy();
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
				if (Conductor.songPosition >= 133923.077) return;
				var obstacle:FlxSprite = new FlxSprite(1100, v2 == 'bot' ? 350 : 50);
				obstacle.frames = Paths.getSparrowAtlas('final/obstaclesfinal');
				final obs:Int = FlxG.random.int(1,7);
				obstacle.animation.addByPrefix(Std.string(obs), Std.string(obs), 0, false);
				obstacle.animation.play(Std.string(obs));
				obstacle.angle = FlxG.random.float(-360, 360);
				obstacle.angularVelocity = FlxG.random.float(-50, 50);
				obstacle.scale.set(1.3, 1.3); obstacle.updateHitbox();
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
					if (tmr.loopsLeft == 2)
					{
						FlxTween.cancelTweensOf(warning); FlxTween.cancelTweensOf(warning.scale);
						warning?.destroy();
						//reaction time
						new FlxTimer().start(0.1, function(_)
						{
							if (v2 == 'bot' && bfAction != 'jump' && !game.cpuControlled)
							{
								FlxG.camera.shake(0.01, 0.1);
								camHUD.shake(0.005, 0.1);
								game.health -= 0.3;
								obstacle?.destroy();
								FlxG.sound.play(Paths.sound('hit'));
								bfAction = 'hit';
								boyfriend.playAnim('hit', true); boyfriend.specialAnim = true;
							}
							else if (v2 == 'top' && bfAction != 'slide' && !game.cpuControlled)
							{
								FlxG.camera.shake(0.01, 0.1);
								camHUD.shake(0.005, 0.1);
								game.health -= 0.3;
								obstacle?.destroy();
								FlxG.sound.play(Paths.sound('hit'));
								bfAction = 'hit';
								boyfriend.playAnim('hit', true); boyfriend.specialAnim = true;
							}
						});
					}
					else if (tmr.loopsLeft > 2)
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
					else if (tmr.loopsLeft == 0) obstacle?.destroy();
				}, 4);
			case 'jumpscarelol':
				jumpscare.alpha = 1;
				new FlxTimer().start(Conductor.crochet / 500, _ -> {
					jumpscare?.destroy();
				});
			case 'wontgetaway':
				if (curBeat <= 404 && YWGA?.loadVideo(Paths.video('you know'))) YWGA.playDelayed();
			case 'wontgetaway2':
				if (curBeat <= 409) YWGA?.destroy();
				boyfriend.visible = true;
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				camHUD.visible = true;
				fifthFloor.visible = true;
			case 'waterxd':
				prefs.ghostTapping = oldGT;
				if (Conductor.songPosition >= 133923.077) return;
				new FlxTimer().start(Conductor.crochet / 500, function(_)
				{
					var fadewhite:FlxSprite = new FlxSprite(-1000, 800).loadGraphic(Paths.image('final/transition'));
					fadewhite.scale.x = 10000; fadewhite.updateHitbox();
					game.insert(game.members.indexOf(boyfriendGroup) + 50, fadewhite);

					var water:FlxSprite = new FlxSprite(-1000, 2200).makeGraphic(3000, 1600, 0xFFFF0000);
					game.insert(game.members.indexOf(boyfriendGroup) + 53, water);

					var bfFalling:FlxSprite = new FlxSprite(250, -1000).loadGraphic(Paths.image('characters/bffallingfe'));
					bfFalling.scale.set(0.6, 0.6); bfFalling.updateHitbox();
					bfFalling.angle = -120;
					bfFalling.angularVelocity = 100;
					bfFalling.velocity.y = 2500;
					bfFalling.color = 0xFF000000;
					game.insert(game.members.indexOf(boyfriendGroup) + 56, bfFalling);
					FlxTween.tween(fifthFloor, {x: fifthFloor.x + 200}, 1, {ease: FlxEase.cubeInOut});

					FlxTween.tween(camHUD, {y: -770}, 1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(camGame, {zoom: 0.5}, 3, {ease: FlxEase.cubeOut});
					FlxTween.tween(camGame.targetOffset, {y: 2000}, 1, {ease: FlxEase.cubeInOut});
					new FlxTimer().start(Conductor.crochet / 250, function(_)
					{
						bfFalling.color = 0xFF00FFFF;
						bfFalling.velocity.y = 100;
						bfFalling.acceleration.y = 1000;
						FlxTween.cancelTweensOf(fifthFloor); fifthFloor?.destroy();
						boyfriend.alpha = 0;
						FlxTween.tween(water, {y: water.y - 600}, 1.5, {ease: FlxEase.sineOut});
						for (spr in bgSecond) spr.sprite.visible = false;
					});
					new FlxTimer().start(Conductor.crochet / 100, function(_)
					{
						FlxTween.cancelTweensOf(camHUD); FlxTween.cancelTweensOf(camGame);
						camGame.targetOffset.y = 0; game.cameraSpeed = 9999;
						camHUD.y = camHUD.alpha = 0;
						fadewhite?.destroy();
						bfFalling?.destroy();
						water.y -= 2000;
						FlxTween.tween(water, {alpha: 0}, 3, {ease: FlxEase.cubeInOut, onComplete: function(_) { water?.destroy(); }});
					});
				});
			case 'fadewaterxd':
				curBG = 'water';
				game.cameraSpeed = 1;
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 0;
				FlxTween.tween(camHUD, {alpha: 1}, 2.2);
				FlxTween.tween(drowningBf, {alpha: 1}, 3);
				for (i in 0...4)
				{
					opponentStrums.members[i].x = -1000;
					playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width) + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i;
					playerStrums.members[i].alpha = 0;
					playerStrums.members[i].y += (prefs.downScroll ? 30 : -30);
					FlxTween.tween(playerStrums.members[i], {alpha: 1, y: (playerStrums.members[i].y + (prefs.downScroll ? -30 : 30))}, Conductor.crochet / 250, {ease: FlxEase.cubeOut, startDelay: i / 4});
				}

				//just in case
				for (spr in bgSecond) spr.sprite.visible = false;
				boyfriend.alpha = 0;
				FlxTween.cancelTweensOf(fifthFloor); fifthFloor?.destroy();
				camGame.targetOffset.y = 0;
				cam.MiddleX = 0; cam.MiddleY = 0;
			case 'showbflol':
				bfDrowningPlayable.visible = true;
				FlxTween.tween(bfDrowningPlayable, {x: 600}, 2, {ease: FlxEase.cubeOut});
			case 'flackback':
				_fbc++;
				var fbs:FlxSprite = new FlxSprite(-50).loadGraphic(Paths.image('final/flashbacks/$_fbc'));
				fbs.camera = camVideo;
				fbs.scale.set(0.6, 0.6); fbs.updateHitbox();
				fbs.screenCenter(0x10);
				fbs.alpha = 0;
				game.add(fbs);
				FlxTween.tween(fbs, {x: 0, alpha: 0.7}, 1, {ease: FlxEase.cubeOut, onComplete: function(_) { FlxTween.tween(fbs, {alpha: 0, y: fbs.y - 50}, 1, {ease: FlxEase.cubeIn}); }});
			case 'endwatersection':
				FlxTween.cancelTweensOf(bfDrowningPlayable);
				FlxTween.tween(bfDrowningPlayable, {x: 2000}, 6, {ease: FlxEase.cubeIn});
				FlxTween.color(drowningBf, Conductor.crochet / (1000 / 17), 0xFFFFFFFF, 0xFFFF7777, {ease: FlxEase.sineIn});
				FlxTween.color(bfDrowningPlayable, Conductor.crochet / (1000 / 17), 0xFFFFFFFF, 0xFFFF7777, {ease: FlxEase.sineIn});
			case 'evillaugh':
				laughxeno.alpha = 1;
				laughxeno.animation.play('idle', true);
				FlxTween.color(laughxeno, Conductor.crochet / 100, 0x00FFFFFF, 0xFFFF7777, {ease: FlxEase.sineIn});
			case 'grandxenopart':
				for (spr in hbvanilla) game.getLuaObject(spr).alpha = 1;
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 1;
				FlxTween.cancelTweensOf(laughxeno); FlxTween.cancelTweensOf(bfDrowningPlayable); FlxTween.cancelTweensOf(drowningBf); bfDrowningPlayable.visible = false;
				laughxeno?.destroy(); bfDrowningPlayable?.destroy(); drowningBf?.destroy();
				boyfriend.alpha = 1;
				dad.alpha = 1;

				for (spr in bgIntro) {
					spr.sprite.visible = true;
					spr.sprite.scale.x *= 2; spr.sprite.scale.y *= 2;
					spr.sprite.updateHitbox();
					spr.sprite.x -= 900; spr.sprite.y -= 200;
				}
				bgIntro[5].sprite.visible = false; bgIntro[6].sprite.visible = false; bgIntro[7].sprite.visible = false; bgIntro[9].sprite.visible = false;

				fade = new FlxSprite(-1300, 0).loadGraphic(Paths.image('final/fade'));
				fade.scale.set(2500, 1); fade.updateHitbox();
				game.add(fade);

				curBG = 'hand';
				changeCharacter('dad', 'xeno-fegrand');
				dad.x -= 100;
				dad.danceEveryNumBeats = 9999; // xd

				changeCharacter('bf', 'bf-marionette');
				boyfriend.setPosition(-340, -900);

				boyfriend.alpha = 0;
				bf.visible = true;

				cam.MiddleZoom = 0.72;

				dad.library.getSymbol("Símbolo 10").timeline.layers[0].forEachFrame((frame) -> {
					for (i in frame.elements) i.visible = false;  
					frame.add(bfAtlas);
				});
			case 'laughxenotwo':
				xenoLaugh.setPosition(dad.x, dad.y);
				xenoLaugh.visible = true;
				xenoLaugh.playAnim('risa', true);

				dad.library.getSymbol("Carpeta de elementos duplicados/xeno").timeline.layers[0].forEachFrame((frame) -> { for (i in frame.elements) i.visible = false; });
				xenoLaugh?.library?.getSymbol("11 Xeno Laught/Carpeta de elementos duplicados Xeno Laughts/mano").timeline?.layers[0]?.forEachFrame((frame) -> { for (i in frame?.elements) i?.visible = false; });
			case 'marionette':
				fade?.destroy();
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				curBG = 'marionette';
				xenoLaugh?.destroy();
				bf.visible = false;
				boyfriend.alpha = 1;

				for (spr in bgIntro) spr.sprite.visible = false;
				for (spr in bgCarnival) spr.sprite.visible = true;
			case 'aaacinematica':
				FlxTween.cancelTweensOf(blackBG);
				FlxTween.tween(blackBG, {alpha: 0}, Conductor.crochet / 250, {ease: FlxEase.expoIn});
				curBG = 'nulo jajaja para q no pase nada aca';
				FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / 250);
			case 'superbf':
				chrom.setFloat('amount', 0.4);
				for (s in 0...ballList.length - 2) FlxTween.cancelTweensOf(shields.members[s]);
				shields?.destroy();
				for (spr in hbvanilla) game.getLuaObject(spr).alpha = 0;
				game.videoCutscene?.destroy();
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				curBG = 'super';
				FlxTween.cancelTweensOf(camHUD);
				camHUD.alpha = 1;
				for (spr in bgCarnival) spr.sprite?.destroy();
				changeCharacter('dad', 'xeno-fe2');
				changeCharacter('bf', 'bf-superfe');
				boyfriend.x += 300;
				for (spr in bgSecond) spr.sprite.visible = true;
				bgIntro[1].sprite.visible = true;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgSecond[4].sprite), bgIntro[1].sprite);
				xenoRing.visible = true;
				cam.BFx = 250;
				cam.BFy = 120;
				cam.DADx = 0;
				cam.DADy = 0;
				cam.MiddleX = 100;
				cam.MiddleY = 0;
				cam.MiddleZoom = 0.58;

				bgIntro[1].sprite.x += 400;
				bgSecond[0].sprite.velocity.x = -1000;
				bgSecond[1].sprite.velocity.x = -200;
				bgSecond[2].sprite.velocity.x = -400;
				bgSecond[4].sprite.velocity.x = -2000;
				bgSecond[5].sprite.velocity.x = -2500;
				floatIntensity = 4;

				for (spr in hudSprites) game.getLuaObject(spr).alpha = 1;
				for (i in 0...4)
				{
					opponentStrums.members[i].x = notesPosition[0][i][0];
					playerStrums.members[i].x = notesPosition[1][i][0];
				}
			case 'sides':
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				for (spr in bgSecond) spr.sprite.visible = false;
				for (spr in bgIntro) spr.sprite.visible = true;
				bgIntro[5].sprite.visible = false; bgIntro[6].sprite.visible = false; bgIntro[7].sprite.visible = false; bgIntro[9].sprite.visible = false;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgIntro[0].sprite) + 1, bgIntro[1].sprite);
				curBG = 'sides';

				xdringbg = new FlxSprite(6400, -500).loadGraphic(Paths.image('final/ringfinalescape'));
				xdringbg.scale.set(2,2); xdringbg.updateHitbox();
				game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), xdringbg);

				changeCharacter('dad', 'xeno-rightfinale');
				changeCharacter('bf', 'bf-leftfinale');
				dad.setPosition(7550, -100);
				boyfriend.setPosition(170, -60);
				cameraLeft.filters = camGame.filters;
				cameraRight.filters = camGame.filters;
				cameraLeft.visible = true;
				cameraRight.visible = true;
				cameraRight.scroll.x = 8000;
				superBFAura.visible = true; superBFAura.scale.set(3, 3); superBFAura.updateHitbox(); superBFAura.x += -400; superBFAura.y = -400;
				xenoRing.visible = false;
			case 'normal':
				chrom.setFloat('amount', 0.5);
				xdringbg?.destroy();
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				for (spr in bgIntro) if (spr.sprite != bgIntro[1].sprite) spr.sprite?.destroy();
				for (spr in bgSecond) spr.sprite.visible = true;
				bgIntro[1].sprite.visible = true;
				game.remove(bgIntro[1].sprite, true); game.insert(game.members.indexOf(bgSecond[4].sprite), bgIntro[1].sprite);
				curBG = 'super';
				superBFAura.visible = false; superBFAura.scale.set(0.65, 0.65); superBFAura.updateHitbox();
				xenoRing.visible = true;
				changeCharacter('dad', 'xeno-fe2');
				changeCharacter('bf', 'bf-superfe');
				FlxG.cameras.remove(cameraLeft, true);
				FlxG.cameras.remove(cameraRight, true);

				bgSecond[0].sprite.velocity.x = -2500;
				bgSecond[1].sprite.velocity.x = -600;
				bgSecond[2].sprite.velocity.x = -1200;
				bgSecond[4].sprite.velocity.x = -3000;
				bgSecond[5].sprite.velocity.x = -4500;
				floatIntensity = 6;
			case 'finale':
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);
				xenoRing?.destroy();
				curBG = 'finale';
				cam.MiddleZoom = 0.8;
				changeCharacter('dad', 'xeno-fefinale');
				changeCharacter('bf', 'bf-superfinale');
				dad.setPosition(-800, -250);
				boyfriend.setPosition(300, -500);
				superBFAura.scale.set(2, 2); superBFAura.updateHitbox();
				superBFAura.setPosition(boyfriend.x - 50, boyfriend.y - 250);

				bgSecond[6].sprite?.destroy();
				bgSecond[7].sprite?.destroy();
				bgSecond[8].sprite?.destroy();
				bgSecond[9].sprite?.destroy();
			case 'ending':
				renderFinale.alpha = 1;
				FlxTween.tween(renderFinale.scale, {x: renderFinale.scale.x / 1.2, y: renderFinale.scale.y / 1.2}, Conductor.crochet / (1000 / 12), {ease: FlxEase.cubeOut});
				camHUD.flash(0xFFFFFFFF, Conductor.crochet / (1000 / 8), null, true);
				boyfriend.visible = false;
				dad.visible = false;
				superBFAura?.destroy();
				bgIntro[1].sprite.destroy();
				for (spr in bgSecond) spr.sprite?.destroy();
				curBG = 'ending';
				for (i in 0...8) strumLineNotes.members[i].y = notesPosition[Std.int(i / 4)][i % 4][1];
				for (spr in hbvanilla) game.getLuaObject(spr).alpha = 0;
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 0;
				FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / (1000 / 8));
			case 'tvoff':
				FlxTween.cancelTweensOf(renderFinale.scale);
				renderFinale.setColorTransform(0, 0, 0, 1, 255, 255, 255, 0);
				curBG = 'tvfinal';
		}
	}
	if (n == 'ScreenBorders' && _bruh)
	{
		FlxTween.cancelTweensOf(lua('topbar'));
		FlxTween.tween(lua('topbar'), {y: -lua('topbar').height}, 1, {ease: FlxEase.cubeOut});
	}
}

function onDestroy() prefs.ghostTapping = oldGT;

function opponentNoteHit(note)
{
	if (curBG == 'intro')
	{
		FlxG.camera.shake(0.0015, 0.1);
		camHUD.shake(0.001, 0.1);
	}
	else if ((curBG == 'super' || curBG == 'sides' || curBG == 'finale') && floatIntensity == 6)
	{
		FlxG.camera.shake(0.0075, 0.1);
		camHUD.shake(0.004, 0.1);
	}
	else
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

	if (bfDrowningPlayable != null && bfDrowningPlayable.visible)
	{
		bfDrowningPlayable.playAnim(game.singAnimations[note.noteData], true);
		bfDrowningPlayable.holdTimer = 0;
	}

	//xd
	if (bf.visible && curBG == 'hand')
	{
		if (note.noAnimation || note.hitCausesMiss) return;
		bf.playAnim(singAnimations[note.noteData], true);
		bf.holdTimer = 0;
	}
}

function noteMiss(note)
{
	if (curBG == 'second' && bfLegs2 != null && bfLegs2back != null) bfLegs2.playAnim(game.singAnimations[note.noteData] + 'miss', true);
	if (curBG == 'third' && bfLegs3 != null) bfLegs3.playAnim(game.singAnimations[note.noteData] + 'miss', true);
	if (curBG == 'fourth' && bfLegs4 != null) bfLegs4.playAnim(game.singAnimations[note.noteData] + 'miss', true);
}

var _angulo:Bool = false;
function onBeatHit()
{
	if (curBG == 'hand')
	{
		if (bf != null && curBeat % 3 == 2 && !bf.stunned && !bf.getAnimationName().startsWith('sing')) bf.dance();
		if (dad != null && curBeat % 3 == 2 && !dad.stunned && !dad.getAnimationName().startsWith('sing')) dad.dance();
	}
	if (curBG == 'marionette' && curBeat % 3 == 2)
	{
		var _soundVolume:Float = 0.4;
		var daBall:String = ballList[FlxG.random.int(0, ballList.length - 2)];
		if (curBeat >= 640)
		{
			_soundVolume = 0.75;
			daBall = 'super';
		}

		var ball:FlxSprite = new FlxSprite();
		ball.frames = Paths.getSparrowAtlas('final/carnival/balls/$daBall');
		ball.animation.addByPrefix('idle', 'idle', 8, true);
		ball.animation.play('idle', true);
		switch (FlxG.random.int(0, 3)) //xd
		{
			case 0:
				ball.x = -1100;
				ball.y = FlxG.random.float(-720, 550);

			case 1:
				ball.x = 900;
				ball.y = FlxG.random.float(-720, 550);

			case 2:
				ball.x = FlxG.random.float(-1100, 900);
				ball.y = -720;

			case 3:
				ball.x = FlxG.random.float(-1100, 900);
				ball.y = 550;
		}
		var dx:Float = -100 - ball.x; var dy:Float = -85 - ball.y;
		ball.velocity.set(dx * 1000 / (Conductor.crochet * 1.5), dy * 1000 / (Conductor.crochet * 1.5));
		game.insert(game.members.indexOf(boyfriendGroup) + 1, ball);
		new FlxTimer().start(Conductor.crochet / 750, function(_)
		{
			for (b in 0...ballList.length - 2)
			{
				if (daBall == ballList[b])
				{
					for (i in 0...ballList.length - 2) shields.members[i].alpha = 0.0001;
					final shield:FlxSprite = shields.members[b];
					FlxTween.cancelTweensOf(shield.scale);
					shield.scale.set(0.1, 1);
					FlxTween.tween(shield.scale, {x: 0.7, y: 0.7}, Conductor.crochet / (1000 / 3), {ease: FlxEase.backOut});
					shield.alpha = 1;
				}
			}
			if (curBeat >= 640)
			{
				blackBG.camera = camVideo;
				camHUD.flash(0xFFFFFF00, Conductor.crochet / 250, null, true);
				blackBG.color = 0xFFFFFFFF;
				blackBG.alpha = 1;
			}

			FlxG.sound.play(Paths.sound('balls/$daBall'), _soundVolume);
			FlxG.camera.shake(0.015, 0.15);
			camHUD.shake(0.0075, 0.15);
			ball.destroy();
			camGame.angle = _angulo ? 3 : -3;
			FlxTween.cancelTweensOf(camGame);
			FlxTween.tween(camGame, {angle: 0}, Conductor.crochet / 750, {ease: FlxEase.cubeIn});
			_angulo = !_angulo;
		});
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);