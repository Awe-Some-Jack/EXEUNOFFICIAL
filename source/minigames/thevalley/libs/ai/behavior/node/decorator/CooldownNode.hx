package minigames.thevalley.libs.ai.behavior.node.decorator;

class CooldownNode extends DecoratorNode {
	final seconds:Float;
	var readyAt:Float = Math.NEGATIVE_INFINITY;

	public function new(child:Node, seconds:Float) {
		super(child);
		this.seconds = seconds;
	}

	public override function execute():NODE_STATUS {
		final time = now();
		if (time < readyAt) {
			return NODE_STATUS.FAILURE;
		}

		final status = child.execute();
		if (status != NODE_STATUS.RUNNING) {
			readyAt = time + seconds;
		}
		return status;
	}

	public function resetCooldown():Void {
		readyAt = Math.NEGATIVE_INFINITY;
	}
}
