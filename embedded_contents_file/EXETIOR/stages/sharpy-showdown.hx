import objects.Character;

using StringTools;

var stage:Array<BackgroundSprite> = [
	{path: 'SS/bg', position: [-1690, -1500], scale: [1.35, 1.35], scroll: [0.8, 0.8]},
	{path: 'SS/floor', position: [-2100, 545], scale: [1.7, 1.7]},
	{path: 'SS/arch', position: [-1180, -840], scale: [1.35, 1.35]},
	{path: 'SS/tv', position: [-280, -850], scale: [1.35, 1.35]},
	{path: 'SS/simulation-error', position: [-440, -870], scale: [1.05, 1.05], animation: [{name: 'simulation-error error', looped: true}]},
	{path: 'characters/k', tag: 'knux', scale: [1.9, 1.9], position: [-1550, -670], isAtlas: true, animation: [{name: 'knuxx'}]},
	{path: 'characters/tails', tag: 'tails', scale: [1.1, 1.1], position: [1020, -690], isAtlas: true, animation: [{name: 'tails'}]},
	{path: 'characters/eggman', tag: 'eggman', scale: [1.7, 1.7], position: [-1080, -50], isAtlas: true, animation: [{name: 'eggman', indices: [9,10,11,12,13,0,1,2,3,4,5,6,7,8]}]},
	{path: 'SS/crystal-walls', position: [-1550, -1200], scale: [1.1, 1.25], scroll: [1.3, 1.3], front: true},
];

var dark:Array<BackgroundSprite> = [
	{path: 'characters/exe1', tag: 'exe1', position: [60, 0], scale: [0.65, 0.65], scroll: [0.8, 0.8], animation: [{name: 'idle'}]},
	{path: 'SS/2nd/spotlight', position: [-820, 600], scale: [0.9, 1.5]},
	{path: 'SS/2nd/lights', position: [-900, -820], scale: [0.65, 0.75], blend: 'add', front: true},
	{path: 'characters/exeller', tag: 'exeller', position: [1000, 50], scroll: [1.3, 1.3], animation: [{name: 'Símbolo 23'}], front: true},
	{path: 'characters/sark', tag: 'sark', position: [-1800, -80], scroll: [1.3, 1.3], animation: [{name: 'sark'}], front: true}
];

var exeeye:FlxSprite;
var overlay:FlxSprite;
var bfDark:Character;
function onCreatePost()
{
	gf.scrollFactor.set(1, 1);
	makeBackground(stage);
	makeBackground(dark);
	for (spr in dark) spr.sprite.alpha = 0;
	for (spr in stage) if (spr.tag == 'eggman') spr.sprite.ID = 123;

	exeeye = new FlxSprite(170, 140).loadGraphic(Paths.image('characters/ojo-exe1'));
	exeeye.scrollFactor.set(0.8, 0.8);
	exeeye.scale.set(0.45, 0.45);
	exeeye.updateHitbox();
	exeeye.alpha = 0;
	game.add(exeeye);

	overlay = new FlxSprite().loadGraphic(Paths.image('VG'));
	overlay.color = 0xFF000000;
	overlay.camera = camHUD;
	overlay.screenCenter();
	overlay.alpha = 0;
	game.add(overlay);

	bfDark = new Character(boyfriend.x, boyfriend.y, 'bfd', true);
	bfDark.alpha = 0;
	game.add(bfDark);
}

