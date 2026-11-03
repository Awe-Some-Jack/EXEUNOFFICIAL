import flixel.addons.display.FlxBackdrop;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;

import lime.app.Application;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.Rectangle;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

import backend.MusicBeatState;
import backend.StageData;
import backend.Language;
import objects.Character;

using StringTools;

var hud1:FlxSprite;
var hud2:FlxSprite;
var icon:FlxSprite;
var bg1:FlxSprite;
var bg2:FlxSprite;
var bg3:FlxSprite;
var dadHitbox:FlxSprite;
var blackboard:FlxSprite;
var triangle:FlxSprite;
var sixSeven:FlxSprite;
var sixSevenHitbox:FlxSprite;
var flash:FlxSprite;
var numbers:Array<FlxSprite> = [];
var numbersHitbox:Array<FlxSprite> = [];
var stoplightHitboxes:Array<FlxSprite> = [];
var tweensX:Array<FlxTween> = [];
var tweensY:Array<FlxTween> = [];

var lastX:Float = 0;
var lastY:Float = 0;
var thingy:Int = 0;
var numClicked:Int;
var clicked:Bool = false;
var helpActive:Bool = false;
var flipped:Bool = false;
var usingBG3:Bool = false;
var continueTween:Bool = false;
var isSixSeven:Bool = false;
var canHandleMouse:Bool = true;

var customFraction:FlxSpriteGroup;

var lastScreenX:Float = 0;
var healthTxt:FlxText;
var equation:FlxText;
var side1:FlxText;
var side2:FlxText;
var side3:FlxText;
var inQuestion:Bool = false;
var ela:Float = 0;
var answer:Int = 0;
var counter:Float = 0;
var correctHovering:Bool = false;
var numHovering:Bool = false;
var dadHovering:Bool = false;
var hoverGlow:Float = 0;
var questionReady:Bool = true;
var clickHintLeft:Float = 0;
var clickWasPlaying:Bool = false;
var stoplightHovering:Bool = false;

final separation:Int = 50;

function getSchoolFont():String {
	return switch (Language.currentKey) {
		case 'ja-JP': 'schoolhouse-japanese.ttf';
		case 'ko-KR': 'schoolhouse-korean.ttf';
		case 'zh-CN': 'schoolhouse-chinese.ttf';
		default: 'schoolhouse.ttf';
	};
}

function onCreate() {
	canHandleMouse = true;

	bg1 = new FlxSprite(-345, -280).loadGraphic(Paths.image('bg/bg-phase1', 'PARALLAX'));
	bg1.scale.set(0.8, 0.8);
	bg1.antialiasing = false;
	bg1.updateHitbox();
	addBehindGF(bg1);

	bg2 = new FlxSprite(-345, -280).loadGraphic(Paths.image('bg/bg-phase2', 'PARALLAX'));
	bg2.scale.set(0.8, 0.8);
	bg2.alpha = 0.00001;
	bg2.antialiasing = false;
	bg2.updateHitbox();
	addBehindGF(bg2);

	bg3 = new FlxSprite(-345, -280).loadGraphic(Paths.image('bg/bg-phase3', 'PARALLAX'));
	bg3.scale.set(0.8, 0.8);
	bg3.alpha = 0.00001;
	bg3.antialiasing = false;
	bg3.updateHitbox();
	addBehindGF(bg3);

	hud1 = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/schoolhouse_hud_normal', 'PARALLAX'));
	hud1.scale.set(1.5, 1.5);
	hud1.antialiasing = false;
	hud1.cameras = [camVideo];
	hud1.updateHitbox();
	hud1.screenCenter();
	add(hud1);

	hud2 = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/schoolhouse_hud_melting', 'PARALLAX'));
	hud2.scale.set(1.5, 1.5);
	hud2.alpha = 0.00001;
	hud2.antialiasing = false;
	hud2.cameras = [camVideo];
	hud2.updateHitbox();
	hud2.screenCenter();
	add(hud2);

	blackboard = new FlxSprite(0, 0).loadGraphic(Paths.image('math/blackboard', 'PARALLAX'));
	blackboard.scale.set(2.7, 2.7);
	blackboard.antialiasing = false;
	blackboard.cameras = [camOther];
	blackboard.updateHitbox();
	blackboard.screenCenter();
	blackboard.scale.x = 0;
	blackboard.alpha = 0.8;
	add(blackboard);

	triangle = new FlxSprite(0, 0).loadGraphic(Paths.image('math/triangle', 'PARALLAX'));
	triangle.scale.set(2.7, 2.7);
	triangle.alpha = 0;
	triangle.antialiasing = false;
	triangle.cameras = [camOther];
	triangle.updateHitbox();
	triangle.screenCenter();
	add(triangle);

	black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black.alpha = 1;
	add(black);
}

