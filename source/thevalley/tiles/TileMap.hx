package thevalley.tiles;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import thevalley.tiles.Tiles.CrumblingTile;
import thevalley.tiles.Tiles.GrabbedTile;
import thevalley.tiles.Tiles.HoldingTile;
import thevalley.tiles.Tiles.SonicBridge;
import thevalley.tiles.Tiles.SpineTile;
import thevalley.npcs.NPCs.GaryNPC;
import thevalley.npcs.NPCs.AmyNPC;
import thevalley.npcs.NPCs.KnucklesNPC;
import thevalley.player.Player;
import thevalley.TheValley;

class TileMap
{
	public var tiles:Array<CrumblingTile>        = [];
	public var grabbedTiles:Array<GrabbedTile>   = [];
	public var holdingTiles:Array<HoldingTile>   = [];
	public var bridges:Array<SonicBridge>        = [];
	public var spines:Array<SpineTile>           = [];
	public var garys:Array<GaryNPC>              = [];
	public var amys:Array<AmyNPC>                = [];
	public var knuckles:Array<KnucklesNPC>       = [];

	public var onPlayerKilled:Void->Void;

	var _dying:Bool = false;

	public function new() {}

	public function loadFromJson(state:FlxState):Void
	{
		var path = "assets/shared/data/minigame/thevalley/tiles.json";
		if (!openfl.Assets.exists(path)) return;
		var raw = openfl.Assets.getText(path);
		if (raw == null || raw == "") return;
		var parsed:Dynamic = haxe.Json.parse(raw);
		var crumbleData:Array<{ x:Float, y:Float }>;
		var grabbedData:Array<{ x:Float, y:Float }>;
		var bridgeData:Array<{ x:Float, y:Float }>;

		if (Std.isOfType(parsed, Array))
		{
			crumbleData = parsed;
			grabbedData = [];
			bridgeData  = [];
		}
		else
		{
			crumbleData = parsed.crumble != null ? parsed.crumble : [];
			grabbedData = parsed.grabbed != null ? parsed.grabbed : [];
			bridgeData  = parsed.bridge  != null ? parsed.bridge  : [];
			var holdingData:Array<{ x:Float, y:Float }> = parsed.holding != null ? parsed.holding : [];
			for (d in holdingData) _spawnHolding(d.x, d.y, state);
			var spineData:Array<{ x:Float, y:Float }> = parsed.spine != null ? parsed.spine : [];
			for (d in spineData) _spawnSpine(d.x, d.y, state);
			var garyData:Array<{ x:Float, y:Float }>     = parsed.gary     != null ? parsed.gary     : [];
			var amyData:Array<{ x:Float, y:Float }>      = parsed.amy      != null ? parsed.amy      : [];
			var knucklesData:Array<{ x:Float, y:Float }> = parsed.knuckles != null ? parsed.knuckles : [];
			for (d in garyData)     _spawnGary(d.x, d.y, state);
			for (d in amyData)      _spawnAmy(d.x, d.y, state);
			for (d in knucklesData) _spawnKnuckles(d.x, d.y, state);
		}
		for (d in crumbleData) _spawn(d.x, d.y, state);
		for (d in grabbedData) _spawnGrabbed(d.x, d.y, state);
		for (d in bridgeData)  _spawnBridge(d.x, d.y, state);
	}

	public function spawnAt(wx:Float, wy:Float, state:FlxState):CrumblingTile
		return _spawn(wx, wy, state);

	public function spawnGrabbedAt(wx:Float, wy:Float, state:FlxState):GrabbedTile
		return _spawnGrabbed(wx, wy, state);

	public function spawnHoldingAt(wx:Float, wy:Float, state:FlxState):HoldingTile
		return _spawnHolding(wx, wy, state);

	public function spawnBridgeAt(wx:Float, wy:Float, state:FlxState):SonicBridge
		return _spawnBridge(wx, wy, state);

	public function spawnSpineAt(wx:Float, wy:Float, state:FlxState):SpineTile
		return _spawnSpine(wx, wy, state);

