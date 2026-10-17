package minigames.thevalley.libs.ai.behavior.node.composite;

import minigames.thevalley.libs.ai.behavior.node.Node;

class SelectorNode extends CompositeNode {
	public function new(children:Array<Node>) {
		super(children);
	}

	public override function execute():NODE_STATUS {
		while (current < children.length) {
			final status = children[current].execute();

			if (status == NODE_STATUS.RUNNING) {
				return NODE_STATUS.RUNNING;
			}

			if (status == NODE_STATUS.SUCCESS) {
				current = 0;
				return NODE_STATUS.SUCCESS;
			}

			current++;
		}

		current = 0;
		return NODE_STATUS.FAILURE;
	}
}
