// THIS MADE THE LITTLE PLAYER CAN GET HIS PERFECT RANK!!!!!!

// - assman

function onCreatePost(){
    var stepMS:Float = Conductor.stepCrochet; 
    var minTime:Float = 1310 * stepMS;
    var maxTime:Float = 1401 * stepMS;

    for (note in unspawnNotes) {
        if (note != null) {
            if (note.strumTime >= minTime && note.strumTime <= maxTime) {
                note.ignoreNote = true;
            }
        }
    }
}