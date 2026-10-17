package minigames.thevalley.libs.ai.pathfinding.types;

@:generic
typedef LinkedItem<T> =
{
    var next: T;

    function reset(): Void;
}

@:generic
class Pool<T: LinkedItem<T>>
{
    var head: T;
    var size: Int;

    inline function new()
    {
        head = null;
        size = 0;
    }

    /**
        Instantiates a new path node or recycles one from the pool.

        @return The path node.
    **/
    public inline function get(): T
    {
        if (head == null)
        {
            return create();
        }

        var node: T = head;

        head = head.next;
        node.next = null;

        size--;

        node.reset();

        return node;
    }

    /**
        Frees a path node and returns it to the pool for recycling.

        @param node The node to return to the pool. Do **not** use it again after calling this.
    **/
    public inline function put(node: T)
    {
        node.next = head;
        head = node;

        size++;
    }

    /**
        Fills the pool with a specified amount of objects.

        @param amount The amount of objects to create in the pool.
    **/
    public inline function fill(amount: Int)
    {
        for (i in 0...amount)
        {
            put(create());
        }
    }

    /**
        Gets the amount of objects currently in the pool.

        @return The amount of pooled objects.
    **/
    public inline function getSize(): Int
    {
        return size;
    }

    /**
        Empties the pool, leaving all currently pooled objects for the garbage collector.
    **/
    public inline function clear()
    {
        head = null;
        size = 0;
    }

    @IgnoreCover
    function create(): T
    {
        throw "Using abstract pool create()";
    }
}
