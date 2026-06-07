package states.extras.achievements;

typedef Achievement =
{
	var name:String;
	var description:String;
	@:optional var locked:Bool;
	@:optional var maxScore:Float;
}