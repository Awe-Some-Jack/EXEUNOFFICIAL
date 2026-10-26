var xd:Array<BackgroundSprite> = [
	{path: 'characters/robot', position: [1030, 420], scale: [0.55, 0.55], isAtlas: true, animation: [{name: 'robot'}], layer: 'behindgf'}
];

final prefs = ClientPrefs.data;
var oldGT:Bool = false;
function onCreatePost()
{
	makeBackground(xd);
	oldGT = prefs.ghostTapping;
}

function onBeatHit() if (curBeat % 2 == 0) for (spr in xd) spr.sprite.animation.play('robot', true);

function onEvent(n, v1, v2)
{
	if (n == 'animation' && v1 == 'end')
	{
		game.canReset = false;
		prefs.ghostTapping = true;
	}
}
function onDestroy() prefs.ghostTapping = oldGT;