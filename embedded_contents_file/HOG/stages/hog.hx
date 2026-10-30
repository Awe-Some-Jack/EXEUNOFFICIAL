import psychlua.LuaUtils;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import flixel.addons.display.FlxBackdrop;
import objects.HealthIcon;
import backend.EXEAchievements;

using StringTools;

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

typedef RollEmber = { spr:FlxSprite, vy:Float, phase:Float, sway:Float, base:Float }

var hogBG:Array<BackgroundSprite> = [
	{path: 'bg/normal/sky', position: [-820, -1100], scroll: [0.2, 0.2]},
	{path: 'bg/normal/clouds', position: [-820, -600], scroll: [0.2, 0.2], backdrop: ['x', [25, 0]]},
	{path: 'bg/normal/bigcloud', position: [-820, -600], scroll: [0.2, 0.2]},
	{path: 'bg/normal/mountains', position: [-820, -320], scroll: [0.4, 0.4]},
	{path: 'bg/normal/hogwaterfall', position: [-270, 70], scroll: [0.4, 0.4], animation: [{name: 'leftwatermark', fps: 12, looped: true}]},
	{path: 'bg/normal/mountain2', position: [-730, 90], scroll: [0.4, 0.4]},
	{path: 'bg/normal/hogwaterfall', position: [600, 50], scroll: [0.4, 0.4], animation: [{name: 'rightwaterfall', fps: 12, looped: true}]},
	{path: 'bg/normal/hill', tag: 'hill', position: [-850, -130], scroll: [0.6, 0.6], isAtlas: true, animation: [{name: 'evil'}, {name: 'needle'}, {name: 'fatal'}, {name: 'starved'}, {name: 'nmi'}, {name: 'devoid'}, {name: 'creepy', fps: 36, looped: true}, {name: 'normal', fps: 36, looped: true}]},
	{path: 'bg/normal/floor', position: [-900, -450]},
	{path: 'characters/tailsatlas', tag: 'tails', position: [-80, -100], scale: [0.8, 0.8], scroll: [0.8, 0.8], isAtlas: true, animation: [{name: 'evilidleg1'}, {name: 'evilidleg2'}, {name: 'evilidleg3'}, {name: 'evilidle'}, {name: 'normalidle1'}, {name: 'normalidle2'}, {name: 'normalidle3'}, {name: 'normalidle4'}, {name: 'normalidle'}]},
	{path: 'characters/knuxatlas', tag: 'knux', position: [1350, 350], isAtlas: true, animation: [{name: 'evilidleg1'}, {name: 'evilidleg2'}, {name: 'evilidleg3'}, {name: 'evilidle'}, {name: 'normalidle'}], layer: 'top'},
	{path: 'bg/normal/fg', position: [-1050, -1150], scroll: [1.5, 1.5], scale: [1.1, 1.1], layer: 'top'},
	{path: 'bg/normal/overlay', tag: 'overlay', position: [-900, -650], scroll: [1.5, 1.5], layer: 'top', blend: 'add', color: 0xFFFF781E, alpha: 0.5}
];

var scorchedBG:Array<BackgroundSprite> = [
	{path: 'bg/evil/sky', position: [-820 - 548, -620], scroll: [0.2, 0.2], scale: [1, 0.6]},
	{path: 'bg/evil/mountains', position: [-820 - 548, -320 - 126], scroll: [0.4, 0.4]},
	{path: 'bg/evil/hogwaterfall', position: [-270, 70], scroll: [0.4, 0.4], animation: [{name: 'leftwatermark', fps: 12, looped: true}]},
	{path: 'bg/evil/mountain2', position: [-730, 90], scroll: [0.4, 0.4]},
	{path: 'bg/evil/hogwaterfall', position: [600, 50], scroll: [0.4, 0.4], animation: [{name: 'rightwaterfall', fps: 12, looped: true}]},
	{path: 'characters/exes', tag: 'exes', position: [-900, -100], isAtlas: true, animation: [{name: 'exes1'}, {name: 'exes2'}]},
	{path: 'bg/evil/floor', position: [-900 - 548, -450 - 731]}
	{path: 'bg/evil/fg', position: [-1254, -650], scroll: [1.5, 1.5], scale: [1.1, 1.1], layer: 'top'},
];

var glitchBG:FlxSprite;
var glitchFG:FlxSprite;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var isManualBlast:Bool = false;
var songPhase:String = 'normal';
var unlockRingAchievement:Bool = true;

//objs

var topBar:FlxSprite;
var botBar:FlxSprite;
var vignette:FlxSprite;

var spacebar:FlxSprite;

var blackScreen:FlxSprite;

//shaders
var bloom:Shader = {shader: null, config: ['saturation' => 1, 'brightness' => 0, 'contrast' => 1]};
var aberration:Shader = {shader: null, config: ['amount' => 0.05], defaultConfig: ['amount' => 0.05]};
var chromatic:Shader = {shader: null};
var glitch:Shader = {shader: null};
var smear:Shader = {shader: null};
var glitch2:Shader = {shader: null, config: ['amount' => 0.1]};

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

