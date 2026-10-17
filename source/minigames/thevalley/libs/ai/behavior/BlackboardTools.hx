package minigames.thevalley.libs.ai.behavior;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;

class BlackboardTools {
	public static inline function has(bb:Blackboard, key:String):Bool {
		return bb.exists(key);
	}

	public static function getFloat(bb:Blackboard, key:String, def:Float = 0):Float {
		final v:Null<Float> = bb.get(key);
		return v == null ? def : v;
	}

	public static function getInt(bb:Blackboard, key:String, def:Int = 0):Int {
		final v:Null<Int> = bb.get(key);
		return v == null ? def : v;
	}

	public static function getBool(bb:Blackboard, key:String, def:Bool = false):Bool {
		final v:Null<Bool> = bb.get(key);
		return v == null ? def : v;
	}

	public static function getOr<T>(bb:Blackboard, key:String, def:T):T {
		return bb.exists(key) ? (bb.get(key) : T) : def;
	}

	public static inline function time(bb:Blackboard):Float {
		return getFloat(bb, "time");
	}
}
