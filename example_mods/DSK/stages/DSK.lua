local fuegoDistancia = 30
local fuegoVelocidad = 2.4
local fuegoYBase = -470

local fx2Pulse = false
local fx2AlphaMin = 0.4
local fx2AlphaMax = 0.8
local fx2PulseSpeed = 0.04

function onCreatePost()
	makeLuaSprite('sky', 'Miasma/sky', -820, -600);
	scaleObject('sky', 1.5, 1.5);
	setScrollFactor('sky', 0.5, 0.5);
	setProperty('sky.antialiasing', true);
	addLuaSprite('sky', false);

	makeLuaSprite('rock2', 'Miasma/rock2', -850, -460);
	scaleObject('rock2', 1, 1);
	setScrollFactor('rock2', 0.6, 0.6);
	setProperty('rock2.antialiasing', true);
	addLuaSprite('rock2', false);

	makeLuaSprite('rock2b', 'Miasma/rock2b', 710, -460);
	scaleObject('rock2b', 1, 1);
	setScrollFactor('rock2b', 0.6, 0.6);
	setProperty('rock2b.antialiasing', true);
	addLuaSprite('rock2b', false);

	makeLuaSprite('rock3', 'Miasma/rock3', -400, -80);
	scaleObject('rock3', 1, 1);
	setScrollFactor('rock3', 0.7, 0.7);
	setProperty('rock3.antialiasing', true);
	addLuaSprite('rock3', false);

	makeLuaSprite('rock3b', 'Miasma/rock3', 500, -80);
	scaleObject('rock3b', 1, 1);
	setScrollFactor('rock3b', 0.7, 0.7);
	setProperty('rock3b.flipX', true);
	setProperty('rock3b.antialiasing', true);
	addLuaSprite('rock3b', false);

	makeLuaSprite('rock4', 'Miasma/rock4', -950, -130);
	scaleObject('rock4', 0.7, 0.7);
	setScrollFactor('rock4', 0.8, 0.8);
	setProperty('rock4.antialiasing', true);
	addLuaSprite('rock4', false);

	makeLuaSprite('rock4b', 'Miasma/rock4', 1100, -130);
	scaleObject('rock4b', 0.7, 0.7);
	setScrollFactor('rock4b', 0.8, 0.8);
	setProperty('rock4b.flipX', true);
	setProperty('rock4b.antialiasing', true);
	addLuaSprite('rock4b', false);

	makeLuaSprite('rock1', 'Miasma/rock1', -110, 170);
	scaleObject('rock1', 1, 1);
	setScrollFactor('rock1', 0.9, 0.9);
	setProperty('rock1.antialiasing', true);
	addLuaSprite('rock1', false);

	makeAnimatedLuaSprite('fuegocaca', 'Miasma/fuegocaca', -1050, -470);
	addAnimationByPrefix('fuegocaca', 'idle', 'fuegocaca instancia 1', 50, true);
	objectPlayAnimation('fuegocaca', 'idle', true);
	scaleObject('fuegocaca', 1.06, 1.06);
	addLuaSprite('fuegocaca', false);
	setProperty('fuegocaca.alpha', 0.000001);
	fuegoYBase = getProperty('fuegocaca.y');
	doTweenY(
		'fuegoBobDown',
		'fuegocaca',
		fuegoYBase + fuegoDistancia,
		fuegoVelocidad,
		'sineInOut'
	);

	makeLuaSprite('tree1', 'Miasma/tree', -1050, -180);
	scaleObject('tree1', 0.2, 0.2);
	setScrollFactor('tree1', 1, 1);
	setProperty('tree1.flipX', true);
	setProperty('tree1.antialiasing', true);
	addLuaSprite('tree1', false);

	makeLuaSprite('tree2', 'Miasma/tree', 650, -180);
	scaleObject('tree2', 0.2, 0.2);
	setScrollFactor('tree2', 1, 1);
	setProperty('tree2.antialiasing', true);
	addLuaSprite('tree2', false);

	makeLuaSprite('floor', 'Miasma/floor', -1050, 120);
	scaleObject('floor', 1, 1);
	setScrollFactor('floor', 1, 1);
	setProperty('floor.antialiasing', true);
	addLuaSprite('floor', false);

	makeLuaSprite('whitebg', 'FX/white', -1050, -680);
	scaleObject('whitebg', 2, 2);
	setProperty('whitebg.alpha', 0.000001);
	setScrollFactor('whitebg', 1, 1);
	setProperty('whitebg.antialiasing', true);
	addLuaSprite('whitebg', false);

	makeLuaSprite('FG1', 'Miasma/FG1', -1150, 800);
	scaleObject('FG1', 1, 1);
	setScrollFactor('FG1', 1.2, 1.2);
	setProperty('FG1.antialiasing', true);
	addLuaSprite('FG1', true);

	makeLuaSprite('FG2', 'Miasma/FG2', 1000, 570);
	scaleObject('FG2', 1, 1);
	setScrollFactor('FG2', 1.2, 1.2);
	setProperty('FG2.antialiasing', true);
	addLuaSprite('FG2', true);

	makeLuaSprite('black', '', 0, -250);
	makeGraphic('black', 1920, 1080, '000000');
	addLuaSprite('black', true);
	setLuaSpriteScrollFactor('black', 0, 0);
	setProperty('black.scale.x', 2);
	setProperty('black.scale.y', 2);
	setProperty('black.alpha', 1);
	setObjectCamera('black', 'camOther');

	makeLuaSprite('black2', '', 0, -250);
	makeGraphic('black2', 1920, 1080, '000000');
	addLuaSprite('black2', true);
	setLuaSpriteScrollFactor('black2', 0, 0);
	setProperty('black2.scale.x', 2);
	setProperty('black2.scale.y', 2);
	setProperty('black2.alpha', 0.000001);
	setObjectCamera('black2', 'camGame');

	makeAnimatedLuaSprite('static', 'FX/Phase3Static', 0, 0);
	addAnimationByPrefix('static', 'idle', 'Phase3Static instance 1', 24, true);
	objectPlayAnimation('static', 'idle', true);
	scaleObject('static', 3.3, 3.3);
	addLuaSprite('static', false);
	setProperty('static.alpha', 0.000001);
	setObjectOrder('static', 99);
	setObjectCamera('static', 'camHUD');

	makeLuaSprite('FX2', 'FX/black_vignette', 0, 0);
	scaleObject('FX2', 1, 1);
	setProperty('FX2.alpha', 1);
	setProperty('FX2.antialiasing', true);
	addLuaSprite('FX2', false);
	setObjectCamera('FX2', 'camOther');

	makeLuaSprite('cc', 'StartScreens/Circle-miasma', 1400, 250);
	scaleObject('cc', 0.8, 0.8);
	setProperty('cc.antialiasing', true);
	addLuaSprite('cc', false);
	setObjectCamera('cc', 'camOther');

	makeLuaSprite('txtm', 'StartScreens/Text-miasma', 1400, 250);
	scaleObject('txtm',  0.8, 0.8);
	setProperty('txtm.antialiasing', true);
	addLuaSprite('txtm', false);
	setObjectCamera('txtm', 'camOther');

	setProperty('camHUD.alpha', 0);
