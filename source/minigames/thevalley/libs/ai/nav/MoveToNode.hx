package minigames.thevalley.libs.ai.nav;

import minigames.thevalley.libs.ai.behavior.BehaviorTree;
import minigames.thevalley.libs.ai.behavior.BehaviorTree.Blackboard;
import minigames.thevalley.libs.ai.behavior.node.Node;
import minigames.thevalley.libs.ai.behavior.node.NODE_STATUS;

using minigames.thevalley.libs.ai.behavior.BlackboardTools;

class MoveToNode implements Node
{
	final agent:NavAgent;
	final follower:PathFollower;
	final xKey:String;
	final yKey:String;
	var context:Blackboard;

	public function new(agent:NavAgent, follower:PathFollower, xKey:String = "targetX", yKey:String = "targetY")
	{
		this.agent = agent;
		this.follower = follower;
		this.xKey = xKey;
		this.yKey = yKey;
	}

	public function init(context:Blackboard):Void
	{
		this.context = context;
	}

	public function execute():NODE_STATUS
	{
		if (!context.has(xKey) || !context.has(yKey))
		{
			stop();
			return NODE_STATUS.FAILURE;
		}

		follower.setTarget(context.getFloat(xKey), context.getFloat(yKey));

		return switch (follower.update(context.getFloat("elapsed"), agent.navX(), agent.navY()))
		{
			case Moving:
				agent.steer(follower.waypointX, follower.waypointY, follower.waypointTransition);
				NODE_STATUS.RUNNING;

			case Arrived:
				stop();
				NODE_STATUS.SUCCESS;

			case _:
				stop();
				NODE_STATUS.FAILURE;
		}
	}

	public function halt():Void
	{
		stop();
	}

	inline function stop():Void
	{
		follower.clear();
		agent.stopMoving();
	}
}
