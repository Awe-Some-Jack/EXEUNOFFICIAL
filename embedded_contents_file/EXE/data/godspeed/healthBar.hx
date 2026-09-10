import flixel.math.FlxMath;

var flagLeft:FlxSprite;
var flagRight:FlxSprite;

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

	flagLeft = new FlxSprite(225, prefs.downScroll ? 32 : FlxG.height - 126);
	flagLeft.frames = Paths.getSparrowAtlas('god/hb/Flag-Godspeed');
	flagLeft.animation.addByPrefix('idle', 'Símbolo 3', 24, true);
	flagLeft.animation.play('idle', true);
	flagLeft.scale.set(0.8, 0.8); flagLeft.updateHitbox();
	flagLeft.camera = camHUD;
	game.add(flagLeft);

	hbChain = new FlxSprite(225 + flagLeft.width - 2, flagLeft.y + 32.9).loadGraphic(Paths.image('god/hb/chain'));
	hbChain.scale.set(21.2, 0.8); hbChain.updateHitbox();
	hbChain.camera = camHUD;
	game.add(hbChain);

	flagRight = new FlxSprite(960, prefs.downScroll ? 32 : FlxG.height - 126);
	flagRight.frames = Paths.getSparrowAtlas('god/hb/Flag-Godspeed');
	flagRight.animation.addByPrefix('idle', 'Símbolo 3', 24, true);
	flagRight.animation.play('idle', true);
	flagRight.flipX = true;
	flagRight.scale.set(0.8, 0.8); flagRight.updateHitbox();
	flagRight.camera = camHUD;
	game.add(flagRight);

	game.health = 2;
	game.healthGain = 0;

	game.remove(game.getLuaObject('iconOpp')); game.insert(game.members.indexOf(flagRight) + 1, game.getLuaObject('iconOpp'));
	game.remove(game.getLuaObject('iconBF')); game.insert(game.members.indexOf(flagRight) + 1, game.getLuaObject('iconBF'));
	for (spr in hbvanilla) game.getLuaObject(spr).alpha = 0;
}

function onUpdatePost(elapsed:Float)
{
	hbChain.scale.x = FlxMath.bound(FlxMath.lerp(hbChain.scale.x, game.health * (21.2 / 2), elapsed * 10), 0.01, 21);
	hbChain.updateHitbox();
	hbChain.x = 225 + flagLeft.width - 2 + (636 - hbChain.width) - 6;

	flagLeft.x = 225 + (636 - hbChain.width);

	healthColor.setGraphicSize(FlxMath.bound(FlxMath.lerp(hbChain.width + 35, 660 - ((2 - game.health) * (660 / 2)), elapsed * 10), 1, 660), 20);
	healthColor.updateHitbox();
	healthColor.x = 320 + (660 - healthColor.width);

	game.getLuaObject('iconOpp').x = 250 + (660 - healthColor.width) + FlxG.random.float(-1, 1);
	game.getLuaObject('iconOpp').y = game.getLuaObject('hbBG').y + (game.getLuaObject('hbBG').height / 2) - 75 + FlxG.random.float(-1, 1);
	game.getLuaObject('iconOpp').angle = FlxG.random.float(-1, 1);
	game.getLuaObject('iconOpp').animation.curAnim.curFrame = game.health < 0.4 ? 1 : 0;

	game.health -= 0.0025 * elapsed;
}