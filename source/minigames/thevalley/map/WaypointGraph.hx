package minigames.thevalley.map;

import flixel.addons.nape.FlxNapeSpace;

import nape.geom.Ray;
import nape.geom.RayResultList;
import nape.geom.Vec2;
import nape.shape.ShapeList;

import minigames.thevalley.character.monster.Monster.ExeWorld;
import minigames.thevalley.libs.ai.nav.NavGraph;
import minigames.thevalley.libs.ai.pathfinding.types.NextNodeCallback;
import minigames.thevalley.map.TVNapeWorld;

typedef WNode = { x:Float, y:Float };

class WaypointGraph extends NavGraph
{
	var _world:ExeWorld;
	public var nodes:Array<WNode> = [];
	var _edges:Array<Array<{to:Int, cost:Float, trans:Int}>> = [];

	public function new(world:ExeWorld)
	{
		super();
		_world = world;
	}

	public function generate(minX:Float, maxX:Float):Void
	{
		nodes = [];
		_edges = [];

		mapBottom = _world.exeMapBottom();

		_createNodes(_sampleColumns(minX, maxX));
		_connectEdges();
		_connectComponents();
	}

	public var mapBottom(default, null):Float = Math.POSITIVE_INFINITY;

	public function walkDegree(state:Int):Int
	{
		if (state < 0 || state >= _edges.length || _edges[state] == null) return 0;
		var n = 0;
		for (e in _edges[state]) if (e.trans == 1) n++;
		return n;
	}

	function _connectComponents():Void
	{
		var n = nodes.length;
		if (n == 0) return;

		var hub = 0;
		var hubEdgeCount = -1;
		for (i in 0...n)
		{
			var c = (i < _edges.length && _edges[i] != null) ? _edges[i].length : 0;
			if (c > hubEdgeCount) { hubEdgeCount = c; hub = i; }
		}

		var reverseEdges:Array<Array<Int>> = [for (i in 0...n) []];
		for (i in 0..._edges.length)
		{
			if (_edges[i] == null) continue;
			for (e in _edges[i]) reverseEdges[e.to].push(i);
		}

		var reachableFromHub = _bfsForward(hub, n);
		var canReachHub       = _bfsBackward(hub, n, reverseEdges);

		for (i in 0...n)
		{
			if (reachableFromHub[i]) continue;
			var bestJ = -1, bestDSq = Math.POSITIVE_INFINITY;
			for (j in 0...n)
			{
				if (!reachableFromHub[j]) continue;
				var dx = nodes[j].x - nodes[i].x;
				var dy = nodes[j].y - nodes[i].y;
				var dSq = dx * dx + dy * dy;
				if (dSq < bestDSq) { bestDSq = dSq; bestJ = j; }
			}
			if (bestJ < 0) continue;
			_addEdge(bestJ, i, Math.sqrt(bestDSq) * (6.0), (4));
			reachableFromHub[i] = true;
		}

		for (i in 0...n)
		{
			if (canReachHub[i]) continue;
			var bestJ = -1, bestDSq = Math.POSITIVE_INFINITY;
			for (j in 0...n)
			{
				if (!canReachHub[j]) continue;
				var dx = nodes[i].x - nodes[j].x;
				var dy = nodes[i].y - nodes[j].y;
				var dSq = dx * dx + dy * dy;
				if (dSq < bestDSq) { bestDSq = dSq; bestJ = j; }
			}
			if (bestJ < 0) continue;
			_addEdge(i, bestJ, Math.sqrt(bestDSq) * (6.0), (4));
			canReachHub[i] = true;
		}
	}

	function _bfsForward(from:Int, n:Int):Array<Bool>
	{
		var seen = [for (i in 0...n) false];
		seen[from] = true;
		var queue = [from];
		var qi = 0;
		while (qi < queue.length)
		{
			var cur = queue[qi++];
			if (cur < _edges.length && _edges[cur] != null)
				for (e in _edges[cur])
					if (!seen[e.to]) { seen[e.to] = true; queue.push(e.to); }
		}
		return seen;
	}

	function _bfsBackward(from:Int, n:Int, reverseEdges:Array<Array<Int>>):Array<Bool>
	{
		var seen = [for (i in 0...n) false];
		seen[from] = true;
		var queue = [from];
		var qi = 0;
		while (qi < queue.length)
		{
			var cur = queue[qi++];
			for (j in reverseEdges[cur])
				if (!seen[j]) { seen[j] = true; queue.push(j); }
		}
		return seen;
	}

	final _rays:RayResultList = new RayResultList();
	final _shapes:ShapeList = new ShapeList();

