function onEvent(name, value1, value2)
	if name == 'Bopping HUD2' then
		v1 = value1
		v2 = value2
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		triggerEvent('ShaderInst', 'cangle', tostring(v1*12))
		triggerEvent('TweenShadersin', 'cangle', '0,0.4,backOut')
	else
		triggerEvent('ShaderInst', 'cangle', tostring(v1*-12))
		triggerEvent('TweenShadersin', 'cangle', '0,0.4,backOut')
	end
end
