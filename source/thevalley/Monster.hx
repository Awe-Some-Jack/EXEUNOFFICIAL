package thevalley;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Ray;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import thevalley.dropecho.behavior_tree.BehaviorTree;
import thevalley.dropecho.behavior_tree.node.Node;
import thevalley.dropecho.behavior_tree.node.NODE_STATUS;
import thevalley.astar.SearchResult;
import thevalley.astar.types.Result;
import thevalley.map.TVNapeWorld;
import thevalley.player.Player;
import thevalley.WaypointGraph.WNode;
import thevalley.tiles.Tiles.Totem;

enum MonsterAnim
{
	Idle; Walk; Run; Brake; Charge; Takeoff; AirFalling; Landing; Searching; GivingUp;
}

class Monster
{
	public final sprite:FlxSprite;
	public final body:Body;
	public var isGrounded:Bool = false;
	public var anim(default, null):MonsterAnim = Idle;
	public var isDormant(get, never):Bool;
	
	inline function get_isDormant() return _dormant;

	final _state:TheValley;
	final _player:Player;
	final _blackboard:Blackboard;
	final _tree:BehaviorTree;

	var _dir:Int = 1;
	var _dormant:Bool = false;

	var _brakeTimer:Float = 0;
	var _brakeResumeRun:Bool = false;

	var _chargeTimer:Float = 0;
	var _chargeDuration:Float = 0;
	var _jumpImpulse:Float = 0;
	var _jumpDir:Int = 1;
	var _landingTimer:Float = 0;

	var _wasChasing:Bool = false;
	var _investigatedThisHide:Bool = false;
	var _targetTotem:Totem = null;
	var _searchTimer:Float = 0;

	var _giveUpTimer:Float = 0;
	var _giveUpDir:Int = 1;

	var _stuckWindowTimer:Float = 0;
	var _stuckWindowStartX:Float = 0;
	var _stuckTimer:Float = 0;

	var _pathNodes:Array<WNode> = null;
	var _pathIndex:Int = 0;
	var _repathTimer:Float = 0;
	var _postJumpGrace:Float = 0;

	var _spineRecoverCooldown:Float = 0;
	var _pathTransitions:Array<Int> = null;

	var _directorActive:Bool = false;
	var _directorHuntTimer:Float = 0;
	var _directorHuntX:Float = 0;
	var _directorHuntY:Float = 0;
	var _directorCheckTimer:Float = 0;
	var _directorChance:Float = 0;

	var _totemUseCounts:Array<Int> = null;
	var _relocateCheckTimer:Float = 0;
	var _relocateChance:Float = 0;
	var _frustration:Int = 0;
	
	var _killTimer:Float = 0;

	public function new(x:Float, y:Float, state:TheValley, player:Player)
	{
		_state = state;
		_player = player;
		
		sprite = new FlxSprite(x, y);
		sprite.frames = Paths.getSparrowAtlas("minigame/thevalley/characters/exe/exe");
		
		_addAnim(Idle,       "exe idle",          1, true);
		_addAnim(Walk,       "exe walk",          14, true);
		_addAnim(Run,        "exe run",           18, true);
		_addAnim(Brake,      "exe brake",         29, false);
		_addAnim(Charge,     "exe charge",        16, true);
		_addAnim(Takeoff,    "exe takeoff",       1, true);
		_addAnim(AirFalling, "exe airandfalling", 1, true);
		_addAnim(Landing,    "exe landing",       17, false);
		_addAnim(Searching,  "exe searching",     12, false);
		_addAnim(GivingUp,   "exe walk",          14, true);
		
		sprite.animation.play("Idle");

		sprite.setSize(44.0, 92.0);
		sprite.offset.set((sprite.frameWidth - 44.0) * 0.5, sprite.frameHeight - 92.0);
		sprite.scrollFactor.set(1, 1);
		state.add(sprite);

		final cx = x + 44.0 * 0.5;
		final cy = y + 92.0 * 0.5;
		body = new Body(BodyType.DYNAMIC, Vec2.weak(cx, cy));

		final footRad = 44.0 * 0.5;
		final footCircle = new Circle(footRad, Vec2.weak(0, 92.0 * 0.5 - footRad));
		body.shapes.add(footCircle);

		final torsoVerts = Polygon.box(44.0 - 2.0, 92.0 - footRad);
		final torso = new Polygon(torsoVerts);
		for (v in torso.localVerts) v.y -= footRad * 0.5;
		body.shapes.add(torso);

		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(TVNapeWorld.CB_DYNAMIC);
		body.space = FlxNapeSpace.space;

		_blackboard = new Blackboard();
		_blackboard.set("monster", this);
		_blackboard.set("player", player);
		_blackboard.set("dir", 1);

		_tree = new BehaviorTree(new _BrainNode());
		_tree.init(_blackboard);
	}

