var bgNeedle:Array<BackgroundSprite> = [
	{path: 'roundabout/sky', position: [-750, -900], scroll: [0.3, 0.3]},
	{path: 'roundabout/bg3', position: [-500, -700], scroll: [0.5, 0.5]},
	{path: 'roundabout/bg2', position: [-600, -550], scroll: [0.65, 0.65]},
	{path: 'roundabout/lava', position: [0, 830], scale: [1.2, 1.2, false], scroll: [0.8, 0.8], animation: [{name: 'Dance', looped: true}]},
	{path: 'roundabout/bg1', position: [-350, -150], scroll: [0.8, 0.8]},
	{path: 'roundabout/floor', position: [-200, 1080]},
	{path: 'roundabout/foreground', position: [100, 450], scroll: [1.2, 1.2], front: true}
];

function onCreate() {
	if(ClientPrefs.data.middleScroll && (ClientPrefs.data.middlescrollType == 'mobile' || ClientPrefs.data.mobileOpponentNotes)) PlayState.instance.opponentStrumOffsetY = -10;
}

function onCreatePost() 
{
	makeBackground(bgNeedle);
}