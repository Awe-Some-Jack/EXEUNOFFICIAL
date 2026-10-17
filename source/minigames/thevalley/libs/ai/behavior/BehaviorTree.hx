package minigames.thevalley.libs.ai.behavior;

import minigames.thevalley.libs.ai.behavior.node.Node;
import minigames.thevalley.libs.ai.behavior.node.NODE_STATUS;

typedef Blackboard = Map<String, Dynamic>;

class BehaviorTree implements Node {
	public var blackboard(get, never):Blackboard;

	public var status(default, null):NODE_STATUS = FAILURE;

	private var child:Node;
	private var context:Blackboard;

	public function new(root:Node = null) {
		if (root == null) {
			throw "Root cannot be null";
		}

		this.child = root;
	}

	inline function get_blackboard():Blackboard {
		return context;
	}

	public function init(context:Blackboard) {
		if (context == null) {
			context = new Blackboard();
		}

		this.context = context;
		child.init(this.context);
	}

	public function execute():NODE_STATUS {
		status = this.child.execute();
		return status;
	}

	public function tick(elapsed:Float):NODE_STATUS {
		if (context == null) {
			init(null);
		}

		context.set("elapsed", elapsed);
		context.set("time", BlackboardTools.getFloat(context, "time") + elapsed);
		return execute();
	}

	public function halt():Void {
		child.halt();
		status = FAILURE;
	}
}
