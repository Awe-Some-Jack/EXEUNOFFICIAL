function onCreatePost()
{
	camHUD.alpha = 0;
	PlayState.instance.dad.alpha = 0;
	PlayState.instance.boyfriend.alpha = 0;
	PlayState.instance.cameraSpeed = 9999;
}

function onSongStart() PlayState.instance.cameraSpeed = 1;

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