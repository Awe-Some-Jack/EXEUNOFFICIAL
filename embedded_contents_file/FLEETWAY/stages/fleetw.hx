
var chaosBG:Array<BackgroundSprite> = [
	{path: 'bg/chaos plaze olders/bg', position: [-50, 150], scale: [0.694, 0.694], scroll: [0.6, 0.6]},
	{path: 'bg/chaos plaze olders/floor', position: [720, 980], scale: [0.694, 0.694]},
	{path: 'bg/chaos plaze olders/fuentes', position: [720, 980], scale: [0.694, 0.694], front: true, isAtlas: true, animation: [{name: 'fuentes'}]},
	{path: 'bg/chaos plaze olders/pilar izquierdo', position: [1500, 1000], scale: [0.694, 0.694], scroll: [1.3, 1.3], front: true},
	{path: 'bg/chaos plaze olders/pilar derecho', position: [4250, 1160], scale: [0.694, 0.694], scroll: [1.3, 1.3], front: true},
];

function onCreatePost()
{
	makeBackground(chaosBG);
}