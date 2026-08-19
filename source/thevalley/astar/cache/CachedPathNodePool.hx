package thevalley.astar.cache;

import thevalley.astar.types.Pool;


class CachedPathNodePool extends Pool<CachedPathNode>
{
    public inline function new()
    {
        super();
    }

    public inline function getCachedPathNode(state: Int, transition: Null<Int>, next: CachedPathNode, costToEnd: Float): CachedPathNode
    {
        var node: CachedPathNode = get();
        node.state = state;
        node.transition = transition;
        node.costToEnd = costToEnd;
        node.next = next;
        return node;
    }

    override inline function create(): CachedPathNode
    {
        return new CachedPathNode();
    }
}