var oppIcons:Map<String, String> = [
	"idle-g1" => "lordx",
	"singLEFT-g1" => "xeno",
	"singDOWN-g1" => "xterion",
	"singUP-g1" => "grimware",
	"singRIGHT-g1" => "rerun",

	"idle-g2" => "mighty",
	"singLEFT-g2" => "cyclops",
	"singDOWN-g2" => "eyx",
	"singUP-g2" => "griatos",
	"singRIGHT-g2" => "sally",

	"idle-g3" => "suicide",
	"singLEFT-g3" => "rewrite",
	"singDOWN-g3" => "scrimbo",
	"singUP-g3" => "mario",
	"singRIGHT-g3" => "hypno"
];

var bfIcons:Map<String, String> = [
	"idle-mb-g1" => "encore",
	"singLEFT-mb-g1" => "hypno",
	"singDOWN-mb-g1" => "corruption",
	"singUP-mb-g1" => "soft",
	"singRIGHT-mb-g1" => "dside",

	"idle-mb-g2" => "doki",
	"singLEFT-mb-g2" => "normal",
	"singDOWN-mb-g2" => "funkadelix",
	"singUP-mb-g2" => "b3",
	"singRIGHT-mb-g2" => "static",

	"idle-mb-alt-g" => "normal",
	"singLEFT-mb-alt-g" => "minus",
	"singDOWN-mb-alt-g" => "suicide",
	"singUP-mb-alt-g" => "madness",
	"singRIGHT-mb-alt-g" => "ihy"
];

