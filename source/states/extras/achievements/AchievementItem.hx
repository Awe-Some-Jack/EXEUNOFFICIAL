package states.extras.achievements;

import flixel.group.FlxSpriteGroup;
import backend.EXEAchievements;
import backend.EXEAchievements.EXEAchievement;
#if !flash
import openfl.filters.ShaderFilter;
#end

import shaders.ErrorHandledShader;
import shaders.ColorSwap;

class AchievementItem extends FlxSpriteGroup
{
    public var achievementId:String;
    public var achievementData:EXEAchievement;
    public var unlocked:Bool = false;
    public var icon:FlxSprite;
    public var title:FlxText;
    public var description:FlxText;

    public static final ICON_SIZE:Int = 115;
    public static final ITEM_HEIGHT:Int = 145;
    public static final ITEM_WIDTH:Int = 900;

    public function new(data:EXEAchievement)
    {
        super();

        achievementData = data;
        achievementId = data.id;
        unlocked = EXEAchievements.isUnlocked(achievementId);

        final iconBg = new FlxSprite(15, 15).makeGraphic(ICON_SIZE, ICON_SIZE, 0x55000000);
        add(iconBg);

        final iconName:String = !unlocked && data.secret ? 'locked' : achievementId;
        icon = new FlxSprite(15, 15).loadGraphic(Paths.getBitmapData('assets/exe/extras/achievements/icons/${iconName}.png'));
        icon.setGraphicSize(ICON_SIZE, ICON_SIZE);
        icon.updateHitbox();
        add(icon);

        final textW:Int = (ITEM_WIDTH - 155 - 15) * 2;
        title = new FlxText(155, 0, textW, data.name, 80);
        title.font = Paths.font('NiseSegaSonic.ttf');
        title.scale.set(0.5, 0.5);
        title.updateHitbox();
        title.antialiasing = true;

        description = new FlxText(155, 0, textW, data.description, 56);
        description.font = Paths.font('NiseSegaSonic.ttf');
        description.scale.set(0.5, 0.5);
        description.updateHitbox();
        description.antialiasing = true;

        final totalTextH = title.height + 6 + description.height;
        final textY = (ITEM_HEIGHT - totalTextH) / 2;
        title.y = textY;
        description.y = textY + title.height + 6;

        add(title);
        add(description);

        if(!unlocked)
        {
            final colorSwap:ColorSwap = new ColorSwap();
            colorSwap.hue = -1;
            colorSwap.brightness = -0.5;
            colorSwap.saturation = -1;

            icon.shader = colorSwap.shader;
            title.color = description.color = 0xFF666666;

            if(data.secret)
            {
                title.text = questionify(data.name);
                description.text = 'Unlock this achievement to see its description.';
            }
        }
    }

    function questionify(text:String)
    {
        var newWord:Array<String> = [];
        var chars:Array<String> = text.split('');
        for(char in chars)
            newWord.push(char == ' ' ? ' ' : '?');

        return newWord.join('');
    }
}
