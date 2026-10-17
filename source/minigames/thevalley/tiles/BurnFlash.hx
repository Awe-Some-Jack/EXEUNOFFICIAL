package minigames.thevalley.tiles;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import minigames.thevalley.character.player.Player;

class BurnFlash
{
	final _state:FlxState;
	final _world:FlxCamera;
	final _ui:FlxCamera;
	final _overlay:FlxSprite;
	var _cam:FlxCamera = null;
	var _actors:Array<FlxSprite> = [];
	var _armed:Bool = false;
	var _time:Float = 0;

	public function new(state:FlxState, world:FlxCamera, ui:FlxCamera)
	{
		_state = state;
		_world = world;
		_ui = ui;
		_overlay = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		_overlay.color = 0xFFD80C0C;
		_overlay.active = false;
	}

	public function arm(player:Player, totem:FlxSprite):Void
	{
		cancel();
		_actors = [player, totem];
		_armed = true;
	}

	public function cancel():Void
	{
		_armed = false;
		if (_cam == null) return;
		for (actor in _actors) actor.cameras = null;
		_state.remove(_overlay, true);
		FlxG.cameras.remove(_cam, true);
		_cam = null;
	}

	public function update(elapsed:Float, player:Player):Void
	{
		if (_armed)
		{
			final anim = player.animation.curAnim;
			if (anim == null || anim.name != "totemdeath") _armed = false;
			else if (anim.curFrame >= 3) _start(player);
		}
		if (_cam == null) return;

		_time += elapsed;
		final alpha = _time < 0.1 ? 1.0 : 1.0 - (_time - 0.1) / 0.9;
		if (alpha <= 0)
		{
			cancel();
			return;
		}
		_overlay.alpha = alpha;
		_sync();
	}

	function _start(player:Player):Void
	{
		_armed = false;
		_time = 0;
		_cam = new FlxCamera();
		_cam.bgColor = 0x00000000;
		final ui = FlxG.cameras.list.indexOf(_ui);
		FlxG.cameras.insert(_cam, ui >= 0 ? ui : FlxG.cameras.list.length, false);

		final at = _state.members.indexOf(player);
		_state.insert(at >= 0 ? at : 0, _overlay);
		_overlay.cameras = [_cam];
		_overlay.alpha = 1;
		for (actor in _actors) actor.cameras = [_world, _cam];
		_sync();
	}

	function _sync():Void
	{
		_cam.zoom = _world.zoom;
		_cam.scroll.copyFrom(_world.scroll);
		_overlay.setGraphicSize(Std.int(_world.viewWidth + 4.0 * 2), Std.int(_world.viewHeight + 4.0 * 2));
		_overlay.updateHitbox();
		_overlay.setPosition(_world.viewLeft - 4.0, _world.viewTop - 4.0);
	}
}
