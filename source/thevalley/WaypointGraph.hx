package thevalley;

import flixel.addons.nape.FlxNapeSpace;
import nape.geom.Ray;
import nape.geom.Vec2;
import thevalley.astar.Graph;
import thevalley.astar.SearchResult;
import thevalley.astar.types.NextNodeCallback;
import thevalley.map.TVNapeWorld;

typedef WNode = { x:Float, y:Float };

class WaypointGraph extends Graph
{




	var _state:TheValley;
	public var nodes:Array<WNode> = [];
	var _edges:Array<Array<{to:Int, cost:Float, trans:Int}>> = [];

	public function new(state:TheValley)
	{
		super();
		_state = state;
	}

	public function generate(minX:Float, maxX:Float):Void
	{
		nodes = [];
		_edges = [];

		var samples = _sampleTerrain(minX, maxX);
		var segments = _buildSegments(samples);
		_createNodes(segments);
		_connectEdges();
		_connectComponents();
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


	function _groundYAt(x:Float, aboveY:Float, range:Float):Null<Float>
	{
		var orig = Vec2.get(x, aboveY);
		var down = Vec2.get(0, 1);
		var ray  = new Ray(orig, down);
		ray.maxDistance = range;
		var res = FlxNapeSpace.space.rayCast(ray, false);
		orig.dispose();
		down.dispose();
		var result:Null<Float> = null;
		if (res != null) { result = aboveY + res.distance; res.dispose(); }
		return result;
	}

	function _sampleTerrain(minX:Float, maxX:Float):Array<WNode>
	{
		var samples:Array<WNode> = [];
		var x = minX;
		while (x <= maxX)
		{
			var y = _groundYAt(x, -(1200.0), (2600.0));
			if (y != null) samples.push({x: x, y: y});
			x += (70.0);
		}
		return samples;
	}

	function _buildSegments(samples:Array<WNode>):Array<Array<WNode>>
	{
		var segments:Array<Array<WNode>> = [];
		var current:Array<WNode> = [];
		for (s in samples)
		{
			if (current.length > 0 && Math.abs(s.y - current[current.length - 1].y) > (60.0))
			{
				segments.push(current);
				current = [];
			}
			current.push(s);
		}
		if (current.length > 0) segments.push(current);
		return segments;
	}

	function _createNodes(segments:Array<Array<WNode>>):Void
	{
		for (seg in segments)
		{
			if (seg.length == 0) continue;
			var first = seg[0];
			var last  = seg[seg.length - 1];
			if (Math.abs(last.x - first.x) < (20.0)) continue;

			var startId = nodes.length;
			nodes.push({x: first.x, y: first.y});

			var lastAddedX = first.x;
			for (s in seg)
			{
				if (s.x - lastAddedX >= (220.0))
				{
					nodes.push({x: s.x, y: s.y});
					lastAddedX = s.x;
				}
			}
			nodes.push({x: last.x, y: last.y});

			for (i in startId...(nodes.length - 1))
			{
				var a = i;
				var b = i + 1;
				var d = Math.abs(nodes[b].x - nodes[a].x);
				_addEdge(a, b, d, (1));
				_addEdge(b, a, d, (1));
			}
		}
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
		var a = nodes[fromId];
		var b = nodes[toId];
		var dist = Math.abs(b.x - a.x);
		var heightDiff = a.y - b.y;

		if (heightDiff <= 0)
		{
			var drop = -heightDiff;
			if (_spineBlocks(a.x, b.x, Math.min(a.y, b.y) - 10, Math.max(a.y, b.y) + 400)) return;

			if (drop <= (40.0)) _addEdge(fromId, toId, dist, (2));
			else if (dist <= (220.0)) _addEdge(fromId, toId, dist, (2));
			return;
		}

		if (heightDiff <= (220.0) && dist <= (220.0))
		{
			var vyForHeight = Math.sqrt(2 * TVNapeWorld.GRAVITY * heightDiff);
			var vyForDist   = dist * TVNapeWorld.GRAVITY / (2 * (230.0));
			var needed = Math.max(vyForHeight, vyForDist);
			if (needed <= (1050.0))
				_addEdge(fromId, toId, dist + heightDiff * 0.5, (3));
		}
	}

	function _spineBlocks(x1:Float, x2:Float, minY:Float, maxY:Float):Bool
	{
		var spines = _state.tileMap.spines;
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


	public function getNextNodes(state:Int, callback:NextNodeCallback):Void
	{
		if (state < 0 || state >= _edges.length) return;
		var arr = _edges[state];
		if (arr == null) return;
		for (e in arr) callback(e.to, e.cost, e.trans);
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

	public function findPath(fromX:Float, fromY:Float, toX:Float, toY:Float):SearchResult
	{
		if (nodes.length == 0) return null;
		var start = nearestNode(fromX, fromY);
		var goal  = nearestNode(toX, toY);
		if (start < 0 || goal < 0 || start == goal) return null;
		return astar.solve(start, goal);
	}
}
