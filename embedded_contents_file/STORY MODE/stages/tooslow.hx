import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

using StringTools;

final game:PlayState = PlayState.instance;
final lq:Bool = ClientPrefs.data.lowQuality;
final prefs = ClientPrefs.data;

var startWave:Bool = false;
var tweenBack:Bool = false;
var tweenStart:Bool = false;
var shaderTime:Float = 0;

var waveVal:Float = 0;
var bwVal:Float = 0;
var waveShader:FlxRuntimeShader;
var bwShader:FlxRuntimeShader;

var sprNames:Array<String> = [];
var sprObjs:Array<FlxSprite> = [];

typedef SprDef = {
	var name:String;
	var path:String;
	var x:Float;
	var y:Float;
	@:optional var scale:Float;
	@:optional var scaleX:Float;
	@:optional var scaleY:Float;
	@:optional var alpha:Float;
	@:optional var front:Bool;
	@:optional var animated:Bool;
	@:optional var prefix:String;
	@:optional var fps:Int;
	@:optional var scrollX:Float;
	@:optional var scrollY:Float;
	@:optional var antialiasing:Bool;
	@:optional var loop:Bool;
	@:optional var animName:String;
	@:optional var animPrefix:String;
}

var sprites:Array<SprDef> = [
	{name: 'fondo',      path: 'slow/fondo',       x: -950, y: -400, scale: 1.4,  alpha: 1},
	{name: 'bg3',        path: 'slow/bg3',         x: -950, y: -150, scale: 1.4,  alpha: 1},
	{name: 'montains',   path: 'slow/montains',    x: -820, y: -95,  scale: 1.4,  scaleY: 1.39, animated: true, prefix: 'rio', fps: 12, alpha: 1},
	{name: 'bg2',        path: 'slow/bg2',         x: -950, y: -700, scale: 1.4,  alpha: 1},
	{name: 'bg1',        path: 'slow/bg1',         x: -950, y: -700, scale: 1.4,  alpha: 1},
	{name: 'b1_front',   path: 'slow/b1 front',    x: -950, y: -700, scale: 1.4,  alpha: 1,  front: true},
	{name: 'ojos_tails', path: 'slow/ojos_tails',  x: 350,  y: 1000, scale: 1.5,  animated: true, prefix: 'Símbolo 10 instancia', fps: 24, alpha: 1, front: true},
	{name: 'eggman',     path: 'slow/eggman',      x: 1800, y: 1500, scale: 1.4,  alpha: 1,  front: true},
];

var flashBackBG:Array<SprDef> = [
	{name: 'static',        path: 'slow/flashback/static-flashback', x:  -950, y:  450, animated: true, animName: 'idle', animPrefix: 'static', fps: 24, loop: true, scaleX:   3, scaleY: 1.5, scrollX: 1, scrollY: 1, alpha: 0},
	{name: 'mount',         path: 'slow/flashback/idk',              x:  -651, y:  338,                                                                              scaleX: 0.3602, scaleY: 0.3602, scrollX: 1, scrollY: 1, alpha: 0},
	{name: 'plant',         path: 'slow/flashback/plants',           x:  -400, y:  730,                                                                              scaleX: 0.5257, scaleY: 0.5257, scrollX: 1, scrollY: 1, alpha: 0},
	{name: 'floor',         path: 'slow/flashback/ground',           x:  -1000,y: 974,                                                                               scaleX: 1.4, scaleY: 1.4, scrollX: 1, scrollY: 1, alpha: 0},
	{name: 'picoDead',      path: 'slow/flashback/pico_ded',         x:   370, y: 900,                                                                              scaleX: 0.6, scaleY: 0.6, scrollX: 1, scrollY: 1, alpha: 0, front: true},
];

