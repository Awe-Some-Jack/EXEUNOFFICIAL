package options;

import flixel.FlxObject;
import flixel.addons.display.FlxRuntimeShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Assets;

typedef ExeVisualOption = {
	var label:String;
	var getValue:Void->Dynamic;
	var setValue:Dynamic->Void;
	@:optional var isInt:Bool;
	@:optional var isFloat:Bool;
	@:optional var isString:Bool;
	@:optional var options:Array<String>;
}

class ExeVisualsState extends MusicBeatState
{
	var bg:FlxSprite;
	var objsGrp:FlxTypedGroup<FlxSprite>;
	var title:FlxSprite;

	var sectionsList:Array<ExeVisualOption> = [];

	var sectionsGrp:FlxTypedGroup<FlxText>;
	var sectionBGGrp:FlxTypedGroup<FlxSprite>;
	var propertieTxtGrp:FlxTypedGroup<FlxText>;
	var propertiesBG:FlxTypedGroup<FlxSprite>;
	var propertieArrows:FlxTypedGroup<FlxSprite>;
	var sectionBGClone:FlxSprite;
	var propertieBGClone:FlxSprite;
	var selectionTween:FlxTween;
	var sectionPos:Array<Dynamic> = [];
	var propertiesPos:Array<Dynamic> = [];
	var propBGCloneShader:FlxRuntimeShader;

	public static var curSelected:Int = 0;

	var canAction:Bool = true;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	final GLOBAL_SCALE:Float = (FlxG.width / 3840);

