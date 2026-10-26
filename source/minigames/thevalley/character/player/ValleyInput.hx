package minigames.thevalley.character.player;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepadInputID;

class ValleyInput
{
	static function _pad(id:FlxGamepadInputID, status:FlxInputState):Bool
	{
		final pad = FlxG.gamepads.lastActive;
		return pad != null && pad.checkStatus(id, status);
	}

	static inline function _tp(name:String):Bool
	{
		#if mobile
		return minigames.MiniTouchPad.pressed(name);
		#else
		return false;
		#end
	}

	static inline function _tj(name:String):Bool
	{
		#if mobile
		return minigames.MiniTouchPad.justPressed(name);
		#else
		return false;
		#end
	}

	static inline function _tr(name:String):Bool
	{
		#if mobile
		return minigames.MiniTouchPad.justReleased(name);
		#else
		return false;
		#end
	}

	public static function left():Bool
		return FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A || Controls.instance.UI_LEFT;

	public static function right():Bool
		return FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D || Controls.instance.UI_RIGHT;

	public static function up():Bool
		return FlxG.keys.pressed.UP || FlxG.keys.pressed.W || Controls.instance.UI_UP;

	public static function down():Bool
		return FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S || Controls.instance.UI_DOWN;

	public static function run():Bool
		return FlxG.keys.pressed.SHIFT || _pad(X, PRESSED) || _pad(RIGHT_SHOULDER, PRESSED) || _pad(RIGHT_TRIGGER, PRESSED) || _tp('run');

	public static function jumpJust():Bool
		return FlxG.keys.justPressed.Z || FlxG.keys.justPressed.SPACE || _pad(A, JUST_PRESSED) || _tj('jump');

	public static function jumpHeld():Bool
		return FlxG.keys.pressed.Z || FlxG.keys.pressed.SPACE || _pad(A, PRESSED) || _tp('jump');

	public static function jumpReleased():Bool
		return FlxG.keys.justReleased.Z || FlxG.keys.justReleased.SPACE || _pad(A, JUST_RELEASED) || _tr('jump');

	public static function interact():Bool
		return FlxG.keys.justPressed.E || _pad(B, JUST_PRESSED) || _pad(Y, JUST_PRESSED) || _tj('accept');

	public static function shardsHeld():Bool
		return FlxG.keys.pressed.TAB || _pad(BACK, PRESSED) || _pad(LEFT_SHOULDER, PRESSED) || _tp('shards');

	public static function shardsJust():Bool
		return FlxG.keys.justPressed.TAB || _pad(BACK, JUST_PRESSED) || _pad(LEFT_SHOULDER, JUST_PRESSED) || _tj('shards');

	public static function skip():Bool
		return FlxG.keys.justPressed.SPACE || _pad(A, JUST_PRESSED) || _tj('skip');

	public static function movedJust(withJump:Bool = true):Bool
	{
		final c = Controls.instance;
		return FlxG.keys.anyJustPressed([LEFT, RIGHT, UP, DOWN, A, D, W, S])
			|| c.UI_LEFT_P || c.UI_RIGHT_P || c.UI_UP_P || c.UI_DOWN_P || (withJump && jumpJust());
	}

	public static function any():Bool
	{
		final pad = FlxG.gamepads.lastActive;
		return FlxG.keys.pressed.ANY || (pad != null && pad.pressed.ANY) || _tp('left') || _tp('right') || _tp('up') || _tp('down') || _tp('jump') || _tp('accept');
	}
}
