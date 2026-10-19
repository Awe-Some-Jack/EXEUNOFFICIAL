import psychlua.LuaUtils;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;

typedef DropShadow = {
	var shader:ErrorHandledRuntimeShader;
	var char:Character;
	var tag:String;
}

typedef Shader = {
	var shader:ErrorHandledRuntimeShader;
	@:optional var defaultConfig:Map<String, Dynamic>;
	@:optional var config:Map<String, Dynamic>;
	@:optional var configOffset:Map<String, Dynamic>;
	@:optional var shaderTweens:Map<String, FlxTween>;
}

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
	{path: 'characters/knuxatlas', tag: 'knux', position: [1180, 350], isAtlas: true, animation: [{name: 'normalidle'}], layer: 'top'},
	{path: 'bg/normal/fg', position: [-915, -950], scroll: [1.5, 1.5], layer: 'top'},
	{path: 'bg/normal/overlay', position: [-900, -650], scroll: [1.5, 1.5], layer: 'top', blend: 'add', color: 0xFFFF781E, alpha: 0}
];

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var isManualBlast:Bool = false;

//objs

var topBar:FlxSprite;
var botBar:FlxSprite;
var vignette:FlxSprite;

//shaders
var bloom:Shader = {shader: null, config: ['saturation' => 0.88, 'brightness' => -0.075, 'contrast' => 0.95]};
var aberration:Shader = {shader: null, config: ['amount' => 0.1]};
var chromatic:Shader = {shader: null};
var glitch:Shader = {shader: null};

var shaderChars:Array<DropShadow> = [
	{shader: null, char: game.dad, tag: 'dad'},
	{shader: null, char: game.boyfriend, tag: 'bf'},
	{shader: null, char: game.gf, tag: 'gf'},

	{shader: null, char: null, tag: 'tails'},
	{shader: null, char: null, tag: 'knux'}
];

//HEDGE MODCHART
var notesPosition:Array<Array<Array<Float>>> = [[[0,0],[0,0],[0,0],[0,0]],[[0,0],[0,0],[0,0],[0,0]]];
var modcharts:Array<Void -> Void> = [
	function() {
		for (i in 0...4) {
			FlxTween.tween(strumLineNotes.members[i], {x: notesPosition[0][3 - i][0], y: prefs.downScroll ? 50 : 570}, 0.1, {ease: FlxEase.cubeOut});
			changeDirection();
		}
	},
	function() {
		for (i in 0...4) {
			FlxTween.tween(strumLineNotes.members[i], {x: notesPosition[1][3 - i][0]}, 0.1, {ease: FlxEase.cubeOut});
			FlxTween.tween(strumLineNotes.members[i + 4], {x: notesPosition[0][3 - i][0]}, 0.1, {ease: FlxEase.cubeOut});
		}
	},
	function() {
		for (i in 0...4) FlxTween.tween(strumLineNotes.members[i], {x: notesPosition[0][3 - i][0]}, 0.1, {ease: FlxEase.cubeOut});
	},
	function() {
		for (i in 0...4) FlxTween.tween(strumLineNotes.members[i], {x: notesPosition[0][i][0] + FlxG.random.float(-200, 200), y: notesPosition[0][i][1] + FlxG.random.float(-200, 200), angle: FlxG.random.float(-50, 50)}, 3, {ease: FlxEase.cubeOut});
	},
	function() {
		for (i in 0...4) {
			FlxTween.cancelTweensOf(strumLineNotes.members[i]);
			FlxTween.cancelTweensOf(strumLineNotes.members[i + 4]);
			FlxTween.tween(strumLineNotes.members[i], {x: notesPosition[0][i][0], y: notesPosition[0][i][1], angle: 0}, 0.1, {ease: FlxEase.cubeOut});
			FlxTween.tween(strumLineNotes.members[i + 4], {x: notesPosition[1][i][0], y: notesPosition[1][i][1], angle: 0}, 0.1, {ease: FlxEase.cubeOut});

			revertDirection();
		}
	}
];

