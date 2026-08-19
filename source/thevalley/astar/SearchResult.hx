package thevalley.astar;

import thevalley.astar.cache.CachedPathNode;
import thevalley.astar.types.PathNode;
import thevalley.astar.types.Result;


@:allow(thevalley.astar.Astar)
@:allow(thevalley.astar.cache.PathCache)
class SearchResult
{
    /**
        Value indicating whether the search was successful.
        It is recommended to check this field before using `path`.
    **/
    public var result(default, null): Result = None;

    /**
        The total exact (non-heuristic) cost of the path.
    **/
    public var cost(default, null): Float = 0;

    /**
     * The solution's path, as an ordered list of states.
     *
     * Check the `result` before using.
     */
    public var path(default, null): Array<Int> = null;

    /**
     * The solution's path transitions, as an ordered list of transition identifiers.
     *
     * This is only relevant when the callback of `Graph.getNextNodes` was also specifying transition ids.
     *
     * In this array, `transitions[i]` is the transition id used to **enter** the node at `path[i]`.
     *
     * Check the `result` before using.
     */
    public var transitions(default, null): Array<Int> = null;

    private function new()
    {
    }

    /**
     * Loads the found path by backtracking from the given end node.
     *
     * All nodes, iterated backwards, are each time prepended to the
     * beginning of the path.
     *
     * @param node The final node in the path.
     */
    private function setResultPath(node: PathNode)
    {
        result = Solved;

        cost += node.costFromStart;

        if (path == null)
        {
            path = [ ];
            transitions = [ ];
        }
        else
        {
            // cache was already added
            // the first node in the cached path, coincides with the last node
            // of the calculated path
            // so skip it here to avoid adding it twice
            node = node.previous;
        }

        while (node != null)
        {
            // insert at the beginning since we are iterating backwards
            path.insert(0, node.state);
            transitions.insert(0, node.transition);

            node = node.previous;
        }
    }

    /**
     * Appends a linked list of cached path nodes to the end of the search result's path..
     *
     * Meant to be called before `setResultPath()` when it is found that the remainder
     * of the path exists in the cache.
     */
    private function appendCachedNodes(node: CachedPathNode)
    {
        if (path == null)
        {
            path = [ ];
            transitions = [ ];
        }

        cost += node.costToEnd;

        while (node != null)
        {
            path.push(node.state);
            transitions.push(node.transition);

            node = node.next;
        }
    }
}
