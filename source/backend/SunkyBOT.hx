package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import objects.Note;

class SunkyBOT
{
	static final spriteScale:Float = 0.6;
	static final spritePath:String = 'assets/exe/botplay/sunkyplaying';

	public var sprite(default, null):FlxSprite;

	/**
		* Variable for the possible cheat scripts that activate botplay
		- cool or cooln't
	**/
	public var wasActivated(default, null):Bool = false;

	final game:PlayState;
	var shown:Bool = false;
	var animPlaying:Bool = false;
	var animTimer:Float = 0;

	public function new(game:PlayState)
	{
		this.game = game;
	}

	public function createSprite():Void
	{
		if (!game.cpuControlled) return;

		sprite = new FlxSprite();
		final bitmap:openfl.display.BitmapData = Paths.getBitmapData('$spritePath.png');
		final xml:String = Paths.getContent('$spritePath.xml');
		sprite.frames = FlxAtlasFrames.fromSparrow(bitmap, xml);

		sprite.animation.addByPrefix('idle',  'idle instancia',  24, true);
		sprite.animation.addByPrefix('left',  'left instancia',  24, false);
		sprite.animation.addByPrefix('down',  'down instancia',  24, false);
		sprite.animation.addByPrefix('up',    'up instancia',    24, false);
		sprite.animation.addByPrefix('right', 'right instancia', 24, false);
		sprite.animation.addByPrefix('space', 'space instancia', 24, false);
		sprite.animation.play('idle');

		sprite.setGraphicSize(Std.int(sprite.width * spriteScale));
		sprite.updateHitbox();
		sprite.scrollFactor.set();
		sprite.antialiasing = ClientPrefs.data.antialiasing;
		sprite.visible = true;
		sprite.alpha = 1;
		sprite.cameras = [game.camOther];
		final targetX:Float = FlxG.width - sprite.width - 10;
		sprite.x = FlxG.width + 50;
		sprite.y = FlxG.height - sprite.height - 10;
		game.add(sprite);
		FlxTween.cancelTweensOf(sprite);
		FlxTween.tween(sprite, {x: targetX}, 0.7, {ease: FlxEase.elasticOut, startDelay: 0.3});
		shown = true;
	}

	public function shouldHit(note:Note):Bool
	{
		return (game.cpuControlled || game.cpuAssist) && !note.blockHit && note.canBeHit && !note.wasGoodHit
			&& (note.isSustainNote || note.strumTime <= Conductor.songPosition);
	}

	public function update(elapsed:Float):Void
	{
		if (game.cpuControlled)
		{
			if (sprite == null)
				createSprite();
			else if (!shown)
			{
				shown = true;
				sprite.visible = true;
				FlxTween.cancelTweensOf(sprite);
				FlxTween.tween(sprite, {x: game.camOther.width - sprite.width - 10}, 0.7, {ease: FlxEase.elasticOut});
			}
			wasActivated = true;
		}
		else if (sprite != null && shown)
		{
			shown = false;
			FlxTween.cancelTweensOf(sprite);
			final spr = sprite;
			FlxTween.tween(spr, {x: game.camOther.width + 50}, 0.4, {ease: FlxEase.quadIn, onComplete: (_) -> { if (!shown) spr.visible = false; }});
		}

		if (sprite != null && animPlaying)
		{
			animTimer -= elapsed;
			if (animTimer <= 0)
			{
				animPlaying = false;
				sprite.animation.play('idle');
			}
		}
	}

	public function onNoteHit(noteData:Int):Void
	{
		if (sprite == null) return;

		final anim:String = switch (noteData)
		{
			case 0: 'left';
			case 1: 'down';
			case 2: 'up';
			case 3: 'right';
			default: 'space';
		};
		if (sprite.animation.curAnim == null || sprite.animation.curAnim.name != anim)
			sprite.animation.play(anim, true);
		animPlaying = true;
		animTimer = Conductor.stepCrochet * 1.5 / 1000 / game.playbackRate;
	}
}
