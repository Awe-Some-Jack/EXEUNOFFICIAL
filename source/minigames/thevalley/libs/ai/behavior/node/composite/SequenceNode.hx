package minigames.thevalley.libs.ai.behavior.node.composite;

class SequenceNode extends CompositeNode {
	public function new(children:Array<Node>) {
		super(children);
	}

	public override function execute():NODE_STATUS {
		while (current < children.length) {
			final status = children[current].execute();

			if (status == NODE_STATUS.RUNNING) {
				return NODE_STATUS.RUNNING;
			}

			if (status == NODE_STATUS.FAILURE) {
				current = 0;
				return NODE_STATUS.FAILURE;
			}

			current++;
		}

		current = 0;
		return NODE_STATUS.SUCCESS;
	}
}
