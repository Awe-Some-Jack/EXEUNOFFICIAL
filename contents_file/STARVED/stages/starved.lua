local fightSprites = {
    'city',
    'bg',
    'table',
    'body1',
    'FlickyBody1',
    'FlickyBody2',
    'FlickyBody3',
    'FlickyBody4',
    'FlickyBody6',
    'EggTV',
    'FrontBody1',
    'WarningLight'
}
-- The Background Stuff
-- AYYY AYYY HACEDLE ARRAY AAAY AYY AAAY AYAYYAYAYAYAYYAYAYAYAA AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYYYY
function onCreate()
	makeLuaSprite('city', 'starved/city', -145, 250)
	scaleObject('city', 1.35, 1.35)
	setScrollFactor('city', 0.7, 0.7)
	addLuaSprite('city')
	
	makeLuaSprite('bg', 'starved/bg', -145, 450)
	scaleObject('bg', 1.35, 1.35)
	addLuaSprite('bg')
	
	makeLuaSprite('table', 'starved/table', -165, 450)
	scaleObject('table', 1.35, 1.35)
	addLuaSprite('table')
	
	makeLuaSprite('body1', 'starved/mrcrabs', -145, 450)
	scaleObject('body1', 1.35, 1.35)
	addLuaSprite('body1')
	
	makeLuaSprite('SonicBody', 'starved/sonic', 115, 1100)
	scaleObject('SonicBody', 1.15, 1.15)
	addLuaSprite('SonicBody')

	makeLuaSprite('SonicBody2', 'starved/sonic-dark', 115, 1100)
	scaleObject('SonicBody2', 1.15, 1.15)
	addLuaSprite('SonicBody2')
	setProperty('SonicBody2.alpha', 0)
	
	makeLuaSprite('FlickyBody1', 'starved/pocky', 1070, 1220)
	scaleObject('FlickyBody1', 0.5, 0.5)
	addLuaSprite('FlickyBody1')
	
	makeLuaSprite('FlickyBody2', 'starved/ricky', 100, 600)
	scaleObject('FlickyBody2', 0.5, 0.5)
	setScrollFactor('FlickyBody2', 1.2, 1.2)
	addLuaSprite('FlickyBody2', true)
		
	makeLuaSprite('FlickyBody3', 'starved/cucky', 1000, 540)
	scaleObject('FlickyBody3', 0.5, 0.5)
	setScrollFactor('FlickyBody3', 1.2, 1.2)
	addLuaSprite('FlickyBody3', true)
	
	makeLuaSprite('FlickyBody4', 'starved/flicky', 1200, 620)
	scaleObject('FlickyBody4', 0.6, 0.6)
	setScrollFactor('FlickyBody4', 1.35, 1.35)
	addLuaSprite('FlickyBody4', true)
	
	makeLuaSprite('FlickyBody5', 'starved/shoe', 920, 1420)
	scaleObject('FlickyBody5', 0.85, 0.85)
	addLuaSprite('FlickyBody5')
	
	makeLuaSprite('FlickyBody6', 'starved/picky', -70, 1380)
	scaleObject('FlickyBody6', 0.5,0.5)
	addLuaSprite('FlickyBody6')
	
	makeAnimatedLuaSprite('EggTV', 'starved/tv', 585, 500)
	addAnimationByPrefix('EggTV', 'hungry', 'idle', 20, true)
	objectPlayAnimation('EggTV', 'hungry', true)
	scaleObject('EggTV', 1.35, 1.35)
	addLuaSprite('EggTV')

	makeLuaSprite('FrontBody1', 'starved/fishF1', -140, 800)
	scaleObject('FrontBody1', 1.5, 1.5)
	setScrollFactor('FrontBody1', 1.5, 1.5)
	addLuaSprite('FrontBody1', true)
	
	makeLuaSprite('WarningLight', 'starved/light', -230, 450)
	scaleObject('WarningLight', 1.35, 1.35)
	setProperty('WarningLight.alpha', 0.75)
	addLuaSprite('WarningLight', true)
	setBlendMode('WarningLight','add')
	
	makeLuaSprite('UI', 'starved/vinevrom')
	addLuaSprite('UI', true)
	setObjectCamera('UI', 'hud')
end

-- For the cam Stuff for the fake 3D shit
function onMoveCamera(focus)
    if focus == 'dad' then
        setProperty('defaultCamZoom', 0.9)
        doTweenAlpha('sex', 'boyfriend', 0.4, 0.2, 'linear')
    elseif focus == 'boyfriend' then
        setProperty('defaultCamZoom', 0.75)
        doTweenAlpha('sex', 'boyfriend', 1, 0.2, 'linear')
    end
end

-- Events Stuff 
function onEvent(name, value1, value2)
    if name == 'Hide' then
        if value1 == '0' then
            doTweenAlpha('hudHide', 'camHUD', 0, 0.3, 'linear')
        elseif value1 == '1' then
            doTweenAlpha('hudShow', 'camHUD', 1, 0.3, 'linear')
        end
    end
    if name == 'secondPhase' then
		if value1 == 'fadeout' then
			for i = 1, #fightSprites do doTweenAlpha('fightHide'..i, fightSprites[i], 0, 3, 'linear') end
			doTweenColor('boyfriendColor','boyfriend','000000',3,'linear')
			doTweenColor('UIColor','UI','000000',3,'linear')
			doTweenAlpha('huddissapear', 'camHUD', 0, 3)
			doTweenColor('sonicColor','SonicBody','000000',3,'linear')
			doTweenColor('FlickyBody5Color','FlickyBody5','000000',3,'linear')
		end
        if value1 == 'fight' then
			doTweenColor('boyfriendColor','boyfriend','FF0000',1,'linear')
	        doTweenColor('dadColor','dad','FF0000',1,'linear')
			doTweenColor('UIColor','UI','FF0000',1,'linear')
			doTweenAlpha('huddissapear', 'camHUD', 1, 1)
			doTweenAlpha('sonicColor2','SonicBody2',1,1,'linear')
			doTweenColor('FlickyBody5Color','FlickyBody5','FF0000',3,'linear')
        end
		if value1 == 'starved' then
			doTweenColor('boyfriendColor','boyfriend','000000',1,'linear')
			doTweenColor('UIColor','UI','000000',1,'linear')
			doTweenAlpha('huddissapear', 'camHUD', 0, 1)
			doTweenAlpha('sonicColor2','SonicBody2',0,1,'linear')
			doTweenColor('FlickyBody5Color','FlickyBody5','000000',3,'linear')
		end
		if value1 == 'fadein' then
            for i = 1, #fightSprites do doTweenAlpha('fightShow'..i, fightSprites[i], 1, 4, 'linear') end
			doTweenColor('boyfriendColor','boyfriend','FFFFFF',4,'linear')
			doTweenColor('dadColor','dad','FFFFFF',4,'linear')
			doTweenColor('UIColor','UI','FFFFFF',4,'linear')
			doTweenAlpha('huddissapear', 'camHUD', 1, 4)
			doTweenColor('sonicColor','SonicBody','FFFFFF',4,'linear')
			doTweenColor('FlickyBody5Color','FlickyBody5','FFFFFF',3,'linear')
        end
    end
end