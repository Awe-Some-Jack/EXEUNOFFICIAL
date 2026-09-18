function onCreatePost()
    setProperty('BlackGraphicGame.alpha', 1)
    setProperty('camHUD.alpha', 0)
    addHaxeLibrary('FlxTrail', 'flixel.addons.effects')
end

function onSongStart()
    doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 0.9, 1)
end


local trailShit = false

local function createTrail(create) trailShit = create and true or false end

function opponentNoteHit()
    if trailShit then
        runHaxeCode([[
            var trail = new Character(0, 0, dad.curCharacter, dad.isPlayer);
            trail.updateHitbox();
            trail.setPosition(dad.x, dad.y);
            trail.alpha = 0.8;
            trail.playAnim(dad.animation.curAnim.name);
            game.add(trail);

            FlxTween.tween(trail, {alpha: 0}, 0.5, {ease: FlxEase.circOut, onComplete: (_) -> {
                remove(trail);
                trail.destroy();
            }});
        ]])
    end
end

function onStepHit()
    if curStep == 8 then
        cancelTween('BlackGraphicGameAlpha')
        setProperty('BlackGraphicGame.alpha', 0.8)
    elseif curStep == 16 then
        setProperty('BlackGraphicGame.alpha', 0.6)
    elseif curStep == 24 then
        setProperty('BlackGraphicGame.alpha', 0.4)
        doTweenAlpha('WhiteGraphicOtherAlpha', 'WhiteGraphicOther', 1, 1)
    elseif curStep == 32 then
        cancelTween('WhiteGraphicOtherAlpha')
        doTweenAlpha('WhiteGraphicOtherAlpha2', 'WhiteGraphicOther', 0, 1)
        setProperty('BlackGraphicGame.alpha', 0)
        doTweenAlpha('camHUDAlpha2', 'camHUD', 1, 1)
    end
    if curStep == 528 or curStep == 784 or curStep == 1296 or curStep == 1552 then
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', .6, 0.6)
    elseif curStep == 544 or curStep == 1056 or curStep == 1312 or curStep == 1824 then
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0, 0.4)
    end
    if curStep == 1568 then
        createTrail(true)
    end
    if curStep == 1824 then
        createTrail()
    end
end