var illegalInstruction1:FlxBackdrop;
var illegalInstruction2:FlxBackdrop;
var _isAttacking:Bool = false;
function onCreate()
{
	if (Paths.formatToSongPath(PlayState.SONG.song) == 'manual-blast') isManualBlast = true;

	if (isManualBlast)
	{
		illegalInstruction1 = new FlxBackdrop(Paths.image('bg/evil/illegalinstruction'), 0x11, 36, 14);
		illegalInstruction1.color = 0xFF000000;
		illegalInstruction1.scrollFactor.set();
		illegalInstruction1.antialiasing = false;
		illegalInstruction1.alpha = 0;
		illegalInstruction1.velocity.set(250, 100);
		illegalInstruction1.scale.set(2.5, 2.5); illegalInstruction1.updateHitbox();
		insert(0, illegalInstruction1);

		illegalInstruction2 = new FlxBackdrop(Paths.image('bg/evil/illegalinstruction'), 0x11, 36, 14);
		illegalInstruction2.color = 0xFF000000;
		illegalInstruction2.scrollFactor.set();
		illegalInstruction2.antialiasing = false;
		illegalInstruction2.alpha = 0;
		illegalInstruction2.velocity.set(200, 100);
		illegalInstruction2.y += 35;
		illegalInstruction2.scale.set(2.5, 2.5); illegalInstruction2.updateHitbox();
		insert(0, illegalInstruction2);
	}

	gf.scrollFactor.set(1, 1);
	makeBackground(hogBG);

	if (isManualBlast)
	{
		makeBackground(scorchedBG);
		for (spr in scorchedBG) spr.sprite.alpha = 0;
		hogBG[7].sprite.animation.play('creepy', true);
	}
	else
	{
		glitchBG = new FlxSprite(-930, -920).loadGraphic(Paths.image('bg/normal/bgg'));
		glitchBG.alpha = 0.0001;
		insert(0, glitchBG);
		glitchFG = new FlxSprite(-930, -920).loadGraphic(Paths.image('bg/normal/fgg'));
		glitchFG.alpha = 0.0001;
		add(glitchFG);
	}
	
	vignette = new FlxSprite().loadGraphic(Paths.image('VG'));
	vignette.color = 0xFF000000;
	vignette.camera = camOther;
	vignette.alpha = 0.6;
	add(vignette);

	topBar = new FlxSprite(-50, -100).makeGraphic(FlxG.width + 100, 100, 0xFF000000);
	topBar.camera = camVideo;
	insert(0, topBar);

	botBar = new FlxSprite(-50, FlxG.height).makeGraphic(FlxG.width + 100, 100, 0xFF000000);
	botBar.camera = camVideo;
	insert(0, botBar);

	spacebar = new FlxSprite(0, FlxG.height * (prefs.downScroll ? 0.6 : 0.2));
	spacebar.frames = Paths.getSparrowAtlas('spacebar');
	spacebar.animation.addByPrefix('idle', 'Símbolo 8', 48, false); spacebar.animation.play('idle', true);
	spacebar.scale.set(0.6, 0.6); spacebar.updateHitbox();
	spacebar.camera = camHUD;
	spacebar.screenCenter(0x01);
	spacebar.alpha = 0.0001;
	add(spacebar);

	if (isManualBlast)
	{
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackScreen.scrollFactor.set();
		blackScreen.screenCenter();
		blackScreen.alpha = 0.0001;
		add(blackScreen);
	}

	//handle shaders vvvvvvvvvvvv xd

	for (c in shaderChars)
	{
		if (c.tag == 'tails' && c.char == null) c.char = hogBG[9].sprite;
		if (c.tag == 'knux' && c.char == null) c.char = hogBG[10].sprite;
		final char:Character = c.char;
		var dropShadow:ErrorHandledRuntimeShader = new ErrorHandledRuntimeShader('DropShadowShader', File.getContent(Paths.shaderFragment('DropShadowShader')));
		dropShadow.setFloat('hue', 0);
		dropShadow.setFloat('brightness', 0);
		dropShadow.setFloat('contrast', 0);
		dropShadow.setFloat('saturation', 0);
		dropShadow.setFloat('str', 1);
		dropShadow.setFloat('dist', 0);
		dropShadow.setFloat('thr', 0.1);
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

	hogBG[9].sprite.offset.set(0, 0);

	bloom.shader = new ErrorHandledRuntimeShader('brightness', File.getContent(Paths.shaderFragment('brightness')));
	bloom.defaultConfig = ['saturation' => 1, 'brightness' => 0, 'contrast' => 1]; //sucks
	bloom.config = ['saturation' => 1, 'brightness' => 0, 'contrast' => 1];
	bloom.configOffset = ['saturation' => 0, 'brightness' => 0, 'contrast' => 0]; //sucks
	bloom.shaderTweens = [];

	aberration.shader = new ErrorHandledRuntimeShader('chromabber', File.getContent(Paths.shaderFragment('chromabber')));
	aberration.shader.setFloat('amount', aberration.config.get('amount'));
	aberration.shaderTweens = [];

	if (!isManualBlast)
	{
		chromatic.shader = new ErrorHandledRuntimeShader('chromatic', File.getContent(Paths.shaderFragment('chromatic')));
		chromatic.shader.setFloatArray('rOffset', [0, 0]);
		chromatic.shader.setFloatArray('gOffset', [0, 0]);
		chromatic.shader.setFloatArray('bOffset', [0, 0]);

		glitch.shader = new ErrorHandledRuntimeShader('glitchChromatic', File.getContent(Paths.shaderFragment('glitchChromatic')));
		camGame.filters = camHUD.filters = [new ShaderFilter(aberration.shader), new ShaderFilter(bloom.shader), new ShaderFilter(chromatic.shader), new ShaderFilter(glitch.shader)];
	}
	else
	{
		smear.shader = new ErrorHandledRuntimeShader('smear', File.getContent(Paths.shaderFragment('smear')));

		glitch2.shader = new ErrorHandledRuntimeShader('glitchb', File.getContent(Paths.shaderFragment('glitchb')));
		glitch2.shader.setFloatArray('iResolution', [FlxG.width, FlxG.height]);
		glitch2.shader.setFloat('Amount', 0);

		camGame.filters = camHUD.filters = [new ShaderFilter(aberration.shader), new ShaderFilter(bloom.shader)];
	}
}

var glitchOppIcon:HealthIcon;
var glitchBFIcon:HealthIcon;

var _particleGroup:Array<RollEmber> = [];
function onCreatePost()
{
	for (i in 0...4)
	{
		notesPosition[0][i][0] = opponentStrums.members[i].x; notesPosition[1][i][0] = playerStrums.members[i].x;
		notesPosition[0][i][1] = opponentStrums.members[i].y; notesPosition[1][i][1] = playerStrums.members[i].y;
	}

	if (isManualBlast)
	{
		dad.idleSuffix = '-alt';
		dad.recalculateDanceIdle();
		for (i in 0...game.unspawnNotes.length)
		{
			final note:Note = game.unspawnNotes[i];
			if (!note.mustPress && note.strumTime <= 60000) note.animSuffix = '-alt';

			if (note.mustPress && note.strumTime > 60000)
			{
				if (note.animSuffix == '-alt') note.animSuffix = '-mb-alt';
				else note.animSuffix = '-mb';
			}
		}
	}

	for (i in 0...75)
	{
		final big = FlxG.random.bool(30);
		final e = new FlxSprite().loadGraphic(Paths.image('bg/evil/logo'));
		e.setGraphicSize(big ? 30 : 15, big ? 30 : 15); e.updateHitbox();
		e.active = false;
		e.visible = false;
		e.scrollFactor.set(FlxG.random.float(0.5, 1.5), FlxG.random.float(0.5, 1.5));
		e.setPosition(FlxG.random.float(-1100, 2500), FlxG.random.float(-850, 800));
		insert(game.members.indexOf(scorchedBG[6].sprite), e);
		_particleGroup.push({spr: e, vy: FlxG.random.float(big ? 30 : 12, big ? 60 : 30), phase: FlxG.random.float(0, Math.PI * 2), sway: FlxG.random.float(6, 22), base: e.x});
	}

	glitchOppIcon = new HealthIcon('lordx', false);
	glitchOppIcon.alpha = 0;
	glitchOppIcon.camera = camHUD;
	add(glitchOppIcon);

	glitchBFIcon = new HealthIcon('encore', false);
	glitchBFIcon.alpha = 0;
	glitchBFIcon.camera = camHUD;
	add(glitchBFIcon);
}

var animationOffsets:Map<String, Map<String, Array<Float>>> = [
	'tails' => [
		'idle' => [0, 0],
		'evilidle' => [0, -90],
		'evilidleg1' => [0, -16],
		'evilidleg2' => [0, -36],
		'evilidleg3' => [0, -52]
	],
	'knux' => [
		'normalidle' => [0, 0],
		'evilidle' => [-30, 200],
		'evilidleg1' => [-21, 312],
		'evilidleg2' => [9, 242],
		'evilidleg3' => [-30, 214]
	]
];

var _idleSuffix:String = '';
function onBeatHit()
{
	for (spr in hogBG)
	{
		if ((spr.tag == 'tails' || spr.tag == 'knux') && curBeat % 2 == 0 && spr.sprite != null)
		{
			var anim:String = 'normalidle' + (spr.tag == 'tails' ? _idleSuffix : '');
			if (songPhase == 'evil') anim = 'evilidle';
			if (songPhase == 'glitch') anim = 'evilidleg' + FlxG.random.int(1,3);

			spr.sprite.animation.play(anim, true);
			if (animationOffsets.exists(spr.tag) && animationOffsets.get(spr.tag).exists(anim)) {
				var offset = animationOffsets.get(spr.tag).get(anim);
				spr.sprite.offset.set(offset[0], offset[1]);
			}
			else spr.sprite.offset.set(0, 0);
		}

		if (songPhase == 'glitch' && curBeat % 2 == 0)
		{
			scorchedBG[5].sprite.animation.play('exes' + FlxG.random.int(1,2), true);
		}
	}

	if (curBeat % 2 == 0 && spacebar != null && spacebar.alpha >= 0.5) spacebar.animation.play('idle', true);

	if (songPhase == 'glitch' && FlxG.random.bool(35))
	{
		var illegal = new FlxSprite().loadGraphic(Paths.image('bg/evil/illegalinstruction'));
		illegal.antialiasing = false;
		illegal.camera = camHUD;
		illegal.setPosition(FlxG.random.int(0, FlxG.width - illegal.width), FlxG.random.int(0, FlxG.height - illegal.height));
		add(illegal);
		new FlxTimer().start(2, _ -> illegal.destroy());
	}
}

var _suffix:Array<String> = [];
var _sine:Float = 0;
function onUpdatePost(e:Float)
{
	_sine += e;
	bloom.shader.setFloat('saturation', bloom.config.get('saturation') + bloom.configOffset.get('saturation'));
	bloom.shader.setFloat('brightness', bloom.config.get('brightness') + bloom.configOffset.get('brightness'));
	bloom.shader.setFloat('contrast', bloom.config.get('contrast') + bloom.configOffset.get('contrast'));

	if (_isAttacking)
	{
		if (FlxG.keys.justPressed.SPACE && boyfriend.getAnimationName() != 'dodge' && !game.cpuControlled)
		{
			spacebar.alpha = 0;
			boyfriend.playAnim('dodge', true);
			boyfriend.specialAnim = true;
		}
	}

	if (!dad.isAnimationNull() && dad.getAnimationName().startsWith('attack') && dad.isAnimationFinished())
	{
		game.remove(dadGroup, true);
		game.insert(game.members.indexOf(game.boyfriendGroup), dadGroup);
	}

	if (songPhase == 'normal')
	{
		if (!isManualBlast) glitch.shader.setFloat('iTime', _sine);

		final progress:Float = FlxMath.bound(Conductor.songPosition / (197142.857142857 - (Conductor.crochet * 12)), 0, 1);
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

	if (songPhase == 'glitch')
	{
		for (i in 0...notes.length)
		{
			var note:Note = notes.members[i];

			if (note.mustPress)
			{
				if (note.animSuffix == _suffix[0]) continue;
				var dasuffix:String = _suffix[0];
				if (note.animSuffix == '-mb-alt') dasuffix = '-mb-alt-g';
				note.animSuffix = dasuffix;
			}
			else 
			{
				if (note.animSuffix == _suffix[1]) continue;
				note.animSuffix = _suffix[1];
			}
		}

		hogBG[7].sprite.shader.setFloat('iTime', _sine);
		for (spr in scorchedBG)
		{
			spr.sprite.shader.setFloat('iTime', _sine);
		}

		glitch2.config.set('amount', FlxMath.lerp(glitch2.config.get('amount'), 0.1, 5 * e));
		glitch2.shader.setFloat('Amount', glitch2.config.get('amount'));
		smear.shader.setFloat('amount', FlxG.random.float(0, 0.075));
		smear.shader.setFloat('angle', FlxG.random.float(0, 2));
		glitch2.shader.setFloat('iTime', _sine);

		var oppicon = game.getLuaObject('iconOpp');
		glitchOppIcon.setPosition(oppicon.x + FlxG.random.int(-3, 3), oppicon.y + FlxG.random.int(-3, 3));
		glitchOppIcon.angle = FlxG.random.int(-3, 3);
		glitchOppIcon.scale.set(oppicon.scale.x, oppicon.scale.y);

		var bficon = game.getLuaObject('iconBF');
		glitchBFIcon.setPosition(bficon.x + FlxG.random.int(-3, 3), bficon.y + FlxG.random.int(-3, 3));
		glitchBFIcon.angle = FlxG.random.int(-3, 3);
		glitchBFIcon.scale.set(bficon.scale.x, bficon.scale.y);
	}

	for (h in _particleGroup)
	{
		if (h.spr == null) continue;
		h.phase += e * 6;
		h.spr.y -= h.vy * e * 6;
		h.spr.x = h.base + Math.sin(h.phase * 0.9) * h.sway;
		h.spr.alpha = 0.5 + 0.3 * Math.sin(h.phase * 2.3);
		if (h.spr.y < -850)
		{
			h.spr.y = 800 + FlxG.random.float(5, 60);
			h.base = FlxG.random.float(-1100, 2500);
		}
	}

	if (isManualBlast && blackScreen != null && blackScreen.alpha > 0.001) blackScreen.scale.set(1 / camGame.zoom, 1 / camGame.zoom);

	hogBG[9].sprite.setPosition(
		hogBG[9].position[0] + Math.cos(_sine) * 30,
		hogBG[9].position[1] + Math.sin(_sine * 2) * 15
	);
}

//hedge vars
var modchartStyle:Int = -1;
var _isGlitch:Bool = false;
var _xdd:Bool = false;
function onEvent(n,v1,v2)
{
	if (n == 'bright zoom' && prefs.flashing)
	{
		if (bloom.shaderTweens['bloom']?.active ?? false) bloom.shaderTweens['bloom'].cancel();

		var oneSplit:Array<String> = v1.split(',');
		var fromValue:Float = (Math.isNaN(Std.parseFloat(oneSplit[0])) ? 0.15 : Std.parseFloat(oneSplit[0]));
		var toValue:Float = (Math.isNaN(Std.parseFloat(oneSplit[1])) ? 0 : Std.parseFloat(oneSplit[1]));

		var twoSplit:Array<String> = v2.split(',');
		var duration:Float = (Math.isNaN(Std.parseFloat(twoSplit[0])) ? 4 : Std.parseFloat(twoSplit[0]));
		var ease:String = (twoSplit[1] == null || twoSplit[1] == '') ? 'cubeOut' : twoSplit[1];

		bloom.shaderTweens['bloom'] = FlxTween.num(fromValue, toValue, Conductor.crochet / (1000 / duration), {ease: LuaUtils.getTweenEaseByString(ease)}, v -> {
			bloom.config.set('brightness', bloom.defaultConfig.get('brightness') + v * 2);
			bloom.config.set('contrast', bloom.defaultConfig.get('contrast') + (v * 4));
		});

		if (aberration.shaderTweens['abb']?.active ?? false) aberration.shaderTweens['abb'].cancel();
		
		aberration.shaderTweens['abb'] = FlxTween.num(fromValue, toValue, Conductor.crochet / (1000 / duration), {ease: LuaUtils.getTweenEaseByString(ease)}, v -> {
			aberration.shader.setFloat('amount', aberration.defaultConfig.get('amount') + v * 2);
		});
	}

	if (n == 'attack')
	{
		var target:FlxSprite = new FlxSprite(boyfriend.x + 450, boyfriend.y + 250);
		target.frames = Paths.getSparrowAtlas('TargetLock');
		target.animation.addByPrefix('idle', 'TargetLock', 24, false); target.animation.play('idle', true);
		FlxTween.tween(target, {angle: 180}, Conductor.crochet / 500, {ease: FlxEase.cubeOut, onComplete: () -> {
			target.colorTransform.color = 0xFFFF0000;
			new FlxTimer().start(Conductor.stepCrochet / 1500, t -> target.colorTransform.color = (t.loopsLeft % 2 == 0 ? 0xFFFF0000 : 0xFF00FF00), 10);
		}});
		add(target);

		new FlxTimer().start(Conductor.stepCrochet / (1000 / 6), _ -> {
			spacebar.alpha = 1;
			spacebar.animation.play('idle', true);
			_isAttacking = true;

			new FlxTimer().start(Conductor.stepCrochet / (1000 / 2), _ -> {
				if (!dad.getAnimationName().startsWith('attack'))
				{
					dad.playAnim('attack' + dad.idleSuffix, true);
					dad.specialAnim = true;
				}
				game.remove(dadGroup, true);
				game.insert(game.members.indexOf(boyfriendGroup) + 1, dadGroup);

				new FlxTimer().start(Conductor.stepCrochet / (1000 / 8), _ -> {
					_isAttacking = false;
					if (boyfriend.getAnimationName() != 'dodge' && !game.cpuControlled)
					{
						game.health = -5;
					}
					if (game.cpuControlled)
					{
						boyfriend.playAnim('dodge', true);
						boyfriend.specialAnim = true;
					}
					target.destroy();
					spacebar.alpha = 0;
				});
			});
		});
	}

	if (n == 'ghhcselol')
	{
		if (!isManualBlast)
		{
			_isGlitch = !_isGlitch;

			glitch.shader.setFloat('GLITCH', _isGlitch ? 1 : 0);
			for (spr in hogBG) if (spr.tag != 'tails' && spr.tag != 'knux') spr.sprite.visible = !_isGlitch;
			glitchFG.alpha = _isGlitch ? 1 : 0.0001;
			glitchBG.alpha = _isGlitch ? 1 : 0.0001;

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
		if (songPhase != 'intro') return;
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

			//manual blast events here vvvvvvvvv

			case 'mbstart':
				_idleSuffix = '1';
				songPhase = 'transform';
				FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / 250);
			case 'tails1': _idleSuffix = '2';
			case 'tails2': _idleSuffix = '3';
			case 'tails3': _idleSuffix = '4';
			case 'fadeinmb':
				FlxTween.tween(vignette, {alpha: 0.8}, Conductor.crochet / 250);
				FlxTween.tween(blackScreen, {alpha: 1}, Conductor.crochet / 250);
			case 'darkflash':
				FlxTween.cancelTweensOf(blackScreen);
				blackScreen.alpha = 0;
				FlxTween.tween(blackScreen, {alpha: 1}, Conductor.crochet / 1000);
			case 'darkflashalt':
				FlxTween.cancelTweensOf(blackScreen);
				blackScreen.alpha = 0;
				FlxTween.tween(blackScreen, {alpha: 1}, Conductor.crochet / 250);
			case 'updateidles':
				_idleSuffix = '';
				songPhase = 'evil';

				boyfriend.idleSuffix = '-mb';
				boyfriend.recalculateDanceIdle();

				gf.idleSuffix = '-g';
				gf.recalculateDanceIdle();
				game.remove(hogBG[7].sprite, true);
				game.insert(game.members.indexOf(scorchedBG[5].sprite) + 1, hogBG[7].sprite);
				game.remove(hogBG[9].sprite, true);
				game.insert(game.members.indexOf(scorchedBG[6].sprite) + 1, hogBG[9].sprite);
				hogBG[7].sprite.animation.play('evil', true);
				hogBG[7].sprite.setPosition(hogBG[7].sprite.x + 50, hogBG[7].sprite.y - 50);

				for (spr in hogBG)
				{
					if (spr.tag != null) continue;
					spr.sprite.destroy();
					spr.sprite = null;
					spr = null;
				}
				hogBG[12].sprite.alpha = 0;
				for (spr in scorchedBG) spr.sprite.alpha = spr.alpha ?? 1;

				bloom.defaultConfig = ['saturation' => 1, 'brightness' => -0.05, 'contrast' => 1.03];
				bloom.config = ['saturation' => 1, 'brightness' => -0.05, 'contrast' => 1.03];

				bloom.configOffset = ['saturation' => 0, 'brightness' => 0, 'contrast' => 0];

				scorchedBG[5].sprite.alpha = 0;

				hogBG[9].sprite.shader = null;
				hogBG[10].sprite.shader = null;
				gf.shader = null;
				dad.shader = null;
				boyfriend.shader = null;
			case 'mbscorched':
				FlxTween.cancelTweensOf(camHUD);
				FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 250);
				FlxTween.cancelTweensOf(blackScreen);
				FlxTween.tween(blackScreen, {alpha: 0}, Conductor.crochet / 250);
			case 'newcampositions':
				cam.DADx = 400;
				cam.DADy = -200;
				cam.OffsetsDAD = 50;
				cam.DADAngle = 1.5;
				cam.OGZoom = 0.47;
				cam.MiddleX = 600;
				cam.MiddleY = 150;
				cam.MiddleZoom = 0.4;
				camGame.zoom = 0.47;
				
				cam.BFx = 900;
				cam.BFy = 350;

				cam.OverrideZoom = false;
			case 'm1xd':
				
			case 'g2xd':
				_xdd = true;
			case 'g3xd':
				for (e in _particleGroup) if (FlxG.random.bool(15)) e.spr.visible = true;
			case 'aayaay':
				if (aberration.shaderTweens['abb']?.active ?? false) aberration.shaderTweens['abb'].cancel();
		
				aberration.shaderTweens['abb'] = FlxTween.num(0, 1, Conductor.crochet / (1000 / 10), {ease: FlxEase.cubeIn}, v -> {
					aberration.shader.setFloat('amount', aberration.defaultConfig.get('amount') + v * 2);
				});
			case 'preglitch':
				camHUD.fade(0x75FFFFFF, Conductor.crochet / 250, false, null, true);
			case 'worlddying':
				camHUD.fade(0x00FFFFFF, 0.0001, false, null, true);
				camHUD.flash(0xFFFFFFFF, 2, null, true);
				debugPrint('[ILLEGAL INSTRUCTION] THE ENVIRONMENT IS CORRUPTED AND IS BEING PREPARED FOR ELIMINATION.', 0xFFFF0000);
				songPhase = 'glitch';
				camGame.bgColor = 0xFFFFFFFF;
				camGame.filters = camHUD.filters = [new ShaderFilter(aberration.shader), new ShaderFilter(bloom.shader), new ShaderFilter(smear.shader), new ShaderFilter(glitch2.shader)];
				for (e in _particleGroup) e.spr.visible = true;
				scorchedBG[5].sprite.alpha = 1;

				applyPseudoGlitch(hogBG[7].sprite, 'hog');
				for (i in 0...scorchedBG.length)
					applyPseudoGlitch(scorchedBG[i].sprite, 'scorched' + i);

				hogBG[12].sprite.color = 0xFFFFFFFF;
				hogBG[12].sprite.scale.set(2, 1.5);
				hogBG[12].sprite.y -= 300;

				//this might be the WORST code ever LMAO 🗣️🗣️🗣️🗣️🗣️🗣️🗣️
			case 'delete1':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/sky.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[12].sprite, {alpha: 0.2}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(scorchedBG[0].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched0', v));
				FlxTween.tween(illegalInstruction1, {alpha: 1}, 30);
				FlxTween.tween(illegalInstruction2, {alpha: 1}, 30);

			case 'delete2':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/mountains.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[12].sprite, {alpha: 0.4}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(scorchedBG[1].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched1', v));
				FlxTween.tween(scorchedBG[4].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched4', v));

			case 'delete3':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/prowler.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[9].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(hogBG[9].sprite.scale, {x: 2, y: 0.0001}, Conductor.crochet / (1000 / 8), null);

			case 'delete4':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/waterfalls.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(scorchedBG[2].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched2', v));
				FlxTween.tween(scorchedBG[3].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched3', v));

			case 'delete5':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/hills.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[12].sprite, {alpha: 0.6}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(hogBG[7].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('hog', v));

				FlxTween.tween(scorchedBG[5].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(scorchedBG[5].sprite.scale, {x: 2, y: 0.0001}, Conductor.crochet / (1000 / 8), null);
			case 'delete6':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/fists.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[10].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(hogBG[10].sprite.scale, {x: 2, y: 0.0001}, Conductor.crochet / (1000 / 8), null);

			case 'delete7':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/foreground.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[12].sprite, {alpha: 0.75}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(scorchedBG[7].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched6', v));

			case 'delete8':
				debugPrint('[WARNING] ASSET "assets/shared/images/characters/unofficialGF/spritemap1.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(gf, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(gf.scale, {x: 2, y: 0.0001}, Conductor.crochet / (1000 / 8), null);

			case 'delete9':
				debugPrint('[WARNING] ASSET "contents/HOG/images/bg/hedge/floor.webp" MAY BE CORRUPTED. PREPARING FOR ITS REMOVAL.', 0xFFFF0000);
				FlxTween.tween(hogBG[12].sprite, {alpha: 1}, Conductor.crochet / (1000 / 8));
				FlxTween.tween(scorchedBG[6].sprite, {alpha: 0}, Conductor.crochet / (1000 / 8));
				FlxTween.num(0, 5, Conductor.crochet / (1000 / 8), null, v -> setPseudoSort('scorched5', v));

			case 'delete10':
				for (e in _particleGroup) e.spr.visible = false;
				debugPrint('[WARNING] THE ENVIRONMENT IS COMPLETELY CORRUPTED; THE ELIMINATION OF THE CODE BEGINS.', 0xFFFF0000);
				FlxTween.tween(hogBG[12].sprite, {alpha: 0}, Conductor.crochet / (1000 / 16));
				FlxTween.tween(camHUD, {alpha: 0}, Conductor.crochet / (1000 / 12));
				FlxTween.tween(dadGroup, {alpha: 0}, Conductor.crochet / (1000 / 12));
				FlxTween.tween(boyfriendGroup, {alpha: 0}, Conductor.crochet / (1000 / 12));

			case 'scoretxt': game.getLuaObject('exeScoreTxt').alpha = 0;
			case 'hbbg': game.getLuaObject('healthBG').alpha = 0;
			case 'hbtrue': game.getLuaObject('hbBG').alpha = 0;
			case 'combo': game.comboGroup.visible = false;
			case 'separator': game.getLuaObject('separatorHealth').alpha = 0;
			case 'leftbar': game.getLuaObject('hbHealth2').alpha = 0;
			case 'rightbar': game.getLuaObject('hbHealth').alpha = 0;
			case 'scorchedicon': game.getLuaObject('iconOpp').alpha = 0;
			case 'bficon': game.getLuaObject('iconBF').alpha = 0;
		}
	}
}

var pseudoShaders:Array<{id:String, shader:ErrorHandledRuntimeShader}> = [];

function applyPseudoGlitch(spr:FlxSprite, id:String)
{
	var shader = new ErrorHandledRuntimeShader(
		'manualblastglitching',
		File.getContent(Paths.shaderFragment('manualblastglitching'))
	);

	shader.setFloat('sort', 0);
	spr.shader = shader;
	pseudoShaders.push({id: id, shader: shader});
}

function setPseudoSort(id:String, value:Float)
{
	for (entry in pseudoShaders)
	{
		if (entry.id == id)
		{
			entry.shader.setFloat('sort', value);
			return;
		}
	}
}

function goodNoteHitPre(note)
{
	if (boyfriend.getAnimationName() == 'dodge' && _isAttacking)
	{
		note.noAnimation = true;
		note.noMissAnimation = true;
	}

	if (songPhase != 'glitch' && FlxG.random.bool(35) && note.noteType == 'Glitch Anim' && !note.isSustainNote)
	{
		var illegal = new FlxSprite().loadGraphic(Paths.image('bg/evil/illegalinstruction'));
		illegal.antialiasing = false;
		illegal.camera = camHUD;
		illegal.setPosition(FlxG.random.int(0, FlxG.width - illegal.width), FlxG.random.int(0, FlxG.height - illegal.height));
		add(illegal);
		new FlxTimer().start(2, _ -> illegal.destroy());
	}
}

function opponentNoteHitPre(note)
{
	if (!dad.isAnimationNull() && dad.getAnimationName().startsWith('attack') && Conductor.songPosition <= 60000)
	{
		note.noAnimation = true;
	}

	if (songPhase != 'glitch' && FlxG.random.bool(35) && note.noteType == 'Glitch Anim' && !note.isSustainNote)
	{
		var illegal = new FlxSprite().loadGraphic(Paths.image('bg/evil/illegalinstruction'));
		illegal.antialiasing = false;
		illegal.camera = camHUD;
		illegal.setPosition(FlxG.random.int(0, FlxG.width - illegal.width), FlxG.random.int(0, FlxG.height - illegal.height));
		add(illegal);
		new FlxTimer().start(2, _ -> illegal.destroy());
	}
}

function goodNoteHit(note)
{
	if (songPhase == 'glitch' && !note.isSustainNote)
	{
		glitch2.config.set('amount', 0.25);

		FlxTween.cancelTweensOf(glitchBFIcon);
		glitchBFIcon.alpha = 0.75;
		glitchBFIcon.changeIcon('bf/' + bfIcons[boyfriend.getAnimationName()]);
		FlxTween.tween(glitchBFIcon, {alpha: 0}, 1);
	}

	if (note.noteType == 'Red Ring' || note.noteType == 'Yellow Ring') unlockRingAchievement = false;
}

function opponentNoteHit(note)
{
	if (songPhase == 'glitch' && !note.isSustainNote)
	{
		FlxTween.cancelTweensOf(glitchOppIcon);
		glitchOppIcon.alpha = 0.75;
		glitchOppIcon.changeIcon('opp/' + oppIcons[dad.getAnimationName()]);
		FlxTween.tween(glitchOppIcon, {alpha: 0}, 1);
	}
}

var _oldMHS:Bool = false;
function onSectionHit()
{
	if (songPhase == 'evil' && _oldMHS != mustHitSection && !tweenCamZoom)
	{
		game.triggerEvent("Tween Camera Zoom", mustHitSection ? "0.7" : "0.47", "");
		//cam.OGZoom = mustHitSection ? 0.7 : 0.47;
	}
	_oldMHS = mustHitSection;

	if (_xdd && curSection % 2 == 0)
	{
		var suffix:String = 'needle';
		switch(FlxG.random.int(0,4))
		{
			case 0: suffix = 'needle';
			case 1: suffix = 'fatal';
			case 2: suffix = 'starved';
			case 3: suffix = 'nmi';
			case 4: suffix = 'devoid';
		}
		hogBG[7].sprite.animation.play(suffix, true);
	}

	if (songPhase == 'glitch')
	{
		glitch2.config.set('amount', 0.4);

		gf.skipDance = true;
		gf.playAnim('idle-alt' + FlxG.random.int(1,9), true);
		gf.specialAnim = true;

		boyfriend.idleSuffix = (curSection % 3 == 0 ? '-mb-g1' : (curSection % 3 == 1 ? '-mb-g2' : '-mb-alt-g'));
		boyfriend.recalculateDanceIdle();
		if (boyfriend.getAnimationName().startsWith('idle'))
		{
			boyfriend.dance();

			FlxTween.cancelTweensOf(glitchBFIcon);
			glitchBFIcon.alpha = 0.75;
			glitchBFIcon.changeIcon('bf/' + bfIcons[boyfriend.getAnimationName()]);
			FlxTween.tween(glitchBFIcon, {alpha: 0}, 1);
		}
		

		dad.idleSuffix = (curSection % 3 == 0 ? '-g1' : (curSection % 3 == 1 ? '-g2' : '-g3'));
		dad.recalculateDanceIdle();
		if (dad.getAnimationName().startsWith('idle'))
		{
			dad.dance();

			FlxTween.cancelTweensOf(glitchOppIcon);
			glitchOppIcon.alpha = 0.75;
			glitchOppIcon.changeIcon('opp/' + oppIcons[dad.getAnimationName()]);
			FlxTween.tween(glitchOppIcon, {alpha: 0}, 1);
		}

		_suffix = [
			(curSection % 2 == 0 ? '-mb-g1' : '-mb-g2'),
			(curSection % 3 == 0 ? '-g1' : (curSection % 3 == 1 ? '-g2' : '-g3'))
		];
	}
}

function setShaderFrameInfo(obj:String) {
	var char:FlxSprite;
	switch(obj) {
		case 'bf': char = game.boyfriend;
		case 'dad': char = game.dad;
		case 'gf': char = game.gf;
		case 'tails': char = hogBG[9].sprite;
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

function onDestroy() FlxG.camera.bgColor = 0x0;
function onGameOverStart() FlxG.camera.bgColor = 0x0;
function onEndSong() if(unlockRingAchievement) EXEAchievements.unlock('norings');