function onCreatePost() {
	FlxG.autoPause = false;
	
	camZooming = false;
	camGame.pixelPerfectRender = camVideo.pixelPerfectRender = camHUD.pixelPerfectRender = camOther.pixelPerfectRender = true;

	camHUD.alpha = 0;

	healthTxt = new FlxText(0, 0, FlxG.width, "", 30);
	healthTxt.font = Paths.font(getSchoolFont());
	healthTxt.cameras = [camVideo];
	healthTxt.screenCenter();
	healthTxt.scrollFactor.set();
	healthTxt.borderSize = 1;
	healthTxt.antialiasing = false;
	healthTxt.x += 50;
	healthTxt.y += 320;
	add(healthTxt);
	
	equation = new FlxText(0, 0, FlxG.width, "Cumming straight from YOUR house", 30);
	equation.setFormat(Paths.font(getSchoolFont()), Language.cjkSize(50, 0.85), FlxColor.WHITE, FlxTextAlign.CENTER, FlxColor.TRANSPARENT, true);
	equation.cameras = [camOther];
	equation.antialiasing = false;
	equation.screenCenter();
	equation.alpha = 0;
	add(equation);

	side1 = new FlxText(0, 0, FlxG.width, "", 30);
	side1.setFormat(Paths.font(getSchoolFont()), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxColor.TRANSPARENT, true);

	side2 = new FlxText(0, 0, FlxG.width, "", 30);
	side2.setFormat(Paths.font(getSchoolFont()), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxColor.TRANSPARENT, true);

	side3 = new FlxText(0, 0, FlxG.width, "", 30);
	side3.setFormat(Paths.font(getSchoolFont()), 40, FlxColor.WHITE, FlxTextAlign.CENTER, FlxColor.TRANSPARENT, true);

	side3.cameras = side2.cameras = side1.cameras = [camOther];
	side3.antialiasing = side2.antialiasing = side1.antialiasing = false;

	side1.screenCenter();
	side2.screenCenter();
	side3.screenCenter();
	side3.alpha = side2.alpha = side1.alpha = 0;

	side1.x += 90;
	side1.y += 20;

	side2.x += 10;
	side2.y += 100;

	side3.x -= 20;
	side3.y -= 10;

	add(side1);
	add(side2);
	add(side3);

	for(i in 0...10) {
		var nun = new FlxSprite(0, 0).loadGraphic(Paths.image('math/' + i, 'PARALLAX'));
		nun.scale.set(1.5, 1.5);
		nun.antialiasing = false;
		nun.cameras = [camOther];
		nun.updateHitbox();
		nun.x = -20;
		nun.y = 0;
		nun.alpha = 0;
		numbers.push(nun);

		var nunH = new FlxSprite(0, 0).makeGraphic(91, 118, 0xFFFF0000);
		nunH.scale.set(1.5, 1.5);
		nunH.antialiasing = false;
		nunH.cameras = [camOther];
		nunH.updateHitbox();
		nunH.x = nun.x+17;
		nunH.y = nun.y;
		nunH.visible = false;
		numbersHitbox.push(nunH);

		add(numbers[i]);
		add(numbersHitbox[i]);
	}

	sixSeven = new FlxSprite(0, 0).loadGraphic(Paths.image('math/67', 'PARALLAX'));
	sixSeven.scale.set(1.5, 1.5);
	sixSeven.antialiasing = false;
	sixSeven.cameras = [camOther];
	sixSeven.updateHitbox();
	sixSeven.x = -20;
	sixSeven.y = 0;
	sixSeven.alpha = 0;
	add(sixSeven);

	sixSevenHitbox = new FlxSprite(0, 0).makeGraphic(165, 118, 0xFFFF0000);
	sixSevenHitbox.scale.set(1.5, 1.5);
	sixSevenHitbox.antialiasing = false;
	sixSevenHitbox.cameras = [camOther];
	sixSevenHitbox.updateHitbox();
	sixSevenHitbox.visible = false;
	add(sixSevenHitbox);

	dadHitbox = new FlxSprite(0, 0).makeGraphic(91, 208, 0xFFFF0000);
	dadHitbox.scale.set(1, 1);
	dadHitbox.antialiasing = false;
	dadHitbox.x = -35;
	dadHitbox.y = -60;
	dadHitbox.alpha = 0;
	add(dadHitbox);

	icon = new FlxSprite(0, 0);
	icon.frames = Paths.getSparrowAtlas('icons/bf-icon');
	icon.animation.addByPrefix('fine', 'finished bf1', 24, true);
	icon.animation.addByPrefix('dying', 'finished bf2', 24, true);
	icon.scale.set(0.67, 0.67);
	icon.antialiasing = false;
	icon.cameras = [camVideo];
	icon.x = 495;
	icon.y = 487;
	add(icon);

	for(i in 0...2) {
		var nun = new FlxSprite(0, 0).makeGraphic(45, 45, 0xFFFF0000);
		nun.scale.set(1.5, 1.5);
		nun.antialiasing = false;
		nun.cameras = [camVideo];
		nun.updateHitbox();
		nun.alpha = 0;
		nun.x = 850;
		nun.y = i == 0 ? 260 : 347;

		stoplightHitboxes.push(nun);
		add(stoplightHitboxes[i]);
	}

	boyfriendGroup.visible = iconP1.visible = iconP2.visible = healthBar.visible = false;

	gf.x = dad.x;
	gf.y = dad.y;

	gf.animSuffix = '-alt';
	gf.alpha = 0;
	gf.recalculateDanceIdle();

	flash = new FlxSprite(0, 0).makeGraphic(3000, 3000, 0xFFFFFFFF);
	flash.antialiasing = false;
	flash.updateHitbox();
	flash.scrollFactor.set();
	flash.blend = BlendMode.ADD;
	flash.alpha = 0;
	add(flash);
}

