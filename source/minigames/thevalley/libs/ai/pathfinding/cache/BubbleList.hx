package minigames.thevalley.libs.ai.pathfinding.cache;

typedef BubbleLinkedItem<T> =
{
    var next: T;

    var previous: T;
}

/**
    Simple wrapper of a linked list, with the following behavior:

    - New elements are added to the middle of the list.
    - If the list exceeds the specified capacity, the last element is removed.
    - A `bubble()` operation allows to move elements one position forward in the list.

    The intented use is for the cache's priority queue, where elements without cache hits
    will be gradually moved to the end of the list, to be replaced by new additions.
**/
@:generic
class BubbleList<T: BubbleLinkedItem<T>>
{
    public final capacity: Int;
    public var length(default, null): Int;

    var head: T;
    var middle: T;
    var tail: T;

    public inline function new(capacity: Int)
    {
        this.capacity = capacity;
        reset();
    }

    /**
        Inserts an element in the list.

        If the insertion causes the list to exceed its capacity,
        the last element is removed and returned.

        @param elem The element to insert.
        @return An element that was removed so that the list does not exceed
                its capacity, or `null` if the list is not yet at capacity.
    **/
    public inline function insert(elem: T): T
    {
        if (head == null)
        {
            head = elem;
            middle = elem;
            tail = elem;

            elem.next = elem.previous = null;
        }
        else
        {
            if (length % 2 == 1)
            {
                // On odd length, insert before middle.
                insertBetween(middle.previous, middle, elem);
            }
            else
            {
                // On even length, insert after middle.
                insertBetween(middle, middle.next, elem);
            }

            middle = elem;
        }

        length++;

        if (length > capacity)
        {
            // List exceeded capacity, remove the tail element.
            return pop();
        }
        else
        {
            // List not yet at capacity.
            return null;
        }
    }

    /**
        Moves the given element one position closer to the head of the list.

        Has no effect if the element is already the head of the list.

        @param elem The element to bubble.
    **/
    public function bubble(elem: T)
    {
        if (elem == head)
        {
            // Is head, do nothing.
            return;
        }

        // Bubble X
        // Next: A -> B -> X -> C -> ...
        // Prev: A <- B <- X <- C <- ...

        elem.previous.next = elem.next;

        // Next: A -> B -> C -> ...
        // Prev: A <- B <- X <- C <- ...

        if (elem.next == null)
        {
            tail = elem.previous;
        }
        else
        {
            elem.next.previous = elem.previous;
        }

        // Next: A -> B -> C -> ...
        // Prev: A <- B <- C <- ...

        // Now X has effectively been removed.

        insertBetween(elem.previous.previous, elem.previous, elem);

        // Check if we need to update the middle pointer.
        if (elem.next == middle)
        {
            middle = elem;
        }
        else if (elem == middle)
        {
            middle = elem.next;
        }
    }

    /**
        Removes and returns the last element in the list.

        @return The removed element, or `null` if the list is empty.
    **/
    public inline function pop(): T
    {
        if (tail == null)
        {
            return null;
        }
        else
        {
            var elem: T = tail;

            remove(elem);

            return elem;
        }
    }

    /**
        Returns the last element in the list.
    **/
    public inline function last(): T
    {
        return tail;
    }

    /**
        Removes the given element from the list.
    **/
    public inline function remove(elem: T)
    {
        if (head == null)
        {
            throw 'Removing from empty list.';
        }
        else if (tail == head)
        {
            reset();
        }
        else
        {
            length--;

            // Update adjacent elements.
            if (elem.previous != null)
            {
                elem.previous.next = elem.next;
            }
            if (elem.next != null)
            {
                elem.next.previous = elem.previous;
            }

            // Check if we should update the middle pointer.
            if (elem == tail)
            {
                // This is pop() operation behavior.
                if (length % 2 == 0)
                {
                    middle = middle.previous;
                }
            }
            else if (elem == middle)
            {
                // Removing the middle, which is not the tail.
                middle = middle.next;
            }
            else
            {
                if (length % 2 == 0)
                {
                    // On even length, move the middle backwards.
                    middle = middle.previous;
                }
                else
                {
                    // On odd length, move the middle forward.
                    middle = middle.next;
                }
            }

            // Update the head and tail pointers if necessary.
            if (elem == tail)
            {
                tail = elem.previous;
            }
            if (elem == head)
            {
                head = elem.next;
            }
        }

        elem.next = elem.previous = null;
    }

    inline function insertBetween(a: T, b: T, elem: T)
    {
        elem.previous = a;
        if (a != null)
            a.next = elem;

        elem.next = b;
        if (b != null)
            b.previous = elem;

        if (elem.previous == null)
            head = elem;
        if (elem.next == null)
            tail = elem;
    }

    inline function reset()
    {
        length = 0;

        head = null;
        middle = null;
        tail = null;
    }
}
