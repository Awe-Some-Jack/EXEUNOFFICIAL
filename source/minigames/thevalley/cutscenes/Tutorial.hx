package minigames.thevalley.cutscenes;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;

import minigames.thevalley.character.player.Player;
import minigames.thevalley.character.player.Player.PlayerMode;
import minigames.thevalley.character.player.ValleyInput;
import minigames.thevalley.tiles.ShardHunt;
import minigames.thevalley.tiles.Tiles.SkullPrompt;
import minigames.thevalley.tiles.Tiles.Totem;

enum TutorialPhase
{
	Intro;
	Steps;
	Outro;
	Story;
	Leave;
}

class Tutorial
{
	static final STEPS:Array<{ key:String, action:String, fallback:String }> = [
		{ key: "LEFT / RIGHT   -   A / D", action: "valley_tutorial_move", fallback: "MOVE" },
		{ key: "SHIFT", action: "valley_tutorial_run", fallback: "HOLD TO RUN" },
		{ key: "Z / SPACE", action: "valley_tutorial_jump", fallback: "JUMP" },
		{ key: "Z / SPACE", action: "valley_tutorial_glide", fallback: "PRESS AGAIN IN THE AIR TO GLIDE" },
		{ key: "E", action: "valley_tutorial_skull", fallback: "SEARCH THE SKULL" },
		{ key: "E", action: "valley_tutorial_hide", fallback: "HIDE IN THE TOTEM" },
		{ key: "E", action: "valley_tutorial_unhide", fallback: "GET OUT OF THE TOTEM" },
	];

	static final STORY:Array<String> = [
		"You woke up with no sign of your boyfriend...",
		"But you feel like you're constantly being watched.",
		"In this lifeless place, search for your loved one while hiding from the unknown. But be aware that $IT$ will not let you go easily.",
		"Search for #Safe Spots# and #Small Entrances#. Do NOT let $him$ find you.",
	];

	public var onDone:Void->Void;

	final _state:FlxState;
	final _world:FlxCamera;
	final _ui:FlxCamera;
	final _cam:FlxCamera;
	final _box:FlxCamera;
	final _player:Player;
	final _sprites:Array<FlxSprite> = [];
	final _bodies:Array<Body> = [];
	final _ox:Float = -3000;
	final _oy:Float = -2000;
	final _objects:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	final _eButton:FlxSprite;
	final _skull:SkullPrompt;
	final _totem:Totem;
	var _skullWon:Bool = false;
	final _render:FlxSprite;
	final _frame:Array<FlxSprite> = [];
	final _title:FlxText;
	final _key:FlxText;
	final _action:FlxText;
	final _count:FlxText;
	final _story:Array<FlxText> = [];
	final _continue:FlxText;
	final _cover:FlxSprite;

	var _phase:TutorialPhase = Intro;
	var _timer:Float = 0;
	var _clock:Float = 0;
	var _step:Int = 0;
	var _progress:Float = 0;
	var _cleared:Float = -1;
	var _lastX:Float = 0;
	var _camX:Float = 0;
	var _camY:Float = 0;

