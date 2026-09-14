import flixel.addons.display.FlxBackdrop;
import psychlua.FunkinLua;
import openfl.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;

import objects.Character;

var skyCamera:FlxCamera;
var stargazers:Array<FlxSprite>;

var bfClone :Character;
var guyClone:Character;

var sky      :FlxBackdrop;
var floor    :FlxSprite;
var spotlight:FlxSprite;

var charPositions:Array<Array<Float>> = [];
var healthStuff:Array<String> = ["hbBG", "hbHealth", "hbHealth2", "separatorHealth", "iconBF", "iconOpp", "healthBG"];

var whiteGraphic:FlxSprite;
function onCreate()
{
	setupCameras();

	stargazers = [];

	sky = new FlxBackdrop(Paths.image('bg/sky'), 0x01);
	sky.scale.set(1.3, 1.3);
	sky.updateHitbox();
	sky.y = -300;
	sky.velocity.x = 30;
	sky.camera = skyCamera;
	add(sky);

	floor = new FlxSprite(-700, -600).loadGraphic(Paths.image('bg/floorst'));
	floor.scale.set(1.5, 1.5);
	floor.updateHitbox();
	addBehindDad(floor);

	spotlight = new FlxSprite(-300, -450).loadGraphic(Paths.image('bg/spotlight'));
	spotlight.scale.y = 1.3;
	spotlight.updateHitbox();
	spotlight.alpha = 0.5;
	spotlight.blend = BlendMode.ADD;
	spotlight.camera = camGame;
	add(spotlight);

	skyCamera.visible = false;

	bfClone = new Character(600, 120, boyfriend.curCharacter, true);
	bfClone.camera = camHUD; //Fixes this shit being on the skyCamera
	bfClone.scale.set(1.2, 1.2);
	bfClone.alpha = 0;
	add(bfClone);
	
	guyClone = new Character(-200, 200, dad.curCharacter);
	guyClone.camera = camHUD;
	guyClone.scale.set(1.2, 1.2);
	guyClone.alpha = 0;
	add(guyClone);

	charPositions = [[boyfriend.x, boyfriend.y], [dad.x, dad.y]];

	whiteGraphic = new FlxSprite(-800, -2200);
	whiteGraphic.makeGraphic(FlxG.width * 4, FlxG.height * 6, FlxColor.WHITE);
	whiteGraphic.alpha = 0;
	insert(dadGroup.members.length, whiteGraphic);
}

function onSongStart()  makeStar();
function onSectionHit() makeStar();

var starID  :Int  =    0;
var redStar :Bool = false;
var blueStar:Bool = false;
function makeStar()
{
	starID++;
	var star:FlxSprite = new FlxSprite(-800,0).loadGraphic(Paths.image('bg/star'));
	star.camera = skyCamera;
	star.y = FlxG.random.int(-200,300);
	if (redStar)       star.velocity.x = FlxG.random.int(600, 1400);
	else if (blueStar) star.velocity.x = FlxG.random.int(1500, 2000);
	else               star.velocity.x = FlxG.random.int(200, 1000);
	star.velocity.y = FlxG.random.int(5,200);
	star.ID = starID;
	star.angle = Math.atan2(star.velocity.y, star.velocity.x) * 180 / Math.PI;
	stargazers.push(star);
	if (redStar)  star.color = 0x830000;
	if (blueStar) star.color = 0x000285;
	add(star);
}

