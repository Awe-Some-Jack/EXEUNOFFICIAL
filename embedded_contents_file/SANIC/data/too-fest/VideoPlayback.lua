local videoSprites = {}
local playedVideos = {}

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
    createInstance(tag, 'hxvlc.flixel.FlxVideoSprite', {0, 0})
    callMethod(tag..'.load', {callMethodFromClass('backend.Paths', 'video', {videoFile})})
    addInstance(tag, front)
    setObjectCamera(tag, (front and 'other' or 'hud'))
    setSpriteShader(tag, 'GreenScreenShader')
    setProperty(tag..'.videoSprite.antialiasing', false)
    callMethod(tag..'.play')

    table.insert(videoSprites, tag)
    runHaxeCode([[
        game.getLuaObject(']]..tag..[[').bitmap.onFormatSetup.add(() -> {
            game.getLuaObject(']]..tag..[[').setGraphicSize(FlxG.width, FlxG.height);
            game.getLuaObject(']]..tag..[[').updateHitbox();
            game.getLuaObject(']]..tag..[[').screenCenter();
        });
        game.getLuaObject(']]..tag..[[').bitmap.onEndReached.add(() -> game.getLuaObject(']]..tag..[[').destroy());
    ]])
end

function onStepHit()
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
