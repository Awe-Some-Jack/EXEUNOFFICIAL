local modchart = 0
local thing = 0
function onEvent(n,v1)
	if n == 'sexxxxxx' then
		if v1 == 'jajajamodchart1' then
			modchart = 1
		end
		if v1 == 'jajajamodchart2' then
			modchart = 2
		end
		if v1 == 'endmodchart' then
			modchart = 0
			for i = 0,3 do
				setProperty('opponentStrums.members['..i..'].y', _G['defaultOpponentStrumY'..i])
				setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i])

				setProperty('opponentStrums.members['..i..'].x', _G['defaultOpponentStrumX'..i])
				setProperty('playerStrums.members['..i..'].x', _G['defaultPlayerStrumX'..i])
			end
		end
	end
end

function onUpdatePost(e)
	thing = thing + e * 5
	if modchart >= 1 then
		for i = 0,3 do
			setProperty('opponentStrums.members['..i..'].y', _G['defaultOpponentStrumY'..i] - math.sin(thing + i) * 6)
			setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] - math.sin(thing + i) * 6)
		end
	end
	if modchart == 2 then
		for i = 0,3 do
			setProperty('opponentStrums.members['..i..'].y', _G['defaultOpponentStrumY'..i] - math.sin(thing + i) * 6)
			setProperty('playerStrums.members['..i..'].y', _G['defaultPlayerStrumY'..i] - math.sin(thing + i) * 6)

			setProperty('opponentStrums.members['..i..'].x', _G['defaultOpponentStrumX'..i] + math.cos(thing + i) * 6)
			setProperty('playerStrums.members['..i..'].x', _G['defaultPlayerStrumX'..i] + math.cos(thing + i) * 6)
		end
	end
end