--Revamped Ultimate Debug Mode (UDM v2) [Psych Engine v1.0.4]
--Script Developed by Dudu.

--Settings and customization for your preferences!
local settings = {
	warnings = true, --Prints some warnings like if you're running this script in an old Psych version. (true by default) [RECOMMENDED]
	alwaysChartingMode = false, --If you want to always be in Charting mode. (false by default)
	blacklistedSongs = {''}, --Table where you can disable the script in certain songs.
	decimals = 1, --Amount of decimals the float numbers show. (2 by default)
	restartInSkipTime = true, --If you want to restart the song everytime you skip time backwards. (true by default) [NOT RECOMMENDED FOR SHITTY PCs]
	cameraBackToNormal = false, --If true, camera will go to its default position after a certain time. (false by default)
	cameraDelay = 3, --Amount of seconds you need to wait before the camera going to its default Position after moving it. Only works if you have 'cameraBackToNormal' enabled. (3 by default)

	--TEXT PREFERENCES
	textFont = 'pixel-latin.ttf', --Font every debug text will use ('pixel-latin.ttf' by default) [NOT RECOMMENDED]
	debugText = 'You are in Debug Mode!', --Custom text to display in the debug warning. (leave blank to disable.) ('You are in Debug Mode!' by default)
	debugTextColor = 'FF0000', --Color in HEX for the custom debug text (FF0000 by default)
	botplayText = 'BOTPLAY', --Custom BOTPLAY text to display when Bot Play is enabled. ('BOTPLAY' by default)
	practiceText = 'PRACTICE', --Custom PRACTICE MODE text to display when Practice Mode is enabled. ('PRACTICE' by default)

	--CUSTOMIZATION (OPTIONAL)
	americanDate = false, --If true, date format will be MM/DD/YYYY. If false, it will be DD/MM/YYYY. (false by default)
	twentyFourFormat = true, --If true, the hour format will be from 00:00 to 23:59. If false, it will be AM/PM. (true by default)
	sounds = false, --Enable sounds when doing an action? (true by default.)
	boxColors = {'540B15', 'D3001C', '110204'}, --First Value is Title (Minimized), second is Title (Selected or Maximized) and third is the content box. (Default values: '000000', 'FFFFFF', '000000')
	hitboxColors = {
		['dad'] = 'FF0000',
		['boyfriend'] = '00FFFF',
		['gf'] = 'FF00FF'
	},
	hitboxByDefault = false,
	gridByDefault = false
}

--Keybinds so you don't use those boring default keys :)
local debugKeys = {
	startDebug = 'F1', --The key where you enable / disable the Debug mode. (F1 by default)
	help = 'TAB', --The key where you open the debug help page. (TAB by default)
	resetBoxPositions = 'F2', --The key which restart all the boxes default positions. (F2 by default)

	saveStampData = 'SPACE', --The key for stamp useful data (SPACE by default)
	resetCharsPositions = 'F5', --The key which restart all character default properties (F5 by default)
	hideHUD = 'C', --The key that toggles HUD Visibility (C by default)
	hideDebug = 'F12', --The key that toggles Debug Camera Visibility (F12 by default)
	toggleBotplay = 'B', --The key that toggles Botplay (B by default)
	togglePractice = 'V', --The key that toggles Practice Mode (V by default)
	takeScreenshot = 'F6', --The key that takes a screenshot (F6 by default)
	toggleHitboxes = 'H', --The key that toggles character hitboxes (H by default)
	toggleGrid = 'G', --The key that toggles camera grid (G by default)

	skipTime = {'F7', 'F8'}, --Skip time keys, first for backwards and second for forwards (F7 and F8 by default)
	scrollSpeed = {'F3', 'F4', 'Y'}, --Scroll Speed keys, first for backwards, second for forwards and third for restart (F3, F4 and Y by default)
	playBackRate = {'N', 'M', 'U'}, --Playback Rate keys, first for backwards, second for forwards and third for restart (N, M and U by default)
	restartSong = 'F9', --The key that restarts the song (F9 by default)
	exitSong = 'F10',--The key that exits the song (F10 by default)

	camera = {
		move = {'J', 'K', 'I', 'L'}, --Move camera, LEFT, DOWN, UP, RIGHT. (J, K, I, L by default)
		zoom = {'Q', 'E'}, --Zoom camera, first for zoom out and second for zoom in (Q, E by default)
		reset = 'T' --Reset camera modifications (T by default)
	},
}

	--=====[IF YOU FIND A BUG]=====--
