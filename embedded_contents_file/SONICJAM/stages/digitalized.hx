import flixel.addons.display.FlxBackdrop;
import psychlua.LuaUtils;
import psychlua.FunkinLua;
import openfl.display.BlendMode;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.VideoSprite;

using StringTools;

var skyCamera:FlxCamera;
var stargazers:Array<FlxSprite>;
var _emitter:FlxEmitter;
var introCutscene:VideoSprite;
var xterionintro:FlxSprite;
var graphic:FlxSprite;

var canGenerateStars:Bool = true;

//mirror shader lol
var mirror = new ErrorHandledRuntimeShader('MirrorRepeatEffect', File.getContent('contents/SONICJAM/shaders/MirrorRepeatEffect.frag'));

//normal
var sky:FlxBackdrop;
var pillars0:FlxSprite;
var floor:FlxSprite;
var exit:FlxSprite;
var tablesh:FlxSprite;
var table:FlxSprite;
var pillars:FlxSprite;
var spotlight:FlxSprite;

//graveyard
var sky2:FlxSprite;
var xd:FlxSprite;
var trees:FlxSprite;
var bg:FlxSprite;

function onCreate()
{
	if(ClientPrefs.data.middleScroll && (ClientPrefs.data.middlescrollType == 'mobile' || ClientPrefs.data.mobileOpponentNotes)) PlayState.instance.opponentStrumOffsetY = -60;

	setupCameras();

	//intro
	skyCamera.alpha = 0;
	camGame.alpha = 0;
	camHUD.alpha = 0;

	introCutscene = new VideoSprite();
	introCutscene.onFormat(() -> {
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.screenCenter();
	});
	introCutscene.camera = camVideo;
	introCutscene.alpha = 0;
	game.add(introCutscene);
	
	graphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
	graphic.camera = camVideo;
	graphic.alpha = 0;
	game.add(graphic);

	xterionintro = new FlxSprite();
	xterionintro.frames = Paths.getSparrowAtlas('xterion evil intro');
	xterionintro.animation.addByPrefix('idle', 'xterion', 24, false); xterionintro.animation.play('idle', true);
	xterionintro.camera = camVideo;
	xterionintro.alpha = 0;
	xterionintro.scale.set(1.2, 1.2); xterionintro.updateHitbox();
	xterionintro.screenCenter();
	game.add(xterionintro);

	stargazers = [];

	game.camZoomingMult = 0;

	sky = new FlxBackdrop(Paths.image('bg/skyevil'), 0x01);
	sky.scale.set(1.3, 1.3);
	sky.updateHitbox();
	sky.y = -300;
	sky.velocity.x = -50;
	sky.camera = skyCamera;
	add(sky);

	pillars0 = new FlxSprite(-170, -450).loadGraphic(Paths.image('bg/pillarsbg'));
	pillars0.scale.set(1, 1);
	pillars0.scrollFactor.set(0.5, 0.5);
	pillars0.updateHitbox();
	addBehindDad(pillars0);

	floor = new FlxSprite(-700, -1100).loadGraphic(Paths.image('bg/floor'));
	floor.scale.set(1.9, 1.9);
	floor.updateHitbox();
	addBehindDad(floor);

	exit = new FlxSprite(-798, -850);
	exit.frames = Paths.getSparrowAtlas('bg/exit');
	exit.animation.addByPrefix('idle', 'digitalized new exit frames', 24, true); exit.animation.play('idle', true);
	exit.scale.set(1.9, 1.9);
	exit.scrollFactor.set(0.7, 0.7);
	exit.updateHitbox();
	addBehindDad(exit);

	tablesh = new FlxSprite(-700, -1060).loadGraphic(Paths.image('bg/tablesh'));
	tablesh.scale.set(1.9, 1.9);
	tablesh.updateHitbox();
	addBehindDad(tablesh);

	table = new FlxSprite(-700, -1060).loadGraphic(Paths.image('bg/table'));
	table.scale.set(1.9, 1.9);
	table.updateHitbox();
	table.camera = camGame;
	add(table);

	pillars = new FlxSprite(-700, -1100).loadGraphic(Paths.image('bg/pillars'));
	pillars.scale.set(1.9, 1.9);
	pillars.updateHitbox();
	pillars.camera = camGame;
	add(pillars);

	//graveyard
	sky2 = new FlxSprite(-400, -250).loadGraphic(Paths.image('bg/skyy'));
	sky2.scale.set(1.3, 2);
	sky2.visible = false;
	sky2.updateHitbox();
	sky2.camera = skyCamera;
	add(sky2);

	xd = new FlxSprite(-700, -470).loadGraphic(Paths.image('bg/eagleeamericaaausalibertyyyystatueburgersss'));
	xd.visible = false;
	xd.scrollFactor.set(0.5, 0.5);
	xd.scale.set(1.7, 1.7);
	xd.updateHitbox();
	addBehindDad(xd);

	trees = new FlxSprite(-500, -500).loadGraphic(Paths.image('bg/trees'));
	trees.visible = false;
	trees.scrollFactor.set(0.7, 0.7);
	trees.scale.set(1.7, 1.7);
	trees.updateHitbox();
	addBehindDad(trees);

	bg = new FlxSprite(-420, -550).loadGraphic(Paths.image('bg/bg'));
	bg.visible = false;
	bg.scale.set(1.7, 1.7);
	bg.updateHitbox();
	addBehindDad(bg);

	spotlight = new FlxSprite(-300, -450).loadGraphic(Paths.image('bg/spotlightblue'));
	spotlight.scale.y = 1.3;
	spotlight.updateHitbox();
	spotlight.alpha = 0.5;
	spotlight.blend = BlendMode.ADD;
	spotlight.camera = camGame;
	add(spotlight);
}

