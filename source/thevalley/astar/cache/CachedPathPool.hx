package thevalley.astar.cache;

import thevalley.astar.types.Pool;


class CachedPathPool extends Pool<CachedPath>
{
    public inline function new()
    {
        super();
    }

    public inline function getSolvedCachedPath(start: CachedPathNode, end: CachedPathNode, hash: Int): CachedPath
    {
        var path: CachedPath = get();
        path.start = start.state;
        path.end = end.state;
        path.startNode = start;
        path.hash = hash;
        return path;
    }

    public inline function getNoSolutionCachedPath(start: Int, end: Int, hash: Int): CachedPath
    {
        var path: CachedPath = get();
        path.start = start;
        path.end = end;
        path.startNode = null;
        path.hash = hash;
        return path;
    }

    override inline function create(): CachedPath
    {
        return new CachedPath();
    }
}
