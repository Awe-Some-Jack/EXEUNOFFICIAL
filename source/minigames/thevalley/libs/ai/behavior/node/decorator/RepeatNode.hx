package minigames.thevalley.libs.ai.behavior.node.decorator;

class RepeatNode extends DecoratorNode {
	final times:Int;
	var count:Int = 0;

	public function new(child:Node, times:Int) {
		super(child);
		this.times = times;
	}

	public override function execute():NODE_STATUS {
		if (times <= 0) {
			return NODE_STATUS.SUCCESS;
		}

		final status = child.execute();

		if (status == NODE_STATUS.RUNNING) {
			return NODE_STATUS.RUNNING;
		}

		if (status == NODE_STATUS.FAILURE) {
			count = 0;
			return NODE_STATUS.FAILURE;
		}

		count++;
		if (count >= times) {
			count = 0;
			return NODE_STATUS.SUCCESS;
		}

		return NODE_STATUS.RUNNING;
	}

	public override function halt():Void {
		super.halt();
		count = 0;
	}
}
