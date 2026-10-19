var firstTime:Bool = true;
var bluescreen:FlxSprite;
function onCountdownStart()
{
    if (firstTime && states.SoundTest.fromSoundTest)
    {
        firstTime = false;

        bluescreen = new FlxSprite(0, 0, Paths.image('fate/bluescreen', 'LORD X'));
        bluescreen.updateHitbox();
        bluescreen.scrollFactor.set();
        bluescreen.setGraphicSize(FlxG.width, FlxG.height);
        bluescreen.screenCenter();
        bluescreen.camera = camOther;
        add(bluescreen);

        new FlxTimer().start(3, () -> {
            FlxTween.tween(bluescreen, {alpha: 0}, 1);
            startCountDown();
        });
    }

    return Function_Stop;
}