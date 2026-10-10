local specialSplashes = {
	{ --the normal splash
		skin = "noteSplashes",
		songs = {"chaos", "sunshine", "hollow", "pre-design", "personel", "endless-us", "mania", "shocker", "flash"},
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
		skin = "noteSplashes-flash",
		songs = {"flash"},
		single = false,
		startWithSkin = false
	},
	{
		skin = "noteSplashes-flash2",
		songs = {"flash"},
		single = false,
		startWithSkin = false
	},
	{
		skin = "noteSplashes-flash3",
		songs = {"flash"},
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
	},
	{
		skin = 'BloodSplashPixel',
		songs = {"prey", "b4cksl4sh", "starline", "fatality", "longstrider", "burning", "expulsion"},
		offset = {
			x = -78,
			y = -36
		},
		scale = 6,
		antialiasing = false,
		holdConfig = {
			skin = 'BloodSplashPixelHOLD',
			scale = 6,
			antialiasing = false,
			offset = {
				x = -102,
				y = -42
			},
			startAnim = {name = 'sustain cover intro', fps = 1},
			holdAnim = {name = 'sustain cover loop', fps = 1},
			endAnim = {name = 'sustain cover end', fps = 1}
		}
	}
}

local blacklistenedSongs = {}
local opponentHoldSplashesDisabled = false
local isMobile = false;

--DONT TOUCH

local holdsSplashTimer = {0,0,0,0,0,0,0,0}
local daHoldConfig = {offsetX = 0, offsetY = 0}
local holdsEnabled = true
local currentSkin = 'BloodSplash'

