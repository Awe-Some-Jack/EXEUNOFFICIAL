function goodNoteHit(id, _, noteType, _)
    local detectChar = noteType == 'GF Sing' and mustHitSection
    local char = ''
    local behind = ''
    if detectChar then
        char = 'gf'
        behind = 'GF'
    else
        char = 'boyfriend'
        behind = 'BF'
    end
    createGhost(char, behind, noteType, sustain)
end
function opponentNoteHit(id, _, noteType, sustain)
    local detectChar = noteType == 'GF Sing' and not mustHitSection
    local char = ''
    local behind = ''
    if detectChar then
        char = 'gf'
        behind = 'GF'
    else
        char = 'dad'
        behind = 'Dad'
    end
    createGhost(char, behind, noteType, sustain)
end
function createGhost(char, behind, noteType, sustain)
    if noteType == 'Alt Animation' and not sustain then
        runHaxeCode([[
            var ghost = new Character(0, 0, ]]..char..[[.curCharacter, ]]..char..[[.isPlayer);
            ghost.updateHitbox();
            ghost.setPosition(]]..char..[[.x, ]]..char..[[.y);
            ghost.alpha = 0.8;
            ghost.angle = ]]..char..[[.angle;
            ghost.visible = ]]..char..[[.visible;
            ghost.playAnim(]]..char..[[.animation.curAnim.name);
            game.addBehind]]..behind..[[(ghost);
            FlxTween.tween(ghost, {alpha: 0}, Conductor.stepCrochet/1000 * 8, {ease:FlxEase.quartOut,onComplete:function() {
                remove(ghost);
                ghost.destroy();
            }});
        ]])
    end
end