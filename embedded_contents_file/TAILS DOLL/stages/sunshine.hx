import openfl.display.BlendMode;
import objects.VideoSprite;

var introCutscene:VideoSprite;
var floor:FlxSprite;
var spotlight:FlxSprite;
var redOverlay:FlxSprite;

final hudSprites:Array<String> = ['iconBF', 'iconOpp', 'hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'exeScoreTxt'];
function onCreatePost()
{
	introCutscene = new VideoSprite();
	introCutscene.onFormat(() -> {
		introCutscene.scale.set(0.71, 0.71);
		introCutscene.screenCenter();
	});
	introCutscene.visible = false;
	introCutscene.camera = camVideo;
	game.add(introCutscene);

	floor = new FlxSprite(-400, -150).loadGraphic(Paths.image('bg/new_floor'));
	addBehindDad(floor);

	spotlight = new FlxSprite(-400, -450).loadGraphic(Paths.image('bg/spotlight'));
	spotlight.scale.y = 1.3;
	spotlight.updateHitbox();
	spotlight.alpha = 0.5;
	spotlight.blend = BlendMode.SCREEN;
	add(spotlight);

	redOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFF0000);
	redOverlay.alpha = 1;
	redOverlay.scrollFactor.set();
	redOverlay.screenCenter();
	redOverlay.alpha = 0;
	redOverlay.blend = BlendMode.MULTIPLY;
	redOverlay.camera = camGame;
	add(redOverlay);

	PlayState.uiPostfix = '-lq';
}

function onUpdatePost()
{
	if (redOverlay != null) redOverlay.scale.set(1 / camGame.zoom, 1 / camGame.zoom);
}

var notesPosition:Array<Array<Float>> = [[0,0,0,0], [0,0,0,0]];
var inDark:Bool = false;
final separation:Float = 10;
function onEvent(n,v1)
{
	if (n == 'sunshinEvent')
	{
		switch(v1)
		{
			case 'startdark':
				FlxTween.tween(redOverlay, {alpha: 1}, Conductor.crochet / (1000 / 3), {ease: FlxEase.expoIn});
			case 'lightsOut':
				redOverlay?.destroy();
				redOverlay = null;
				floor.alpha = 0;
				spotlight.alpha = 0;
				dad.alpha = 0;
				boyfriend.alpha = 0;
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 0;
				for (i in 0...4)
				{
					if (!inDark)
					{
						notesPosition[0][i] = opponentStrums.members[i].x; notesPosition[1][i] = playerStrums.members[i].x;
						playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width) + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i;
						opponentStrums.members[i].x = -1000;
					}
					//playerStrums.members[i].alpha = 0;
				}
				inDark = !inDark;
			case 'creepy':
				PlayState.instance.triggerEvent('Change Character', 'dad', 'taildolpov', Conductor.songPosition);
				dad.setPosition(200, -100);
				camGame.zoom = 0.8;
				camGame.snapToTarget();
				PlayState.instance.gameplayCam.settings.MiddleZoom = 0.8;
				dad.alpha = 1;
				PlayState.instance.comboGroup.x = -1000;
			case 'fadeNotes':
				for (i in 0...4)
				{
					opponentStrums.members[i].x = notesPosition[0][i];
					playerStrums.members[i].x = notesPosition[1][i];
					opponentStrums.members[i].alpha = 0;
					playerStrums.members[i].alpha = 0;
					FlxTween.tween(playerStrums.members[i], {alpha: 1}, Conductor.crochet / 500);
					FlxTween.tween(opponentStrums.members[i], {alpha: 1}, Conductor.crochet / 500);
				}
			case 'back':
				PlayState.instance.triggerEvent('Change Character', 'dad', 'taildol', Conductor.songPosition);
				for (spr in hudSprites) game.getLuaObject(spr).alpha = 1;
				for (i in 0...4)
				{
					FlxTween.cancelTweensOf(playerStrums.members[i]);
					FlxTween.cancelTweensOf(opponentStrums.members[i]);
					opponentStrums.members[i].alpha = 1;
					playerStrums.members[i].alpha = 1;
				}
				boyfriend.alpha = 1;
				dad.alpha = 1;
				floor.alpha = 1;
				spotlight.alpha = 1;

				PlayState.instance.comboGroup.x = 0;
				camGame.zoom = 0.55;
				camGame.snapToTarget();
				PlayState.instance.gameplayCam.settings.MiddleZoom = 0.55;
			case 'videoend':
				introCutscene.visible = true;
				if (introCutscene?.loadVideo(Paths.video('dollending'))) introCutscene.playDelayed();
				FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.cubeInOut});
		}
	}
}

function onGameOverStart()  introCutscene?.destroy();
function onPause() introCutscene?.pause();
function onResume() introCutscene?.resume();