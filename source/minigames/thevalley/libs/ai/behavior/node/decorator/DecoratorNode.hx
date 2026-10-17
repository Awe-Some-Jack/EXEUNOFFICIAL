package minigames.thevalley.libs.ai.behavior.node.decorator;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;
import minigames.thevalley.libs.ai.behavior.BlackboardTools;

class DecoratorNode implements Node {
	private var child:Node;
	private var context:Blackboard;

	public function new(child:Node) {
		if (child == null) {
			throw "Decorator child cannot be null";
		}

		this.child = child;
	}

	public function init(context:Blackboard) {
		this.context = context;
		this.child.init(context);
	}

	public function execute():NODE_STATUS {
		return NODE_STATUS.FAILURE;
	}

	public function halt():Void {
		child.halt();
	}

	inline function now():Float {
		return BlackboardTools.time(context);
	}
}
