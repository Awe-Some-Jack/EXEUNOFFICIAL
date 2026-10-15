local jumpscareSprite = {
    {name = 'jumpscare', path = 'characters/jumcare', x = 0, y = -200, animName = 'aidel', animPrefix = 'jum', fps = 24, loop = false, scaleX = 1, scaleY = 1, antialisasing = true, alpha = 0.0001, camera = 'camHUD', front = true}
}

local isScaringYou = false

precacheImage('characters/jumcare')

function onCreatePost()
    for _, jum in ipairs(jumpscareSprite) do
        makeAnimatedLuaSprite(jum.name, jum.path, jum.x, jum.y)
        addAnimationByPrefix(jum.name, jum.animName, jum.animPrefix, jum.fps, jum.loop)
        scaleObject(jum.name, jum.scaleX, jum.scaleY)
        setProperty(jum.name..'.antialiasing', jum.antialisasing)
        setProperty(jum.name..'.alpha', jum.alpha)
        setObjectCamera(jum.name, jum.camera)
        addLuaSprite(jum.name, jum.front)
    end
end

function onEvent(lol)
    if not isScaringYou then
        if lol == "EXEJumpscare" then
            isScaringYou = true
            setProperty('jumpscare.alpha', 1)
            playAnim('jumpscare', 'aidel', true)
            playSound('jumpscareSound')
            setProperty('cameraSpeed', 1)
            runHaxeCode("camGame.alive = camGame.exists = camHUD.alive = camHUD.exists = true;")
        end
    end
end

function onUpdate(elapsed)
    if isScaringYou then
        if getProperty('jumpscare.animation.curAnim.finished') then
            setProperty('jumpscare.alpha', 0)
            setProperty('camZoomingMult', 1)
            setProperty('camZoomingDecay', 1)
            isScaringYou = false
        end
    end
end