--local animated = {'k', 't', 'waterfallevil2', 'cameos1', 'cameos2'}

function onEvent(n,v1)
	if n == 'deleteSprite' then
		--debugPrint('ERROR - asset located in "HOG/'..getProperty(v1..'.graphic.key'):gsub('-glitch', ''):gsub('/glitch', '')..'" doesn\'t exist!')
		--for _,obj in ipairs(animated) do if v1 == obj then debugPrint('ERROR - asset located in "HOG/'..getProperty(obj..'.graphic.key'):gsub('-glitch', ''):gsub('/glitch', ''):gsub('.png', '')..'.xml" doesn\'t exist!') end end
		--removeLuaSprite(v1, true)
	end
end