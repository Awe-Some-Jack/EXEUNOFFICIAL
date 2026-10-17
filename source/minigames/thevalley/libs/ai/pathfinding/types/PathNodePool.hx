package minigames.thevalley.libs.ai.pathfinding.types;

class PathNodePool extends Pool<PathNode>
{
    public inline function new()
    {
        super();
    }

    public inline function getNode(state: Int, transition: Int, costFromStart: Float, costToGoal: Float, ?previous: PathNode): PathNode
    {
        var node: PathNode = get();
        node.state = state;
        node.transition = transition;
        node.costFromStart = costFromStart;
        node.estimatedCostToGoal = costToGoal;
        node.previous = previous;
        return node;
    }

    override inline function create(): PathNode
    {
        return new PathNode();
    }
}
