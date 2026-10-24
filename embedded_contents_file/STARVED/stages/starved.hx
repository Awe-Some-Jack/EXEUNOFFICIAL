// Raimbow's Ideas
// - A shader that goes dizzy for Tails
// - Once red, every drum beat shakes the camera.
// - Your mom
import psychlua.LuaUtils;
typedef BackgroundSpriteAlt =
{
	var path:String;
	var sprite:FlxSprite;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool;
	@:optional var visible:Bool;
	@:optional var alpha:Float;
	@:optional var angle:Float;
	@:optional var animation:Array<Dynamic>;
}

//Gonna take inspo from you Dudu
typedef ShaderStuff = {
	var daShader:ErrorHandledRuntimeShader;
	@:optional var defaultValues:Map<String, Dynamic>;
	@:optional var uniforms:Map<String, Dynamic>;
	@:optional var valuesOffsets:Map<String, Dynamic>;
	@:optional var shaderTweens:Map<String, FlxTween>;
}

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var starv:Array<BackgroundSpriteAlt> = [
	{path: 'new bg/sky', position: [-1220, -1250], scroll: [0.4, 0.4], scale: [0.8, 0.8]},
	{path: 'new bg/bg', position: [-1350, -1300], scroll: [0.6, 0.6], scale: [0.8, 0.8]},
	{path: 'new bg/tv', position: [40, -680], tag: 'tv', scale: [1.5, 1.35], animation: [{name: 'idle', looped: true}], angle: -6, hide: false},
	{path: 'new bg/floor', position: [-1610, -1450], scale: [0.8, 0.8]},
	{path: 'new bg/metal', position: [-650, -500], scale: [0.38, 0.38], animation: [{name: 'idle', looped: true}], blend: 'add', hide: false},
	{path: 'new bg/tails', position: [-290, -410], scale: [0.45, 0.45], animation: [{name: 'idle', looped: true}], blend: 'add', hide: false},
	{path: 'new bg/starv', tag: 'starvTV', position: [150, -480], scale: [0.4, 0.4], animation: [{name: 'idle', looped: true}], blend: 'add', hide: false},
	{path: 'bee', position: [-520, -150], scale: [0.7, 0.7], darkVariant: true},
	{path: 'moto', position: [-1000, 120], scale: [0.9, 0.9], darkVariant: true},
	{path: 'sonic', position: [-550, 240], scale: [1.15, 1.15], darkVariant: true},
	{path: 'shoe', position: [300, 320], scale: [0.8, 0.8], darkVariant: true},
	{path: 'picky', position: [-870, 400], darkVariant: true},
	{path: 'mrcrabs', position: [200, -60], scale: [1.3, 1.3], darkVariant: true},
	{path: 'pocky', position: [400, 230], scale: [0.7, 0.7], darkVariant: true},
	{path: 'ricky', position: [-1300, -1000], scale: [0.6, 0.6], scroll: [1.7, 1.7], darkVariant: true},
	{path: 'cucky', position: [-50, -900], scale: [0.5, 0.5], scroll: [1.5, 1.5], front: true, darkVariant: true},
	{path: 'flicky', position: [-300, -1100], scale: [0.8, 0.8], scroll: [2.2, 2.2], darkVariant: true},
	{path: 'fish', position: [-1500, 250], scale: [1.2, 1.2], scroll: [2, 2], darkVariant: true},
	{path: 'new bg/light', position: [-1350, -1300], front: true, scale: [0.8, 0.8]}
];

//The Shaders. This is how they're set onCreate.
var bloom    :ShaderStuff  = {daShader: null, uniforms: ["brightness" =>   0, "contrast" => 1, "saturation" => 1]};
var chrom    :ShaderStuff  = {daShader: null, uniforms: ["amount"     => 0.2], defaultValues: ["amount" => 0.2]};
var wave     :ShaderStuff  = {daShader: null, uniforms: ["amount"     =>   0]};
var lilGlitch:ShaderStuff  = {daShader: null, uniforms: ["size"       =>   0]};

var vg:FlxSprite;
function onCreate()
{
	makeBackgroundAlt(starv);
	boyfriend.scrollFactor.set(2, 2);

	vg = new FlxSprite().loadGraphic(Paths.image('starved/vinevrom'));
	vg.camera = camHUD;
	add(vg);

	game.gameplayCam._targetAlpha = 0.5;

	bloom.daShader = new ErrorHandledRuntimeShader("brightness", File.getContent(Paths.shaderFragment('brightness')));
	bloom.uniforms      = ["brightness" => 0, "contrast" => 1, "saturation" => 1]; 
	bloom.defaultValues = ["brightness" => 0, "contrast" => 1, "saturation" => 1]; 
	bloom.shaderTweens  = [];
	
	chrom.daShader = new ErrorHandledRuntimeShader("chromabber", File.getContent(Paths.shaderFragment('chromabber')));
	chrom.daShader.setFloat("amount", chrom.uniforms.get("amount"));
	chrom.shaderTweens = [];
	
	wave.daShader = new ErrorHandledRuntimeShader("wavyDistortion", File.getContent(Paths.shaderFragment('wavyDistortion')));
	wave.uniforms      = ["amount" => 0];
	wave.shaderTweens  = [];
	
	lilGlitch.daShader = new ErrorHandledRuntimeShader("followedglitch", File.getContent(Paths.shaderFragment('followedglitch')));
	lilGlitch.uniforms      = ["size" => 0.001];
	lilGlitch.shaderTweens  = [];

	camGame.filters = camHUD.filters = [new ShaderFilter(bloom.daShader), new ShaderFilter(chrom.daShader), new ShaderFilter(wave.daShader), new ShaderFilter(lilGlitch.daShader)];
}

