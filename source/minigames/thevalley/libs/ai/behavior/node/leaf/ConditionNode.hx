package minigames.thevalley.libs.ai.behavior.node.leaf;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;

class ConditionNode implements Node {
	final condition:Blackboard->Bool;
	var context:Blackboard;

	public function new(condition:Blackboard->Bool) {
		this.condition = condition;
	}

	public function init(context:Blackboard):Void {
		this.context = context;
	}

	public function execute():NODE_STATUS {
		return condition(context) ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE;
	}

	public function halt():Void {}
}
