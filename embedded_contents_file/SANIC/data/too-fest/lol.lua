function onCreatePost()
	doSplash()
end

local inmierda = false
function onEvent(n, v1, v2)
	if n == 'sanicEvent' and v1 == 'mgl' then inmierda = true end
	if n == 'sanicEvent' and v1 == 'normal' then inmierda = false end
end

function goodNoteHit(id,nd,nt,isn)
	if not inmierda then return end
	if not isn and getProperty('notes.members['..id..'].noteSplashDisabled') == false then
		doSplash(nd, false)
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if not inmierda then return end
	if not isn and getProperty('notes.members['..id..'].noteSplashDisabled') == false then
		doSplash(nd, true)
	end
end

function doSplash(data, opponent)
	if data == nil then x, y = 0, 0
	else x, y = getProperty((opponent and 'opponentStrums' or 'playerStrums')..'.members['..data..'].x'), getProperty((opponent and 'opponentStrums' or 'playerStrums')..'.members['..data..'].y') end
	local tag = 'sanichit'..math.floor(getSongPosition())..data
	makeAnimatedLuaSprite(tag, 'hitmarker', x - 13, y - 13)
	addAnimationByPrefix(tag, 'splash', 'hit', 24, false)
	playAnim(tag, 'splash', true)
	playSound('hitmarker', 0.8)
	setObjectCamera(tag, 'hud')
	addToGroup('noteGroup', tag, getObjectOrder('strumLineNotes', 'noteGroup') + 1)
	runTimer(tag, 0.5 * playbackRate)
	if data == nil then setProperty(tag..'.alpha', 0.0001) end
end

function onTimerCompleted(tag)
	if tag:match('sanichit') then
		removeFromGroup('noteGroup', _, tag)
	end
end