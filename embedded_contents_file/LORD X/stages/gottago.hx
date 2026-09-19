import psychlua.LuaUtils;
import flixel.addons.display.FlxBackdrop;

final game:PlayState = PlayState.instance;
final luaObjects:Array<String> = ['hbBG', 'iconOpp', 'iconBF', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];
var vg:FlxSprite;

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

	vg = new FlxSprite(0, 0).loadGraphic(Paths.image('VG'));
	vg.updateHitbox();
	vg.color = 0xFF000000;
	vg.alpha = 0;
	vg.cameras = [camHUD];
	vg.screenCenter();
	add(vg);

	black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black.alpha = 0;
	black.cameras = [camHUD];
	black.screenCenter();
	add(black);

	boyfriend.alpha = 0;

	var bfIdx = game.members.indexOf(game.boyfriendGroup);
	var dadIdx = game.members.indexOf(game.dadGroup);
	if (dadIdx < bfIdx) {
		game.remove(game.dadGroup, true);
		game.insert(game.members.indexOf(game.boyfriendGroup) + 1, game.dadGroup);
	}
}

function onStepHit()
	switch(curStep) {
		case 508: FlxTween.tween(black, {alpha: 1}, 0.3, {ease: FlxEase.linear});
		case 512: black.alpha = 0;
		case 1824:
            for(obj in luaObjects) {
				if(obj != null) FlxTween.tween(game.getLuaObject(obj), {alpha: 0}, 1.2, {ease: FlxEase.smootherStepInOut});
            }
			
			for(i in 0...4) {
                FlxTween.tween(playerStrums.members[i], {alpha: 0.6}, 1.2, {ease: FlxEase.smootherStepInOut});
            }

			FlxTween.tween(vg, {alpha: 1}, 1.2, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(comboGroup, {alpha: 0.6}, 1.2, {ease: FlxEase.smootherStepInOut});

			for(note in unspawnNotes) {
				if(note.mustPress) {
					FlxTween.tween(note, {alpha: 0.6}, 1.2, {ease: FlxEase.smootherStepInOut});
				}
			}
		case 2320:
			for(obj in luaObjects) {
				if(obj != null) FlxTween.tween(game.getLuaObject(obj), {alpha: 1}, 1.2, {ease: FlxEase.smootherStepInOut});
            }

			for(i in 0...4) {
                FlxTween.tween(playerStrums.members[i], {alpha: 1}, 1.2, {ease: FlxEase.smootherStepInOut});
            }

			FlxTween.tween(vg, {alpha: 0}, 1.2, {ease: FlxEase.smootherStepInOut});
			FlxTween.tween(comboGroup, {alpha: 1}, 1.2, {ease: FlxEase.smootherStepInOut});

			for(note in unspawnNotes) {
				if(note.mustPress) {
					FlxTween.tween(note, {alpha: 1}, 1.2, {ease: FlxEase.smootherStepInOut});
				}
			}
	}