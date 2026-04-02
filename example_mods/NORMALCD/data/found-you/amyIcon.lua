function onCreatePost()
	createInstance('amyIcon', 'objects.HealthIcon', {'amy', true})
	addToGroup('uiGroup', 'amyIcon', getObjectOrder('iconBF', 'uiGroup') + 1)
	setProperty('amyIcon.alpha', 0)
end

function onUpdatePost(e)
	setProperty('amyIcon.animation.curAnim.curFrame', getProperty('iconBF.animation.curAnim.curFrame'))
	setProperty('amyIcon.x', getProperty('iconBF.x') + 50)
	setProperty('amyIcon.y', getProperty('iconBF.y') - 35)
	setProperty('amyIcon.scale.x', getProperty('iconBF.scale.x') * 0.8)
	setProperty('amyIcon.scale.y', getProperty('iconBF.scale.y') * 0.8)

	if curBeat >= 648 and getProperty('amyIcon.alpha') == 0 then
		doTweenAlpha('amyIcon', 'amyIcon', 1, 0.4)
	end
end