function onCreatePost() //for manual blast
{
	for (i in 0...game.unspawnNotes.length)
	{
		var note:Note = game.unspawnNotes[i];

		if (note.noteType == 'Glitch Anim' && !note.isSustainNote)
		{
			if (note.mustPress)
			{
				final suffix:String = FlxG.random.bool(25) ? '-alt-g' : '-g' + Std.string(FlxG.random.int(1,2));
				note.animSuffix = '-mb' + suffix;
				for(childNote in note.tail) childNote.animSuffix = note.animSuffix;
			}
			else 
			{
				note.animSuffix = '-g' + Std.string(FlxG.random.int(1,3));
				for(childNote in note.tail) childNote.animSuffix = note.animSuffix;
			}
		}
	}
}