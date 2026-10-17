package minigames.thevalley.libs.ai.behavior.node.decorator;

class TimeoutNode extends DecoratorNode {
	final seconds:Float;
	var startedAt:Float = -1;

	public function new(child:Node, seconds:Float) {
		super(child);
		this.seconds = seconds;
	}

	public override function execute():NODE_STATUS {
		final time = now();
		if (startedAt < 0) {
			startedAt = time;
		}

		if (time - startedAt >= seconds) {
			child.halt();
			startedAt = -1;
			return NODE_STATUS.FAILURE;
		}

		final status = child.execute();
		if (status != NODE_STATUS.RUNNING) {
			startedAt = -1;
		}
		return status;
	}

	public override function halt():Void {
		super.halt();
		startedAt = -1;
	}
}
