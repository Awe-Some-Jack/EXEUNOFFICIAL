package minigames.thevalley.libs.ai.behavior.node.composite;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;

class CompositeNode implements Node {
	private var children:Array<Node>;
	private var current:Int = 0;
	private var context:Blackboard;

	public function new(children:Array<Node>) {
		this.children = children != null ? children : [];
	}

	public function init(context:Blackboard) {
		this.context = context;

		for (child in children) {
			child.init(context);
		}
	}

	public function execute():NODE_STATUS {
		return NODE_STATUS.FAILURE;
	}

	public function halt():Void {
		haltChildren(0);
		current = 0;
	}

	function haltChildren(from:Int):Void {
		for (i in from...children.length) {
			children[i].halt();
		}
	}
}
