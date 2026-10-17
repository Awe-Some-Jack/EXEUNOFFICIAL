package minigames.thevalley.libs.ai.nav;

interface NavAgent
{
	function navX():Float;

	function navY():Float;

	function steer(x:Float, y:Float, transition:Int):Void;

	function stopMoving():Void;
}
