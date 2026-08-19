package thevalley.astar.types;

typedef PathPoint =
{
    /**
     * The state identifier of the node.
     */
    var state: Int;

    /**
     * The total cost from the beginning of the path to this point.
     */
    var costFromStart: Float;
}