function onCountdownStarted() {
	new FlxTimer().start(10, function(tmr:FlxTimer) {
		for(i in 0...tweensX.length) if(!inQuestion) tweensX[i].active = tweensY[i].active = false;
	});

	for (i in 0...4) {
		opponentStrums.members[i].x = -1000;
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i);
	}
}

function createProblem(types:Array<Int>, ?flash:Bool = false, ?preNum:Int, ?hardEquation:String) {
	counter = 0;
	game.canPause = helpActive = false;
	continueTween = true;
	
	if(!flash && !inQuestion) {
		inQuestion = true;
		questionReady = false;
		clicked = false;
		isSixSeven = false;

		if (customFraction != null) {
			remove(customFraction);
			customFraction.destroy();
			customFraction = null;
		}

		var int1:Int = 0;
		var int2:Int = 0;

		equation.size = Language.cjkSize(50, 0.85);

		numbers[6].visible = numbers[7].visible = true;
		equation.screenCenter();

		thingy = FlxG.random.int(1, 1000) == 777 ? 12 : types[FlxG.random.int(0, types.length-1)];
	
		if(thingy == null) {
			trace("Failed to load question");
			return;
		}

		switch(thingy) {
			case 0: // addition
				if(FlxG.random.int(1, 100) == 67) {
					trace("SIX SEVEN");
					int1 = FlxG.random.int(10, 43);
					int2 = 67-int1;
					answer = 6;

					numbers[6].visible = numbers[7].visible = false;
					isSixSeven = true;
				} else {
					int1 = FlxG.random.int(0, 5);
					int2 = FlxG.random.int(0, 5);
					if(int1 + int2 == 10) int1--;
					answer = int1 + int2;
				}
				equation.text = Language.getPhrase('math_add', 'What does {1} + {2} equal? _', [int1, int2]);

			case 1: // subtraction
				int1 = FlxG.random.int(5, 10);
				int2 = FlxG.random.int(1, 5);

				answer = int1 - int2;
				equation.text = Language.getPhrase('math_sub', 'What does {1} - {2} equal? _', [int1, int2]);

			case 2: // multiplication
				int1 = FlxG.random.int(0, 4);
				int2 = FlxG.random.int(1, 3);
				if(int1 * int2 >= 10) int2--;
				answer = int1 * int2;
				equation.text = Language.getPhrase('math_mul', 'What does {1} X {2} equal? _', [int1, int2]);

			case 3: // division
				int1 = FlxG.random.int(1, 100);
				var int2list:Array<Int> = [];
				for(i in 0...int1)
					if(int1 % i == 0 && i != 1 && int1/i <= 9) int2list.push(i);

				while(int2list.length <= 1) {
					int2list = [];
					int1++;

					for(i in 0...int1+1)
						if(int1 % i == 0 && i != 1 && int1/i <= 9) int2list.push(i);
				}

				int2 = int2list[FlxG.random.int(0, int2list.length-1)];

				answer = Std.int(int1 / int2);
				
				equation.text = Language.getPhrase('math_div_frac', 'What does        equal? _');
				
				var fracX:Float = 475;
                var fracY:Float = 315;
                
                switch (Language.currentKey) {
                    case 'ja-JP':
                        fracX -= 230;
                    case 'ru-RU', "pt-BR": 
                        fracX += 75;
					case "de-DE", "pl-PL":
						fracX += 55;
					case "uz-UZ", 'zh-CN', 'ko-KR':
						fracX -= 170;
					case 'tr-TR':
						fracX -= 140;
					case 'en-PIRATE':
						fracX -= 7.5;
					case 'es-419', "uk-UA", "it-IT", "fr-FR":
						fracX += 100;
                }
                
                customFraction = createFraction(fracX, fracY, '$int1', '$int2', 40);
				insert(members.indexOf(equation) + 1, customFraction);

			case 4: // fill in the blank
				var int2Arr:Array<Int> = [];
				var lim = 0;
				int1 = FlxG.random.int(0, 9);

				for(i in 0...4) {
					int2Arr.push(int1+i);
					if(int2Arr[i] < 10) lim = i;
				}

				final spot:Int = FlxG.random.int(0, lim);
				final flip:Bool = FlxG.random.bool(50);

				answer = int2Arr[spot];

				if(!flip) {
					switch(spot) {
						case 0: equation.text = '_, ' + int2Arr[1] + ', ' + int2Arr[2] + ', ' + int2Arr[3];
						case 1: equation.text = int2Arr[0] + ', _, ' + int2Arr[2] + ', ' + int2Arr[3];
						case 2: equation.text = int2Arr[0] + ', ' + int2Arr[1] + ', _, ' + int2Arr[3];
						case 3: equation.text = int2Arr[0] + ', ' + int2Arr[1] + ', ' + int2Arr[2] + ', _';
					}
				} else {
					switch(spot) {
						case 3: equation.text = '_, ' + int2Arr[2] + ', ' + int2Arr[1] + ', ' + int2Arr[0];
						case 2: equation.text = int2Arr[3] + ', _, ' + int2Arr[1] + ', ' + int2Arr[0];
						case 1: equation.text = int2Arr[3] + ', ' + int2Arr[2] + ', _, ' + int2Arr[0];
						case 0: equation.text = int2Arr[3] + ', ' + int2Arr[2] + ', ' + int2Arr[1] + ', _';
					}
				}

			case 5: // what comes before
				int1 = FlxG.random.int(1, 10);
				answer = int1-1;
				equation.text = Language.getPhrase('math_before', 'What comes before {1}? _', [int1]);

			case 6: // what comes after
				int1 = FlxG.random.int(0, 8);
				answer = int1+1;
				equation.text = Language.getPhrase('math_after', 'What comes after {1}? _', [int1]);

			case 7: // find the variable
				final flip:Bool = FlxG.random.bool(50);

				int1 = FlxG.random.int(1, 9);
				int2 = FlxG.random.int(1, 9);
				answer = FlxG.random.int(2, 9);
				
				if(flip) {
					while((int1*answer)-int2 < 0) int2--;
					final int3 = (int1*answer) - int2;
					equation.text = (int1 == 1) 
						? Language.getPhrase('math_solve_x_sub_1', 'Solve for X: X - {1} = {2} _', [int2, int3]) 
						: Language.getPhrase('math_solve_x_sub_2', 'Solve for X: {1}X - {2} = {3} _', [int1, int2, int3]);
				} else {
					final int3 = (int1*answer) + int2;
					equation.text = (int1 == 1) 
						? Language.getPhrase('math_solve_x_add_1', 'Solve for X: X + {1} = {2} _', [int2, int3]) 
						: Language.getPhrase('math_solve_x_add_2', 'Solve for X: {1}X + {2} = {3} _', [int1, int2, int3]);
				}

			case 8: // trig (pythagorean theorem)
				if(FlxG.random.bool(5)) {
					int1 = FlxG.random.int(1, 9);
					int2 = FlxG.random.int(2, 9);
					
					answer = Math.round(Math.sqrt((Math.pow(int1, 2) + Math.pow(int2, 2))));
					while(answer > 9) {
						int2--;
						answer = Math.round(Math.sqrt((Math.pow(int1, 2) + Math.pow(int2, 2))));
					}
					equation.text = Language.getPhrase('math_c_approx', 'What does C approximately equal? ~_');
					equation.size = Language.cjkSize(40, 0.85);
				} else {
					int1 = 3;
					int2 = 4;
					answer = 5;
					equation.text = Language.getPhrase('math_c_exact', 'What does C equal? _');
				}
				side1.text = int1>int2 ? '$int2' : '$int1';
				side2.text = int1>int2 ? '$int1' : '$int2';
				side3.text = 'C';

				equation.y -= 90;
				
			case 9: // derivative
				int1 = FlxG.random.int(2, 9);
				int2 = FlxG.random.int(2, 9);
				final int3:Int = int2-1;
				while(int1*int2 >= 10) int1--;

				answer = int1*int2;

				equation.size = Language.cjkSize(40, 0.85);
				equation.text = int1 == 1 
					? Language.getPhrase('math_deriv_1', 'What is the derivative of X^{1}? _X^{2}', [int2, int3]) 
					: Language.getPhrase('math_deriv_2', 'What is the derivative of {1}X^{2}? _X^{3}', [int1, int2, int3]);

			case 10: // sin, cos
				var nums:Array<Int> = [0, 30, 90];
				int1 = nums[FlxG.random.int(0,2)];
				int2 = FlxG.random.int(0, 18);
				if(int2 % 2 != 0 && int2 != 0) int2++;

				equation.size = Language.cjkSize(45, 0.85);

				switch(FlxG.random.int(0, 1)) {
					case 0:
						if(int1 == 90) int2 = Std.int(int2 / 2);
						answer = Math.round(Math.sin(int1 * (Math.PI / 180)) * int2);
						equation.text = Language.getPhrase('math_sin', 'What does sin({1}) X {2} equal? _', [int1, int2]);
					case 1:
						if(int1 == 30) int1 = 60;
						if(int1 == 0) int2 = Std.int(int2 / 2);
						answer = Math.round(Math.cos(int1 * (Math.PI / 180)) * int2);
						equation.text = Language.getPhrase('math_cos', 'What does cos({1}) X {2} equal? _', [int1, int2]);
				}

			case 11: // symbols
				equation.size = Language.cjkSize(38, 0.85);
				switch(FlxG.random.int(0, 3)) {
					case 0:
						answer = 3;
						equation.text = FlxG.random.bool(66) 
							? Language.getPhrase('math_pi', 'What does Pi approximately equal? ~_') 
							: Language.getPhrase('math_e', 'What does e approximately equal? ~_');
					case 1:
						answer = 2;
						equation.text = Language.getPhrase('math_phi', 'What does Phi approximately equal? ~_');
					case 2:
						answer = 1;
						equation.text = Language.getPhrase('math_i', 'What does -i^2 equal? _');
					case 3:
						answer = 6;
						equation.text = Language.getPhrase('math_tau', 'What does Tau approximately equal? ~_');
				}

			case 12: // Super-rare (0.1% chance)
				equation.size = Language.cjkSize(28, 0.85);
				equation.text = Language.getPhrase('math_eval_long', 'Evaluate:               + sum_(n=1)^inf(1/2)^n + d/dx(x^3)|x=1 = _');
				answer = 5; 
				
				if (customFraction != null) {
					remove(customFraction);
					customFraction.destroy();
				}

				var fracX:Float = 270;
                var fracY:Float = 315;
                
                switch (Language.currentKey) {
                    case 'ru-RU': 
                        fracX += 15;
					case "pl-PL":
						fracX -= 5;
					case "zh-CN":
						fracX += 40;
					case 'tr-TR':
						fracX += 2.5;
					case 'en-PIRATE':
						fracX += 85;
					case "uk-UA", "de-DE":
						fracX += 5;
					case 'es-419', "uk-UA", "it-IT", "fr-FR":
						fracX -= 5;
                }
				
				customFraction = createFraction(fracX, fracY, "e^x - 1", "x", 28);
				insert(members.indexOf(equation) + 1, customFraction);
		}
		
		if(answer >= 10) answer = 9;

		FlxTween.tween(blackboard.scale, {x: 2.7}, 0.4, {
			ease: FlxEase.bounceOut,
			onComplete: function(_) {
				if(numClicked != null) {
					numbers[numClicked].x = lastX;
					numbers[numClicked].y = lastY;
				}
				for(i in 0...numbers.length) {
					if(tweensX[i] != null && tweensY[i] != null) tweensX[i].active = tweensY[i].active = true;
					numbers[i].scale.set(1.5, 1.5);
					FlxTween.tween(numbers[i], {alpha: 1}, 0.4, {ease: FlxEase.smoothStepOut});
				}
				
				FlxTween.tween(equation, {alpha: 1}, 0.4, {ease: FlxEase.smoothStepOut});
				if (customFraction != null) FlxTween.tween(customFraction, {alpha: 1}, 0.4, {ease: FlxEase.smoothStepOut});
				
				if(thingy == 8) FlxTween.tween(triangle, {alpha: 1}, 0.4, {ease: FlxEase.smoothStepOut});
				game.canPress = false;
				questionReady = true;
			}
		});
	} else if(flash && !inQuestion) {
		inQuestion = false;
		if(hardEquation == "") {
			FlxTween.tween(equation, {alpha: 0}, 1, {ease: FlxEase.smoothStepOut});
			FlxTween.tween(blackboard.scale, {x: 0}, 1, {
				ease: FlxEase.bounceOut,
				onComplete: function(_) {
					equation.color = blackboard.color = 0xFFFFFFFF;
					equation.text = "";
				}
			});
		} else {
			FlxTween.shake(equation, 0.025, 3.1);
			FlxTween.shake(blackboard, 0.025, 3.1);

			final hardList = Language.getArray('math_hard_list', [
				'lim X->inf (3X^2+5)/(X^2-1) _',
				'What is tan(45)*9 _',
				'Solve for X: (X^6-9)/(X-3) _',
				'The answer is wrong.',
				'7(pi+(x^4(1-x)^4)/(1+x^2)) = _',
				'lim X->inf pi(x)/(x/lnx) = 1 _',
				'What does tan^-1*cos(3!!) equal? _',
				'Solve for X: -5*15^(x+8) = -56 _',
				'Simplify: (8x^3+14x^2+15x+18)/(2x+3) _',
				'Simplify: 5(2xy^2+3x^2y-xy) _',
				'What is cos(asin(sin(ln(e^3!)))) _',
				'Factor: 7x^3+4x^2-6x+9'
			]);
			hardEquation = hardList[FlxG.random.int(0, hardList.length-1)];
			
			equation.text = '$hardEquation';
			equation.color = blackboard.color = 0xFFFF0000;
			FlxTween.tween(blackboard.scale, {x: 2.7}, 0.4, {
				ease: FlxEase.bounceOut,
				onComplete: function(_) {
					FlxTween.tween(equation, {alpha: 1}, 0.4, {ease: FlxEase.smoothStepOut});
				}
			});
			FlxTween.tween(game, {health: 0.001}, 2, {
				ease: FlxEase.smootherStepOut,
				onComplete: function(_) {
					createProblem([0], true, 0, "");
				}
			});
		}
	}
}

