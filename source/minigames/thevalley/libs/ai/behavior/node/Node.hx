package minigames.thevalley.libs.ai.behavior.node;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;
import minigames.thevalley.libs.ai.behavior.node.NODE_STATUS;

interface Node {
	public function init(context:Blackboard):Void;

	public function execute():NODE_STATUS;

	public function halt():Void;
}
