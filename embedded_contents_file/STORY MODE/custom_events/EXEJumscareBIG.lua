local jumpscareBIGSprite = {
    {name = 'jumpscareBIG', path = 'slow/simplejump', x = 0, y = 0, scaleX = 0.8, scaleY = 0.8, antialisasing = true, alpha = 0, camera = 'camOther', front = true}
}

precacheImage('slow/simplejump')

function onCreatePost()
    for _, jum in ipairs(jumpscareBIGSprite) do
        makeLuaSprite(jum.name, jum.path, jum.x, jum.y)
        scaleObject(jum.name, jum.scaleX, jum.scaleY)
        setProperty(jum.name..'.antialiasing', jum.antialisasing)
        setProperty(jum.name..'.alpha', jum.alpha)
        setObjectCamera(jum.name, jum.camera)
        screenCenter(jum.name)
        addLuaSprite(jum.name, jum.front)
    end
end

math.randomseed(os.clock())
function onEvent(lol)
    if lol == "EXEJumscareBIG" then

        setProperty('jumpscareBIG.alpha', 1)
        playSound('simplejumpsound', 1)
        runTimer('dissapearJumpscareBIG', 0.1)
    end
end

function onTimerCompleted(t)
    if t == 'dissapearJumpscareBIG' then
        setProperty('jumpscareBIG.alpha', 0)
    end
end