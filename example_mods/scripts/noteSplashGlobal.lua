local specialSplashes = {
	{ --the normal splash
		skin = "noteSplashes",
		songs = {"chaos", "sunshine", "hollow", "pre-design", "personel", "endless-us"},
		offset = {
			x = -75,
			y = -100
		},
		single = false,
		animations = {'note impact {KEY} purple', 'note impact {KEY} blue', 'note impact {KEY} green', 'note impact {KEY} red'},
		lifeTime = 0.18,
		isRandom = true
	},

	{
		skin = "sunky_splash",
		songs = {"chocolate-milk", "vanilla-milk"},
		offset = {
			x = -110,
			y = -150
		},
		framerate = 30,
		single = false,
		animations = {'purple', 'blue', 'green', 'red'},
		indices = {0,1,2,3,4,5,6,7,8,9,10,11},
		scale = 0.8
	},
	{
		skin = "BloodSplash-sanic",
		songs = {"too-fest"},
	},
	{
		skin = "BloodSplash-mono",
		songs = {"monochromatic"},
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
		isRandom = true
	}
}
local pixelSplashesList = {"prey", "b4cksl4sh", "starline", "fatality"}
local blacklistenedSongs = {"round-a-bout"}





--DONT TOUCH

local disableSkin = false
local currentSkin = 'BloodSplash'
local pixelSplash = false
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

			break
		end
	end
	if not foundSkin then doSplash(nil, currentSkin, nil, true) end
end

function goodNoteHit(id,nd,nt,isn)
	if not isn and getProperty('notes.members['..id..'].noteSplashData.disabled') == false and getProperty('notes.members['..id..'].rating') == 'sick' and not disableSkin then
		doSplash(nd, currentSkin, pixelSplash)
	end
end

function doSplash(data, skin, pixel, precache)
	data = data or 0
	local x, y = getProperty('playerStrums.members['..data..'].x'), getProperty('playerStrums.members['..data..'].y')
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

function onUpdatePost()
	if songPath == 'you-cant-run' and curBeat >= 132 and curBeat < 200 and not pixelSplash then pixelSplash = true
	elseif songPath == 'you-cant-run' and curBeat >= 200 and pixelSplash then pixelSplash = false end
end

function onEvent(n,v1,v2)
	if n == 'changenoteSkin' then
		if v1 == 'NOTE_assets_ENDLESS' then
			currentSkin = 'noteSplashes-endless-us'
		end
	end
end

function onTimerCompleted(tag)
	if tag:match('dasplash') then
		removeFromGroup('noteGroup', _, tag)
		removeLuaSprite(tag, true)
	end
end