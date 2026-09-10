import flixel.math.FlxMath;

var flagLeft:FlxSprite;
var flagRight:FlxSprite;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

function onCreatePost()
{
	healthColor = new FlxSprite(320, prefs.downScroll ? 80 : FlxG.height - 80).makeGraphic(660, 20, 0xFFFFFFFF);
	healthColor.color = 0xFF24CDF1;
	healthColor.camera = camHUD;
	game.add(healthColor);

	flagLeft = new FlxSprite(225, prefs.downScroll ? 32 : FlxG.height - 126);
	flagLeft.frames = Paths.getSparrowAtlas('final/hb/Flag-final-escape');
	flagLeft.animation.addByPrefix('idle', 'Símbolo 3', 24, true);
	flagLeft.animation.play('idle', true);
	flagLeft.scale.set(0.8, 0.8); flagLeft.updateHitbox();
	flagLeft.camera = camHUD;
	game.add(flagLeft);

	hbChain = new FlxSprite(225 + flagLeft.width - 2, flagLeft.y + 32.9).loadGraphic(Paths.image('final/hb/chain'));
	hbChain.scale.set(21.2, 0.8); hbChain.updateHitbox();
	hbChain.camera = camHUD;
	game.add(hbChain);

	flagRight = new FlxSprite(960, prefs.downScroll ? 32 : FlxG.height - 126);
	flagRight.frames = Paths.getSparrowAtlas('final/hb/Flag-final-escape');
	flagRight.animation.addByPrefix('idle', 'Símbolo 3', 24, true);
	flagRight.animation.play('idle', true);
	flagRight.flipX = true;
	flagRight.scale.set(0.8, 0.8); flagRight.updateHitbox();
	flagRight.camera = camHUD;
	game.add(flagRight);

	game.remove(game.getLuaObject('iconBF')); game.insert(game.members.indexOf(flagRight) + 1, game.getLuaObject('iconBF'));
	game.remove(game.getLuaObject('iconOpp')); game.insert(game.members.indexOf(flagRight) + 1, game.getLuaObject('iconOpp'));

	healthColor.visible = false;
	flagLeft.visible = false;
	hbChain.visible = false;
	flagRight.visible = false;
}

var _drain:Float = 0.0001;
var _xd:Bool = false;
var _ya:Bool = false;
function onUpdatePost(elapsed:Float)
{
	if (!_ya) return;
	hbChain.scale.x = FlxMath.bound(FlxMath.lerp(hbChain.scale.x, game.health * (21.2 / 2), elapsed * 10), 0.01, 21);
	hbChain.updateHitbox();

	flagRight.x = 960 - (636 - hbChain.width);
	game.getLuaObject('iconBF').x = 865.5 - (636 - hbChain.width);

	healthColor.setGraphicSize(FlxMath.bound(FlxMath.lerp(hbChain.width + 35, 660 - ((2 - game.health) * (660 / 2)), elapsed * 10), 1, 660), 20);
	healthColor.updateHitbox();

	if (_xd) game.health -= _drain;
}

function onEvent(n,v1,v2)
{
	if (n == 'finalescapeEvent')
	{
		switch(v1)
		{
			case 'secondsection':
				_ya = true;
				_xd = true;
				game.health = 2;
				healthColor.visible = true;
				flagLeft.visible = true;
				hbChain.visible = true;
				flagRight.visible = true;
			case 'startfifthsection':
				_xd = false;
			case 'fadewaterxd':
				_ya = false;
				healthColor.visible = false;
				flagLeft.visible = false;
				hbChain.visible = false;
				flagRight.visible = false;
			case 'superbf':
				healthColor.color = 0xFFFED24D;
				_ya = true;
				_xd = true;
				_drain = 0.00025;
				game.health = 2;
				healthColor.visible = true;
				flagLeft.visible = true;
				hbChain.visible = true;
				flagRight.visible = true;
			case 'ending':
				_xd = false;
				game.health = 2;
				healthColor.visible = false;
				flagLeft.visible = false;
				hbChain.visible = false;
				flagRight.visible = false;
		}
	}
}