	function _addAnim(a:MonsterAnim, prefix:String, fps:Int, loop:Bool):Void
	{
		final idxs:Array<Int> = [];
		final frames = sprite.frames.frames;
		for (fi in 0...frames.length)
			if (frames[fi].name.indexOf(prefix) == 0)
				idxs.push(fi);
		sprite.animation.add(Std.string(a), idxs, fps, loop);
	}

	function _playAnim(a:MonsterAnim):Void
	{
		anim = a;
		final name = Std.string(a);
		if (sprite.animation.curAnim?.name != name)
			sprite.animation.play(name, true);
	}

	public function update(elapsed:Float):Void
	{
		_detectGround();

		if (sprite.y > 6000) relocateNear(_player.x, _player.y);

		if (_killTimer > 0)
		{
			_killTimer -= elapsed;
			body.velocity.x *= 0.8;
			sprite.x = body.position.x - 44.0 * 0.5;
			sprite.y = body.position.y - 92.0 * 0.5;
			return;
		}

		if (_checkSpineRecovery(elapsed)) {}
		else if (_dormant)
			_updateDormant(elapsed);
		else
			switch (anim)
			{
				case Brake:      _updateBrake(elapsed);
				case Charge:     _updateCharge(elapsed);
				case Takeoff:    _updateTakeoff();
				case AirFalling: _updateAirFalling();
				case Landing:    _updateLanding(elapsed);
				case Searching:  _updateSearching(elapsed);
				case GivingUp:   _updateGivingUp(elapsed);
				case Walk, Run, Idle: _updateTracking(elapsed);
			}

		if (body.velocity.y > 900.0) body.velocity.y = 900.0;

		sprite.x = body.position.x - 44.0 * 0.5;
		sprite.y = body.position.y - 92.0 * 0.5;
	}

	function _updateTracking(elapsed:Float):Void
	{
		if (_directorActive)
		{
			_directorHuntTimer -= elapsed;
			if (_directorHuntTimer <= 0)
			{
				_directorActive = false;
				_giveUpTimer = 1.8;
				_giveUpDir = _dir;
				_playAnim(GivingUp);
				return;
			}
		}

		_blackboard.set("elapsed", elapsed);
		_tree.execute();
	}

	public function executeKill():Void 
	{
		_killTimer = 1.2;
		body.velocity.x = 0;
		_playAnim(Charge);
		_state.onPlayerKilled();
	}

	public function checkStuck(elapsed:Float, wantsToMove:Bool, dir:Int):Bool
	{
		if (!wantsToMove || !isGrounded)
		{
			_stuckWindowTimer = 0;
			_stuckWindowStartX = sprite.x;
			_stuckTimer = 0;
			return false;
		}

		_stuckWindowTimer += elapsed;
		if (_stuckWindowTimer >= 0.15)
		{
			final progress = (sprite.x - _stuckWindowStartX) * dir;
			_stuckTimer = (progress < 6.0) ? _stuckTimer + _stuckWindowTimer : 0;
			_stuckWindowTimer = 0;
			_stuckWindowStartX = sprite.x;
		}

		return _stuckTimer >= 0.3;
	}

	public function pathTargetX(elapsed:Float, targetX:Float, targetY:Float, fallbackX:Float):Float
	{
		final graph = _state.waypointGraph;
		if (graph == null || graph.nodes.length == 0) return fallbackX;

		if (_postJumpGrace > 0)
		{
			_postJumpGrace -= elapsed;
			return fallbackX;
		}

		_repathTimer -= elapsed;
		if (_repathTimer <= 0)
		{
			_repathTimer = 0.4;
			final result = graph.findPath(sprite.x, sprite.y + 92.0, targetX, targetY);
			if (result?.result == Result.Solved && result.path.length > 1)
			{
				_pathNodes = [for (id in result.path) graph.nodes[id]];
				_pathTransitions = result.transitions;
				_pathIndex = 1;
			}
			else
			{
				_pathNodes = null;
				_pathTransitions = null;
			}
		}

		if (_pathNodes == null || _pathIndex >= _pathNodes.length) return fallbackX;
		return _pathNodes[_pathIndex].x;
	}

