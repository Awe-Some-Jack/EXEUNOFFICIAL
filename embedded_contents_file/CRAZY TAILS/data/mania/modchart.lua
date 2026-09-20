local funy = false

function onUpdatePost(e)
	if funy and not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then
		for i = 0,7 do
			setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumY'..(i % 4)] - (math.abs(math.sin(curDecBeat * math.pi) * 40)))
			setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Player' or 'Opponent')..'StrumX'..(i % 4)] - (math.sin(curDecBeat * math.pi + (math.pi / 4) + (i * (math.pi / 8))) * 40))
			setProperty('strumLineNotes.members['..i..'].angle', -math.sin(curDecBeat * math.pi + (math.pi / 4) + (i * (math.pi / 8))) * 10)
		end
	elseif funy then
		for i = 0,7 do
			setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)] - (math.abs(math.sin(curDecBeat * math.pi) * 40)))
			setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)] - (math.sin(curDecBeat * math.pi + (math.pi / 4) + (i * (math.pi / 8))) * 40))
			setProperty('strumLineNotes.members['..i..'].angle', -math.sin(curDecBeat * math.pi + (math.pi / 4) + (i * (math.pi / 8))) * 10)
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
				if not getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll') then 
					setProperty('strumLineNotes.members['..i..'].y', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumY'..(i % 4)])
					setProperty('strumLineNotes.members['..i..'].x', _G['default'..(i < 4 and 'Opponent' or 'Player')..'StrumX'..(i % 4)])
				end
				setProperty('strumLineNotes.members['..i..'].angle', 0)
			end
		end
	end
end