	public function new(state:FlxState, world:FlxCamera, ui:FlxCamera, player:Player, camera:minigames.Camera)
	{
		_state = state;
		_world = world;
		_ui = ui;
		_player = player;

		final x0 = 40;
		final y0 = 156;
		_box = new FlxCamera(x0, y0, 576, 324);
		_box.bgColor = 0xFF3A6BC4;
		_box.zoom = 2;
		FlxG.cameras.add(_box, false);

		_cam = new FlxCamera();
		_cam.bgColor = 0x00000000;
		FlxG.cameras.add(_cam, false);
		_ui.visible = false;
		_world.visible = false;

		final room = new FlxSprite(_ox - 32, _oy - 200, Paths.image("minigame/thevalley/hud/tutorial/room"));
		room.antialiasing = false;
		room.active = false;
		room.cameras = [_box];
		state.insert(state.members.indexOf(player), room);
		_sprites.push(room);
		_solid(_ox - 32, _oy + 200, 764, 48);
		_solid(_ox + 400, _oy + 152, 96, 48);
		_solid(_ox - 32, _oy - 200, 32, 400);
		_solid(_ox + 700, _oy - 200, 32, 400);

		_eButton = new FlxSprite();
		_eButton.frames = Paths.getSparrowAtlas('minigame/thevalley/characters/fakergf/button');
		_eButton.animation.addByIndices("idle", "button press", [0], "", 1, true);
		_eButton.animation.play("idle");
		_eButton.scale.set(1.2, 1.2);
		_eButton.updateHitbox();
		_eButton.alpha = 0;

		_skull = new SkullPrompt(_ox + 250, _oy, player, _eButton, _objects, camera, new ShardHunt(), (_, _) -> _skullWon = true);
		@:privateAccess _skull._skull.y = _oy + 200 - _skull._skull.height;
		_totem = new Totem(0, 0, Short, player, _eButton, _objects, state);
		_totem.placeAt(_ox + 610, _oy + 200);
		for (spr in _objects.members) spr.cameras = [_box];
		_eButton.cameras = [_box];
		state.insert(state.members.indexOf(player), _objects);
		state.add(_eButton);

		_add(state, new FlxSprite(0, 0).makeGraphic(FlxG.width, y0, FlxColor.BLACK));
		_add(state, new FlxSprite(0, y0 + 324).makeGraphic(FlxG.width, FlxG.height - y0 - 324, FlxColor.BLACK));
		_add(state, new FlxSprite(0, y0).makeGraphic(x0, 324, FlxColor.BLACK));
		_add(state, new FlxSprite(x0 + 576, y0).makeGraphic(FlxG.width - x0 - 576, 324, FlxColor.BLACK));

		for (side in 0...4)
		{
			final horizontal = side < 2;
			final bar = new FlxSprite(side == 3 ? x0 + 576 : x0 - 4, side == 1 ? y0 + 324 : y0 - 4)
				.makeGraphic(horizontal ? 576 + 8 : 4, horizontal ? 4 : 324 + 8, 0xFF8C8CA0);
			_frame.push(_add(state, bar));
		}

		_render = _add(state, new FlxSprite(0, 0, Paths.image("minigame/thevalley/hud/tutorial/render")));
		_render.scale.set(2.3, 2.3);
		_render.updateHitbox();
		_render.setPosition(FlxG.width - 10 - 273 * 2.3, FlxG.height - 268 * 2.3);

		_title = _text(state, x0, y0 - 64, 576, Language.getPhrase("valley_tutorial_title", "HOW TO SURVIVE"), 34);
		_key = _text(state, x0, y0 + 324 + 26, 576, "", 30);
		_action = _text(state, x0, y0 + 324 + 70, 576, "", 22);
		_action.color = 0xFFB8B8C8;
		_count = _text(state, x0, y0 + 324 + 128, 576, "", 18);
		_count.color = 0xFF6E6E80;

		final red = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFE03C3C), "#");
		final blue = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF6478FF), "$");
		var y = 96.0;
		for (i in 0...STORY.length)
		{
			final t = _text(state, x0, y, 600, "", 24, false);
			t.applyMarkup(Language.getPhrase('valley_tutorial_story_${i + 1}', STORY[i]), [red, blue]);
			t.alpha = 0;
			_story.push(t);
			y += t.height + 26;
		}
		_continue = _text(state, x0, FlxG.height - 70, 600, Language.getPhrase("valley_tutorial_continue", "PRESS ENTER TO CONTINUE"), 20, false);
		_continue.alpha = 0;

		_cover = _add(state, new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		_player.cinematic = false;
		_player.lockedAnim = null;
		_player.mode = Ground;
		_player.cameras = [_box];
		_player.body.position.setxy(_ox + 120, _oy + 200 - _player.height * 0.5 - 1);
		_player.body.velocity.setxy(0, 0);
		_player.animation.play("idle", true);
		_lastX = _player.body.position.x;
		_camX = _player.body.position.x;
		_camY = _player.body.position.y - 10;
		_showStep();
	}

	function _solid(x:Float, y:Float, w:Float, h:Float):Void
	{
		final body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(x, y, w, h)));
		body.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		body.space = FlxNapeSpace.space;
		_bodies.push(body);
	}

	function _add<T:FlxSprite>(state:FlxState, spr:T):T
	{
		spr.antialiasing = false;
		spr.scrollFactor.set(0, 0);
		spr.cameras = [_cam];
		state.add(spr);
		_sprites.push(spr);
		return spr;
	}

	function _text(state:FlxState, x:Float, y:Float, width:Float, text:String, size:Int, center:Bool = true):FlxText
	{
		final t = new FlxText(x, y, width, text, size);
		final langFont = Language.getPhrase("valley_subtitle_font", "");
		t.font = langFont.length > 0 ? Paths.font(langFont) : "assets/fonts/SonicFont.ttf";
		t.alignment = center ? FlxTextAlign.CENTER : FlxTextAlign.LEFT;
		t.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 3);
		return _add(state, t);
	}

	public function update(elapsed:Float):Void
	{
		_timer += elapsed;
		_clock += elapsed;
		_follow(elapsed);

		switch (_phase)
		{
			case Intro:
				_player.cinematic = true;
				_cover.alpha = 1 - Math.min(1, _timer / 0.8);
				if (_timer >= 0.8)
				{
					_player.cinematic = false;
					_setPhase(Steps);
				}

			case Steps:
				_updateStep(elapsed);

			case Outro:
				_player.cinematic = true;
				final t = Math.min(1, _timer / 0.6);
				for (spr in [_title, _key, _action, _count]) spr.alpha = 1 - t;
				for (bar in _frame) bar.alpha = 1 - t;
				_box.alpha = 1 - t;
				if (_timer >= 0.8)
				{
					_box.visible = false;
					_setPhase(Story);
				}

			case Story:
				for (i in 0..._story.length)
				{
					final t = FlxEase.quadOut(Math.max(0, Math.min(1, (_timer - 0.3 - i * 1.1) / 0.7)));
					_story[i].alpha = t;
					_story[i].offset.x = -18 * (1 - t);
				}
				final ready = _timer >= 0.3 + _story.length * 1.1;
				if (ready) _continue.alpha = 0.55 + 0.35 * Math.sin(_clock * 4);
				if (ready && Controls.instance.ACCEPT)
				{
					FlxG.sound.play(Paths.sound("confirmMenu"), 0.5);
					_setPhase(Leave);
				}

			case Leave:
				_cover.alpha = Math.min(1, _timer / 0.6);
				if (_timer >= 0.8) _finish();
		}
	}

	function _updateStep(elapsed:Float):Void
	{
		final x = _player.body.position.x;
		_updateObjects(elapsed);

		if (_cleared >= 0)
		{
			_cleared += elapsed;
			_key.color = _action.color = 0xFF5CE07A;
			if (_cleared >= 0.9 && !_skull.isBusy())
			{
				_cleared = -1;
				_step++;
				if (_step >= STEPS.length) _setPhase(Outro);
				else _showStep();
			}
			_lastX = x;
			return;
		}

		final vx = Math.abs(_player.body.velocity.x);
		switch (_step)
		{
			case 0:
				if (_player.isGrounded) _progress += Math.abs(x - _lastX) / 120;
			case 1:
				if (ValleyInput.run() && _player.isGrounded && vx > _player.cfg.physics.walkMax) _progress += elapsed / 0.6;
			case 2:
				if (!_player.isGrounded && _player.mode == Air && _player.body.velocity.y < 0) _progress = 1;
			case 3:
				if (_player.mode == Glide) _progress += elapsed / 0.35;
			case 4:
				if (_skullWon) _progress = 1;
			case 5:
				if (_player.isHidden) _progress = 1;
			default:
				if (!_totem.isBusy()) _progress = 1;
		}
		_lastX = x;

		_key.scale.x = _key.scale.y = 1 + 0.04 * Math.sin(_clock * 6);
		if (_progress >= 1)
		{
			_cleared = 0;
			_key.scale.set(1.15, 1.15);
			FlxG.sound.play(Paths.sound("minigame/thevalley/crystal"), 0.35);
		}
	}

	function _updateObjects(elapsed:Float):Void
	{
		_skull.update(elapsed);
		final skullOn = _skull.isBusy() || (_step == 4 && _cleared < 0);
		final totemOn = _totem.isBusy() || (_step >= 5 && _cleared < 0);
		if (skullOn) _skull.updateActive(elapsed, _skull.getDist());
		if (totemOn) _totem.updateActive(elapsed, _totem.getDist());
		if (!skullOn && !totemOn) _eButton.alpha = 0;

		if (_totem.hiddenTime >= 12 && _totem.isBusy())
		{
			_totem.interrupt();
			_player.setGravity(true);
			_player.animation.play("idle", true);
		}
	}

	function _showStep():Void
	{
		final s = STEPS[_step];
		_progress = 0;
		_key.text = s.key;
		_action.text = Language.getPhrase(s.action, s.fallback);
		_key.color = FlxColor.WHITE;
		_action.color = 0xFFB8B8C8;
		_count.text = '${_step + 1} / ${STEPS.length}';
	}

	function _follow(elapsed:Float):Void
	{
		final ease = 1.0 - Math.pow(0.01, elapsed * 2.5);
		_camX += (_player.body.position.x - _camX) * ease;
		_camY += (_player.body.position.y - 10 - _camY) * ease;
		final cx = Math.max(_ox + 112, Math.min(_ox + 588, _camX));
		final cy = Math.min(_oy + 150, _camY);
		_box.scroll.set(cx - _box.width * 0.5, cy - _box.height * 0.5);
	}

	function _finish():Void
	{
		FlxG.save.data.tvTutorialSeen = true;
		FlxG.save.flush();

		_totem.interrupt();
		_player.isHidden = _player.isHiding = false;
		_player.setGravity(true);
		_player.lockedAnim = null;
		_player.cinematic = true;
		_player.cameras = null;
		_player.body.velocity.setxy(0, 0);
		for (body in _bodies) body.space = null;
		_world.visible = true;
		_ui.visible = true;
		for (spr in _sprites)
		{
			_state.remove(spr, true);
			spr.destroy();
		}
		for (spr in _objects.members.copy())
			if (spr != null) _state.remove(spr, true);
		_state.remove(_totem.sprite, true);
		if (!_objects.members.contains(_totem.sprite)) _objects.add(_totem.sprite);
		_state.remove(_objects, true);
		_objects.destroy();
		_state.remove(_eButton, true);
		_eButton.destroy();
		FlxG.cameras.remove(_cam);
		FlxG.cameras.remove(_box);
		if (onDone != null) onDone();
	}

	inline function _setPhase(p:TutorialPhase):Void
	{
		_phase = p;
		_timer = 0;
	}
}
