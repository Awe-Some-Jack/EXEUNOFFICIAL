package minigames.thevalley.libs.ai.pathfinding.cache;

import minigames.thevalley.libs.ai.pathfinding.types.PathNode;

class PathCache
{
    public var size(get, never): Int;
    public var hits(default, null): Int;
    public var misses(default, null): Int;

    var cache: BubbleList<CachedPath>;
    var cacheHashMap: Map<Int, CachedPath>;

    var cachedPathPool: CachedPathPool;
    var cachedPathNodePool: CachedPathNodePool;

    public function new(size: Int = 100)
    {
        hits = 0;
        misses = 0;

        cache = new BubbleList<CachedPath>(size);
        cacheHashMap = new Map<Int, CachedPath>();

        cachedPathPool = new CachedPathPool();
        cachedPathNodePool = new CachedPathNodePool();
    }

    public function lookup(start: Int, end: Int): CachedPath
    {
        var cachedPath: CachedPath = get(hash(start, end));

        if (cachedPath == null || !cachedPath.matches(start, end))
        {
            misses++;
            return null;
        }

        // Cache hit!
        hits++;

        cache.bubble(cachedPath);

        return cachedPath;
    }

    public function addSolution(end: PathNode, ?tail: CachedPathNode)
    {
        var endState: Int;
        var next: CachedPathNode;

        if (tail == null)
        {
            next = cachedPathNodePool.getCachedPathNode(end.state, end.transition, null, 0);
            endState = end.state;
        }
        else
        {
            next = cachedPathNodePool.getCachedPathNode(end.state, end.transition, tail.next, tail.costToEnd);

            var last: CachedPathNode = tail;
            while (last.next != null)
                last = last.next;
            endState = last.state;
        }

        // Start iterating backwards from the end node.
        var iter: PathNode = end;

        while (iter.previous != null)
        {
            // iter is still pointing to the next node in the path.
            // The total cost to the end is the cost to move to the next node, plus the next node's cost to the end.
            var costToEnd: Float = iter.getCostFromPrevious() + next.costToEnd;

            // Move the iterator to point to this node.
            iter = iter.previous;

            // Create the node and simultaneously store it for the next loop.
            var node: CachedPathNode = cachedPathNodePool.getCachedPathNode(iter.state, iter.transition, next, costToEnd);

            // Store a path that goes from this node to the end.
            var hash: Int = hash(node.state, endState);

            var path: CachedPath = cachedPathPool.getSolvedCachedPath(node, endState, hash);

            addPath(path);

            next = node;
        }
    }

    /**
        Adds a pair of start and end coordinates to the cache, which are known to have no solution.

        @param start The state identifier of the starting node.
        @param end The state identifier of the ending node.
        @param endX The x-coordinate of the ending point.
        @param endY The y-coordinate of the ending point.
    **/
    public function addNoSolution(start: Int, end: Int)
    {
        var hash: Int = hash(start, end);

        var path: CachedPath = cachedPathPool.getNoSolutionCachedPath(start, end, hash);

        addPath(path);
    }

    /**
        Empties the cache.

        It is recommended to keep and reuse the `PathCache` object, since
        internal objects are being pooled for better performance.
    **/
    public function reset(freeMemory: Bool = false)
    {
        while (cache.length > 0)
        {
            var path: CachedPath = cache.last();

            if (path.hasSolution())
            {
                if (path.startNode.next.next == null)
                {
                    // If the node after this one's starting node has no next node,
                    // then it is the ending node.
                    // In this case we should free it here, since no other path will have it as its starting node.
                    cachedPathNodePool.put(path.startNode.next);
                }

                // Put its starting node back to the pool.
                // We only know for sure that the starting node is only referenced by this path,
                // all the rest in the path can be referenced by multiple, so we won't return them to the pool here.
                cachedPathNodePool.put(path.startNode);
            }

            freePath(path.hash);
        }

        if (freeMemory)
        {
            cachedPathPool.clear();
            cachedPathNodePool.clear();
        }
    }

    /**
        Updates the configuration of the cache.

        Should only be called after `reset()`.

        @param size The new size of the cache.
    **/
    public inline function configure(size: Int)
    {
        cache = new BubbleList<CachedPath>(size);
    }

    public inline function get_size(): Int
    {
        return cache.capacity;
    }

    function addPath(path: CachedPath)
    {
        // Check if a path already exists with this hash
        if (get(path.hash) != null)
        {
            freePath(path.hash);
        }

        var popped: CachedPath = cache.insert(path);

        if (popped != null)
        {
            // Inserting the given path caused the list to exceed capacity.
            // Thus the last path in order was popped and should be deleted.
            if (popped != path)
                cacheHashMap.remove(popped.hash);

            cachedPathPool.put(popped);
            popped.startNode = null;

            if (popped == path)
            {
                return;
            }
        }

        cacheHashMap[ path.hash ] = path;
    }

    inline function freePath(hash: Int)
    {
        var path: CachedPath = get(hash);

        // Remove from the list and the map.
        cache.remove(path);
        cacheHashMap.remove(hash);

        // Free up memory.
        cachedPathPool.put(path);
        path.startNode = null;
    }

    inline function get(hash: Int): CachedPath
    {
        return cacheHashMap[ hash ];
    }

    public static inline function hash(start: Int, end: Int): Int
    {
        var sum: Int = start + end;
        return ((sum * (sum + 1)) >> 1) + end;
    }
}
