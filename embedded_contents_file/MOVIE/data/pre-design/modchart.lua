local strumScale = 1
function onSongStart()
	strumScale = getProperty('strumLineNotes.members[0].scale.x')
end

local distance = false
function onEvent(n,v1)
	if n == 'Trigger BG Ghouls' then
		local randomSeed = getRandomInt(-25, 25)
		for i = 0,7 do
			cancelTween('strumX'..i) cancelTween('strumY'..i) cancelTween('strumA'..i) cancelTween('strumXS'..i) cancelTween('strumYS'..i)
			setProperty('strumLineNotes.members['..i..'].scale.x', strumScale) setProperty('strumLineNotes.members['..i..'].scale.y', strumScale)
			setProperty('strumLineNotes.members['..i..'].angle', 0)
			if v1 == '' then
				setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] + getRandomInt(-70, 70))
				doTweenX('strumX'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)] + getRandomInt(-70, 70))
				doTweenY('strumY'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].angle', getRandomInt(-75, 75))
				doTweenAngle('strumA'..i, 'strumLineNotes.members['..i..']', 0, crochet / 250, 'expoOut')
			elseif v1 == 'r' then
				setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] + getRandomInt(-5, 5) + (distance and -30 or 30))
				doTweenX('strumX'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)] + math.sin(i - randomSeed) * 70)
				doTweenY('strumY'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].angle', 0)
				doTweenAngle('strumA'..i, 'strumLineNotes.members['..i..']', 360 * (distance and -1 or 1), crochet / 250, 'expoOut')
			elseif v1 == 'd' then
				setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] + getRandomInt(-25, 25))
				doTweenX('strumX'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)] + math.sin(i - randomSeed) * 70 + (distance and -30 or 30))
				doTweenY('strumY'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].scale.x', strumScale / 2)
				doTweenX('strumXS'..i, 'strumLineNotes.members['..i..'].scale', strumScale, crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].scale.y', strumScale * 2)
				doTweenY('strumYS'..i, 'strumLineNotes.members['..i..'].scale', strumScale, crochet / 250, 'expoOut')
			elseif v1 == 'e' then
				setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] + ((i % 4) - ((i % 4) > 1 and 1 or 2)) * 30)
				doTweenX('strumX'..i, 'strumLineNotes.members['..i..']', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)], crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].angle', 0)
				doTweenAngle('strumA'..i, 'strumLineNotes.members['..i..']', 360 * (distance and -1 or 1), crochet / 500, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].scale.x', strumScale * 2)
				doTweenX('strumXS'..i, 'strumLineNotes.members['..i..'].scale', strumScale, crochet / 250, 'expoOut')

				setProperty('strumLineNotes.members['..i..'].scale.y', strumScale / 2)
				doTweenY('strumYS'..i, 'strumLineNotes.members['..i..'].scale', strumScale, crochet / 250, 'expoOut')
			end
		end
		distance = not distance
	end
end