	public function insertSpineSprites(state:FlxState, map7Spr:FlxSprite):Void
	{
		var idx = state.members.indexOf(map7Spr);
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
			var i = state.members.indexOf(a);
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

	public function spawnGaryAt(wx:Float, wy:Float, state:flixel.FlxState):GaryNPC
		return _spawnGary(wx, wy, state);

	public function spawnAmyAt(wx:Float, wy:Float, state:FlxState):AmyNPC
		return _spawnAmy(wx, wy, state);

	public function spawnKnucklesAt(wx:Float, wy:Float, state:FlxState):KnucklesNPC
		return _spawnKnuckles(wx, wy, state);

	public function removeAt(wx:Float, wy:Float):Bool
	{
		for (i in 0...tiles.length)
		{
			var t = tiles[i];
			if (wx >= t.x && wx < t.x + CrumblingTile.TILE_W
			&&  wy >= t.y && wy < t.y + CrumblingTile.TILE_H)
			{
				t.visible = false;
				if (t.body != null) t.body.space = null;
				tiles.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	public function saveToJson():Void
	{
		#if sys
		var data = {
			crumble:  [for (t in tiles)         { x: t.x, y: t.y }],
			grabbed:  [for (g in grabbedTiles)   { x: g.x, y: g.y }],
			holding:  [for (h in holdingTiles)   { x: h.x, y: h.y }],
			bridge:   [for (b in bridges)        { x: b.x, y: b.y }],
			spine:    [for (s in spines)         { x: s.x, y: s.y }],
			gary:     [for (g in garys)          { x: g.x, y: g.y }],
			amy:      [for (a in amys)           { x: a.x, y: a.y }],
			knuckles: [for (k in knuckles)       { x: k.x, y: k.y }]
		};
		sys.io.File.saveContent("assets/shared/data/minigame/thevalley/tiles.json", haxe.Json.stringify(data, null, "  "));
		#end
	}

	public function update(elapsed:Float, player:Player):Void
	{
		var footY  = player.y + player.height;
		var px     = player.x;
		var pw     = player.width;
		var tw     = CrumblingTile.TILE_W;

		for (tile in tiles)
		{
			if (tile.tileState == Gone) continue;
			var onTile = footY >= tile.y
			          && footY <= tile.y + tile.height + 4
			          && px + pw > tile.x
			          && px < tile.x + tw;
			tile.notifyStanding(onTile);
			tile.tileUpdate(elapsed);
		}

		for (gt in grabbedTiles)
			gt.tileUpdate(elapsed, player);

		for (ht in holdingTiles)
			ht.tileUpdate(elapsed, player);

		for (br in bridges)
			br.bridgeUpdate(elapsed, player);

		_updateSpines(elapsed, player);
	}

	function _updateSpines(elapsed:Float, player:Player):Void
	{
		if (_dying)
		{

			player.body.velocity.setxy(0, 0);
			player.body.angularVel = 0;
			player.body.gravMass = 0;
			return;
		}

		if (player.cinematic) return;

		for (sp in spines)
		{
			if (sp.checkKill(player))
			{
				_dying = true;
				player.cinematic  = true;
				player.body.velocity.setxy(0, 0);
				player.body.angularVel = 0;
				player.body.gravMass = 0;
				player.lockedAnim = "death1";
				player.animation.play("death1", true);
				FlxG.sound.play(Paths.sound("minigame/thevalley/deathspikes"), 0.7);
				if (onPlayerKilled != null) onPlayerKilled();
				return;
			}
		}

		var warning = false;
		for (sp in spines)
			if (sp.checkFallingWarning(player)) { warning = true; break; }

		if (warning)
		{
			if (player.lockedAnim != "fallingtodeath")
			{

				player.mode = thevalley.player.Player.PlayerMode.Air;
			}
			player.lockedAnim = "fallingtodeath";
		}
		else if (player.lockedAnim == "fallingtodeath")
			player.lockedAnim = null;
	}

	public function clearDying(player:Player):Void
	{
		_dying = false;
		player.cinematic     = false;
		player.lockedAnim    = null;
		player.body.gravMass = 1.0;
	}

	function _spawn(wx:Float, wy:Float, state:FlxState):CrumblingTile
	{
		var tile = new CrumblingTile(wx, wy);
		tiles.push(tile);
		state.add(tile);
		return tile;
	}

	function _spawnGrabbed(wx:Float, wy:Float, state:FlxState):GrabbedTile
	{
		var gt = new GrabbedTile(wx, wy, state);
		grabbedTiles.push(gt);
		return gt;
	}

	function _spawnHolding(wx:Float, wy:Float, state:FlxState):HoldingTile
	{
		var ht = new HoldingTile(wx, wy, state);
		holdingTiles.push(ht);
		return ht;
	}

	function _spawnBridge(wx:Float, wy:Float, state:FlxState):SonicBridge
	{
		var br = new SonicBridge(wx, wy, state);
		bridges.push(br);
		return br;
	}

	function _spawnSpine(wx:Float, wy:Float, state:FlxState):SpineTile
	{
		var sp = new SpineTile(wx, wy);
		spines.push(sp);
		state.add(sp.sprite);
		return sp;
	}

	function _spawnGary(wx:Float, wy:Float, state:FlxState):GaryNPC
	{
		var tv = Std.downcast(state, thevalley.TheValley);
		var g = (tv != null)
			? new GaryNPC(wx, wy, tv.player, tv.cutscene, tv.uiCam, state, tv.bgCam)
			: new GaryNPC(wx, wy, null, null, null, state, null);
		garys.push(g);
		if (tv != null) tv.objectGroup.add(g) else state.add(g);
		return g;
	}

	function _spawnAmy(wx:Float, wy:Float, state:FlxState):AmyNPC
	{
		var a = new AmyNPC(wx, wy);
		amys.push(a);
		var tv = Std.downcast(state, thevalley.TheValley);
		if (tv != null) tv.objectGroup.add(a) else state.add(a);
		return a;
	}

	function _spawnKnuckles(wx:Float, wy:Float, state:FlxState):KnucklesNPC
	{
		var k = new KnucklesNPC(wx, wy);
		knuckles.push(k);
		var tv = Std.downcast(state, thevalley.TheValley);
		if (tv != null) tv.objectGroup.add(k) else state.add(k);
		return k;
	}
}