function onStepHit() {
	switch(curStep) {
		case 256, 576: createProblem([0, 0, 1, 2, 3], false);
		case 456: createProblem([4, 5, 6], false);
		case 784: createProblem([8], false);
		case 1240, 1308, 1446: createProblem([0], true, 0, 'h');
		case 1536: createProblem([9, 11, 11], false);
		case 1600: createProblem([7, 10], false);
		case 152: FlxTween.tween(camHUD, {alpha: 1}, 0.86, {ease: FlxEase.smoothStepInOut});
		case 384, 896: switchStage(0.00001, 1, 0, 'linear');
		case 1216:
			usingBG3 = true;
			switchStage(0.00001, 1, 0, 'linear');
		case 640, 1024, 1152: switchStage(0.86, 0, 1, 'linear');
		case 656, 1552: switchStage(1.72, 0.5, 1, 'cubeOut');
		case 1648:
			usingBG3 = false;
			switchStage(1.72, 0.5, 1, 'cubeOut');
		case 672, 1567, 1664: switchStage(0.86, 0, 1, 'smootherStepOut');
		case 1088:
			createProblem([9], false);
			switchStage(3.44, 1, 0, 'smoothStepIn');
		case 1696:
			usingBG3 = true;
			switchStage(3.44, 1, 0, 'smoothStepIn');
		case 1472: switchStage(1.72, 0, 1, 'smootherStepOut');
		case 1728: switchStage(0.86, 0, 1, 'smootherStepOut');
		case 1736: FlxTween.tween(camHUD, {alpha: 0}, 0.86, {ease: FlxEase.smoothStepOut});
	}
}

