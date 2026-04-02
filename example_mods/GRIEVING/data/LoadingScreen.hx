import flixel.math.FlxMath;

var newBar:FlxSprite;
var loadedTxt:FlxText;
var blackFadeScreen:FlxSprite;

function onCreate()
{
	var logo:FlxSprite = new FlxSprite();
	logo.antialiasing = true;
	logo.frames = Paths.getSparrowAtlas('ring');
	logo.animation.addByPrefix('idle', 'idle', 60, true);
	logo.animation.play('idle', true);
	logo.scale.set(0.35, 0.35);
	logo.updateHitbox();
	logo.setPosition(FlxG.width - logo.width - 35, FlxG.height - logo.height - 35);
	add(logo);

	newBar = new FlxSprite(50, FlxG.height - 90).makeGraphic(Std.int(FlxG.width * 0.8), 40, 0xFFFFFFFF);
	add(newBar);

	loadedTxt = new FlxText(50, newBar.y - 50, 0, 'Loading... (?/?)', 40);
	loadedTxt.setFormat(Paths.font("visitor1.ttf"), 40);
	add(loadedTxt);

	blackFadeScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackFadeScreen.alpha = 0;
	add(blackFadeScreen);

	barGroup.visible = false;
	game.stateChangeDelay = 1.5;
	FlxTransitionableState.skipNextTransOut = true;
}

var dotsCount:Int = 1;
var dotsHold:Float = 0;

var timeTaken:Float = 0;
var isDoneLoading:Bool = false;
var triggerOnce:Bool = false;
function onUpdate(elapsed:Float)
{
	newBar.setGraphicSize(Std.int((FlxG.width * 0.8) * curPercent), 40);
	newBar.updateHitbox();

	if (!isDoneLoading)
	{
		timeTaken += elapsed;

		dotsHold += elapsed;
		if (dotsHold >= 0.3)
		{
			dotsHold = 0;
			dotsCount = FlxMath.wrap(dotsCount + 1, 1, 3);
		}

		loadedTxt.text = "Loading" + StringTools.lpad("", ".", dotsCount) + " (" + getLoaded() + "/" + getLoadMax() + ") " + Math.floor(curPercent * 100) + "%";

		if (curPercent == 1) isDoneLoading = true;
	}

	if (isDoneLoading && !triggerOnce){
		triggerOnce = true;
		loadedTxt.text = "Done! (Took " + (Math.round(timeTaken * 1000) / 1000) + " s)";
		FlxTween.tween(blackFadeScreen, {alpha: 1}, 1);
		FlxTween.tween(FlxG.sound.music, {volume: 0}, 1);
	}
}