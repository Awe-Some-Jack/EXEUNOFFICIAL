package minigames.thevalley.libs.ai.behavior.node.composite;

class ParallelNode extends CompositeNode {
	final successThreshold:Int;
	final failureThreshold:Int;
	var results:Array<NODE_STATUS>;

	public function new(children:Array<Node>, successThreshold:Int = -1, failureThreshold:Int = -1) {
		super(children);
		this.successThreshold = successThreshold;
		this.failureThreshold = failureThreshold;
		results = [for (_ in this.children) NODE_STATUS.RUNNING];
	}

	public override function execute():NODE_STATUS {
		final n = children.length;
		final needSuccess = successThreshold < 0 ? n : (successThreshold > n ? n : successThreshold);
		var successes = 0;
		var failures = 0;

		for (i in 0...n) {
			var status = results[i];
			if (status == NODE_STATUS.RUNNING) {
				status = children[i].execute();
				results[i] = status;
			}

			if (status == NODE_STATUS.SUCCESS) {
				successes++;
			} else if (status == NODE_STATUS.FAILURE) {
				failures++;
			}
		}

		if (successes >= needSuccess) {
			finish();
			return NODE_STATUS.SUCCESS;
		}

		if ((failureThreshold > 0 && failures >= failureThreshold) || failures > n - needSuccess) {
			finish();
			return NODE_STATUS.FAILURE;
		}

		return NODE_STATUS.RUNNING;
	}

	public override function halt():Void {
		super.halt();
		resetResults();
	}

	function finish():Void {
		for (i in 0...children.length) {
			if (results[i] == NODE_STATUS.RUNNING) {
				children[i].halt();
			}
		}
		resetResults();
	}

	inline function resetResults():Void {
		for (i in 0...results.length) {
			results[i] = NODE_STATUS.RUNNING;
		}
	}
}
