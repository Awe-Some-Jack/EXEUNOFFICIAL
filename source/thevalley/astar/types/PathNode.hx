package thevalley.astar.types;

@:publicFields
class PathNode
{
    /** The node state identifier on the graph. **/
    var state: Int;

    /** The id of the transition used to get to this node. Will default to `0` if the user doesn't specify transitions. **/
    var transition: Int;

    /** Known cost from start. **/
    var costFromStart: Float;

    /** Heuristic estimation for the cost to the goal. **/
    var estimatedCostToGoal: Float;

    /** Total cost of the node, the sum of the cost from the start and the estimated cost to the goal. **/
    var totalCost(get, never): Float;

    /** The previous node, used to reconstruct the path. **/
    var previous: PathNode;

    /** Indicates whether this node has already been visited during search. Visited nodes are not checked again. **/
    var visited: Bool;

    // =====================================================
    //          POOLING
    // =====================================================

    /** For pooling in a linked list. **/
    var next: PathNode;

    // =====================================================
    //          BINARY SEARCH
    // =====================================================

    /** Left child for binary-tree sorting. **/
    var left: PathNode;

    /** Right child for binary-tree sorting. **/
    var right: PathNode;

    /** Parent in the binary-tree. **/
    var parent: PathNode;

    @:allow(thevalley.astar.types.PathNodePool)
    private function new()
    {
        reset();
    }

    inline function reset()
    {
        state = 0;
        transition = 0;
        visited = false;
        next = left = right = parent = null;
    }

    /**
        Returns the exact cost of moving from the previous node in the path to this one.
    **/
    inline function getCostFromPrevious(): Float
    {
        // Note: not having a previous node and calling this function should be a logical error.
        return costFromStart - previous.costFromStart;
    }

    inline function get_totalCost(): Float
    {
        return costFromStart + estimatedCostToGoal;
    }
}
