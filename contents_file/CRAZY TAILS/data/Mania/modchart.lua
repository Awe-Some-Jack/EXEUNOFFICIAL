local funy = false

function onUpdatePost(e)
	if funy then
		for i = 0,7 do
			setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)] - (math.abs(math.sin(curDecBeat * math.pi) * e * 60) * 60))
			setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)] - (math.sin(curDecBeat * math.pi + (math.pi / 4) + (i * (math.pi / 8))) * e * 60 * 40))
			setProperty('strumLineNotes.members['..i..'].angle', -math.sin(curDecBeat * math.pi + (math.pi / 4) + (i * (math.pi / 8))) * e * 60 * 10)
		end
	end
end

function onEvent(n,v1)
	if n == 'maniaevents' then
		if v1 == 'endcine' then
			funy = true
		end
		if v1 == 'originalbg' then
			funy = false

			for i = 0,7 do
				setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)])
				setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)])
				setProperty('strumLineNotes.members['..i..'].angle', 0)
			end
		end
	end
end