final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'exeScoreTxt', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG'];
function onEvent(n,v1,v2)
{
	if (n == 'ssStageEvents')
	{
		switch(v1)
		{
			case 'part2':
				for (spr in stage) spr.sprite.alpha = 0;
				for (spr in dark) spr.sprite.alpha = 1;
				exeeye.alpha = 1;
				gf.alpha = 0;
			case 'hide':
				for (spr in dark) spr.sprite.alpha = 0;
				exeeye.alpha = 0;
				dad.alpha = 0;
				boyfriend.alpha = 0;
			case 'si': 
			case 'hideHUD':
				for (spr in hudSprites) FlxTween.tween(game.getLuaObject(spr), {alpha: (v2 == 'true' ? 1 : 0)}, 1.2);
				for (i in 0...8) FlxTween.tween(strumLineNotes.members[i], {alpha: (v2 == 'true' ? 1 : 0)}, 1.2);
			case 'noteTween':
				FlxTween.tween(strumLineNotes.members[Std.int(v2)], {alpha: 0.5}, 1.2);
			case 'tweenCharacter':
				if (v2 == 'dad')
				{
					FlxTween.tween(dad, {alpha: 1}, 0.5);
				}
				else if (v2 == 'bfX')
				{
					FlxTween.tween(bfDark, {alpha: 1}, 1);
				}
				else if (v2 == 'bf')
				{
					FlxTween.tween(boyfriend, {alpha: 1}, 1);
					FlxTween.tween(bfDark, {alpha: 0}, 1);
				}
			case 'part1':
				for (spr in stage) spr.sprite.alpha = 1;
				gf.alpha = 1;
			case 'tweenObject':
				var split = v2.split(', ');
				FlxTween.tween(camHUD, {alpha: Std.parseFloat(split[1])}, Std.parseFloat(split[2]));
		}
	}
}

var _eyeLerp:Float = 0;
var _target:Float = 0;
var eyeOffset:Array<Float> = [0, 0];
var _sine:Float = 0;
function onUpdatePost(e)
{
	if (bfDark != null && bfDark.alpha != 0) bfDark.update();
	for (spr in dark) if (spr.sprite != null && spr.tag == 'exe1' && spr.sprite.alpha != 0)
	{
		_sine += e;
		_eyeLerp = FlxMath.lerp(_eyeLerp, _target, e * 15);
		eyeOffset = [
			FlxMath.lerp(eyeOffset[0], 0, e * 3),
			FlxMath.lerp(eyeOffset[1], 0, e * 3)
		];
		exeeye.setPosition(FlxMath.lerp(170, 230, _eyeLerp) + eyeOffset[0] + Math.cos(_sine) * 30, FlxMath.lerp(130, 125, _eyeLerp) + eyeOffset[1] + Math.sin(_sine / 2) * 30);
		spr.sprite.setPosition(spr.position[0] + Math.cos(_sine) * 30, spr.position[1] + Math.sin(_sine / 2) * 30);
	}
}

var _oldMHS:Bool = false;
function onSectionHit()
{
	if (_oldMHS != mustHitSection && exeeye.alpha != 0)
	{
		if (mustHitSection) _target = 1;
		else _target = 0;

	}
	_oldMHS = mustHitSection;
}

function onBeatHit()
{
	if (curBeat % 2 == 0)
	{
		for (spr in stage) if (spr.sprite != null && spr.animation != null && spr.sprite.alpha != 0 && spr.tag != null) spr.sprite.animation.play(spr.animation[0].name, true);
		for (spr in dark) if (spr.sprite != null && spr.animation != null && spr.sprite.alpha != 0 && spr.tag != null)
		{
			if (spr.tag == 'exe1') eyeOffset = [-7, 15];
			spr.sprite.animation.play(spr.animation[0].name, true);
		}
	}

	if (bfDark != null && curBeat % 2 == 0 && !bfDark.getAnimationName().startsWith('sing') && bfDark.alpha != 0) bfDark.dance();
}

function goodNoteHit() if (bfDark != null && bfDark.alpha != 0) { bfDark.playAnim('singUP', true); bfDark.holdTimer = 0; }
function noteMiss() if (bfDark != null && bfDark.alpha != 0) bfDark.playAnim('singUPmiss', true);

function opponentNoteHitPre(note) if (dad.getAnimationName() == 'laugh') note.noAnimation = true;