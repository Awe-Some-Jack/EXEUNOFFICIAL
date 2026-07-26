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

    public static final ICON_SIZE:Int = 125;

    public function new(data:EXEAchievement) 
    {
        super();

        achievementData = data;
        achievementId = data.id;
        unlocked = EXEAchievements.isUnlocked(achievementId);

        final iconName:String = !unlocked && data.secret ? 'locked' : achievementId;
        icon = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/extras/achievements/icons/${iconName}.png'));
        icon.setGraphicSize(ICON_SIZE, ICON_SIZE);
        add(icon);

        title = new FlxText(150, 0, 900, data.name, 40);
        title.font = Paths.font('NiseSegaSonic.ttf');
        add(title);

        description = new FlxText(150, title.height + 7, 800, data.description, 30);
        description.font = Paths.font('NiseSegaSonic.ttf');
        add(description);

        if(!unlocked)
        {
			final colorSwap:ColorSwap = new ColorSwap();
			colorSwap.hue = -1;
			colorSwap.brightness = -0.5;
			colorSwap.saturation = -1;

            icon.shader = colorSwap.shader;
            title.color = description.color = 0xFF555555;

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