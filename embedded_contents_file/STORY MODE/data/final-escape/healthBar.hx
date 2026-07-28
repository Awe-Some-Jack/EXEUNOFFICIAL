import flixel.math.FlxMath;

var healthBG:FlxSprite;

final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

function onCreatePost()
{
	healthColor = new FlxSprite(320, prefs.downScroll ? 80 : FlxG.height - 126).makeGraphic(660, 20, 0xFFFFFFFF);
	healthColor.color = 0xFF24CDF1;
	healthColor.camera = camHUD;
	healthColor.visible = false;
	game.add(healthColor);

	healthBG = new FlxSprite(225, prefs.downScroll ? 32 : FlxG.height - 126);
	healthBG.frames = Paths.getSparrowAtlas('final/finalgel');
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
	healthBG.visible = false;

	game.remove(game.getLuaObject('iconOpp')); game.insert(game.members.indexOf(healthBG) + 1, game.getLuaObject('iconOpp'));
	game.remove(game.getLuaObject('iconBF')); game.insert(game.members.indexOf(healthBG) + 1, game.getLuaObject('iconBF'));
}

var _drain:Float = 0.0001;
var _xd:Bool = false;
var _ya:Bool = false;
function onUpdatePost(elapsed:Float)
{
	if (!_ya) return;
	var shouldPlay:String = '1';
	shouldPlay = Std.string(Std.int(FlxMath.bound(11 - (game.health * 5), 1, 10)));
	if (shouldPlay != healthBG.animation.curAnim.name){
		healthBG.animation.play(shouldPlay, true);
		healthColor.setGraphicSize(660 - (43 * Std.int(shouldPlay - 1)), 20);
		healthColor.updateHitbox();
	}
	game.getLuaObject('iconBF').x = 865.5 - (43 * Std.int(shouldPlay - 1));

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
				healthBG.visible = true;
			case 'startfifthsection':
				_xd = false;
			case 'fadewaterxd':
				_ya = false;
				healthColor.visible = false;
				healthBG.visible = false;
			case 'superbf':
				healthColor.color = 0xFFFED24D;
				_ya = true;
				_xd = true;
				_drain = 0.00025;
				game.health = 2;
				healthColor.visible = true;
				healthBG.visible = true;
			case 'ending':
				_xd = false;
				game.health = 2;
				healthColor.visible = false;
				healthBG.visible = false;
		}
	}
}