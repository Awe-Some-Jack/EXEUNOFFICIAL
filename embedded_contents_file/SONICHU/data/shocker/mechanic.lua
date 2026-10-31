precacheImage('characters/Lighting')

local lightings = {}
local zappedRecently = false

function opponentNoteHit(id,nd,nt,isn)
	if nd == 3 and not isn and nt == 'Alt Animation' then
		local tag = 'lighting'..(math.floor(getSongPosition()))
		makeAnimatedLuaSprite(tag, 'characters/Lighting', getProperty('dad.x') + 800, getProperty('dad.y') + 200)
		addAnimationByPrefix(tag, 'idle', 'Símbolo 146', 24, false)
		playAnim(tag, 'idle', true)
		addLuaSprite(tag, true)
		table.insert(lightings, tag)

		addHealth(-0.075)
		playAnim('boyfriend', 'shock', true)
		setProperty('boyfriend.specialAnim', true)
		zappedRecently = true
		cancelTimer('asdaj')
		runTimer('asdaj', 0.5)
	end
end

function onTimerCompleted(t) if t == 'asdaj' then zappedRecently = false end end

function onGameOver()
	if zappedRecently and not getProperty('cpuControlled') and not getProperty('practiceMode') then
		addHaxeLibrary('EXEAchievements', "backend")
		runHaxeCode([[
			import backend.EXEAchievements;
			EXEAchievements.unlock('shocks');
			EXEAchievements.save();
		]])

		
	end
end

function onUpdate(e)
	for i,l in ipairs(lightings) do
		if luaSpriteExists(l) and getProperty(l..'.animation.curAnim.finished') then removeLuaSprite(l, true) table.remove(lightings, 1) end
	end
end