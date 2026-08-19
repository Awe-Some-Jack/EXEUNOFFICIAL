package thevalley.astar;

import thevalley.astar.cache.CacheResult;
import thevalley.astar.cache.PathCache;
import thevalley.astar.types.PathNode;
import thevalley.astar.types.PathNodePool;
import thevalley.astar.types.SortedPathNodeList;
import thevalley.astar.wrappers.ClosedSet;


class Astar
{
    var graph: Graph;

    var nodePool: PathNodePool;
    var pathCache: PathCache;
    var cacheEnabled: Bool;

    var openList: SortedPathNodeList;
    var closedList: ClosedSet;

    public function new(graph: Graph)
    {
        this.graph = graph;

        nodePool = new PathNodePool();
        pathCache = null;
        cacheEnabled = false;

        openList = new SortedPathNodeList();
        closedList = new ClosedSet();
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
    public function configureCache(enabled: Bool, ?size: Int)
    {
        if (enabled)
        {
            cacheEnabled = true;

            if (pathCache == null)
            {
                if (size == null)
                {
                    throw "You need to specify a cache size when enabling path caching.";
                }

                pathCache = new PathCache(size);
            }
            else if (size != null)
            {
                // Size changed, reset and reconfigure the cache.
                resetCache();
                pathCache.configure(size);
            }
        }
        else
        {
            cacheEnabled = false;
        }
    }

    /**
     * Resets the cache, emptying it of all cached paths.
     *
     * @param freeMemory By default, internal objects are pooled in order to minimize memory allocations and
     * improve overall performance. Setting this parameter to `true` will clear all cache object pools in
     * addition to resetting the cache, leaving all occupied memory out for the garbage collector.
     */
    public function resetCache(freeMemory: Bool = false)
    {
        if (pathCache != null)
        {
            pathCache.reset(freeMemory);
        }
    }

    /**
     * Tries to find the shortest path between the given points `(startX, startY)` and `(endX, endY)`,
     * on the grid that was loaded using `setWorld()`.
     *
     * The returned object's `result` field contains a value specifying whether the search was successful,
     * unsuccessful, or if there is no solution due to obstacles.
     */
    public function solve(start: Int, goal: Int, ?maxCost: Float): SearchResult
    {
        var result: SearchResult = new SearchResult();
        result.result = NoSolution;

        if (start == goal)
        {
            result.result = StartEndSame;
            return result;
        }

        var pathEndNode: PathNode = findPath(start, goal, result, maxCost);

        if (pathEndNode != null)
        {
            // Goal reached.
            result.setResultPath(pathEndNode);

            if (cacheEnabled)
            {
                pathCache.addSolution(pathEndNode);
            }

            return result;
        }

        // all nodes visited, couldn't reach the goal
        return result;
    }

    /**
     * Internal method for finding the shortest path between two points.
     *
     * @return The final node in the path, or `null` if a path could not be found.
     */
    function findPath(start: Int, goal: Int, ?result: SearchResult, ?maxCost: Float): PathNode
    {
        // Initialize lists.
        openList.clear();
        closedList.clear(nodePool);

        // Initialize starting node.
        var startingNode: PathNode = nodePool.getNode(start, 0, 0, 0);

        // Put starting node in open list.
        openList.insert(startingNode);
        closedList.addNode(startingNode);

        while (!openList.isEmpty())
        {
            var node: PathNode = openList.popNext();
            node.visited = true;

            if (maxCost != null && node.costFromStart > maxCost)
            {
                result.result = MaxCostExceeded;
                return null;
            }

            if (node.state == goal)
            {
                // Goal reached.
                return node;
            }

            if (cacheEnabled && result != null)
            {
                // Can the cache complete the path from here to the end?
                var cacheResult: CacheResult = pathCache.solve(node.state, goal, result, node.costFromStart, maxCost);

                switch cacheResult
                {
                    case Hit:
                        {
                            // Hit, path found!
                            return node;
                        }

                    case NoSolution:
                        {
                            // The path is known to not have a solution.
                            return null;
                        }

                    case MaxCostExceeded:
                        {
                            // Path found, but it exceeds the maximum cost.
                            result.result = MaxCostExceeded;
                            return null;
                        }

                    default:
                }
            }

            // Add the neighbors and move on to the next node.
            addNextNodes(node, goal);
        }

        if (cacheEnabled)
        {
            pathCache.addNoSolution(start, goal);
        }

        return null;
    }

    function addNextNodes(node: PathNode, goal: Int)
    {
        graph.getNextNodes(node.state, (nextState: Int, cost: Float, ?transition: Int) ->
        {
            var costFromStart: Float = node.costFromStart + cost;
            var costEstimateToGoal: Float = graph.getHeuristicCost(nextState, goal);

            if (closedList.contains(nextState))
            {
                // Node has already been checked, check if previous path was better.
                var existing: PathNode = closedList[ nextState ];

                if (existing.visited)
                {
                    // Node has already been visited, do nothing.
                }
                else if (existing.costFromStart <= costFromStart)
                {
                    // Node has already been checked from a shorter path, do nothing.
                }
                else
                {
                    // Current node is better than existing node, replace it.
                    openList.remove(existing);

                    existing.costFromStart = costFromStart;
                    existing.estimatedCostToGoal = costEstimateToGoal;
                    existing.previous = node;
                    existing.transition = transition;

                    openList.insert(existing);
                }
                return;
            }

            // node not discovered yet
            var transitionId: Int = transition == null ? 0 : transition;
            var nextNode: PathNode = nodePool.getNode(nextState, transitionId, costFromStart, costEstimateToGoal, node);

            openList.insert(nextNode);
            closedList.addNode(nextNode);
        });
    }
}
