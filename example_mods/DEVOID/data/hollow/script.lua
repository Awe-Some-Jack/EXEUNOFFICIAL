function onCreatePost()
    setProperty('BlackGraphicGame.alpha', 1)
    setProperty('camHUD.alpha', 0)
    addHaxeLibrary('FlxTrail', 'flixel.addons.effects')
end

function onSongStart()
    doTweenAlpha('BlackGraphicGameAlpha', 'BlackGraphicGame', 0.9, 1)
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
    elseif curStep == 544 or curStep == 1056 or curStep == 1312 or curStep == 1568 then
        doTweenAlpha('BlackGraphicBehindAlpha', 'BlackGraphicBehind', 0, 0.4)
    end
    if curStep == 1568 then
        addHaxeLibrary('FlxTrail', 'flixel.addons.effects')
        runHaxeCode([[
        import flixel.addons.effects.FlxTrail;

        var dadTrail = new FlxTrail(game.dad, null, 8, 6, 0.8, 0.12);
        dadTrail.color = 0x00FFFF;

        game.insert(game.members.indexOf(game.dadGroup), dadTrail);

        setVar('dadTrail', dadTrail);
    ]])
    end
    if curStep == 1824 then
        runHaxeCode([[
            var trail = getVar('dadTrail');
            if (trail != null) {
                trail.kill();
                game.remove(trail, true);
                trail.destroy();
                setVar('dadTrail', null);
            }
        ]])
    end
end