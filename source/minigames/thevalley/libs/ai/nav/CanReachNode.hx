package minigames.thevalley.libs.ai.nav;

import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;
import minigames.thevalley.libs.ai.behavior.node.Node;
import minigames.thevalley.libs.ai.behavior.node.NODE_STATUS;

using minigames.thevalley.libs.ai.behavior.BlackboardTools;

class CanReachNode implements Node
{
	final agent:NavAgent;
	final graph:NavGraph;
	final xKey:String;
	final yKey:String;
	var context:Blackboard;

	public function new(agent:NavAgent, graph:NavGraph, xKey:String = "targetX", yKey:String = "targetY")
	{
		this.agent = agent;
		this.graph = graph;
		this.xKey = xKey;
		this.yKey = yKey;
	}

	public function init(context:Blackboard):Void
	{
		this.context = context;
	}

	public function execute():NODE_STATUS
	{
		if (graph.stateCount() == 0 || !context.has(xKey) || !context.has(yKey))
			return NODE_STATUS.FAILURE;

		final res = graph.findPath(agent.navX(), agent.navY(), context.getFloat(xKey), context.getFloat(yKey));

		return res == null || res.isSolved ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE;
	}

	public function halt():Void {}
}
