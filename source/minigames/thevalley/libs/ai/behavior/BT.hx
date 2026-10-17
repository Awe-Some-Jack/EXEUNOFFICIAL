package minigames.thevalley.libs.ai.behavior;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;
import minigames.thevalley.libs.ai.behavior.node.Node;
import minigames.thevalley.libs.ai.behavior.node.NODE_STATUS;
import minigames.thevalley.libs.ai.behavior.node.composite.*;
import minigames.thevalley.libs.ai.behavior.node.decorator.*;
import minigames.thevalley.libs.ai.behavior.node.leaf.*;
import minigames.thevalley.libs.ai.nav.CanReachNode;
import minigames.thevalley.libs.ai.nav.MoveToNode;
import minigames.thevalley.libs.ai.nav.NavAgent;
import minigames.thevalley.libs.ai.nav.NavGraph;
import minigames.thevalley.libs.ai.nav.PathFollower;

class BT {
	public static inline function tree(root:Node):BehaviorTree return new BehaviorTree(root);

	public static inline function sequence(children:Array<Node>):SequenceNode return new SequenceNode(children);
	public static inline function selector(children:Array<Node>):SelectorNode return new SelectorNode(children);
	public static inline function reactiveSequence(children:Array<Node>):ReactiveSequenceNode return new ReactiveSequenceNode(children);
	public static inline function reactiveSelector(children:Array<Node>):ReactiveSelectorNode return new ReactiveSelectorNode(children);
	public static inline function parallel(children:Array<Node>, successThreshold:Int = -1, failureThreshold:Int = -1):ParallelNode
		return new ParallelNode(children, successThreshold, failureThreshold);

	public static inline function invert(child:Node):InverterNode return new InverterNode(child);
	public static inline function succeed(child:Node):SucceederNode return new SucceederNode(child);
	public static inline function fail(child:Node):FailerNode return new FailerNode(child);
	public static inline function forever(child:Node):RepeaterNode return new RepeaterNode(child);
	public static inline function repeat(child:Node, times:Int):RepeatNode return new RepeatNode(child, times);
	public static inline function repeatUntil(child:Node, until:NODE_STATUS = NODE_STATUS.FAILURE):RepeatUntilNode return new RepeatUntilNode(child, until);
	public static inline function retry(child:Node, attempts:Int):RetryNode return new RetryNode(child, attempts);
	public static inline function cooldown(child:Node, seconds:Float):CooldownNode return new CooldownNode(child, seconds);
	public static inline function timeout(child:Node, seconds:Float):TimeoutNode return new TimeoutNode(child, seconds);

	public static inline function action(fn:Blackboard->NODE_STATUS, ?onHalt:Void->Void):ActionNode return new ActionNode(fn, onHalt);
	public static inline function condition(fn:Blackboard->Bool):ConditionNode return new ConditionNode(fn);
	public static inline function wait(seconds:Float):WaitNode return new WaitNode(seconds);

	public static inline function moveTo(agent:NavAgent, follower:PathFollower, xKey:String = "targetX", yKey:String = "targetY"):MoveToNode
		return new MoveToNode(agent, follower, xKey, yKey);
	public static inline function canReach(agent:NavAgent, graph:NavGraph, xKey:String = "targetX", yKey:String = "targetY"):CanReachNode
		return new CanReachNode(agent, graph, xKey, yKey);
}