function onSongStart()
{
	makeStar();
	if (introCutscene?.loadVideo(Paths.video('introdigitalized'))) introCutscene.playDelayed();
	FlxTween.tween(introCutscene, {alpha: 1}, Conductor.crochet / (1000 / 32));
}
function onSectionHit() makeStar();
function onBeatHit()
{
	if (boyfriend.getAnimationName() == 'idle') boyfriend.animation.curAnim.curFrame = FlxMath.wrap(boyfriend.animation.curAnim.curFrame + 7, 0, boyfriend.animation.curAnim.numFrames - 1);
	if (dad.getAnimationName() == 'idle') dad.animation.curAnim.curFrame = FlxMath.wrap(dad.animation.curAnim.curFrame + 4, 0, dad.animation.curAnim.numFrames - 1);
}

var mirrorTween:FlxTween;
var grave:Bool = false;
function onEvent(n,v1,v2)
{
	if (n == 'substantialEvent')
	{
		switch(v1)
		{
			case 'xterionintro':
				xterionintro.animation.play('idle', true);
				FlxTween.tween(xterionintro, {alpha: 1}, Conductor.crochet / (1000 / 16));
			case 'fadein':
				FlxTween.tween(graphic, {alpha: 1}, Conductor.crochet / (1000 / 4), {ease: FlxEase.expoIn});
			case 'finishVideo':
				camGame.zoom = 10;
				camHUD.zoom = 30;
				FlxTween.cancelTweensOf(introCutscene);
				introCutscene.destroy();
				camOther.flash(0xFFFFFFFF, Conductor.crochet / 250, null, true);

				skyCamera.alpha = 1;
				camGame.alpha = 1;
				camHUD.alpha = 1;
				FlxTween.cancelTweensOf(xterionintro);
				xterionintro.destroy();
				FlxTween.cancelTweensOf(graphic); graphic.alpha = 0;
			case 'trans':
				canGenerateStars = true;

				FlxTween.cancelTweensOf(graphic);
				FlxTween.tween(graphic, {alpha: 1}, Conductor.crochet / 250, {ease: FlxEase.expoIn});
			case 'switchbg':
				grave = !grave; //S-SNOW???????

				FlxTween.cancelTweensOf(graphic);
				FlxTween.tween(graphic, {alpha: 0}, Conductor.crochet / 500);

				canGenerateStars = !grave;
				for (star in stargazers) star.visible = !grave;
				sky.visible = !grave;
				pillars0.visible = !grave;
				floor.visible = !grave;
				exit.visible = !grave;
				tablesh.visible = !grave;
				table.visible = !grave;
				pillars.visible = !grave;
				spotlight.visible = !grave;

				sky2.visible = grave;
				xd.visible = grave;
				trees.visible = grave;
				bg.visible = grave;

			case 'mirror':
				//this might be a bit confusing but ill break it down for you:
				//value 2 are the settings basically of the mirror effect, as you will see something like this: 03>[4,5]>c3>expoIn
				//so the first value its the mode of the tween, like which values do you wanna modify
				//modes: [zoom: 0, x: 1, y: 2, angle: 3]
				//the second value are the target value the modes will go, so if you used 0 (zoom) and target its [2] the zoom will go to 2, and if the mode its 03, the target should be like [2,25] if that makes sense.
				//third value its the duration or time, time can be either a regular in seconds ruler (like 0.5 for half second and 1 for a second) or in crochet (for beat based time) so if you see for example c3 it will mean "crochet / (1000 / 3)" and that means the tween will last 3 beats.
				//and the fourth value its basically just the ease of the tween

				if (mirrorTween != null) mirrorTween.cancel();
				final settings:Array<String> = v2.split('>');

				trace(settings);

				//mode setup
				var mode:String = '0';
				if (settings[0] != null && settings[0] != '') mode = settings[0];

				//target values setup
				var targets:Array<String> = ['1'];
				if (settings[1] != null && settings[1] != '') targets = settings[1].replace('[', '').replace(']', '').split(',');

				//duration setup
				var duration:Float = 1;
				if (settings[2] != null && settings[2] != '')
				{
					if (settings[2].startsWith('c')) duration = Conductor.crochet / (1000 / Std.parseFloat(settings[2].substr(1)));
					else duration = Std.parseFloat(settings[2]);
				}

				//ease setup
				var mirrorEase:String = 'linear';
				if (settings[3] != null && settings[3] != '') mirrorEase = settings[3];

				//da start values so it doesnt start from scratch making an ugly ass effect lol
				final startValue:Array<Float> = [
					mirror.getFloat('zoom'),
					mirror.getFloat('x'),
					mirror.getFloat('y'),
					mirror.getFloat('angle')
				];

				//the actual tween here
				mirrorTween = FlxTween.num(0, 1, duration, {
					ease: LuaUtils.getTweenEaseByString(mirrorEase),
					onComplete: (_) -> {mirrorTween = null;}
				}, (v:Float) -> {
					for (i in 0...mode.length)
					{
						if (i >= targets.length) break;
						final target:Float = Std.parseFloat(targets[i]);
						switch (mode.charAt(i))
						{
							case '0': mirror.setFloat('zoom', FlxMath.lerp(startValue[0], target, v));
							case '1': mirror.setFloat('x', FlxMath.lerp(startValue[1], target, v));
							case '2': mirror.setFloat('y', FlxMath.lerp(startValue[2], target, v));
							case '3': mirror.setFloat('angle', FlxMath.lerp(startValue[3], target, v));
						}
					}
				});
		}
	}
}