function switchStage(time:Float = 1, ?amount1:Float = 1, ?amount2:Float = 0, tween:String) {
	final easeFunction = Reflect.hasField(FlxEase, tween) ? Reflect.field(FlxEase, tween) : FlxEase.linear;

	if(usingBG3 && Math.round(time) == 0) {
		FlxTween.cancelTweensOf(flash);
		flash.color = 0xFF990000;
		flash.alpha = 1;
		FlxTween.tween(flash, {alpha: 0}, 0.86, {ease: BlendMode.LINEAR});
	} else if(Math.round(time) == 0) {
		FlxTween.cancelTweensOf(flash);
		flash.color = 0xFFFFFFFF;
		flash.alpha = 1;
		FlxTween.tween(flash, {alpha: 0}, 0.86, {ease: BlendMode.LINEAR});
	}
	FlxTween.cancelTweensOf(gf);
	FlxTween.cancelTweensOf(dad);

	FlxTween.tween(gf, {alpha: amount1}, time, {ease: easeFunction});
	FlxTween.tween(dad, {alpha: amount2}, time, {ease: easeFunction});

	flipped = !flipped;
}

function opponentNoteHit(note:Note):Void {
	if(!note.isSustain && (dad.alpha >= 0.5 || usingBG3) && Math.round(gf.alpha) != 0) {
		var ghost = new Character(0, 0, dad.curCharacter, dad.isPlayer);
		ghost.x = dad.x;
		ghost.y = dad.y;
		if(usingBG3) ghost.color = 0xFFFF0000;
		ghost.alpha = gf.alpha;
		ghost.blend = BlendMode.SCREEN;
		ghost.angle = gf.angle;
		ghost.visible = gf.visible;
		ghost.playAnim(gf.animation.curAnim.name);
		addBehindGF(ghost);
		FlxTween.tween(ghost, {alpha: 0}, Conductor.stepCrochet/1000 * 8, {ease:FlxEase.quartOut,onComplete:function() {
			remove(ghost);
			ghost.destroy();
		}});
	}

	if(note.noteType == '') {
		var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;

		if(gf != null) {
			var canPlay:Bool = true;
			if(note.isSustainNote)
			{
				var holdAnim:String = animToPlay + '-hold';
				if(gf.animation.exists(holdAnim)) animToPlay = holdAnim;
				final _curCharAnim:String = gf.getAnimationName();
				if(_curCharAnim == holdAnim || _curCharAnim == holdAnim + '-loop') canPlay = false;
			}

			var charCurFrame = 0;
			if (gf.animation != null) charCurFrame = gf.animation.curAnim.curFrame;
			if (gf.getAnimationName().startsWith('sing') && note.isSustainNote && charCurFrame < 2) canPlay = false;
			if (note.noteType == 'Sustain Animation' && note.isSustainNote) canPlay = false;
			if(canPlay) gf.playAnim(animToPlay, true);
			gf.holdTimer = 0;
		}
	}
}

