package minigames.thevalley.libs.ai.pathfinding.cache;

import minigames.thevalley.libs.ai.pathfinding.types.Pool;

class CachedPathPool extends Pool<CachedPath>
{
    public inline function new()
    {
        super();
    }

    public inline function getSolvedCachedPath(start: CachedPathNode, end: Int, hash: Int): CachedPath
    {
        var path: CachedPath = get();
        path.start = start.state;
        path.end = end;
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