	public function pathTargetY(fallbackY:Float):Float
	{
		if (_pathNodes == null || _pathIndex >= _pathNodes.length) return fallbackY;
		return _pathNodes[_pathIndex].y;
	}

	public function pathTargetTransition(fallback:Int):Int
	{
		if (_pathNodes == null || _pathIndex >= _pathNodes.length) return fallback;
		if (_pathTransitions == null || _pathIndex >= _pathTransitions.length) return fallback;
		return _pathTransitions[_pathIndex];
	}

	function _updateBrake(elapsed:Float):Void
	{
		_brakeTimer -= elapsed;
		body.velocity.x *= Math.pow(0.02, elapsed / Math.max(0.05, 0.16));
		if (_brakeTimer <= 0)
		{
			body.velocity.x = 0;
			_playAnim(_brakeResumeRun ? Run : Walk);
		}
	}

	function _updateCharge(elapsed:Float):Void
	{
		body.velocity.x = 0;
		_chargeTimer -= elapsed;
		if (_chargeTimer <= 0)
		{
			body.velocity.x = _jumpDir * effectiveRunSpeed();
			body.velocity.y = _jumpImpulse;
			_bbSetDir(_jumpDir);
			_playAnim(Takeoff);
		}
	}

	function _updateTakeoff():Void
	{
		if (body.velocity.y >= 0) _playAnim(AirFalling); 
	}

	function _updateAirFalling():Void
	{
		if (isGrounded)
		{
			body.velocity.x = 0;
			_landingTimer = 0.12;
			_playAnim(Landing);
		}
	}

	function _updateLanding(elapsed:Float):Void
	{
		_landingTimer -= elapsed;
		if (_landingTimer <= 0)
		{
			_postJumpGrace = 0.6;
			_playAnim(_distToPlayer() <= 480.0 ? Run : Walk);
		}
	}

	function _updateSearching(elapsed:Float):Void
	{
		body.velocity.x = 0;

		if (!_player.isHidden && !_player.isHiding)
		{
			_targetTotem = null;
			_investigatedThisHide = false;
			_playAnim(Run);
			return;
		}

		if (_isPlayerLoud()) 
		{
			_targetTotem = null;
			executeKill();
			return;
		}

		_searchTimer -= elapsed;
		if (_searchTimer <= 0)
		{
			_giveUpTimer = 1.8;
			_giveUpDir = (_targetTotem != null && _targetTotem.totemX < sprite.x) ? 1 : -1;
			_targetTotem = null;
			_playAnim(GivingUp);
		}
	}

	function _updateGivingUp(elapsed:Float):Void
	{
		body.velocity.x = _giveUpDir * 40.0;
		sprite.flipX = _giveUpDir < 0;

		_giveUpTimer -= elapsed;
		sprite.alpha = Math.max(0, _giveUpTimer / 1.8);

		if (_giveUpTimer <= 0)
		{
			body.velocity.x = 0;
			_dormant = true;
			sprite.visible = false;
			_wasChasing = false;
			_frustration = Std.int(Math.min(_frustration + 1, 6));
		}
	}

	function _updateDormant(elapsed:Float):Void
	{
		body.velocity.x = 0;
		final wakeRange = _isPlayerLoud() ? 680.0 : 480.0;
		if (_distToPlayer() <= wakeRange)
		{
			_wakeUp();
			return;
		}

		_directorCheckTimer += elapsed;
		if (_directorCheckTimer < 3.5) return;
		_directorCheckTimer = 0;

		if (Math.random() >= _directorChance)
		{
			_directorChance = Math.min(0.65, _directorChance + 0.1);
			return;
		}

		_directorChance = 0;

		final fav = _favoriteTotem();
		if (fav != null && Math.random() < 0.5)
		{
			_directorHuntX = fav.totemX;
			_directorHuntY = fav.totemY;
		}
		else
		{
			final angle = Math.random() * Math.PI * 2;
			final radius = Math.random() * 220.0;
			_directorHuntX = _player.x + Math.cos(angle) * radius;
			_directorHuntY = _player.y;
		}

		_directorActive = true;
		_directorHuntTimer = 5.0;
		_wakeUp();
	}

