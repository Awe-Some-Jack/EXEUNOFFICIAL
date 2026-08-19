package thevalley.astar.cache;

@:publicFields
class CachedPath
{
    /** The state identifier of the starting node. **/
    var start: Int;

    /** The state identifier of the end node. **/
    var end: Int;

    /** The end node. **/
    var startNode: CachedPathNode;

    /** Next linked object for pooling and bubble-sorting. **/
    var next: CachedPath;

    /** Previous linked object for bubble-sorting. **/
    var previous: CachedPath;

    /** Hash number identifying the start-end pair. **/
    var hash: Int;

    @:allow(thevalley.astar.cache.CachedPathPool)
    private function new()
    {
        reset();
    }

    function reset()
    {
        startNode = null;
        hash = 0;
    }

    inline function matches(start: Int, end: Int): Bool
    {
        return this.start == start && this.end == end;
    }

    inline function hasSolution(): Bool
    {
        return startNode != null;
    }
}
