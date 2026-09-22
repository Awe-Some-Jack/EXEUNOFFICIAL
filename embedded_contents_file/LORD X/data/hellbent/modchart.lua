local separation = 50
local backToOg = false
local oldNoteGroup = 0
local startHell = false

function onCreatePost()
	if not lowQuality then
		for i = 0,getProperty('unspawnNotes.length') - 1 do
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
				oldNoteGroup = getObjectOrder('noteGroup')
				setObjectOrder('noteGroup', 3)
			end
		end
	end
end

function onCountdownStarted()
	if not lowQuality then
		for i = 0,3 do
			setProperty('opponentStrums.members['..i..'].downScroll', true)
			setProperty('opponentStrums.members['..i..'].y', 900)
			scaleObject('opponentStrums.members['..i..']', getProperty('opponentStrums.members['..i..'].scale.x') * 2, getProperty('opponentStrums.members['..i..'].scale.y') * 2, true)

			separation = 0
			setProperty('opponentStrums.members['..i..'].x', -397 + (screenWidth / 2) + (separation / 2) - ((((getProperty('opponentStrums.members['..i..'].width') * 1.5) + (separation * 2)) * 4) / 2) + ((getProperty('opponentStrums.members['..i..'].width') * 1.5) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
			separation = 50
			setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + (getProperty('playerStrums.members['..i..'].width') + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
		end

		for i = 0,getProperty('notes.length') - 1 do
			if getPropertyFromGroup('notes', i, 'mustPress') == false then
				setProperty('notes.members['..i..'].copyX', false)
				setProperty('notes.members['..i..'].alpha', 1)
				setPropertyFromGroup('notes', i, 'multSpeed', 2)
				if getPropertyFromGroup('notes', i, 'isSustainNote') then
					scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x') * 2, getProperty('notes.members['..i..'].scale.y'), true)
					setPropertyFromGroup('notes', i, 'flipY', true)
				else
					scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x') * 2, getProperty('notes.members['..i..'].scale.y') * 2, true)
				end
			end
		end
		
		for i = 0,getProperty('unspawnNotes.length') - 1 do
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
				setObjectCamera('unspawnNotes['..i..']')
				callMethod('unspawnNotes['..i..'].scrollFactor.set', {1, 1})

				setProperty('unspawnNotes['..i..'].copyX', 1)
				setProperty('unspawnNotes['..i..'].alpha', 1)
				setPropertyFromGroup('unspawnNotes', i, 'multSpeed', 2)
				if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
					scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 2, getProperty('unspawnNotes['..i..'].scale.y'), true)
					setPropertyFromGroup('unspawnNotes', i, 'flipY', true)
				else
					scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 2, getProperty('unspawnNotes['..i..'].scale.y') * 2, true)
				end
			end
		end
	end
end

function onUpdatePost(e)
	if not lowQuality then
		if backToOg == false then
			for i = 0,getProperty('notes.length') - 1 do
				if getPropertyFromGroup('notes', i, 'mustPress') == false then
					setProperty('notes.members['..i..'].x',
						getProperty('opponentStrums.members['..getProperty('notes.members['..i..'].noteData')..'].x') - (
							math.pow(1.0225, (math.abs(getProperty('notes.members['..i..'].distance')) / 5) - 1) *
							((getProperty('notes.members['..i..'].noteData') == 1 or getProperty('notes.members['..i..'].noteData') == 2) and 0.4 or 1) *
							((getProperty('notes.members['..i..'].noteData') == 2 or getProperty('notes.members['..i..'].noteData') == 3) and -1 or 1)
						)
					)
					if getPropertyFromGroup('notes', i, 'isSustainNote') then
						setProperty('notes.members['..i..'].angle',
							math.pow(1.0125, (math.abs(getProperty('notes.members['..i..'].distance')) / 5) - 1) *
							((getProperty('notes.members['..i..'].noteData') == 1 or getProperty('notes.members['..i..'].noteData') == 2) and 0.4 or 1) *
							((getProperty('notes.members['..i..'].noteData') == 2 or getProperty('notes.members['..i..'].noteData') == 3) and 1 or -1)
						)
					end

					setProperty('notes.members['..i..'].alpha', 0.55)
				end
			end
		end
	end
end

function onSongStart()
	if not lowQuality then
		for i = 0,3 do
			separation = 0
			setProperty('opponentStrums.members['..i..'].x', -370 + (screenWidth / 2) + (separation / 2) - ((((getProperty('opponentStrums.members['..i..'].width') * 1.5) + (separation * 2)) * 4) / 2) + ((getProperty('opponentStrums.members['..i..'].width') * 1.5) + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
			separation = 50
			setProperty('playerStrums.members['..i..'].x', (screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + (getProperty('playerStrums.members['..i..'].width') + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i)
			setObjectCamera('opponentStrums.members['..i..']')
			callMethod('opponentStrums.members['..i..'].scrollFactor.set', {1, 1})
		end
		for i = 0,getProperty('unspawnNotes.length') - 1 do
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
				setObjectCamera('unspawnNotes['..i..']')
				callMethod('unspawnNotes['..i..'].scrollFactor.set', {1, 1})
				oldNoteGroup = getObjectOrder('noteGroup')
				setObjectOrder('noteGroup', 3)
			end
		end
	end
end

function onEvent(n,v1)
	if not lowQuality then
		if n == 'hellbentEvents' then
			if v1 == 'startwhite' then setObjectOrder('noteGroup', 7) end
			if v1 == 'changeBG' then
				backToOg = true

				for i = 0,3 do
					setProperty('opponentStrums.members['..i..'].x', -500) 

					setProperty('opponentStrums.members['..i..'].downScroll', downscroll)
					setObjectCamera('opponentStrums.members['..i..']', 'hud')
					scaleObject('opponentStrums.members['..i..']', getProperty('opponentStrums.members['..i..'].scale.x') * 0.5, getProperty('opponentStrums.members['..i..'].scale.y') * 0.5, true)
					callMethod('opponentStrums.members['..i..'].scrollFactor.set', {0, 0})
					setProperty('opponentStrums.members['..i..'].y', _G['defaultOpponentStrumY'..i])
				end

				for i = 0,getProperty('unspawnNotes.length') - 1 do
					if getPropertyFromGroup('unspawnNotes', i, 'mustPress') == false then
						setProperty('unspawnNotes['..i..'].alpha', 0.35)
						setPropertyFromGroup('unspawnNotes', i, 'multSpeed', 1)
						setObjectCamera('unspawnNotes['..i..']', 'hud')
						callMethod('unspawnNotes['..i..'].scrollFactor.set', {0, 0})
						setObjectOrder('noteGroup', oldNoteGroup)

						if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
							scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.5, getProperty('unspawnNotes['..i..'].scale.y'), true)
							setPropertyFromGroup('unspawnNotes', i, 'flipY', downscroll)
						else
							scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.5, getProperty('unspawnNotes['..i..'].scale.y') * 0.5, true)
						end
					end

					--setProperty('unspawnNotes['..i..'].texture', 'noteSkins/NOTE_assets')
				end

				startHell = true
				for i = 0,getProperty('notes.length') - 1 do
					removeSpriteShader('notes.members['..i..']')
					if getPropertyFromGroup('notes', i, 'mustPress') == false then
						setProperty('unspawnNotes['..i..'].alpha', 0.35)
						setPropertyFromGroup('notes', i, 'multSpeed', 1)
						setObjectCamera('notes.members['..i..']', 'hud')
						callMethod('notes.members['..i..'].scrollFactor.set', {0, 0})
						setObjectOrder('noteGroup', oldNoteGroup)

						if getPropertyFromGroup('notes', i, 'isSustainNote') then
							scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x') * 0.5, getProperty('notes.members['..i..'].scale.y'), true)
							setPropertyFromGroup('notes', i, 'flipY', downscroll)
						else
							scaleObject('notes.members['..i..']', getProperty('notes.members['..i..'].scale.x') * 0.5, getProperty('notes.members['..i..'].scale.y') * 0.5, true)
						end
					end

					--setProperty('notes.members['..i..'].texture', 'noteSkins/NOTE_assets')
				end
			end
			if v1 == 'noteposs' then
				for i = 0,3 do
					noteTweenX('player'..i, i + 4, _G['defaultPlayerStrumX'..i], 2 - (0.065 * i), 'cubeInOut')
					noteTweenX('opp'..i, i, _G['defaultOpponentStrumX'..i], 2 - (0.065 * i), 'cubeInOut')
				end
			end
			if v1 == 'middlebb' then
				for i = 0,3 do
					noteTweenX('notelol'..i, i, -1000, 2 + (0.5 * i), 'cubeInOut')
					noteTweenX('notelol'..(i + 4), i + 4,
						(screenWidth / 2) + (separation / 2) - (((getProperty('playerStrums.members['..i..'].width') + (separation * 2)) * 4) / 2) + (getProperty('playerStrums.members['..i..'].width') + separation * (i > 1 and (i == 3 and 2.33 or 3) or 1)) * i,
					2 + (0.5 * i), 'cubeInOut')
				end
			end
			if v1 == 'fadeout' then
				doTweenAlpha('camHUD', 'camHUD', 0, 1)
				doTweenAlpha('BlackGraphicGame', 'BlackGraphicGame', 1, 1)
			end
		end
	end
end

function onSpawnNote(id,nd,nt,isn)
	if not getPropertyFromGroup('notes', id, 'mustPress') and not startHell then
		setSpriteShader('notes.members['..id..']', 'brightness')
		setShaderFloat('notes.members['..id..']', 'saturation', 0.15)
		setShaderFloat('notes.members['..id..']', 'brightness', -0.5)
		setShaderFloat('notes.members['..id..']', 'contrast', 1.5)
	end
end