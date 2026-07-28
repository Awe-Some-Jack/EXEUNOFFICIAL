var separation:Int = 50;
function onCreatePost()
{
	camHUD.alpha = 0;
	PlayState.instance.dad.alpha = 0;
	PlayState.instance.boyfriend.alpha = 0;
	PlayState.instance.cameraSpeed = 9999;

	PlayState.instance.iconP1.alpha = 0;
	PlayState.instance.iconP2.alpha = 0;
	PlayState.instance.healthBar.alpha = 0;
	PlayState.instance.scoreTxt.alpha = 0;
}

function onSongStart()
{
	PlayState.instance.cameraSpeed = 1;

	for (i in 0...4)
	{
		opponentStrums.members[i].x = -1000;
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i);
	}
}

function onEvent(n,v1)
{
	if (n == 'genesysEvents')
	{
		switch(v1)
		{
			case 'hudappear':
				FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 250, {ease: FlxEase.cubeInOut});
		}
	}
}