	override public function create()
	{
		super.create();

		sectionsList = [
			{label: "HIDE HUD",       getValue: () -> ClientPrefs.data.hideHud,      setValue: (v) -> ClientPrefs.data.hideHud = v},
			{label: "FLASHING LIGHTS", getValue: () -> ClientPrefs.data.flashing,    setValue: (v) -> ClientPrefs.data.flashing = v},
			{label: "CAMERA ZOOMS",   getValue: () -> ClientPrefs.data.camZooms,     setValue: (v) -> ClientPrefs.data.camZooms = v},
			{label: "SCORE TEXT ZOOM", getValue: () -> ClientPrefs.data.scoreZoom,   setValue: (v) -> ClientPrefs.data.scoreZoom = v},
			{label: "HEALTH BAR ALPHA", getValue: () -> ClientPrefs.data.healthBarAlpha, setValue: (v) -> ClientPrefs.data.healthBarAlpha = v, isFloat: true},
			{label: "FPS COUNTER",    getValue: () -> ClientPrefs.data.showFPS,      setValue: (v) -> { ClientPrefs.data.showFPS = v; #if !mobile if (Main.fpsVar != null) Main.fpsVar.visible = v; #end }},
			{label: "COMBO STACKING", getValue: () -> ClientPrefs.data.comboStacking, setValue: (v) -> ClientPrefs.data.comboStacking = v}
		];

		buildUI();
	}

	function buildUI()
	{
		bg = new FlxSprite(-100, -100).loadGraphic(Assets.getBitmapData('assets/exe/options/bg.png'));
		bg.setGraphicSize(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0.1, 0.1);
		add(bg);

		objsGrp = new FlxTypedGroup<FlxSprite>();
		add(objsGrp);

		for (i in 0...15)
		{
			var obj = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/objs/' + ((i % 7) + 1) + '.png'));
			obj.setGraphicSize(Std.int(obj.width * GLOBAL_SCALE));
			obj.updateHitbox();
			obj.ID = i;
			obj.antialiasing = ClientPrefs.data.antialiasing;
			objsGrp.add(obj);
			resetObj(obj);
		}

		title = new FlxSprite(0, 20).loadGraphic(Assets.getBitmapData('assets/exe/options/optionsTitle.png'));
		title.setGraphicSize(Std.int(title.width * GLOBAL_SCALE));
		title.updateHitbox();
		title.screenCenter(X);
		title.antialiasing = ClientPrefs.data.antialiasing;
		add(title);

		sectionBGClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionsBG.png'));
		sectionBGClone.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		sectionBGClone.updateHitbox();
		add(sectionBGClone);

		#if !html5
		if (ClientPrefs.data.shaders)
		{
			try
			{
				var shaderPath = Paths.shaderFragment('adjustColor');
				if (Assets.exists(shaderPath))
				{
					propBGCloneShader = new FlxRuntimeShader(Assets.getText(shaderPath));
					propBGCloneShader.setFloat("hue", 0);
					propBGCloneShader.setFloat("brightness", 100);
					propBGCloneShader.setFloat("contrast", 100);
					propBGCloneShader.setFloat("saturation", 100);
					sectionBGClone.shader = propBGCloneShader;
				}
			}
			catch (e:Dynamic) { trace("Shader error: " + e); }
		}
		#end

		propertieBGClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		propertieBGClone.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		propertieBGClone.updateHitbox();
		add(propertieBGClone);

		#if !html5
		if (ClientPrefs.data.shaders && propBGCloneShader != null)
			propertieBGClone.shader = propBGCloneShader;
		#end

		sectionBGGrp = new FlxTypedGroup<FlxSprite>();
		add(sectionBGGrp);
		sectionsGrp = new FlxTypedGroup<FlxText>();
		add(sectionsGrp);
		propertiesBG = new FlxTypedGroup<FlxSprite>();
		add(propertiesBG);
		propertieArrows = new FlxTypedGroup<FlxSprite>();
		add(propertieArrows);
		propertieTxtGrp = new FlxTypedGroup<FlxText>();
		add(propertieTxtGrp);

		for (i in 0...sectionsList.length)
			addOption(sectionsList[i].label, sectionsList[i].getValue());

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		changeSelect();

		camFollow.setPosition(FlxG.width / 2, sectionsGrp.members[curSelected].y);
		camFollowPos.setPosition(camFollow.x, camFollow.y);
		FlxG.camera.follow(camFollowPos, null, 0.15);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerpVal:Float = FlxMath.bound(elapsed * 9.6, 0, 1);
		camFollowPos.setPosition(
			FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal),
			FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal)
		);

		objsGrp.forEachExists(function(o)
		{
			if (o.y > FlxG.height || o.x > FlxG.width || o.y < -o.height || o.x < -o.width)
				resetObj(o);
		});

		sectionsGrp.forEachExists(function(txt)
		{
			if (sectionPos.length > 0)
			{
				if (txt.ID != curSelected)
				{
					txt.x = FlxMath.lerp(txt.x, sectionPos[txt.ID].x, elapsed * 9);
					txt.y = FlxMath.lerp(txt.y, sectionPos[txt.ID].y, elapsed * 9);
				}
				var sep = 14;
				var bg = sectionBGGrp.members[txt.ID];
				bg.x = txt.x + ((28 * sectionsList[txt.ID].label.length - bg.width) / 2) - 20;
				bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
			}
		});

		propertieTxtGrp.forEachExists(function(txt)
		{
			if (propertiesPos.length > 0)
			{
				if (txt.ID != curSelected)
				{
					txt.x = FlxMath.lerp(txt.x, propertiesPos[txt.ID].x, elapsed * 9);
					txt.y = FlxMath.lerp(txt.y, propertiesPos[txt.ID].y, elapsed * 9);
				}
				var sep = 14;
				var bg = propertiesBG.members[txt.ID];
				bg.x = txt.x + ((28 * txt.text.length - bg.width) / 2);
				bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
				var arrows = propertieArrows.members[txt.ID];
				arrows.x = bg.x;
				arrows.y = bg.y;
			}
		});

		if (!canAction) return;

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelect(controls.UI_UP_P ? -1 : 1);
		}

