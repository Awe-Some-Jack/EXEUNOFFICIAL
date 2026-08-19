package thevalley.astar;

import thevalley.astar.types.NextNodeCallback;

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

    /**
     * Gets the heuristic cost estimate from one state to another in the graph.
     *
     * @param from the state from which the cost should be calculated
     * @param to the state into which the cost should be calculated
     * @return the heuristic cost estimate
     */
    public abstract function getHeuristicCost(from: Int, to: Int): Float;

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
