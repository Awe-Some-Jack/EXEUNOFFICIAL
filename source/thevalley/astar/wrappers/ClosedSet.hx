package thevalley.astar.wrappers;

import thevalley.astar.types.PathNode;
import thevalley.astar.types.PathNodePool;

/**
    Wrapper over a 2D node array for marking cells that have been checked on the grid.
**/
abstract ClosedSet(Map<Int, PathNode>)
{
    public inline function new()
    {
        this = [ ];
    }

    /**
     * Adds a node to the closed set, marking its coordinates as checked.
     */
    public inline function addNode(node: PathNode)
    {
        this.set(node.state, node);
    }

    /**
     * Checks if the coordinates of a node already exist in the set,
     * indicating that it has already been checked.
     */
    public inline function contains(state: Int): Bool
    {
        return this.exists(state);
    }

    /**
     * Checks it a node has already been visited at the given coordinates.
     */
    public inline function isVisited(state: Int): Bool
    {
        return this.exists(state) && this[ state ].visited;
    }

    /**
     * Returns an existing node in the set at the given coordinates.
     */
    @:op([ ])
    public inline function get(state: Int): PathNode
    {
        return this[ state ];
    }

    /**
     * Clears the underlying 2D array, setting all elements to `null`.
     *
     * Any existing nodes that are not cached will be returned to the
     * specified pool.
     */
    public inline function clear(?pool: PathNodePool)
    {
        // create a separate array with all states, to avoid touching the map during iteration
        var states: Array<Int> = [ ];
        for (state in this.keys())
        {
            states.push(state);
        }

        for (state in states)
        {
            remove(state, pool);
        }
    }

    /**
     * Clears a specific position in the underlying 2D array.
     * If a node exists in that position, and it is not cached,
     * it will be returned to the specified pool.
     */
    public inline function remove(state: Int, ?pool: PathNodePool)
    {
        var node: PathNode = this[ state ];
        this.remove(state);
        if (pool != null)
        {
            pool.put(node);
        }
    }
}
