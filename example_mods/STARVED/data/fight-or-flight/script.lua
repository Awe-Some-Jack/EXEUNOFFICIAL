local bfx = 200
local bfy = 0
local zoomshit = 0

function onCreatePost()
    setProperty('timeBar.x', getProperty('healthBar.x') + 105)
    setProperty('timeBar.y', getProperty('healthBar.y'))
    setProperty('timeTxt.y', getProperty('healthBar.y') - 12)

    setPropertyFromClass('ClientPrefs', 'middleScroll', true)
    for i = 0, 3 do
        setPropertyFromGroup('playerStrums', i, 'x', 412 + (112 * i))
        setPropertyFromGroup('playerStrums', i, 'alpha', 0.6)
    end
    for i = 0, 3 do
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
    end

    setProperty('healthBar.angle', 90)
    setProperty('healthBar.x', 840)
    setProperty('healthBar.y', 350)
end

function onUpdate()
    zoomshit = (getProperty('camGame.zoom') / 0.75)
    setProperty('boyfriend.scale.x', zoomshit)
    setProperty('boyfriend.scale.y', zoomshit)
end

function onUpdatePost(elapsed)
    local sacrifices = getProperty('songMisses')
    local accuracy = math.floor(getProperty('ratingPercent') * 100)
    local rating = getProperty('ratingName')
 
   setTextString('scoreTxt',"Sacrifices: "..sacrifices.." | Accuracy: "..accuracy.."%".." ["..rating.."]")
    setProperty('healthBar.x', 840)
    setProperty('healthBar.y', 350)

    local healthPercent = getProperty('healthBar.percent')
    local hbY = getProperty('healthBar.y')
    local hbX = getProperty('healthBar.x')
    local hbW = getProperty('healthBar.width')
    local scaleY = getProperty('healthBar.scale.y')

    local P1Y = hbY - ((hbW * (healthPercent * scaleY * 0.01)) + (150 * getProperty('iconP1.scale.x') - 150)) + 270
    local P2Y = hbY - ((hbW * (healthPercent * scaleY * 0.01)) - (150 * getProperty('iconP2.scale.x')))

    setProperty('iconP1.x', hbX + 220)
    setProperty('iconP2.x', hbX + 220)
    setProperty('iconP1.y', P1Y)
    setProperty('iconP2.y', P2Y)

    scaleObject('iconP1', 1, 1, false) scaleObject('iconP2', 1, 1, false)

    setProperty('camHUD.zoom', 1.0)

    for i = 0, getProperty('notes.length') - 1 do
        local mustPress = getPropertyFromGroup('notes', i, 'mustPress')
        if mustPress then
            setPropertyFromGroup('notes', i, 'alpha', 0.6)
        else
            setPropertyFromGroup('notes', i, 'alpha', 0)
            setPropertyFromGroup('notes', i, 'ignoreNote', false)
        end
    end
end

function onBeatHit()
     scaleObject('iconP1', 1, 1, false) scaleObject('iconP2', 1, 1, false)
end