	function _wakeUp():Void
	{
		_dormant = false;
		_investigatedThisHide = false;
		sprite.visible = true;
		sprite.alpha = 1;
		_playAnim(Walk);
	}

	inline function _speedMult():Float return 1.0 + _frustration * 0.05;
	inline function _reactionMult():Float return 1.0 - _frustration * 0.06;

	public inline function effectiveRunSpeed():Float return 230.0 * _speedMult();
	public inline function effectiveWalkSpeed():Float return 72.0 * _speedMult();

	public function recordTotemUse(totem:Totem):Void
	{
		final idx = _state.totems.indexOf(totem);
		if (idx < 0) return;
		if (_totemUseCounts == null || _totemUseCounts.length != _state.totems.length)
			_totemUseCounts = [for (i in 0..._state.totems.length) 0];
		_totemUseCounts[idx]++;
	}

	function _favoriteTotem():Totem
	{
		if (_totemUseCounts == null) return null;
		var bestIdx = -1, bestCount = 1;
		for (i in 0..._totemUseCounts.length)
			if (_totemUseCounts[i] > bestCount) { bestCount = _totemUseCounts[i]; bestIdx = i; }
		return bestIdx >= 0 ? _state.totems[bestIdx] : null;
	}

	public function relocateNear(px:Float, py:Float):Void
	{
		final graph = _state.waypointGraph;
		if (graph == null || graph.nodes.length == 0) return;

		final candidates = [];
		for (n in graph.nodes)
		{
			final dx = n.x - px;
			final dy = n.y - py;
			final d = Math.sqrt(dx * dx + dy * dy);
			if (d >= 250.0 && d <= 550.0) candidates.push(n);
		}
		if (candidates.length == 0) return;

		final pick = candidates[Std.random(candidates.length)];

		body.position.setxy(pick.x, pick.y - 92.0 * 0.5);
		body.velocity.setxy(0, 0);
		body.angularVel = 0;

		_pathNodes = null;
		_pathTransitions = null;
		_repathTimer = 0;
		_postJumpGrace = 0;
		_stuckWindowTimer = 0;
		_stuckWindowStartX = pick.x;
		_stuckTimer = 0;

		_playAnim(Walk);
	}

