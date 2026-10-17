package minigames.thevalley.character.monster;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import nape.callbacks.CbType;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.geom.Ray;
import nape.geom.RayResultList;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Space;
import minigames.thevalley.libs.ai.behavior.BT;
import minigames.thevalley.libs.ai.behavior.BehaviorTree;
import minigames.thevalley.libs.ai.behavior.node.NODE_STATUS;
import minigames.thevalley.libs.ai.nav.NavAgent;
import minigames.thevalley.libs.ai.nav.PathFollower;
import minigames.thevalley.libs.ai.nav.PathFollower.NavStatus;
import flixel.FlxState;
import minigames.thevalley.map.WaypointGraph;
import minigames.thevalley.map.WaypointGraph.WNode;
import minigames.thevalley.map.TVNapeWorld;
import minigames.thevalley.character.player.Player;
import minigames.thevalley.tiles.Tiles.Totem;
import flixel.FlxCamera;
import minigames.thevalley.tiles.Tiles.SpineTile;
import flixel.sound.FlxSound;

using minigames.thevalley.libs.ai.behavior.BlackboardTools;

enum MonsterAnim
{
	Idle; Walk; Run; Brake; Charge; Takeoff; AirFalling; Landing; Searching; GivingUp; Faker; Transform;
}

enum MonsterMood
{
	Dormant; Prowling; Investigating; Chasing; Stalking; CheckingTotem; AtTheDark; Leaving; Killing; Faking; Disguised;
}


class Monster implements NavAgent
{
	public static var fakerSpent:Bool = false;

	public static final CB_MONSTER:CbType = new CbType();
	static var _listenerSpace:Space = null;

	public final sprite:FlxSprite;
	public final body:Body;
	public var isGrounded:Bool = false;
	public var anim(default, null):MonsterAnim = Idle;
	public var mood(default, null):MonsterMood = Prowling;
	public var isDormant(get, never):Bool;

	inline function get_isDormant() return _dormant;

	final _world:ExeWorld;
	final _layer:FlxState;
	final _player:Player;
	final _follower:PathFollower;
	final _brain:BehaviorTree;
	final _rays:RayResultList = new RayResultList();

	var _time:Float = 0;
	var _dir:Int = 1;
	var _dormant:Bool = false;
	var _frustration:Int = 0;
	var _baseGravMass:Float = 1;
	var _totemUseCounts:Array<Int> = null;

	var _hasIntent:Bool = false;
	var _intentX:Float = 0;
	var _intentY:Float = 0;
	var _intentTransition:Int = 0;
	var _speed:Float = 115.0;
	var _pose:Null<MonsterAnim> = null;

	var _brakeTimer:Float = 0;
	var _chargeTimer:Float = 0;
	var _jumpImpulse:Float = 0;
	var _jumpDir:Int = 1;
	var _jumpVx:Float = 0;
	var _quickLeap:Bool = false;
	var _spineStuck:Float = 0;
	var _landingTimer:Float = 0;
	var _verticalJumpCooldown:Float = 0;
	var _stuckWindowTimer:Float = 0;
	var _stuckWindowStartX:Float = 0;
	var _stuckTimer:Float = 0;
	var _spineRecoverCooldown:Float = 0;
	var _killTimer:Float = 0;

	var _lookTimer:Float = 0;
	var _canSee:Bool = false;
	var _smells:Bool = false;
	var _heard:Bool = false;
	var _lastSeenTime:Float = -999;
	var _lastKnownX:Float = 0;
	var _lastKnownY:Float = 0;
	var _lastKnownVx:Float = 0;
	var _wasHunting:Bool = false;
	var _wasPlayerHidden:Bool = false;
	var _wasPlayerGrounded:Bool = true;
	var _playerGroundY:Float = Math.NEGATIVE_INFINITY;
	var _playerFallSpeed:Float = 0;

	var _leadX:Float = 0;
	var _leadY:Float = 0;
	var _leadTime:Float = -999;
	var _lookLeadTime:Float = -999;
	var _lookAroundTimer:Float = 0;
	var _suspectTotem:Totem = null;

	var _darkEdge:Bool = false;
	var _edgeX:Float = 0;
	var _edgeY:Float = 0;
	var _edgeDir:Int = 1;
	var _edgeZone:Int = -1;
	var _edgeTimer:Float = 0;
	var _wasPlayerInDark:Bool = false;
	final _darkUses:Map<Int, Int> = [];
	var _ambushTime:Float = 5.0;

	public var onLostYou:(hidden:Bool, closest:Float) -> Void = null;
	var _huntChase:Float = 0;
	var _huntClosest:Float = Math.POSITIVE_INFINITY;
	var _searchTimer:Float = 0;
	var _hasHunch:Bool = false;
	var _hunchX:Float = 0;
	var _hunchY:Float = 0;
	var _prowlTime:Float = 0;
	var _stalkTimer:Float = 0;
	var _stalkTotal:Float = 0;
	var _ignoreUntil:Float = -1;
	var _harmlessUntil:Float = -1;
	var _leaving:Bool = false;
	var _leaveTimer:Float = 0;
	var _leaveDir:Int = 1;
	var _leaveAmbush:Bool = false;

	var _graceTimer:Float = 0;
	var _ambushTimer:Float = 0;
	var _directorTimer:Float = 0;
	var _directorChance:Float = 0;
	var _vanishTimer:Float = 0;

	var _trickTotem:Totem = null;
	var _trickPhase:Int = 0;
	var _trickTimer:Float = 0;
	var _lurking:Bool = false;
	var _fakerPhase:Int = 0;
	var _fakerTimer:Float = 0;
	var _fakerGrew:Bool = false;
	var _leaveSpeed:Float = 40.0;
	var _ambushX:Float = 0;
	var _ambushY:Float = 0;

	var _fallSpeed:Float = 0;
	var _lastRunFrame:Int = -1;
	var _dustTimer:Float = 0;
	final _dust:Array<{ spr:FlxSprite, vx:Float, vy:Float, life:Float, max:Float }> = [];

	public function new(x:Float, y:Float, world:ExeWorld, player:Player)
	{
		_world = world;
		_layer = world.exeLayer();
		_player = player;

		sprite = new FlxSprite(x, y);
		sprite.frames = Paths.getSparrowAtlas("minigame/thevalley/characters/exe/exe");

		final walk = _seq("walk", [0, 2, 4, 6, 8, 10, 12, 14]);
		sprite.animation.add("Idle",       _seq("idle", [0]), 1, true);
		sprite.animation.add("Walk",       walk, Std.int(8.0), true);
		sprite.animation.add("Run",        _seq("run", [0, 1, 2, 3, 4, 5]), Std.int(16.0), true);
		sprite.animation.add("Brake",      _seq("brake", [0, 1, 0, 1, 6, 7]), 22, false);
		sprite.animation.add("Charge",     _seq("charge", [0, 1]), 10, true);
		sprite.animation.add("Takeoff",    _seq("takeoff", [0]), 1, true);
		sprite.animation.add("AirFalling", _seq("airandfalling", [0]), 1, true);
		sprite.animation.add("Landing",    _seq("landing", [0, 1]), 12, false);
		sprite.animation.add("SearchIn",   _seq("searching", [27, 26, 25, 24]), 10, false);
		sprite.animation.add("SearchA",    _seq("searching", [11, 0, 1, 2, 2, 2, 2, 2, 2, 2]), 10, false);
		sprite.animation.add("SearchB",    _seq("searching", [5, 6, 7, 8, 8, 8, 8, 8, 8, 8]), 10, false);
		sprite.animation.add("SearchOut",  _seq("searching", [24, 25, 26, 27]), 12, false);
		sprite.animation.add("GivingUp",   walk, 4, true);
		sprite.animation.add("Faker",      _seq("faker", [0]), 1, true);
		sprite.animation.add("Transform",  _seq("transform", [0, 1, 2, 3, 4, 5, 6]), 7, false);

		sprite.animation.play("Idle");

		sprite.setSize(44.0, 92.0);
		sprite.offset.set((sprite.frameWidth - 44.0) * 0.5, sprite.frameHeight - 92.0);
		sprite.scrollFactor.set(1, 1);
		final gf = _layer.members.indexOf(player);
		if (gf >= 0) _layer.insert(gf + 1, sprite);
		else _layer.add(sprite);

		body = new Body(BodyType.DYNAMIC, Vec2.weak(x + 44.0 * 0.5, y + 92.0 * 0.5));

		final footRad = 44.0 * 0.5;
		body.shapes.add(new Circle(footRad, Vec2.weak(0, 92.0 * 0.5 - footRad)));

		final torso = new Polygon(Polygon.box(44.0 - 2.0, 92.0 - footRad));
		for (v in torso.localVerts) v.y -= footRad * 0.5;
		body.shapes.add(torso);

		body.allowRotation = false;
		body.setShapeMaterials(new Material(0.0, 0.0, 0.0, 1.0, 0.0));
		body.cbTypes.add(TVNapeWorld.CB_DYNAMIC);
		body.cbTypes.add(CB_MONSTER);
		body.space = FlxNapeSpace.space;
		_ensureNoPlayerCollision();
		_baseGravMass = body.gravMass;

		final graph = world.exeGraph();
		graph.configureSearch(null, 4000, true);

		_follower = new PathFollower(graph);
		_follower.waypointRadius = 26;

		_brain = _buildBrain();
		_brain.init(null);
	}