local holdSplashConf = {
	skin = 'BloodSplashHOLD',
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
	local foundSkin = false
	for _,splashes in ipairs(specialSplashes) do
		for _,songs in ipairs(splashes.songs) do if songPath == songs then foundSkin = true end end
		if foundSkin then
			if splashes.single ~= false then
				if splashes.startWithSkin ~= false then currentSkin = splashes.skin end
				doSplash(nil, splashes.skin, true)
			else for i = 0,3 do
				if splashes.startWithSkin ~= false then currentSkin = splashes.skin end
				doSplash(i, splashes.skin, true)
			end end

			if splashes.holdConfig.disabled then holdsEnabled = false
			else
				if splashes.skin ~= nil then holdSplashConf.skin = splashes.skin..'HOLD' end
				if splashes.holdConfig.skin ~= nil then holdSplashConf.skin = splashes.holdConfig.skin end
				if splashes.holdConfig.scale ~= nil then holdSplashConf.scale = splashes.holdConfig.scale end
				if splashes.holdConfig.antialiasing ~= nil then holdSplashConf.antialiasing = splashes.holdConfig.antialiasing else holdSplashConf.antialiasing = getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing') end
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
            local dastrum = ((getProperty('strumLineNotes.length') > 8 and i > 5) and (i + 1) or i)
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
            setProperty('noteHold'..i..'.alpha', getProperty('strumLineNotes.members['..dastrum..'].alpha'))
            setProperty('noteHold'..i..'.antialiasing', holdSplashConf.antialiasing)
            addToGroup('noteGroup', 'noteHold'..i)
        end
        daHoldConfig = {offsetX = holdSplashConf.offset.x, offsetY = holdSplashConf.offset.y}
    end
	
	if not foundSkin then doSplash(nil, currentSkin, true) end

	isMobile = (buildTarget == 'android' or buildTarget == 'ios');
	opponentHoldSplashesDisabled = isMobile and getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') and (getPropertyFromClass('backend.ClientPrefs', 'data.middlescrollType') == 'mobile' or getPropertyFromClass('backend.ClientPrefs', 'data.mobileOpponentNotes'));
end

function goodNoteHit(id,nd,nt,isn) if not isn and getProperty('notes.members['..id..'].noteSplashDisabled') == false and getProperty('notes.members['..id..'].rating') == 'sick' then doSplash(nd, currentSkin) end end

-- new system
function goodNoteHitPre(id,nd,nt,isn)
    if not holdsEnabled then return end
    local strumIdx = nd + 4
    local noteHold = 'noteHold'..strumIdx
    if isn then holdsSplashTimer[strumIdx] = 0 end
    if not isn and getProperty('notes.members['..id..'].tail.length') > 0 then
        holdsSplashTimer[nd] = 0
        local dastrum = ((getProperty('strumLineNotes.length') > 8 and strumIdx > 5) and (strumIdx + 1) or strumIdx)
        if getProperty('strumLineNotes.members['..dastrum..'].visible') then
            setProperty(noteHold..'.visible', true)
            playAnim(noteHold, 'start', true)
        end
    end
end

function opponentNoteHitPre(id,nd,nt,isn)
    if not holdsEnabled or opponentHoldSplashesDisabled then return end
    local noteHold = 'noteHold'..nd
    if isn then holdsSplashTimer[nd] = 0 end
    if not isn and getProperty('notes.members['..id..'].tail.length') > 0 then
        holdsSplashTimer[nd] = 0
        local dastrum = ((getProperty('strumLineNotes.length') > 8 and nd > 5) and (nd + 1) or nd)
        if getProperty('strumLineNotes.members['..dastrum..'].visible') then
            setProperty(noteHold..'.visible', true)
            playAnim(noteHold, 'start', true)
        end
    end
end

local tryAndChange = false
function doSplash(data, skin, precache)
	data = data or 0
	local x, y = getProperty('playerStrums.members['..data..'].x') or 0, getProperty('playerStrums.members['..data..'].y') or 0
	local tag = 'dasplash_'..math.floor(math.min(getSongPosition(), 0))..data

	local indicesAnim = false
	local indicesList = {}
	local offsets = {x = -70, y = -30}
	local animName = 'Squirt'
	local framerate = 24
	local scale = 1
	local antialiasing = getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing')
	local lifeTime = 0.5

	if tryAndChange then
		for _,splashes in ipairs(specialSplashes) do
			if currentSkin == splashes.skin then
				if splashes.offset ~= nil then offsets = {x = splashes.offset.x, y = splashes.offset.y} end
				if splashes.framerate ~= nil then framerate = splashes.framerate end
				if splashes.scale ~= nil then scale = splashes.scale end
				if splashes.lifeTime ~= nil then lifeTime = splashes.lifeTime end
				if splashes.antialiasing ~= nil then antialiasing = splashes.antialiasing end
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
	else
		local foundSkin = false
		for _,splashes in ipairs(specialSplashes) do
			for _,songs in ipairs(splashes.songs) do if songPath == songs then foundSkin = true end end
			if foundSkin then
				if splashes.offset ~= nil then offsets = {x = splashes.offset.x, y = splashes.offset.y} end
				if splashes.framerate ~= nil then framerate = splashes.framerate end
				if splashes.scale ~= nil then scale = splashes.scale end
				if splashes.lifeTime ~= nil then lifeTime = splashes.lifeTime end
				if splashes.antialiasing ~= nil then antialiasing = splashes.antialiasing end
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
	setProperty(tag..'.antialiasing', antialiasing)
	addToGroup('noteGroup', tag, getObjectOrder('strumLineNotes', 'noteGroup') + 1)

	runTimer(tag, lifeTime / playbackRate)
	if precache then setProperty(tag..'.alpha', 0.0001) end
end

function onUpdatePost(e)
    if not holdsEnabled then return end
    for i = 0,getProperty('notes.length')-1 do
        local note = 'notes.members['..i..']'
        if getProperty(note..'.isSustainNote') and getProperty(note..'.parent.wasGoodHit') then
            if getProperty(note..'.strumTime') == getProperty(note..'.parent.tail['..(getProperty(note..'.parent.tail.length') - 1)..'].strumTime') and getSongPosition() >= getProperty(note..'.parent.strumTime') + getProperty(note..'.parent.sustainLength') and not getProperty(note..'.noteWasHit') then
                if getProperty(note..'.mustPress') then
                    playAnim('noteHold'..(getProperty(note..'.noteData') + 4), 'end', true)
                else
                    setProperty('noteHold'..getProperty(note..'.noteData')..'.visible', false)
                    holdsSplashTimer[getProperty(note..'.noteData')] = 0
                end
                setProperty(note..'.noteWasHit', true)
            end
        end
    end
    for i = 0,7 do
        local dastrum = ((getProperty('strumLineNotes.length') > 8 and i > 5) and (i + 1) or i)
        local strumAlpha = getProperty('strumLineNotes.members['..dastrum..'].alpha') or 1
        local strumVisible = getProperty('strumLineNotes.members['..dastrum..'].visible')

        setProperty('noteHold'..i..'.alpha', strumAlpha)

        if not strumVisible or strumAlpha <= 0 then
            setProperty('noteHold'..i..'.visible', false)
        end

        if getProperty('noteHold'..i..'.visible') then
            holdsSplashTimer[i] = holdsSplashTimer[i] + e * playbackRate
            if holdsSplashTimer[i] > (stepCrochet / (1000 / (1.5 * playbackRate)) / playbackRate) and getProperty('noteHold'..i..'.animation.curAnim.name') ~= 'end' then
                setProperty('noteHold'..i..'.visible', false)
            end

            if getProperty('noteHold'..i..'.animation.curAnim.finished') then
                local name = getProperty('noteHold'..i..'.animation.curAnim.name')
                if name == 'start' then playAnim('noteHold'..i, 'hold', true) end
                if name == 'end' then setProperty('noteHold'..i..'.visible', false) holdsSplashTimer[i] = 0 end
            end

            callMethod('noteHold'..i..'.setPosition', {getProperty('strumLineNotes.members['..dastrum..'].x') + daHoldConfig.offsetX, getProperty('strumLineNotes.members['..dastrum..'].y') + daHoldConfig.offsetY})
        end
    end
end

local pixelxdxd = false
function onEvent(n,v1,v2)
    if n == 'changenoteSkin' then
		if songPath == 'universal-collapse' then return end
        local targetPath = nil

        if v1 == 'NOTE_assets_ENDLESS' then
            currentSkin = 'noteSplashes-endless-us'
            targetPath = 'exeSplashes/holds/noteSplashesHOLD-endless-us'
        elseif v1 == 'NOTE_assets_FLASH' then
            currentSkin = 'noteSplashes-flash'
            targetPath = 'exeSplashes/holds/noteSplashesHOLD-flash'
        elseif v1 == 'NOTE_assets_FLASH2' then
            currentSkin = 'noteSplashes-flash2'
            targetPath = 'exeSplashes/holds/noteSplashesHOLD-flash2'
        elseif v1 == 'NOTE_assets_FLASH3' then
            currentSkin = 'noteSplashes-flash3'
            targetPath = 'exeSplashes/holds/noteSplashesHOLD-flash3'
        elseif v1 == 'NOTE_assets' then
            currentSkin = 'noteSplashes'
            targetPath = 'exeSplashes/holds/noteSplashes'
        end

        if targetPath ~= nil then
            for i = 0,7 do
				cancelTimer('noteHold'..i)

				setProperty('noteHold'..i..'.visible', false)

                loadFrames('noteHold'..i, targetPath)
                addAnimationByPrefix('noteHold'..i, 'start', holdSplashConf.startAnim[(i % 4) + 1].name, holdSplashConf.startAnim[(i % 4) + 1].fps, false)
                addAnimationByPrefix('noteHold'..i, 'hold', holdSplashConf.holdAnim[(i % 4) + 1].name, holdSplashConf.holdAnim[(i % 4) + 1].fps, true)
                addAnimationByPrefix('noteHold'..i, 'end', holdSplashConf.endAnim[(i % 4) + 1].name, holdSplashConf.endAnim[(i % 4) + 1].fps, false)
				holdsSplashTimer[i] = 0
            end
        end
    end

    if n == 'Swap Pixel Combo' then
        pixelxdxd = not pixelxdxd
        if pixelxdxd then
            currentSkin = 'BloodSplashPixel'
            tryAndChange = true
            for i = 0,7 do
                loadFrames('noteHold'..i, 'exeSplashes/holds/BloodSplashPixelHOLD')
                addAnimationByPrefix('noteHold'..i, 'start', 'sustain cover intro', 24, false)
                addAnimationByPrefix('noteHold'..i, 'hold', 'sustain cover loop', 24, true)
                addAnimationByPrefix('noteHold'..i, 'end', 'sustain cover end', 24, false)
                setProperty('noteHold'..i..'.antialiasing', false)
                scaleObject('noteHold'..i, 6, 6)
                daHoldConfig = {offsetX = -102, offsetY = -42}
                if getProperty('noteHold'..i..'.visible') then playAnim('noteHold'..i, 'hold', true) end
				holdsSplashTimer[i] = 0
            end
        else
            currentSkin = 'BloodSplash'
            tryAndChange = false
            for i = 0,7 do
                loadFrames('noteHold'..i, 'exeSplashes/holds/BloodSplashHOLD')
                addAnimationByPrefix('noteHold'..i, 'start', 'sustain cover intro', 24, false)
                addAnimationByPrefix('noteHold'..i, 'hold', 'sustain cover loop', 24, true)
                addAnimationByPrefix('noteHold'..i, 'end', 'sustain cover end', 24, false)
				setProperty('noteHold'..i..'.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing'))
                scaleObject('noteHold'..i, 0.9, 0.9)
                daHoldConfig = {offsetX = -85, offsetY = -62}
                playAnim('noteHold'..i, 'end', true)
                setProperty('noteHold'..i..'.visible', false)
				holdsSplashTimer[i] = 0
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