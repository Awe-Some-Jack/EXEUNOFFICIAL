package states.extras.achievements;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
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

        bg = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF3d0008, 0xFFbd0033], 1, 0);
        add(bg);

        add(achievementGroup);

        spikes = new FlxBackdrop(null, X);
        spikes.makeGraphic(100, 100, 0xFF000000);
        spikes.spacing.x = 40;
        spikes.angle = 45;
		spikes.y = spikes.height / 2;
		spikes.velocity.x = -50;
		add(spikes);

        black = new FlxSprite().makeGraphic(FlxG.width, Std.int(spikes.x + spikes.height), 0xFF000000);
        add(black);

        achievementsTitle = new FlxText(30, 30, 0, Language.get('mainmenu.achievements', 'ACHIEVEMENTS'), 50);
        achievementsTitle.font = Paths.font('NiseSegaSonic.ttf');
        add(achievementsTitle);

        sideBar = new FlxSprite(FlxG.width - 45, 210).makeGraphic(20, 450, 0x66000000);
        add(sideBar);

        sideBarScroll = new FlxSprite(sideBar.x, sideBar.y).makeGraphic(20, 75, 0xFFFFFFFF);
        add(sideBarScroll);

        loadAchievements();
        
        var percent:Float = FlxMath.roundDecimal((unlockedAmount / achievementAmount) * 100, 1);
        achievementProgress = new FlxText(5, 5, 0, 'Unlocked: $unlockedAmount / $achievementAmount  -  $percent%', 14);
        add(achievementProgress);

        achievementGroup.x = -FlxG.width;
        FlxTween.tween(achievementGroup, {x: 100}, 2, {ease: FlxEase.expoOut});
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

        achievementGroup.y = FlxMath.lerp(achievementGroup.y, 210 - achievementGroup.height * scrollValue, LERP_SPEED * elapsed);
        
        if (FlxG.mouse.justPressed) isScrolling = FlxG.mouse.overlaps(sideBarScroll);
        else if (!FlxG.mouse.pressed) isScrolling = false;

        if(isScrolling)
            sideBarScroll.y = FlxMath.bound(sideBarScroll.y + FlxG.mouse.deltaY, sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height);
        else 
            sideBarScroll.y = FlxMath.bound(sideBarScroll.y - (FlxG.mouse.wheel * WHEEL_SENSITIVITY), sideBar.y, sideBar.y + sideBar.height - sideBarScroll.height);

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
            item.y = i * 175;
            achievementGroup.add(item);

            var separator = new FlxSprite(30, item.y + AchievementItem.ICON_SIZE + 10).makeGraphic(700, 10, 0x88FFFFFF);
            achievementGroup.add(separator);

            if(EXEAchievements.isUnlocked(achieve.id)) unlockedAmount++;
        }
    }
}