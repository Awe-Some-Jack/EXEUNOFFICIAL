package states.extras.achievements;

import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import states.extras.achievements.AchievementItem;
import flixel.group.FlxSpriteGroup;
import backend.EXEAchievements.EXEAchievement;
import backend.EXEAchievements;
import states.EXEMenu;

class AchievementsState extends MusicBeatSubstate 
{
    var bg:FlxSprite;
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
    static inline final WHEEL_SENSITIVITY:Float = 4;
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
        final _ch = new FlxBackdrop(_cbmd, XY, 0, 0);
        _ch.alpha = 0.10;
        _ch.velocity.x = -60;
        add(_ch);

        final _fadeBmd = new openfl.display.BitmapData(_w, _h, true, 0x00000000);
        for (_x in 0..._w) {
            final t = 1.0 - _x / (_w - 1);
            final r = Math.round(0xbd + (0x57 - 0xbd) * t);
            final b = Math.round(0x33 + (0x0b - 0x33) * t);
            final a = Math.round(t * 255);
            _fadeBmd.fillRect(new openfl.geom.Rectangle(_x, 0, 1, _h), (a << 24) | (r << 16) | b);
        }
        add(new FlxSprite().loadGraphic(_fadeBmd));

        add(achievementGroup);

        spikes = new FlxBackdrop(null, X);
        spikes.makeGraphic(100, 100, 0xFF000000);
        spikes.spacing.x = 40;
        spikes.angle = 45;
		spikes.y = spikes.height / 2;
		spikes.velocity.x = -50;
		add(spikes);

        black = new FlxSprite().makeGraphic(FlxG.width, Std.int(spikes.y + spikes.height / 2), 0xFF000000);
        add(black);

        achievementsTitle = new FlxText(30, 30, 0, Language.get('mainmenu.achievements', 'ACHIEVEMENTS'), 100);
        achievementsTitle.font = Paths.font('NiseSegaSonic.ttf');
        achievementsTitle.scale.set(0.5, 0.5);
        achievementsTitle.updateHitbox();
        achievementsTitle.antialiasing = true;
        add(achievementsTitle);

        sideBar = new FlxSprite(FlxG.width - 30, 210).makeGraphic(12, 450, 0x55000000);
        add(sideBar);

        sideBarScroll = new FlxSprite(sideBar.x, sideBar.y).makeGraphic(12, 75, 0xCCFFFFFF);
        add(sideBarScroll);

        loadAchievements();
        
        achievementProgress = new FlxText(0, 0, 0, 'Unlocked: $unlockedAmount / $achievementAmount', 52);
        achievementProgress.font = Paths.font('NiseSegaSonic.ttf');
        achievementProgress.scale.set(0.5, 0.5);
        achievementProgress.updateHitbox();
        achievementProgress.antialiasing = true;
        achievementProgress.alpha = 0.7;
        achievementProgress.x = FlxG.width - achievementProgress.width - 35;
        achievementProgress.y = FlxG.height - achievementProgress.height - 10;
        achievementProgress.scrollFactor.set();
        add(achievementProgress);

        achievementGroup.x = -FlxG.width;
        FlxTween.tween(achievementGroup, {x: 30}, 1.2, {ease: FlxEase.expoOut});
    }

    var isScrolling:Bool = false;
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if(controls.BACK) 
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            close();
        }
        if(FlxG.keys.justPressed.G) EXEAchievements.unlockAll();
        if(FlxG.keys.justPressed.H) EXEAchievements.lockAll();

        achievementGroup.y = FlxMath.lerp(achievementGroup.y, 160 - achievementGroup.height * scrollValue, LERP_SPEED * elapsed);
        
        if (FlxG.mouse.justPressed) isScrolling = FlxG.mouse.overlaps(sideBarScroll);
        else if (!FlxG.mouse.pressed) isScrolling = false;

        var keyDelta:Float = 0;
        if (FlxG.keys.pressed.S || controls.UI_DOWN) keyDelta = WHEEL_SENSITIVITY / 5;
        if (FlxG.keys.pressed.W || controls.UI_UP)   keyDelta = -WHEEL_SENSITIVITY / 5;

        if(isScrolling)
            sideBarScroll.y = FlxMath.bound(sideBarScroll.y + FlxG.mouse.deltaY, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height);
        else
            sideBarScroll.y = FlxMath.bound(sideBarScroll.y - (FlxG.mouse.wheel * WHEEL_SENSITIVITY) + keyDelta, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height);

        scrollValue = FlxMath.remapToRange(sideBarScroll.y, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height, 0, 0.95);
    }

    public function loadAchievements():Void
    {
        var rawJson = File.getContent(ACHIEVEMENTS_PATH + 'achievements.json').trim();
        achievementsData = cast tjson.TJSON.parse(rawJson);

        achievementAmount = achievementsData.length;
        for(i => achieve in achievementsData) 
        {
            var item = new AchievementItem(achieve);
            item.y = i * (AchievementItem.ITEM_HEIGHT + 10);
            achievementGroup.add(item);

            var separator = new FlxSprite(0, item.y + AchievementItem.ITEM_HEIGHT + 4).makeGraphic(AchievementItem.ITEM_WIDTH, 2, 0x33FFFFFF);
            achievementGroup.add(separator);

            if(EXEAchievements.isUnlocked(achieve.id)) unlockedAmount++;
        }
    }
}