var areFloating:Bool = false;
var areFloatingIntense:Bool = false;
var areFloatingHUD:Bool = false;
var holdMove:Float = 0;
function onUpdatePost(e:Float)
{
	holdMove = holdMove + e;
	for (star in stargazers)
	{
		if (star.x > 1200)
		{
			remove(star, true);
			star.destroy();
			stargazers.remove(star);
			break;
		}
	}

	if (bfClone.exists){
		bfClone.animation.play(boyfriend.animation.curAnim.name, true);
		bfClone.animation.curAnim.curFrame = boyfriend.animation.curAnim.curFrame;
	}

	if (guyClone.exists){
		guyClone.animation.play(dad.animation.curAnim.name, true);
		guyClone.animation.curAnim.curFrame = dad.animation.curAnim.curFrame;
	}

	if (areFloating)
	{
		boyfriend.setPosition(
			boyfriend.x + Math.cos(holdMove + 1.9) * 1.6,
			boyfriend.y + Math.sin(holdMove + 2.8) * 0.8
		);
		dad.setPosition(
			dad.x + Math.cos(holdMove + 1.9) * 1.2,
			dad.y + Math.sin(holdMove + 2.8) * 0.8
		);

		if (areFloatingHUD)
		{
			camHUD.setPosition(
				camHUD.x + Math.cos(holdMove + 0.2) * 0.3,
				camHUD.y + Math.sin(holdMove + 0.8) * 0.3
				);
			camHUD.angle = camHUD.angle + Math.cos(holdMove + 0.1) * 0.05;
		}
	}

	if (areFloatingIntense)
	{
		boyfriend.setPosition(
			boyfriend.x + Math.cos(holdMove + 3.9) * 1.8,
			boyfriend.y + Math.sin(holdMove + 4.8) * 1.2
		);
		dad.setPosition(
			dad.x + Math.cos(holdMove + 3.9) * 1.8,
			dad.y + Math.sin(holdMove + 4.8) * 1.2
		);

	}
}

function onCreatePost()
{
	if (ClientPrefs.data.shaders) {
		var fishEye = new ErrorHandledRuntimeShader('fisheye', File.getContent('contents/SONICJAM/shaders/fisheye.frag'));
		fishEye.setFloat('amount', -0.75);
		skyCamera.filters = [new ShaderFilter(fishEye), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader), new ShaderFilter(game.getLuaObject('pixel').shader)];
		camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader), new ShaderFilter(game.getLuaObject('pixel').shader)];
		camHUD.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader), new ShaderFilter(game.getLuaObject('pixel').shader)];
	}
}

function setupCameras()
{
	skyCamera = new FlxCamera();
	skyCamera.zoom = 0.5;

	FlxG.cameras.remove(camGame, false);
	FlxG.cameras.remove(camVideo, false);
	FlxG.cameras.remove(camHUD, false);
	FlxG.cameras.remove(camOther, false);
	FlxG.cameras.add(skyCamera);
	FlxG.cameras.add(camGame);
	FlxG.cameras.add(camVideo, false);
	FlxG.cameras.add(camHUD, false);
	FlxG.cameras.add(camOther, false);
	camGame.bgColor = 0x0; 
}