	function _buildBrain():BehaviorTree
	{
		return BT.tree(BT.reactiveSelector([
			BT.reactiveSequence([
				BT.condition(_ -> _dormant),
				BT.action(_ -> _dormantTick()),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> _fakerPhase > 0),
				BT.action(_ -> _fakerTick()),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> _canKill()),
				BT.action(_ -> { executeKill(); return SUCCESS; }),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> _trickTotem != null),
				BT.action(_ -> _playDumb()),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> _isHunting()),
				BT.action(_ -> _aimAtPlayer()),
				BT.selector([
					BT.moveTo(this, _follower),
					BT.action(_ -> _stalk()),
				]),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> _suspectTotem != null),
				BT.sequence([
					BT.action(_ -> _aimAtTotem()),
					BT.selector([
						BT.moveTo(this, _follower),
						BT.action(_ -> { _suspectTotem = null; return FAILURE; }),
					]),
					BT.action(_ -> _searchTotem()),
				]),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> _darkEdge),
				BT.sequence([
					BT.action(_ -> _aimAtEdge()),
					BT.selector([
						BT.moveTo(this, _follower),
						BT.action(_ -> SUCCESS),
					]),
					BT.action(_ -> _searchEdge()),
				]),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> !_leaving && _hasLead()),
				BT.sequence([
					BT.action(_ -> _aimAtLead()),
					BT.selector([
						BT.moveTo(this, _follower),
						BT.action(_ -> SUCCESS),
					]),
					BT.action(_ -> _lookAround()),
				]),
			]),

			BT.reactiveSequence([
				BT.condition(_ -> !_leaving && _prowlTime < 14.0 && !_player.inDark),
				BT.action(_ -> _aimAtHunch()),
				BT.selector([
					BT.moveTo(this, _follower),
					BT.action(_ -> _hunchUnreachable()),
				]),
			]),

			BT.action(_ -> _leaveTick()),
		]));
	}

	function _dormantTick():NODE_STATUS
	{
		mood = Dormant;
		final dt = _dt();

		if (_graceTimer > 0)
		{
			_graceTimer -= dt;
			if (_graceTimer <= 0)
				_directorChance = Math.max(_directorChance, 0.45);
			return RUNNING;
		}

		final hidden = _playerHidden();

		if (_ambushTimer > 0)
		{
			_ambushTimer -= dt;
			if (!hidden && _dist(_ambushX, _ambushY, _playerFeetX(), _playerFeetY()) <= 420.0)
			{
				_comeBack(true);
				return SUCCESS;
			}
			if (_ambushTimer <= 0) _relocate();
			return RUNNING;
		}

		if (_player.cinematic) return RUNNING;

		if (!hidden && _heard)
		{
			_comeBack(true);
			return SUCCESS;
		}

		_directorTimer += dt;
		if (!fakerSpent)
		{
			if (_directorTimer >= 0.5)
			{
				_directorTimer = 0;
				if (!hidden && _startFaker())
				{
					_wake(false);
					return SUCCESS;
				}
			}
			return RUNNING;
		}

		if (!hidden && _directorTimer >= _returnDelay)
		{
			_comeBack(false);
			return SUCCESS;
		}
		return RUNNING;
	}

	var _returnDelay:Float = 12.0;

	function _comeBack(heardHer:Bool):Void
	{
		if (!_offScreen(body.position.x, _feetY()) || _distToPlayer() < 700.0 * 0.8) _relocate();
		_wake(false);
		if (heardHer) _setLead(_playerFeetX(), _playerFeetY());
	}

	inline function _relocate():Void
	{
		_teleportNear(_playerFeetX(), _playerFeetY(), 700.0, 1100.0, true);
	}

	function _aimAtPlayer():NODE_STATUS
	{
		mood = Chasing;
		_speed = 230.0;
		_leaving = false;
		_prowlTime = 0;
		_hasHunch = false;
		if (_follower.status == NavStatus.Moving) _stalkTotal = 0;

		var tx:Float;
		var ty:Float;
		if (_canSee || _smells)
		{
			tx = _playerFeetX();
			ty = _playerGroundY;
			final ahead = Math.abs(tx - body.position.x) / (230.0 * _speedMult());
			tx += _clamp(_player.body.velocity.x * ahead * 0.6, -160, 160);
		}
		else
		{
			final since = _time - _lastSeenTime;
			tx = _lastKnownX + _clamp(_lastKnownVx * since, -220, 220);
			ty = _lastKnownY;
		}

		_setTarget(tx, ty, 14, 0.3);
		return SUCCESS;
	}

	function _stalk():NODE_STATUS
	{
		mood = Stalking;
		final dt = _dt();
		_face(_playerFeetX());
		_stalkTimer += dt;
		_stalkTotal += dt;

		if (_stalkTotal >= 3.0)
		{
			_stalkTotal = 0;
			if (_tryLunge()) return SUCCESS;
			_giveUp();
			return FAILURE;
		}

		if (_stalkTimer >= 1.0)
		{
			_stalkTimer = 0;
			return SUCCESS;
		}
		return RUNNING;
	}

	function _aimAtTotem():NODE_STATUS
	{
		mood = CheckingTotem;
		_speed = 230.0;
		_leaving = false;
		_searchTimer = 0;
		_setTarget(_totemFeetX(_suspectTotem), _totemFeetY(_suspectTotem), 18, 0.8);
		return SUCCESS;
	}

	function _searchTotem():NODE_STATUS
	{
		mood = CheckingTotem;
		if (_suspectTotem == null) return FAILURE;

		_face(_totemFeetX(_suspectTotem));
		_pose = Searching;
		_searchTimer += _dt();

		if (_searchTimer >= 3.5 * _reactionMult())
		{
			recordTotemUse(_suspectTotem);
			_suspectTotem = null;
			_searchTimer = 0;
			_startLeaving(true);
			return SUCCESS;
		}
		return RUNNING;
	}

	function _aimAtEdge():NODE_STATUS
	{
		mood = AtTheDark;
		_speed = 230.0;
		_leaving = false;
		_edgeTimer = 0;
		_setTarget(_edgeX, _edgeY, 36, 0.3);
		return SUCCESS;
	}

	function _searchEdge():NODE_STATUS
	{
		mood = AtTheDark;
		_pose = Searching;
		final total = 3.2 * _reactionMult();
		_edgeTimer += _dt();
		_setDir(_edgeTimer < total * 0.65 ? _edgeDir : -_edgeDir);

		if (_edgeTimer < total) return RUNNING;

		_darkEdge = false;
		final uses = (_darkUses.get(_edgeZone) ?? 0) + 1;
		_darkUses.set(_edgeZone, uses);
		_ambushTime = 5.0 * Math.min(2.0, 1 + 0.5 * (uses - 1));
		_startLeaving(true);
		return SUCCESS;
	}

	function _aimAtLead():NODE_STATUS
	{
		mood = Investigating;
		_speed = 115.0;
		_lookAroundTimer = 0;
		_lookLeadTime = _leadTime;
		_setTarget(_leadX, _leadY, 40, 0.8);
		return SUCCESS;
	}

	function _lookAround():NODE_STATUS
	{
		mood = Investigating;
		if (_lookLeadTime != _leadTime) return FAILURE;

		_pose = Searching;
		final before = _lookAroundTimer;
		_lookAroundTimer += _dt();
		final total = 1.6 * _reactionMult();
		if (before < total * 0.5 && _lookAroundTimer >= total * 0.5) _setDir(-_dir);

		if (_lookAroundTimer >= total)
		{
			_leadTime = -999;
			_maybeSuspectNearbyTotem(_leadX, _leadY);
			return SUCCESS;
		}
		return RUNNING;
	}

	function _hunchUnreachable():NODE_STATUS
	{
		_prowlRetry += _dt();
		if (_prowlRetry < 0.5) return RUNNING;

		_prowlRetry = 0;
		_hasHunch = false;
		if (++_prowlFails >= 3) _prowlTime = 14.0;
		return SUCCESS;
	}

	var _prowlRetry:Float = 0;
	var _prowlFails:Int = 0;

	function _aimAtHunch():NODE_STATUS
	{
		if (_follower.status == NavStatus.Moving) _prowlFails = 0;
		mood = Prowling;
		_speed = 115.0;
		_prowlTime += _dt();

		if (!_hasHunch || _dist(body.position.x, _feetY(), _hunchX, _hunchY) < 50)
		{
			_hasHunch = true;
			final err = 200.0 * (_playerHidden() ? 2.5 : 1.0);
			_hunchX = _playerFeetX() + FlxG.random.float(-err, err);
			_hunchY = _playerFeetY();
		}
		_setTarget(_hunchX, _hunchY, 48, 0.8);
		return SUCCESS;
	}

	function _leaveTick():NODE_STATUS
	{
		if (!_leaving) _startLeaving(false);
		mood = Leaving;
		_pose = GivingUp;

		_leaveTimer += _dt();
		if (_leaveTimer >= 1.8)
		{
			_ambushX = body.position.x;
			_ambushY = _feetY();
			_goDormant(_leaveAmbush, true);
			_withdraw();
			return SUCCESS;
		}
		return RUNNING;
	}

	function _withdraw():Void
	{
		_relocate();
	}

	function _playDumb():NODE_STATUS
	{
		final totem = _trickTotem;
		final inside = totem.isBusy() && (_player.isHidden || _player.isHiding) && !_player.inDecoy;
		if (!inside && _trickPhase < 2)
		{
			_endTrick();
			return FAILURE;
		}

		final dt = _dt();
		final away = _totemFeetX(totem) > body.position.x ? -1 : 1;
		_trickTimer += dt;
		switch (_trickPhase)
		{
			case 0:
				mood = Faking;
				_setDir(away);
				if (_trickTimer >= 0.35)
				{
					_trickPhase = 1;
					_trickTimer = 0;
					_leaving = true;
					_leaveTimer = 0;
					_leaveDir = away;
					_leaveSpeed = 72.0;
				}

			case 1:
				mood = Faking;
				_pose = GivingUp;
				_leaveTimer += dt;
				if (_leaveTimer >= 1.8)
				{
					_trickPhase = 2;
					_trickTimer = 0;
					_leaving = false;
					_lurking = true;
				}

			default:
				mood = Faking;
				body.velocity.x = 0;
				if (_trickTimer >= 0.5) _strike(totem);
		}
		return RUNNING;
	}

	function _strike(totem:Totem):Void
	{
		_endTrick();
		if (!_world.exeCanKill()) return;

		final side = _playerFeetX() < _totemFeetX(totem) ? -1 : 1;
		body.position.setxy(_playerFeetX() + side * (44.0 * 0.5 + 6), _playerFeetY() - 92.0 * 0.5);
		body.velocity.setxy(0, 0);
		_setDir(-side);
		_syncSprite();
		sprite.alpha = 1;
		sprite.visible = true;
		_rumble(0.006, 0.25, true);
		_thump(true);
		executeKill();
	}

	function _endTrick():Void
	{
		_leaveSpeed = 40.0;
		_trickTotem = null;
		_trickPhase = 0;
		_trickTimer = 0;
		_lurking = false;
		_leaving = false;
	}

	function _sense(elapsed:Float):Void
	{
		final p = _player;
		final hidden = _playerHidden();
		final pcx = p.x + p.width * 0.5;
		final pcy = p.y + p.height * 0.5;
		if (p.isGrounded || p.y + p.height > _playerGroundY) _playerGroundY = p.y + p.height;
		final ex = body.position.x;
		final ey = body.position.y - 30;
		final d = _dist(ex, ey, pcx, pcy);

		_lookTimer -= elapsed;
		if (_lookTimer <= 0)
		{
			_lookTimer = 0.1;
			final range = _time - _lastSeenTime <= 3.0 ? 640.0 : 480.0;
			_canSee = !hidden && !_dormant && d <= range && _lineOfSight(ex, ey, pcx, pcy, d);
		}
		if (hidden || _dormant) _canSee = false;
		_smells = !hidden && !_dormant && d <= 150.0;

		if (_smells || (_canSee && _time >= _ignoreUntil))
		{
			_lastSeenTime = _time;
			_lastKnownX = pcx;
			_lastKnownY = _playerGroundY;
			_lastKnownVx = p.body.velocity.x;
		}

		var loudness = 0.0;
		if (p.isMakingNoise)
			loudness = 560.0;
		else if (p.isGrounded && Math.abs(p.body.velocity.x) > p.cfg.physics.walkMax)
			loudness = 340.0;
		if (p.isGrounded && !_wasPlayerGrounded && _playerFallSpeed > 760.0)
			loudness = Math.max(loudness, 260.0);
		_playerFallSpeed = p.isGrounded ? 0 : Math.max(_playerFallSpeed, p.body.velocity.y);
		_wasPlayerGrounded = p.isGrounded;
		if (p.inDark) loudness = 0;

		_heard = loudness > 0 && d <= loudness;
		if (_heard && !_dormant && !(_canSee || _smells))
		{
			final err = (d / loudness) * 70;
			_setLead(pcx + FlxG.random.float(-err, err), p.y + p.height);
		}

		if (p.inDark && !_wasPlayerInDark && !_dormant && _killTimer <= 0 && _time - _lastSeenTime <= 1.0)
		{
			_darkEdge = true;
			_edgeX = _lastKnownX;
			_edgeY = _lastKnownY;
			_edgeDir = _lastKnownVx > 5 ? 1 : _lastKnownVx < -5 ? -1 : (_lastKnownX >= body.position.x ? 1 : -1);
			_edgeZone = p.darkZone;
			_edgeTimer = 0;
		}
		if (_canSee) _darkEdge = false;
		_wasPlayerInDark = p.inDark;

		if (p.isHiding && !p.inDecoy && !_wasPlayerHidden && !_dormant)
		{
			final totem = _busyTotem();
			if (totem != null)
			{
				final sawIt = _time - _lastSeenTime <= 0.6;
				if (sawIt && _fakerPhase == 0 && !_offScreen(body.position.x, _feetY()))
				{
					_trickTotem = totem;
					_trickPhase = 0;
					_trickTimer = 0;
					_suspectTotem = null;
				}
				else if (sawIt || d <= 560.0 * 0.45)
					_suspectTotem = totem;
				else if (d <= 560.0)
					_setLead(_totemFeetX(totem), _totemFeetY(totem));
			}
		}
		if (!hidden && _suspectTotem != null && !_suspectTotem.isBusy()) _suspectTotem = null;
		_wasPlayerHidden = hidden;

		final hunting = _isHunting();
		if (_wasHunting && !hunting && !_dormant && _suspectTotem == null && _trickTotem == null)
			_setLead(_lastKnownX + _clamp(_lastKnownVx * 0.8, -220, 220), _lastKnownY);
		_wasHunting = hunting;
	}

	inline function _isHunting():Bool
		return !_playerHidden() && _time - _lastSeenTime <= 3.0;

	inline function _hasLead():Bool
		return _time - _leadTime <= 8.0;

	function _setLead(x:Float, y:Float):Void
	{
		_leadX = x;
		_leadY = y;
		_leadTime = _time;
		if (mood == Investigating) _setTarget(x, y, 40, 0.8);
	}

	function _lineOfSight(x0:Float, y0:Float, x1:Float, y1:Float, d:Float):Bool
	{
		if (d < 1) return true;
		return _probe(x0, y0, (x1 - x0) / d, (y1 - y0) / d, d, true) < 0;
	}

	function _canKill():Bool
	{
		if (_dormant || _killTimer > 0 || _fakerPhase > 0 || _playerHidden()) return false;
		if (_time < _harmlessUntil) return false;
		if (_player.lockedAnim == "death1") return false;
		if (!_world.exeCanKill()) return false;

		final r = 10.0;
		final x0 = body.position.x - 44.0 * 0.5 - r;
		final x1 = body.position.x + 44.0 * 0.5 + r;
		final y0 = body.position.y - 92.0 * 0.5 - r;
		final y1 = body.position.y + 92.0 * 0.5 + r;
		final p = _player;
		return p.x < x1 && p.x + p.width > x0 && p.y < y1 && p.y + p.height > y0;
	}

	public function executeKill():Void
	{
		mood = Killing;
		_killTimer = 1.2;
		body.velocity.x = 0;
		_playAnim(Charge);
		_brain.halt();
		_frustration = Std.int(Math.max(0, _frustration - 2));
		forgetHunt();
		_world.exeCaught();
	}

	public function forgetHunt():Void
	{
		_huntChase = 0;
		_huntClosest = Math.POSITIVE_INFINITY;
	}

	function _startLeaving(ambush:Bool):Void
	{
		_leaveSpeed = 40.0;
		_leaving = true;
		_leaveTimer = 0;
		_leaveAmbush = ambush;
		_leaveDir = _player.x < body.position.x ? 1 : -1;
	}

	function _goDormant(ambush:Bool, gaveUp:Bool):Void
	{
		if (gaveUp && _huntChase >= 1.0 && onLostYou != null)
			onLostYou(_playerHidden(), _huntClosest);
		forgetHunt();

		_dormant = true;
		_trickTotem = null;
		_lurking = false;
		_fakerPhase = 0;
		body.velocity.setxy(0, 0);
		body.gravMass = 0;
		mood = Dormant;
		_leaving = false;
		body.velocity.x = 0;
		_ambushTimer = ambush ? _ambushTime : 0;
		_ambushTime = 5.0;
		_returnDelay = FlxG.random.float(9.0, 16.0);
		_darkEdge = false;
		_directorTimer = 0;
		_prowlTime = 0;
		_hasHunch = false;
		_leadTime = -999;
		_suspectTotem = null;
		_lastSeenTime = -999;
		_wasHunting = false;
		_follower.clear();
		if (gaveUp) _frustration = Std.int(Math.min(_frustration + 1, 6));
	}

	function _wake(knowsWhere:Bool):Void
	{
		_dormant = false;
		_lunges = 0;
		_harmlessUntil = _time + 0.5;
		_directorChance = 0;
		body.gravMass = _baseGravMass;
		_ambushTimer = 0;
		_prowlTime = 0;
		_hasHunch = false;
		_stalkTotal = 0;
		sprite.visible = true;
		_follower.clear();
		if (knowsWhere)
		{
			_lastSeenTime = _time;
			_lastKnownX = _playerFeetX();
			_lastKnownY = _playerFeetY();
			_lastKnownVx = _player.body.velocity.x;
		}
		_playAnim(_fakerPhase > 0 ? Faker : Idle);
	}

	function _vanish():Void
	{
		_goDormant(false, false);
		_graceTimer = 6.0;
		_vanishTimer = 0.35;
	}

	public var disguised(get, never):Bool;
	inline function get_disguised() return _fakerPhase > 0;

	public var revealing(get, never):Bool;
	inline function get_revealing() return _fakerPhase >= 2;

	public var grew(get, never):Bool;
	inline function get_grew() return _fakerGrew && _fakerPhase == 3;

	public var transforming(get, never):Bool;
	inline function get_transforming() return _fakerPhase == 3;

	public function lurkAhead():Bool
	{
		_graceTimer = 0;
		_ambushTimer = 0;
		_vanishTimer = 0;
		_killTimer = 0;
		if (!_dormant) _goDormant(false, false);
		if (!_startFaker()) return false;
		_wake(false);
		return true;
	}

	function _startFaker():Bool
	{
		if (!_placeFaker()) return false;
		_fakerPhase = 1;
		_fakerTimer = 0;
		_fakerGrew = false;
		return true;
	}

	function _placeFaker():Bool
	{
		final spot = _fakerSpot();
		if (spot == null) return false;
		_teleportTo(spot);
		_setDir(_playerFeetX() > spot.x ? 1 : -1);
		return true;
	}

	inline function _aheadDir():Int
	{
		final vx = _player.body.velocity.x;
		return Math.abs(vx) > 20 ? (vx > 0 ? 1 : -1) : (_player.flipX ? -1 : 1);
	}

	function _inView(margin:Float):Bool
	{
		final cam = _world.exeCamera();
		return sprite.x + sprite.width > cam.viewLeft - margin && sprite.x < cam.viewRight + margin
			&& sprite.y + sprite.height > cam.viewTop - margin && sprite.y < cam.viewBottom + margin;
	}

	function _fakerLeftBehind():Bool
	{
		if (_inView(80)) return false;
		final along = (body.position.x - _playerFeetX()) * _aheadDir();
		return along < -200.0 || _distToPlayer() > 1800.0;
	}

	function _fakerSpot():Null<WNode>
	{
		final graph = _world.exeGraph();
		if (graph == null || graph.nodes.length == 0) return null;
		final px = _playerFeetX();
		final py = _playerFeetY();
		final ahead = _aheadDir();

		var best:WNode = null;
		var bestScore = Math.POSITIVE_INFINITY;
		for (i in _nodesThatReach(graph.nearestNode(px, py)).keys())
		{
			final n = graph.nodes[i];
			final along = (n.x - px) * ahead;
			if (along < 1000.0 || along > 1500.0 || Math.abs(n.y - py) > 160) continue;
			if (graph.walkDegree(i) < 1) continue;
			final score = along + (_offScreen(n.x, n.y) ? 0 : 1000) + Math.abs(n.y - py) * 0.5;
			if (score < bestScore)
			{
				bestScore = score;
				best = n;
			}
		}
		return best;
	}

	function _fakerTick():NODE_STATUS
	{
		mood = Disguised;
		body.velocity.x = 0;
		_face(_playerFeetX());
		_fakerTimer += _dt();

		if (_fakerPhase == 1)
		{
			_pose = Faker;
			final ready = !_playerHidden() && _player.isGrounded && !_player.cinematic;
			final close = _distToPlayer() <= 470.0 && Math.abs(_feetY() - _playerFeetY()) <= 160.0;
			if (ready && (close || _inView(0)))
			{
				fakerSpent = true;
				_fakerPhase = 2;
				_fakerTimer = 0;
			}
			else if (_fakerTimer >= 1.0)
			{
				_fakerTimer = 0;
				if (_fakerLeftBehind()) _placeFaker();
			}
			return RUNNING;
		}

		if (_fakerPhase == 2)
		{
			_pose = Faker;
			if (_fakerTimer >= 1.9)
			{
				_fakerPhase = 3;
				_fakerTimer = 0;
			}
			return RUNNING;
		}

		_pose = Transform;
		final cur = sprite.animation.curAnim;
		if (cur == null || cur.name != "Transform") return RUNNING;
		if (!_fakerGrew && cur.curFrame >= 3)
		{
			_fakerGrew = true;
			_rumble(0.006 * 0.9, 0.3, true);
			_thump(true, 1.2);
		}
		if (!cur.finished) return RUNNING;

		_fakerPhase = 0;
		_pose = null;
		_harmlessUntil = _time + 0.8;
		_lastSeenTime = _time;
		_lastKnownX = _playerFeetX();
		_lastKnownY = _playerFeetY();
		_lastKnownVx = _player.body.velocity.x;
		_playAnim(Idle);
		return SUCCESS;
	}

	function _teleportNear(px:Float, py:Float, minD:Float, maxD:Float, mustBeHidden:Bool):Bool
	{
		final graph = _world.exeGraph();
		if (graph == null || graph.nodes.length == 0) return false;

		final canReach = _nodesThatReach(graph.nearestNode(_playerFeetX(), _playerFeetY()));

		var pick:WNode = null;
		var onScreen:Array<WNode> = [];
		var unreachable:Array<WNode> = [];
		for (ring in [[minD, maxD], [minD, maxD * 1.7], [minD * 0.6, maxD * 2.5]])
		{
			final good = [];
			for (i in 0...graph.nodes.length)
			{
				final n = graph.nodes[i];
				final d = _dist(n.x, n.y, px, py);
				if (d < ring[0] || d > ring[1]) continue;
				final hidden = _offScreen(n.x, n.y);
				if (canReach.exists(i) && graph.walkDegree(i) >= 2) (hidden ? good : onScreen).push(n);
				else if (hidden) unreachable.push(n);
			}
			if (good.length > 0)
			{
				pick = good[FlxG.random.int(0, good.length - 1)];
				break;
			}
		}
		if (pick == null && !mustBeHidden)
		{
			if (onScreen.length > 0) pick = onScreen[FlxG.random.int(0, onScreen.length - 1)];
			else if (unreachable.length > 0) pick = unreachable[FlxG.random.int(0, unreachable.length - 1)];
		}
		if (pick == null) return false;

		_teleportTo(pick);
		return true;
	}

	function _teleportTo(n:WNode):Void
	{
		body.position.setxy(n.x, n.y - 92.0 * 0.5);
		body.velocity.setxy(0, 0);
		body.angularVel = 0;
		_stuckWindowTimer = 0;
		_stuckWindowStartX = n.x;
		_stuckTimer = 0;
		_progressTimer = 0;
		_progressBest = Math.POSITIVE_INFINITY;
		_spineHits = 0;
		_follower.clear();
		if (anim == Charge || anim == Takeoff || anim == AirFalling || anim == Landing || anim == Brake) _playAnim(Idle);
		_syncSprite();
	}

	var _progressTimer:Float = 0;
	var _progressBest:Float = Math.POSITIVE_INFINITY;
	var _spineHits:Int = 0;
	var _spineHitTime:Float = -999;

	function _checkProgress(elapsed:Float):Void
	{
		if (_dormant || _leaving || !_follower.hasTarget || mood == Stalking)
		{
			_progressTimer = 0;
			_closerTimer = 0;
			_progressBest = Math.POSITIVE_INFINITY;
			_progressX = body.position.x;
			_progressY = _feetY();
			return;
		}

		final d = _dist(body.position.x, _feetY(), _follower.targetX, _follower.targetY);
		final travelled = _dist(body.position.x, _feetY(), _progressX, _progressY);
		if (d < _progressBest - 24 || travelled > 56)
		{
			if (d < _progressBest - 24) _closerTimer = 0;
			_progressBest = Math.min(_progressBest, d);
			_progressX = body.position.x;
			_progressY = _feetY();
			_progressTimer = 0;
			_lunges = 0;
		}
		else _progressTimer += elapsed;

		_closerTimer += elapsed;
		final patience = _offScreen(body.position.x, _feetY()) ? 2.5 : 2.5;
		if (_progressTimer >= patience || _closerTimer >= 9.0)
		{
			_closerTimer = 0;
			_unstick();
		}
	}

	var _progressX:Float = 0;
	var _progressY:Float = 0;
	var _closerTimer:Float = 0;

	function _unstick():Void
	{
		_progressTimer = 0;
		_progressBest = Math.POSITIVE_INFINITY;
		if (_tryLunge()) return;
		_giveUp();
	}

	var _lunges:Int = 0;

	function _dropThrough():Void
	{
		if (!isGrounded || !(_canSee || _smells || _isHunting())) return;
		if (_playerFeetY() - _feetY() < 40 || Math.abs(_playerFeetX() - body.position.x) > 160) return;
		final x = body.position.x;
		final y = _feetY() - 2;
		if (_probe(x, y, 0, 1, 12, false) < 0 || _probe(x, y, 0, 1, 12, true) >= 0) return;
		body.userData.dropUntil = haxe.Timer.stamp() + 0.35;
		body.velocity.y = 120;
	}

	function _tryLunge():Bool
	{
		if (!(_canSee || _smells) || _distToPlayer() > 520.0 || _lunges >= 3) return false;
		_lunges++;
		if (!isGrounded) return true;
		final dx = _playerFeetX() - body.position.x;
		final dir = dx >= 0 ? 1 : -1;
		_setDir(dir);
		beginCharge(dir, Math.max(0, _feetY() - _playerFeetY()), Math.max(60, Math.abs(dx)), true);
		return true;
	}

	function _directLine():Bool
	{
		if (!(_canSee || _smells) || !isGrounded || _killTimer > 0) return false;
		final px = _playerFeetX();
		final dx = px - body.position.x;
		final startY = _feetY();
		if (Math.abs(dx) > 440.0 || Math.abs(_playerFeetY() - startY) > 40.0) return false;
		if (hasSpineAhead(dx >= 0 ? 1 : -1)) return false;
		final dir = dx >= 0 ? 1.0 : -1.0;
		final steps = Std.int(Math.abs(dx) / 20.0);
		var y = startY;
		for (i in 1...steps + 1)
		{
			final x = body.position.x + dir * i * 20.0;
			final d = _probe(x, y - 40, 0, 1, 90, false);
			if (d < 0) return false;
			final g = y - 40 + d;
			if (Math.abs(g - y) > 16.0) return false;
			y = g;
		}
		return true;
	}

	function _giveUp():Void
	{
		_ignoreUntil = _time + 5;
		_lastSeenTime = -999;
		_leadTime = -999;
		_suspectTotem = null;
		_darkEdge = false;
		_prowlTime = 14.0;
	}

	static var _reverseEdges:Array<Array<Int>> = null;
	static var _reverseFor:WaypointGraph = null;

	function _nodesThatReach(target:Int):Map<Int, Bool>
	{
		final graph = _world.exeGraph();
		if (_reverseFor != graph)
		{
			_reverseFor = graph;
			_reverseEdges = [for (_ in 0...graph.nodes.length) []];
			for (i in 0...graph.nodes.length)
				graph.getNextNodes(i, (to, _, ?_) -> _reverseEdges[to].push(i));
		}

		final seen = new Map<Int, Bool>();
		if (target < 0) return seen;
		seen[target] = true;
		final queue = [target];
		var qi = 0;
		while (qi < queue.length)
			for (from in _reverseEdges[queue[qi++]])
				if (!seen.exists(from)) { seen[from] = true; queue.push(from); }
		return seen;
	}

	function _offScreen(x:Float, feetY:Float):Bool
	{
		final cam = _world.exeCamera();
		final m = 40;
		return x + 44.0 * 0.5 < cam.viewLeft - m || x - 44.0 * 0.5 > cam.viewRight + m
			|| feetY < cam.viewTop - m || feetY - 92.0 > cam.viewBottom + m;
	}

	public function recordTotemUse(totem:Totem):Void
	{
		final idx = _world.exeTotems().indexOf(totem);
		if (idx < 0) return;
		if (_totemUseCounts == null || _totemUseCounts.length != _world.exeTotems().length)
			_totemUseCounts = [for (i in 0..._world.exeTotems().length) 0];
		_totemUseCounts[idx]++;
	}

	function _busyTotem():Totem
	{
		for (tm in _world.exeTotems()) if (tm.isBusy()) return tm;
		return null;
	}

	function _maybeSuspectNearbyTotem(x:Float, y:Float):Void
	{
		final r = 260.0;
		final busy = _busyTotem();
		if (busy != null && _dist(_totemFeetX(busy), _totemFeetY(busy), x, y) <= r && FlxG.random.float() < 0.6)
		{
			_suspectTotem = busy;
			return;
		}

		if (FlxG.random.float() >= 0.25) return;
		final near = [for (tm in _world.exeTotems()) if (_dist(_totemFeetX(tm), _totemFeetY(tm), x, y) <= r * 0.8) tm];
		if (near.length > 0) _suspectTotem = near[FlxG.random.int(0, near.length - 1)];
	}

	inline function _totemFeetX(t:Totem):Float return t.totemX + @:privateAccess t._sprite.width * 0.5;

	inline function _totemFeetY(t:Totem):Float return t.totemY + @:privateAccess t._sprite.height;

	public function navX():Float return body.position.x;

	public function navY():Float return _feetY();

	public function steer(x:Float, y:Float, transition:Int):Void
	{
		_hasIntent = true;
		_intentX = x;
		_intentY = y;
		_intentTransition = transition;
	}

	public function stopMoving():Void
	{
		_hasIntent = false;
	}

	function _setTarget(x:Float, y:Float, arrive:Float, repath:Float):Void
	{
		final bb = _brain.blackboard;
		bb.set("targetX", x);
		bb.set("targetY", y);
		_follower.arriveRadius = arrive;
		_follower.repathInterval = repath;
	}

	public var paused:Bool = false;

	public function update(elapsed:Float):Void
	{
		if (paused)
		{
			body.velocity.x = 0;
			if (!_dormant && _killTimer <= 0) _playAnim(Idle);
			_finishFrame(elapsed);
			return;
		}

		_time += elapsed;
		_detectGround();

		if (_feetY() > _world.exeGraph().mapBottom + 60 || sprite.y > 6000)
		{
			_goDormant(false, false);
			_relocate();
		}

		if (_killTimer > 0)
		{
			_killTimer -= elapsed;
			body.velocity.x *= 0.8;
			if (_killTimer <= 0) _vanish();
			_finishFrame(elapsed);
			return;
		}

		_sense(elapsed);

		if (_verticalJumpCooldown > 0) _verticalJumpCooldown -= elapsed;

		if (!_checkSpineRecovery(elapsed))
		{
			_hasIntent = false;
			_pose = null;
			_brain.tick(elapsed);
			if ((mood == Chasing || mood == Stalking) && _directLine()) steer(_playerFeetX(), _playerFeetY(), 1);
			if (mood == Chasing || mood == Stalking || mood == Investigating) _dropThrough();
			if (mood == Chasing)
			{
				_huntChase += elapsed;
				_huntClosest = Math.min(_huntClosest, _distToPlayer());
			}
			if (_killTimer <= 0)
			{
				_updateMotion(elapsed);
				_checkProgress(elapsed);
			}
		}

		_finishFrame(elapsed);
	}

	function _finishFrame(elapsed:Float):Void
	{
		if (body.velocity.y > 900.0) body.velocity.y = 900.0;
		if (anim == Takeoff) _fallSpeed = Math.max(_fallSpeed, body.velocity.y);
		_syncSprite();
		_footsteps();
		_updateDust(elapsed);
		_updateAlpha(elapsed);

	}

	inline function _syncSprite():Void
	{
		sprite.x = body.position.x - 44.0 * 0.5;
		sprite.y = body.position.y - 92.0 * 0.5;
		sprite.flipX = _flipFor(_dir);
	}

	inline function _flipFor(d:Int):Bool return anim == Brake ? d > 0 : d < 0;

	function _updateAlpha(elapsed:Float):Void
	{
		if (_vanishTimer > 0)
		{
			_vanishTimer -= elapsed;
			sprite.alpha = Math.max(0, _vanishTimer / 0.35);
			if (_vanishTimer <= 0) _relocate();
		}
		else if (_fakerPhase > 0)
			sprite.alpha = 1;
		else if (_dormant || _lurking)
			sprite.alpha = 0;
		else if (_leaving)
			sprite.alpha = Math.max(0, 1 - _leaveTimer / 1.8);
		else
			sprite.alpha = Math.min(1, sprite.alpha + elapsed * 2.5);

		sprite.visible = sprite.alpha > 0.01;
	}

	inline function _dt():Float return _brain.blackboard.getFloat("elapsed");

	function _updateMotion(elapsed:Float):Void
	{
		if (_dormant)
		{
			body.velocity.x = 0;
			return;
		}

		switch (anim)
		{
			case Brake:      _updateBrake(elapsed); return;
			case Charge:     _updateCharge(elapsed); return;
			case Takeoff:    _updateTakeoff(); return;
			case AirFalling: _updateAirFalling(); return;
			case Landing:    _updateLanding(elapsed); return;
			default:
		}

		if (_pose == GivingUp)
		{
			final blocked = isGrounded && (isAbyssAhead(_leaveDir) || hasWallAhead(_leaveDir));
			body.velocity.x = blocked ? 0 : _leaveDir * _leaveSpeed;
			_setDir(_leaveDir);
			if (blocked) _playAnim(Idle);
			else
			{
				_playAnim(GivingUp);
				_stride(8.0, 72.0, _leaveSpeed);
			}
			return;
		}

		if (!_hasIntent)
		{
			body.velocity.x = 0;
			_playPose();
			return;
		}

		_drive(elapsed);
	}

	function _playPose():Void
	{
		_playAnim(_pose != null ? _pose : Idle);
	}

	function _drive(elapsed:Float):Void
	{
		final cx = body.position.x;
		final feetY = _feetY();
		final dx = _intentX - cx;
		final moving = anim == Walk || anim == Run;
		var wantsToMove = Math.abs(dx) > 14 || (moving && Math.abs(dx) > 6);
		var newDir = wantsToMove ? (dx > 0 ? 1 : -1) : _dir;
		final above = feetY - _intentY;

		if (isGrounded && above > 40 && Math.abs(dx) <= 70 && _verticalJumpCooldown <= 0)
		{
			_verticalJumpCooldown = 1.0;
			beginCharge(Math.abs(dx) > 6 ? newDir : _dir, above, Math.max(Math.abs(dx), 30));
			return;
		}

		final anticipatedJump = isGrounded && wantsToMove && _intentTransition == 3 && above > 0 && Math.abs(dx) <= 110;
		final blockedBySpine = wantsToMove && hasSpineAhead(newDir);
		final wallAhead = isGrounded && wantsToMove && hasWallAhead(newDir);
		final gapAhead = isGrounded && wantsToMove && !hasGroundAhead(newDir) && _intentY <= feetY + 24;
		final stuck = checkStuck(elapsed, wantsToMove && !blockedBySpine, newDir);

		final abyss = wantsToMove && isGrounded && !anticipatedJump && !blockedBySpine && isAbyssAhead(newDir);
		if (abyss) wantsToMove = false;

		if (newDir != _dir && wantsToMove)
		{
			if (Math.abs(body.velocity.x) > 60)
			{
				beginBrake(newDir);
				return;
			}
			_setDir(newDir);
		}

		if (blockedBySpine)
		{
			final plan = planSpineCrossing(newDir);
			if (plan != null)
			{
				_spineStuck = 0;
				beginCharge(newDir, plan.heightDiff, plan.dist, Math.abs(body.velocity.x) > 115.0);
			}
			else
			{
				body.velocity.x = 0;
				_playAnim(Idle);
				_spineStuck += elapsed;
				if (_spineStuck >= 0.6)
				{
					_spineStuck = 0;
					_unstick();
				}
			}
			return;
		}

		if (isGrounded && wantsToMove && (stuck || wallAhead || gapAhead || anticipatedJump))
		{
			final quick = Math.abs(body.velocity.x) > 115.0;
			if (anticipatedJump)
				beginCharge(newDir, Math.max(0, above), Math.abs(dx), quick);
			else
				beginCharge(newDir, measureObstacleHeight(newDir, 46), 86, quick);
			return;
		}

		if (wantsToMove)
		{
			final speed = _speed * _speedMult();
			body.velocity.x = _dir * speed;
			if (_speed >= 230.0)
			{
				_playAnim(Run);
				_stride(16.0, 230.0, speed);
			}
			else
			{
				_playAnim(Walk);
				_stride(8.0, 72.0, speed);
			}
		}
		else
		{
			body.velocity.x = 0;
			_playPose();
		}
	}

	inline function _speedMult():Float return 1.0 + _frustration * 0.05;

	inline function _reactionMult():Float return 1.0 - _frustration * 0.06;

	public inline function effectiveRunSpeed():Float return 230.0 * _speedMult();

	public inline function effectiveWalkSpeed():Float return 72.0 * _speedMult();

	function _setDir(d:Int):Void
	{
		_dir = d;
		sprite.flipX = _flipFor(d);
	}

	inline function _face(x:Float):Void
	{
		if (Math.abs(x - body.position.x) > 4) _setDir(x > body.position.x ? 1 : -1);
	}

	inline function _stride(fps:Float, baseSpeed:Float, speed:Float):Void
	{
		final cur = sprite.animation.curAnim;
		if (cur != null) cur.frameRate = Math.max(2, fps * speed / baseSpeed);
	}

	public function beginBrake(newDir:Int):Void
	{
		_brakeTimer = 0.27 * _reactionMult();
		_dustTimer = 0;
		_puff(-newDir, 4, 90);
		_rumble(0.0012 * 1.6, 0.12, false);
		_thump(false, 1.3);
		_setDir(newDir);
		_playAnim(Brake);
	}

	public function beginCharge(dir:Int, heightDiff:Float, jumpDist:Float, quick:Bool = false):Void
	{
		final g = TVNapeWorld.GRAVITY;
		final maxVy = Math.min(1050.0, Math.sqrt(2 * g * Math.max(_clearanceAbove() - 30.0, 40.0)));
		final maxVx = effectiveRunSpeed() * 1.35;
		var apex = Math.max(Math.max(heightDiff, 0) + 30.0, 75.0);
		var vy = 0.0;
		var vx = 0.0;
		for (_ in 0...8)
		{
			vy = Math.min(Math.sqrt(2 * g * apex), maxVy);
			final reach = vy * vy / (2 * g);
			final airtime = vy / g + Math.sqrt(2 * Math.max(reach - heightDiff, 1.0) / g);
			vx = (Math.max(jumpDist, 44.0 * 0.5 + 24.0) + 10.0) / airtime;
			if (vx <= maxVx || vy >= maxVy) break;
			apex *= 1.4;
		}

		_jumpImpulse = -vy;
		_jumpVx = Math.max(heightDiff > 20.0 ? 110.0 : 60.0, Math.min(vx, maxVx));
		_jumpDir = dir;
		_quickLeap = quick;
		_chargeTimer = quick ? 0.04 : Math.min(1.5, (0.12 + Math.max(0, heightDiff) / 150.0) * _reactionMult());
		_setDir(dir);

		_stuckWindowTimer = 0;
		_stuckWindowStartX = sprite.x;
		_stuckTimer = 0;

		_playAnim(Charge);
	}

	function _updateBrake(elapsed:Float):Void
	{
		_brakeTimer -= elapsed;
		body.velocity.x *= Math.pow(0.02, elapsed / 0.16);
		_dustTimer -= elapsed;
		if (_dustTimer <= 0 && Math.abs(body.velocity.x) > 30)
		{
			_dustTimer = 0.06;
			_puff(body.velocity.x > 0 ? 1 : -1, 1, 60);
		}
		if (_brakeTimer <= 0)
		{
			body.velocity.x = 0;
			_playAnim(Idle);
		}
	}

	function _updateCharge(elapsed:Float):Void
	{
		if (!_quickLeap) body.velocity.x = 0;
		_chargeTimer -= elapsed;
		if (_chargeTimer <= 0)
		{
			body.velocity.x = _jumpDir * _jumpVx;
			body.velocity.y = _jumpImpulse;
			_setDir(_jumpDir);
			_fallSpeed = 0;
			_puff(-_jumpDir, 3, 70);
			_playAnim(Takeoff);
		}
	}

	function _updateTakeoff():Void
	{
		_airPush();
		if (body.velocity.y >= 0) _playAnim(AirFalling);
	}

	inline function _airPush():Void
	{
		if (Math.abs(body.velocity.x) < _jumpVx) body.velocity.x = _jumpDir * _jumpVx;
	}

	function _updateAirFalling():Void
	{
		_fallSpeed = Math.max(_fallSpeed, body.velocity.y);
		_airPush();
		if (isGrounded) _land();
	}

	function _land():Void
	{
		final impact = Math.min(1, _fallSpeed / 900.0);
		body.velocity.x = 0;
		_landingTimer = 0.14 + 0.16 * impact;
		_fallSpeed = 0;
		_puff(1, 2 + Std.int(impact * 4), 80 + impact * 60);
		_puff(-1, 2 + Std.int(impact * 4), 80 + impact * 60);
		_rumble(0.006 * (0.35 + 0.65 * impact), 0.12 + 0.18 * impact, true);
		_thump(true, 0.35 + 0.65 * impact);
		_playAnim(Landing);
	}

	function _updateLanding(elapsed:Float):Void
	{
		_landingTimer -= elapsed;
		if (_landingTimer <= 0)
		{
			_follower.invalidate();
			_playAnim(Idle);
		}
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

	function _checkSpineRecovery(elapsed:Float):Bool
	{
		if (_spineRecoverCooldown > 0)
		{
			_spineRecoverCooldown -= elapsed;
			return false;
		}

		if (_dormant || !_isOnSpine()) return false;

		_spineHits = _time - _spineHitTime < 6 ? _spineHits + 1 : 1;
		_spineHitTime = _time;
		if (_spineHits >= 3)
		{
			_spineHits = 0;
			_unstick();
			if (!_dormant && _isOnSpine()) _goDormant(false, true);
			return true;
		}

		final escapeDir = (_player.x >= sprite.x) ? 1 : -1;
		final maxVyForClearance = Math.sqrt(2 * TVNapeWorld.GRAVITY * Math.max(_clearanceAbove() - 30.0, 40.0));

		body.velocity.x = escapeDir * 280.0;
		_jumpDir = escapeDir;
		_jumpVx = 280.0;
		body.velocity.y = -Math.min(1400.0, maxVyForClearance);
		_setDir(escapeDir);
		_spineRecoverCooldown = 1.2;
		_playAnim(Takeoff);
		return true;
	}

	function _probe(ox:Float, oy:Float, dx:Float, dy:Float, maxDist:Float, ignorePlatforms:Bool):Float
	{
		final space = body.space;
		if (space == null) return -1;

		final orig = Vec2.get(ox, oy);
		final dir = Vec2.get(dx, dy);
		final ray = new Ray(orig, dir);
		ray.maxDistance = maxDist;
		space.rayMultiCast(ray, false, null, _rays);
		orig.dispose();
		dir.dispose();

		var best = -1.0;
		for (i in 0..._rays.length)
		{
			final r = _rays.at(i);
			final b = r.shape.body;
			if (b.isDynamic() || (ignorePlatforms && b.cbTypes.has(TVNapeWorld.CB_PLATFORM))) continue;
			if (best < 0 || r.distance < best) best = r.distance;
		}
		while (_rays.length > 0) _rays.pop().dispose();
		return best;
	}

	function _detectGround():Void
	{
		final halfW = 44.0 * 0.5;
		final footY = _feetY();
		isGrounded = _probe(body.position.x - halfW * 0.7, footY - 2, 0, 1, 10.0, false) >= 0
			|| _probe(body.position.x + halfW * 0.7, footY - 2, 0, 1, 10.0, false) >= 0;
	}

	public function hasWallAhead(dir:Int):Bool
	{
		final startX = body.position.x + dir * (44.0 * 0.5);
		final footY = _feetY();
		for (hy in [footY - 10, footY - 92.0 * 0.35, footY - 92.0 * 0.65, footY - 92.0 + 6])
			if (_probe(startX, hy, dir, 0, 26.0, true) >= 0) return true;
		return false;
	}

	public function hasGroundAhead(dir:Int):Bool
	{
		final lookX = body.position.x + dir * (44.0 * 0.5 + 40.0);
		return _probe(lookX, _feetY() - 20, 0, 1, 80.0, false) >= 0;
	}

	public function isAbyssAhead(dir:Int):Bool
	{
		return _groundYAt(body.position.x + dir * (44.0 * 0.5 + 40.0)) == null;
	}

	function _groundYAt(atX:Float):Null<Float>
	{
		final probeAbove = 260.0;
		final top = _feetY() - probeAbove;
		final d = _probe(atX, top, 0, 1, probeAbove + 600.0, false);
		return d >= 0 ? top + d : null;
	}

	function _clearanceAbove():Float
	{
		final d = _probe(body.position.x, body.position.y - 92.0 * 0.5, 0, -1, 900.0, true);
		return d >= 0 ? d : 900.0;
	}

	function _isOnSpine():Bool
	{
		final spines = _world.exeSpines();
		if (spines == null || spines.length == 0) return false;

		final footY = _feetY();
		final loX = body.position.x - 44.0 * 0.5;
		final hiX = body.position.x + 44.0 * 0.5;

		for (sp in spines)
		{
			if (sp.x + sp.sprite.width < loX || sp.x > hiX) continue;
			if (footY > sp.y + 15.0) return true;
		}
		return false;
	}

	public function hasSpineAhead(dir:Int):Bool
	{
		final spines = _world.exeSpines();
		if (spines == null || spines.length == 0) return false;

		final x2 = body.position.x + dir * (44.0 * 0.5 + 140.0);
		final loX = Math.min(body.position.x, x2);
		final hiX = Math.max(body.position.x, x2);
		final footY = _feetY();

		for (sp in spines)
		{
			if (sp.x + sp.sprite.width < loX || sp.x > hiX) continue;
			if (sp.y < footY - 40 || sp.y > footY + 400) continue;

			final cx = _clamp(sp.x + sp.sprite.width * 0.5, loX, hiX);
			final gy = _groundYAt(cx);
			if (gy != null && gy < sp.y - 30) continue;
			return true;
		}
		return false;
	}

	function _spineFarEdge(dir:Int):Float
	{
		var edge = body.position.x + dir * (44.0 * 0.5);
		for (sp in _world.exeSpines())
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
		final footY = _feetY();
		final startX = body.position.x + dir * (44.0 * 0.5);
		final landX = _spineFarEdge(dir) + dir * 30.0;
		final dist = Math.abs(landX - startX);

		if (dist <= 220.0)
		{
			final gy = _groundYAt(landX);
			if (gy != null && gy <= footY + 24.0)
				return { heightDiff: Math.max(0, footY - gy), dist: dist };
		}

		for (s in [60.0, 100.0, 140.0, 180.0])
		{
			final gy = _groundYAt(startX + dir * s);
			if (gy != null && gy < footY - 10 && (footY - gy) <= 220.0)
				return { heightDiff: footY - gy, dist: s };
		}

		return null;
	}

	public function measureObstacleHeight(dir:Int, aheadDist:Float):Float
	{
		final gy = _groundYAt(body.position.x + dir * (44.0 * 0.5 + aheadDist));
		return gy != null ? Math.max(0, _feetY() - gy) : 60.0;
	}

	function _seq(prefix:String, numbers:Array<Int>):Array<Int>
	{
		return [for (n in numbers) sprite.frames.getIndexByName('exe $prefix${StringTools.lpad(Std.string(n), "0", 4)}')];
	}

	function _playAnim(a:MonsterAnim):Void
	{
		final cur = sprite.animation.curAnim;
		final curName = cur != null ? cur.name : "";
		if (a == Searching)
		{
			_playSearch(curName);
			return;
		}

		final searching = curName == "SearchIn" || curName == "SearchA" || curName == "SearchB";
		if (a == Idle && (searching || (curName == "SearchOut" && !cur.finished)))
		{
			anim = Idle;
			if (searching) sprite.animation.play("SearchOut", true);
			return;
		}

		anim = a;
		final name = Std.string(a);
		if (curName != name) sprite.animation.play(name, true);
	}

	function _playSearch(curName:String):Void
	{
		anim = Searching;
		final cur = sprite.animation.curAnim;
		if (curName != "SearchIn" && curName != "SearchA" && curName != "SearchB")
		{
			sprite.animation.play(curName == "SearchOut" ? "SearchA" : "SearchIn", true);
			return;
		}
		if (!cur.finished) return;
		sprite.animation.play(curName == "SearchA" ? "SearchB" : "SearchA", true);
		sprite.animation.curAnim.frameRate = FlxG.random.int(7, 11);
	}

	function _rumble(intensity:Float, duration:Float, force:Bool):Void
	{
		if (_dormant || _lurking || sprite.alpha < 0.5 || _offScreen(body.position.x, _feetY())) return;
		final near = 1 - Math.min(1, _distToPlayer() / 520.0);
		if (near <= 0) return;
		_world.exeCamera().shake(intensity * (0.4 + 0.6 * near), duration, null, force);
	}

	function _thump(land:Bool, weight:Float = 1.0):Void
	{
		if (_dormant || _lurking || sprite.alpha < 0.5) return;
		final near = 1 - Math.min(1, _distToPlayer() / 700.0);
		if (near <= 0) return;
		final cam = _world.exeCamera();
		final half = cam.width * 0.5 / cam.zoom;
		final dx = body.position.x - (cam.scroll.x + cam.width * 0.5);
		final volume = (land ? 0.4 : 0.3) * weight * (0.35 + 0.65 * near);
		final s = FlxG.sound.play(Paths.sound(land ? "minigame/thevalley/exeland" : "minigame/thevalley/exestep"), Math.min(1, volume));
		s.pan = Math.max(-1, Math.min(1, dx / half * 0.7));
		s.pitch = FlxG.random.float(0.9, 1.1);
	}

	function _footsteps():Void
	{
		final cur = sprite.animation.curAnim;
		if (anim != Run || cur == null || !isGrounded)
		{
			_lastRunFrame = -1;
			return;
		}
		if (cur.curFrame == _lastRunFrame) return;
		_lastRunFrame = cur.curFrame;
		if (cur.curFrame == 2 || cur.curFrame == 5)
		{
			_rumble(0.0012, 0.05, false);
			_thump(false);
			if (FlxG.random.bool(50)) _puff(-_dir, 1, 40);
		}
	}

	function _puff(dir:Int, count:Int, speed:Float):Void
	{
		if (_dormant || _lurking || !sprite.visible) return;
		for (_ in 0...count)
		{
			var d = null;
			for (p in _dust) if (p.life <= 0) { d = p; break; }
			if (d == null)
			{
				final spr = new FlxSprite().makeGraphic(3, 3, 0xFFB4ACC0);
				spr.active = false;
				final at = _layer.members.indexOf(sprite);
				if (at >= 0) _layer.insert(at, spr);
				else _layer.add(spr);
				d = { spr: spr, vx: 0.0, vy: 0.0, life: 0.0, max: 1.0 };
				_dust.push(d);
			}
			d.max = d.life = FlxG.random.float(0.3, 0.55);
			d.vx = dir * FlxG.random.float(0.4, 1.0) * speed;
			d.vy = -FlxG.random.float(15, 55);
			d.spr.setPosition(body.position.x + FlxG.random.float(-44.0 * 0.4, 44.0 * 0.4), _feetY() - FlxG.random.float(2, 6));
			d.spr.visible = true;
		}
	}

	function _updateDust(elapsed:Float):Void
	{
		for (d in _dust)
		{
			if (d.life <= 0) continue;
			d.life -= elapsed;
			d.vx *= Math.pow(0.05, elapsed);
			d.vy += 90 * elapsed;
			d.spr.x += d.vx * elapsed;
			d.spr.y += d.vy * elapsed;
			d.spr.alpha = Math.max(0, d.life / d.max) * 0.85;
			d.spr.visible = d.life > 0;
		}
	}

	inline function _feetY():Float return body.position.y + 92.0 * 0.5;

	inline function _playerFeetX():Float return _player.x + _player.width * 0.5;

	inline function _playerFeetY():Float return _player.y + _player.height;

	inline function _playerHidden():Bool return ((_player.isHidden || _player.isHiding) && !_player.inDecoy) || _player.inDark;

	inline function _distToPlayer():Float
		return _dist(body.position.x, body.position.y, _player.x + _player.width * 0.5, _player.y + _player.height * 0.5);

	static inline function _dist(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		final dx = ax - bx;
		final dy = ay - by;
		return Math.sqrt(dx * dx + dy * dy);
	}

	static inline function _clamp(v:Float, lo:Float, hi:Float):Float return v < lo ? lo : (v > hi ? hi : v);

	static function _ensureNoPlayerCollision():Void
	{
		final space = FlxNapeSpace.space;
		if (space == null || _listenerSpace == space) return;
		_listenerSpace = space;
		space.listeners.add(new PreListener(InteractionType.COLLISION, CB_MONSTER, TVNapeWorld.CB_DYNAMIC,
			function(cb:PreCallback):Null<PreFlag> return PreFlag.IGNORE, 0, false));
	}

	public function destroy():Void
	{
		if (body != null) body.space = null;
		sprite?.destroy();
	}
}

