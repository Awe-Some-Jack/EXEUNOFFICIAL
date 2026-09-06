import openfl.display.BlendMode;

var faker:Array<BackgroundSprite> = [
	{path: 'faker/newBG/sky', position: [-300, -400], scale: [1.8, 1.8, false], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/sun', position: [-1050 + 250, -450], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/sunshine', position: [-1050 + 250, -450], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/moon', position: [-1008, -450], scroll: [0.2, 0.2]},
	{path: 'faker/newBG/clouds', position: [-300, -400], scale: [1.8, 1.8, false], scroll: [0.2, 0.2], backdrop: ['x', [50, 0]]},
	{path: 'faker/newBG/mountainsback', position: [-300, -400], scale: [1.8, 1.8, false], scroll: [0.5, 0.5]},
	{path: 'faker/newBG/mountaints', position: [-100, -400], scale: [1.8, 1.8, false], scroll: [0.65, 0.65]},
	{path: 'faker/newBG/mountaints2', position: [-100, -200], scale: [1.8, 1.8, false], scroll: [0.8, 0.8]},
	{path: 'faker/newBG/water', position: [-100, 400], scale: [1.8, 1.8, false], scroll: [0.8, 0.8]},
	{path: 'faker/newBG/totems', position: [150, -450], scale: [1.8, 1.8, false], scroll: [0.9, 0.9]},
	{path: 'faker/newBG/floor', position: [350, 450], scale: [1.8, 1.8, false]},
	{path: 'faker/newBG/foreground', position: [100, 390], scale: [1.6, 1.6, false], scroll: [1.3, 1.3]},
	{path: 'faker/newBG/glow', position: [0, -200], scale: [2.8, 1.3, false], front: true, alpha: 0.4, color: 0xFFA81000, blend: 'add'}
];

final game:PlayState = PlayState.instance;

var overlay:FlxSprite;
var blackbgxd:FlxSprite;
function onCreate()
{
	makeBackground(faker);
	
	overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFAAAAFF);
	overlay.blend = BlendMode.MULTIPLY;
	overlay.alpha = 0.5;
	overlay.screenCenter();
	overlay.scrollFactor.set();
	game.add(overlay);
	setVar('glowfaker', faker[faker.length - 1].sprite);

	blackbgxd = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	blackbgxd.screenCenter();
	blackbgxd.alpha = 0;
	blackbgxd.scrollFactor.set();
	game.insert(game.members.indexOf(game.boyfriendGroup), blackbgxd);
}

function onUpdatePost(elapsed)
{
	overlay.scale.set(1 / camGame.zoom, 1 / camGame.zoom);
	blackbgxd.scale.set(1 / camGame.zoom, 1 / camGame.zoom);

	var progress = Math.min(Conductor.songPosition / (109.71 * 1000), 1);

	faker[3].sprite.x = Math.min(FlxMath.lerp(-1300, -1008, progress), -1008) - 7 + 250;
	faker[3].sprite.y = FlxMath.lerp(-300, -450, Math.sin(progress * Math.PI * 0.5)) - 1;

	faker[2].sprite.alpha = Math.min(FlxMath.lerp(0.5, 1, progress), 1);
	var scale = Math.min(FlxMath.lerp(1.2, 2, progress), 2);
	faker[2].sprite.scale.set(scale, scale);
	faker[2].sprite.y = Math.min(FlxMath.lerp(-450, -65, progress), -65) + 100;
}

function onEvent(n)
{
	if (n == 'blackdbg')
	{
		FlxTween.cancelTweensOf(blackbgxd);
		FlxTween.tween(blackbgxd, {alpha: (blackbgxd.alpha != 0 ? 0 : 1)}, 0.6);
		FlxTween.tween(faker[11].sprite, {alpha: (faker[11].sprite.alpha != 1 ? 1 : 0.5)}, 0.6);
		FlxTween.tween(faker[12].sprite, {alpha: (faker[12].sprite.alpha != 0.4 ? 0.4 : 0.06)}, 0.6);
	}
}