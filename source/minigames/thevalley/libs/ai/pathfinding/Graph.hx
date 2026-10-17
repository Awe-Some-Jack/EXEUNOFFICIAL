package minigames.thevalley.libs.ai.pathfinding;

import minigames.thevalley.libs.ai.pathfinding.types.NextNodeCallback;

abstract class Graph
{
    final astar: Astar;

    function new()
    {
        astar = new Astar(this);
    }

    /**
     * Gets the states that are reachable from the given node.
     *
     * @param state the state identifier of the node
     * @param callback the callback to invoke with the next states;
     *                 each call should specify the next node state identifier, along with the real cost of traversing
     *                 from the current `state` to that one
     */
    public abstract function getNextNodes(state: Int, callback: NextNodeCallback): Void;

    public abstract function getHeuristicCost(from: Int, to: Int): Float;

    public inline function solve(start: Int, goal: Int, ?maxCost: Float): SearchResult
    {
        return astar.solve(start, goal, maxCost);
    }

    public function configureSearch(?heuristicWeight: Float, ?maxIterations: Int, ?allowPartial: Bool)
    {
        if (heuristicWeight != null) astar.heuristicWeight = heuristicWeight;
        if (maxIterations != null) astar.maxIterations = maxIterations;
        if (allowPartial != null) astar.allowPartial = allowPartial;
    }

    /**
     * Enables or disables path caching.
     *
     * Simply disabling the cache does not reset it.
     *
     * @param enabled Set to `true` to enable caching or `false` to disable it.
     * @param size The new size of the cache, representing the amount of paths that should be cached
     * at the same time. Passing this parameter will also reset and reconfigure the cache.
     */
    public inline function configureCache(enabled: Bool, ?size: Int)
    {
        astar.configureCache(enabled, size);
    }

    public inline function resetCache()
    {
        astar.resetCache();
    }
}
