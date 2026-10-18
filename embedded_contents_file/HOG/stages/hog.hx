import flixel.math.FlxMath;

var hogBG:Array<BackgroundSprite> = [
	{path: 'bg/normal/sky', position: [-820, -450], scroll: [0.2, 0.2]},
	{path: 'bg/normal/clouds', position: [-820, -600], scroll: [0.2, 0.2], backdrop: ['x', [25, 0]], alpha: 0},
	{path: 'bg/normal/bigcloud', position: [-820, -600], scroll: [0.2, 0.2], alpha: 0},
	{path: 'bg/normal/mountains', position: [-820, -320], scroll: [0.4, 0.4]},
	{path: 'bg/normal/hogwaterfall', position: [-270, 70], scroll: [0.4, 0.4], animation: [{name: 'leftwatermark', fps: 12, looped: true}]},
	{path: 'bg/normal/mountain2', position: [-730, 90], scroll: [0.4, 0.4]},
	{path: 'bg/normal/hogwaterfall', position: [550, 50], scroll: [0.4, 0.4], animation: [{name: 'rightwaterfall', fps: 12, looped: true}]},
	{path: 'bg/normal/hill', position: [-850, -130], scroll: [0.6, 0.6], isAtlas: true, animation: [{name: 'hill', fps: 36, looped: true}]},
	{path: 'characters/tailsatlas', tag: 'tails', position: [100, -50], scale: [0.8, 0.8], scroll: [0.8, 0.8], isAtlas: true, animation: [{name: 'normalidle'}]},
	{path: 'bg/normal/floor', position: [-900, -450]},
	{path: 'characters/knuxatlas', tag: 'knux', position: [1180, 350], isAtlas: true, animation: [{name: 'normalidle'}], layer: 'behindbf'},
	{path: 'bg/normal/fg', position: [-900, -950], scroll: [1.5, 1.5], front: true},
	{path: 'bg/normal/overlay', position: [-900, -650], scroll: [1.5, 1.5], front: true, blend: 'add', color: 0xFFFF781E, alpha: 0}
];

var isManualBlast:Bool = false;

//shaders
var bloom:ErrorHandledRuntimeShader;
var chromatic:ErrorHandledRuntimeShader;
var glitch:ErrorHandledRuntimeShader;

function onCreate()
{
	if (Paths.formatToSongPath(PlayState.SONG.song) == 'manual-blast') isManualBlast = true;
	gf.scrollFactor.set(1, 1);
	makeBackground(hogBG);

	bloom = new ErrorHandledRuntimeShader('brightness', File.getContent('contents/HOG/shaders/brightness.frag'));
	bloom.setFloat('saturation', 1);
	bloom.setFloat('brightness', 0);
	bloom.setFloat('contrast', 1);

	camGame.filters = camHUD.filters = [new ShaderFilter(bloom)];

	if (!isManualBlast)
	{
		chromatic = new ErrorHandledRuntimeShader('chromatic', File.getContent('contents/HOG/shaders/chromatic.frag'));
		chromatic.setFloatArray('rOffset', [0, 0]);
		chromatic.setFloatArray('gOffset', [0, 0]);
		chromatic.setFloatArray('bOffset', [0, 0]);

		glitch = new ErrorHandledRuntimeShader('glitchChromatic', File.getContent('contents/HOG/shaders/glitchChromatic.frag'));
		camGame.filters = camHUD.filters = [new ShaderFilter(bloom), new ShaderFilter(chromatic), new ShaderFilter(glitch)];
	}
}

function onBeatHit()
{
	for (spr in hogBG) if ((spr.tag == 'tails' || spr.tag == 'knux') && curBeat % 2 == 0 && spr.sprite != null) spr.sprite.animation.play('normalidle', true);
}

var _sine:Float = 0;
function onUpdatePost(e:Float)
{
	_sine += e;
	if (!isManualBlast)
	{
		glitch.setFloat('iTime', _sine);

		final progress:Float = FlxMath.bound(Conductor.songPosition / (FlxG.sound.music.length - (Conductor.crochet * 12)), 0, 1);
		hogBG[0].sprite.y = FlxMath.lerp(-1100, -450, progress);
		hogBG[1].sprite.alpha = FlxMath.lerp(1, 0, progress);
		hogBG[2].sprite.alpha = FlxMath.lerp(1, 0, progress);
		hogBG[12].sprite.alpha = FlxMath.lerp(0.5, 0, progress);
	}

	for (spr in hogBG) if (spr.tag == 'tails' && spr.sprite != null)
	{
		spr.sprite.setPosition(
			spr.position[0] + Math.cos(_sine) * 30,
			spr.position[1] + Math.sin(_sine * 2) * 15
		);
	}

}