end

function onTweenCompleted(tag)
	if tag == 'fuegoBobDown' then
		doTweenY(
			'fuegoBobUp',
			'fuegocaca',
			fuegoYBase - fuegoDistancia,
			fuegoVelocidad,
			'sineInOut'
		);
	elseif tag == 'fuegoBobUp' then
		doTweenY(
			'fuegoBobDown',
			'fuegocaca',
			fuegoYBase + fuegoDistancia,
			fuegoVelocidad,
			'sineInOut'
		);
	end
	if fx2Pulse then
		if tag == 'fx2Down' then
			doTweenAlpha(
				'fx2Up',
				'FX2',
				fx2AlphaMax,
				fx2PulseSpeed,
				'linear'
			);
		elseif tag == 'fx2Up' then
			doTweenAlpha(
				'fx2Down',
				'FX2',
				fx2AlphaMin,
				fx2PulseSpeed,
				'linear'
			);
		end
	end
end

function onStepHit()
	if curStep == 2 then
		doTweenX('cctween', 'cc', 430, 0.65, 'CircOut')
		doTweenX('txtmtween', 'txtm', 430, 0.7, 'CircOut')

		doTweenAlpha('blackIn', 'black', 0, 2, 'linear');
		doTweenAlpha('FX2', 'FX2', 0.3, 2, 'linear');
		doTweenAlpha('camHUD', 'camHUD', 1, 2, 'linear');
	end
	if curStep == 3 then
		triggerEvent('Set Character Offset', 'bf', '40');
		triggerEvent('Set Character Offset', 'dad', '40');
		triggerEvent('Set Character Offset', 'gf', '40');
	end
	if curStep == 10 then
		doTweenY('cctween', 'cc', -670, 0.75, 'CircIn')
		doTweenY('txtmtween', 'txtm', -670, 0.69, 'CircIn')
	end
	if curStep == 392 then
		doTweenAlpha('FX2', 'FX2', 0.7, 1, 'linear');
		triggerEvent('Set Character Offset', 'bf', '60');
		triggerEvent('Set Character Offset', 'dad', '60');
		triggerEvent('Set Character Offset', 'gf', '60');
	end
	if curStep == 464 then
		setProperty('FX2.alpha', 1);
		triggerEvent('Set Character Offset', 'bf', '70');
		triggerEvent('Set Character Offset', 'dad', '70');
		triggerEvent('Set Character Offset', 'gf', '70');
	end
	if curStep == 520 then
		doTweenAlpha('blackIn2', 'black2', 1, 0.6, 'linear');
		doTweenAlpha('camHUD', 'camHUD', 0, 0.8, 'linear');
	end
	if curStep == 528 then
		setProperty('black2.alpha', 0);
		setProperty('FX2.alpha', 0.4);
		setProperty('camHUD.alpha', 1);
	end
	if curStep == 784 then
		doTweenAlpha('blackIn2', 'black2', 1, 0.7, 'linear');
		doTweenAlpha('camHUD', 'camHUD', 0, 0.8, 'linear');
	end
	if curStep == 797 then
		setProperty('fuegocaca.alpha', 1);
		triggerEvent('Set Character Offset', 'bf', '80');
		triggerEvent('Set Character Offset', 'dad', '80');
		triggerEvent('Set Character Offset', 'gf', '80');
	end
	if curStep == 816 then
		setProperty('black2.alpha', 0);
		setProperty('FX2.alpha', 0.5);
		setProperty('camHUD.alpha', 1);
	end
	if curStep == 944 then
		setProperty('black.alpha', 0.3);
	end
	if curStep == 948 then
		setProperty('black.alpha', 0);
	end
	if curStep == 948 or curStep == 1200 then
		fx2Pulse = true
		doTweenAlpha(
			'fx2Down',
			'FX2',
			fx2AlphaMin,
			fx2PulseSpeed,
			'linear'
		);
	end
	if curStep == 1072 then
	-- badapple
	setProperty('FG1.alpha', 0);
	setProperty('FG2.alpha', 0);
	setProperty('whitebg.alpha', 1);
	doTweenColor('dadColorTween', 'dad', '000000', 0.01, 'linear');
	doTweenColor('gfColorTween', 'gf', '000000', 0.01, 'linear');
	doTweenColor('boyfriendColorTween', 'boyfriend', '000000', 0.01, 'linear');

	fx2Pulse = false
	cancelTween('fx2Down')
	cancelTween('fx2Up')
	setProperty('FX2.alpha', 0.5)
	end
	if curStep == 1192 then
	doTweenAlpha('FG1', 'FG1', 1, 0.3, 'linear');
	doTweenAlpha('FG2', 'FG2', 1, 0.3, 'linear');
	doTweenAlpha('whitebg', 'whitebg', 0, 0.5, 'linear');
	doTweenColor('dadColorTween', 'dad', 'FFFFFF', 0.5, 'linear');
	doTweenColor('gfColorTween', 'gf', 'FFFFFF', 0.5, 'linear');
	doTweenColor('boyfriendColorTween', 'boyfriend', 'FFFFFF', 0.5, 'linear');
	end
	if curStep == 1344 then
		objectPlayAnimation('static', 'idle', true);
		setProperty('static.alpha', 1);
	end
	if curStep == 1360 then
		setProperty('static.alpha', 0);
		setProperty('black.alpha', 1);
	end
end

function opponentNoteHit() -- Thx MerphiPlay for the little help :3
    health = getProperty('health')
    if getProperty('health') > 0.2 then
        setProperty('health', health-0.005);
    end
end