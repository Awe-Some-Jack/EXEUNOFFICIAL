function onCreatePost()
	makeAnimatedLuaSprite('legsframeratesa', 'characters/deception/picolegs')
	addAnimationByPrefix('legsframeratesa', 'idle', 'Símbolo 133', 24, true)
	addLuaSprite('legsframeratesa')
	setProperty('legsframeratesa.visible', false)
end

function onUpdatePost(e)
	if boyfriendName == 'bf-run' then
		callMethod('boyfriend.setPosition', {getProperty('gf.x') + 395, getProperty('gf.y') + 203})

		setProperty('boyfriend.atlas.anim.curFrame', getProperty('legsframeratesa.animation.curAnim.curFrame'))
		setProperty('boyfriend.atlas.anim.framerate', 0)
	end
end

function goodNoteHit(id,nd,nt,isn)
	if boyfriendName == 'bf-run' then
		if nt == 'GF Sing' then
			setProperty('gf.animation.curAnim.curFrame', getProperty('legsframerate.animation.curAnim.curFrame'))
			if stringStartsWith(getProperty('boyfriend._lastPlayedAnimation'), 'idle') then
				local anim = {'left', 'down', 'up', 'right'}
				playAnim('boyfriend', 'idle-'..anim[nd + 1], true)
				setProperty('boyfriend.atlas.anim.curFrame', getProperty('legsframeratesa.animation.curAnim.curFrame'))
				setProperty('boyfriend.atlas.anim.framerate', 0)
			end
		else
			if isn then return end
			setPropertyFromGroup('notes', id, 'noAnimation', true)
			local anim = {
				['idle'] = '',
				['singLEFT'] = '-left',
				['singDOWN'] = '-down',
				['singUP'] = '-up',
				['singRIGHT'] = '-right'
			}
			playAnim('boyfriend', getProperty('singAnimations['..nd..']')..anim[getProperty('gf.animation.curAnim.name'):gsub('-loop', '')], true)
			setProperty('boyfriend.atlas.anim.curFrame', getProperty('legsframeratesa.animation.curAnim.curFrame'))
			setProperty('boyfriend.atlas.anim.framerate', 0)
			setProperty('boyfriend.holdTimer', 0)
		end
	end
end