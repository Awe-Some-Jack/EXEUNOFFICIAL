package minigames.thevalley.libs.ai.pathfinding.wrappers;

import haxe.ds.IntMap;
import minigames.thevalley.libs.ai.pathfinding.types.PathNode;
import minigames.thevalley.libs.ai.pathfinding.types.PathNodePool;

class ClosedSet
{
    var map: IntMap<PathNode>;
    var nodes: Array<PathNode>;
    var count: Int;

    public inline function new()
    {
        map = new IntMap();
        nodes = [ ];
        count = 0;
    }

    public inline function addNode(node: PathNode)
    {
        map.set(node.state, node);

        if (count < nodes.length)
            nodes[ count ] = node;
        else
            nodes.push(node);
        count++;
    }

    public inline function contains(state: Int): Bool
    {
        return map.exists(state);
    }

    public inline function isVisited(state: Int): Bool
    {
        var node: PathNode = map.get(state);
        return node != null && node.visited;
    }

    public inline function get(state: Int): PathNode
    {
        return map.get(state);
    }

    public inline function nodeAt(i: Int): PathNode
    {
        return nodes[ i ];
    }

    public inline function getSize(): Int
    {
        return count;
    }

    public function clear(?pool: PathNodePool)
    {
        for (i in 0...count)
        {
            if (pool != null)
                pool.put(nodes[ i ]);
            nodes[ i ] = null;
        }
        count = 0;
        map.clear();
    }
}