var _inTrans:Bool = false;
function onSectionHit(x)
{
	if (_inTrans) return;
	if (!tweenCamZoom)
	{
		if (x.mustHitSection == false) game.triggerEvent("Tween Camera Zoom", "0.9", "");
		else game.triggerEvent("Tween Camera Zoom", "0.65", "");
	}
}

var _isDark:Bool = false;
var notesPosition:Array<Array<Array<Float>>> = [[[0,0],[0,0],[0,0],[0,0]],[[0,0],[0,0],[0,0],[0,0]]];
function onEvent(n, v1, v2)
{
	//Shader Tweens Event
	//According to v1, you choose between the shaders in the script and set the start and end
	//In v2, you just set the time and ease.
	//Don't worry about having tweens in between, they'll be canceled!
	//(sorry dudu i took some things from ya)
	if (n == "shaderTween")
	{
		var split1:Array<String> = v1.split(", ");
		var shaderName:String = split1[0];
		var from:Float = Std.parseFloat(split1[1]);
		var to:Float = Std.parseFloat(split1[2]);
		
		var split2:Array<String> = v2.split(", ");
		var time:Float = Std.parseFloat(split2[0]);
		var easeValue:String = (split2[1] == null || split2[1] == '') ? "linear" : split2[1];

		switch(split1[0])
		{
			case "bloom":
				if (bloom.shaderTweens['bloomBaby']?.active ?? false) bloom.shaderTweens['bloomBaby'].cancel();

				bloom.shaderTweens['bloomBaby'] = FlxTween.num(from, to, time, {ease: LuaUtils.getTweenEaseByString(easeValue)}, (v:Float) -> {
					bloom.uniforms.set("brightness", bloom.defaultValues.get("brightness") + v * 2);
					bloom.uniforms.set("contrast", bloom.defaultValues.get("contrast") + v * 4);
				});
			case "chrom":
				if (chrom.shaderTweens['chromTween']?.active ?? false) chrom.shaderTweens['chromTween'].cancel();

				chrom.shaderTweens['chromTween'] = FlxTween.num(from, to, time, {ease: LuaUtils.getTweenEaseByString(easeValue)}, (v:Float) -> {
					chrom.uniforms.set("amount", v);
				});
			case "wave":
				if (wave.shaderTweens['waveTween']?.active ?? false) wave.shaderTweens['waveTween'].cancel();

				wave.shaderTweens['waveTween'] = FlxTween.num(from, to, time, {ease: LuaUtils.getTweenEaseByString(easeValue)}, (v:Float) -> {
					wave.uniforms.set("amount", v);
				});
			case "glitchie":
				if (lilGlitch.shaderTweens['lilGlitchTween']?.active ?? false) lilGlitch.shaderTweens['lilGlitchTween'].cancel();

				lilGlitch.shaderTweens['lilGlitchTween'] = FlxTween.num(from, to, time, {ease: LuaUtils.getTweenEaseByString(easeValue)}, (v:Float) -> {
					lilGlitch.uniforms.set("size", v);
				});
		}
	}
	if (n == 'Hide') FlxTween.tween(camHUD, {alpha: Std.int(v1)}, 0.3);
	if (n == 'secondPhase')
	{
		switch(v1)
		{
			case 'fadeout':
				_inTrans = true;
				for (spr in starv) if (spr.hide == null || spr.hide == true) FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(vg, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 3);
				for (i in 0...4)
				{
					notesPosition[0][i][0] = opponentStrums.members[i].x; notesPosition[1][i][0] = playerStrums.members[i].x;
					notesPosition[0][i][1] = opponentStrums.members[i].y; notesPosition[1][i][1] = playerStrums.members[i].y;
				}
			case 'fight':
				_inTrans = false;
				for (spr in starv)
				{
					if (spr.tag == 'starvTV' || spr.tag == 'tv') FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFFFF0000);
					if (spr.darkVariant != null && spr.spriteDark != null && (spr.hide == null || spr.hide == true) && (spr.tag != 'starvTV' || spr.tag != 'tv'))
					{
						spr.spriteDark.alpha = 1;
						FlxTween.color(spr.spriteDark, 1, 0xFF000000, 0xFFFFFFFF);
					}
				}
				FlxTween.color(boyfriend, 1, 0xFF000000, 0xFFFF0000);
				FlxTween.color(vg, 1, 0xFF000000, 0xFFFF0000);
				FlxTween.color(dad, 1, 0xFFFFFFFF, 0xFFFF0000);
				FlxTween.tween(camHUD, {alpha: 1}, 1);
				_isDark = true;
			case 'starved':
				_inTrans = true;
				for (spr in starv) if (spr.darkVariant != null && spr.spriteDark != null && (spr.hide == null || spr.hide == true) && (spr.tag != 'starvTV' || spr.tag != 'tv')) FlxTween.color(spr.spriteDark, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 1, 0xFFFF0000, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 1);
				FlxTween.color(vg, 3, 0xFFFF0000, 0xFF000000);
			case 'fadein':
				_inTrans = false;
				_isDark = false;
				for (i in 0...4)
				{
					opponentStrums.members[i].setPosition(notesPosition[0][i][0], notesPosition[0][i][1]);
					playerStrums.members[i].setPosition(notesPosition[1][i][0], notesPosition[1][i][1]);
					opponentStrums.members[i].angle = 0;
					playerStrums.members[i].angle = 0;
				}
				for (spr in starv)
				{
					if (spr.tag == 'starvTV' || spr.tag == 'tv') FlxTween.color(spr.sprite, 1, 0xFFFF0000, 0xFFFFFFFF);
					if (spr.hide == false) continue;
					if (spr.darkVariant != null && spr.spriteDark != null) spr.spriteDark.alpha = 0;
					FlxTween.color(spr.sprite, 1, 0xFF000000, 0xFFFFFFFF);
				}
				FlxTween.tween(camHUD, {alpha: 1}, 4);
				FlxTween.color(boyfriend, 1, 0xFF000000, 0xFFFFFFFF);
				FlxTween.color(vg, 1, 0xFF000000, 0xFFFFFFFF);
				FlxTween.color(dad, 1, 0xFFFF0000, 0xFFFFFFFF);
			case 'fadefinalxd':
				for (spr in starv) FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(dad, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(vg, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 3);
		}
	}

}

