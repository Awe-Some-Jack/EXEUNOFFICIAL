package states.extras;

import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import sys.io.File;
import flixel.*;
import objects.*;

import flixel.addons.display.shapes.*;

var data:Dynamic;
var files:Array<String> = [];
var jsons:Dynamic;

var curChar:Int = 0;

var chars_list:Array<String> = [];
var offsets_list:Array<Dynamic> = [];
var icon_offset:Array<Dynamic> = [];
var bios_list:Array<String> = [];
var artist_list:Array<String> = [];

var CAM_FOLLOW:FlxObject;

var namesGrp:FlxTypedGroup<FlxText>;

var character:Character;
var icon:HealthIcon;

var circle:FlxShapeCircle;
var circleBig:FlxShapeCircle;

var bioBox:FlxShapeBox;

var textCenter:FlxSprite;

var charName:FlxText;
var artistName:FlxText;
var bioTxt:FlxText;

var boxCanva:FlxCamera;

var scrollTxt:FlxText;

var helpCanva:FlxCamera;
var bgThing:FlxSprite;
var helpText:FlxText;
class CharacterBIOS extends MusicBeatState
{
	override function create()
	{
		super.create();

		var folderPath = "assets/exe/extras/bios";
		if (FileSystem.exists(folderPath)) {
		    for (file in FileSystem.readDirectory(folderPath)) {
		        if (file.endsWith(".json")) {
		            var nameOnly = haxe.io.Path.withoutExtension(file);
					files.push(nameOnly);
				}
		    }
		}

		for (fl in files)
		{
		    jsons = File.getContent('assets/exe/extras/bios/' + fl + '.json');
		    data = Json.parse(jsons);

			chars_list[data.list_position] = fl;
			icon_offset[data.list_position] = [
				data.icon_offset[0],
				data.icon_offset[1]
			];
			bios_list[data.list_position] = data.bio;
			artist_list[data.list_position] = data.artist;
			offsets_list[data.list_position] = [
			    data.char_offset[0],
			    data.char_offset[1]
			];
		}

		CAM_FOLLOW = new FlxObject(0, 0, 1, 1);
		add(CAM_FOLLOW);

		namesGrp = new FlxTypedGroup<FlxText>();
		add(namesGrp);

		for (i in 0...chars_list.length)
		{
			var chars = new FlxText(20, 0 + (i * 60), chars_list[i], 30);
			chars.setFormat(Paths.font('NiseSegaSonic.TTF'), 60, FlxColor.WHITE, LEFT);
			chars.ID = i;
			chars.scrollFactor.x = 0;

			if (chars.ID == 0)
				CAM_FOLLOW.setPosition(chars.x, chars.y);

			namesGrp.add(chars);
		}
		var spikestop:FlxBackdrop = new FlxBackdrop(Assets.getBitmapData('assets/exe/bios/backdrop.png'), Y);
		spikestop.antialiasing = ClientPrefs.data.antialiasing;
		spikestop.velocity.y = 60;
		spikestop.screenCenter();
		spikestop.scrollFactor.set();
		add(spikestop);

		character = new Character(0, 0, 'faker', true);
		character.scrollFactor.set();
		add(character);

		circle = new FlxShapeCircle(810, 440, 40, {thickness:0,color:FlxColor.TRANSPARENT}, FlxColor.BLACK);
        circle.alpha = 0.75;
		circle.scrollFactor.set();
        add(circle);

		circleBig = new FlxShapeCircle(804, 434, 46, {thickness:4,color:FlxColor.BLACK}, FlxColor.TRANSPARENT);
        circleBig.alpha = 0.75;
		circleBig.scrollFactor.set();
        add(circleBig);

		icon = new HealthIcon('faker', true);
		icon.scale.set(0.7, 0.7);
		icon.setPosition(786, 425);
		add(icon);

		textCenter = new FlxSprite(690,320);
		textCenter.makeGraphic(50, 50, FlxColor.TRANSPARENT);
		textCenter.scrollFactor.set();
		add(textCenter);

		charName = new FlxText(0, 30, chars_list[curChar], 40);
		charName.setFormat(Paths.font('NiseSegaSonic.TTF'), 80, FlxColor.WHITE, CENTER);
		charName.scrollFactor.set();
		add(charName);

		artistName = new FlxText(0, FlxG.height - 150, "", 40);
		artistName.setFormat(Paths.font('NiseSegaSonic.TTF'), 40, FlxColor.WHITE, CENTER);
		artistName.scrollFactor.set();
		artistName.text = 'by\n${artist_list[curChar]}';
		add(artistName);

		boxCanva = new FlxCamera(920, 50, 300, 600);
		boxCanva.bgColor = 0x00000000;
		FlxG.cameras.add(boxCanva, false); 

		helpCanva = new FlxCamera();
		helpCanva.bgColor = 0x00000000;
		FlxG.cameras.add(helpCanva, false); 

		bioBox = new FlxShapeBox(920,50, 300, 600, {thickness:4,color:FlxColor.WHITE}, FlxColor.TRANSPARENT);
		bioBox.scrollFactor.set();
		add(bioBox);

		bioTxt = new FlxText(5, 0, 290, bios_list[curChar], 24);
		bioTxt.setFormat(Paths.font('courbi.ttf'), 24, FlxColor.WHITE, LEFT);
		bioTxt.scrollFactor.set();
		bioTxt.cameras = [boxCanva];
		add(bioTxt);

		scrollTxt = new FlxText(0, 10, 0, "auto scroll: on", 30);
		scrollTxt.setFormat(Paths.font('NiseSegaSonic.TTF'), 30, FlxColor.WHITE, RIGHT);
		scrollTxt.scrollFactor.set();
		add(scrollTxt);

		var indiTxt = new FlxText(0, FlxG.height - 50, 0, "press [TAB] for help", 24);
		indiTxt.setFormat(Paths.font('NiseSegaSonic.TTF'), 24, FlxColor.WHITE, RIGHT);
		indiTxt.scrollFactor.set();
		indiTxt.x = bioBox.x + (bioBox.width - indiTxt.width) / 2;
		add(indiTxt);

		bgThing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgThing.scrollFactor.set();
		bgThing.alpha = 0.5;
		bgThing.visible = false;
		bgThing.cameras = [helpCanva];
		add(bgThing);
		
		helpText = new FlxText(0,0,0);
		helpText.setFormat(Paths.font("NiseSegaSonic.TTF"), 30, FlxColor.WHITE, CENTER);
		helpText.scrollFactor.set();
		helpText.visible = false;
		helpText.text = [
			"to navigate between characters, use the arrows",
			"[Up, Down] or the mouse wheel",
			"without hovering over the biography box",
			"",
			"to navigate within the biography",
			"hover over the biography box",
			"and use the mouse wheel",
			"",
			"if you do nothing for 5 seconds",
			"the biography will scroll automatically",
			"you can disable this in [auto scroll]",
			"",
			"PRESS [TAB] TO CLOSE THIS"
		].join("\n");
		helpText.screenCenter();
		helpText.cameras = [helpCanva];
		add(helpText);

		changeCharBio();

		FlxG.camera.follow(CAM_FOLLOW, null, 1);

	}