	function _sampleColumns(minX:Float, maxX:Float):Array<{ x:Float, ys:Array<Float> }>
	{
		final columns = [];
		var x = minX;
		while (x <= maxX)
		{
			columns.push({ x: x, ys: _surfacesAt(x) });
			x += 70.0;
		}
		return columns;
	}

	function _surfacesAt(x:Float):Array<Float>
	{
		final hits:Array<Float> = [];
		final orig = Vec2.get(x, -1200.0);
		final down = Vec2.get(0, 1);
		final ray = new Ray(orig, down);
		ray.maxDistance = 2600.0;
		FlxNapeSpace.space.rayMultiCast(ray, false, null, _rays);
		orig.dispose();
		down.dispose();

		for (i in 0..._rays.length)
		{
			final r = _rays.at(i);
			if (!r.shape.body.isDynamic()) hits.push(-1200.0 + r.distance);
		}
		while (_rays.length > 0) _rays.pop().dispose();
		hits.sort((a, b) -> a < b ? -1 : (a > b ? 1 : 0));

		final ys:Array<Float> = [];
		for (y in hits)
		{
			if (y > mapBottom - 2) continue;
			if (ys.length > 0 && y - ys[ys.length - 1] < 20) continue;
			if (_solidAt(x, y - 3) || _solidAt(x, y - 88.0)) continue;
			if (_spikesOn(x, y)) continue;
			ys.push(y);
		}
		return ys;
	}

	function _spikesOn(x:Float, y:Float):Bool
	{
		for (sp in _world.exeSpines())
		{
			if (x < sp.x - 12 || x > sp.x + sp.sprite.width + 12) continue;
			if (y >= sp.y - 4 && y <= sp.y + sp.sprite.height + 24) return true;
		}
		return false;
	}

	function _solidAt(x:Float, y:Float):Bool
	{
		final p = Vec2.get(x, y);
		FlxNapeSpace.space.shapesUnderPoint(p, null, _shapes);
		p.dispose();

		var solid = false;
		for (i in 0..._shapes.length)
		{
			final b = _shapes.at(i).body;
			if (!b.isDynamic() && !b.cbTypes.has(TVNapeWorld.CB_PLATFORM)) { solid = true; break; }
		}
		_shapes.clear();
		return solid;
	}

	function _segmentFree(x0:Float, y0:Float, x1:Float, y1:Float, platformsBlock:Bool = false):Bool
	{
		final dx = x1 - x0;
		final dy = y1 - y0;
		final len = Math.sqrt(dx * dx + dy * dy);
		if (len < 1) return true;

		final orig = Vec2.get(x0, y0);
		final dir = Vec2.get(dx / len, dy / len);
		final ray = new Ray(orig, dir);
		ray.maxDistance = len;
		FlxNapeSpace.space.rayMultiCast(ray, false, null, _rays);
		orig.dispose();
		dir.dispose();

		var free = true;
		for (i in 0..._rays.length)
		{
			final b = _rays.at(i).shape.body;
			if (!b.isDynamic() && (platformsBlock || !b.cbTypes.has(TVNapeWorld.CB_PLATFORM))) { free = false; break; }
		}
		while (_rays.length > 0) _rays.pop().dispose();
		return free;
	}

	function _createNodes(columns:Array<{ x:Float, ys:Array<Float> }>):Void
	{
		final ids:Array<Array<Int>> = [];
		for (c in columns)
		{
			final colIds = [];
			for (y in c.ys)
			{
				colIds.push(nodes.length);
				nodes.push({x: c.x, y: y});
			}
			ids.push(colIds);
		}

		for (i in 0...columns.length - 1)
		{
			for (a in ids[i])
			{
				var best = -1;
				var bestDy = 60.0;
				for (b in ids[i + 1])
				{
					final dy = Math.abs(nodes[b].y - nodes[a].y);
					if (dy <= bestDy && _walkable(a, b)) { best = b; bestDy = dy; }
				}
				if (best < 0) continue;

				final cost = _len(a, best);
				_addEdge(a, best, cost, 1);
				_addEdge(best, a, cost, 1);
				_walkLinked.set(_pairKey(a, best), true);
				_walkLinked.set(_pairKey(best, a), true);
			}
		}
	}

	final _walkLinked:Map<Int, Bool> = new Map();

	inline function _pairKey(a:Int, b:Int):Int return a * 65536 + b;

	function _walkable(a:Int, b:Int):Bool
	{
		final na = nodes[a];
		final nb = nodes[b];
		return _segmentFree(na.x, na.y - 20, nb.x, nb.y - 20) && _segmentFree(na.x, na.y - 88.0, nb.x, nb.y - 88.0);
	}

