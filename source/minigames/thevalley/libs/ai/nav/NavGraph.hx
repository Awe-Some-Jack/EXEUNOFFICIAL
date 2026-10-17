package minigames.thevalley.libs.ai.nav;

import minigames.thevalley.libs.ai.pathfinding.Graph;
import minigames.thevalley.libs.ai.pathfinding.SearchResult;

abstract class NavGraph extends Graph
{
	function new()
	{
		super();
	}

	public abstract function stateCount():Int;

	public abstract function stateX(state:Int):Float;

	public abstract function stateY(state:Int):Float;

	public function nearestState(x:Float, y:Float):Int
	{
		var best = -1;
		var bestD = Math.POSITIVE_INFINITY;
		for (i in 0...stateCount())
		{
			final dx = stateX(i) - x;
			final dy = stateY(i) - y;
			final d = dx * dx + dy * dy;
			if (d < bestD)
			{
				bestD = d;
				best = i;
			}
		}
		return best;
	}

	public function findPath(fromX:Float, fromY:Float, toX:Float, toY:Float):SearchResult
	{
		if (stateCount() == 0) return null;

		final start = nearestState(fromX, fromY);
		final goal = nearestState(toX, toY);
		if (start < 0 || goal < 0 || start == goal) return null;

		return solve(start, goal);
	}
}
