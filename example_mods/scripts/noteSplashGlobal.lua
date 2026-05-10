local specialSplashes = {
	{ --the normal splash
		skin = "noteSplashes",
		songs = {"chaos", "sunshine", "hollow", "pre-design", "personel", "endless-us", "mania", "shocker"},
		offset = {
			x = -75,
			y = -100
		},
		single = false,
		animations = {'note impact {KEY} purple', 'note impact {KEY} blue', 'note impact {KEY} green', 'note impact {KEY} red'},
		lifeTime = 0.18,
		isRandom = true,

		holdConfig = {
			skin = 'noteSplashesHOLD',
			scale = 1,
			offset = {
				x = -77,
				y = -55
			},
			multiKeyHold = true,
			startAnim = {
				{name = 'sustain cover start purple', fps = 24},
				{name = 'sustain cover start blue', fps = 24},
				{name = 'sustain cover start green', fps = 24},
				{name = 'sustain cover start red', fps = 24}
			},
			holdAnim = {
				{name = 'sustain cover loop purple', fps = 24},
				{name = 'sustain cover loop blue', fps = 24},
				{name = 'sustain cover loop green', fps = 24},
				{name = 'sustain cover loop red', fps = 24}
			},
			endAnim = {
				{name = 'sustain cover end purp', fps = 24},
				{name = 'sustain cover end blue', fps = 24},
				{name = 'sustain cover end green', fps = 24},
				{name = 'sustain cover end red', fps = 24}
			}
		}
	},
	{
		skin = "sunky_splash",
		songs = {"chocolate-milk", "vanilla-milk"},
		offset = {
			x = -95,
			y = -125
		},
		framerate = 30,
		single = false,
		animations = {'purple', 'blue', 'green', 'red'},
		indices = {0,1,2,3,4,5,6,7,8,9,10,11},
		scale = 0.7,

		holdConfig = {
			skin = 'sunky_splashHOLD',
			scale = 0.7,
			offset = {
				x = -90,
				y = -70
			},
			multiKeyHold = true,
			startAnim = {
				{name = 'sustain cover start purple', fps = 24},
				{name = 'sustain cover start blue', fps = 24},
				{name = 'sustain cover start green', fps = 24},
				{name = 'sustain cover start red', fps = 24}
			},
			holdAnim = {
				{name = 'sustain cover loop purple', fps = 24},
				{name = 'sustain cover loop blue', fps = 24},
				{name = 'sustain cover loop green', fps = 24},
				{name = 'sustain cover loop red', fps = 24}
			},
			endAnim = {
				{name = 'sustain cover end purp', fps = 24},
				{name = 'sustain cover end blue', fps = 24},
				{name = 'sustain cover end green', fps = 24},
				{name = 'sustain cover end red', fps = 24}
			}
		}
	},
	{
		skin = "BloodSplash-sanic",
		songs = {"too-fest"},
		holdConfig = {
			skin = "BloodSplashHOLD-sanic"
		}
	},
	{
		skin = "BloodSplash-mono",
		songs = {"monochromatic"},
		holdConfig = {
			skin = "BloodSplashHOLD-mono"
		}
	},
	{ --ESTO SOLO SIRVE PARA PRECACHEAR LA SPLASH JAJAJAJ
		skin = "noteSplashes-endless-us",
		songs = {"endless-us"},
		single = false,
		startWithSkin = false
	},
	{
		skin = "noteSplashes-endless-jp",
		songs = {"endless-jp"},
		offset = {
			x = -75,
			y = -100
		},
		single = false,
		animations = {'note impact {KEY} purple', 'note impact {KEY} blue', 'note impact {KEY} green', 'note impact {KEY} red'},
		lifeTime = 0.18,
		isRandom = true,

		holdConfig = {
			skin = 'noteSplashesHOLD-endless-jp',
			scale = 1,
			offset = {
				x = -77,
				y = -55
			},
			multiKeyHold = true,
			startAnim = {
				{name = 'sustain cover start purple', fps = 24},
				{name = 'sustain cover start blue', fps = 24},
				{name = 'sustain cover start green', fps = 24},
				{name = 'sustain cover start red', fps = 24}
			},
			holdAnim = {
				{name = 'sustain cover loop purple', fps = 24},
				{name = 'sustain cover loop blue', fps = 24},
				{name = 'sustain cover loop green', fps = 24},
				{name = 'sustain cover loop red', fps = 24}
			},
			endAnim = {
				{name = 'sustain cover end purp', fps = 24},
				{name = 'sustain cover end blue', fps = 24},
				{name = 'sustain cover end green', fps = 24},
				{name = 'sustain cover end red', fps = 24}
			}
		}
	}
}


