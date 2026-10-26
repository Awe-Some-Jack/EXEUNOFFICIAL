local ringKeybind = 'SPACE' --change this if you want to have a custom keybind
local botplayRingIgnore = false --if true and botplay is enabled it will ignore each ring


--dont really touch from here


local rings = 0
local resetAnim = 0
local hasBeenPressed = false --why is keyboardReleased so evil...
local swapped = false
local notPressedAny = true
function onCreatePost()
	makeLuaSprite('ringCounter', 'tt/Counter')
	setObjectCamera('ringCounter', 'hud')
	addLuaSprite('ringCounter', true)
	scaleObject('ringCounter', 0.67)
	callMethod('ringCounter.setPosition', {screenWidth - getProperty('ringCounter.width') - 40, (downscroll and 10 or (screenHeight - getProperty('ringCounter.height') - 10))})

	makeLuaText('ringTxt', tostring(rings))
	setTextSize('ringTxt', 60)
	setTextColor('ringTxt', 'FDC93A')
	setTextBorder('ringTxt', 3, '862800')
	setTextFont('ringTxt', 'EurostileTBla.ttf')
	setProperty('ringTxt.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing'))
	setObjectCamera('ringTxt', 'hud')
	addLuaText('ringTxt')
	callMethod('ringTxt.setPosition', {getProperty('ringCounter.x') + 76, getProperty('ringCounter.y') - 6})
	callMethod('comboGroup.setPosition', {-((screenWidth - 275) / 2), (downscroll and (-(screenHeight - 200)) or (screenHeight - 200))})
end

function usesMobileLayout()
	return getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') and getPropertyFromClass('backend.ClientPrefs', 'data.middlescrollType') == 'mobile'
end

function onCountdownStarted()
	local mobileLayout = usesMobileLayout()
	if not mobileLayout then
		for i = 0,3 do
			setProperty('playerStrums.members['..i..'].x', _G['defaultPlayerStrumX'..i] + (56 * round((i > 1 and (i + 1) or i) - 2, -1, 1)))
		end
	end

	makeAnimatedLuaSprite('strumLineRing', 'noteSkins/ring', defaultPlayerStrumX1 + 50, defaultPlayerStrumY2)
	setObjectCamera('strumLineRing', 'hud')
	scaleObject('strumLineRing', 0.7, 0.7)
	if mobileLayout then setProperty('strumLineRing.x', (screenWidth - getProperty('strumLineRing.width')) / 2) end
	addLuaSprite('strumLineRing', false)
	addToGroup('strumLineNotes', 'strumLineRing', 6)

	addAnimationByPrefix('strumLineRing', 'pressed', 'note circle', 24, false)
	addAnimationByPrefix('strumLineRing', 'confirm', 'ring confirm', 18, false)
	addAnimationByPrefix('strumLineRing', 'static', 'arrowRING', 24, false)
	ringAnim('static')

	setProperty('strumLineRing.alpha', 0)
	if getProperty('skipArrowStartTween') == false then
		startTween('daringstarting', 'strumLineRing', {alpha = 1}, 1, {ease = 'circOut'})
	else
		setProperty('strumLineRing.alpha', 1)
	end
end

function onUpdatePost(e)
	for i = 0, getProperty('notes.length')-1 do
		if getProperty('notes.members['..i..'].noteType') == 'Ring Note' then
			setProperty('notes.members['..i..'].x', getProperty('strumLineRing.x'))

			--RING HIT
			if getProperty('notes.members['..i..'].strumTime') - getPropertyFromClass('backend.Conductor', 'safeZoneOffset') * (getProperty('cpuControlled') and 0 or 0.7) <= getSongPosition()
			and getProperty('notes.members['..i..'].active') then
				if keyboardJustPressed(ringKeybind) or (getProperty('cpuControlled') and not botplayRingIgnore) then
					ringAnim('confirm', (getProperty('cpuControlled') == false and 0 or (stepCrochet * 1.25 / 1000 / playbackRate)))
					ringHit(i)
					hasBeenPressed = true
				end
			end

			--RING MISS
			local noteKillOffset = math.max(stepCrochet, 350 / getProperty('songSpeed') * playbackRate) - 5
			if (getSongPosition() - getProperty('notes.members['..i..'].strumTime')) > noteKillOffset then
				setProperty('notes.members['..id..'].active', false)
				removeFromGroup('notes', id, false)
				setProperty('notes.members['..id..'].tooLate', true)
			end
		end
	end

	if not getProperty('cpuControlled') then
		if keyboardJustPressed(ringKeybind) and getProperty('strumLineRing.animation.curAnim.name') ~= 'confirm' then
			ringAnim('pressed')
			hasBeenPressed = true
		end

		--[[if keyboardReleased(ringKeybind) then
			ringAnim('static')
			debugPrint('huh')
		end]]

		if not keyboardPressed(ringKeybind) and hasBeenPressed then
			ringAnim('static')
			hasBeenPressed = false
		end
	end

	if resetAnim > 0 then
		resetAnim = resetAnim - e
		if resetAnim <= 0 then
			ringAnim('static')
			resetAnim = 0
		end
	end
