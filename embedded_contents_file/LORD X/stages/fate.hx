import states.PlayState as PS;
import flixel.FlxSprite;

var stat:FlxSprite;
var bgGraphic:FlxSprite;
var eas:FlxSprite;

function onCreate() {
    bgGraphic = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    bgGraphic.alpha = 0.00001;
    bgGraphic.scale.set(2, 2);
    bgGraphic.screenCenter();
    bgGraphic.scrollFactor.set();

    eas = new FlxSprite(0, 0, Paths.image('fate/eas', 'LORD X'));
    eas.updateHitbox();
    eas.scrollFactor.set(0, 0);
    eas.setGraphicSize(FlxG.width, FlxG.height);
    eas.screenCenter();
    add(eas);

    stat = new FlxSprite(0, 0);
    stat.frames = Paths.getSparrowAtlas('daSTAT', 'LORD X');
    stat.animation.addByPrefix('idle', 'staticFLASH', 24, true);
    stat.animation.play('idle',true);
    stat.screenCenter();
    stat.scale.set(3.4, 3.4);
    stat.antialiasing = false;
    add(stat);

    eas.cameras = stat.cameras = [camOther];
    eas.alpha = stat.alpha = 0.00001;
}
// all squished together for you
function onUpdate() {
    if(curStep >= 68 && dad.animation.curAnim.name == 'jarona') {
        switch(dad.animation.curAnim.curFrame) {
            case 25: stat.alpha = 1;
            case 43: stat.alpha = 0;
            case 92:
                addBehindDad(bgGraphic);
                FlxTween.tween(bgGraphic, {alpha: 1}, 0.78, {ease: FlxEase.linear});
            case 117, 185: bgGraphic.alpha = 0;
            case 161: bgGraphic.alpha = 1;
            case 230: eas.alpha = 1;
            case 256:  eas.alpha = 0;
            case 449:
                bgGraphic.color = 0xFF000000;
                bgGraphic.cameras = [camOther];
                FlxTween.tween(bgGraphic, {alpha: 1}, 3, {ease: FlxEase.smootherStepInOut});
        }
    }
}