local pixelSplashesList = {"prey", "b4cksl4sh", "starline", "fatality", "longstrider"}
local blacklistenedSongs = {}


--DONT TOUCH

local daHoldConfig = {offsetX = 0, offsetY = 0}
local holdsSplashHold = {0,0,0,0,0,0,0,0}
local holdsEnabled = true
local disableSkin = false
local currentSkin = 'BloodSplash'
local pixelSplash = false

local holdSplashConf = {
	skin = 'BloodSplashHOLD',
	pixel = false,
	scale = 0.9,
	multiKeyHold = false,
	offset = {
		x = -85,
		y = -62
	},
	startAnim = {name = 'sustain cover intro', fps = 24},
	holdAnim = {name = 'sustain cover loop', fps = 24},
	endAnim = {name = 'sustain cover end', fps = 24}
}

function onCreatePost()
	setProperty('grpNoteSplashes.visible', false)
	for i = 1,#blacklistenedSongs do if songPath == blacklistenedSongs[i] then disableSkin = true return end end
	for i = 1,#pixelSplashesList do if songPath == pixelSplashesList[i] then pixelSplash = true end end

	local foundSkin = false
	for _,splashes in ipairs(specialSplashes) do
		for _,songs in ipairs(splashes.songs) do if songPath == songs then foundSkin = true end end
		if foundSkin then
			if splashes.single ~= false then
				if splashes.startWithSkin ~= false then currentSkin = splashes.skin end
				doSplash(nil, splashes.skin, nil, true)
			else for i = 0,3 do
				if splashes.startWithSkin ~= false then currentSkin = splashes.skin end
				doSplash(i, splashes.skin, nil, true)
			end end

			if splashes.holdConfig.disabled then holdsEnabled = false
			else
				if splashes.skin ~= nil then holdSplashConf.skin = splashes.skin..'HOLD' end
				if splashes.holdConfig.skin ~= nil then holdSplashConf.skin = splashes.holdConfig.skin end
				if splashes.holdConfig.scale ~= nil then holdSplashConf.scale = splashes.holdConfig.scale end
				if splashes.holdConfig.offset ~= nil then for z,v in pairs(splashes.holdConfig.offset) do if v ~= nil then holdSplashConf.offset[z] = v end end end
				for n,d in pairs(splashes.holdConfig) do if type(v) == 'table' then for k,v in pairs(d) do if v ~= nil then holdSplashConf[n][k] = v end end end end
				if splashes.holdConfig.multiKeyHold then
					holdSplashConf.multiKeyHold = true
					for _, animType in ipairs({'startAnim', 'holdAnim', 'endAnim'}) do
						holdSplashConf[animType] = {}
						for i, src in pairs(splashes.holdConfig[animType]) do
							holdSplashConf[animType][i] = {}
							for k, v in pairs(src) do if v ~= nil then holdSplashConf[animType][i][k] = v end end
						end
					end
				end
			end

			break
		end
	end

	if holdsEnabled then
		for i = 0,7 do
			makeAnimatedLuaSprite('noteHold'..i, 'exeSplashes/holds/'..holdSplashConf.skin)
			if holdSplashConf.multiKeyHold then
				addAnimationByPrefix('noteHold'..i, 'start', holdSplashConf.startAnim[(i % 4) + 1].name, holdSplashConf.startAnim[(i % 4) + 1].fps, false)
				addAnimationByPrefix('noteHold'..i, 'hold', holdSplashConf.holdAnim[(i % 4) + 1].name, holdSplashConf.holdAnim[(i % 4) + 1].fps, true)
				addAnimationByPrefix('noteHold'..i, 'end', holdSplashConf.endAnim[(i % 4) + 1].name, holdSplashConf.endAnim[(i % 4) + 1].fps, false)
			else
				addAnimationByPrefix('noteHold'..i, 'start', holdSplashConf.startAnim.name, holdSplashConf.startAnim.fps, false)
				addAnimationByPrefix('noteHold'..i, 'hold', holdSplashConf.holdAnim.name, holdSplashConf.holdAnim.fps, true)
				addAnimationByPrefix('noteHold'..i, 'end', holdSplashConf.endAnim.name, holdSplashConf.endAnim.fps, false)
			end
			playAnim('noteHold'..i, 'hold', true)
			scaleObject('noteHold'..i, holdSplashConf.scale, holdSplashConf.scale)
			setObjectCamera('noteHold'..i, 'hud')
			setProperty('noteHold'..i..'.visible', false)
			addToGroup('noteGroup', 'noteHold'..i)

			if pixelSplash then
				setSpriteShader('noteHold'..i, 'pixelsplash')
				setShaderFloat('noteHold'..i, 'pixelsize', 6)
			end
		end
		daHoldConfig = {offsetX = holdSplashConf.offset.x, offsetY = holdSplashConf.offset.y}
	end
	
	if not foundSkin then doSplash(nil, currentSkin, nil, true) end