function onCreate()
{
	if (Paths.formatToSongPath(PlayState.SONG.song) == 'manual-blast') isManualBlast = true;

	gf.scrollFactor.set(1, 1);
	makeBackground(hogBG);
	
	vignette = new FlxSprite().loadGraphic(Paths.image('VG'));
	vignette.color = 0xFF000000;
	vignette.camera = camOther;
	vignette.alpha = 0.6;
	add(vignette);

	topBar = new FlxSprite(-50, -100).makeGraphic(FlxG.width + 100, 100, 0xFF000000);
	topBar.camera = camHUD;
	insert(0, topBar);

	botBar = new FlxSprite(-50, FlxG.height).makeGraphic(FlxG.width + 100, 100, 0xFF000000);
	botBar.camera = camHUD;
	insert(0, botBar);

	//handle shaders vvvvvvvvvvvv xd

	for (c in shaderChars)
	{
		if (c.tag == 'tails' && c.char == null) c.char = hogBG[8].sprite;
		if (c.tag == 'knux' && c.char == null) c.char = hogBG[10].sprite;
		final char:Character = c.char;
		var dropShadow:ErrorHandledRuntimeShader = new ErrorHandledRuntimeShader('DropShadowShader', File.getContent(Paths.shaderFragment('DropShadowShader')));
		dropShadow.setFloat('hue', 0);
		dropShadow.setFloat('brightness', 0);
		dropShadow.setFloat('contrast', 0);
		dropShadow.setFloat('saturation', 0);
		dropShadow.setFloat('str', 1);
		dropShadow.setFloat('dist', 0);
		dropShadow.setFloat('thr', 0.15);
		dropShadow.setFloatArray('dropColor', [137 / 255, 96 / 255, 0 / 255]);

		switch(c.tag) {
			case 'bf': dropShadow.setFloat('ang', 105 * (Math.PI / 180));
			case 'dad': dropShadow.setFloat('ang', 75 * (Math.PI / 180));
			case 'gf': dropShadow.setFloat('ang', 95 * (Math.PI / 180));
			case 'tails': dropShadow.setFloat('ang', 80 * (Math.PI / 180));
			case 'knux': dropShadow.setFloat('ang', 115 * (Math.PI / 180));
		}
		
		c.shader = dropShadow;
		char.useRenderTexture = true;
		char.shader = dropShadow;
		setShaderFrameInfo(c.tag);
	}

	bloom.shader = new ErrorHandledRuntimeShader('brightness', File.getContent(Paths.shaderFragment('brightness')));
	bloom.configOffset = ['saturation' => 0, 'brightness' => 0, 'contrast' => 0]; //sucks
	bloom.defaultConfig = ['saturation' => 0.88, 'brightness' => -0.075, 'contrast' => 0.95];
	bloom.shaderTweens = [];

	aberration.shader = new ErrorHandledRuntimeShader('chromabber', File.getContent(Paths.shaderFragment('chromabber')));
	aberration.shader.setFloat('amount', aberration.config.get('amount'));
	aberration.shaderTweens = [];

	camGame.filters = camHUD.filters = [new ShaderFilter(aberration.shader), new ShaderFilter(bloom.shader)];

	if (!isManualBlast)
	{
		bloom.config = ['saturation' => 1, 'brightness' => 0, 'contrast' => 1];
		bloom.defaultConfig = ['saturation' => 1, 'brightness' => 0, 'contrast' => 1]; //sucks

		chromatic.shader = new ErrorHandledRuntimeShader('chromatic', File.getContent(Paths.shaderFragment('chromatic')));
		chromatic.shader.setFloatArray('rOffset', [0, 0]);
		chromatic.shader.setFloatArray('gOffset', [0, 0]);
		chromatic.shader.setFloatArray('bOffset', [0, 0]);

		glitch.shader = new ErrorHandledRuntimeShader('glitchChromatic', File.getContent(Paths.shaderFragment('glitchChromatic')));
		camGame.filters = camHUD.filters = [new ShaderFilter(aberration.shader), new ShaderFilter(bloom.shader), new ShaderFilter(chromatic.shader), new ShaderFilter(glitch.shader)];
	}
}

