package minigames.thevalley.libs.ai.pathfinding.types;

class PathNodeHeap
{
    var heap: Array<PathNode>;
    var size: Int;

    public inline function new()
    {
        heap = [ ];
        size = 0;
    }

    public inline function isEmpty(): Bool
    {
        return size == 0;
    }

    public inline function getSize(): Int
    {
        return size;
    }

    public function clear()
    {
        for (i in 0...size)
        {
            heap[ i ].heapIndex = -1;
            heap[ i ] = null;
        }
        size = 0;
    }

    public function insert(node: PathNode)
    {
        if (size < heap.length)
            heap[ size ] = node;
        else
            heap.push(node);

        node.heapIndex = size;
        size++;

        siftUp(node.heapIndex);
    }

    public function popNext(): PathNode
    {
        if (size == 0)
            return null;

        var top: PathNode = heap[ 0 ];

        size--;
        if (size > 0)
        {
            var last: PathNode = heap[ size ];
            heap[ 0 ] = last;
            last.heapIndex = 0;
            siftDown(0);
        }
        heap[ size ] = null;

        top.heapIndex = -1;
        return top;
    }

    public inline function update(node: PathNode)
    {
        siftUp(node.heapIndex);
    }

    public function remove(node: PathNode)
    {
        var i: Int = node.heapIndex;
        if (i < 0 || i >= size || heap[ i ] != node)
            return;

        size--;
        if (i != size)
        {
            var last: PathNode = heap[ size ];
            heap[ i ] = last;
            last.heapIndex = i;

            siftUp(i);
            siftDown(last.heapIndex);
        }
        heap[ size ] = null;

        node.heapIndex = -1;
    }

    inline function less(a: PathNode, b: PathNode): Bool
    {
        var fa: Float = a.totalCost;
        var fb: Float = b.totalCost;
        return fa < fb || (fa == fb && a.estimatedCostToGoal < b.estimatedCostToGoal);
    }

    function siftUp(i: Int)
    {
        var node: PathNode = heap[ i ];

        while (i > 0)
        {
            var parentIndex: Int = (i - 1) >> 1;
            var parent: PathNode = heap[ parentIndex ];

            if (!less(node, parent))
                break;

            heap[ i ] = parent;
            parent.heapIndex = i;
            i = parentIndex;
        }

        heap[ i ] = node;
        node.heapIndex = i;
    }

    function siftDown(i: Int)
    {
        var node: PathNode = heap[ i ];
        var half: Int = size >> 1;

        while (i < half)
        {
            var child: Int = (i << 1) + 1;
            var right: Int = child + 1;

            if (right < size && less(heap[ right ], heap[ child ]))
                child = right;

            if (!less(heap[ child ], node))
                break;

            heap[ i ] = heap[ child ];
            heap[ i ].heapIndex = i;
            i = child;
        }

        heap[ i ] = node;
        node.heapIndex = i;
    }

    #if UNIT_TEST
    @:noCompletion
    public function validate(): String
    {
        for (i in 0...size)
        {
            if (heap[ i ].heapIndex != i)
                return 'Node at $i has heapIndex ${heap[ i ].heapIndex}';

            var child: Int = (i << 1) + 1;
            for (c in [ child, child + 1 ])
                if (c < size && less(heap[ c ], heap[ i ]))
                    return 'Child $c is smaller than parent $i';
        }
        return "";
    }
    #end
}
