var colors = [  // Colors in order
    "green",
    "yellow",
    "blue",
    "purple",
    "gray",
    "cyan",
    "red"
];

var count:Int = 0;

function onCreate() {
    var count:Int = 0;
	for (note in unspawnNotes) {
		if (note.noteType == 'emerald') {
            note.texture = 'bg/emerals/${colors[count]}';
            note.scale.set(0.45, 0.45);
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