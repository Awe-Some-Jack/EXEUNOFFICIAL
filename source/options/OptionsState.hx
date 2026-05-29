package options;

import flixel.addons.display.FlxRuntimeShader;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.Assets;

import states.EXEMenu;

class OptionsState extends MusicBeatState
{
	var bg:FlxSprite;
	var objsGrp:FlxTypedGroup<FlxSprite>;
	var title:FlxSprite;

	var sectionsList = ["CONTROLS", "VISUALS", "GRAPHICS", "GAMEPLAY", "LANGUAGE"];
	var sectionsGrp:FlxTypedGroup<FlxText>;
	var sectionBGGrp:FlxTypedGroup<FlxSprite>;
	var sectionBGClone:FlxSprite;
	var propBGCloneShader:FlxRuntimeShader;
	var selectionTween:FlxTween;
	var sectionPos:Array<Dynamic> = [];

	public static var curSelected:Int = 0;
	public static var onPlayState:Bool = false;

	var canAction:Bool = true;

	final GLOBAL_SCALE:Float = (FlxG.width / 3840);

	override public function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/bg.png'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		objsGrp = new FlxTypedGroup<FlxSprite>();
		add(objsGrp);

		for (i in 0...7)
		{
			var obj = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/objs/' + (i + 1) + '.png'));
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

		sectionBGClone = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
		sectionBGClone.setGraphicSize(Std.int(sectionBGClone.width * GLOBAL_SCALE));
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

		sectionBGGrp = new FlxTypedGroup<FlxSprite>();
		add(sectionBGGrp);

		sectionsGrp = new FlxTypedGroup<FlxText>();
		add(sectionsGrp);

		for (i in 0...sectionsList.length)
		{
			var section = new FlxText(0, 0, 0, sectionsList[i], 50);
			section.setFormat(Paths.font("SonicCD.ttf"), 28, FlxColor.WHITE, CENTER);
			section.ID = i;
			section.screenCenter(X);
			var sep = 14;
			var y = title.y + section.size + sep;
			section.y = y + 110;

			switch (section.ID)
			{
				case 0, 1:
					section.x += (300 * ((section.ID == 1) ? 1 : -1));
				case 2:
					section.y += (section.size + sep) * 4;
				case 3, 4:
					section.x += (300 * ((section.ID == 4) ? 1 : -1));
					section.y += (section.size + sep) * 8;
			}

			sectionsGrp.add(section);
			sectionPos.push({x: section.x, y: section.y});

			var sectionBG = new FlxSprite().loadGraphic(Assets.getBitmapData('assets/exe/options/propertyBG.png'));
			var sectionWidth = 28 * sectionsList[i].length;
			sectionBG.setGraphicSize(Std.int(sectionBG.width * GLOBAL_SCALE));
			sectionBG.updateHitbox();
			sectionBG.ID = i;
			sectionBG.x = section.x + ((sectionWidth - sectionBG.width) / 2);
			sectionBG.y = (section.y - (section.size / 2)) + (sep * 2.5);
			sectionBGGrp.add(sectionBG);
		}

		changeSelect();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		objsGrp.forEachExists(function(o)
		{
			if (o.y > FlxG.height || o.x > FlxG.width || o.y < -o.height || o.x < -o.width)
				resetObj(o);
		});

		sectionsGrp.forEachExists(function(txt)
		{
			if (sectionPos.length > 0)
			{
				var lerpX = FlxMath.lerp(txt.x, sectionPos[txt.ID].x, elapsed * 9);
				var lerpY = FlxMath.lerp(txt.y, sectionPos[txt.ID].y, elapsed * 9);
				if (txt.ID != curSelected)
				{
					txt.x = lerpX;
					txt.y = lerpY;
				}
				var sectionWidth = 28 * sectionsList[txt.ID].length;
				var sep = 14;
				var bg = sectionBGGrp.members[txt.ID];
				bg.x = txt.x + ((sectionWidth - bg.width) / 2);
				bg.y = (txt.y - (txt.size / 2)) + (sep * 2.5);
			}
		});

		if (!canAction) return;

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelect(controls.UI_LEFT_P ? -1 : 1);
		}

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			select();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (onPlayState)
			{
				onPlayState = false;
				backend.StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else FlxG.switchState(() -> new EXEMenu());
		}
	}

	var selectionCloneTween:FlxTween;

	function changeSelect(x:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + x, 0, sectionsList.length - 1);
		if (sectionBGGrp.members[curSelected] == null) return;

		var curSectionBG = sectionBGGrp.members[curSelected];
		var curSectionText = sectionsGrp.members[curSelected];
		var currentPos = sectionPos[curSelected];

		sectionBGClone.setPosition(curSectionBG.x - 3, curSectionBG.y - 3);
		curSectionBG.x -= 8;
		curSectionBG.y -= 8;
		curSectionText.x -= 8;
		curSectionText.y -= 8;

		if (selectionTween != null) selectionTween.cancel();
		selectionTween = FlxTween.tween(curSectionText, {x: currentPos.x - 12, y: currentPos.y - 16}, 0.18, {
			ease: FlxEase.quadInOut,
			onComplete: (_) -> selectionTween = null
		});

		if (selectionCloneTween != null) selectionCloneTween.cancel();
		selectionCloneTween = FlxTween.tween(sectionBGClone, {x: curSectionBG.x + 13, y: curSectionBG.y + 13}, 0.2, {
			ease: FlxEase.quadInOut,
			onComplete: (_) -> selectionCloneTween = null
		});
	}

	function select()
	{
		canAction = false;
		var curSectionText = sectionsGrp.members[curSelected];
		FlxFlicker.flicker(curSectionText, 1, 0.06, true, false, (_) -> canAction = true);

		new FlxTimer().start(1.5, function(_)
		{
			switch (sectionsList[curSelected])
			{
				case "CONTROLS":  FlxG.switchState(() -> new options.ExeControlsState());
				case "VISUALS":   FlxG.switchState(() -> new options.ExeVisualsState());
				case "GRAPHICS":  FlxG.switchState(() -> new options.ExeGraphicsState());
				case "GAMEPLAY":  FlxG.switchState(() -> new options.ExeGameplayState());
				case "LANGUAGE":
					#if TRANSLATIONS_ALLOWED
					openSubState(new options.LanguageSubState());
					#end
			}
			canAction = true;
		});
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

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		canAction = true;
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function destroy()
	{
		if (selectionTween != null)      { selectionTween.cancel();      selectionTween = null; }
		if (selectionCloneTween != null) { selectionCloneTween.cancel(); selectionCloneTween = null; }
		bg = null; objsGrp = null; title = null;
		sectionsGrp = null; sectionBGGrp = null;
		sectionBGClone = null; propBGCloneShader = null; sectionPos = null;
		super.destroy();
	}
}
