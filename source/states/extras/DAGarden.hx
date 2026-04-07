package states.extras;

import backend.MusicBeatState;
import backend.Controls;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import states.extras.ExtrasMenu;
import backend.Paths;

class DAGarden extends MusicBeatState
{
    private var fondo:FlxSprite;
    private var sprite1:FlxSprite;
    private var sprite2:FlxSprite;
    private var sprite3:FlxSprite;
    private var sprite4:FlxSprite;
    private var sprite6:FlxSprite;
    private var sprite7:FlxSprite;
    private var sprite8:FlxSprite;
    private var arrow:FlxSprite;
    private var spikes:FlxBackdrop;
    private var marcogris:FlxSprite;
    private var dagarden:FlxSprite;
    private var box:FlxSprite;
    private var disk:FlxSprite;
    private var bar:FlxSprite;

    private var fadeOverlay:FlxSprite;
    private var rotationTime:Float = 0;

    override public function create():Void
    {
        Paths.clearStoredMemory();
        
        super.create();

        initializeSprites();
        setupAnimations();

        Paths.clearUnusedMemory();
    }

    private function initializeSprites():Void
    {
        fondo = createSprite(0, 0, "fondo.png", 0.34);

        sprite1 = createSprite(560, 560, "1.png", 0.25);
        sprite2 = createSprite(950, 580, "2.png", 0.15);
        sprite3 = createSprite(1100, 50, "3.png", 0.25);
        sprite4 = createSprite(540, 300, "4.png", 0.25);
        sprite6 = createSprite(700, 800, "6.png", 0.25);
        sprite7 = createSprite(550, 50, "7.png", 0.25);
        sprite8 = createSprite(800, 50, "8.png", 0.25);

        arrow = createSprite(490, 90, "arrow.png", 0.34);

        spikes = new FlxBackdrop("assets/exe/extras/dagarden/spikes.png", Y, 0, 0);
        spikes.setPosition(70, 87);
        spikes.scale.set(0.34, 0.34);
        spikes.updateHitbox();
        spikes.antialiasing = ClientPrefs.data.antialiasing;
        add(spikes);

        marcogris = createSprite(0, 0, "marcogris.png", 0.34);
        dagarden = createSprite(70, 35, "dagarden.png", 0.34);
        box = createSprite(565, 100, "box.png", 0.34);
        disk = createSprite(691, 220, "disk.png", 0.34);
        bar = createSprite(620, 620, "bar.png", 0.34);
    }

    private function createSprite(x:Float, y:Float, fileName:String, scale:Float):FlxSprite
    {
        var sprite = new FlxSprite(x, y);
        var path = "assets/exe/extras/dagarden/" + fileName;
        sprite.loadGraphic(openfl.utils.Assets.getBitmapData(path));
        sprite.scale.set(scale, scale);
        sprite.updateHitbox();
        sprite.antialiasing = ClientPrefs.data.antialiasing;
        add(sprite);
        return sprite;
    }

    private function setupAnimations():Void
    {
        createFloatAnimation(sprite1, 20, 8, 3.2, 2.1);
        createFloatAnimation(sprite2, -10, 18, 1.8, 3.5);
        createFloatAnimation(sprite3, 25, -15, 2.9, 1.7);
        createFloatAnimation(sprite4, -18, 22, 2.4, 3.1);
        createFloatAnimation(sprite6, 12, -20, 3.6, 2.2);
        createFloatAnimation(sprite7, -16, 14, 1.9, 2.8);
        createFloatAnimation(sprite8, 28, 10, 3.3, 2.5);

        FlxTween.tween(arrow, {y: arrow.y - 10}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});

        FlxTween.tween(disk, {angle: 360}, 8.0, {ease: FlxEase.linear, type: LOOPING});
        FlxTween.tween(dagarden, {y: dagarden.y + 5}, 3.0, {ease: FlxEase.sineInOut, type: PINGPONG});
    }

    private function createFloatAnimation(sprite:FlxSprite, offsetX:Float, offsetY:Float, durationX:Float, durationY:Float):Void
    {
        FlxTween.tween(sprite, {x: sprite.x + offsetX}, durationX, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.tween(sprite, {y: sprite.y + offsetY}, durationY, {ease: FlxEase.sineInOut, type: PINGPONG});
        FlxTween.tween(sprite, {alpha: 0.85}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG, startDelay: Math.random() * 2});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        spikes.velocity.y = 50;

        rotationTime += elapsed;
        updateSubtleRotations(elapsed);

        if (Controls.instance.BACK)
            FlxG.switchState(new ExtrasMenu());
    }

    private function updateSubtleRotations(elapsed:Float):Void
    {
        sprite1.angle = Math.sin(rotationTime * 0.5) * 3;
        sprite3.angle = Math.cos(rotationTime * 0.7) * 4;
        sprite7.angle = Math.sin(rotationTime * 0.6) * 2;
        sprite8.angle = Math.cos(rotationTime * 0.8) * 3.5;
    }

    override public function destroy():Void
    {
        if (sprite1 != null)     FlxTween.cancelTweensOf(sprite1);
        if (sprite2 != null)     FlxTween.cancelTweensOf(sprite2);
        if (sprite3 != null)     FlxTween.cancelTweensOf(sprite3);
        if (sprite4 != null)     FlxTween.cancelTweensOf(sprite4);
        if (sprite6 != null)     FlxTween.cancelTweensOf(sprite6);
        if (sprite7 != null)     FlxTween.cancelTweensOf(sprite7);
        if (sprite8 != null)     FlxTween.cancelTweensOf(sprite8);
        if (arrow != null)       FlxTween.cancelTweensOf(arrow);
        if (disk != null)        FlxTween.cancelTweensOf(disk);
        if (dagarden != null)    FlxTween.cancelTweensOf(dagarden);
        fondo = null;
        sprite1 = null;
        sprite2 = null;
        sprite3 = null;
        sprite4 = null;
        sprite6 = null;
        sprite7 = null;
        sprite8 = null;
        arrow = null;
        spikes = null;
        marcogris = null;
        dagarden = null;
        box = null;
        disk = null;
        bar = null;

        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        super.destroy();
    }
}