function onCreatePost()
{
	for (i in 0...4)
	{
		notesPosition[0][i][0] = opponentStrums.members[i].x; notesPosition[1][i][0] = playerStrums.members[i].x;
		notesPosition[0][i][1] = opponentStrums.members[i].y; notesPosition[1][i][1] = playerStrums.members[i].y;
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
	
	bloom.shader.setFloat('saturation', bloom.config.get('saturation') + bloom.configOffset.get('saturation'));
	bloom.shader.setFloat('brightness', bloom.config.get('brightness') + bloom.configOffset.get('brightness'));
	bloom.shader.setFloat('contrast', bloom.config.get('contrast') + bloom.configOffset.get('contrast'));

	if (!isManualBlast)
	{
		glitch.shader.setFloat('iTime', _sine);

		final progress:Float = FlxMath.bound(Conductor.songPosition / (FlxG.sound.music.length - (Conductor.crochet * 12)), 0, 1);
		hogBG[0].sprite.y = FlxMath.lerp(-1100, -450, progress);
		hogBG[1].sprite.alpha = FlxMath.lerp(1, 0, progress);
		hogBG[2].sprite.alpha = FlxMath.lerp(1, 0, progress);
		hogBG[12].sprite.alpha = FlxMath.lerp(0.5, 0, progress);

		vignette.alpha = FlxMath.lerp(0.0001, 0.6, progress);

		bloom.configOffset.set('saturation', FlxMath.lerp(0, -0.12, progress));
		bloom.configOffset.set('brightness', FlxMath.lerp(0, -0.075, progress));
		bloom.configOffset.set('contrast', FlxMath.lerp(0, -0.05, progress));

		for (c in shaderChars) c.shader.setFloat('dist', FlxMath.lerp(15, 0, progress));
	}

	for (spr in hogBG) if (spr.tag == 'tails' && spr.sprite != null)
	{
		spr.sprite.setPosition(
			spr.position[0] + Math.cos(_sine) * 30,
			spr.position[1] + Math.sin(_sine * 2) * 15
		);
	}
}

//hedge vars
var modchartStyle:Int = -1;
var _isGlitch:Bool = false;
function onEvent(n,v1,v2)
{
	if (n == 'bright zoom' && prefs.flashing)
	{
		if (bloom.shaderTweens['bloom']?.active ?? false) bloom.shaderTweens['bloom'].cancel();

		var baseBrightness:Float = bloom.defaultConfig.get('brightness');
   		var baseContrast:Float = bloom.defaultConfig.get('contrast');

		var oneSplit:Array<String> = v1.split(',');
		var fromValue:Float = (Math.isNaN(Std.parseFloat(oneSplit[0])) ? 0.15 : Std.parseFloat(oneSplit[0]));
		var toValue:Float = (Math.isNaN(Std.parseFloat(oneSplit[1])) ? 0 : Std.parseFloat(oneSplit[1]));

		var twoSplit:Array<String> = v2.split(',');
		var duration:Float = (Math.isNaN(Std.parseFloat(twoSplit[0])) ? 4 : Std.parseFloat(twoSplit[0]));
		var ease:String = (twoSplit[1] == null || twoSplit[1] == '') ? 'cubeOut' : twoSplit[1];

		bloom.shaderTweens['bloom'] = FlxTween.num(fromValue, toValue, Conductor.crochet / (1000 / duration), {ease: LuaUtils.getTweenEaseByString(ease)}, v -> {
			bloom.config.set('brightness', baseBrightness + v * 2);
			bloom.config.set('contrast', baseContrast + (v * 4));
		});

		if (aberration.shaderTweens['abb']?.active ?? false) aberration.shaderTweens['abb'].cancel();
		
		aberration.shaderTweens['abb'] = FlxTween.num(fromValue, toValue, Conductor.crochet / (1000 / duration), {ease: LuaUtils.getTweenEaseByString(ease)}, v -> {
			aberration.shader.setFloat('amount', aberration.config.get('amount') + (v / 5));
		});
	}

	if (n == 'ghhcselol')
	{
		if (!isManualBlast)
		{
			_isGlitch = !_isGlitch;

			if (_isGlitch)
			{
				modchartStyle++;
				modcharts[modchartStyle]();
			}
			else modcharts[4]();

			for (i in 0...game.notes.length)
			{
				var note:Note = game.notes.members[i];
				note.multSpeed = (_isGlitch ? FlxG.random.float(0.8, 1.4) : 1);
				if (note.noteType == 'Fake Note') note.alpha = (_isGlitch ? 1 : 0.0001);
			}
		}
	}

	if (n == 'Change Character')
	{
		for (c in shaderChars)
		{
			if (c.tag == v1)
			{
				if (c.char != null) {
					c.char.shader = null;
					c.char.useRenderTexture = false;
					c.char.animation.callback = null;
				}

				var char:Character = game.boyfriend;
				switch(v1.toLowerCase())
				{
					case 'gf': char = game.gf;
					case 'dad': char = game.dad;
				}

				char.useRenderTexture = true;
				char.shader = c.shader;
				c.char = char;
				setShaderFrameInfo(c.tag);
			}
		}
	}

	if (n == 'sexxxxxx')
	{
		switch(v1)
		{
			case 'saturation':
				if (bloom.shaderTweens['sat']?.active ?? false) bloom.shaderTweens['sat'].cancel();

				var split:Array<String> = v2.split(',');
				var sat:Float = (Math.isNaN(Std.parseFloat(split[0])) ? 1 : Std.parseFloat(split[0]));
				var duration:Float = (Math.isNaN(Std.parseFloat(split[1])) ? 0 : Std.parseFloat(split[1]));
				if (duration <= 0)
					bloom.config.set('saturation', sat);
				else
				{
					bloom.shaderTweens['sat'] = FlxTween.num(bloom.config.get('saturation'), sat, Conductor.crochet / (1000 / duration), {ease: FlxEase.cubeInOut}, v -> {
						bloom.config.set('saturation', v);
					});
				}

			case 'cinematicbars':
				FlxTween.cancelTweensOf(topBar); FlxTween.cancelTweensOf(botBar);

				var split:Array<String> = v2.split(',');
				var duration:Float = (Math.isNaN(Std.parseFloat(split[1])) ? 4 : Std.parseFloat(split[1]));

				FlxTween.tween(topBar, {y: split[0] == '1' ? -50 : -100}, Conductor.crochet / (1000 / duration), {ease: FlxEase.cubeInOut});
				FlxTween.tween(botBar, {y: split[0] == '1' ? FlxG.height - 50 : FlxG.height}, Conductor.crochet / (1000 / duration), {ease: FlxEase.cubeInOut});
		}
	}
}

function setShaderFrameInfo(obj:String) {
	var char:FlxSprite;
	switch(obj) {
		case 'bf': char = game.boyfriend;
		case 'dad': char = game.dad;
		case 'gf': char = game.gf;
		case 'tails': char = hogBG[8].sprite;
		case 'knux': char = hogBG[10].sprite;
	}

	char.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
	{
		if (char.shader != null) {
			char.shader.setFloatArray('uFrameBounds', [char.frame.uv.x, char.frame.uv.y, char.frame.uv.width, char.frame.uv.height]);
			char.shader.setFloat('angOffset', char.frame.angle * FlxAngle.TO_RAD);
		}
	}
}

//for hedge modchart lol

function changeDirection()
{
	for (i in 0...4) opponentStrums.members[i].downScroll = !prefs.downScroll;
	for (i in 0...notes.length)
	{
		var note:Note = notes.members[i];
		if (!note.mustPress)
		{
			if (note.isSustainNote)
			{
				note.flipY = !prefs.downScroll;
				note.correctionOffset = 56.204081 * (prefs.downScroll ? 1 : 0);
			}
			note.updateHitbox();
		}
	}
	for (i in 0...unspawnNotes.length)
	{
		var note:Note = unspawnNotes[i];
		if (!note.mustPress)
		{
			if (note.isSustainNote)
			{
				note.flipY = !prefs.downScroll;
				note.correctionOffset = 56.204081 * (prefs.downScroll ? 1 : 0);
			}
			note.updateHitbox();
		}
	}
}

function revertDirection()
{
	for (i in 0...4) opponentStrums.members[i].downScroll = prefs.downScroll;
	for (i in 0...notes.length)
	{
		var note:Note = notes.members[i];
		if (!note.mustPress)
		{
			if (note.isSustainNote)
			{
				note.flipY = prefs.downScroll;
				note.correctionOffset = 56.204081 * (prefs.downScroll ? 0 : 1);
			}
			note.updateHitbox();
		}
	}
	for (i in 0...unspawnNotes.length)
	{
		var note:Note = unspawnNotes[i];
		if (!note.mustPress)
		{
			if (note.isSustainNote)
			{
				note.flipY = prefs.downScroll;
				note.correctionOffset = 56.204081 * (prefs.downScroll ? 0 : 1);
			}
			note.updateHitbox();
		}
	}
}