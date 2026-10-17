package minigames.thevalley.libs.ai.behavior.node;

enum abstract NODE_STATUS(Int) {
	var SUCCESS = 0;
	var FAILURE = 1;
	var RUNNING = 2;

	public function toString():String {
		return switch (this) {
			case 0: "SUCCESS";
			case 1: "FAILURE";
			default: "RUNNING";
		}
	}
}
