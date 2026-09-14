var hogBG:Array<BackgroundSprite> = [
	{path: 'bg/sky', position: [-820, -500], scroll: [0.2, 0.2]},
	{path: 'bg/clouds', position: [-820, -500], scroll: [0.2, 0.2], backdrop: ['x', [10, 0]]},
	{path: 'bg/mountains', position: [-820, -500], scroll: [0.4, 0.4]},
	{path: 'bg/bg', position: [-850, -500], scroll: [0.6, 0.6]},
	{path: 'bg/trees', position: [-850, -550], scroll: [0.8, 0.8]},
	{path: 'characters/tailsatlas', tag: 'tails', position: [100, -50], scale: [0.8, 0.8], scroll: [0.8, 0.8], isAtlas: true, animation: [{name: 'normalidle'}]},
	{path: 'bg/floor', position: [-900, -550]},
	{path: 'characters/knuxatlas', tag: 'knux', position: [1200, 300], isAtlas: true, animation: [{name: 'normalidle'}], layer: 'behindbf'},
	{path: 'bg/rocks', position: [-900, -550], scroll: [1.25, 1.25], front: true},
	{path: 'bg/fg', position: [-900, -560], scroll: [1.5, 1.5], front: true},
	{path: 'bg/overlay', position: [-900, -650], scroll: [1.5, 1.5], front: true, blend: 'add', color: 0xFFFF781E, alpha: 0.5}
];

function onCreate()
{
	makeBackground(hogBG);
	gf.scrollFactor.set(1, 1);
}

function onBeatHit()
{
	for (spr in hogBG) if ((spr.tag == 'tails' || spr.tag == 'knux') && curBeat % 2 == 0 && spr.sprite != null) spr.sprite.animation.play('normalidle', true);
}

var _tailsSine:Float = 0;
function onUpdatePost(e:Float)
{
	_tailsSine += e;
	for (spr in hogBG) if (spr.tag == 'tails' && spr.sprite != null)
	{
		spr.sprite.setPosition(
			spr.position[0] + Math.cos(_tailsSine) * 30,
			spr.position[1] + Math.sin(_tailsSine * 2) * 15
			);
	}
}