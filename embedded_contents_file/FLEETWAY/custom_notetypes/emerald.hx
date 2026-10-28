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
            note.extraData.set('emeraldIndex', count);
            note.scale.set(0.45, 0.45);
            note.updateHitbox();
            note.ratingDisabled = true;
            note.noAnimation = true;
            note.ignoreNote = !game.cpuControlled;
            note.hitHealth = 0;
            note.missHealth = 0;
            
            count++;
        }
    }
    lastBotplay = game.cpuControlled;
}

var lastBotplay:Bool = false;
function onUpdatePost(e) {
    if (lastBotplay != game.cpuControlled){
        game.notes.forEachAlive(note->{
            if (note == null) return;
            if (note.noteType == "emerald") note.ignoreNote = !game.cpuControlled;
        });
        lastBotplay = game.cpuCOntrolled;
    }
}