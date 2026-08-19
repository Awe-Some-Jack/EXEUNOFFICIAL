package thevalley.astar.types;

class SortedPathNodeList
{
    /** Binary tree root. **/
    var root: PathNode;

    /** Points to the leftmost leaf in the tree, which has the smallest cost. **/
    var min: PathNode;

    /** The amount of nodes currently in the list. **/
    var size: Int;

    public inline function new()
    {
        clear();
    }

    /**
        Returns `true` if the list is empty.
    **/
    public inline function isEmpty(): Bool
    {
        return getSize() == 0;
    }

    /**
        Clears the binary tree, returning all objects to a pool.
    **/
    public inline function clear(?pool: PathNodePool)
    {
        if (pool != null)
            clearIntoPoolRecursive(root, pool);

        root = null;
        min = null;
        size = 0;
    }

    /**
        Inserts a node into the sorted list. Nodes are sorted according to `totalCost`.

        @param node The node to insert.
    **/
    public function insert(node: PathNode)
    {
        size++;

        node.left = node.right = node.parent = null;

        if (root == null)
        {
            root = node;
            min = node;
            return;
        }

        var iter: PathNode = root;

        while (iter != node)
        {
            /**
                The equals case is deliberately allowed to go left.

                This could make the tree a bit more skewed, and traversing the left side
                could take longer, but since we are keeping a reference to the min at all
                times, this should hopefully be minimal.

                If all ties end on the leftmost side, then traversing them should just go
                from parent to parent and overall be faster.

                This way we are also treating ties that are added as better and pushing
                them to the front of the open list, which is a well-known general improvement to A*
                since prioritizing newer nodes sometimes helps narrow down the area that is searched.
            **/


            if (node.totalCost > iter.totalCost)
            {
                // Go right
                if (iter.right == null)
                {
                    addRight(iter, node);
                    node.left = node.right = null;
                }

                iter = iter.right;
            }
            else
            {
                // Go left
                if (iter.left == null)
                {
                    addLeft(iter, node);
                    node.left = node.right = null;

                    if (iter == min)
                    {
                        min = node;
                    }
                }

                iter = iter.left;
            }
        }
    }

    /**
        Removes and returns the first node in the list, i.e the one with the smallest `totalCost`.
    **/
    public function popNext(): PathNode
    {
        if (min == null)
        {
            return null;
        }

        size--;

        var node: PathNode = min;

        if (node == root)
        {
            root = node.right;
            if (root != null)
            {
                root.parent = null;
            }

            findMin(node.right);
        }
        else if (node.right != null)
        {
            addLeft(node.parent, node.right);

            findMin(node.right);
        }
        else
        {
            min = min.parent;
            min.left = null;
        }

        node.left = node.right = node.parent = null;

        return node;
    }

    /**
        Removes a node from the binary tree.

        Removing a node with two children is a recursive operation.

        @param node The node to remove.
    **/
    public function remove(node: PathNode)
    {
        if (root == null)
        {
            throw 'Cannot delete from an empty tree.';
        }

        if (node.parent == null && node.left == null && node.right == null)
        {
            if (node == root)
            {
                clear();
                return;
            }
            else
            {
                throw 'Attempting to remove node not present in the tree?';
            }
        }

        if (node.left == null && node.right == null)
        {
            // No children, simply remove from its parent.
            if (node == min)
            {
                min = node.parent;
            }

            removeFromParent(node);
        }
        else if (node.left == null)
        {
            // One child on the right.
            if (node == min)
            {
                min = getInOrderSuccessorOf(node);
            }

            reparentNode(node.right, node);
        }
        else if (node.right == null)
        {
            // One child on the left.
            reparentNode(node.left, node);

            // The node is not min if it has left children.
        }
        else if (node.right.left == null)
        {
            // Two children.
            // Special case, the right subtree has no left part.
            var successor: PathNode = node.right;

            // Delete successor.
            node.right = successor.right;

            // Replace this node with the successor.
            replaceNode(successor, node);
        }
        else
        {
            // Two children.
            // Replace the node with the inorder successor.
            // (i.e the smallest node on the right subtree)
            var successor: PathNode = getInOrderSuccessorOf(node);
            var successorParent: PathNode = successor.parent;

            // Since successor is always left child of its parent
            // we can safely make successor's right child as left of its parent.
            successorParent.left = successor.right;
            if (successor.right != null)
            {
                // Fix the parent pointer.
                successor.right.parent = successorParent;
            }

            // Replace this node with the successor.
            replaceNode(successor, node);
        }

        node.left = node.right = node.parent = null;

        size--;
    }

    /**
        Returns the number of nodes in the tree.
    **/
    public inline function getSize(): Int
    {
        #if UNIT_TEST
        var countSize: Int = getSizeRecursive(root, [ ]);
        // if (countSize != size) throw 'SortedPathNodeList wrong size: var: $size, actual: $countSize';
        return countSize;
        #else
        return size;
        #end
    }