function onEvent(e, v1, v2)
{
	var split1 = v1.split(', ');
	var split2 = v2.split(', ');
	if (e == 'substantialEvent'){
		if (v1 == 'showSky')
			skyCamera.visible = true;

		if (v1 == 'fadeBG')
		{
			if (v2 == 'true')
				FlxTween.tween(game.getLuaObject("BlackGraphicBehind"), {alpha: 0.6}, 0.8);
			else
				FlxTween.tween(game.getLuaObject("BlackGraphicBehind"), {alpha: 0}, 0.4);
		}
		if (v1 == 'fadeSky')
		{
			if (v2 == 'true')
				FlxTween.tween(skyCamera, {alpha: 0}, 1.1);
			else
				FlxTween.tween(skyCamera, {alpha: 1}, 0.4);
		}
		if (v1 == 'showClones')
		{
			FlxTween.tween(bfClone,  {alpha: 0.5, x: bfClone.x  - 120}, 3, {ease: FlxEase.cubeOut});
			FlxTween.tween(guyClone, {alpha: 0.5, x: guyClone.x + 120}, 3, {ease: FlxEase.cubeOut});
		}else if (v1 == 'fadeClones') {
			FlxTween.tween(bfClone,  {alpha: 0, x: bfClone.x  + 180}, 1.2, {ease: FlxEase.cubeIn});
			FlxTween.tween(guyClone, {alpha: 0, x: guyClone.x - 180}, 1.2, {ease: FlxEase.cubeIn});
		}else if (v1 == 'removeClones') for (clones in [bfClone, guyClone]) clones.destroy();
		if (v1 == 'floatMode')
		{
			if (v2 == 'start')
			{
				for (health in healthStuff) FlxTween.tween(game.getLuaObject(health), {alpha: 0}, 1);
				FlxTween.num(1, 0.8, 1, {ease:FlxEase.circIn}, (val:Float) -> defaultCamHUD = val);
				FlxTween.tween(floor, {y: floor.y + 1250}, 1, {ease: FlxEase.circIn, onComplete: () -> {areFloating = true; areFloatingHUD = true;}});
				FlxTween.tween(boyfriend, {x: boyfriend.x + 150}, 1, {ease: FlxEase.circIn});
				FlxTween.tween(dad, {x: dad.x - 150}, 1, {ease: FlxEase.circIn});

				boyfriend.angularVelocity = Math.random(45,   85);
				dad.angularVelocity       = Math.random(-85, -45);
			}
			if (v2 == 'end'){
				FlxTween.tween(floor, {y: floor.y - 1250}, 3, {ease: FlxEase.circOut, onStart: () -> {areFloating = false; areFloatingHUD = false;}});
				
				FlxTween.tween(boyfriend, {x: charPositions[0][0], y: charPositions[0][1], angle: 0}, 3, {ease: FlxEase.circOut});
				FlxTween.tween(dad,       {x: charPositions[1][0], y: charPositions[1][1], angle: 0}, 3, {ease: FlxEase.circOut});

				boyfriend.angularVelocity = 0;
				dad.angularVelocity       = 0;
				
				FlxTween.tween(camHUD, {angle: 0, y: 0}, 3, {ease: FlxEase.circOut});
				for (health in healthStuff) FlxTween.tween(game.getLuaObject(health), {alpha: 1}, 1);
				game.defaultCamHUD = 1;
			}
		}

		if (v1 == "deactivateHUDFloating")
			areFloatingHUD = false;
		
		if (v1 == 'redSkyColor')
		{
			FlxG.camera.flash(0xB60101, 1);
			sky.color = 0xF10606;
			spotlight.color = 0xF10606;
			for (stars in stargazers) stars.color = 0x830000;
			redStar = true;
			sky.velocity.x = 280;
		}
		if (v1 == "blueSkyColor")
		{
			FlxG.camera.flash(0x0401B6, 1);
			sky.color = 0x1600D8;
			spotlight.color = 0x1600D8;
			for (stars in stargazers) stars.color = 0x000285;
			blueStar = true;
			sky.velocity.x = 760;
			areFloating = false;
			areFloatingIntense =  true;
		}
		if (v1 == 'badAppleTime')
		{
			skyCamera.visible  = false;
			whiteGraphic.alpha =     1;
			for (chars in [boyfriend, dad]) chars.color = FlxColor.BLACK;

			areFloatingIntense = false;
			areFloatingHUD = false;
			areFloating = false;

			FlxTween.tween(camHUD, {angle: 0, x: 0, y: 0}, 3, {ease: FlxEase.circOut});
			FlxTween.tween(boyfriend, {x: charPositions[0][0], y: charPositions[0][1], angle: 0}, 8, {ease: FlxEase.circOut});
			FlxTween.tween(dad,       {x: charPositions[1][0], y: charPositions[1][1], angle: 0}, 8, {ease: FlxEase.circOut});
		}
		if (v1 == 'fadeEverything'){
			for (chars in [boyfriend, dad]) FlxTween.tween(chars, {alpha: 0}, 3, {startDelay: 1});
		    FlxTween.tween(camHUD, {alpha: 0}, 2.2, {startDelay: 3.5});
		    FlxTween.tween(game.getLuaObject("BlackGraphicOther"), {alpha: 1}, 2, {startDelay: 5});
		}
	}
}