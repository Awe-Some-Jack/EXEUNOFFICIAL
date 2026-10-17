package minigames.thevalley.libs.ai.pathfinding;

import minigames.thevalley.libs.ai.pathfinding.cache.CachedPathNode;
import minigames.thevalley.libs.ai.pathfinding.types.PathNode;
import minigames.thevalley.libs.ai.pathfinding.types.Result;

@:allow(minigames.thevalley.libs.ai.pathfinding.Astar)
@:allow(minigames.thevalley.libs.ai.pathfinding.cache.PathCache)
class SearchResult
{
    /**
        Value indicating whether the search was successful.
        It is recommended to check this field before using `path`.
    **/
    public var result(default, null): Result = None;

    public var partialReason(default, null): Result = None;

    /**
        The total exact (non-heuristic) cost of the path.
    **/
    public var cost(default, null): Float = 0;

    public var expanded(default, null): Int = 0;

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

    public var isSolved(get, never): Bool;

    public var hasPath(get, never): Bool;

    public var length(get, never): Int;

    private function new()
    {
    }

    inline function get_isSolved(): Bool
    {
        return result == Solved;
    }

    inline function get_hasPath(): Bool
    {
        return (result == Solved || result == Partial) && path != null && path.length > 0;
    }

    inline function get_length(): Int
    {
        return path == null ? 0 : path.length;
    }

    public inline function lastState(): Int
    {
        return path[ path.length - 1 ];
    }

    public function toString(): String
    {
        return 'SearchResult(${result.toString()}, cost: $cost, length: $length, expanded: $expanded)';
    }

    private function setResultPath(node: PathNode)
    {
        result = Solved;

        cost += node.costFromStart;

        if (path != null)
        {
            // cache was already added
            // the first node in the cached path, coincides with the last node
            // of the calculated path
            // so skip it here to avoid adding it twice
            transitions[ 0 ] = node.transition;
            node = node.previous;
        }

        var states: Array<Int> = [ ];
        var trans: Array<Int> = [ ];

        while (node != null)
        {
            states.push(node.state);
            trans.push(node.transition);

            node = node.previous;
        }

        states.reverse();
        trans.reverse();

        if (path == null)
        {
            path = states;
            transitions = trans;
        }
        else
        {
            path = states.concat(path);
            transitions = trans.concat(transitions);
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
