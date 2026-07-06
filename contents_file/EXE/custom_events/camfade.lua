function onEvent(n)
	if n == 'camfade' then
		doTweenAlpha('hjasd', 'camHUD', 0, 1.6 / playbackRate)
	end
end