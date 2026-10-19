function onCreate() //for hedge only lol
{
	for (i in 0...game.unspawnNotes.length)
	{
		var note:Note = game.unspawnNotes[i];

		if (note.noteType == 'Fake Note')
		{
			note.copyAlpha = false;
			note.alpha = 0.0001;
			note.noAnimation = true;
			note.ignoreNote = true;
		}
	}
}