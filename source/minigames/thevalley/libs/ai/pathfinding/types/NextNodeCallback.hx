package minigames.thevalley.libs.ai.pathfinding.types;

/**
 * Callback that should be used to add new nodes to the exploration queue.
 *
 * @param nextNode the state identifier of the next node
 * @param cost the real cost of transitioning to the `nextNode`
 * @param transition optional transition identifier;
 *                   specify this if when going through the solution it is also necessary to track
 *                   which transition was used to get to each node in the graph
 */
typedef NextNodeCallback = (nextNode: Int, cost: Float, ?transitionId: Int) -> Void;
