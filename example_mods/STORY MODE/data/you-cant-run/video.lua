local seenVideo = false

function onCreatePost()
    makeLuaSprite('blackscreenlol')
    makeGraphic('blackscreenlol', 3000, 3000, '000000')
    screenCenter('blackscreenlol')
    addLuaSprite('blackscreenlol', true)
    setProperty('blackscreenlol.visible', false)
end

function onEndSong()
    if seenVideo == false then
        startVideo('tripletrouble')
        setProperty('blackscreenlol.visible', true)
        seenVideo = true
        return Function_Stop
    end
    
    return Function_Continue
end

function onEndVideo()
    endSong()
end