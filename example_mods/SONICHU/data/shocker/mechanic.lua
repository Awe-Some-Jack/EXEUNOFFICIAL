precacheImage('characters/Lighting')

local lightings = {}

function goodNoteHitPre(id)
	if getProperty('boyfriend.animation.curAnim.name') == 'shock' then
		setProperty('notes.members['..id..'].noAnimation', true)
		setProperty('notes.members['..id..'].noMissAnimation', true)
	end
end

function opponentNoteHit(id,nd,nt,isn)
	if nd == 3 and not isn and nt == 'Alt Animation' then
		local tag = 'lighting'..(math.floor(getSongPosition()))
		makeAnimatedLuaSprite(tag, 'characters/Lighting', getProperty('dad.x') + 800, getProperty('dad.y') + 200)
		addAnimationByPrefix(tag, 'idle', 'Símbolo 146', 24, false)
		playAnim(tag, 'idle', true)
		addLuaSprite(tag, true)
		table.insert(lightings, tag)

		if getHealth() > 0.04 then addHealth(-0.02) end
		playAnim('boyfriend', 'shock', true)
		setProperty('boyfriend.specialAnim', true)
	end
end

function onUpdate(e)
	for i,l in ipairs(lightings) do
		if luaSpriteExists(l) and getProperty(l..'.animation.curAnim.finished') then removeLuaSprite(l, true) table.remove(lightings, 1) end
	end
end