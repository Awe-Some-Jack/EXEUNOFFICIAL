package minigames.thevalley.libs.ai.behavior.node.decorator;

class RetryNode extends DecoratorNode {
	final attempts:Int;
	var failures:Int = 0;

	public function new(child:Node, attempts:Int) {
		super(child);
		this.attempts = attempts;
	}

	public override function execute():NODE_STATUS {
		final status = child.execute();

		if (status == NODE_STATUS.SUCCESS) {
			failures = 0;
			return NODE_STATUS.SUCCESS;
		}

		if (status == NODE_STATUS.FAILURE) {
			failures++;
			if (failures >= attempts) {
				failures = 0;
				return NODE_STATUS.FAILURE;
			}
		}

		return NODE_STATUS.RUNNING;
	}

	public override function halt():Void {
		super.halt();
		failures = 0;
	}
}