-- 1.- Explain your bug (can be a screenshot or a description)
-- 2.- Did you modified something in the script?
-- 3.- Did the bug broke the script? (like you can still use it)
-- 4.- Provide more information (like your current Psych Engine version, if you're in Mobile, etc..)





--Ok from now you shouldn't touch or edit anything since here starts the actual code!
--Btw if you know what you're doing, i made the code very easy to understand!





--RUDM Variables
local inDebugMode = false
local boxProps = {}
local draggingBox = nil
local mouseProps = {
	prevPos = {x = 0, y = 0},
	delta = {x = 0, y = 0}
}

--Other Variables
local selectedChar = nil
local lastClick = 0
local startedSong = false
local oppHits = 0
local totalNotes = 0
local totalOppNotes = 0
local totalScore = 0
local highCombo = 0
local lastShot = ''
practiceSine = 0
local npsNotes = {}
local nps = 0
local maxNps = 0
local ogValues = {
	scrollSpeed = 1,
	playback = 1,
	camZoom = 1,
	camPos = {0, 0}
}

local savedCharProp = {
	boyfriend = {x = 0, y = 0, alpha = 1, angle = 0},
	dad = {x = 0, y = 0, alpha = 1, angle = 0},
	gf = {x = 0, y = 0, alpha = 1, angle = 0}
}

function onCreate() -- im sorry but if you're using a very old version of PE it will not load code outside callbacks :(
	if settings.warnings and not version:match('1.0') then
		debugPrint('[RUDM_Warning]: This script might not work properly on Psych Engine v'..version..' because it was made for a certain version. Try using the supported version. (1.0.X)', 'FF0000')
		luaDebugMode = true
		luaDeprecatedWarnings = true
	end
	for i = 1,#settings.blacklistedSongs do if songName == settings.blacklistedSongs[i] then close() end end
	if settings.alwaysChartingMode then setPropertyFromClass('states.PlayState', 'chartingMode', true) end
end

function onCreatePost()
	createInstance('camDebug', 'flixel.FlxCamera', {})
	setProperty('camDebug.bgColor', 0x0)
	setVar('camDebug', instanceArg('camDebug'))

	createInstance('camDebug2', 'flixel.FlxCamera', {})
	setProperty('camDebug2.bgColor', 0x0)
	setProperty('camDebug2.visible', false)
	setVar('camDebug2', instanceArg('camDebug2'))

	createInstance('camPause', 'flixel.FlxCamera', {})
	setProperty('camPause.bgColor', 0x0)
	setVar('camPause', instanceArg('camPause'))

	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camDebug'), false})
	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camDebug2'), false})
	callMethodFromClass('flixel.FlxG', 'cameras.add', {instanceArg('camPause'), false})

	createInstance('hideDebugCheck', 'flixel.addons.display.shapes.FlxShapeCircle', {10, 10, 10, {thickness = 2, pixelHinting = false}, getColorFromHex('FF0000')})
	setProperty('hideDebugCheck.camera', instanceArg('camDebug2'), false, true)
	addInstance('hideDebugCheck')
	makeLuaText('hideDebugTxt', 'Debug Camera is currently Hidden! - Press '..debugKeys.hideDebug..' to return.', 0, 40, 10)
	setTextSize('hideDebugTxt', 12)
	setTextBorder('hideDebugTxt', 1, '000000')
	setTextFont('hideDebugTxt', settings.textFont)
	setProperty('hideDebugTxt.camera', instanceArg('camDebug2'), false, true)
	addLuaText('hideDebugTxt')

	makeLuaText('debugText', settings.debugText, screenWidth, 0, 10)
	setTextSize('debugText', 10)
	setTextColor('debugText', settings.debugTextColor)
	setTextFont('debugText', settings.textFont)
	setProperty('debugText.camera', instanceArg('camDebug'), false, true)
	if (settings.debugText):gsub(' ', '') ~= '' then addLuaText('debugText') end

	--If you wanna make a custom box? here: makeDebugBox(tag:String, x:Float = 0, y:Float = 0, title:String, content:String, ?whiteTitle:Bool = false, ?alignment:String = 'Left')
	makeDebugBox('songInfo', 10, 10, 'Song Information', 'Sorry! The Song Information is empty... Check back later!')
	makeDebugBox('chartInfo', 10, 201 + (isStoryMode and 10 or 0), 'Chart Information', 'Sorry! The Chart Information is empty... Check back later!')
	makeDebugBox('charInfo', 10, 469 + (isStoryMode and 10 or 0), 'Character Information', 'Boyfriend?: Null!\nOpponent?: Null aswell!\nGirlfriend?: she\'s too hot...')
	makeDebugBox('playerInfo', screenWidth - 10, 10, 'Player Information', 'Erm erm... Hello??!! No Player info yet!', 'Right')
	makeDebugBox('generalInfo', screenWidth - 10, 266 + (isStoryMode and 33 or 0), 'General Information', 'No general INFO... WAAAAAA', 'Right')
	makeDebugBox('prefsInfo', screenWidth - 10, 424 + (currentModDirectory ~= '' and 10 or 0) + (isStoryMode and 33 or 0), 'Client Preferences', 'um um where is it? hello? anybody there?', 'Right')
	makeDebugBox('stampInfo', 0, 0, 'Stamped Data', 'Sorry! no stamped data yet!\n\nPress "'..debugKeys.saveStampData..'" to start :3!', 'Left', true, 'songInfo')

	--Ig you can remove the watermark stuff (don't do that :cry:)
	makeLuaText('watermarkTxt', 'Revamped Ultimate Debug Mode developed by Dudu.', 0, 10, screenHeight - 21)
	setTextSize('watermarkTxt', 8)
	setTextBorder('watermarkTxt', 0)
	setTextFont('watermarkTxt', settings.textFont)
	setProperty('watermarkTxt.camera', instanceArg('camDebug'), false, true)
	makeLuaSprite('watermark', nil, 5, screenHeight - 24)
	makeGraphic('watermark', getTextGraphicSize('watermarkTxt').width + 12, getTextGraphicSize('watermarkTxt').height + 8, '000000')
	setProperty('watermark.alpha', 0.6)
	setProperty('watermark.camera', instanceArg('camDebug'), false, true)
	addLuaSprite('watermark')
	addLuaText('watermarkTxt')

	setTextString('botplayTxt', settings.botplayText)
	makeLuaText('practiceTxt', settings.practiceText, screenWidth - 800, 400, getProperty('healthBar.y') + (downscroll and (70 + 32) or (-90 - 32)))
	setTextAlignment('practiceTxt', 'Center')
	setTextSize('practiceTxt', 32)
	setTextBorder('practiceTxt', 1.25, '000000')
	setObjectCamera('practiceTxt', 'hud')
	setProperty('practiceTxt.visible', getProperty('practiceMode'))
	addToGroup('uiGroup', 'practiceTxt', getObjectOrder('botplayTxt', 'uiGroup'))

	makeLuaText('helpTxt', 'Press '..(debugKeys.help)..' to open Debug Mode Help page.', screenWidth - 20, 10)
	setTextSize('helpTxt', 12)
	setTextAlignment('helpTxt', 'Right')
	setTextBorder('helpTxt', 1, '000000')
	setTextFont('helpTxt', settings.textFont)
	setObjectCamera('helpTxt', 'other')
	setProperty('helpTxt.y', screenHeight - 10 - getTextGraphicSize('helpTxt').height)
	addLuaText('helpTxt')

	for _,hb in ipairs({'dad', 'boyfriend', 'gf'}) do
		if hb == 'gf' and not getProperty('gf') then break end
		local tag = hb..'Hitbox'
		makeLuaSprite(tag, nil, getProperty(hb..'.x'), getProperty(hb..'.y'))
		makeGraphic(tag, getProperty(hb..(getProperty(hb..'.isAnimateAtlas') and '.atlas.width' or '.width')), getProperty(hb..(getProperty(hb..'.isAnimateAtlas') and '.atlas.height' or '.height')), settings.hitboxColors[hb])
		setProperty(tag..'.alpha', 0.25)
		addLuaSprite(tag)
		setScrollFactor(tag, getProperty(hb..'.scrollFactor.x'), getProperty(hb..'.scrollFactor.y'))
		setObjectOrder(tag, getObjectOrder(hb..'Group') + 1)
		setProperty(tag..'.visible', false)
	end

	makeCrosses()
	makeGrid()

	toggleDebug(false, false)

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then totalNotes = totalNotes + 1 else totalOppNotes = totalOppNotes + 1 end
		end
	end
	totalScore = 350 * totalNotes

	--setPropertyFromClass('Main','fpsVar.visible', false)

	ogValues = {
		scrollSpeed = scrollSpeed,
		playback = playbackRate,
		camZoom = getProperty('defaultCamZoom'),
		camPos = {getProperty('camFollow.x'), getProperty('camFollow.y')}
	}
	saveCharsProps()
end

function onDestroy()
	if getPropertyFromClass('backend.ClientPrefs', 'data.showFPS') then
		setPropertyFromClass('Main','fpsVar.visible', true)
	end
end

local gameMouse = {
	delta = {x = 0, y = 0},
	prev = {x = 0, y = 0}
}
local moved = false
local savedTime = 0
local bruh = 0
local zoom = 1
local totalMemory = 0
local cantSelect = false
function onUpdatePost(e)
	if getPropertyFromClass('flixel.FlxG', 'mouse.visible') == false then
		setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)
	end

	if keyboardJustPressed(debugKeys.help) then
		--yayy
		if settings.sounds then playSound('scrollMenu', 0.4) end
		openCustomSubstate('helpSubstate', true)
	end
	bruh = bruh + e / 2
	setProperty('helpTxt.alpha', 1.025 - math.sin(bruh))

	if keyboardJustPressed(debugKeys.startDebug) and not getProperty('camDebug2.visible') then
		toggleDebug()

		if not settings.cameraBackToNormal then
			cancelTween('yayBackToNormal')
			callMethod('camFollow.setPosition', {ogValues.camPos[1], ogValues.camPos[2]})
			setProperty('isCameraOnForcedPos', false)
			moved = false
		end
	end

	practiceSine = practiceSine + 180 * e
	setProperty('practiceTxt.alpha', 1 - math.sin((math.pi * practiceSine) / 180))
	setProperty('practiceTxt.visible', getProperty('practiceMode'))

	--Take Screenshot
	if keyboardJustPressed(debugKeys.takeScreenshot) then
		if lastShot ~= os.time() then
			saveScreenshot()
			debugPrint('[RUDM] Screenshot taken! saved in: "rudm-screenshots/fnfpe-rudm-screenshot-'..lastShot..'.png"', '00FFAF')
		end
	end

	if inDebugMode then
		local amount = keyboardPressed('CONTROL') and 0.2 or (keyboardPressed('SHIFT') and 5 or 1)
		lastClick = lastClick + e
		mouseProps.delta = {x = runHaxeCode("return FlxG.mouse.getViewPosition(getVar('camDebug'), true).x;") - mouseProps.prevPos.x, y = runHaxeCode("return FlxG.mouse.getViewPosition(getVar('camDebug'), true).y;") - mouseProps.prevPos.y}
		gameMouse.delta = {
			x = (getProperty('camGame.scroll.x') - gameMouse.prev.x) * getProperty('camGame.zoom'),
			y = (getProperty('camGame.scroll.y') - gameMouse.prev.y) * getProperty('camGame.zoom')
		}

		gameMouse.prev = {x = getProperty('camGame.scroll.x'), y = getProperty('camGame.scroll.y')}

		--Text Updating.
		weekCampaign = {'','','',''}
		if isStoryMode then
			weekCampaign = {
				'\nWeek: '..week..' (ID: '..weekRaw ..')',
				'\n\nWeek Score: '..getPropertyFromClass('states.PlayState', 'campaignScore') + score,
				'\nWeek Misses: '..getPropertyFromClass('states.PlayState', 'campaignMisses') + misses,
				'\nWeek Accuracy: ' --STOP I NEED TO FIGURE OUT HOW TO GET CAMPAIGN ACCURACY BUT I WILL MAKE IT POSSIBLE SOON
			}
		end

		--NPS Calculation.
		while #npsNotes > 0 and getSongPosition() - npsNotes[1] > 1000 do
			table.remove(npsNotes, 1)
		end
	
		nps = #npsNotes
		if nps > maxNps then maxNps = nps end

		for _,hb in ipairs({'dad', 'boyfriend', 'gf'}) do
			if hb == 'gf' and not getProperty('gf') then break end
			callMethod(hb..'Hitbox.setPosition', {getProperty(hb..'.x'), getProperty(hb..'.y')})
			if getProperty(hb..'.scrollFactor.x') ~= getProperty(hb..'Hitbox.scrollFactor.x') or getProperty(hb..'.scrollFactor.y') ~= getProperty(hb..'Hitbox.scrollFactor.y') then
				setScrollFactor(hb..'Hitbox', getProperty(hb..'.scrollFactor.x'), getProperty(hb..'.scrollFactor.y'))
			end
			if getProperty(hb..(getProperty(hb..'.isAnimateAtlas') and '.atlas.width' or '.width')) ~= getProperty(hb..'Hitbox.width') or getProperty(hb..(getProperty(hb..'.isAnimateAtlas') and '.atlas.height' or '.height')) ~= getProperty(hb..'Hitbox.height') then
				setGraphicSize(hb..'Hitbox', getProperty(hb..(getProperty(hb..'.isAnimateAtlas') and '.atlas.width' or '.width')), getProperty(hb..(getProperty(hb..'.isAnimateAtlas') and '.atlas.height' or '.height')))
			end
			if getObjectOrder(hb..'Group') ~= getObjectOrder(hb..'Hitbox') + 1 then
				setObjectOrder(hb..'Hitbox', getObjectOrder(hb..'Group') + 1)
			end
		end

		updateBoxText('songInfo',
		'Song Name: '..songName..' ('..songPath..difficultyPath..')\nFreeplay Name: '..(loadedSongName and loadedSongName or 'Not Found')..' ('..(loadedSongPath ~= '' and loadedSongPath or 'Not Found')..')\n'..
		'Difficulty: '..difficultyName..' (ID: '..difficulty..')'..weekCampaign[1]..'\n\nTime Position\n'..callMethodFromClass('flixel.util.FlxStringUtil', 'formatTime', {math.max(0, getSongPosition() / 1000), true})..
		' / '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatTime', {songLength / 1000, true})..' ('..decimal(lerp(0, 100, math.max(0, getSongPosition()) / songLength))..'%)\nTime Left: '..
		callMethodFromClass('flixel.util.FlxStringUtil', 'formatTime', {(math.min(songLength, songLength - getSongPosition())) / 1000, true})..'\n\nStarted Countdown: '..tostring(startedCountdown)..
		'\nStarted Song: '..tostring(startedSong)..'\nSeen Cutscene: '..tostring(seenCutscene)..'\n\nCamera Zoom: '..decimal(getProperty('camGame.zoom'))..' (Default: '..decimal(getProperty('defaultCamZoom'))..')'..'\nProperties: [X: '..
		decimal(getProperty('camFollow.x'))..', Y: '..decimal(getProperty('camFollow.y'))..', Angle: '..decimal(getProperty('camGame.angle'))..', Alpha: '..decimal(getProperty('camGame.alpha'))..']')

		sectionBeats, sectionNotes = getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].sectionBeats') or 0, getPropertyFromClass('states.PlayState', 'SONG.notes['..curSection..'].sectionNotes.length') or 0
		updateBoxText('chartInfo',
		'Current Stage: '..curStage..'\nStage UI: '..getPropertyFromClass('states.PlayState', 'stageUI')..'\nSong Speed: '..decimal(getProperty('songSpeed'))..'\nHas Vocals: '..tostring(hasVocals)..
		'\n\nInitial BPM: '..bpm..'\nCurrent BPM: '..curBpm..'\nPlayback Rate: '..playbackRate..'\n\nMust Hit Section: '..tostring(mustHitSection)..'\nAlt Anim Section: '..tostring((altAnim and altAnim or false))..'\nGF Section: '..tostring((gfSection and gfSection or false))..
		'\nSection Beats: '..sectionBeats..'\nSection Notes: '..sectionNotes..
		'\n\nBeat Crochet: '..string.format('%.'..(settings.decimals)..'f', decimal(crochet))..'\nStep Crochet: '..string.format('%.'..(settings.decimals)..'f', decimal(stepCrochet))..'\n\nCur Section: '..curSection..'\nCur Beat: '..curBeat..' ('..
		string.format('%.'..(settings.decimals)..'f', decimal(math.max(0, curDecBeat)))..')\nCur Step: '..curStep..' ('..string.format('%.'..(settings.decimals)..'f', decimal(math.max(0, curDecStep)))..')')

		gfCheck = ''
		if getProperty('gf') then 
			gfCheck = '\n\nGirlfriend\n• Current Animation: '..(getProperty('gf.animation.name') or (getProperty('gf._lastPlayedAnimation') or 'Not Found'))..' ['..(getProperty('gf.animation.curAnim.curFrame') or (getProperty('gf.atlas.anim.curFrame') or '?'))..'/'..(getProperty('gf.animation.curAnim.numFrames') and (getProperty('gf.animation.curAnim.numFrames') - 1) or ((getProperty('gf.atlas.anim.length') - 1) or '?'))..']\n• Current Character: '..getProperty('gf.curCharacter')..'\n• Properties: [X: '..decimal(getProperty('gf.x'))..', Y: '..decimal(getProperty('gf.y'))..', Angle: '..decimal(getProperty('gf.angle'))..', Alpha: '..decimal(getProperty('gf.alpha'))..']'
		end
		updateBoxText('charInfo',
		'Boyfriend\n• Current Animation: '..(getProperty('boyfriend.animation.name') or (getProperty('boyfriend._lastPlayedAnimation') or 'Not Found'))..' ['..(getProperty('boyfriend.animation.curAnim.curFrame') or (getProperty('boyfriend.atlas.anim.curFrame') or '?'))..'/'..(getProperty('boyfriend.animation.curAnim.numFrames') and (getProperty('boyfriend.animation.curAnim.numFrames') - 1) or ((getProperty('boyfriend.atlas.anim.length') - 1) or '?'))..']\n• Current Character: '..getProperty('boyfriend.curCharacter')..'\n• Properties: [X: '..decimal(getProperty('boyfriend.x'))..', Y: '..decimal(getProperty('boyfriend.y'))..', Angle: '..decimal(getProperty('boyfriend.angle'))..', Alpha: '..decimal(getProperty('boyfriend.alpha'))..']'..
		'\n\nOpponent\n• Current Animation: '..(getProperty('dad.animation.name') or (getProperty('dad._lastPlayedAnimation') or 'Not Found'))..' ['..(getProperty('dad.animation.curAnim.curFrame') or (getProperty('dad.atlas.anim.curFrame') or '?'))..'/'..(getProperty('dad.animation.curAnim.numFrames') and (getProperty('dad.animation.curAnim.numFrames') - 1) or ((getProperty('dad.atlas.anim.length') - 1) or '?'))..']\n• Current Character: '..getProperty('dad.curCharacter')..'\n• Properties: [X: '..decimal(getProperty('dad.x'))..', Y: '..decimal(getProperty('dad.y'))..', Angle: '..decimal(getProperty('dad.angle'))..', Alpha: '..decimal(getProperty('dad.alpha'))..']'..
		gfCheck)

		if combo > highCombo then highCombo = highCombo + 1 end
		updateBoxText('playerInfo',
		'Deaths: '..deaths..'\nCombo: '..combo..' (High Combo: '..highCombo..')\nScore: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatMoney', {score, false})..' (Total Score: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatMoney', {totalScore, false})..')\nAccuracy: '..
		ratingName..' ('..decimal(rating * 100)..'%)'..(ratingFC ~= '' and (' - '..ratingFC) or '')..'\nHealth: '..decimal(getHealth() * 50)..'% ('..(getHealth() < 0.4 and 'Losing' or (getHealth() > 1.6 and 'Winning' or 'Tie'))..')'..weekCampaign[2]..weekCampaign[3]..'\n\nHits: '..hits..
		' (Total: '..totalNotes..')\nOpponent Hits: '..oppHits..' (Total: '..totalOppNotes..')\nNotes Played: '..totalPlayed..'\nTotal Notes Hit: '..totalNotesHit..'\nNPS: '..nps..' (Max. NPS: '..maxNps..')\n\nSicks: '..getProperty('ratingsData[0].hits')..'\nGoods: '..getProperty('ratingsData[1].hits')..
		'\nBads: '..getProperty('ratingsData[2].hits')..'\nShits: '..getProperty('ratingsData[3].hits')..'\nMisses: '..misses..'\n\nBotplay: '..tostring(botPlay)..'\nPractice Mode: '..tostring(getProperty('practiceMode')))

		dayThing, form = {'st', 'nd', 'rd', 'th'}, (os.date('*t').day % 100 >= 11 and os.date('*t').day % 100 <= 13) and 4 or math.min(4, (os.date('*t').day % 10 == 0 and 4 or os.date('*t').day % 10))
		if getPropertyFromClass("Main", "fpsVar.currentMemory") > totalMemory then totalMemory = getPropertyFromClass("Main", "fpsVar.currentMemory") end
		updateBoxText('generalInfo',
		'Psych Engine v'..version..'\nFriday Night Funkin\' v'..runHaxeCode("import lime.app.Application; return Application.current.meta.get('version');")..'\nBuild Target: '..buildTarget..(currentModDirectory ~= '' and ('\nMod Directory: '..currentModDirectory) or '')..
		'\n\nDate: '..os.date(settings.americanDate and "%m/%d/%y" or "%d/%m/%y")..'\n'..os.date('%A, %B %d')..dayThing[form]..'\nTime: '..os.date((settings.twentyFourFormat and "%H:%M:%S" or ("%I:%M:%S "..(tonumber(os.date("%H")) < 12 and 'a. m.' or 'p. m.'))))..'\n\nFPS: '..
		getPropertyFromClass("Main", "fpsVar.currentFPS")..'\nMemory: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatBytes', {getPropertyFromClass("Main", "fpsVar.currentMemory")})..'\nMemory Peak: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatBytes', {totalMemory}))

		updateBoxText('prefsInfo',
		'Language: '..getPropertyFromClass('backend.ClientPrefs', 'data.language')..'\nDownscroll: '..tostring(downscroll)..'\nMiddlescroll: '..tostring(middlescroll)..'\nGhost Tapping: '..tostring(ghostTapping)..'\nGuitar Hero Sustains: '..tostring(guitarHeroSustains)..
		'\nNote Offset: '..noteOffset..'\nOpponent Notes: '..tostring(getPropertyFromClass('backend.ClientPrefs', 'data.opponentStrums'))..'\nFramerate: '..framerate..'\nScore Zoom: '..tostring(scoreZoom)..'\nZoom on Beat: '..tostring(cameraZoomOnBeat)..'\nShaders: '..tostring(shadersEnabled)..
		'\nLow Quality: '..tostring(lowQuality)..'\n Anti-Aliasing: '..tostring(getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing'))..'\nFlashing Lights: '..tostring(flashingLights)..'\n\nInsta-kill on miss: '..tostring(instakillOnMiss)..'\nHealth Gain: '..healthGainMult..
		'\nHealth Loss: '..healthGainMult)

		--Move Camera Function.

		if not moved then
			ogValues.camPos = {getProperty('camFollow.x'), getProperty('camFollow.y')}
			ogValues.camZoom = getProperty('defaultCamZoom')
			zoom = ogValues.camZoom
		else setProperty('camGame.zoom', zoom) end

		if selectedChar == nil then
			--Movement
			if keyboardPressed(debugKeys.camera.move[1]) then
				setProperty('camFollow.x', getProperty('camFollow.x') - (amount * 5))
				updateCamera()
			elseif keyboardPressed(debugKeys.camera.move[4]) then
				setProperty('camFollow.x', getProperty('camFollow.x') + (amount * 5))
				updateCamera()
			end
			if keyboardPressed(debugKeys.camera.move[2]) then
				setProperty('camFollow.y', getProperty('camFollow.y') + (amount * 5))
				updateCamera()
			elseif keyboardPressed(debugKeys.camera.move[3]) then
				setProperty('camFollow.y', getProperty('camFollow.y') - (amount * 5))
				updateCamera()
			end

			--Zooming
			if keyboardPressed(debugKeys.camera.zoom[1]) and zoom > 0.01 then
				zoom = zoom - e * zoom * amount
				updateCamera()
			elseif keyboardPressed(debugKeys.camera.zoom[2]) and zoom < 6 then
				zoom = zoom + e * zoom * amount
				updateCamera()
			end
		end

		--Reset shit
		if keyboardJustPressed(debugKeys.camera.reset) then
			if settings.sounds then playSound('scrollMenu', 0.4) end
			cancelTween('yayBackToNormal')
			callMethod('camFollow.setPosition', {ogValues.camPos[1], ogValues.camPos[2]})
			setProperty('isCameraOnForcedPos', false)
			moved = false
		end

		--Other Functions.

		if keyboardJustPressed(debugKeys.saveStampData) then
			updateBoxText('stampInfo', '- Time Position -\n'..callMethodFromClass('flixel.util.FlxStringUtil', 'formatTime', {math.max(0, getSongPosition() / 1000), true})..' / '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatTime', {songLength / 1000, true})..' ('..decimal(lerp(0, 100, math.max(0, getSongPosition()) / songLength))..'%)\nTime Left: '..
			callMethodFromClass('flixel.util.FlxStringUtil', 'formatTime', {(math.min(songLength, songLength - getSongPosition())) / 1000, true})..'\n\n- Charting Information -\nCurrent BPM: '..curBpm..'\nSong Speed: '..decimal(getProperty('songSpeed'))..'\n\nCur Section: '..curSection..'\nCur Beat: '..curBeat..' ('..string.format('%.'..(settings.decimals)..'f', decimal(math.max(0, curDecBeat)))..
			')\nCur Step: '..curStep..' ('..string.format('%.'..(settings.decimals)..'f', decimal(math.max(0, curDecStep)))..')\n\n- Game Information -\nCombo: '..combo..'\nScore: '..callMethodFromClass('flixel.util.FlxStringUtil', 'formatMoney', {score, false})..'\nMisses: '..misses..'\nAccuracy: '..ratingName..' ('..decimal(rating * 100)..'%)'..(ratingFC ~= '' and (' - '..ratingFC) or '')..
			'\nHealth: '..decimal(getHealth() * 50)..'% ('..(getHealth() < 0.4 and 'Losing' or (getHealth() > 1.6 and 'Winning' or 'Tie'))..')'..weekCampaign[2]..weekCampaign[3]..'\n\nOpponent Hits: '..oppHits..'\nNotes Played: '..totalPlayed..'\nNPS: '..nps..'\n\n- General Information -\nFPS: '..getPropertyFromClass("Main", "fpsVar.currentFPS")..'\nMemory: '..
			callMethodFromClass('flixel.util.FlxStringUtil', 'formatBytes', {getPropertyFromClass("Main", "fpsVar.currentMemory")}))
		end

		--Playback Rate Modifiers
		if keyboardJustPressed(debugKeys.playBackRate[1]) then
			setProperty('playbackRate', math.max(amount / 10, getProperty('playbackRate') - (amount / 10)))
			if settings.sounds then playSound('scrollMenu', 0.4) end
		elseif keyboardJustPressed(debugKeys.playBackRate[2]) then
			setProperty('playbackRate', math.min(3, getProperty('playbackRate') + (amount / 10)))
			if settings.sounds then playSound('scrollMenu', 0.4) end
		elseif keyboardJustPressed(debugKeys.playBackRate[3]) then
			setProperty('playbackRate', ogValues.playback)
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Scroll Speed Modifiers
		if keyboardJustPressed(debugKeys.scrollSpeed[1]) then
			setProperty('songSpeed', math.max(amount / 10, getProperty('songSpeed') - (amount / 10)))
			if settings.sounds then playSound('scrollMenu', 0.4) end
		elseif keyboardJustPressed(debugKeys.scrollSpeed[2]) then
			setProperty('songSpeed', math.min(10, getProperty('songSpeed') + (amount / 10)))
			if settings.sounds then playSound('scrollMenu', 0.4) end
		elseif keyboardJustPressed(debugKeys.scrollSpeed[3]) then
			setProperty('songSpeed', ogValues.scrollSpeed)
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Time Position Modifiers
		if keyboardJustPressed(debugKeys.skipTime[1]) then
			local bruh = getSongPosition() - (1000 * (amount * 2.5))
			if bruh <= 0 then return end
			if settings.restartInSkipTime then
				setPropertyFromClass('states.PlayState', 'startOnTime', bruh)
				restartSong(true)
			else
				callMethod('setSongTime', {bruh})
				callMethod('clearNotesBefore', {bruh})
			end
			if settings.sounds then playSound('scrollMenu', 0.4) end
		elseif keyboardJustPressed(debugKeys.skipTime[2]) then
			local bruh = getSongPosition() + (1000 * (amount * 2.5))
			if bruh >= songLength then return end
			callMethod('setSongTime', {bruh})
			callMethod('clearNotesBefore', {bruh})
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Hide HUD
		if keyboardJustPressed(debugKeys.hideHUD) then
			setProperty('camHUD.visible', not getProperty('camHUD.visible'))
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Hide Debug Camera
		if keyboardJustPressed(debugKeys.hideDebug) then
			setProperty('camDebug.visible', not getProperty('camDebug.visible'))
			setProperty('camDebug2.visible', not getProperty('camDebug.visible'))
			setProperty('hideDebugCheck.alpha', 0)
			setProperty('hideDebugTxt.alpha', 0)
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end
		setProperty('hideDebugCheck.alpha', lerp(1, getProperty('hideDebugCheck.alpha'), 1 - e * 2))
		setProperty('hideDebugTxt.alpha', lerp(0.1, getProperty('hideDebugTxt.alpha'), 1 - e * 2))

		--Restart song
		if keyboardJustPressed(debugKeys.restartSong) then
			restartSong()
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Exit Song
		if keyboardJustPressed(debugKeys.exitSong) then
			exitSong()
			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Toggle Botplay
		if keyboardJustPressed(debugKeys.toggleBotplay) then
			setProperty('cpuControlled', not botPlay)
			botPlay = not botPlay
			setProperty('botplaySine', 0)
			setProperty('botplayTxt.visible', botPlay)

			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Toggle Practice
		if keyboardJustPressed(debugKeys.togglePractice) then
			setProperty('practiceMode', not getProperty('practiceMode'))
			practiceSine = 0

			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Toggle Character Hitboxes
		if keyboardJustPressed(debugKeys.toggleHitboxes) then
			for _,hb in ipairs({'dad', 'boyfriend', 'gf'}) do
				if hb == 'gf' and not getProperty('gf') then break end
				setProperty(hb..'Hitbox.visible', not getProperty(hb..'Hitbox.visible'))
			end

			if settings.sounds then playSound('scrollMenu', 0.4) end
		end

		--Toggle Camera Grid
		if keyboardJustPressed(debugKeys.toggleGrid) then
			for i = 0,2 do
				setProperty('debug_centerX'..i..'.visible', not getProperty('debug_centerX'..i..'.visible'))
				setProperty('debug_centerY'..i..'.visible', not getProperty('debug_centerY'..i..'.visible'))
			end

			if settings.sounds then playSound('scrollMenu', 0.4) end
		end
		
		--Watermark Utility.
		if luaTextExists('watermarkTxt') then
			setTextColor('watermarkTxt', 'FFFFFF')
			if callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg('watermarkTxt'), instanceArg('camDebug')}) then
				setTextColor('watermarkTxt', '42dcff')

				if mouseClicked() then callMethodFromClass('backend.CoolUtil', 'browserLoad', {'https://x.com/dudugd20'}) end
			end
		end

		--Box dragging system.
		if selectedChar == nil then
			for i, box in ipairs(boxProps) do
				if draggingBox == nil and keyboardJustPressed(debugKeys.resetBoxPositions) then
					box.newX = box.x
					box.newY = box.y
					setBoxPosition(box.tag, box.x, box.y)

					box.isCurLinked = true

					if settings.sounds and getSongPosition() ~= savedTime then playSound('scrollMenu', 0.4) end
					savedTime = getSongPosition()
				end

				if draggingBox ~= nil then
					if mouseReleased() then
						if lastClick < 0.15 then
							setProperty(draggingBox..'.visible', not getProperty(draggingBox..'.visible'))
							setProperty(draggingBox..'-text.visible', not getProperty(draggingBox..'-text.visible'))
							boxTag(draggingBox).minimized = not boxTag(draggingBox).minimized
							lastClick = 0
						end

						boxTag(draggingBox).newX = getProperty(draggingBox..'-title.x') + (boxTag(draggingBox).align == 'right' and getProperty(draggingBox..'-title.width') or 0)
						boxTag(draggingBox).newY = getProperty(draggingBox..'-title.y')

						if boxTag(draggingBox).hasLinkRelation == true then
							local linkedBox = ((boxTag(draggingBox).linkedTo ~= 'none') and boxTag(draggingBox).linkedTo or linkedBy(draggingBox))

							if (boxTag(draggingBox).newX ~= boxTag(draggingBox).x or boxTag(draggingBox).newY ~= boxTag(draggingBox).y) or (boxTag(linkedBox).newX ~= boxTag(linkedBox).x or boxTag(linkedBox).newY ~= boxTag(linkedBox).y) then
								boxTag((boxTag(draggingBox).linkedTo ~= 'none') and draggingBox or linkedBy(draggingBox)).isCurLinked = false
							end
						end

						draggingBox = nil
						break
					else
						setProperty(draggingBox..'-title.color', getColorFromHex(settings.boxColors[2]))
						setProperty(draggingBox..'-title.alpha', 1)
						setBoxPosition(draggingBox, getProperty(draggingBox..'-title.x') + mouseProps.delta.x, getProperty(draggingBox..'-title.y') + mouseProps.delta.y)

						break
					end
				else
					if callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg((box.tag)..'-title'), instanceArg('camDebug')}) and mousePressed() then
						draggingBox = box.tag
						cantSelect = true
						lastClick = 0
						break
					end

					if box.minimized then
						setProperty((box.tag)..'-title.color', getColorFromHex(settings.boxColors[1]))
						setProperty((box.tag)..'-title.alpha', 0.8)
						setTextColor((box.tag)..'-titleTxt', darkColor(settings.boxColors[1]) and 'FFFFFF' or '000000')

						if callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg((box.tag)..'-title'), instanceArg('camDebug')}) then
							setProperty((box.tag)..'-title.color', getColorFromHex(settings.boxColors[2]))
							setTextColor((box.tag)..'-titleTxt', darkColor(settings.boxColors[2]) and 'FFFFFF' or '000000')
							break
						end
					else
						setProperty((box.tag)..'-title.color', getColorFromHex(settings.boxColors[2]))
						setProperty((box.tag)..'-title.alpha', 1)
						setTextColor((box.tag)..'-titleTxt', darkColor(settings.boxColors[2]) and 'FFFFFF' or '000000')
					end

					if box.isCurLinked and box.linkedTo ~= 'none' then
						box.x, box.y = getProperty((box.linkedTo)..'.x') + getProperty((box.linkedTo)..'.width') + 10, getProperty((box.linkedTo)..'-title.y')
						box.newX, box.newY = box.x, box.y
						setBoxPosition((box.tag), box.x, box.y)
					end

					cantSelect = false
					if callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg((box.tag)..'-title'), instanceArg('camDebug')}) then
						cantSelect = true
						break
					end
				end
			end
		end

		if not cantSelect then
			for i,char in ipairs({'boyfriend', 'dad', 'gf'}) do
				if char == 'gf' and not getProperty('gf') then break end
				if selectedChar ~= nil then
					if mouseReleased('right') then
						selectedChar = nil
						break
					end
					if not settings.cameraBackToNormal then updateCamera() end

					if keyboardPressed('SHIFT') then
						setProperty(selectedChar..'.alpha', boundTo(getProperty(selectedChar..'.alpha') + getPropertyFromClass('flixel.FlxG', 'mouse.wheel') / 10, 0, 1))
					else
						setProperty(selectedChar..'.angle', getProperty(selectedChar..'.angle') + getPropertyFromClass('flixel.FlxG', 'mouse.wheel') * -5)
					end

					callMethod(selectedChar..'.setPosition', {
						getProperty(selectedChar..'.x') + ((gameMouse.delta.x + mouseProps.delta.x) / getProperty('camGame.zoom')),
						getProperty(selectedChar..'.y') + ((gameMouse.delta.y + mouseProps.delta.y) / getProperty('camGame.zoom'))
					})
					break
				else
					if callMethodFromClass('flixel.FlxG', 'mouse.overlaps', {instanceArg(char..'Hitbox'), instanceArg('camGame')}) and mousePressed('right') then
						selectedChar = char
						break
					end
				end
			end
		end
		if keyboardJustPressed(debugKeys.resetCharsPositions) then
			if selectedChar == nil then
				if settings.sounds then playSound('scrollMenu', 0.4) end
				callMethod('boyfriend.setPosition', {savedCharProp.boyfriend.x, savedCharProp.boyfriend.y})
				setProperty('boyfriend.angle', savedCharProp.boyfriend.angle)
				setProperty('boyfriend.alpha', savedCharProp.boyfriend.alpha)

				callMethod('dad.setPosition', {savedCharProp.dad.x, savedCharProp.dad.y})
				setProperty('dad.angle', savedCharProp.dad.angle)
				setProperty('dad.alpha', savedCharProp.dad.alpha)

				if getProperty('gf') then
					callMethod('gf.setPosition', {savedCharProp.gf.x, savedCharProp.gf.y})
					setProperty('gf.angle', savedCharProp.gf.angle)
					setProperty('gf.alpha', savedCharProp.gf.alpha)
				end

				saveCharsProps()
			else
				if settings.sounds then playSound('cancelMenu', 0.4) end
				debugPrint('[RUDM_Warning]: You can\'t set Characters Properties to Default! (Already Selecting Character.)', 'FF0000')
			end
		end
		mouseProps.prevPos = {x = runHaxeCode("return FlxG.mouse.getViewPosition(getVar('camDebug'), true).x;"), y = runHaxeCode("return FlxG.mouse.getViewPosition(getVar('camDebug'), true).y;")}
	end