end

function goodNoteHit(id,nd,nt,isn)
	if not isn and getProperty('notes.members['..id..'].noteSplashData.disabled') == false and getProperty('notes.members['..id..'].rating') == 'sick' and not disableSkin then
		doSplash(nd, currentSkin, pixelSplash)
	end

	if not holdsEnabled then return end
	if isn then
		if not stringEndsWith(getProperty('notes.members['..id..'].animation.curAnim.name'), 'end') then
			cancelTimer('noteHold'..(nd + 4))
			runTimer('noteHold'..(nd + 4), stepCrochet / 900 / playbackRate)
		end

		if getProperty('noteHold'..(nd + 4)..'.visible') == false and holdsSplashHold[nd + 5] == 0 then
			setProperty('noteHold'..(nd + 4)..'.visible', true)
			playAnim('noteHold'..(nd + 4), 'start', true)
		end
		if stringEndsWith(getProperty('notes.members['..id..'].animation.curAnim.name'), 'end') then cancelTimer('noteHold'..(nd + 4)) playAnim('noteHold'..(nd + 4), 'end', true) holdsSplashHold[nd + 5] = 0 end
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if not holdsEnabled then return end
	if isn then
		if not stringEndsWith(getProperty('notes.members['..id..'].animation.curAnim.name'), 'end') then
			cancelTimer('noteHold'..nd)
			runTimer('noteHold'..nd, stepCrochet / 900 / playbackRate)
		end

		if getProperty('noteHold'..nd..'.visible') == false and holdsSplashHold[nd + 1] == 0 then
			setProperty('noteHold'..nd..'.visible', true)
			playAnim('noteHold'..nd, 'start', true)
		end
		if stringEndsWith(getProperty('notes.members['..id..'].animation.curAnim.name'), 'end') then cancelTimer('noteHold'..nd) setProperty('noteHold'..nd..'.visible', false) holdsSplashHold[nd + 1] = 0 end
	end
end

