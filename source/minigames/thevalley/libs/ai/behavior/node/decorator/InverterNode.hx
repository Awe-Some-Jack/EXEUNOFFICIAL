package minigames.thevalley.libs.ai.behavior.node.decorator;

class InverterNode extends DecoratorNode {
	public function new(child:Node) {
		super(child);
	}

	public override function execute():NODE_STATUS {
		return switch (child.execute()) {
			case NODE_STATUS.SUCCESS: NODE_STATUS.FAILURE;
			case NODE_STATUS.FAILURE: NODE_STATUS.SUCCESS;
			case _: NODE_STATUS.RUNNING;
		}
	}
}
