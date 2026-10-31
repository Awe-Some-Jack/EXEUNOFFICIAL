package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextBorderStyle;

class ParallaxUnlockState extends MusicBeatState
{
	var transitioning:Bool = false;

	override function create():Void
	{
		super.create();

		FlxG.sound.music?.stop();
		FlxG.mouse.visible = true;

		final background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		add(background);

		final font = Language.needsCustomFont() ? Paths.font(Language.getFontForLanguage()) : Paths.font('SonicFont.ttf');

		final title = new FlxText(60, 0, FlxG.width - 120, Language.get('parallax.unlock.title', 'YOU UNLOCKED THE PARALLAX MENU!'), 48);
		title.setFormat(font, 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.screenCenter(Y);
		title.y -= 74;
		title.scrollFactor.set();
		add(title);

		final message = new FlxText(80, title.y + 105, FlxG.width - 160, Language.get('parallax.unlock.message', 'Return to the title screen to enter the menu.'), 32);
		message.setFormat(font, 32, 0xFFFF3030, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		message.scrollFactor.set();
		add(message);

		final prompt = new FlxText(60, FlxG.height - 100, FlxG.width - 120, Language.get('parallax.unlock.prompt', 'Press ENTER to return to the title screen.'), 24);
		prompt.setFormat(font, 24, FlxColor.WHITE, CENTER);
		prompt.scrollFactor.set();
		add(prompt);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!transitioning && (controls.ACCEPT #if mobile || shortPress #end))
		{
			transitioning = true;
			FlxG.save.data.parallaxUnlockNoticePending = false;
			FlxG.save.flush();
			FlxG.switchState(() -> new EXETitle());
		}
	}
}
