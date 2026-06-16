import flixel.addons.display.FlxBackdrop;
import psychlua.FunkinLua;

var skyCamera:FlxCamera;
function onCreate()
{
	setupCameras();

	var sky:FlxBackdrop = new FlxBackdrop(Paths.image('bg/sky'), 0x01);
	sky.scale.set(1.5, 1.5);
	sky.updateHitbox();
	sky.setPosition(-700, -500);
	sky.velocity.x = 30;
	sky.camera = skyCamera;
	add(sky);

	var floor:FlxSprite = new FlxSprite(-700, -600).loadGraphic(Paths.image('bg/floorst'));
	floor.scale.set(1.5, 1.5);
	floor.updateHitbox();
	addBehindDad(floor);
}

function onCreatePost()
{
	if (ClientPrefs.data.shaders) {
		var fishEye = new ErrorHandledRuntimeShader('fisheye', File.getContent('mods/SONICJAM/shaders/fisheye.frag'));
		fishEye.setFloat('amount', -0.6);
		skyCamera.filters = [new ShaderFilter(fishEye), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
		camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
		camHUD.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
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