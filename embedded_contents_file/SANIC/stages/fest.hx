import hxvlc.flixel.FlxVideoSprite;
import psychlua.LuaUtils;

var sanicBG:FlxVideoSprite;
final game = PlayState.instance;

//shaders
var rgbShit:ErrorHandledRuntimeShader;
var brightness:ErrorHandledRuntimeShader;

function onCreate()
{
	sanicBG = new FlxVideoSprite(null, -900, -800);
	sanicBG.load(Paths.video('bg${FlxG.random.int(1,2)}'));
	sanicBG.bitmap.onFormatSetup.add(() -> { 
		sanicBG.scale.set(2, 2);
		sanicBG.updateHitbox();
	});
	sanicBG.bitmap.onEndReached.add(() -> {sanicBG.destroy();});
	insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sanicBG);

	//shaders
	rgbShit = new ErrorHandledRuntimeShader('Gay', File.getContent('contents/SANIC/shaders/Gay.frag'));
	brightness = new ErrorHandledRuntimeShader('brightness', File.getContent('contents/SANIC/shaders/brightness.frag'));
	brightness.setFloat('saturation', 1);
	brightness.setFloat('brightness', 0);
	brightness.setFloat('contrast', 1);
	camGame.filters = [new ShaderFilter(brightness)]; camHUD.filters = [new ShaderFilter(brightness)];
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
			case 'sentimental':
			case 'mgl':
		}
	}
}

function onSongStart() sanicBG.play();
function onGameOverStart() sanicBG.destroy();
function onPause() sanicBG.pause();
function onResume() sanicBG.resume();

function onBeatHit()
{
	for (char in [boyfriend, dad])
	{
		if (char.getAnimationName() == 'idle' && char.animation.curAnim.curFrame > 3 && curBeat % 2 == 0) char.playAnim('idle', true);
	}
}