	function _distToPlayer():Float
	{
		if ((_player.isHidden || _player.isHiding) && !_player.isMakingNoise) return Math.POSITIVE_INFINITY;
		final dx = _player.x - sprite.x;
		final dy = _player.y - sprite.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	inline function _isPlayerLoud():Bool
	{
		return _player.isMakingNoise || Math.abs(_player.body.velocity.x) > _player.cfg.physics.walkMax;
	}

	function _bbSetDir(d:Int):Void
	{
		_dir = d;
		_blackboard.set("dir", d);
		sprite.flipX = d < 0;
	}

	public function beginBrake(newDir:Int, wasRunning:Bool):Void
	{
		_brakeTimer = 0.16 * _reactionMult();
		_brakeResumeRun = wasRunning;
		_bbSetDir(newDir);
		_playAnim(Brake);
	}

	public function beginCharge(dir:Int, heightDiff:Float, jumpDist:Float):Void
	{
		final h = Math.max(heightDiff, 75.0) + 30.0;
		final vyForHeight = Math.sqrt(2 * TVNapeWorld.GRAVITY * h);
		final vyForDist   = jumpDist * TVNapeWorld.GRAVITY / (2 * effectiveRunSpeed());
		final neededSpeed = Math.max(vyForHeight, vyForDist);
		final clearance = _clearanceAbove();
		final maxVyForClearance = Math.sqrt(2 * TVNapeWorld.GRAVITY * Math.max(clearance - 30.0, 40.0));
		final cappedSpeed = Math.min(Math.min(neededSpeed, maxVyForClearance), 1050.0);
		
		_jumpImpulse = -cappedSpeed;
		_jumpDir = dir;
		_chargeDuration = Math.min(1.5, (0.12 + Math.max(0, heightDiff) / 150.0) * _reactionMult());
		_chargeTimer = _chargeDuration;
		_bbSetDir(dir);

		_stuckWindowTimer = 0;
		_stuckWindowStartX = sprite.x;
		_stuckTimer = 0;

		_playAnim(Charge);
	}

	public function beginSearching(totem:Totem):Void
	{
		_targetTotem = totem;
		_searchTimer = 3.5;
		body.velocity.x = 0;
		_playAnim(Searching);
	}

	function _detectGround():Void
	{
		final halfW = 44.0 * 0.5;
		final footY = body.position.y + 92.0 * 0.5;
		var grounded = false;

		final rayDir = Vec2.get(0, 1);
		for (ox in [-halfW * 0.7, halfW * 0.7])
		{
			final orig = Vec2.get(body.position.x + ox, footY - 2);
			final ray  = new Ray(orig, rayDir);
			ray.maxDistance = 10.0;

			final res = body.space.rayCast(ray, false);
			orig.dispose();
			if (res != null) { grounded = true; res.dispose(); }
		}
		rayDir.dispose();

		isGrounded = grounded;
	}

	public function hasWallAhead(dir:Int):Bool
	{
		final startX = body.position.x + dir * (44.0 * 0.5);
		final footY  = body.position.y + 92.0 * 0.5;
		final heights = [footY - 10, footY - 92.0 * 0.35, footY - 92.0 * 0.65, footY - 92.0 + 6];

		for (hy in heights)
		{
			final orig   = Vec2.get(startX, hy);
			final dirVec = Vec2.get(dir, 0);
			final ray    = new Ray(orig, dirVec);
			ray.maxDistance = 26.0;

			final res = body.space.rayCast(ray, false);
			orig.dispose();
			dirVec.dispose();
			if (res != null) { res.dispose(); return true; }
		}
		return false;
	}

	public function hasGroundAhead(dir:Int):Bool
	{
		final lookX = body.position.x + dir * (44.0 * 0.5 + 40.0);
		final orig  = Vec2.get(lookX, body.position.y);
		final down  = Vec2.get(0, 1);
		final ray   = new Ray(orig, down);
		ray.maxDistance = 92.0 * 0.5 + 60.0;

		final res = body.space.rayCast(ray, false);
		orig.dispose();
		down.dispose();
		
		final hit = res != null;
		res?.dispose();
		return hit;
	}

	public function isAbyssAhead(dir:Int):Bool
	{
		final checkX = body.position.x + dir * (44.0 * 0.5 + 40.0);
		return _groundYAt(checkX) == null;
	}

	function _checkSpineRecovery(elapsed:Float):Bool
	{
		if (_spineRecoverCooldown > 0)
		{
			_spineRecoverCooldown -= elapsed;
			return false;
		}

		if (!_isOnSpine()) return false;

		final escapeDir = (_player.x >= sprite.x) ? 1 : -1;
		final clearance = _clearanceAbove();
		final maxVyForClearance = Math.sqrt(2 * TVNapeWorld.GRAVITY * Math.max(clearance - 30.0, 40.0));
		final vy = Math.min(1400.0, maxVyForClearance);

		body.velocity.x = escapeDir * 280.0;
		body.velocity.y = -vy;
		_bbSetDir(escapeDir);
		_spineRecoverCooldown = 1.2;
		_playAnim(Takeoff);
		return true;
	}

	function _clearanceAbove():Float
	{
		final orig = Vec2.get(body.position.x, body.position.y - 92.0 * 0.5);
		final up   = Vec2.get(0, -1);
		final ray  = new Ray(orig, up);
		ray.maxDistance = 900.0;
		
		final res = body.space.rayCast(ray, false);
		orig.dispose();
		up.dispose();
		
		final dist = res != null ? res.distance : 900.0;
		res?.dispose();
		return dist;
	}

	function _isOnSpine():Bool
	{
		final spines = _state.tileMap.spines;
		if (spines == null || spines.length == 0) return false;

		final footY = body.position.y + 92.0 * 0.5;
		final loX   = body.position.x - 44.0 * 0.5;
		final hiX   = body.position.x + 44.0 * 0.5;

		for (sp in spines)
		{
			final spLo = sp.x;
			final spHi = sp.x + sp.sprite.width;
			if (spHi < loX || spLo > hiX) continue;
			if (footY > sp.y + 15.0) return true;
		}
		return false;
	}

	public function hasSpineAhead(dir:Int):Bool
	{
		final spines = _state.tileMap.spines;
		if (spines == null || spines.length == 0) return false;

		final x1  = body.position.x;
		final x2  = body.position.x + dir * (44.0 * 0.5 + 140.0);
		final loX = Math.min(x1, x2);
		final hiX = Math.max(x1, x2);
		final footY = body.position.y + 92.0 * 0.5;

		for (sp in spines)
		{
			final spLo = sp.x;
			final spHi = sp.x + sp.sprite.width;
			if (spHi < loX || spLo > hiX) continue;
			if (sp.y < footY - 40) continue;
			if (sp.y > footY + 400) continue;
			return true;
		}
		return false;
	}

	function _groundYAt(atX:Float):Null<Float>
	{
		final footY = body.position.y + 92.0 * 0.5;
		final probeAbove = 260.0;
		final orig = Vec2.get(atX, footY - probeAbove);
		final down = Vec2.get(0, 1);
		final ray  = new Ray(orig, down);
		ray.maxDistance = probeAbove + 600.0;
		
		final res = body.space.rayCast(ray, false);
		orig.dispose();
		down.dispose();
		
		final result:Null<Float> = res != null ? (footY - probeAbove) + res.distance : null;
		res?.dispose();
		return result;
	}

	function _spineFarEdge(dir:Int):Float
	{
		final spines = _state.tileMap.spines;
		var edge = body.position.x + dir * (44.0 * 0.5);
		for (sp in spines)
		{
			final spLo = sp.x;
			final spHi = sp.x + sp.sprite.width;
			if (dir > 0 && spHi > edge && spLo < edge + 140.0) edge = Math.max(edge, spHi);
			if (dir < 0 && spLo < edge && spHi > edge - 140.0) edge = Math.min(edge, spLo);
		}
		return edge;
	}

	public function planSpineCrossing(dir:Int):Null<{ heightDiff:Float, dist:Float }>
	{
		final footY = body.position.y + 92.0 * 0.5;
		final farEdge = _spineFarEdge(dir);
		final startX  = body.position.x + dir * (44.0 * 0.5);

		final margin = 30.0;
		final landX  = farEdge + dir * margin;
		final dist   = Math.abs(landX - startX);

		if (dist <= 220.0)
		{
			final gy = _groundYAt(landX);
			if (gy != null && gy <= footY + 24.0)
				return { heightDiff: Math.max(0, footY - gy), dist: dist };
		}

		final steps = [60.0, 100.0, 140.0, 180.0];
		for (s in steps)
		{
			final testX = startX + dir * s;
			final gy = _groundYAt(testX);
			if (gy != null && gy < footY - 10 && (footY - gy) <= 220.0)
				return { heightDiff: footY - gy, dist: s };
		}

		return null;
	}

	public function measureObstacleHeight(dir:Int, aheadDist:Float):Float
	{
		final footY = body.position.y + 92.0 * 0.5;
		final aheadX = body.position.x + dir * (44.0 * 0.5 + aheadDist);
		final gy = _groundYAt(aheadX);
		return gy != null ? Math.max(0, footY - gy) : 60.0;
	}

	public function destroy():Void
	{
		if (body != null) body.space = null;
		sprite?.destroy();
	}
}

private class _BrainNode implements Node
{
	var _bb:Blackboard;
	var _track:_TrackNode;

