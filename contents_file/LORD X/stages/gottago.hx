import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;

final game:PlayState = PlayState.instance;

function onCreate()
{
	var bg = new FlxBackdrop(Paths.image('gottago/bg'), 0x01);
	bg.scale.set(0.9, 0.9);
	bg.updateHitbox();
	bg.y = -600;
	bg.antialiasing = false;
	bg.velocity.x = -2500;
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), bg);

	var ring = new FlxSprite(-1090, -500);
	ring.loadGraphic(Paths.image('gottago/ring'));
	ring.scale.set(0.3, 0.3);
	ring.updateHitbox();
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), ring);

	boyfriend.alpha = 0;

	var bfIdx = game.members.indexOf(game.boyfriendGroup);
	var dadIdx = game.members.indexOf(game.dadGroup);
	if (dadIdx < bfIdx) {
		game.remove(game.dadGroup, true);
		game.insert(game.members.indexOf(game.boyfriendGroup) + 1, game.dadGroup);
	}
}