function onSongStart() {
	FlxTween.tween(black, {alpha: 0}, 6.88, {ease: FlxEase.smootherStepInOut});

	for(i in 0...numbers.length) {
		tweensX.push(null);
		tweensY.push(null);
	}
	for(i in 0...numbers.length) {
		startBounce(numbers[i], 800, -20, FlxG.random.float(1.5, 2.5), true, i);
		startBounce(numbers[i], 0, 540, FlxG.random.float(2, 3), false, i);
	}
}

function startBounce(sprite:FlxSprite, fromX:Float, toX:Float, duration:Float, doX:Bool, i:Int):Void {
	if(doX) {
		tweensX[i] = FlxTween.tween(sprite, {x: toX}, duration, {
			ease: FlxEase.smoothStepInOut,
			onComplete: function(_) {
				startBounce(sprite, toX, fromX, duration, true, i);
			}
		});
	} else {
		tweensY[i] = FlxTween.tween(sprite, {y: toX}, duration, {
			ease: FlxEase.smoothStepInOut,
			onComplete: function(_) {
				startBounce(sprite, toX, fromX, duration, false, i);
			}
		});
	}
}

function onPause() {
    for(i in 0...tweensX.length) {
        if(tweensX[i] != null) tweensX[i].active = false;
        if(tweensY[i] != null) tweensY[i].active = false;
    }
}

function onResume() {
    for(i in 0...tweensX.length) {
        tweensX[i].active = continueTween;
        tweensY[i].active = continueTween;
    }
}

function onUpdate(elapsed:Float) {
	ela += elapsed;
	if(curStep < 100) game.health = 1;

	updateHUD();
	handleMouseLogic();
}

function updateHUD() {
	if(!usingBG3) {
		hud2.alpha = bg2.alpha = gf.alpha;
		gf.color = 0xFFFFFFFF;
	} else {
		hud2.alpha = bg3.alpha = gf.alpha;
		gf.color = 0xFFffb3b3;
	}

	var hpValue = game.health <= 2 ? Std.int((game.health*100)/2) : 100;
	healthTxt.text = Language.getPhrase('math_health', 'Health: {1}%', [hpValue]);
	
	if(game.health >= 0.5) {
		icon.animation.play('fine', true);
		healthTxt.color = 0xFFFFFFFF;
	} else {
		icon.animation.play('dying', true);
		healthTxt.color = 0xFFFF0000;
	}

	side1.alpha = side2.alpha = side3.alpha = triangle.alpha;
	side1.visible = side2.visible = side3.visible = triangle.visible;

	if(isSixSeven) {
		sixSeven.x = numbers[6].x - 64;
		sixSeven.y = numbers[6].y;
		sixSeven.alpha = numbers[6].alpha;
		sixSeven.scale.x = sixSeven.scale.y = numbers[6].scale.x;

		if(tweensX[7] != null && tweensY[7] != null) tweensX[7].active = tweensY[7].active = false;
		
		sixSevenHitbox.x = sixSeven.x + 26;
		sixSevenHitbox.y = sixSeven.y;
		numbersHitbox[7].x = 10000;
	}
}

