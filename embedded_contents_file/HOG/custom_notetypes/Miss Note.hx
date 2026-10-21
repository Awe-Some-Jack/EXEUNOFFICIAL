function onCreate()
{
	for (i in 0...game.unspawnNotes.length)
	{
		var note:Note = game.unspawnNotes[i];
		if (note.noteType == 'Miss Note') note.ignoreNote = true;
	}
}

function onUpdatePost(e)
{
	for (i in 0...notes.length)
	{
		var note:Note = notes.members[i];
		if (note.noteType == 'Miss Note')
		{
			if ((Conductor.songPosition - note.strumTime) > 10 && note.active)
			{
				if(note != null && note.parent == null && note.tail.length > 0) {
					note.copyAlpha = false;
					note.alpha = 0.7;
					for(childNote in note.tail) {
						childNote.copyAlpha = false;
						childNote.alpha = note.alpha;
						childNote.ignoreNote = true;
						childNote.active = false;
						childNote.tooLate = true;
						childNote.desat();
					}
					note.desat();
					note.active = false;
					notes.remove(note, true);
					note.tooLate = true;
				}
			}
		}
	}
}