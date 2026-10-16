function onCreate()
{
	for (i in 0...unspawnNotes.length)
	{
		var note:Note = unspawnNotes[i];
		if (note.mustPress && note.noteType == 'FakeNote')
		{
			note.ignoreNote = true;
			note.blockHit = true;
			note.ratingDisabled = true;
		}
	}
}