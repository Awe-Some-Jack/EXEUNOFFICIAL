package thevalley.dropecho.behavior_tree.node;

import thevalley.dropecho.behavior_tree.BehaviorTree.Blackboard;
import thevalley.dropecho.behavior_tree.node.NODE_STATUS;

interface Node {
	public function init(context:Blackboard):Void;
	public function execute():NODE_STATUS;
}
