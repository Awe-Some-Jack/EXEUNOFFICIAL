package states.extras.achievements;

import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import states.extras.achievements.AchievementItem;
import flixel.group.FlxSpriteGroup;
import backend.EXEAchievements.EXEAchievement;
import backend.EXEAchievements;
import states.EXEMenu;

class AchievementsState extends SonicSubState 
{
    var bg:FlxSprite;
    var bg2:FlxSprite;
    var bg3:FlxSprite;
    var spikes:FlxBackdrop;
    var black:FlxSprite;
    var achievementsTitle:FlxText;
    var sideBar:FlxSprite;
    var sideBarScroll:FlxSprite;
    var achievementProgress:FlxText;
    var scrollValue:Float;
    var achievementGroup:FlxSpriteGroup = new FlxSpriteGroup();
    var achievementsData:Array<EXEAchievement>;
    var unlockedAmount:Int = 0;
    var achievementAmount:Int = 0;

    static inline final ACHIEVEMENTS_PATH:String = 'assets/exe/extras/achievements/';
    static inline final WHEEL_SENSITIVITY:Float = #if !mobile 4 #else 0.05 #end;
    static inline final LERP_SPEED:Float = 10;

    public function new()
    {
        super();
    }

    override public function create():Void
    {
        super.create();

        final _w = FlxG.width;
        final _h = FlxG.height;
        final _bmd = new openfl.display.BitmapData(_w, _h, false, 0xFFbd0033);
        for (_x in 0..._w) {
            final t = 1.0 - _x / (_w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            _bmd.fillRect(new openfl.geom.Rectangle(_x, 0, 1, _h), 0xFF000000 | (r << 16) | b);
        }
        bg = new FlxSprite().loadGraphic(_bmd);
        add(bg);

        final _ts = 40;
        final _cbmd = new openfl.display.BitmapData(_ts * 2, _ts * 2, true, 0x00000000);
        _cbmd.fillRect(new openfl.geom.Rectangle(0,   0,   _ts, _ts), 0xFF3d0008);
        _cbmd.fillRect(new openfl.geom.Rectangle(_ts, 0,   _ts, _ts), 0xFF831826);
        _cbmd.fillRect(new openfl.geom.Rectangle(0,   _ts, _ts, _ts), 0xFF831826);
        _cbmd.fillRect(new openfl.geom.Rectangle(_ts, _ts, _ts, _ts), 0xFF3d0008);
        bg3 = new FlxBackdrop(_cbmd, XY, 0, 0);
        bg3.alpha = 0.10;
        bg3.velocity.x = -60;
        add(bg3);

        final _fadeBmd = new openfl.display.BitmapData(_w, _h, true, 0x00000000);
        for (_x in 0..._w) {
            final t = 1.0 - _x / (_w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            final a = Math.round(t * 255);
            _fadeBmd.fillRect(new openfl.geom.Rectangle(_x, 0, 1, _h), (a << 24) | (r << 16) | b);
        }
        bg2 = new FlxSprite().loadGraphic(_fadeBmd);
        add(bg2);

        spikes = new FlxBackdrop(null, X);
        spikes.makeGraphic(100, 100, 0xFF000000);
        spikes.spacing.x = 40;
        spikes.angle = 45;
		spikes.y = spikes.height / 2;
		spikes.velocity.x = -50;
        FlxTween.tween(spikes, {y: -400}, 0.8, {ease: FlxEase.expoOut, type: 16});

        black = new FlxSprite().makeGraphic(FlxG.width, Std.int(spikes.y + spikes.height / 2), 0xFF000000);
        FlxTween.tween(black, {y: -400}, 0.8, {ease: FlxEase.expoOut, type: 16});

        achievementsTitle = new FlxText(30, 30, 0, Language.get('mainmenu.achievements', 'ACHIEVEMENTS'), 100);
        achievementsTitle.font = Paths.font('NiseSega.ttf');
        achievementsTitle.scale.set(0.5, 0.5);
        achievementsTitle.updateHitbox();
        achievementsTitle.antialiasing = ClientPrefs.data.antialiasing;
        FlxTween.tween(achievementsTitle, {y: -400}, 0.8, {ease: FlxEase.expoOut, type: 16});

        sideBar = new FlxSprite(FlxG.width - 30, 210).makeGraphic(12, 450, 0x55000000);
        FlxTween.tween(sideBar, {alpha: 0}, 0.8, {ease: FlxEase.expoOut, type: 16});
        sideBarScroll = new FlxSprite(sideBar.x, sideBar.y).makeGraphic(12, 75, 0xCCFFFFFF);
        FlxTween.tween(sideBarScroll, {alpha: 0}, 0.8, {ease: FlxEase.expoOut, type: 16});

        loadAchievements();
        
        achievementProgress = new FlxText(0, 0, 0, '${Language.get('achievements_unlocked', 'Unlocked:')} $unlockedAmount / $achievementAmount', 52);
        achievementProgress.font = Paths.font('NiseSega.ttf');
        achievementProgress.scale.set(0.5, 0.5);
        achievementProgress.updateHitbox();
        achievementProgress.antialiasing = ClientPrefs.data.antialiasing;
        achievementProgress.alpha = 0.7;
        achievementProgress.x = FlxG.width - achievementProgress.width - 35;
        achievementProgress.y = FlxG.height - achievementProgress.height - 10;
        achievementProgress.scrollFactor.set();
        FlxTween.tween(achievementProgress, {alpha: 0}, 0.8, {ease: FlxEase.expoOut, type: 16});
        add(achievementProgress);

        add(achievementGroup);
        add(spikes);
        add(black);
        add(achievementsTitle);
        add(sideBar);
        add(sideBarScroll);

        achievementGroup.x = -FlxG.width;
        FlxTween.tween(achievementGroup, {x: 30}, 1.2, {ease: FlxEase.expoOut});
    }

    var isScrolling:Bool = false;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(controls.BACK) back();
        
        if(FlxG.keys.justPressed.G) EXEAchievements.unlockAll();
        if(FlxG.keys.justPressed.H) EXEAchievements.lockAll();

        achievementGroup.y = FlxMath.lerp(achievementGroup.y, 160 - achievementGroup.height * scrollValue, LERP_SPEED * elapsed);
        
        if (FlxG.mouse.justPressed) isScrolling = FlxG.mouse.overlaps(sideBarScroll);
        else if (!FlxG.mouse.pressed) isScrolling = false;

        var keyDelta:Float = 0;
        if (FlxG.keys.pressed.S || controls.UI_DOWN) keyDelta = WHEEL_SENSITIVITY / 5;
        if (FlxG.keys.pressed.W || controls.UI_UP)   keyDelta = -WHEEL_SENSITIVITY / 5;

        if(isScrolling #if mobile && pressHolding #end)
            sideBarScroll.y = FlxMath.bound(sideBarScroll.y + FlxG.mouse.deltaY, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height);
        else #if mobile if(pressHolding) #end
            sideBarScroll.y = FlxMath.bound(sideBarScroll.y - (#if !mobile FlxG.mouse.deltaWheel.y #else deltaMouseY #end * WHEEL_SENSITIVITY ) + keyDelta, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height);

        scrollValue = FlxMath.remapToRange(sideBarScroll.y, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height, 0, 0.95);
    }

    public function loadAchievements():Void
    {
        final rawJson = OpenFlAssets.getText(ACHIEVEMENTS_PATH + 'achievements.json').trim();
        achievementsData = cast tjson.TJSON.parse(rawJson);

        achievementAmount = achievementsData.length;
        for(i => achieve in achievementsData) 
        {
            final item = new AchievementItem(achieve);
            item.y = i * (AchievementItem.ITEM_HEIGHT + 10);
            achievementGroup.add(item);

            final separator = new FlxSprite(0, item.y + AchievementItem.ITEM_HEIGHT + 4).makeGraphic(AchievementItem.ITEM_WIDTH, 2, 0x33FFFFFF);
            achievementGroup.add(separator);

            if(EXEAchievements.isUnlocked(achieve.id)) unlockedAmount++;
        }
    }

    function back():Void
    {
        FlxG.sound.play(Paths.sound('cancelMenu'));

        FlxTween.tween(spikes, {y: -400}, 0.8, {ease: FlxEase.cubeIn});
        FlxTween.tween(black, {y: -400}, 0.8, {ease: FlxEase.cubeIn});
        FlxTween.tween(achievementsTitle, {y: -400}, 0.8, {ease: FlxEase.cubeIn});
        FlxTween.tween(sideBar, {alpha: 0}, 0.8, {ease: FlxEase.cubeIn});
        FlxTween.tween(sideBarScroll, {alpha: 0}, 0.8, {ease: FlxEase.cubeIn});
        FlxTween.tween(achievementProgress, {alpha: 0}, 0.8, {ease: FlxEase.cubeIn});
        // commented for the transition! 
        // FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.cubeInOut});
        // FlxTween.tween(bg2, {alpha: 0}, 0.8, {ease: FlxEase.cubeInOut});
        // FlxTween.tween(bg3, {alpha: 0}, 0.8, {ease: FlxEase.cubeInOut});
        FlxTween.tween(achievementGroup, {x: -FlxG.width}, 0.8, {ease: FlxEase.cubeIn});

        FlxTimer.wait(0.8, close);
    }
}