function addSpr(def:SprDef)
{
	var spr:FlxSprite;
	if (def.animated == true)
	{
		spr = new FlxSprite(def.x, def.y);
		spr.frames = Paths.getSparrowAtlas(def.path);
		var animN:String = def.animName != null ? def.animName : 'idle';
		var animP:String = def.animPrefix != null ? def.animPrefix : (def.prefix != null ? def.prefix : animN);
		var fps:Int = def.fps != null ? def.fps : 24;
		var loop:Bool = def.loop != null ? def.loop : true;
		spr.animation.addByPrefix(animN, animP, fps, loop);
		spr.animation.play(animN);
	}
	else
	{
		spr = new FlxSprite(def.x, def.y).loadGraphic(Paths.image(def.path));
	}

	var sx:Float = def.scaleX != null ? def.scaleX : (def.scale != null ? def.scale : 1);
	var sy:Float = def.scaleY != null ? def.scaleY : (def.scale != null ? def.scale : 1);
	spr.scale.set(sx, sy);
	spr.updateHitbox();

	if (def.scrollX != null) spr.scrollFactor.set(def.scrollX, def.scrollY != null ? def.scrollY : def.scrollX);
	if (lq) spr.antialiasing = false;
	spr.alpha = def.alpha != null ? def.alpha : 1;

	sprNames.push(def.name);
	sprObjs.push(spr);

	if (def.front == true)
		game.add(spr);
	else
		game.insert(game.members.indexOf(getLowestGroup()), spr);
}

function onCreate()
{
	for (fl in flashBackBG) addSpr(fl);
	for (spr in sprites)    addSpr(spr);

	game.gfGroup.scrollFactor.set(1, 1);
}

function getLowestGroup()
{
	var g = game.gfGroup;
	var pos = game.members.indexOf(g);
	var p2 = game.members.indexOf(game.boyfriendGroup);
	if (p2 < pos) { g = game.boyfriendGroup; pos = p2; }
	var p3 = game.members.indexOf(game.dadGroup);
	if (p3 < pos) g = game.dadGroup;
	return g;
}

function getSpr(name)
{
	for (i in 0...sprNames.length)
		if (sprNames[i] == name) return sprObjs[i];
	return null;
}

function onEvent(e, v1, v2)
{
	if (e != 'tooSlowEvents' || v1 != 'flashBack') return;
	if (lq) return;

	if (v2 == '')
	{
		for (yes in flashBackBG) FlxTween.tween(getSpr(yes.name), {alpha: 1}, 2);
		for (yes in sprites) if (yes.prefix != 'Símbolo 10 instancia') FlxTween.tween(getSpr(yes.name), {alpha: 0}, 2);
		
		FlxTween.tween(gfGroup, {alpha: 0}, 2);

		if (prefs.shaders)
		{
			waveShader = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment('wavyDistortion')));
			bwShader   = new FlxRuntimeShader(Paths.getContent(Paths.shaderFragment('blackwhite')));

			waveVal = 0;
			bwVal   = 0;
			waveShader.setFloat('amount', 0);
			bwShader.setFloat('grayness', 0);

			game.camGame.filters = [new ShaderFilter(waveShader), new ShaderFilter(bwShader)];

			FlxTween.num(0, 0.5, 2, {}, function(v) { waveVal = v; });
			FlxTween.num(0, 0.5, 2, {}, function(v) { bwVal = v; });
			startWave  = true;
			tweenStart = true;
		}
	}
	else if (v2 == 'fade')
	{
		tweenBack = true;
		if (prefs.shaders)
		{
			FlxTween.num(waveVal, 0, 4, {}, function(v) { waveVal = v; });
			FlxTween.num(bwVal,   0, 4, {}, function(v) { bwVal = v; });
		}
		for (yes in flashBackBG) FlxTween.tween(getSpr(yes.name), {alpha: 0}, 4, {onComplete: (_) -> getSpr(yes.name).destroy});
		for (yes in sprites)     FlxTween.tween(getSpr(yes.name), {alpha: 1}, 4);

		FlxTween.tween(gfGroup, {alpha: 1}, 4);
	}
}

function onUpdatePost(elapsed:Float)
{
	if (!prefs.shaders || lq) return;
	shaderTime += elapsed / game.playbackRate;
	if (startWave && waveShader != null)
		waveShader.setFloat('iTime', shaderTime);
	if ((tweenBack || tweenStart) && waveShader != null && bwShader != null)
	{
		waveShader.setFloat('amount', waveVal);
		bwShader.setFloat('grayness', bwVal);
	}
}

function onTweenCompleted(tag)
{
	if (!prefs.shaders || lq) return;
	if (tag == 'waveTween')
	{
		startWave = false;
		tweenBack = false;
		game.camGame.filters = [];
	}
	if (tag == 'waveTweenStart')
		tweenStart = false;
}