	var moveCounter:Float;
	var moveTween:FlxTween;
	var canScrollAutomactially:Bool = true;
	var canMove:Bool = true;

	var onHelpScreen:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (character.animation.curAnim != null && character.animation.curAnim.name == 'idle' && character.animation.curAnim.finished)
        {
            character.playAnim('idle', true);
        }

		if (FlxG.keys.justPressed.TAB)
		{
			if (onHelpScreen)
			{
				onHelpScreen = false;
				bgThing.visible = false;
				helpText.visible = false;
			}
			else
			{
				onHelpScreen = true;
				bgThing.visible = true;
				helpText.visible = true;
			}
		}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new ExtrasMenu());
			}

			if (FlxG.mouse.overlaps(scrollTxt))
			{
				scrollTxt.color = FlxColor.YELLOW;

				if (FlxG.mouse.justPressed)
				{
					canScrollAutomactially = !canScrollAutomactially;
					
					if (!canScrollAutomactially)
					{
						if (moveTween != null){
				moveTween.cancel();
				moveTween = null;
			}
			moveCounter = 0;
					canMove = true;
					}
				}
			}
			else
			{
				scrollTxt.color = FlxColor.WHITE;
			}

			if (canScrollAutomactially) scrollTxt.text = "auto scroll: on";
			else scrollTxt.text = "auto scroll: off";

			charName.x = textCenter.x + (textCenter.width - charName.width) / 2;
			artistName.x = textCenter.x + (textCenter.width - artistName.width) / 2;
			scrollTxt.x = bioBox.x + (bioBox.width - scrollTxt.width) / 2;

			if (controls.RESET)
				FlxG.resetState();

			var canScroll:Bool = bioTxt.height > 600;

			if (canScrollAutomactially)
			{

				moveCounter += elapsed;

			if (canScroll && moveCounter > 5 && canMove)
			{
				canMove = false;
				moveTween = FlxTween.tween(bioTxt, {y: -(bioTxt.height - 600)}, 10);
			}
			}

			if (FlxG.mouse.wheel != 0 && FlxG.mouse.overlaps(bioBox) && canScroll)
			{
				if (canScrollAutomactially)
				{
					if (moveTween != null){
						moveTween.cancel();
						moveTween = null;
					}

					moveCounter = 0;
					canMove = true;
				}

				bioTxt.y += FlxG.mouse.wheel * 10;

				if (bioTxt.y > 0) bioTxt.y = 0;
				if (bioTxt.y < -(bioTxt.height - 600)) bioTxt.y = -(bioTxt.height - 600); 
			}

			if (chars_list.length > 1)
			{
			if (FlxG.mouse.wheel != 0 && !FlxG.mouse.overlaps(bioBox))
				changeCharBio(-FlxG.mouse.wheel * 1);
			if (controls.UI_UP_P)
				changeCharBio(-1);
			if (controls.UI_DOWN_P)
				changeCharBio(1);
			}
	}

	function moveDebbug(obj:FlxCamera)
	{
		if (FlxG.keys.justPressed.I)
				obj.scroll.y -= 10;
			if (FlxG.keys.justPressed.K)
				obj.scroll.y += 10;
			if (FlxG.keys.justPressed.J)
				obj.scroll.x -= 10;
			if (FlxG.keys.justPressed.L)
				obj.scroll.x += 10;

			if (FlxG.keys.justPressed.ANY)
				trace('x: ${obj.x} y: ${obj.y}');
			
	}

	function scaleDebbug(obj:FlxShape)
	{
		if (FlxG.keys.justPressed.F)
				obj.shapeWidth -= 10;
			if (FlxG.keys.justPressed.H)
				obj.shapeWidth += 10;
			if (FlxG.keys.justPressed.T)
				obj.shapeHeight -= 10;
			if (FlxG.keys.justPressed.G)
				obj.shapeHeight += 10;

			if (FlxG.keys.justPressed.ANY)
				trace('x: ${obj.shapeWidth} y: ${obj.shapeHeight}');
			
	}

	function changeCharBio(ola:Int = 0)
	{
		if (canScrollAutomactially)
		{
			if (moveTween != null){
				moveTween.cancel();
				moveTween = null;
			}
		
			moveCounter = 0;
			canMove = true;
		}

		curChar = FlxMath.wrap(curChar + ola, 0, chars_list.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);

		character.changeCharacter(chars_list[curChar]);
		icon.changeIcon(chars_list[curChar]);
		character.scale.set(0.5, 0.5);
		character.setPosition(offsets_list[curChar][0], offsets_list[curChar][1]);


		bioTxt.text = bios_list[curChar];
		bioTxt.y = 0;

		icon.setPosition(icon_offset[curChar][0], icon_offset[curChar][1]);

		charName.text = chars_list[curChar];
		artistName.text = 'by\n${artist_list[curChar]}';

		namesGrp.forEach(function(t:FlxText){
			if (t.ID == curChar)
			{
				t.color = FlxColor.YELLOW;
				CAM_FOLLOW.setPosition(t.x, t.y);
			}
			else
				t.color = FlxColor.WHITE;
		});
	}
}
