function opponentNoteHitPre(note) if (note.noteType == 'Genesys Ghost') note.noAnimation = true;

function opponentNoteHit(note)
{
	if (note.isSustainNote) return;

	if (note.noteType == 'Genesys Ghost')
	{
		var moveAmount:Array<Int> = [note.noteData == 0 ? -1 : (note.noteData == 3 ? 1 : 0), note.noteData == 1 ? 1 : (note.noteData == 2 ? -1 : 0)];
		var prefix:String = '-alt';
		if (dad.idleSuffix == '-alt') prefix = '';
		var ghost:Character = new Character(dad.x + moveAmount[0] * 200, dad.y + moveAmount[1] * 200, 'genesys', false);
		ghost.playAnim(PlayState.instance.singAnimations[note.noteData] + prefix, true);
		addBehindDad(ghost);
		FlxTween.tween(ghost, {alpha: 0, x: (dad.x + moveAmount[0] * 250), y: (dad.y + moveAmount[1] * 250)}, Conductor.crochet / 500, {ease: FlxEase.cubeOut, onComplete: function(_) { ghost.destroy(); }});
	}
}