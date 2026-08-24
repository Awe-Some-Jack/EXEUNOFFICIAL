import flixel.math.FlxMath;

var healthBG:FlxSprite;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;
final hbvanilla:Array<String> = ['hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG'];

function onCreatePost()
{
	healthColor = new FlxSprite(320, prefs.downScroll ? 80 : FlxG.height - 80).makeGraphic(660, 20, 0xFFFFFFFF);
	healthColor.color = 0xFF24CDF1;
	healthColor.camera = camHUD;
	game.add(healthColor);

	healthBG = new FlxSprite(225, prefs.downScroll ? 32 : FlxG.height - 126);
	healthBG.frames = Paths.getSparrowAtlas('god/godspeed helbart');
	healthBG.animation.addByPrefix('1', 'normal', 24, true);
	healthBG.animation.addByPrefix('2', '2', 24, true);
	healthBG.animation.addByPrefix('3', '3', 24, true);
	healthBG.animation.addByPrefix('4', '4', 24, true);
	healthBG.animation.addByPrefix('5', '5', 24, true);
	healthBG.animation.addByPrefix('6', '6', 24, true);
	healthBG.animation.addByPrefix('7', '7', 24, true);
	healthBG.animation.addByPrefix('8', '8', 24, true);
	healthBG.animation.addByPrefix('9', '9', 24, true);
	healthBG.animation.addByPrefix('10', '10', 24, true);
	healthBG.animation.play('1', true);
	healthBG.scale.set(0.8, 0.8); healthBG.updateHitbox();
	healthBG.camera = camHUD;
	game.add(healthBG);
	game.health = 2;
	game.healthGain = 0;

	game.remove(game.getLuaObject('iconOpp')); game.insert(game.members.indexOf(healthBG) + 1, game.getLuaObject('iconOpp'));
	game.remove(game.getLuaObject('iconBF')); game.insert(game.members.indexOf(healthBG) + 1, game.getLuaObject('iconBF'));
	for (spr in hbvanilla) game.getLuaObject(spr).alpha = 0;
}

function onUpdatePost(elapsed:Float)
{
	var shouldPlay:String = '1';
	shouldPlay = Std.string(Std.int(FlxMath.bound(11 - (game.health * 5), 1, 10)));
	if (shouldPlay != healthBG.animation.curAnim.name){
		healthBG.animation.play(shouldPlay, true);
		healthColor.setGraphicSize(660 - (43 * Std.int(shouldPlay - 1)), 20);
		healthColor.updateHitbox();
	}
	healthBG.x = 225 + (43 * Std.int(shouldPlay - 1));
	healthColor.x = 320 + (43 * Std.int(shouldPlay - 1));
	game.getLuaObject('iconOpp').x = 264.5 + (43 * Std.int(shouldPlay - 1)) + FlxG.random.float(-1, 1);
	game.getLuaObject('iconOpp').y = game.getLuaObject('hbBG').y + (game.getLuaObject('hbBG').height / 2) - 75 + FlxG.random.float(-1, 1);
	game.getLuaObject('iconOpp').angle = FlxG.random.float(-1, 1);
	game.getLuaObject('iconOpp').animation.curAnim.curFrame = game.health < 0.4 ? 1 : 0;

	game.health -= 0.0025 * elapsed;
}