package minigames.thevalley.tiles;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import minigames.thevalley.TheValley;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.character.player.Player.PlayerMode;
import minigames.thevalley.tiles.Tiles;
import minigames.thevalley.tiles.npcs.NPCs.AmyNPC;
import minigames.thevalley.tiles.npcs.NPCs.GaryNPC;
import minigames.thevalley.tiles.npcs.NPCs.KnucklesNPC;

class TileMap
{
	public final tiles:Array<CrumblingTile> = [];
	public final grabbedTiles:Array<GrabbedTile> = [];
	public final holdingTiles:Array<HoldingTile> = [];
	public final bridges:Array<SonicBridge> = [];
	public final spines:Array<SpineTile> = [];
	public final garys:Array<GaryNPC> = [];
	public final amys:Array<AmyNPC> = [];
	public final knuckles:Array<KnucklesNPC> = [];
	public final loops:Array<LoopTile> = [];
	public final tails:Array<FlxSprite> = [];

	public var onPlayerKilled:Void->Void;

	var _dying:Bool = false;

	public function new() {}

	public function loadFromJson(state:FlxState):Void
	{
		if (!openfl.Assets.exists("assets/shared/data/minigame/thevalley/tiles.json")) return;
		final raw = #if sys sys.FileSystem.exists("assets/shared/data/minigame/thevalley/tiles.json") ? sys.io.File.getContent("assets/shared/data/minigame/thevalley/tiles.json") : #end openfl.Assets.getText("assets/shared/data/minigame/thevalley/tiles.json");
		if (raw == null || raw == "") return;

		final data:Dynamic = haxe.Json.parse(raw);
		final legacy = data is Array;
		function each(key:String, spawn:(Float, Float) -> Void)
		{
			final list:Array<Dynamic> = legacy ? (key == "crumble" ? data : null) : Reflect.field(data, key);
			if (list != null) for (d in list) spawn(d.x, d.y);
		}

		final tv = Std.downcast(state, TheValley);
		function place(spr:FlxSprite)
		{
			if (tv != null) tv.objectGroup.add(spr);
			else state.add(spr);
		}

		each("holding",  (x, y) -> holdingTiles.push(new HoldingTile(x, y, state)));
		each("spine",    (x, y) -> { final sp = new SpineTile(x, y); spines.push(sp); state.add(sp.sprite); });
		each("gary",     (x, y) -> { final g = new GaryNPC(x, y, tv); garys.push(g); place(g); });
		each("amy",      (x, y) -> { final a = new AmyNPC(x, y); amys.push(a); place(a); });
		each("knuckles", (x, y) -> { final k = new KnucklesNPC(x, y); knuckles.push(k); place(k); });
		each("crumble",  (x, y) -> { final t = new CrumblingTile(x, y); tiles.push(t); state.add(t); });
		each("grabbed",  (x, y) -> grabbedTiles.push(new GrabbedTile(x, y, state)));
		each("bridge",   (x, y) -> bridges.push(new SonicBridge(x, y, state)));
		each("loop",     (x, y) -> { final l = new LoopTile(x, y); loops.push(l); place(l); });
		each("tails",    (x, y) -> { final t = tailsSprite(x, y); tails.push(t); place(t); });
	}

	public static function tailsSprite(x:Float, y:Float):FlxSprite
	{
		final t = new FlxSprite(x, y, Paths.image('minigame/thevalley/bg/tiles/tails/tails'));
		t.active = false;
		return t;
	}

	public function insertSpineSprites(state:FlxState, map7Spr:FlxSprite):Void
	{
		final idx = state.members.indexOf(map7Spr);
		if (idx < 0) return;
		for (sp in spines)
		{
			state.members.remove(sp.sprite);
			state.members.insert(idx + 1, sp.sprite);
		}
	}

	public function insertHoldingSprites(state:FlxState, anchors:Array<FlxSprite>):Void
	{
		var refIdx = -1;
		for (a in anchors)
		{
			final i = state.members.indexOf(a);
			if (i >= 0 && (refIdx < 0 || i < refIdx)) refIdx = i;
		}
		if (refIdx < 0) return;
		for (ht in holdingTiles)
		{
			state.members.remove(ht.ropeSprite);
			state.members.remove(ht.tileSprite);
			state.members.insert(refIdx, ht.ropeSprite);
			state.members.insert(refIdx, ht.tileSprite);
		}
	}

	public function update(elapsed:Float, player:Player):Void
	{
		final px = player.x;
		inline function near(x:Float) return Math.abs(x - px) < 1400.0;

		for (t in tiles)
		{
			if (t.atRest() && !near(t.x)) continue;
			final on = t.tileState == Gone || t.tileState == Sinking
				? player.x + player.width > t.x - 8 && player.x < t.x + CrumblingTile.TILE_W + 8 && player.y < t.y + CrumblingTile.TILE_H && player.y + player.height > t.surfaceTop() - 60
				: TileKit.standing(player, t.x + t.surface.x, t.surface.w, t.surfaceTop());
			t.tileUpdate(elapsed, on);
		}

		for (ht in grabbedTiles) if (!ht.atRest() || near(ht.x)) ht.update(elapsed, player);
		for (ht in holdingTiles) if (!ht.atRest() || near(ht.x)) ht.update(elapsed, player);
		for (br in bridges) if (!br.atRest() || near(br.x) || near(br.x + br.totalWidth)) br.update(elapsed, player);

		_updateSpines(player);
	}

	function _updateSpines(player:Player):Void
	{
		if (_dying)
		{
			player.body.velocity.setxy(0, 0);
			player.body.angularVel = 0;
			player.setGravity(false);
			return;
		}

		if (player.cinematic) return;

		var warning = false;
		for (sp in spines)
		{
			if (sp.checkKill(player))
			{
				_dying = true;
				player.cinematic = true;
				player.body.velocity.setxy(0, 0);
				player.body.angularVel = 0;
				player.setGravity(false);
				player.lockedAnim = "death1";
				player.animation.play("death1", true);
				FlxG.sound.play(Paths.sound("minigame/thevalley/deathspikes"), 0.7);
				if (onPlayerKilled != null) onPlayerKilled();
				return;
			}
			if (!warning && sp.checkFallingWarning(player)) warning = true;
		}

		if (warning)
		{
			if (player.lockedAnim != "fallingtodeath") player.mode = PlayerMode.Air;
			player.lockedAnim = "fallingtodeath";
		}
		else if (player.lockedAnim == "fallingtodeath")
			player.lockedAnim = null;
	}

	public function clearDying(player:Player):Void
	{
		_dying = false;
		player.cinematic = false;
		player.lockedAnim = null;
		player.setGravity(true);
	}
}