end

function noteMiss(id,nd,nt,isn)
	if rings > 0 then
		addHealth(0.1 * healthLossMult)
	end
	if isn then return end
	rings = math.max(rings - 1, 0)
	setTextString('ringTxt', tostring(rings))
end

--Ring Functions

function ringHit(id)
	playSound('Ringer', 0.5)
	if notPressedAny then notPressedAny = false end
	rings = math.min(rings + 1, 99)
	setTextString('ringTxt', tostring(rings))

	setProperty('notes.members['..id..'].wasGoodHit', true)
	setProperty('notes.members['..id..'].active', false)
	removeFromGroup('notes', id, false)
	setProperty('notes.members['..id..'].visible', false)

	callOnScripts('ringHit', {id})
end

function ringAnim(anim, time)
	time = time or 0
	playAnim('strumLineRing', anim, true)
	resetAnim = time

	--fix offset
	local strumRingOffset = {
		['pressed'] = {x = 2, y = 2},
		['confirm'] = {x = 20, y = 20},
		['static'] = {x = 0, y = 0}
	}

	callMethod('strumLineRing.offset.set', {22.5 + strumRingOffset[anim].x, 22.5 + strumRingOffset[anim].y})
end

function onPause()
	if not getProperty('cpuControlled') then
		if getProperty('strumLineRing.animation.curAnim') ~= nil and getProperty('strumLineRing.animation.curAnim.name') ~= 'static' then
			ringAnim('static')
		end
	end
end

function onEvent(n,v1,v2)
	if n == 'Knux' then
		swapped = not swapped
		triggerEvent("Flip Health Bar", '', '')
		if middlescroll then return end
		for i = 0,3 do
			setProperty('playerStrums.members['..i..'].x', _G['default'..(swapped and 'Opponent' or 'Player')..'StrumX'..i] + (56 * round((i > 1 and (i + 1) or i) - 2, -1, 1)))
			setProperty('strumLineRing.x', _G['default'..(swapped and 'Opponent' or 'Player')..'StrumX1'] + 50)
			setProperty('opponentStrums.members['..i..'].x', _G['default'..(swapped and 'Player' or 'Opponent')..'StrumX'..i])
		end
		runTimer('danote', 0.15, 10)
	end
end

function onTimerCompleted(t, l, ll)
	if t == 'danote' then
		local i = ((l - ll) - 1) % 5

		cancelTween('notemove'..i)
		noteTweenY('notemove'..i, i + 4, _G['defaultPlayerStrumY'..(i > 1 and (i - 1) or i)] + ((l - ll) < 6 and -30 or 0), 1.1, 'cubeInOut')
	end
end

function goodNoteHit(id,nd,nt,isn)
	if not isn and nt == 'Phantom Note' then
		rings = math.max(rings - 1, 0)
		setTextString('ringTxt', tostring(rings))
	end
end

function round(number, min, max)
	return math.max(min, math.min(max, number))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function onBeatHit()
	if curBeat >= 1300 and not getProperty('cpuControlled') and not getProperty('practiceMode') and notPressedAny then
		runHaxeCode([[
			import backend.EXEAchievements;
			EXEAchievements.unlock('rings');
			EXEAchievements.save();
		]])
	end
end