local tweening = false
function onCreatePost()
	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)
	setShaderFloat('bloom', 'brightness', -0.2)
	setShaderFloat('bloom', 'contrast', 0.8)

	makeLuaSprite('dss')
	setSpriteShader('dss', 'DropShadowShader')
	setShaderFloat('dss', 'ang', 90)
	setShaderFloat('dss', 'thr', 1)
	setShaderFloat('dss', 'hue', -38)
	setShaderFloat('dss', 'saturation', -20)
	setShaderFloat('dss', 'brightness',-46)
	setShaderFloat('dss', 'contrast', -25)
	setProperty('BlackGraphicOther.alpha', 1)

	if shadersEnabled then
		runHaxeCode([[
			game.camGame.filters = [
				new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('dss').shader)
			];
			game.camHUD.filters = [
				new ShaderFilter(game.getLuaObject('dss').shader)
			];
		]])
	end
end


function lerp(a, b, t)
	return a + t * (b - a)
end

function onSongStart()
	doTweenAlpha('BlackGraphicOther', 'BlackGraphicOther', 0, 2)
end

function onEvent(n, v1)
	if n == 'hellbentEvents' then
		if v1 == 'blackout' then
			doTweenAlpha('BlackGraphicHUD', 'BlackGraphicHUD', 1, crochet / (1000 / 4) / playbackRate)
			doTweenAlpha('icon1Xd', 'iconBF', 0, crochet / (1000 / 4) / playbackRate)
			doTweenAlpha('icon2Xd', 'iconOpp', 0, crochet / (1000 / 4) / playbackRate)
			for i = 0,7 do noteTweenAlpha('noteAlpha'..i, i, 0, crochet / (1000 / 4) / playbackRate) end
		end
		if v1 == 'lessdark' then
			for i = 0,7 do cancelTween('noteAlpha'..i) setProperty('strumLineNotes.members['..i..'].alpha', 1) end
			cancelTween('icon1Xd') setProperty('iconBF.alpha', 1)
			cancelTween('icon2Xd') setProperty('iconOpp.alpha', 1)
			cancelTween('BlackGraphicHUD')
			cameraFlash('game', 'FFFFFF', 1, true)
			setProperty('BlackGraphicHUD.alpha', 0)
			setShaderFloat('dss', 'saturation', -10)
			setShaderFloat('dss', 'brightness',-23)
			setShaderFloat('dss', 'contrast', -17)
			setShaderFloat('bloom', 'brightness', -0.1)
			setShaderFloat('bloom', 'contrast', 0.9)
		end
		if v1 == 'startwhite' then
			for i = 0,7 do cancelTween('noteAlpha'..i) setProperty('strumLineNotes.members['..i..'].alpha', 1) end
			cancelTween('icon1Xd') setProperty('iconBF.alpha', 1)
			cancelTween('icon2Xd') setProperty('iconOpp.alpha', 1)
			cancelTween('BlackGraphicHUD')
			cameraFlash('game', 'FFFFFF', 1, true)
			setProperty('BlackGraphicHUD.alpha', 0)
			if shadersEnabled then
				runHaxeCode([[
					game.camGame.filters = [];
					game.camHUD.filters = [];
				]])
			end
		end
		if v1 == 'fucklol' then
			for i = 0,7 do
				cancelTween('noteAlpha'..i) setProperty('strumLineNotes.members['..i..'].alpha', 1)
				if i < 4 then
					setProperty('playerStrums.members['..i..'].y', downscroll and screenHeight or (-getProperty('playerStrums.members['..i..'].height')))
					noteTweenY('noteY'..(i + 4), (i + 4), _G['defaultPlayerStrumY'..i], 1.5 + (0.2 * i), 'cubeOut')
				end
			end
		end
		if v1 == 'changeBG' then
			cancelTween('BlackGraphicHUD')
			doTweenAlpha('BlackGraphicHUD', 'BlackGraphicHUD', 0, crochet / (1000 / 4) / playbackRate)
			cancelTween('icon1Xd') doTweenAlpha('icon1Xd', 'iconBF', 1, crochet / (1000 / 4) / playbackRate)
			cancelTween('icon2Xd') doTweenAlpha('icon2Xd', 'iconOpp', 1, crochet / (1000 / 4) / playbackRate)
		end
	end
end