function isClickHint():Bool {
	var playing:Bool = false;
	for (educator in [dad, gf])
		if (educator != null && educator.alpha > 0.1 && educator.getAnimationName() == 'click' && !educator.isAnimationFinished()) playing = true;
	if (playing && !clickWasPlaying) clickHintLeft = 1.2;
	clickWasPlaying = playing;
	clickHintLeft = Math.max(0, clickHintLeft - FlxG.elapsed);
	return clickHintLeft > 0;
}

function updateEducatorGlow(active:Bool) {
	var target:Float = active ? 70 : (isClickHint() ? 40 + Math.sin(ela * 12) * 30 : 0);
	hoverGlow = FlxMath.lerp(hoverGlow, target, FlxMath.bound(FlxG.elapsed * 14, 0, 1));
	if (hoverGlow < 0.5 && target == 0) hoverGlow = 0;
	for (educator in [dad, gf])
		if (educator != null) educator.setColorTransform(educator.color.redFloat, educator.color.greenFloat, educator.color.blueFloat, educator.alpha, hoverGlow, hoverGlow, hoverGlow, 0);
}

function handleMouseLogic() {
	if (!canHandleMouse) {
		updateEducatorGlow(false);
		Mouse.cursor = MouseCursor.ARROW;
		return;
	}

	numHovering = false;
	dadHovering = false;
	stoplightHovering = false;

	if (inQuestion && !questionReady) {
		updateEducatorGlow(false);
		Mouse.cursor = MouseCursor.ARROW;
		return;
	}

	for(i in 0...numbers.length) {
		numbersHitbox[i].x = isSixSeven && i == 7 ? 10000 : numbers[i].x + 26;
		numbersHitbox[i].y = numbers[i].y;

		if(inQuestion && !clicked && FlxG.mouse.overlaps(numbersHitbox[i], camOther)) {
			numHovering = true;
			numClicked = i;
		}
	}

	if(inQuestion) {
		if (!clicked) {
            if(counter > 1) {
                helpActive = true;
                equation.text = isSixSeven ? StringTools.replace(equation.text, "_", '67') : StringTools.replace(equation.text, "_", '$answer');
                if(equation.alpha == 1) FlxTween.tween(equation, {alpha: 0.5}, 1, {ease: FlxEase.smoothStepOut});
                else if(equation.alpha == 0.5) FlxTween.tween(equation, {alpha: 1}, 1, {ease: FlxEase.smoothStepOut});

                for(i in 0...numbers.length)
                    if(i != answer) FlxTween.tween(numbers[i], {alpha: 0.5}, 0.5, {ease: FlxEase.smoothStepOut});
            }

            if(!numHovering && !helpActive && FlxG.mouse.overlaps(dadHitbox, camGame)) {
                dadHovering = true;
                if(blackboard.alpha == 0.8) FlxTween.tween(blackboard, {alpha: 0.5}, 0.3, {ease: FlxEase.linear});

                if(FlxG.mouse.justPressed) {
                    helpActive = true;

                    for(i in 0...numbers.length)
                        if(i != answer) FlxTween.tween(numbers[i], {alpha: 0.5}, 0.5, {ease: FlxEase.smoothStepOut});

                    equation.text = isSixSeven ? StringTools.replace(equation.text, "_", '67') : StringTools.replace(equation.text, "_", '$answer');
                }
            } else {
                if(blackboard.alpha == 0.5) FlxTween.tween(blackboard, {alpha: 0.8}, 0.3, {ease: FlxEase.linear});
            }
        }

		if((!clicked && FlxG.mouse.overlaps(numbersHitbox[answer], camOther)) || 
		   (!clicked && isSixSeven && FlxG.mouse.overlaps(sixSevenHitbox, camOther))) {
			
			correctHovering = true;
			if(FlxG.mouse.justPressed) {
				game.canPause = game.canPress = clicked = true;
				continueTween = correctHovering = numHovering = false;

				FlxTween.cancelTweensOf(blackboard);
				FlxTween.cancelTweensOf(equation);

				FlxTween.tween(blackboard, {alpha: 0.8}, 0.3, {ease: FlxEase.linear});
				FlxTween.tween(equation, {alpha: 1}, 0.3, {ease: FlxEase.linear});

				FlxG.sound.play(Paths.sound('sendit'), 1);

				for(i in 0...numbers.length) {
					tweensX[i].active = tweensY[i].active = false;
					lastX = numbers[answer].x;
					lastY = numbers[answer].y;
				}

				numClicked = answer;

				FlxTween.tween(numbers[answer].scale, {x: 0.6, y: 0.6}, 1, {ease: FlxEase.linear});
				FlxTween.tween(numbers[answer], {x: 390, y: -50}, 1, {ease: FlxEase.linear});

				new FlxTimer().start(1.5, (tmr:FlxTimer) -> {
					game.health += 0.5;

					FlxG.sound.play(isSixSeven ? Paths.sound('67') : Paths.sound('yay'), 1);

					for(i in 0...numbers.length)
						if(i != answer) FlxTween.tween(numbers[i], {alpha: 0}, 1, {ease: FlxEase.linear});
					
					equation.text = isSixSeven ? StringTools.replace(equation.text, "_", '67') : StringTools.replace(equation.text, "_", '$answer');
					
					if (customFraction != null) FlxTween.flicker(customFraction, 1.4, 0.2);
					
					FlxTween.flicker(isSixSeven ? sixSeven : numbers[answer], 1.4, 0.2, {onComplete: (_) -> numbers[answer].alpha = 0});
					FlxTween.flicker(equation, 1.4, 0.2, {
						onComplete: (_) -> {
							equation.alpha = 0;
							if (customFraction != null) customFraction.alpha = 0;
							
							FlxTween.tween(blackboard.scale, {x: 0}, 1, {
								ease: FlxEase.bounceOut,
								onComplete: (_) -> inQuestion = false
							});
						}
					});

					if(triangle.alpha == 1) {
						if(answer == 5) side3.text = '$answer'; else side3.text = '~$answer';
						side3.x -= 10;
						FlxTween.flicker(triangle, 1.4, 0.2, {onComplete: (_) -> triangle.alpha = 0});
					}
				});
			}
		} else {
			correctHovering = false;
		}
		
		if(!correctHovering && numHovering) {
			if(!clicked && FlxG.mouse.justPressed) {
				clicked = true;
				continueTween = inQuestion = correctHovering = numHovering = false;

				FlxG.sound.play(Paths.sound('sendit'), 1);

				for(i in 0...numbers.length) {
					tweensX[i].active = tweensY[i].active = false;
					if(i == numClicked) {
						lastX = numbers[i].x;
						lastY = numbers[i].y;

						FlxTween.tween(numbers[i].scale, {x: 0.6, y: 0.6}, 1, {ease: FlxEase.linear});
						FlxTween.tween(numbers[i], {x: 390, y: -50}, 1, {ease: FlxEase.linear});
					}
				}

				new FlxTimer().start(1.5, function(tmr:FlxTimer) {
					inQuestion = true;
					FlxG.sound.play(Paths.sound('incorrect'), 2);

					if(game.health-0.2 > 0) game.health -= 0.2;
					counter++;

					numbers[numClicked].x = lastX;
					numbers[numClicked].y = lastY;
					numbers[numClicked].scale.set(1.5, 1.5);
					numbers[numClicked].updateHitbox();

					for(i in 0...numbers.length)
						tweensX[i].active = tweensY[i].active = true;

					clicked = false;
					continueTween = true;
				});
			}
		}
	} else {
		if(FlxG.mouse.overlaps(stoplightHitboxes[0], camVideo)) {
			stoplightHovering = true;

			if(!numHovering && FlxG.mouse.justPressed && buildTarget != 'android' && buildTarget != 'ios')
				Sys.exit(0);
		} else if(game.canPause && FlxG.mouse.overlaps(stoplightHitboxes[1], camVideo)) {
			stoplightHovering = true;

			if(!numHovering && FlxG.mouse.justPressed && buildTarget != 'android' && buildTarget != 'ios')
				game.openPauseMenu();
		}
	}

	updateEducatorGlow(dadHovering);
	Mouse.cursor = (numHovering || dadHovering || stoplightHovering) ? MouseCursor.BUTTON : MouseCursor.ARROW;		
}