var holdTime:Float = 0;
function onUpdatePost(e)
{
	holdTime += e;

	//Shaders uniforms should be updated getting their numbers, duh. 
	bloom.daShader.setFloat('brightness', bloom.uniforms.get('brightness'));
	bloom.daShader.setFloat('saturation', bloom.uniforms.get('saturation'));
	bloom.daShader.setFloat('contrast',   bloom.uniforms.get('contrast'));
	
	chrom.daShader.setFloat('amount', chrom.uniforms.get('amount'));
	
	wave.daShader.setFloat('amount', wave.uniforms.get('amount'));
	
	lilGlitch.daShader.setFloat('size', lilGlitch.uniforms.get('size'));
	
	for (holdShit in [wave, lilGlitch]) holdShit.daShader.setFloat('iTime', holdTime);
	
	if (_isDark)
	{
		for (i in 0...4)
		{
			opponentStrums.members[i].setPosition(notesPosition[0][i][0] + FlxG.random.float(-1, 1), notesPosition[0][i][1] + FlxG.random.float(-1, 1));
			playerStrums.members[i].setPosition(notesPosition[1][i][0] + FlxG.random.float(-1, 1), notesPosition[1][i][1] + FlxG.random.float(-1, 1));
			opponentStrums.members[i].angle = FlxG.random.float(-1, 1);
			playerStrums.members[i].angle = FlxG.random.float(-1, 1);
		}
	}
}

function makeBackgroundAlt(background:Array<BackgroundSpriteAlt>)
{
	for (spriteDef in background)
	{
		var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
		if (spriteDef.animation != null)
		{
			sprite.frames = Paths.getSparrowAtlas('starved/' + spriteDef.path);
			for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
		}
		else sprite.loadGraphic(Paths.image('starved/' + spriteDef.path));
		sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
		sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
		if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
		if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
		if (spriteDef.angle != null) sprite.angle = spriteDef.angle;
		if (spriteDef.blend != null) sprite.blend = LuaUtils.blendModeFromString(spriteDef.blend);
		if (spriteDef.front) game.add(sprite);
		else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
		spriteDef.sprite = sprite;

		if (spriteDef.darkVariant != null) {
			var sprite:FlxSprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
			if (spriteDef.animation != null)
			{
				sprite.frames = Paths.getSparrowAtlas('starved/dark/' + spriteDef.path);
				for (anim in spriteDef.animation) {sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false); sprite.animation.play(anim.name, true);}
			}
			else sprite.loadGraphic(Paths.image('starved/dark/' + spriteDef.path));
			sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
			sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]); if ((spriteDef.scale ?? [1, 1, true])[2]) sprite.updateHitbox();
			sprite.alpha = 0;
			if (spriteDef.blend != null) sprite.blend = LuaUtils.blendModeFromString(spriteDef.blend);
			if (spriteDef.front) game.add(sprite);
			else game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
			spriteDef.spriteDark = sprite;
		}
	}
}