interface ExeWorld
{
	function exeLayer():FlxState;
	function exeGraph():WaypointGraph;
	function exeCamera():FlxCamera;
	function exeTotems():Array<Totem>;
	function exeSpines():Array<SpineTile>;
	function exeMapBottom():Float;
	function exeCanKill():Bool;
	function exeCaught():Void;
}

class ExeBreath
{
	final _sound:FlxSound;
	var _volume:Float = 0;
	var _pan:Float = 0;
	var _pitch:Float = 1;

	public function new()
	{
		_sound = FlxG.sound.load(Paths.sound("minigame/thevalley/breathing"), 0, true, null, false, true);
	}

	public function update(elapsed:Float, monsters:Array<Monster>, player:Player, cam:FlxCamera, duck:Float = 1.0):Void
	{
		final px = player.x + player.width * 0.5;
		final py = player.y + player.height * 0.5;

		var volume = 0.0;
		var pan = _pan;
		var pitch = 1.0;
		var nearest = 900.0;
		for (m in monsters)
		{
			final spr = m.sprite;
			if (m.isDormant || m.disguised || spr.alpha < 0.05) continue;
			final onScreen = spr.x + spr.width > cam.viewLeft && spr.x < cam.viewRight && spr.y + spr.height > cam.viewTop && spr.y < cam.viewBottom;
			if (onScreen) continue;

			final mx = spr.x + spr.width * 0.5;
			final my = spr.y + spr.height * 0.5;
			final dx = mx - px;
			final dy = my - py;
			final d = Math.sqrt(dx * dx + dy * dy);
			if (d >= nearest) continue;
			nearest = d;

			final t = 1 - _clamp((d - 110.0) / (900.0 - 110.0));
			final chasing = m.anim == MonsterAnim.Run;
			volume = t * t * (3 - 2 * t) * (chasing ? 1.25 : 1.0);

			final side = dx >= 0 ? 1 : -1;
			final past = side > 0 ? spr.x - cam.viewRight : cam.viewLeft - (spr.x + spr.width);
			pan = past > 0
				? side * (0.55 + (1 - 0.55) * _clamp(past / 260.0))
				: side * 0.55 * _clamp(Math.abs(dx) / 400.0);

			pitch = chasing ? 1.12 : (m.anim == MonsterAnim.Searching ? 0.9 : 1.0);
		}

		final ease = (rate:Float) -> 1.0 - Math.pow(0.01, elapsed * rate);
		_volume += (Math.min(1, volume * duck) - _volume) * ease(volume > _volume ? 2.5 : 1.5);
		_pan += (pan - _pan) * ease(4.0);
		_pitch += (pitch - _pitch) * ease(2.0);
		_sound.volume = _volume;
		_sound.pan = _pan;
		_sound.pitch = _pitch;
	}

	public function fadeOut(time:Float):Void
	{
		_sound.fadeOut(time, 0);
	}

	static inline function _clamp(v:Float):Float return v < 0 ? 0 : (v > 1 ? 1 : v);
}

class ChaseMusic
{
	public var mix(default, null):Float = 0;

	final _sound:FlxSound;
	var _since:Float = 999;

	public function new()
	{
		_sound = FlxG.sound.load(Paths.sound("minigame/thevalley/chasetheme"), 0, true, null, false, false);
	}

	public function update(elapsed:Float, monsters:Array<Monster>):Void
	{
		var chasing = false;
		for (m in monsters) if (m.mood == MonsterMood.Chasing || m.transforming) chasing = true;

		_since = chasing ? 0 : _since + elapsed;
		final on = _since < 2.5;
		if (on && !_sound.playing && mix <= 0) _sound.play(true);
		mix = on ? Math.min(1, mix + elapsed / 0.4) : Math.max(0, mix - elapsed / 2.0);
		_sound.volume = 0.5 * mix;
		if (mix <= 0 && _sound.playing) _sound.stop();
	}

	public inline function release():Void
	{
		_since = 2.5;
	}

	public function stop():Void
	{
		_since = 999;
		mix = 0;
		_sound.stop();
	}
}
