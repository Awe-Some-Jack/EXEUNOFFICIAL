var notesPosition:Array<Array<Array<Float>>> = [[[0,0],[0,0],[0,0],[0,0]],[[0,0],[0,0],[0,0],[0,0]]];
var modchart:String = 'intro';
var saveOnce:Bool = true;
var float:Float = 0;
function onUpdatePost(elapsed:Float)
{
	switch(modchart)
	{
		case 'intro':
			float += elapsed * 1.5;
			for (i in 0...8)
			{
				var strum:StrumNote = game.strumLineNotes.members[i];
				if (strum == null) return;

				if (saveOnce)
				{
					saveOnce = false;
					for (i in 0...4)
					{
						notesPosition[0][i][0] = opponentStrums.members[i].x; notesPosition[1][i][0] = playerStrums.members[i].x;
						notesPosition[0][i][1] = opponentStrums.members[i].y; notesPosition[1][i][1] = playerStrums.members[i].y;
					}
				}

				strum.setPosition(
					notesPosition[Std.int(i / 4)][i % 4][0] + Math.sin(float + i) * 6,
					notesPosition[Std.int(i / 4)][i % 4][1] + Math.cos(float + i) * 3
				);
			}
	}
}

function onBeatHit() float += 0.1;