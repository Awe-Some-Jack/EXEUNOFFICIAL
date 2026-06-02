setProperty('skipCountdown', true)
runHaxeCode([[FlxG.camera.pixelPerfectRender = true;]])
setPropertyFromClass('flixel.addons.transition.FlxTransitionableState', 'skipNextTransOut', true)

local BG_Y = -1000
local FLOOR_Y = -1496
local PARALLAX_BASE = -1250
local PARALLAX_STEP = 50
local BG_COUNT = 13
local SKY_COUNT = 15

local function addBackdrop(tag, graphic, opts)
	opts = opts or {}
	local axisFlag = opts.axis or 0x01
	local gap = opts.gap or -1
	local gapY = opts.gapY or 0
	createInstance(tag, 'flixel.addons.display.FlxBackdrop', {nil, axisFlag, gap, gapY})
	if opts.animated then
		loadFrames(tag, graphic)
		addAnimationByPrefix(tag, 'idle', 'idle', opts.fps or 8, opts.loop ~= false)
	else
		loadGraphic(tag, graphic)
	end
	addInstance(tag)
	scaleObject(tag, opts.scaleX or 3, opts.scaleY or 3.01)
	setScrollFactor(tag, opts.scrollX or 0.2, opts.scrollY or 0.6)
	setProperty(tag .. '.y', opts.y or BG_Y)
	setProperty(tag .. '.color', getColorFromHex('000000'))
	setProperty(tag .. '.antialiasing', false)
	if opts.orderAfter then
		setObjectOrder(tag, getObjectOrder(opts.orderAfter) + 1)
	end
end

local lightningActive = false

function onCreatePost()
	if not lowQuality then
		for i = 1, BG_COUNT do
			addBackdrop('bg' .. i, 'prey/bottom/bg' .. i, {y = BG_Y - 5})
		end

		for i = 1, SKY_COUNT do
			addBackdrop('sky' .. i, 'prey/sky/sky' .. i)
		end

		addBackdrop('sky15flash', 'prey/sky/sky15-lightning-anim', {animated = true, fps = 12, loop = false})
		setProperty('sky15flash.visible', false)
	else
		addBackdrop('bg-lq', 'prey/bg-lq', {axis = 0x01, gap = 0, gapY = 0, scaleX = 3, scaleY = 3})
	end

	if not lowQuality then
		addBackdrop('floor1', 'prey/floor1-anim', {
			animated = true, fps = 8, scaleX = 5, scaleY = 5,
			y = FLOOR_Y, scrollX = 1, scrollY = 1, orderAfter = 'boyfriendGroup',
		})
		addBackdrop('floor2', 'prey/floor2', {
			scaleX = 5, scaleY = 5, y = FLOOR_Y, scrollX = 1, scrollY = 1,
		})
		addBackdrop('fg', 'prey/fg-pilar-anim', {
			animated = true, fps = 8, axis = 0x01, gap = 2800, gapY = 0,
			scaleX = 5, scaleY = 5, y = FLOOR_Y + 1300,
			scrollX = 1, scrollY = 1, orderAfter = 'floor1',
		})
	else
		addBackdrop('floor-lq', 'prey/floor-lq', {
			axis = 0x01, gap = 0, gapY = 0,
			scaleX = 5, scaleY = 5, y = FLOOR_Y, scrollX = 1, scrollY = 1,
		})
	end

	makeLuaSprite('flashOverlay')
	makeGraphic('flashOverlay', screenWidth, screenHeight, 'ffff99')
	setObjectCamera('flashOverlay', 'hud')
	addLuaSprite('flashOverlay')
	setProperty('flashOverlay.alpha', 0)
	setBlendMode('flashOverlay', 'add')

	changeBGVelocity(1)
end

local stopNextShock = false
function onSectionHit()
	if curSection % 16 == 0 then
		if not stopNextShock then
			lightningActive = true
			setProperty('sky15flash.visible', true)
			setProperty('sky15flash.alpha', 1)
			playAnim('sky15flash', 'idle', true)
			if flashingLights then
				setProperty('flashOverlay.alpha', 0.3)
				doTweenAlpha('flashFade', 'flashOverlay', 0, crochet / (1000 / 4) / playbackRate, 'cubeOut')
			end
		end
		stopNextShock = false
	end
end

function onUpdatePost(e)
	if lightningActive then
		if getProperty('sky15flash.animation.curAnim.finished') then
			setProperty('sky15flash.alpha', getProperty('sky15flash.alpha') - (e * playbackRate * 0.75))
		end
		if getProperty('sky15flash.alpha') <= 0 then
			lightningActive = false
			setProperty('sky15flash.visible', false)
		end
	end
end

function changeBGVelocity(value)
	if not lowQuality then
		for i = 1, BG_COUNT do
			local j = BG_COUNT + 1 - i
			setProperty('bg' .. j .. '.velocity.x', (PARALLAX_BASE + (PARALLAX_STEP * (i - 1))) * value)
		end
		for i = 1, SKY_COUNT do
			setProperty('sky' .. i .. '.velocity.x', (PARALLAX_BASE + (PARALLAX_STEP * (i - 1))) * value)
		end
		setProperty('sky15flash.velocity.x', (PARALLAX_BASE + (PARALLAX_STEP * (SKY_COUNT - 1))) * value)

		setProperty('floor1.velocity.x', -2000 * value)
		setProperty('floor2.velocity.x', -2000 * value)
		setProperty('fg.velocity.x', -3500 * value)
	else
		setProperty('bg-lq.velocity.x', -900 * value)
		setProperty('floor-lq.velocity.x', -2000 * value)
	end
end

function onEvent(n, v1)
	if n == 'Change BG Velocity' then
		changeBGVelocity(tonumber(v1))
	end
	if n == 'preyEvent' and songPath == 'prey' then
		if v1 == 'stopnextshock' then stopNextShock = true end
		if v1 == 'shock' then
			lightningActive = true
			setProperty('sky15flash.visible', true)
			setProperty('sky15flash.alpha', 1)
			playAnim('sky15flash', 'idle', true)
			if flashingLights then
				setProperty('flashOverlay.alpha', 0.3)
				doTweenAlpha('flashFade', 'flashOverlay', 0, crochet / (1000 / 4) / playbackRate, 'cubeOut')
			end
		end
	end
end