	public function new() {}

	public function init(context:Blackboard):Void
	{
		_bb = context;
		_track = new _TrackNode();
		_track.init(context);
	}

	public function execute():NODE_STATUS
	{
		final m:Monster = _bb.get("monster");
		final p:Player  = _bb.get("player");

		@:privateAccess final wasChasing = m._wasChasing;
		@:privateAccess final investigated = m._investigatedThisHide;

		if ((p.isHidden || p.isHiding) && wasChasing && !investigated)
		{
			final totem = _findBusyTotem(m);
			if (totem != null)
			{
				@:privateAccess m._investigatedThisHide = true;
				@:privateAccess m._targetTotem = totem;
				m.recordTotemUse(totem);
				return NODE_STATUS.RUNNING;
			}
		}

		@:privateAccess final targetTotem = m._targetTotem;
		if (targetTotem != null)
		{
			final elapsed:Float = _bb.get("elapsed");
			return _headToTotem(m, elapsed, targetTotem);
		}

		return _track.execute();
	}

	function _findBusyTotem(m:Monster):Totem
	{
		@:privateAccess final state = m._state;
		for (tm in state.totems) if (tm.isBusy()) return tm;
		return null;
	}

	function _headToTotem(m:Monster, elapsed:Float, totem:Totem):NODE_STATUS
	{
		final realDx = totem.totemX - m.sprite.x;

		if (Math.abs(realDx) <= 20)
		{
			m.beginBrake(realDx >= 0 ? 1 : -1, true);
			m.beginSearching(totem);
			return NODE_STATUS.RUNNING;
		}

		final pathX = m.pathTargetX(elapsed, totem.totemX, totem.totemY, totem.totemX);
		final dir = (pathX - m.sprite.x) >= 0 ? 1 : -1;

		final blockedBySpine = m.hasSpineAhead(dir);
		final stuck = m.checkStuck(elapsed, !blockedBySpine, dir);

		if (blockedBySpine)
		{
			final plan = m.planSpineCrossing(dir);
			if (plan != null)
				m.beginCharge(dir, plan.heightDiff, plan.dist);
			else
				m.body.velocity.x = 0;
			return NODE_STATUS.RUNNING;
		}

		final wallAhead = m.isGrounded && m.hasWallAhead(dir);
		final pathY = m.pathTargetY(totem.totemY);
		final gapAhead  = m.isGrounded && !m.hasGroundAhead(dir) && pathY <= m.sprite.y + 92.0 + 24.0;
		final anticipatedJump = m.isGrounded && !blockedBySpine
			&& m.pathTargetTransition(1) == 3
			&& Math.abs(pathX - m.sprite.x) <= 80.0;
		final needsJump = m.isGrounded && (stuck || wallAhead || gapAhead || anticipatedJump);

		if (needsJump)
		{
			var h:Float; var dist:Float;
			if (anticipatedJump)
			{
				h    = Math.max(0, (m.sprite.y + 92.0) - pathY);
				dist = Math.abs(pathX - m.sprite.x);
			}
			else
			{
				h    = m.measureObstacleHeight(dir, 26.0 + 20);
				dist = 26.0 + 60.0;
			}
			m.beginCharge(dir, h, dist);
			return NODE_STATUS.RUNNING;
		}

		m.body.velocity.x = dir * m.effectiveRunSpeed();
		m.sprite.flipX = dir < 0;
		@:privateAccess m._wasChasing = true;
		return NODE_STATUS.RUNNING;
	}
}

private class _TrackNode implements Node
{
	var _bb:Blackboard;