	inline function _len(a:Int, b:Int):Float
	{
		final dx = nodes[a].x - nodes[b].x;
		final dy = nodes[a].y - nodes[b].y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	function _connectEdges():Void
	{
		var order = [for (i in 0...nodes.length) i];
		order.sort((a, b) -> nodes[a].x < nodes[b].x ? -1 : (nodes[a].x > nodes[b].x ? 1 : 0));

		for (oi in 0...order.length)
		{
			var i = order[oi];
			for (oj in (oi + 1)...order.length)
			{
				var j = order[oj];
				if (nodes[j].x - nodes[i].x > (260.0)) break;
				_tryConnect(i, j);
				_tryConnect(j, i);
			}
		}
	}

	function _tryConnect(fromId:Int, toId:Int):Void
	{
		if (_walkLinked.exists(_pairKey(fromId, toId))) return;

		var a = nodes[fromId];
		var b = nodes[toId];
		var dist = Math.abs(b.x - a.x);
		var heightDiff = a.y - b.y;

		if (heightDiff <= 0)
		{
			var drop = -heightDiff;
			if (drop <= 40.0 && dist <= 70.0 * 1.5) return;
			if (dist > 220.0 && drop > 40.0) return;
			if (_spineBlocks(a.x, b.x, Math.min(a.y, b.y) - 10, Math.max(a.y, b.y) + 400))
			{
				final apexY = Math.min(a.y, b.y) - 80;
				if (drop <= 60.0 && dist <= 240.0 && _segmentFree(a.x, a.y - 5, a.x, apexY) && _segmentFree(a.x, apexY, b.x, apexY) && _segmentFree(b.x, apexY, b.x, b.y - 5))
					_addEdge(fromId, toId, dist * 1.2, 3);
				return;
			}

			if (!_segmentFree(a.x, a.y - 30, b.x, a.y - 30) || !_segmentFree(b.x, a.y - 10, b.x, b.y - 5, true)) return;

			_addEdge(fromId, toId, _len(fromId, toId), 2);
			return;
		}

		if (heightDiff <= 220.0 && dist <= 220.0)
		{
			var vyForHeight = Math.sqrt(2 * TVNapeWorld.GRAVITY * heightDiff);
			var vyForDist   = dist * TVNapeWorld.GRAVITY / (2 * 230.0);
			if (Math.max(vyForHeight, vyForDist) > 1050.0) return;

			final apexY = b.y - 60;
			if (!_segmentFree(a.x, a.y - 5, a.x, apexY) || !_segmentFree(a.x, apexY, b.x, apexY) || !_segmentFree(b.x, apexY, b.x, b.y - 5)) return;

			_addEdge(fromId, toId, dist + heightDiff, 3);
		}
	}

	function _spineBlocks(x1:Float, x2:Float, minY:Float, maxY:Float):Bool
	{
		var spines = _world.exeSpines();
		var loX = Math.min(x1, x2);
		var hiX = Math.max(x1, x2);
		for (sp in spines)
		{
			var spLo = sp.x;
			var spHi = sp.x + sp.sprite.width;
			if (spHi < loX || spLo > hiX) continue;
			if (sp.y < minY || sp.y > maxY) continue;
			return true;
		}
		return false;
	}

	function _addEdge(from:Int, to:Int, cost:Float, trans:Int):Void
	{
		while (_edges.length <= from) _edges.push([]);
		_edges[from].push({to: to, cost: cost, trans: trans});
	}

	public var useComponentLinks:Bool = false;

	public function getNextNodes(state:Int, callback:NextNodeCallback):Void
	{
		if (state < 0 || state >= _edges.length) return;
		var arr = _edges[state];
		if (arr == null) return;
		for (e in arr)
			if (useComponentLinks || e.trans != 4)
				callback(e.to, e.cost, e.trans);
	}

	public function edgeStats():Map<Int, Int>
	{
		final stats = [1 => 0, 2 => 0, 3 => 0, 4 => 0];
		for (arr in _edges) if (arr != null) for (e in arr) stats[e.trans] = stats[e.trans] + 1;
		return stats;
	}

	public function getHeuristicCost(from:Int, to:Int):Float
	{
		var a = nodes[from];
		var b = nodes[to];
		var dx = a.x - b.x;
		var dy = a.y - b.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function nearestNode(x:Float, y:Float):Int
	{
		var best = -1;
		var bestD = Math.POSITIVE_INFINITY;
		for (i in 0...nodes.length)
		{
			var n = nodes[i];
			var dx = n.x - x;
			var dy = (n.y - y) * (4.0);
			var d = dx * dx + dy * dy;
			if (d < bestD) { bestD = d; best = i; }
		}
		return best;
	}

	public function stateCount():Int return nodes.length;

	public function stateX(state:Int):Float return nodes[state].x;

	public function stateY(state:Int):Float return nodes[state].y;

	override public function nearestState(x:Float, y:Float):Int return nearestNode(x, y);
}
