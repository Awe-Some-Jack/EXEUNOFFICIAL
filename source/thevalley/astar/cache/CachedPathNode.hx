package thevalley.astar.cache;

@:publicFields
class CachedPathNode
{
    /** The state identifier of the node. **/
    var state: Int;

    /** The id of the transition used to get to this node. **/
    var transition: Int;

    /** The exact cost from this node to the end of the path. **/
    var costToEnd: Float;

    /** Used both for pooling and reconstructing the path. **/
    var next: CachedPathNode;

    @:allow(thevalley.astar.cache.CachedPathNodePool)
    private function new()
    {
        reset();
    }

    inline function reset()
    {
        next = null;
    }
}
