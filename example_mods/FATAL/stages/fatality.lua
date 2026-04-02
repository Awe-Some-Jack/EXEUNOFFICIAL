local fatalStages = {
	{name = 'truefatalstage', path = 'fatality/truefatalstage', x = -1050, y = -850, scaleX = 5, scaleY = 5, fps = 15, antialiasing = false, visible = true, front = false},
	{name = 'launchbase', path = 'fatality/launchbase', x = -1050, y = -1110, scaleX = 6, scaleY = 6, fps = 15, antialiasing = false, visible = true, front = false}
}

local newBG = {
	{name = 'redbg', x = -1350, y = -900, scale = 5},
	{name = 'smallassbox', backdrop = true, velocityX = -700, animated = true, animPrefix = 'smallassbox idle', x = -1350, y = -900, scale = 5, framerate = 12, bopper = true},
	{name = 'glitchythingy', animated = true, animPrefix = 'glitchythingy idle',  x = -1350, y = -900, scale = 5, framerate = 12, bopper = true},
	{name = 'smallbox', backdrop = true, velocityX = -500, animated = true, animPrefix = 'smallbox idle',  backdrop = true, x = -1350, y = -900, scale = 5, framerate = 12, bopper = true},
	{name = 'bigbox', animated = true, animPrefix = 'bigbox idle', x = -1350, y = -900, scale = 5, framerate = 12, bopper = true},
	{name = 'barbg', backdrop = true, velocityX = -100, x = -1350, y = -900, scale = 5},
	{name = 'floorbg', x = -1350, y = -900, scale = 5},

	{name = 'Banshee BG sheet', animated = true, animPrefix = 'Banshee BG', x = 1300, y = 100, scale = 4, framerate = 24, flipX = true, front = true, bopper = true},
	{name = 'Dismantler and Meatsheild BG sheet', animated = true, animPrefix = 'Dismantler and Meatsheild BG', x = 750, y = -200, scale = 4, framerate = 24, flipX = true, bopper = true},
	{name = 'Machine BG sheet', animated = true, animPrefix = 'Machine BG', x = -1200, y = -500, scale = 4, framerate = 24, bopper = true},
	{name = 'Trapper BG sheet', animated = true, animPrefix = 'Trapper BG', x = 0, y = -270, scale = 4, framerate = 24, bopper = true}
}

function onCreatePost()
	for _, stage in ipairs(fatalStages) do
		makeAnimatedLuaSprite(stage.name, stage.path, stage.x, stage.y)
		addAnimationByPrefix(stage.name, stage.name, 'idle', stage.fps, true)
		objectPlayAnimation(stage.name, stage.name, true)
		scaleObject(stage.name, stage.scaleX, stage.scaleY)
		setProperty(stage.name..'.antialiasing', stage.antialiasing)
		setProperty(stage.name..'.visible', stage.visible)
		addLuaSprite(stage.name, stage.front)
	end

	for _,stage in ipairs(newBG) do
		local daPath = 'fatality/new/domain/'..stage.name
		if stage.backdrop == true then
			createInstance(stage.name, 'flixel.addons.display.FlxBackdrop', {nil, 0x01})
			if stage.animated == true then
				loadFrames(stage.name, daPath)
				addAnimationByPrefix(stage.name, 'idle', stage.animPrefix, stage.framerate, stage.bopper ~= true)
			else loadGraphic(stage.name, daPath) end
			setProperty(stage.name..'.velocity.x', stage.velocityX)
			addInstance(stage.name, (stage.front == nil and false or stage.front))
		else
			if stage.animated == true then
				makeAnimatedLuaSprite(stage.name, daPath)
				addAnimationByPrefix(stage.name, 'idle', stage.animPrefix, stage.framerate, stage.bopper ~= true)
			else makeLuaSprite(stage.name, daPath) end
			addLuaSprite(stage.name, (stage.front == nil and false or stage.front))
		end
		setProperty(stage.name..'.visible', false)
		setProperty(stage.name..'.flipX', (stage.flipX == nil and false or stage.flipX))
		callMethod(stage.name..'.setPosition', {stage.x, stage.y})
		scaleObject(stage.name, stage.scale, stage.scale)
		setProperty(stage.name..'.antialiasing', false)
	end

	setProperty('scoreTxt.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('timeBar.visible', false)
	setProperty('timeBarBG.visible', false)

	for i = 0,3 do
        setProperty('opponentStrums.members['..i..'].x', 10 + (getProperty('opponentStrums.members['..i..'].width') * i))
        setProperty('playerStrums.members['..i..'].x', (screenWidth - 10 - (getProperty('opponentStrums.members['..i..'].width') * 4)) + (getProperty('opponentStrums.members['..i..'].width') * i))

		setProperty('opponentStrums.members['..i..'].texture', 'noteSkins/NOTEFATAL_assets')
    end

	for i = 0,getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteSkins/NOTEFATAL_assets')
		end
	end
end

function onBeatHit()
	if curBeat % 4 == 0 then
		for _,stage in ipairs(newBG) do
			if stage.bopper == true then
				playAnim(stage.name, 'idle', true)
			end
		end
	end
end

function onStepHit()
	if curStep == 255 then
		setProperty('launchbase.visible', false)
		for _,stage in ipairs(newBG) do
			setProperty(stage.name..'.visible', true)
		end
	end

	if curStep == 1983 then
		for _,stage in ipairs(newBG) do
			setProperty(stage.name..'.visible', false)
		end
		setProperty('truefatalstage.visible', true)

		triggerEvent('Change Character', 'dad', 'true-fatal')
		triggerEvent('Change Character', 'bf', 'bf-fatal-small')
		setProperty('dad.danceEveryNumBeats', 4)
	end
end
