local videoSprites = {}
local playedVideos = {}
local trailActive = false

local videoSchedule = {
    {step = 912, video = 'Mlg'},
    {step = 912, video = 'Explosion', id = 'explosion1', front = true},
    {step = 912, video = 'Glasses', front = true},
    {step = 919, video = 'Weed', front = true},
    {step = 958, video = 'Guns'},
    {step = 971, video = 'Hitmarkers', id = 'hitmarkers1', front = true},
    {step = 975, video = 'OHHH'},
    {step = 984, video = 'teletubby', front = true},
    {step = 1033, video = 'Noscope', id = 'noscope1'},
    {step = 1038, video = 'Explosion', id = 'explosion2', front = true},
    {step = 1048, video = 'smg4', front = true},
    {step = 1103, video = 'Illuminaticonfirmed', front = true},
    {step = 1164, video = 'Noscope', id = 'noscope2'},
    {step = 1164, video = 'Hitmarkers', id = 'hitmarkers2', front = true},
    {step = 1164, video = 'Explosion', id = 'explosion3'}
}

function onCreate()
    if not flashingLights then
        close()
        return
    end

    for _, entry in ipairs(videoSchedule) do
        precacheImage(entry.video)
    end
end

function makeVideoSprite(tag, videoFile, canSkip, front)
    if front == nil then front = false end
    createInstance(tag, 'objects.VideoSprite', {
        callMethodFromClass('backend.Paths', 'video', {videoFile}),
        false,
        canSkip or false
    })
    addInstance(tag, front)

    setObjectCamera(tag, (front and 'other' or 'hud'))

    setSpriteShader(tag..'.videoSprite', 'GreenScreenShader')

    setProperty(tag..'.videoSprite.blend', 'NORMAL')
    setProperty(tag..'.videoSprite.antialiasing', true)

    setProperty(tag..'.alpha', 0.0001)
    setProperty(tag..'.videoSprite.alpha', 1)

    screenCenter(tag)

    callMethod(tag..'.play')

    table.insert(videoSprites, tag)
end

function onStepHit()
    if curStep == 912 and not trailActive then
        trailActive = true
        runHaxeCode([[
            var dad = game.dad;
            var bf = game.boyfriend;

            var dadTrail = new flixel.addons.effects.FlxTrail(dad, null, 4, 3, 0.4, 0.069);
            dadTrail.cameras = [game.camGame];
            game.insert(game.members.indexOf(dad), dadTrail);
            game.variables.set('dadTrail', dadTrail);

            var bfTrail = new flixel.addons.effects.FlxTrail(bf, null, 4, 3, 0.4, 0.069);
            bfTrail.cameras = [game.camGame];
            game.insert(game.members.indexOf(bf), bfTrail);
            game.variables.set('bfTrail', bfTrail);
        ]])
    end

    if curStep == 1179 and trailActive then
        trailActive = false
        runHaxeCode([[
            var dadTrail = game.variables.get('dadTrail');
            var bfTrail = game.variables.get('bfTrail');

            if (dadTrail != null) {
                dadTrail.kill();
                game.remove(dadTrail);
                dadTrail.destroy();
                game.variables.remove('dadTrail');
            }

            if (bfTrail != null) {
                bfTrail.kill();
                game.remove(bfTrail);
                bfTrail.destroy();
                game.variables.remove('bfTrail');
            }
        ]])
    end

    for _, entry in ipairs(videoSchedule) do
        if curStep == entry.step then
            local uniqueId = entry.id or entry.video
            local tag = 'video_'..uniqueId..'_'..curStep

            if not playedVideos[tag] then
                makeVideoSprite(tag, entry.video, false, entry.front or false)
                playedVideos[tag] = true
            end
        end
    end
end

function onPause()
    for _, video in ipairs(videoSprites) do
        callMethod(video..'.pause')
    end
end

function onResume()
    for _, video in ipairs(videoSprites) do
        callMethod(video..'.resume')
    end
end

function onDestroy()
    for _, video in ipairs(videoSprites) do
        if luaSpriteExists(video) then
            removeInstance(video, true)
        end
    end
    videoSprites = {}
    playedVideos = {}
end
