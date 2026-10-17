package minigames.thevalley.libs.ai.behavior.node.decorator;

class FailerNode extends DecoratorNode {
	public function new(child:Node) {
		super(child);
	}

	public override function execute():NODE_STATUS {
		return child.execute() == NODE_STATUS.RUNNING ? NODE_STATUS.RUNNING : NODE_STATUS.FAILURE;
	}
}
