import psychlua.LuaUtils;
import hxvlc.flixel.FlxVideoSprite;
import openfl.display.BlendMode;

final game = PlayState.instance;

//shaders
var rgbShit:ErrorHandledRuntimeShader;
var brightness:ErrorHandledRuntimeShader;

var introCutscene:FlxVideoSprite;
var sanicBG:FlxVideoSprite;
var videos:Array<FlxVideoSprite> = [];
var spotlights:Array<FlxSprite> = [];
function onCreate()
{
	camGame.alpha = 0; camHUD.alpha = 0;
	introCutscene = new FlxVideoSprite();
	introCutscene.load(Paths.video('intro'));
	introCutscene.bitmap.rate = 1.08;
	introCutscene.bitmap.onFormatSetup.add(() -> { 
		introCutscene.setGraphicSize(FlxG.width, FlxG.height);
		introCutscene.screenCenter();
	});
	introCutscene.camera = camVideo;
	introCutscene.bitmap.onEndReached.add(() -> {camGame.alpha = 1; introCutscene.destroy();});
	game.add(introCutscene);
	videos.push(introCutscene);

	sanicBG = new FlxVideoSprite(null, -900, -800);
	sanicBG.load(Paths.video('bg${FlxG.random.int(1,2)}'));
	sanicBG.bitmap.onFormatSetup.add(() -> { 
		sanicBG.scale.set(2, 2);
		sanicBG.updateHitbox();
	});
	sanicBG.bitmap.onEndReached.add(() -> {sanicBG.destroy();});
	insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sanicBG);
	videos.push(sanicBG);

	for (s in 0...2)
	{
		var spotlight:FlxSprite = new FlxSprite(-330 + (1370 * s), -700).loadGraphic(Paths.image('spotlight'));
		spotlight.scale.set(2, 2.8); spotlight.updateHitbox();
		spotlight.alpha = 0;
		spotlight.blend = BlendMode.ADD;
		spotlights.push(spotlight);
		game.add(spotlight);
	}

	//shaders
	rgbShit = new ErrorHandledRuntimeShader('Gay', File.getContent('contents/SANIC/shaders/Gay.frag'));
	brightness = new ErrorHandledRuntimeShader('brightness', File.getContent('contents/SANIC/shaders/brightness.frag'));
	brightness.setFloat('saturation', 1);
	brightness.setFloat('brightness', 0);
	brightness.setFloat('contrast', 1);
	camGame.filters = [new ShaderFilter(brightness)]; camHUD.filters = [new ShaderFilter(brightness)];

	//precache
	preloadCharacter(1, 'sanicsad');
	preloadCharacter(0, 'bfsanicsad');
}

function onCreatePost()
{
	var bandicam:FlxSprite = new FlxSprite(0, 5).loadGraphic(Paths.image('bandimark'));
	bandicam.camera = camOther;
	bandicam.scale.set(1.2, 1.2); bandicam.updateHitbox();
	bandicam.alpha = 0.5;
	bandicam.screenCenter(0x01);
	add(bandicam);
}

var iTime:Float = 0;
function onUpdatePost(e)
{
	iTime += e;
	rgbShit.setFloat('iTime', iTime);
}

var brightTween:FlxTween;
function onEvent(n,v1,v2)
{
	if (n == 'bright zoom')
	{
		if (brightTween?.active ?? false) brightTween.cancel();
		brightTween = FlxTween.num(0.2, 0, Conductor.crochet / 250, {ease: FlxEase.cubeOut}, v -> {
			brightness.setFloat('brightness', v);
			brightness.setFloat('contrast', 1 + (v * 3.12));
		});
	}
	if (n == 'sanicEvent')
	{
		switch(v1)
		{
			case 'hud':
				sanicBG.play();
				FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 250);
			case 'removeintro':
				camGame.alpha = 1;
				introCutscene.stop();
				introCutscene.destroy();
			case 'fadein':
				camGame.fade(0x75FFFFFF, 1, false, null, true);
			case 'flash':
				camGame.fade(0x00FFFFFF, 0.0001, false, null, true);
				camGame.flash(0x75FFFFFF, 1, null, true);
			case 'sentimental':
				sanicBG.alpha = 0.4;
				camGame.flash(0xFFFFFFFF, 1, null, true);
				changeCharacter('dad', 'sanicsad');
				changeCharacter('bf', 'bfsanicsad');
				for (s in spotlights) s.alpha = 0.35;
			case 'fadespotlight':
				FlxTween.tween(spotlights[0], {alpha: 0}, Conductor.crochet / 500, {ease: FlxEase.cubeIn});
			case 'mgl':
				changeCharacter('dad', 'sanic');
				changeCharacter('bf', 'bfsanic');
				for (s in spotlights) s.alpha = 0;
				sanicBG.alpha = 1;
		}
	}
}

function onSongStart() introCutscene.play();
function onGameOverStart() for (video in videos) video?.destroy();
function onPause() for (video in videos) video?.pause();
function onResume() for (video in videos) video?.resume();

function onBeatHit()
{
	for (char in [boyfriend, dad])
	{
		if (char.getAnimationName() == 'idle' && char.animation.curAnim.curFrame > 3 && curBeat % 2 == 0) char.playAnim('idle', true);
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);