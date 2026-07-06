local anims = {
	['idle'] = 'griatosA',
	['risa'] = 'griatosB',
	[3] = 'griatosB',
	[2] = 'griatosC',
	[1] = 'griatosC',
	[0] = 'griatosA'
}

function onCreate()
	addCharacterToList('griatosB', 'dad') addCharacterToList('griatosC', 'dad')
end

local oldDadName = 'griatosA'
function onEvent(n,v1,v2)
	if dadName == 'griatosA' or dadName == 'griatosB' or dadName == 'griatosC' then
		if n == 'Play Animation' and v2:lower() == 'dad' and anims[v1] ~= oldDadName then
			triggerEvent('Change Character', 'dad', anims[v1])
			playAnim('dad', v1, true)
			oldDadName = anims[v1]
		end
	end
end

function opponentNoteHit(_,nd,nt)
	if dadName == 'griatosA' or dadName == 'griatosB' or dadName == 'griatosC' then
		if nt ~= 'No Animation' and anims[nd] ~= oldDadName then
			triggerEvent('Change Character', 'dad', anims[nd])
			playAnim('dad', getProperty('singAnimations['..nd..']'), true)
			oldDadName = anims[nd]
		end
	end
end

function onUpdatePost(e)
	if dadName == 'griatosA' or dadName == 'griatosB' or dadName == 'griatosC' then
		if getProperty('dad.animation.curAnim.name') ~= 'idle' and getProperty('dad.animation.curAnim.finished') and anims['idle'] ~= oldDadName then
			triggerEvent('Change Character', 'dad', anims['idle'])
			playAnim('dad', 'idle', true)
			oldDadName = anims['idle']
		end
	end
end