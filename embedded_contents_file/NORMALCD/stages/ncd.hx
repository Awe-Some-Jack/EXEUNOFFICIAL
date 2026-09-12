var xd:Array<BackgroundSprite> = [
	{path: 'characters/robot', position: [1030, 420], scale: [0.55, 0.55], isAtlas: true, animation: [{name: 'robot'}], layer: 'behindgf'}
];

function onCreatePost()
{
	makeBackground(xd);
}

function onBeatHit() if (curBeat % 2 == 0) for (spr in xd) spr.sprite.animation.play('robot', true);