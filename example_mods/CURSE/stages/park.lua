local dancerValues = {32, 28, 24, 20, 16, 12, 8}
local randomDancer = 32
local beats = 0
function onCreate()
	makeLuaSprite('sky', 'Park/sky', -700, -370)
	addLuaSprite('sky')
	scaleObject('sky', 0.8, 0.8)
	setScrollFactor('sky', 0.5, 0.5)

	makeLuaSprite('city', 'Park/city', -800, -370)
	addLuaSprite('city')
	scaleObject('city', 0.8, 0.8)
	setScrollFactor('city', 0.7, 0.7)

	makeLuaSprite('floor', 'Park/floor', -900, -370)
	scaleObject('floor', 0.8, 0.8)
	addLuaSprite('floor')

	makeLuaSprite('trees2', 'Park/trees2', -900, -370)
	scaleObject('trees2', 0.8, 0.8)
	addLuaSprite('trees2')

	makeLuaSprite('trees1', 'Park/trees1', -900, -370)
	scaleObject('trees1', 0.8, 0.8)
	addLuaSprite('trees1')
	
	makeAnimatedLuaSprite('tails', 'Park/tails', -1796, 100)
	addAnimationByPrefix('tails', 'anim', 'tails instancia 1', 24, false)
	scaleObject('tails', 0.37, 0.37)
	setProperty('tails.visible', false)
	addLuaSprite('tails')

	makeAnimatedLuaSprite('fuente', 'Park/fuente', -50, 50)
	addAnimationByIndices('fuente', 'idle', 'anim instancia 1', {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}, 24, true)
	addAnimationByPrefix('fuente', 'anim', 'anim instancia 1', 24, false)
	playAnim('fuente', 'idle', true)
	scaleObject('fuente', 0.37, 0.37)
	addLuaSprite('fuente')

	makeAnimatedLuaSprite('menuSTATIC', 'Park/menuSTATIC')
	addAnimationByPrefix('menuSTATIC', 'anim', 'staticBackground', 24, true)
	setGraphicSize('menuSTATIC', 1280, 720)
	setScrollFactor('menuSTATIC', 0, 0)
	setProperty('menuSTATIC.alpha', 0)
	--setBlendMode('menuSTATIC', 'add')
	screenCenter('menuSTATIC')
	addLuaSprite('menuSTATIC')

	setScrollFactor('gf', 1, 1)
end

function onCreatePost() if getRandomBool() == true then triggerEvent('Change Character', 'gf', 'gfc2') end end

local wavyness = 0
function onUpdatePost(e)
	wavyness = wavyness + (e * 10)
	for i,sprite in ipairs({'sky' ,'city', 'floor', 'trees2', 'trees1'}) do setShaderFloat(sprite, 'iTime', wavyness + i) end

	scaleObject('menuSTATIC', 1 / getProperty('camGame.zoom'), 1 / getProperty('camGame.zoom'), false)
end

function onSongStart() playAnim('gf', 'danceLeft', true) setProperty('gf.danced', false) end

function onBeatHit()
	beats = beats + 1
	if beats == randomDancer then beats = 0 end
	if beats % randomDancer == 2 then
		playAnim('gf', 'danceLeftALT', true)
	elseif beats % randomDancer == 3 then
		playAnim('gf', 'danceRightALT', true)
		randomDancer = dancerValues[getRandomInt(1,#dancerValues)]
	end
	if curBeat >= 180 and curBeat < 244 then
		playAnim('gf', 'dance'..(curBeat % 2 == 0 and 'Left' or 'Right')..'-sad', true)
	end
end