	public function new() {}

	public function init(context:Blackboard):Void
	{
		_bb = context;
	}

	public function execute():NODE_STATUS
	{
		final m:Monster = _bb.get("monster");
		final p:Player  = _bb.get("player");
		final elapsed:Float = _bb.get("elapsed");

		final realDx = p.x - m.sprite.x;
		final realDy = p.y - m.sprite.y;
		final playerHidden = (p.isHidden || p.isHiding) && !p.isMakingNoise;
		final dist = playerHidden ? Math.POSITIVE_INFINITY : Math.sqrt(realDx * realDx + realDy * realDy);

		if (dist <= 75.0 && !playerHidden)
		{
			m.executeKill();
			return NODE_STATUS.RUNNING;
		}

		@:privateAccess final isPlayerLoud = !playerHidden && m._isPlayerLoud();
		final detectRange = isPlayerLoud ? 680.0 : 480.0;

		@:privateAccess final wasRunning = m.anim == Run || m.anim == Idle;
		final shouldRun = wasRunning ? (dist <= 620.0) : (dist <= detectRange);
		if (shouldRun) @:privateAccess m._wasChasing = true;

		if (!playerHidden && !shouldRun && dist >= 400.0)
		{
			@:privateAccess m._relocateCheckTimer += elapsed;
			@:privateAccess final relocateTimer = m._relocateCheckTimer;
			if (relocateTimer >= 6.0)
			{
				@:privateAccess m._relocateCheckTimer = 0;
				@:privateAccess final relocateChance = m._relocateChance;
				if (Math.random() < relocateChance)
				{
					@:privateAccess m._relocateChance = 0;
					m.relocateNear(p.x, p.y);
					return NODE_STATUS.RUNNING;
				}
				@:privateAccess m._relocateChance = Math.min(0.7, relocateChance + 0.12);
			}
		}
		else
		{
			@:privateAccess m._relocateCheckTimer = 0;
			@:privateAccess m._relocateChance = 0;
		}
		
		@:privateAccess var directorActive = m._directorActive;
		if (directorActive && dist <= 480.0)
		{
			@:privateAccess m._directorActive = false;
			directorActive = false;
		}

		var targetX:Float; var targetY:Float;
		if (directorActive)
		{
			@:privateAccess targetX = m._directorHuntX;
			@:privateAccess targetY = m._directorHuntY;
		}
		else
		{
			final timeToIntercept = dist / Math.max(m.effectiveRunSpeed(), 1.0);
			var predictedLead = p.body.velocity.x * timeToIntercept * 0.85; 
			
			predictedLead = Math.max(-350.0, Math.min(350.0, predictedLead));
			
			targetX = p.x + predictedLead;
			targetY = p.y + p.cfg.hitbox.height;
		}
		
		var pathX = m.pathTargetX(elapsed, targetX, targetY, targetX);
		final pathStale = Math.abs(pathX - m.sprite.x) <= 12.0 && dist > 60.0;
		
		final dir:Int = _bb.get("dir");
		
		final dx = pathX - m.sprite.x;
		
		var wantsToMove = false;
		@:privateAccess final isMoving = m.anim == Walk || m.anim == Run;
		if (Math.abs(dx) > 20.0) wantsToMove = true;
		else if (isMoving && Math.abs(dx) > 8.0) wantsToMove = true;

		var newDir:Int = dir;
		if (wantsToMove) newDir = (dx > 0 ? 1 : -1);

		if (pathStale) 
		{
			pathX = targetX;
			if (wantsToMove && m.hasWallAhead(newDir) && m.isGrounded) 
			{
				m.beginCharge(newDir, 120.0, 150.0);
				return NODE_STATUS.RUNNING;
			}
		}

		final blockedBySpine = m.hasSpineAhead(newDir);
		final wallAhead = m.isGrounded && m.hasWallAhead(newDir);
		final pathY = m.pathTargetY(targetY);
		final gapAhead  = m.isGrounded && !m.hasGroundAhead(newDir) && pathY <= m.sprite.y + 92.0 + 24.0;
		final anticipatedJump = m.isGrounded && !blockedBySpine && !pathStale
			&& m.pathTargetTransition(1) == 3
			&& Math.abs(pathX - m.sprite.x) <= 80.0;
		final stuck = m.checkStuck(elapsed, wantsToMove && !blockedBySpine, newDir);
		final needsJump = m.isGrounded && (stuck || wallAhead || gapAhead || anticipatedJump);

		if (wantsToMove && m.isGrounded && !anticipatedJump && !blockedBySpine)
			if (m.isAbyssAhead(newDir)) wantsToMove = false;

		if (newDir != dir && wantsToMove)
		{
			if (Math.abs(m.body.velocity.x) > 60.0) {
				m.beginBrake(newDir, shouldRun);
				return NODE_STATUS.RUNNING;
			} else {
				@:privateAccess m._bbSetDir(newDir);
			}
		}

		if (blockedBySpine)
		{
			final plan = m.planSpineCrossing(newDir);
			if (plan != null)
				m.beginCharge(newDir, plan.heightDiff, plan.dist);
			else
				m.body.velocity.x = 0;
			return NODE_STATUS.RUNNING;
		}

		if (needsJump)
		{
			var h:Float; var jumpDist:Float;
			if (anticipatedJump)
			{
				h = Math.max(0, (m.sprite.y + 92.0) - pathY);
				jumpDist = Math.abs(pathX - m.sprite.x);
			}
			else
			{
				h = m.measureObstacleHeight(newDir, 26.0 + 20);
				jumpDist = 26.0 + 60.0;
			}
			m.beginCharge(newDir, h, jumpDist);
			return NODE_STATUS.RUNNING;
		}

		if (wantsToMove)
		{
			m.body.velocity.x = newDir * (shouldRun ? m.effectiveRunSpeed() : m.effectiveWalkSpeed());
			_bb.set("dir", newDir);
		}
		else
		{
			m.body.velocity.x = 0;
		}

		m.sprite.flipX = newDir < 0;

		@:privateAccess final anim = !wantsToMove ? MonsterAnim.Idle : (shouldRun ? MonsterAnim.Run : MonsterAnim.Walk);
		@:privateAccess m._playAnim(anim);

		return NODE_STATUS.RUNNING;
	}
}