var firstBG:Array<BackgroundSprite> = [
	{path: 'newbg/bg', position: [-849, -596], scale: [6, 6], scroll: [0.5, 0.5]},
	{path: 'newbg/eyes', position: [-849, -596], scale: [6, 6], scroll: [0.5, 0.5], animation: [{name: 'idle', fps: 12, looped: false}]}
	{path: 'newbg/bg2', position: [-953, -660], scale: [6, 6], scroll: [0.75, 0.75]},
	{path: 'newbg/floor', position: [-1056, -726], scale: [6, 6]},
	{path: 'newbg/lava', position: [-1056, -726], scale: [6, 6], animation: [{name: 'idle', fps: 12, looped: true}]},
	{path: 'newbg/zzz', position: [-1056, -726], scale: [6, 6], animation: [{name: 'idle', fps: 12, looped: true}], front: true}
	{path: 'newbg/mist', position: [-1056, -726], scale: [6, 6], animation: [{name: 'idle', fps: 12, looped: true}], front: true},
	{path: 'newbg/badnick', position: [-1100, -830], scale: [6, 6], scroll: [1.4, 1.4], front: true, animation: [{name: 'idle', fps: 12, looped: false}]},
	{path: 'newbg/fg', position: [-1100, -830], scale: [6, 6], scroll: [1.4, 1.4], front: true}
];

function onCreate()
{
	makeBackground(firstBG);
	firstBG[1].sprite.animation.paused = true;

	for (i in 0...firstBG.length) //Fuck antialiasing
		firstBG[i].sprite.antialiasing = false;
}

var oldMHS:Bool = false;
function onSectionHit()
{
	if (oldMHS != mustHitSection)
	{
		if (mustHitSection)
			firstBG[1].sprite.animation.play('idle', true, false);
		else
			firstBG[1].sprite.animation.play('idle', true, true);
	}

	oldMHS = mustHitSection;
}