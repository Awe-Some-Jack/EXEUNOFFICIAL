import psychlua.LuaUtils;
import objects.VideoSprite;

var bgDark:Array<BackgroundSprite> = [
	{path: 'hellbent/GUARDIAN-N', position: [-1000, -430], scroll: [0.7, 0.7]},
	{path: 'hellbent/BG-N1', position: [-1080, -430]},
	{path: 'hellbent/bgnew/murofuego 3', position: [-1080, -500], animation: [{name: "Símbolo 21", looped: true}]},
	{path: 'hellbent/bgnew/murofuego 3', position: [900, -500], flipX: true, animation: [{name: "Símbolo 21", looped: true}]}
];

var bgFirst:Array<BackgroundSprite> = [
	{path: 'hellbent/bgnew/hellbentnew', position: [-2450, -1310], visible: false, scroll: [0.2, 0.2], animation: [{name: "4"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2520, -1310], visible: false, scale: [0.9, 0.9, false], scroll: [0.5, 0.5], animation: [{name: "3"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2600, -1310], visible: false, scale: [0.9, 0.9, false], scroll: [0.7, 0.7], animation: [{name: "2"}]},
	{path: 'hellbent/bgnew/hellbentnew', position: [-2745, -1310], visible: false, scale: [0.9, 0.9, false], animation: [{name: "1"}]},
	{path: 'hellbent/bgnew/banderas', position: [-440, 550], visible: false, scale: [4, 4, false], animation: [{name: "bandera instancia 1", looped: true}]},
	{path: 'hellbent/bgnew/banderas', position: [850, 550], visible: false, scale: [4, 4, false], animation: [{name: "bandera instancia 1", looped: true}], flipX: true}
];

var bgHell:Array<BackgroundSprite> = [
	{path: 'hellbent/plataformna', position: [440, 1250], visible: false, scale: [0.45, 0.45, false]},
	{path: 'hellbent/plataformna', position: [-950, 1200], visible: false, scale: [0.55, 0.55, false], flipX: true}
]; 

var hellBG:VideoSprite;

final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];
final game:PlayState = PlayState.instance;
final prefs = ClientPrefs.data;
final cam = game.gameplayCam.settings;

var trans:Character;

var eyes:FlxSprite;
function onCreate()
{
	boyfriend.alpha = 0;
	makeBackground(bgDark);
	makeBackground(bgFirst);

	hellBG = new VideoSprite(-3500, -1600, false);
	hellBG.onFormat(() -> {
		hellBG.scale.set(3, 3);
		hellBG.updateHitbox();
	});
	hellBG.alpha = 0.0001;
	hellBG.onEnd(() -> {hellBG.seekToSeconds(0); hellBG.play();});
	game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), hellBG);

	makeBackground(bgHell);

	eyes = new FlxSprite();
	eyes.frames = Paths.getSparrowAtlas('characters/ojos');
	eyes.animation.addByPrefix('idle', 'idle', 0, false); eyes.animation.play('idle', true);
	eyes.camera = camOther;
	game.add(eyes);
	
	trans = new Character(0, 0, 'hellbenttrans', false);
	trans.camera = camOther;
	trans.screenCenter();
	trans.alpha = 0;
	game.add(trans);

	preloadCharacter(1, 'hellbenttrans');
	preloadCharacter(1, 'hellbemnt');
	preloadCharacter(0, 'bf-hellbent');
}

var _phase2Active:Bool = false;
function onEvent(n,v1)
{
	if (n == 'hellbentEvents')
	{
		switch(v1)
		{
			case 'startwhite':
				camGame.zoom = 0.25;
				cam.OGZoom = 0.25;
				bgDark[0].sprite.destroy(); bgDark[1].sprite.destroy();
				for (spr in bgFirst) spr.sprite.visible = true;
				bgDark[2].sprite.y -= 750; bgDark[3].sprite.y -= 750;
				bgDark[2].sprite.x += 350; bgDark[3].sprite.x -= 350;
				game.remove(bgDark[2].sprite, true); game.insert(game.members.indexOf(bgFirst[3].sprite) - 1, bgDark[2].sprite);
				game.remove(bgDark[3].sprite, true); game.insert(game.members.indexOf(bgFirst[3].sprite) - 1, bgDark[3].sprite);
			case 'changeBG':
				camGame.alpha = 1; camHUD.alpha = 1;
				trans.destroy();
				_phase2Active = true;
				bgDark[2].sprite.destroy(); bgDark[3].sprite.destroy();
				for (spr in bgFirst) spr.sprite.destroy();
				for (spr in bgHell) spr.sprite.visible = true;

				if (hellBG?.loadVideo(Paths.video('../images/hellbent/hellbebt-1'), [VideoSprite.ARG_LOOPING])) hellBG.playDelayed();
				hellBG.alpha = 1;

				boyfriend.alpha = 1;
				changeCharacter('dad', 'hellbemnt');
				changeCharacter('bf', 'bf-hellbent');
				dad.setPosition(-700, 960);
				boyfriend.setPosition(650, 1100);
			case 'scaryyy':
				eyes?.destroy();
				eyes = null;
				camGame.alpha = 0; camHUD.alpha = 0;
				trans.alpha = 1;
				new FlxTimer().start(Conductor.crochet / 500, function(_){trans?.alpha = 0;});
			case 'fucklol':
				trans.alpha = 1;
				trans.idleSuffix = '-alt';
				trans.recalculateDanceIdle();
				trans.dance();
		}
	}
}

var _floatTime:Float = 0;
function onUpdatePost(elapsed:Float)
{
	if (!_phase2Active)
	{
		if (eyes != null && eyes.alpha != game.getLuaObject('BlackGraphicHUD').alpha) eyes.alpha = game.getLuaObject('BlackGraphicHUD').alpha;
		if (eyes != null) eyes.visible = dad?.getAnimationName() == 'idle';
		if (eyes != null && dad?.getAnimationName() == 'idle')
		{
			eyes.scale.set(camGame.zoom * 0.5, camGame.zoom * 0.5);
			eyes.animation.curAnim.curFrame = dad.animation.curAnim.curFrame ?? 0;
			eyes.setPosition(
				((dad.x - 5 - camGame.scroll.x) * camGame.zoom) + (FlxG.width / 2) * (1 - camGame.zoom),
				((dad.y + 145 - camGame.scroll.y) * camGame.zoom) + (FlxG.height / 2) * (1 - camGame.zoom)
			);
		}
	}
	else
	{
		_floatTime += elapsed * 1.5;
		dad.setPosition(
			-750 + Math.cos(_floatTime + 0.5) * 25,
			850 + Math.sin(_floatTime + 0.5) * 50
		);
		bgHell[1].sprite.setPosition(
			-1400 + Math.cos(_floatTime + 0.5) * 25,
			750 + Math.sin(_floatTime + 0.5) * 50
		);

		boyfriend.setPosition(
			650 + Math.cos(_floatTime) * 25,
			1030 + Math.sin(_floatTime) * 50
		);
		bgHell[0].sprite.setPosition(
			-20 + Math.cos(_floatTime) * 25,
			750 + Math.sin(_floatTime) * 50
		);
	}
}

function preloadCharacter(char:Int, target:String) game.addCharacterToList(target, char);
function changeCharacter(char:String, target:String) game.triggerEvent('Change Character', char, target, Conductor.songPosition);