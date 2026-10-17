package minigames.thevalley.libs.ai.pathfinding;

import minigames.thevalley.libs.ai.pathfinding.cache.CachedPath;
import minigames.thevalley.libs.ai.pathfinding.cache.CachedPathNode;
import minigames.thevalley.libs.ai.pathfinding.cache.PathCache;
import minigames.thevalley.libs.ai.pathfinding.types.NextNodeCallback;
import minigames.thevalley.libs.ai.pathfinding.types.PathNode;
import minigames.thevalley.libs.ai.pathfinding.types.PathNodeHeap;
import minigames.thevalley.libs.ai.pathfinding.types.PathNodePool;
import minigames.thevalley.libs.ai.pathfinding.types.Result;
import minigames.thevalley.libs.ai.pathfinding.wrappers.ClosedSet;

class Astar
{
    public var heuristicWeight: Float = 1.0;

    public var maxIterations: Int = 0;

    public var allowPartial: Bool = false;

    public var lastIterations(default, null): Int = 0;

    var graph: Graph;

    var nodePool: PathNodePool;
    var pathCache: PathCache;
    var cacheEnabled: Bool;

    var openList: PathNodeHeap;
    var closedList: ClosedSet;

    var expanding: PathNode;
    var goal: Int;
    final onNextNodeCallback: NextNodeCallback;

    var joinedTail: CachedPathNode;

    public function new(graph: Graph)
    {
        this.graph = graph;

        nodePool = new PathNodePool();
        pathCache = null;
        cacheEnabled = false;

        openList = new PathNodeHeap();
        closedList = new ClosedSet();

        onNextNodeCallback = onNextNode;
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

    public function resetCache(freeMemory: Bool = false)
    {
        if (pathCache != null)
        {
            pathCache.reset(freeMemory);
        }
    }

    public function solve(start: Int, goal: Int, ?maxCost: Float): SearchResult
    {
        var result: SearchResult = new SearchResult();
        result.result = NoSolution;
        lastIterations = 0;

        if (start == goal)
        {
            result.result = StartEndSame;
            return result;
        }

        var pathEndNode: PathNode = findPath(start, goal, result, maxCost);
        result.expanded = lastIterations;

        if (pathEndNode != null)
        {
            // Goal reached.
            result.setResultPath(pathEndNode);

            if (cacheEnabled)
            {
                pathCache.addSolution(pathEndNode, joinedTail);
            }

            return result;
        }

        if (allowPartial)
        {
            var closest: PathNode = findClosestVisited(start);
            if (closest != null)
            {
                var reason: Result = result.result;
                result.setResultPath(closest);
                result.result = Partial;
                result.partialReason = reason;
            }
        }

        return result;
    }

    function findPath(start: Int, goal: Int, result: SearchResult, ?maxCost: Float): PathNode
    {
        // Initialize lists.
        openList.clear();
        closedList.clear(nodePool);

        this.goal = goal;

        // Initialize starting node.
        var startingNode: PathNode = nodePool.getNode(start, 0, 0, heuristic(start));

        // Put starting node in open list.
        openList.insert(startingNode);
        closedList.addNode(startingNode);

        var joinNode: PathNode = null;
        var joinPath: CachedPath = null;
        var joinCost: Float = Math.POSITIVE_INFINITY;
        joinedTail = null;

        while (!openList.isEmpty())
        {
            var node: PathNode = openList.popNext();

            if (joinNode != null && node.totalCost >= joinCost)
            {
                break;
            }

            if (maxCost != null && node.costFromStart > maxCost)
            {
                result.result = MaxCostExceeded;
                return null;
            }

            node.visited = true;

            if (node.state == goal)
            {
                // Goal reached.
                return node;
            }

            if (maxIterations > 0 && lastIterations >= maxIterations)
            {
                if (joinNode != null)
                    break;

                result.result = MaxIterationsExceeded;
                return null;
            }

            lastIterations++;

            if (cacheEnabled)
            {
                var cached: CachedPath = pathCache.lookup(node.state, goal);

                if (cached != null)
                {
                    if (!cached.hasSolution())
                    {
                        continue;
                    }

                    var total: Float = node.costFromStart + cached.startNode.costToEnd;
                    if (maxCost == null || total <= maxCost)
                    {
                        if (total < joinCost)
                        {
                            joinNode = node;
                            joinPath = cached;
                            joinCost = total;
                        }

                        continue;
                    }
                }
            }

            // Add the neighbors and move on to the next node.
            expanding = node;
            graph.getNextNodes(node.state, onNextNodeCallback);
        }

        expanding = null;

        if (joinNode != null)
        {
            joinedTail = joinPath.startNode;
            result.appendCachedNodes(joinedTail);
            return joinNode;
        }

        if (cacheEnabled)
        {
            pathCache.addNoSolution(start, goal);
        }

        return null;
    }

    function onNextNode(nextState: Int, cost: Float, ?transition: Int)
    {
        var node: PathNode = expanding;
        var costFromStart: Float = node.costFromStart + cost;
        var transitionId: Int = transition == null ? 0 : transition;

        var existing: PathNode = closedList.get(nextState);
        if (existing != null)
        {
            if (existing.visited || existing.costFromStart <= costFromStart)
            {
                return;
            }

            existing.costFromStart = costFromStart;
            existing.previous = node;
            existing.transition = transitionId;

            openList.update(existing);
            return;
        }

        // node not discovered yet
        var nextNode: PathNode = nodePool.getNode(nextState, transitionId, costFromStart, heuristic(nextState), node);

        openList.insert(nextNode);
        closedList.addNode(nextNode);
    }

    inline function heuristic(state: Int): Float
    {
        return heuristicWeight == 0 ? 0 : graph.getHeuristicCost(state, goal) * heuristicWeight;
    }

    function findClosestVisited(start: Int): PathNode
    {
        var best: PathNode = null;
        var bestH: Float = Math.POSITIVE_INFINITY;

        for (i in 0...closedList.getSize())
        {
            var node: PathNode = closedList.nodeAt(i);
            if (!node.visited || node.state == start)
                continue;

            var h: Float = graph.getHeuristicCost(node.state, goal);
            if (best == null || h < bestH || (h == bestH && node.costFromStart < best.costFromStart))
            {
                best = node;
                bestH = h;
            }
        }

        if (best != null && bestH >= graph.getHeuristicCost(start, goal))
        {
            return null;
        }

        return best;
    }
}
