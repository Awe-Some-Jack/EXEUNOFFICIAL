package minigames.thevalley.libs.ai.behavior.node.decorator;

class RepeatUntilNode extends DecoratorNode {
	final until:NODE_STATUS;

	public function new(child:Node, until:NODE_STATUS = NODE_STATUS.FAILURE) {
		super(child);
		this.until = until;
	}

	public override function execute():NODE_STATUS {
		return child.execute() == until ? NODE_STATUS.SUCCESS : NODE_STATUS.RUNNING;
	}
}
