import objects.Note;
function goodNoteHit(note)
{
	if (note.noteType != 'doubleHitNote') return;
	if (note.extraData.get("pressedNote") != true)
	{
		note.extraData.set("pressedNote", true);
		note.wasGoodHit = false;
		note.isSustainNote = true;
		note.strumTime += Conductor.crochet * 2;
		note.extraData.set("lerpOffset", Conductor.crochet * 2);
		new FlxTimer().start(0.01, function(_){note.isSustainNote = false;});
	}
}

function onUpdatePost(e)
{
	for(i in 0...PlayState.instance.notes.members.length)
	{
		var note:Note = PlayState.instance.notes.members[i];
		if (note.extraData.get("pressedNote") == true)
		{
			var lerp:Float = FlxMath.lerp(note.extraData.get("lerpOffset"), 0, e * 15);
			note.offsetY = 0.45 * lerp * PlayState.instance.songSpeed * note.multSpeed * (ClientPrefs.data.downScroll ? 1 : -1);
			note.extraData.set("lerpOffset", lerp);
		}
	}
}