function onCreate() {
    var count:Int = 0;
	for (note in unspawnNotes) {
		if (note.noteType == 'emerald') {
            note.texture = 'noteSkins/placeholder';
            //note.texture = 'noteSkins/emerald' + count;
            note.scale.set(2, 2);
            note.updateHitbox();
            note.ratingDisabled = true;
            note.noAnimation = true;
            //note.ignoreNote = true;
            note.hitHealth = 0;
            note.missHealth = 0;
            
            count++;
        }
    }
}