package minigames.thevalley.libs.ai.behavior.node.leaf;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;

class ActionNode implements Node {
	final action:Blackboard->NODE_STATUS;
	final onHalt:Null<Void->Void>;
	var context:Blackboard;

	public function new(action:Blackboard->NODE_STATUS, ?onHalt:Void->Void) {
		this.action = action;
		this.onHalt = onHalt;
	}

	public function init(context:Blackboard):Void {
		this.context = context;
	}

	public function execute():NODE_STATUS {
		return action(context);
	}

	public function halt():Void {
		if (onHalt != null) {
			onHalt();
		}
	}
}
