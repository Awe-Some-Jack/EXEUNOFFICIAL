import flixel.addons.display.FlxBackdrop;
import psychlua.FunkinLua;
import openfl.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;

var skyCamera:FlxCamera;
var stargazers:Array<FlxSprite>;
function onCreate()
{
	setupCameras();

	stargazers = [];

	var sky:FlxBackdrop = new FlxBackdrop(Paths.image('bg/sky'), 0x01);
	sky.scale.set(1.3, 1.3);
	sky.updateHitbox();
	sky.y = -300;
	sky.velocity.x = 30;
	sky.camera = skyCamera;
	add(sky);

	var floor:FlxSprite = new FlxSprite(-700, -600).loadGraphic(Paths.image('bg/floorst'));
	floor.scale.set(1.5, 1.5);
	floor.updateHitbox();
	addBehindDad(floor);

	var spotlight:FlxSprite = new FlxSprite(-300, -450).loadGraphic(Paths.image('bg/spotlight'));
	spotlight.scale.y = 1.3;
	spotlight.updateHitbox();
	spotlight.alpha = 0.5;
	spotlight.blend = BlendMode.ADD;
	spotlight.camera = camGame;
	add(spotlight);

	skyCamera.visible = false;
}

function onSongStart()  makeStar();
function onSectionHit() makeStar();

var starID:Int = 0;
function makeStar()
{
	starID++;
	var star:FlxSprite = new FlxSprite(-800,0).loadGraphic(Paths.image('bg/star'));
	star.camera = skyCamera;
	star.y = FlxG.random.int(-200,300);
	star.velocity.x = FlxG.random.int(200,1000);
	star.velocity.y = FlxG.random.int(5,200);
	star.ID = starID;
	star.angle = Math.atan2(star.velocity.y, star.velocity.x) * 180 / Math.PI;
	stargazers.push(star);
	add(star);
}

function onUpdatePost(e:Float)
{
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
				FlxTween.tween(skyCamera, {alpha: 0.6}, 2);
			else
				FlxTween.tween(skyCamera, {alpha: 0}, 0.4);
		}

	}
}