		if (controls.UI_RIGHT_P || controls.UI_LEFT_P)
		{
			var isRight = controls.UI_RIGHT_P;
			var option = sectionsList[curSelected];
			var val = option.getValue();
			var txt = propertieTxtGrp.members[curSelected];

			if (Std.isOfType(val, Bool))
			{
				var b = !cast(val, Bool);
				option.setValue(b);
				txt.text = b ? "ON" : "OFF";
			}
			else if (option.isInt == true)
			{
				var n = cast(val, Int) + (isRight ? 1 : -1);
				n = Std.int(isRight ? Math.min(n, 240) : Math.max(n, 60));
				option.setValue(n);
				txt.text = Std.string(n);
			}
			else if (option.isFloat == true)
			{
				var n = Math.round((cast(val, Float) + (isRight ? 0.1 : -0.1)) * 10) / 10;
				n = isRight ? Math.min(n, 1.0) : Math.max(n, 0.0);
				option.setValue(n);
				txt.text = Std.string(n);
			}
			else if (option.isString == true && option.options != null)
			{
				var idx = option.options.indexOf(cast(val, String));
				idx = isRight ? (idx + 1) % option.options.length : (idx - 1 + option.options.length) % option.options.length;
				var newVal = option.options[idx];
				option.setValue(newVal);
				txt.text = newVal.toUpperCase();
			}
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(() -> new options.OptionsState());
		}
	}

	var selectionCloneTween:FlxTween;
	var propTween:FlxTween;
	var propArrowTween:FlxTween;
	var propCloneTween:FlxTween;

	function changeSelect(x:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + x, 0, sectionsList.length - 1);
		if (sectionBGGrp.members[curSelected] == null) return;

		var curSectionBG = sectionBGGrp.members[curSelected];
		var curSectionText = sectionsGrp.members[curSelected];
		var currentPos = sectionPos[curSelected];

		camFollow.setPosition(FlxG.width / 2, curSectionText.y);
		sectionBGClone.setPosition(curSectionBG.x - 3, curSectionBG.y - 3);
		curSectionBG.x -= 8; curSectionBG.y -= 8;
		curSectionText.x -= 8; curSectionText.y -= 8;

		if (selectionTween != null) selectionTween.cancel();
		selectionTween = FlxTween.tween(curSectionText, {x: currentPos.x - 12, y: currentPos.y - 16}, 0.18, {ease: FlxEase.quadInOut, onComplete: (_) -> selectionTween = null});

		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(sectionBGClone, {x: curSectionBG.x + 13, y: curSectionBG.y + 13}, 0.2, {ease: FlxEase.quadInOut, onComplete: (_) -> selectionCloneTween = null});

		if (propertieTxtGrp.members[curSelected] == null) return;
		var curPropertieBG = propertiesBG.members[curSelected];
		var curPropertieTxt = propertieTxtGrp.members[curSelected];
		var curPropertieArrows = propertieArrows.members[curSelected];
		var currentPropPos = propertiesPos[curSelected];

		propertieBGClone.setPosition(curPropertieBG.x - 3, curPropertieBG.y - 3);
		curPropertieBG.x -= 8; curPropertieBG.y -= 8;
		curPropertieTxt.x -= 8; curPropertieTxt.y -= 8;

		if (propTween != null) propTween.cancel();
		propTween = FlxTween.tween(curPropertieTxt, {x: currentPropPos.x - 12, y: currentPropPos.y - 16}, 0.18, {ease: FlxEase.quadInOut, onComplete: (_) -> propTween = null});

		if (propArrowTween != null) propArrowTween.cancel();
		propArrowTween = FlxTween.tween(curPropertieArrows, {x: currentPropPos.x - 12, y: currentPropPos.y - 16}, 0.18, {ease: FlxEase.quadInOut, onComplete: (_) -> propArrowTween = null});

		if (propCloneTween != null) propCloneTween.cancel();
		propCloneTween = FlxTween.tween(propertieBGClone, {x: curPropertieBG.x + 13, y: curPropertieBG.y + 13}, 0.2, {ease: FlxEase.quadInOut, onComplete: (_) -> propCloneTween = null});
	}

	var optionID:Int = -1;

	function addOption(label:String, property:Dynamic)
	{
		optionID++;
		var sep = 14;
		var y = title.y + 28 + sep;

		var section = new FlxText(0, 0, 0, label, 50);
		section.setFormat(Paths.font("SonicCD.ttf"), 28, FlxColor.WHITE, CENTER);
		section.ID = optionID;
		section.screenCenter(X);
		section.x -= 230;
		section.y = y + 90 + (section.size + sep + 70) * optionID;
		sectionsGrp.add(section);
		sectionPos.push({x: section.x, y: section.y});

		var sectionBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionsBG.png'));
		sectionBG.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		sectionBG.updateHitbox();
		sectionBG.ID = optionID;
		var sectionWidth = 28 * label.length;
		sectionBG.x = section.x + ((sectionWidth - sectionBG.width) / 2);
		sectionBG.y = (section.y - (section.size / 2)) + (sep * 2.5);
		sectionBGGrp.add(sectionBG);

		var propertyTag = "?";
		if (Std.isOfType(property, Bool))
			propertyTag = cast(property, Bool) ? "ON" : "OFF";
		else if (Std.isOfType(property, Int))
			propertyTag = Std.string(property);
		else if (Std.isOfType(property, Float))
			propertyTag = Std.string(Math.round(cast(property, Float) * 10) / 10);
		else if (Std.isOfType(property, String))
			propertyTag = cast(property, String);

		var propTxt = new FlxText(0, 0, 0, propertyTag.toUpperCase(), 50);
		propTxt.setFormat(Paths.font("SonicCD.ttf"), 28, FlxColor.WHITE, CENTER);
		propTxt.ID = optionID;
		propTxt.screenCenter(X);
		propTxt.x += 380;
		propTxt.y = y + 90 + (propTxt.size + sep + 70) * optionID;
		propertieTxtGrp.add(propTxt);
		propertiesPos.push({x: propTxt.x, y: propTxt.y});

		var propBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		propBG.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		propBG.updateHitbox();
		propBG.ID = optionID;
		var propSectionWidth = 28 * propTxt.text.length;
		propBG.x = propTxt.x + ((propSectionWidth - propBG.width) / 2);
		propBG.y = (propTxt.y - (propTxt.size / 2)) + (sep * 2.5);
		propertiesBG.add(propBG);

		var propArrow = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/optionArrow.png'));
		propArrow.scale.set(GLOBAL_SCALE, GLOBAL_SCALE);
		propArrow.updateHitbox();
		propArrow.ID = optionID;
		propArrow.x = propBG.x;
		propArrow.y = propBG.y;
		propertieArrows.add(propArrow);
	}

	function resetObj(m:FlxSprite)
	{
		m.x = FlxG.random.int(0, FlxG.width);
		m.y = FlxG.random.int(0, FlxG.height);
		m.velocity.x = FlxG.random.float(-20, 20);
		m.velocity.y = FlxG.random.float(-20, 20);
		m.angularVelocity = FlxG.random.float(-14, 14);
		m.updateHitbox();
	}

	override function destroy()
	{
		if (selectionTween != null)      { selectionTween.cancel();      selectionTween = null; }
		if (selectionCloneTween != null) { selectionCloneTween.cancel(); selectionCloneTween = null; }
		if (propTween != null)           { propTween.cancel();           propTween = null; }
		if (propArrowTween != null)      { propArrowTween.cancel();      propArrowTween = null; }
		if (propCloneTween != null)      { propCloneTween.cancel();      propCloneTween = null; }
		bg = null; title = null; objsGrp = null;
		sectionsGrp = null; sectionBGGrp = null;
		propertieTxtGrp = null; propertiesBG = null; propertieArrows = null;
		sectionBGClone = null; propertieBGClone = null;
		propBGCloneShader = null; camFollow = null; camFollowPos = null;
		super.destroy();
	}
}
