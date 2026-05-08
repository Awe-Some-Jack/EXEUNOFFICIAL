local fightSprites = {
    'city',
    'bg',
    'table',
    'body1',
    'FlickyBody1',
    'FlickyBody2',
    'FlickyBody3',
    'FlickyBody4',
    'FlickyBody5',
    'FlickyBody6'
    'SonicBody',
    'EggTV',
    'FrontBody1',
    'WarningLight'
}
-- The Background Stuff
function onCreate()
        makeLuaSprite('city', 'starved/city', -145, 450);
		scaleObject('city', 1.35, 1.35);
		addLuaSprite('city', false);
		
		makeLuaSprite('bg', 'starved/bg', -145, 450);
		scaleObject('bg', 1.35, 1.35);
		addLuaSprite('bg', false);
		
		makeLuaSprite('table', 'starved/table', -165, 450);
		scaleObject('table', 1.35, 1.35);
		setScrollFactor('table', 1, 1);
		addLuaSprite('table', false);
		
		makeLuaSprite('body1', 'starved/mrcrabs', -145, 450);
		scaleObject('body1', 1.35, 1.35);
		setScrollFactor('body1', 1, 1);
		addLuaSprite('body1', false);
		
		makeLuaSprite('SonicBody', 'starved/SonicBody', 0, 1090);
		scaleObject('SonicBody', 1.3, 1.3);
		setScrollFactor('SonicBody', 1, 1);
		addLuaSprite('SonicBody', false);
		
		makeLuaSprite('FlickyBody1', 'starved/pocky', 1111, 1200);
		scaleObject('FlickyBody1', 0.65, 0.65);
		setScrollFactor('FlickyBody1', 1, 1);
		addLuaSprite('FlickyBody1', false);
		
		makeLuaSprite('FlickyBody2', 'starved/ricky', -150, 860);
		scaleObject('FlickyBody2', 0.65, 0.65);
		setScrollFactor('FlickyBody2', 1.2, 1.2);
		addLuaSprite('FlickyBody2', true);
			
        makeLuaSprite('FlickyBody3', 'starved/cucky', 1100, 540);
		scaleObject('FlickyBody3', 0.5, 0.5);
		setScrollFactor('FlickyBody3', 1.2, 1.2);
		addLuaSprite('FlickyBody3', true);
		
		makeLuaSprite('FlickyBody4', 'starved/flicky', 1300, 800);
		scaleObject('FlickyBody4', 0.6, 0.6);
		setScrollFactor('FlickyBody4', 1.2, 1.2);
		addLuaSprite('FlickyBody4', true);
		
        makeLuaSprite('FlickyBody5', 'starved/shoe', 920, 1400);
		scaleObject('FlickyBody5', 0.7,0.7);
		setScrollFactor('FlickyBody5', 1, 1);
		addLuaSprite('FlickyBody5', false);
		
		makeLuaSprite('FlickyBody6', 'starved/picky', -120, 1400);
		scaleObject('FlickyBody6', 0.7,0.7);
		setScrollFactor('FlickyBody6', 1, 1);
		addLuaSprite('FlickyBody6', false);
		
		makeAnimatedLuaSprite('EggTV', 'starved/tv', 595, 500);
		addAnimationByPrefix('EggTV', 'hungry', 'idle', 20, true);
		objectPlayAnimation('EggTV', 'hungry', true);
		scaleObject('EggTV', 1.35, 1.35);
		addLuaSprite('EggTV', false);

		makeLuaSprite('FrontBody1', 'starved/fishF1', -140, 460);
		scaleObject('FrontBody1', 1.35, 1.35);
		setScrollFactor('FrontBody1', 1.1, 1);
		addLuaSprite('FrontBody1', true);
		
		makeLuaSprite('WarningLight', 'starved/light', -230, 450);
		scaleObject('WarningLight', 1.35, 1.35);
		setProperty('WarningLight.alpha', 0.60)
		addLuaSprite('WarningLight', false);
		setBlendMode('WarningLight','add')
		
        makeLuaSprite('UI', 'starved/vinevrom', 0, 0)
        addLuaSprite('UI', true)
        scaleObject('UI', 1, 1)
        setScrollFactor('UI', 0, 0);
        setObjectCamera('UI', 'camOther')
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
        if value1 == 'fight' then
            for i = 1, #fightSprites do
                doTweenAlpha('fightHide'..i, fightSprites[i], 0, 0.5, 'linear')
                doTweenColor('boyfriendColor','boyfriend','FF0000',1,'linear')
	        	doTweenColor('dadColor','dad','FF0000',1,'linear')
        		doTweenColor('sonicColor','StarvedSonicDead','FF0000',1,'linear')
            end
        elseif value1 == 'normal' then
            for i = 1, #fightSprites do
                doTweenAlpha('fightShow'..i, fightSprites[i], 1, 0.5, 'linear')
                doTweenColor('boyfriendColor','boyfriend','FFFFFF',1,'linear')
	        	doTweenColor('dadColor','dad','FFFFFF',1,'linear')
        		doTweenColor('sonicColor','StarvedSonicDead','FFFFFF',1,'linear')
            end
        end
    end
end