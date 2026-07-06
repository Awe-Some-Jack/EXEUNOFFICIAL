var bfAtlas:FlxSpriteElement;
var bf:Character;
var beast:Character;
var beastAtlas:FlxSpriteElement;
var beastLegs:Character;
function onCreatePost()
{
	bf = new Character(0, 0, 'bfd-run', true);
	bf.origin.set();
	bfAtlas = new animate.internal.elements.FlxSpriteElement(bf);
	bfAtlas.active = false;
	bf.visible = false;

	beastLegs = new Character(1150, 580, 'beast-run', false);
	add(beastLegs);
	beastLegs.visible = false;

	beast = new Character(0, 0, 'beast-runhead', false);
	beast.origin.set();
	beast.visible = false;
}

function onEvent(n,v1,v2)
{
	if (n == 'BGchange')
	{
		switch(v1)
		{
			case 'jajaja':
				boyfriend.alpha = 0;
				dad.alpha = 0;
				bf.visible = true;
				beast.visible = true;
				beastLegs.visible = true;

				var shit = gf.library.getSymbol("bfplaceholder");
				shit.timeline.layers[0].forEachFrame((frame) -> {
					for (i in frame.elements) i.visible = false;  
					frame.add(bfAtlas);
				});

				beastAtlas = new animate.internal.elements.FlxSpriteElement(beast);
				beastAtlas.active = false;
				var shit = beastLegs.library.getSymbol("Carpeta de elementos duplicados/reemplazar");
				shit.timeline.layers[0].forEachFrame((frame) -> {
					for (i in frame.elements) i.visible = false;
					frame.add(beastAtlas);
				});
			case 'pixel': beastLegs.visible = false;
			case 'back': beastLegs.visible = true;
			case 'dark': beastLegs.visible = false;
			case 'running': beastLegs.visible = true;
		}
	}
}

var curLegsFrame:Int = 0;
function onUpdate(elapsed:Float):Void
{
	curLegsFrame = PlayState.instance.getLuaObject('legsframerate')?.animation?.curAnim?.curFrame ?? 0;
	if (bf.visible) bf.update(elapsed); if (beast.visible) beast.update(elapsed);
	if (bf.animation.curAnim.name == 'idle') bf.animation.curAnim.curFrame = curLegsFrame;
	if (dad.curCharacter == 'beast-run') {
		beastLegs.animation.curAnim.curFrame = curLegsFrame;
		if ((beast.animation.curAnim.name == 'idle')) {
			beast.animation.curAnim.curFrame = curLegsFrame;
			if (!beast.animation.paused) beast.animation.paused = true;
		}
	}
}

function onDestroy():Void
{
	bf.destroy();
	beast.destroy();
	beastLegs.destroy();
}

function opponentNoteHitPre(note):Void
{
	if (beast.visible)
	{
		if (beastLegs.animation.curAnim.name != singAnimations[note.noteData] && !note.isSustainNote) {
			beastLegs.playAnim(singAnimations[note.noteData], true);
			beastLegs.holdTimer = 0;
			beastLegs.animation.curAnim.curFrame = curLegsFrame;
		}

		beast.playAnim(singAnimations[note.noteData], true);
		beast.holdTimer = 0;
	}
}

function goodNoteHitPre(note):Void
{
	if (note.noteType == '' && bf.visible)
	{
		bf.playAnim(singAnimations[note.noteData]);
		bf.holdTimer = 0;
	}
}