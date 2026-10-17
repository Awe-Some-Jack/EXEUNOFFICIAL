package minigames.thevalley.libs.ai.nav;

import minigames.thevalley.libs.ai.pathfinding.SearchResult;
import minigames.thevalley.libs.ai.pathfinding.types.Result;

enum abstract NavStatus(Int)
{
	var Idle = 0;

	var Moving = 1;

	var Arrived = 2;

	var Unreachable = 3;

	public function toString():String
	{
		return switch (this)
		{
			case 1: "Moving";
			case 2: "Arrived";
			case 3: "Unreachable";
			default: "Idle";
		}
	}
}

class PathFollower
{
	public final graph:NavGraph;

	public var repathInterval:Float = 0.4;

	public var waypointRadius:Float = 16;

	public var arriveRadius:Float = 24;

	public var status(default, null):NavStatus = Idle;

	public var hasTarget(default, null):Bool = false;
	public var targetX(default, null):Float = 0;
	public var targetY(default, null):Float = 0;

	public var waypointX(default, null):Float = 0;
	public var waypointY(default, null):Float = 0;

	public var waypointTransition(default, null):Int = 0;

	public var result(default, null):SearchResult = null;

	public var index(default, null):Int = 0;

	public var searches(default, null):Int = 0;

	var repathTimer:Float = 0;
	var searched:Bool = false;

	public function new(graph:NavGraph)
	{
		this.graph = graph;
	}

	public function setTarget(x:Float, y:Float):Void
	{
		if (!hasTarget) searched = false;
		hasTarget = true;
		targetX = x;
		targetY = y;
	}

	public function clear():Void
	{
		hasTarget = false;
		result = null;
		index = 0;
		searched = false;
		repathTimer = 0;
		status = Idle;
	}

	public inline function invalidate():Void
	{
		searched = false;
	}

	public function repath(x:Float, y:Float):Void
	{
		result = graph.findPath(x, y, targetX, targetY);
		searched = true;
		searches++;
		repathTimer = repathInterval > 0 ? repathInterval : Math.POSITIVE_INFINITY;

		index = result != null && result.hasPath ? 1 : 0;
	}

	public function update(elapsed:Float, x:Float, y:Float):NavStatus
	{
		if (!hasTarget) return status = Idle;

		if (dist2(x, y, targetX, targetY) <= arriveRadius * arriveRadius) return status = Arrived;

		repathTimer -= elapsed;
		if (!searched || repathTimer <= 0) repath(x, y);

		if (result == null)
		{
			setWaypoint(targetX, targetY, 0);
			return status = Moving;
		}

		if (!result.hasPath) return status = Unreachable;

		final path = result.path;
		final r2 = waypointRadius * waypointRadius;
		while (index < path.length && dist2(x, y, graph.stateX(path[index]), graph.stateY(path[index])) <= r2)
			index++;

		if (index >= path.length)
		{
			if (result.result == Partial) return status = Unreachable;

			setWaypoint(targetX, targetY, 0);
			return status = Moving;
		}

		setWaypoint(graph.stateX(path[index]), graph.stateY(path[index]), result.transitions[index]);
		return status = Moving;
	}

	inline function setWaypoint(x:Float, y:Float, transition:Int):Void
	{
		waypointX = x;
		waypointY = y;
		waypointTransition = transition;
	}

	static inline function dist2(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		final dx = ax - bx;
		final dy = ay - by;
		return dx * dx + dy * dy;
	}
}
