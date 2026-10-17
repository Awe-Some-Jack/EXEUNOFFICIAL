package minigames.thevalley.libs.ai.behavior.node.leaf;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;
import minigames.thevalley.libs.ai.behavior.BlackboardTools;

class WaitNode implements Node {
	final seconds:Float;
	var startedAt:Float = -1;
	var context:Blackboard;

	public function new(seconds:Float) {
		this.seconds = seconds;
	}

	public function init(context:Blackboard):Void {
		this.context = context;
	}

	public function execute():NODE_STATUS {
		final time = BlackboardTools.time(context);
		if (startedAt < 0) {
			startedAt = time;
		}

		if (time - startedAt >= seconds) {
			startedAt = -1;
			return NODE_STATUS.SUCCESS;
		}
		return NODE_STATUS.RUNNING;
	}

	public function halt():Void {
		startedAt = -1;
	}
}
