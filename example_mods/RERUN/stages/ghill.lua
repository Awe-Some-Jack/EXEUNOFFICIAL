function onCreate()
    makeLuaSprite('ground', 'bg/piso', -2540, -935);
	scaleObject('ground', 1.12, 1.12);
	addLuaSprite('ground');

    --     makeLuaSprite('sky', 'bg/piso', 0, 0);
	-- scaleObject('ground', 1.4, 1.4);
	-- addLuaSprite('ground');
end

function onUpdate()
    setProperty('defaultCamZoom', 0.2);
end