function onCreatePost()
	setProperty('camGame.pixelPerfectRender', true)

	makeLuaSprite('sky', 'longstrider/bg/sky')
	scaleObject('sky', 4, 4)
	setProperty('sky.antialiasing', false)
	addLuaSprite('sky')

	createInstance('clouds', 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
	loadGraphic('clouds', 'longstrider/bg/clouds')
	scaleObject('clouds', 4, 4)
	setProperty('clouds.antialiasing', false)
	addInstance('clouds')

	makeLuaSprite('mountains', 'longstrider/bg/mountains', 0, 109 * 4)
	scaleObject('mountains', 4, 4)
	setProperty('mountains.antialiasing', false)
	addLuaSprite('mountains')

	makeAnimatedLuaSprite('water', 'longstrider/bg/water')
	addAnimationByPrefix('water', 'idle', 'water', 12, true)
	scaleObject('water', 4, 4)
	setProperty('water.antialiasing', false)
	addLuaSprite('water')

	makeAnimatedLuaSprite('waterfall', 'longstrider/bg/waterfall')
	addAnimationByPrefix('waterfall', 'idle', 'idle', 12, true)
	scaleObject('waterfall', 4, 4)
	setProperty('waterfall.antialiasing', false)
	addLuaSprite('waterfall')

	createInstance('omwhand', 'objects.Character', {2 + 270 * 4, 176 * 4, 'omwlsheand', false})
	addInstance('omwhand')

	makeLuaSprite('grass', 'longstrider/bg/grass', 0, 240 * 4)
	scaleObject('grass', 4, 4)
	setProperty('grass.antialiasing', false)
	addLuaSprite('grass')

	makeLuaSprite('floor', 'longstrider/bg/floor')
	scaleObject('floor', 4, 4)
	setProperty('floor.antialiasing', false)
	addLuaSprite('floor')

	makeLuaSprite('rock', 'longstrider/bg/rock', 156 * 4, 333 * 4)
	scaleObject('rock', 4, 4)
	setProperty('rock.antialiasing', false)
	addLuaSprite('rock')

	makeAnimatedLuaSprite('radio', 'longstrider/radio')
	addAnimationByPrefix('radio', 'idle', 'idle', 12, false)
	scaleObject('radio', 4, 4)
	setProperty('radio.antialiasing', false)
	addLuaSprite('radio')
	
	setProperty('dad.alpha', 0) setProperty('omwhand.alpha', 0)
	setObjectOrder('dadGroup', getObjectOrder('mountains') - 1)

	setProperty('camHUD.alpha', 0)
	setProperty('BlackGraphicOther.alpha', 1)
end

function onSongStart()
	doTweenAlpha('WhiteGraphicOther', 'WhiteGraphicOther', 1, crochet / 250)
end

function onCountdownTick() playAnim('radio', 'idle', true) end
function onBeatHit()
	playAnim('radio', 'idle', true)

	if curBeat >= 4 and getProperty('BlackGraphicOther.alpha') > 0 then
		setProperty('BlackGraphicOther.alpha', 0)
		cancelTween('WhiteGraphicOther')
		doTweenAlpha('WhiteGraphicOther', 'WhiteGraphicOther', 0, crochet / 250)
	end
end

function opponentNoteHit(_,nd)
	playAnim('omwhand', getProperty('singAnimations['..nd..']'), true)
	setProperty('omwhand.holdTimer', 0)
end

local grid = 0
function onUpdatePost(e)
	grid = grid + e
	setProperty('clouds.x', math.floor(grid) * 4)
end