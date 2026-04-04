precacheSound('../songs/round-a-bout/Inst-vhs') precacheSound('../songs/round-a-bout/Voices-vhs')

function onSongStart()
	playSound('../songs/round-a-bout/Inst-vhs', 1, 'inst-vhs')
	playSound('../songs/round-a-bout/Voices-vhs', 1, 'voices-vhs')

	setSoundVolume('inst-vhs', 0)
	setSoundVolume('voices-vhs', 0)
end

function onPause()
	pauseSound('inst-vhs')
	pauseSound('voices-vhs')
end

function onResume()
	resumeSound('inst-vhs')
	resumeSound('voices-vhs')

	setSoundTime('inst-vhs', getSongPosition())
	setSoundTime('voices-vhs', getSongPosition())
end

function onGameOverStart()
	stopSound('inst-vhs')
	stopSound('voices-vhs')
end

local lowornormal = 'normal'
function onUpdatePost()
	if getHealth() < 0.4 and lowornormal == 'normal' then
		lowornormal = 'low'
		--setSoundVolume('inst-vhs', 1)
		--setSoundVolume('voices-vhs', 1)
		--setSoundVolume(null, 0)
		--setProperty('vocals.volume', 0)

		soundFadeIn('inst-vhs', crochet / 1000)
		soundFadeIn('voices-vhs', crochet / 1000)
		soundFadeOut(null, crochet / 1000)
		soundFadeOut('vocals', crochet / 1000)

		setSoundTime('inst-vhs', getSongPosition())
		setSoundTime('voices-vhs', getSongPosition())
	elseif getHealth() > 0.4 and lowornormal == 'low' then
		lowornormal = 'normal'
		--setSoundVolume('inst-vhs', 0)
		--setSoundVolume('voices-vhs', 0)
		--setSoundVolume(null, 1)
		--setProperty('vocals.volume', 1)

		soundFadeOut('inst-vhs', crochet / 1000)
		soundFadeOut('voices-vhs', crochet / 1000)
		soundFadeIn(null, crochet / 1000)
		soundFadeIn('vocals', crochet / 1000)
	end

	if lowornormal == 'low' then
		setProperty('vocals.volume', 0)
	end

	if getProperty('vocals.pitch') ~= getSoundPitch('voices-vhs') then
		setSoundPitch('voices-vhs', getProperty('vocals.pitch'))
		setSoundPitch('inst-vhs', getSoundPitch('voices-vhs'))
	end
end

function noteMiss()
	if lowornormal == 'low' then
		setSoundVolume('voices-vhs', 0)
	end
end

function opponentNoteHit()
	if lowornormal == 'low' then
		setSoundVolume('voices-vhs', 1)
	end
end

function goodNoteHit()
	if lowornormal == 'low' then
		setProperty('vocals.volume', 0)
		setSoundVolume('voices-vhs', 1)
	end
end

function onDestroy()
	stopSound('inst-vhs')
	stopSound('voices-vhs')
end