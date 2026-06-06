var bfAtlas:FlxSpriteElement;
var bf:Character;
function onCreatePost()
{
    bf = new Character(0, 0, 'bfd-run', true);
	bf.origin.set();
    bfAtlas = new animate.internal.elements.FlxSpriteElement(bf);
	bfAtlas.active = false;
    bf.visible = false;
}

function onEvent(n,v1,v2)
{
    if (n == 'BGchange' && v1 == 'jajaja')
    {
        boyfriend.alpha = 0;
        bf.visible = true;

        var shit = gf.library.getSymbol("bfplaceholder");
        shit.timeline.layers[0].forEachFrame((frame) -> {
            for (i in frame.elements) i.visible = false;  
            frame.add(bfAtlas);
        });
    }
}

function onUpdate(elapsed:Float):Void
{
    if (bf.visible) bf.update(elapsed);
}

function onDestroy():Void
{
	if (bf.visible) bf.destroy();
}

function goodNoteHitPre(note)
{
    if (note.noteType == '' && bf.visible)
    {
        bf.playAnim(singAnimations[note.noteData]);
        bf.holdTimer = 0;
    }
}