end

--Help Substate

function onCustomSubstateCreate(n)
	if n == 'helpSubstate' then
		local dahelp = {
			"DEBUG MODE",
			debugKeys.startDebug.." - Opens Debug Mode",
			debugKeys.help.." - Open Debug Help Page",
			"",
			"DEBUG BOXES",
			"Mouse & Left click - Move selected Box",
			debugKeys.resetBoxPositions.." - Reset Boxes Positions",
			"",
			"CAMERA",
			debugKeys.camera.zoom[1].."/"..debugKeys.camera.zoom[2].." - Camera Zoom In/Out",
			string.format('%s/%s/%s/%s', debugKeys.camera.move[1], debugKeys.camera.move[2], debugKeys.camera.move[3], debugKeys.camera.move[4]).." - Move Camera",
			debugKeys.camera.reset.." - Reset Camera Zoom & Position",
			"",
			"CHARACTER",
			"Mouse & Right click - Move selected Character.",
			"Mouse Wheel - Change selected Character Angle.",
			"Mouse Wheel & SHIFT - Change selected Character Alpha.",
			debugKeys.resetCharsPositions.." - Reset Characters Properties",
			"",
			"SONG",
			debugKeys.restartSong.." - Restart Song",
			debugKeys.exitSong.." - Exit Song",
			debugKeys.skipTime[1].."/"..debugKeys.skipTime[2].." - Skip Time (Back/Forwards)",
			debugKeys.scrollSpeed[1]..'/'..debugKeys.scrollSpeed[2].." - Change Scroll Speed (Slower/Faster)",
			debugKeys.scrollSpeed[3].." - Reset Scroll Speed",
			debugKeys.playBackRate[1].."/"..debugKeys.playBackRate[2].." - Change Playback Rate (Slower/Faster)",
			debugKeys.playBackRate[3].." - Reset Playback Rate",
			"",
			"UTILITIES",
			debugKeys.saveStampData.." - Stamp Data",
			debugKeys.toggleBotplay.." - Toggle Botplay",
			debugKeys.togglePractice.." - Toggle Practice Mode",
			debugKeys.hideHUD.." - Toggle HUD Visibility",
			debugKeys.hideDebug.." - Toggle Debug Mode Visibility",
			debugKeys.toggleFullscreen.." - Toggle Fullscreen",
			debugKeys.takeScreenshot.." - Take Screenshot",
			"",
			"If you hold SHIFT you can go 5X faster for some functions.",
			"However, if you hold CTRL you will go 5X slower."
		}

		makeLuaSprite('debugHelpBG')
		makeGraphic('debugHelpBG', screenWidth, screenHeight, '000000')
		setProperty('debugHelpBG.alpha', 0.6)
		insertToCustomSubstate('debugHelpBG')

		for i = 1, #dahelp do
			local text = dahelp[i]
			if text ~= '' then
				local tag = 'debugHelpTxt'..i
				makeLuaText(tag, text, 600)
				setTextAlignment(tag, 'Center')
				setTextSize(tag, 10)
				setTextBorder(tag, 1, '000000')
				setTextFont(tag, settings.textFont)
				setObjectCamera(tag, 'other') -- why?
				screenCenter(tag)
				setProperty(tag..'.y', getProperty(tag..'.y') + ((i - (#dahelp + 2) / 2) * 18) + 10)
				insertToCustomSubstate(tag)
			end
		end
	end
end

function onCustomSubstateUpdate(n, e)
	if n == 'helpSubstate' then
		if keyJustPressed('back') then
			if settings.sounds then playSound('cancelMenu', 0.4) end
			closeCustomSubstate()
		end
	end
end

--Box Functions

function makeDebugBox(tag, x, y, title, content, alignment, startMinimized, linkedTo)
	--Just in case somebody tries to make a new box and leave some args blank
	x, y = x or 0, y or 0
	title, content = title or '', content or ''
	alignment = alignment or 'Left'
	startMinimized = startMinimized or false
	linkedTo = linkedTo or 'none'

	if tag == nil then  --If the tag is null or nil, then you can't create a box!!!
		debugPrint('[RUDM_Function] makeDebugBox: Error! Couldn\'t Create a new Debug Box. (No Tag Provided.)', 'FF0000')
		return
	end
	for i,box in ipairs(boxProps) do --Checks if another box has the same tag so it doesn't create another
		if box.tag == tag then
			debugPrint('[RUDM_Function] makeDebugBox: Error! Couldn\'t Create a new Debug Box. (Debug Box with the exact same tag "'..tag..'" already exists!)', 'FF0000')
			return
		end
	end

	local found = false --Checks if a box with the tag provided in linkedTo exists
	for _, box in ipairs(boxProps) do if box.tag == linkedTo then found = true break end end
	if not found and linkedTo ~= 'none' then
		debugPrint('[RUDM_Function] makeDebugBox: Error! Couldn\'t Create a new Debug Box. (No Debug Box with the tag "'..linkedTo..'" exists to link!)', 'FF0000')
		return
	end

	if linkedTo ~= 'none' then
		x, y = getProperty(linkedTo..'.x') + getProperty(linkedTo..'.width') + 10, getProperty(linkedTo..'-title.y')
	end

	local gap = 8

	makeLuaText(tag..'-titleTxt', title, screenWidth / 3, x + (gap / 2), y + (gap / 2))
	setTextColor(tag..'-titleTxt', '000000')
	setTextAlignment(tag..'-titleTxt', 'Center')
	setTextSize(tag..'-titleTxt', 8)
	setTextBorder(tag..'-titleTxt', 0)
	setTextFont(tag..'-titleTxt', settings.textFont)
	setProperty(tag..'-titleTxt.camera', instanceArg('camDebug'), false, true)

	makeLuaText(tag..'-text', content, screenWidth / 3, x + (gap / 2), y + getTextGraphicSize(tag..'-titleTxt').height + (gap * 1.5))
	setTextAlignment(tag..'-text', alignment)
	setTextSize(tag..'-text', 8)
	setTextColor(tag..'-text', darkColor(settings.boxColors[3]) and 'FFFFFF' or '000000')
	setTextBorder(tag..'-text', 0)
	setTextFont(tag..'-text', settings.textFont)
	setProperty(tag..'-text.camera', instanceArg('camDebug'), false, true)

	local bigText = getTextGraphicSize(tag..'-titleTxt').width >= getTextGraphicSize(tag..'-text').width and (tag..'-titleTxt') or (tag..'-text')

	makeLuaSprite(tag..'-title', nil, x, y)
	makeGraphic(tag..'-title', getTextGraphicSize(bigText).width + (gap * 1.5), getTextGraphicSize(tag..'-titleTxt').height + gap, 'FFFFFF')
	setProperty(tag..'-title.alpha', 0.8)
	setProperty(tag..'-title.camera', instanceArg('camDebug'), false, true)
	setTextWidth(tag..'-titleTxt', getProperty(tag..'-title.width') - gap)

	makeLuaSprite(tag, nil, x, y + getTextGraphicSize(tag..'-titleTxt').height + gap)
	makeGraphic(tag, getTextGraphicSize(bigText).width + (gap * 1.5), getTextGraphicSize(tag..'-text').height + gap, settings.boxColors[3])
	setProperty(tag..'.alpha', 0.6)
	setProperty(tag..'.camera', instanceArg('camDebug'), false, true)

	addLuaSprite(tag..'-title')
	addLuaText(tag..'-titleTxt')
	addLuaSprite(tag)
	addLuaText(tag..'-text')

	setProperty(tag..'.visible', not startMinimized)
	setProperty(tag..'-text.visible', not startMinimized)

	table.insert(boxProps, {
		tag = tag,
		x = x,
		y = y,
		align = alignment:lower(),
		minimized = startMinimized,
		newX = x,
		newY = y,
		linkedTo = linkedTo,
		isCurLinked = true,
		hasLinkRelation = (linkedTo ~= 'none')
	})
	
	if linkedTo ~= 'none' then
		for _, box in ipairs(boxProps) do
			if linkedBy(linkedTo) == tag then
				box.hasLinkRelation = true
				break
			end
		end
	end

	updateBoxText(tag)
end

function updateBoxText(tag, newContent, newTitle)
	local gap = 8
	local oldTitle, oldContent = getTextString(tag..'-titleTxt'), getTextString(tag..'-text')
	newTitle, newContent = newTitle or oldTitle, newContent or oldContent

	if tag == nil then 
		debugPrint('[RUDM_Function] updateBoxText: Error! Couldn\'t update Text to a Debug Box. (No Tag Provided.)', 'FF0000')
		return
	end

	setTextWidth(tag..'-titleTxt', screenWidth / 3)
	setTextWidth(tag..'-text', screenWidth / 3)
	setTextString(tag..'-titleTxt', newTitle)
	setTextString(tag..'-text', newContent)

	local bigText = getTextGraphicSize(tag..'-titleTxt').width >= getTextGraphicSize(tag..'-text').width and (tag..'-titleTxt') or (tag..'-text')

	setGraphicSize(tag, getTextGraphicSize(bigText).width + (gap * 1.5), getTextGraphicSize(tag..'-text').height + gap)
	setGraphicSize(tag..'-title', getTextGraphicSize(bigText).width + (gap * 1.5), getTextGraphicSize(tag..'-titleTxt').height + gap)
	setTextWidth(tag..'-titleTxt', getProperty(tag..'-title.width') - gap)
	setTextWidth(tag..'-text', getProperty(tag..'.width'))

	for i, box in ipairs(boxProps) do
		if box.tag == tag and draggingBox ~= tag then
			setBoxPosition(tag, box.newX, box.newY)
			break
		end
	end
end

function setBoxPosition(tag, x, y)
	local gap = 8
	x, y = x or 0, y or 0
	
	if tag == nil then 
		debugPrint('[RUDM_Function] setBoxPosition: Error! Couldn\'t set Position to a Debug Box. (No Tag Provided.)', 'FF0000')
		return
	end

	local offset = 0
	for i, box in ipairs(boxProps) do
		if box.tag == tag then
			if box.align == 'right' and draggingBox ~= tag then
				local width = getProperty(tag..'-title.width')
				x = x - width
			end
			if box.align == 'right' then offset = gap end
			break
		end
	end

	callMethod(tag..'.setPosition', {x, y + getTextGraphicSize(tag..'-titleTxt').height + gap})
	callMethod(tag..'-title.setPosition', {x, y})
	callMethod(tag..'-text.setPosition', {x + (gap / 2) - offset, y + getTextGraphicSize(tag..'-titleTxt').height + (gap * 1.5)})
	callMethod(tag..'-titleTxt.setPosition', {x + (gap / 2), y + (gap / 2)})
end

function boxTag(tag) --Fuck you??? why??
	for i, box in ipairs(boxProps) do
		if box.tag == tag then return box end
	end
	return nil
end

function makeCrosses()
	makeLuaSprite('debug_crossDH')
	makeGraphic('debug_crossDH', 30, 3, 'FFFFFF')
	setProperty('debug_crossDH.camera', instanceArg('camDebug'), false, true)
	screenCenter('debug_crossDH')
	addLuaSprite('debug_crossDH')
	
	makeLuaSprite('debug_crossDV')
	makeGraphic('debug_crossDV', 3, 30, 'FFFFFF')
	setProperty('debug_crossDV.camera', instanceArg('camDebug'), false, true)
	screenCenter('debug_crossDV')
	addLuaSprite('debug_crossDV')

	makeLuaSprite('debug_crossGH', nil, -15, -1.5)
	makeGraphic('debug_crossGH', 30, 3, 'FFFFFF')
	addLuaSprite('debug_crossGH', true)
	
	makeLuaSprite('debug_crossGV', nil, -1.5, -15)
	makeGraphic('debug_crossGV', 3, 30, 'FFFFFF')
	addLuaSprite('debug_crossGV', true)
end

function makeGrid()
	makeLuaSprite('debug_centerX0')
	makeGraphic('debug_centerX0', 1, screenHeight, 'FFFFFF')
	--setProperty('debug_centerX0.camera', instanceArg('camDebug'), false, true)
	setObjectCamera('debug_centerX0', 'other')
	screenCenter('debug_centerX0')
	addLuaSprite('debug_centerX0')
	setProperty('debug_centerX0.visible', false)

	makeLuaSprite('debug_centerX1', nil, screenWidth / 4)
	makeGraphic('debug_centerX1', 1, screenHeight, 'FF4444')
	--setProperty('debug_centerX1.camera', instanceArg('camDebug'), false, true)
	setObjectCamera('debug_centerX1', 'other')
	addLuaSprite('debug_centerX1')
	setProperty('debug_centerX1.visible', false)

	makeLuaSprite('debug_centerX2', nil, screenWidth * 0.75)
	makeGraphic('debug_centerX2', 1, screenHeight, 'FF4444')
	--setProperty('debug_centerX2.camera', instanceArg('camDebug'), false, true)
	setObjectCamera('debug_centerX2', 'other')
	addLuaSprite('debug_centerX2')
	setProperty('debug_centerX2.visible', false)

	--Y

	makeLuaSprite('debug_centerY0')
	makeGraphic('debug_centerY0', screenWidth, 1, 'FFFFFF')
	--setProperty('debug_centerY0.camera', instanceArg('camDebug'), false, true)
	setObjectCamera('debug_centerY0', 'other')
	screenCenter('debug_centerY0')
	addLuaSprite('debug_centerY0')
	setProperty('debug_centerY0.visible', false)

	makeLuaSprite('debug_centerY1', nil, 0, screenHeight / 4)
	makeGraphic('debug_centerY1', screenWidth, 1, '44FF44')
	--setProperty('debug_centerY1.camera', instanceArg('camDebug'), false, true)
	setObjectCamera('debug_centerY1', 'other')
	addLuaSprite('debug_centerY1')
	setProperty('debug_centerY1.visible', false)

	makeLuaSprite('debug_centerY2', nil, 0, screenHeight * 0.75)
	makeGraphic('debug_centerY2', screenWidth, 1, '44FF44')
	--setProperty('debug_centerY2.camera', instanceArg('camDebug'), false, true)
	setObjectCamera('debug_centerY2', 'other')
	addLuaSprite('debug_centerY2')
	setProperty('debug_centerY2.visible', false)
end

function toggleDebug(playSounds, forceToggle)
	if forceToggle == nil then
		inDebugMode = not inDebugMode
		setProperty('camDebug.visible', inDebugMode)
	else
		inDebugMode = forceToggle
		setProperty('camDebug.visible', forceToggle)
	end

	for _,hb in ipairs({'dad', 'boyfriend', 'gf'}) do
		if hb == 'gf' and not getProperty('gf') then break end
		if not inDebugMode then setProperty(hb..'Hitbox.visible', false) else if settings.hitboxByDefault then setProperty(hb..'Hitbox.visible', true) end end
	end
	if settings.gridByDefault then
		for i = 0,2 do
			setProperty('debug_centerX'..i..'.visible', inDebugMode)
			setProperty('debug_centerY'..i..'.visible', inDebugMode)
		end
	end
	setProperty('debug_crossGH.visible', inDebugMode)
	setProperty('debug_crossGV.visible', inDebugMode)
	if playSounds == nil and settings.sounds == true then playSound(inDebugMode and 'confirmMenu' or 'cancelMenu', 0.4) end
end

--Shit lmao

function onSongStart() startedSong = true end
function opponentNoteHit(_,_,_,isn) if not isn then oppHits = oppHits + 1 end end

function goodNoteHit(id, nd, nt, isn)
	if not isn then
		table.insert(npsNotes, getSongPosition())
	end
end

function onTimerCompleted(t)
	if t == 'yayBackToNormal' then
		callMethod('camFollow.setPosition', {ogValues.camPos[1], ogValues.camPos[2]})
		setProperty('isCameraOnForcedPos', false)
		moved = false
	end
end

--Other Functions

function saveCharsProps()
	if getProperty('gf') then
		savedCharProp = {
			boyfriend = {x = getProperty('boyfriend.x'), y = getProperty('boyfriend.y'), alpha = getProperty('boyfriend.alpha'), angle = getProperty('boyfriend.angle')},
			dad = {x = getProperty('dad.x'), y = getProperty('dad.y'), alpha = getProperty('dad.alpha'), angle = getProperty('dad.angle')},
			gf = {x = getProperty('gf.x'), y = getProperty('gf.y'), alpha = getProperty('gf.alpha'), angle = getProperty('gf.angle')},
		}
	else
		savedCharProp = {
			boyfriend = {x = getProperty('boyfriend.x'), y = getProperty('boyfriend.y'), alpha = getProperty('boyfriend.alpha'), angle = getProperty('boyfriend.angle')},
			dad = {x = getProperty('dad.x'), y = getProperty('dad.y'), alpha = getProperty('dad.alpha'), angle = getProperty('dad.angle')},
			gf = {x = 0, y = 0, alpha = 1, angle = 0}
		}
	end
end

function linkedBy(tag)
	for _, box in ipairs(boxProps) do
		if box.linkedTo == tag then
			return box.tag
		end
	end
	return 'none'
end

function updateCamera()
	moved = true
	setProperty('isCameraOnForcedPos', true)
	callMethod('camGame.snapToTarget')
	if settings.cameraBackToNormal then
		cancelTimer('yayBackToNormal')
		runTimer('yayBackToNormal', settings.cameraDelay)
	end
end

function saveScreenshot() --Screenshotting code by meloomazy on discord!
	addHaxeLibrary("Application", "lime.app")
	addHaxeLibrary("Rectangle", "lime.math")
	addHaxeLibrary("File", "sys.io")
	addHaxeLibrary("FileSystem", "sys")
	addHaxeLibrary("Main")
	lastShot = os.time()
	return runHaxeCode([[
		if (!FileSystem.exists("rudm-screenshots"))
			FileSystem.createDirectory("rudm-screenshots");

		var img = Application.current.window.readPixels(new Rectangle(0, 0, ]]..screenWidth..[[, ]]..screenHeight..[[));
		File.saveBytes("rudm-screenshots/fnfpe-rudm-screenshot-]]..lastShot..[[.png", img.encode());
		return true;
	]])
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function boundTo(number, min, max)
	return math.max(min, math.min(max, number))
end

function decimal(number)
	return math.floor(number * (10 ^ settings.decimals) + 0.5) / (10 ^ settings.decimals)
end

function getTextGraphicSize(text) --Function made by Dudu (me)
	local txtwid = getProperty(text..'.textField.textWidth') * getProperty(text..'.scale.y')
	local txthei = getProperty(text..'.textField.textHeight') * getProperty(text..'.scale.y')

	return {width = txtwid, height = txthei}
end

function darkColor(hex) --thank to chat gpt ig??? sorry for using AI as a TOOL
	local r = tonumber(hex:sub(1, 2), 16)
	local g = tonumber(hex:sub(3, 4), 16)
	local b = tonumber(hex:sub(5, 6), 16)

	local brightness = 0.299 * r + 0.587 * g + 0.114 * b

	return brightness < 128
end