    /**
        Moves a node (along with its children) to a new position in the tree.

        It updates `src`'s parent to point to `dst`'s parent.

        The `dst` node is removed from the tree.

        @param src The node to move to the position of `dst`.
        @param dst The destination node, the position of which will be overtaken by `src`.
    **/
    inline function reparentNode(src: PathNode, dst: PathNode)
    {
        // Remove src from current parent
        removeFromParent(src);

        // Move src to new parent
        src.parent = dst.parent;

        // Update new parent to point to src
        if (dst.parent == null)
        {
            // dst is root
            root = src;
        }
        else if (dst == dst.parent.left)
        {
            // src is the left child
            src.parent.left = src;
        }
        else
        {
            // src is the right child
            src.parent.right = src;
        }

        dst.parent = null;
    }

    /**
        Fully replaces one node with another, preserving the old one's children.

        To call this method, `src` must not have children, or their `parent` pointer
        must be updated separately.

        @param src The source node, the position of which will be overtaken by `dst`.
        @param dst The node to replace `src` with.
    **/
    inline function replaceNode(src: PathNode, dst: PathNode)
    {
        reparentNode(src, dst);

        src.left = dst.left;
        src.right = dst.right;

        if (src.left != null)
            src.left.parent = src;
        if (src.right != null)
            src.right.parent = src;

        dst.left = dst.right = null;

        if (dst == min)
        {
            min = src;
        }
        if (dst == root)
        {
            root = src;
        }
    }

    function clearIntoPoolRecursive(node: PathNode, pool: PathNodePool)
    {
        if (node.left != null)
            clearIntoPoolRecursive(node.left, pool);
        if (node.right != null)
            clearIntoPoolRecursive(node.right, pool);

        pool.put(node);
    }

    inline function findMin(startingNode: PathNode)
    {
        var iter: PathNode = startingNode;

        while (iter != null && iter.left != null)
        {
            iter = iter.left;
        }

        min = iter;
    }

    inline function addLeft(parent: PathNode, node: PathNode)
    {
        node.parent = parent;
        parent.left = node;
    }

    inline function addRight(parent: PathNode, node: PathNode)
    {
        node.parent = parent;
        parent.right = node;
    }

    /**
        Gets the in-order successor of a given node, which is the leftmost
        node of its right subtree.
    **/
    inline function getInOrderSuccessorOf(node: PathNode): PathNode
    {
        /**
            We don't check if node.right is null because if we are looking for a node's
            successor it means that we know it has two children.

            So this should better throw an error cause it will mean a logical problem.
        **/


        node = node.right;

        while (node.left != null)
            node = node.left;

        return node;
    }

    /**
     * Removes a node from its parent, while preserving its children.
     */
    inline function removeFromParent(node: PathNode)
    {
        if (node.parent != null)
        {
            if (node.parent.left == node)
            {
                node.parent.left = null;
            }
            else if (node.parent.right == node)
            {
                node.parent.right = null;
            }

            node.parent = null;
        }
        else
        {
            // Node is root.
            root = null;
        }
    }

    #if UNIT_TEST
    @IgnoreCover
    function getSizeRecursive(node: PathNode, visited: Array<PathNode>): Int
    {
        if (node == null)
            return 0;

        if (visited.indexOf(node) > -1)
            throw 'getSizeRecursive() infinite.';

        visited.push(node);

        return 1 + getSizeRecursive(node.left, visited) + getSizeRecursive(node.right, visited);
    }

    @IgnoreCover
    function forEach(cb: (n: PathNode) -> Void, ?node: PathNode)
    {
        if (node == null)
            return;

        forEach(cb, node.left);

        cb(node);

        forEach(cb, node.right);
    }

    @IgnoreCover
    function visualize(): String
    {
        var buf: StringBuf = new StringBuf();
        visualizeRecursive(root, buf, "");
        return buf.toString();
    }

    @IgnoreCover
    function visualizeRecursive(node: PathNode, buf: StringBuf, indent: String)
    {
        if (node == null)
            return;

        buf.add(' ${node.totalCost}\n');

        if (node.right != null)
        {
            buf.add('${indent}R  ');

            visualizeRecursive(node.right, buf, indent + "  ");
        }
        if (node.left != null)
        {
            buf.add('${indent}L  ');

            visualizeRecursive(node.left, buf, indent + "  ");
        }
    }

    @IgnoreCover
    function validateTree(node: PathNode = null): String
    {
        if (node == null && root == null)
            return "";
        if (node == null)
            node = root;

        if (node.right != null)
        {
            if (node.right.parent != node)
                return 'Right node wrong parent: ${node.totalCost} -> ${node.right.totalCost}';

            var res: String = validateTree(node.right);

            if (res != "")
                return res;
        }
        if (node.left != null)
        {
            if (node.left.parent != node)
                return 'Left node wrong parent: ${node.totalCost} -> ${node.left.totalCost}';

            var res: String = validateTree(node.left);

            if (res != "")
                return res;
        }

        return "";
    }
    #end
}