function doSplash(data, skin, pixel, precache)
	data = data or 0
	local x, y = getProperty('playerStrums.members['..data..'].x') or 0, getProperty('playerStrums.members['..data..'].y') or 0
	local tag = 'dasplash_'..math.floor(math.min(getSongPosition(), 0))..data

	local indicesAnim = false
	local indicesList = {}
	local offsets = {x = -70, y = -30}
	local animName = 'Squirt'
	local framerate = 24
	local scale = 1
	local lifeTime = 0.5

	local foundSkin = false
	for _,splashes in ipairs(specialSplashes) do
		for _,songs in ipairs(splashes.songs) do if songPath == songs then foundSkin = true end end
		if foundSkin then
			if splashes.offset ~= nil then offsets = {x = splashes.offset.x, y = splashes.offset.y} end
			if splashes.framerate ~= nil then framerate = splashes.framerate end
			if splashes.scale ~= nil then scale = splashes.scale end
			if splashes.lifeTime ~= nil then lifeTime = splashes.lifeTime end
			if splashes.animations ~= nil then
				if #splashes.animations > 1 then animName = splashes.animations[data + 1]
				elseif #splashes.animations == 1 then animName = splashes.animations[1] end
			end
			if splashes.indices ~= nil then
				indicesAnim = true
				indicesList = splashes.indices
			end
			if splashes.isRandom == true then animName = animName:gsub('{KEY}', getRandomInt(1,2)) end

			break
		end
	end

	makeAnimatedLuaSprite(tag, 'exeSplashes/'..skin, x + offsets.x, y + offsets.y)
	scaleObject(tag, scale, scale)
	if indicesAnim then
		addAnimationByIndices(tag, 'splash', animName, indicesList, framerate, false)
	else
		addAnimationByPrefix(tag, 'splash', animName, framerate, false)
	end
	playAnim(tag, 'splash', true)
	setObjectCamera(tag, 'hud')
	addToGroup('noteGroup', tag, getObjectOrder('grpNoteSplashes', 'noteGroup'))

	if pixel then
		setSpriteShader(tag, 'pixelsplash')
		setShaderFloat(tag, 'pixelsize', 6)
	end

	runTimer(tag, lifeTime / playbackRate)
	if precache then setProperty(tag..'.alpha', 0.0001) end
end

function onUpdatePost(e)
	if songPath == 'you-cant-run' and curBeat >= 132 and curBeat < 200 and not pixelSplash then pixelSplash = true
	elseif songPath == 'you-cant-run' and curBeat >= 200 and pixelSplash then pixelSplash = false end

	if not holdsEnabled then return end
	for i = 0,7 do
		if getProperty('noteHold'..i..'.visible') then
			holdsSplashHold[i + 1] = holdsSplashHold[i + 1] + e * playbackRate
			if getProperty('noteHold'..i..'.animation.curAnim.finished') then
				local name = getProperty('noteHold'..i..'.animation.curAnim.name')
				if name == 'start' then playAnim('noteHold'..i, 'hold', true) end
				if name == 'end' then setProperty('noteHold'..i..'.visible', false) holdsSplashHold[i + 1] = 0 end
			end

			local dastrum = ((getProperty('strumLineNotes.length') > 8 and i > 5) and (i + 1) or i)
			callMethod('noteHold'..i..'.setPosition', {getProperty('strumLineNotes.members['..dastrum..'].x') + daHoldConfig.offsetX, getProperty('strumLineNotes.members['..dastrum..'].y') + daHoldConfig.offsetY})
		end
	end
end

function onEvent(n,v1,v2)
	if n == 'changenoteSkin' then
		if v1 == 'NOTE_assets_ENDLESS' then
			currentSkin = 'noteSplashes-endless-us'
			for i = 0,7 do
				loadFrames('noteHold'..i, 'exeSplashes/holds/noteSplashesHOLD-endless-us')
				addAnimationByPrefix('noteHold'..i, 'start', holdSplashConf.startAnim[(i % 4) + 1].name, holdSplashConf.startAnim[(i % 4) + 1].fps, false)
				addAnimationByPrefix('noteHold'..i, 'hold', holdSplashConf.holdAnim[(i % 4) + 1].name, holdSplashConf.holdAnim[(i % 4) + 1].fps, true)
				addAnimationByPrefix('noteHold'..i, 'end', holdSplashConf.endAnim[(i % 4) + 1].name, holdSplashConf.endAnim[(i % 4) + 1].fps, false)
				playAnim('noteHold'..i, 'hold', true)
			end
		end
	end
end

function noteMiss(id,nd,nt,isn)
	if not holdsEnabled then return end
	if isn then
		setProperty('noteHold'..(nd + 4)..'.visible', false)
	end
end

function onTimerCompleted(tag)
	if tag:match('dasplash') then
		removeFromGroup('noteGroup', _, tag)
		removeLuaSprite(tag, true)
	end
	if stringStartsWith(tag, 'noteHold') then
		setProperty(tag..'.visible', false)
	end
end