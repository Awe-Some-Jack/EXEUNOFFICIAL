import flixel.addons.display.FlxBackdrop;
import psychlua.FunkinLua;
import openfl.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.particles.FlxEmitter;

var skyCamera:FlxCamera;
var stargazers:Array<FlxSprite>;
var _emitter:FlxEmitter;
function onCreate()
{
	setupCameras();

	stargazers = [];

	game.camZoomingMult = 0;

	var sky:FlxBackdrop = new FlxBackdrop(Paths.image('bg/skyevil'), 0x01);
	sky.scale.set(1.3, 1.3);
	sky.updateHitbox();
	sky.y = -300;
	sky.velocity.x = -50;
	sky.camera = skyCamera;
	add(sky);

	var pillars:FlxSprite = new FlxSprite(-170, -450).loadGraphic(Paths.image('bg/pillarsbg'));
	pillars.scale.set(1, 1);
	pillars.scrollFactor.set(0.5, 0.5);
	pillars.updateHitbox();
	addBehindDad(pillars);

	var floor:FlxSprite = new FlxSprite(-700, -1100).loadGraphic(Paths.image('bg/floor'));
	floor.scale.set(1.9, 1.9);
	floor.updateHitbox();
	addBehindDad(floor);

	var exit:FlxSprite = new FlxSprite(-798, -850);
	exit.frames = Paths.getSparrowAtlas('bg/exit');
	exit.animation.addByPrefix('idle', 'digitalized new exit frames', 24, true); exit.animation.play('idle', true);
	exit.scale.set(1.9, 1.9);
	exit.scrollFactor.set(0.7, 0.7);
	exit.updateHitbox();
	addBehindDad(exit);

	var tablesh:FlxSprite = new FlxSprite(-700, -1060).loadGraphic(Paths.image('bg/tablesh'));
	tablesh.scale.set(1.9, 1.9);
	tablesh.updateHitbox();
	addBehindDad(tablesh);

	var table:FlxSprite = new FlxSprite(-700, -1060).loadGraphic(Paths.image('bg/table'));
	table.scale.set(1.9, 1.9);
	table.updateHitbox();
	table.camera = camGame;
	add(table);

	var pillars:FlxSprite = new FlxSprite(-700, -1100).loadGraphic(Paths.image('bg/pillars'));
	pillars.scale.set(1.9, 1.9);
	pillars.updateHitbox();
	pillars.camera = camGame;
	add(pillars);

	var spotlight:FlxSprite = new FlxSprite(-300, -450).loadGraphic(Paths.image('bg/spotlightblue'));
	spotlight.scale.y = 1.3;
	spotlight.updateHitbox();
	spotlight.alpha = 0.5;
	spotlight.blend = BlendMode.ADD;
	spotlight.camera = camGame;
	add(spotlight);

	_emitter = new FlxEmitter(FlxG.width / 2, FlxG.height / 2, 200);
	_emitter.makeParticles(2, 2, FlxColor.WHITE, 200);
	_emitter.camera = camGame;
	add(_emitter);
}

function onSongStart() makeStar();
function onSectionHit() makeStar();
function onBeatHit()
{
	if (boyfriend.getAnimationName() == 'idle') boyfriend.animation.curAnim.curFrame = FlxMath.wrap(boyfriend.animation.curAnim.curFrame + 7, 0, boyfriend.animation.curAnim.numFrames - 1);
	if (dad.getAnimationName() == 'idle') dad.animation.curAnim.curFrame = FlxMath.wrap(dad.animation.curAnim.curFrame + 4, 0, dad.animation.curAnim.numFrames - 1);
}

var starID:Int = 0;
function makeStar()
{
	starID++;

	var star:FlxSprite = new FlxSprite(1200, 0).loadGraphic(Paths.image('bg/star'));
	star.camera = skyCamera;
	star.y = FlxG.random.int(100, 600);
	final speedX:Float = FlxG.random.int(300, 1500);
	final speedY:Float = FlxG.random.int(10, 300);
	star.velocity.x = -speedX;
	star.velocity.y = -speedY;
	star.ID = starID;
	star.angle = Math.atan2(speedY, speedX) * 180 / Math.PI;
	stargazers.push(star);
	add(star);
}

function onUpdatePost(elapsed:Float)
{
	for (star in stargazers)
	{
		if (star.x < -800)
		{
			remove(star, true);
			star.destroy();
			stargazers.remove(star);
			break;
		}
	}
	
	lua('iconBF').scale.set(1, 1);
	lua('iconOpp').scale.set(1, 1);
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

function lua(obj:String) return game.getLuaObject(obj); 