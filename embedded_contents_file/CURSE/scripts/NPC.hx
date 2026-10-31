import flixel.FlxSprite;

var tag:String;
var DEFAULT_BEATS_PER_BEATS:Int = 2;
var dancePerBeats:Int = DEFAULT_BEATS_PER_BEATS;
var beatProgress:Int = -1;

// for now, default states are DANCE, STATIC, ACTION
var curState:String = "DANCE";

var animTimer:Float = 2;

function onUpdatePost(elapsed:Float)
{
	animTimer -= elapsed;
}

function onBeatHit()
{
	beatProgress++;

	if (curState == "DANCE")
	{
		if (curBeat % 2 == 0)
		{
			// danz danz danze
		}
	}
}