var starID:Int = 0;
function makeStar()
{
	if (!canGenerateStars) return;
	starID++;

	var star:FlxSprite = new FlxSprite(1200, 0).loadGraphic(Paths.image('bg/star'));
	star.camera = skyCamera;
	star.y = FlxG.random.int(100, 600);
	final speedX:Float = FlxG.random.int(300, 1500) + Math.abs(sky.velocity.x)-50;
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
	game.canReset = curStep >= 128 ? true : false;

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

	if(curStep >= 1664) sky.velocity.x -= elapsed * 40;
	
	lua('iconBF').scale.set(1, 1);
	lua('iconOpp').scale.set(1, 1);
}

function onStepHit() {
	switch(curStep) {
		case 1920: FlxTween.tween(camHUD, {alpha: 0}, 2.74, {ease: FlxEase.smootherStepInOut});
			
	}
}

function onCreatePost()
{
	if (ClientPrefs.data.shaders) {
		var fishEye = new ErrorHandledRuntimeShader('fisheye', File.getContent('contents/SONICJAM/shaders/fisheye.frag'));
		fishEye.setFloat('amount', -0.75);

		mirror.setFloat('zoom', 1);
		mirror.setFloat('x', 0);
		mirror.setFloat('y', 0);
		mirror.setFloat('angle', 0);

		skyCamera.filters = [new ShaderFilter(game.getLuaObject('dss').shader), new ShaderFilter(fishEye), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader), new ShaderFilter(mirror)];
		camGame.filters = [new ShaderFilter(game.getLuaObject('dss').shader), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader), new ShaderFilter(mirror)];
		camHUD.filters = [new ShaderFilter(game.getLuaObject('dss').shader), new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject("VHS").shader)];
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

function onGameOverStart()  introCutscene?.destroy();
function onPause() introCutscene?.pause();
function onResume() introCutscene?.resume();

function lua(obj:String) return game.getLuaObject(obj); 