function onDestroy() {
	FlxG.autoPause = true;
	Mouse.cursor = MouseCursor.ARROW;
}

function onGameOverStart() {
	canHandleMouse = false;
	blackboard.visible = false;
	equation.visible = false;
	triangle.visible = false;
	side1.visible = side2.visible = side3.visible = false;
	
	if (isSixSeven) sixSeven.visible = false;
	
	for(num in numbers)
		if (num != null) num.visible = false;
}

function createFraction(x:Float, y:Float, topText:String, bottomText:String, size:Int = 32) {
	final mathGroup = new FlxSpriteGroup(x, y);
	
	final topTxt = new FlxText(0, 0, 0, topText, size);
	topTxt.setFormat(Paths.font(getSchoolFont()), size, 0xFFFFFFFF, "center");
	topTxt.antialiasing = false;
	topTxt.cameras = [camOther];
	
	final bottomTxt = new FlxText(0, size + 10, 0, bottomText, size);
	bottomTxt.setFormat(Paths.font(getSchoolFont()), size, 0xFFFFFFFF, "center");
	bottomTxt.antialiasing = false;
	bottomTxt.cameras = [camOther];
	
	final maxWidth = Math.max(topTxt.width, bottomTxt.width);
	topTxt.x = (maxWidth - topTxt.width) / 2;
	bottomTxt.x = (maxWidth - bottomTxt.width) / 2;
	
	final line = new FlxSprite(0, size + 4).makeGraphic(Std.int(maxWidth), 4, 0xFFFFFFFF);
	line.cameras = [camOther];
	
	mathGroup.add(topTxt);
	mathGroup.add(line);
	mathGroup.add(bottomTxt);
	
	mathGroup.alpha = 0;
	mathGroup.cameras = [camOther];
	
	return mathGroup;
}