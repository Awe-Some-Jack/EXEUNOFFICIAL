package minigames.thevalley.libs.ai.behavior.node.composite;

class ReactiveSequenceNode extends CompositeNode {
	var running:Int = -1;

	public function new(children:Array<Node>) {
		super(children);
	}

	public override function execute():NODE_STATUS {
		for (i in 0...children.length) {
			final status = children[i].execute();

			if (status == NODE_STATUS.SUCCESS) {
				continue;
			}

			if (running > i) {
				children[running].halt();
			}
			running = status == NODE_STATUS.RUNNING ? i : -1;
			return status;
		}

		running = -1;
		return NODE_STATUS.SUCCESS;
	}

	public override function halt():Void {
		super.halt();
		running = -1;
	}
}
