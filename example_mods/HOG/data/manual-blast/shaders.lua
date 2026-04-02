local canGlitch = false
local scorchedSinging = false

local winIsFull = nil
local moveWindow = false

local iconsGlitch = {
	['scorched-g'] = {['idle'] = 'lordx', ['singLEFT'] = 'XENO-P3', ['singDOWN'] = 'xterion', ['singUP'] = 'grimeware', ['singRIGHT'] = 'rerun'},
	['scorched-g2'] = {['idle'] = 'mighty', ['singLEFT'] = 'cyclops', ['singDOWN'] = 'eyx', ['singUP'] = 'griatos', ['singRIGHT'] = 'sallyAlt'}
}

local savedWidth = 0
local savedHeight = 0

function onCreatePost()
	savedWidth = getPropertyFromClass('flixel.FlxG', 'stage.window.width')
	savedHeight = getPropertyFromClass('flixel.FlxG', 'stage.window.height')

	createInstance('iconGlitch', 'objects.HealthIcon', {iconsGlitch['scorched-g']['idle'], false})
	addToGroup('uiGroup', 'iconGlitch', getObjectOrder('iconOpp', 'uiGroup') + 1)
	setProperty('iconGlitch.visible', false)

	makeLuaSprite('scorch', 'manual-blast/glitch/scorchedface')
	setProperty('scorch.color', getColorFromHex('000000'))
	setProperty('scorch.alpha', 0)
	scaleObject('scorch', 0.7, 0.7)
	screenCenter('scorch')
	setObjectCamera('scorch', 'other')
	addLuaSprite('scorch')

	makeLuaSprite('shake') makeLuaSprite('winpos')

	makeLuaSprite('bloom')
	setSpriteShader('bloom', 'brightness')
	setShaderFloat('bloom', 'saturation', 1)

	makeLuaSprite('cab')
	setSpriteShader('cab', 'chromatic')
	
	makeLuaSprite('glitch')
	setSpriteShader('glitch', 'glitchChromatic')

	makeLuaSprite('glitch2', nil, 0)
	setSpriteShader('glitch2', 'glitchb')
	setShaderFloatArray('glitch2', 'iResolution', {1280, 720})
	setShaderFloat('glitch2', 'Amount', 0)
	if shadersEnabled and not lowQuality then
		runHaxeCode([[
			game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader)];
		]])
	end
end

local oldAnimDad = ''
local noteShake = 0
local targetCAB = 0
local targetGlitch = 0
local targetGlitch2 = 0
local sex = 0
local fucker = false

local winShake = 0
function onUpdatePost(e)
	callMethod('iconGlitch.setPosition', {getProperty('iconOpp.x'), getProperty('iconOpp.y')})
	setProperty('iconGlitch.alpha', getProperty('iconOpp.alpha') - 0.4)
	scaleObject('iconGlitch', getProperty('iconOpp.scale.x'), getProperty('iconOpp.scale.y'))

	sex = sex + e * playbackRate
	setShaderFloat('glitch', 'iTime', sex)
	setShaderFloat('glitch2', 'iTime', sex)

	setShaderFloat('bloom', 'brightness', getProperty('bloom.x') * 2)
	setShaderFloat('bloom', 'contrast', 1 + (getProperty('bloom.x') * 4))

	setProperty('glitch2.x', lerp(getProperty('glitch2.x'), targetGlitch, 5 * e))
	setShaderFloat('glitch2', 'Amount', getProperty('glitch2.x'))

	setProperty('cab.x', lerp(getProperty('cab.x'), targetCAB, 5 * e))
	setShaderFloatArray('cab', 'rOffset', {-getProperty('cab.x'), 0})
	setShaderFloatArray('cab', 'gOffset', {getProperty('cab.x'), 0})
	setShaderFloatArray('cab', 'bOffset', {getProperty('cab.x') * 2, 0})

	if canGlitch and curBeat < 1250 then
		setProperty('glitch.x', lerp(getProperty('glitch.x'), targetGlitch2, 5 * e))
		cameraShake('game', 0.005, 0.1)
		cameraShake('hud', 0.002, 0.1)
		setHealth(getRandomFloat(0.75,0.6))

		callMethod('winpos.setPosition', {
			((getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.width') - getPropertyFromClass('flixel.FlxG', 'stage.window.width')) / 2) + math.sin(sex / 2) * 30,
			((getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.height') - getPropertyFromClass('flixel.FlxG', 'stage.window.height')) / 2) + math.cos(sex + (math.pi / 2)) * 30
		})

		setShaderFloat('iconBF', 'binaryIntensity', getRandomFloat(2,5))
		setShaderFloat('iconOpp', 'binaryIntensity', getRandomFloat(5,15))
		setShaderFloat('iconGlitch', 'binaryIntensity', getRandomFloat(5,15))

		for i = 0,7 do
			setShaderFloat('strumLineNotes.members['..i..']', 'binaryIntensity', getRandomFloat(2,5))
		end
	end

	if moveWindow then
		winShake = getProperty('shake.x')

		setPropertyFromClass('flixel.FlxG', 'stage.window.x', getProperty('winpos.x') + getRandomFloat(-3, 3) * winShake)
		setPropertyFromClass('flixel.FlxG', 'stage.window.y', getProperty('winpos.y') + getRandomFloat(-3, 3) * winShake)

		setShaderFloat('glitch', 'GLITCH', getProperty('glitch.x'))
	end

	if noteShake > 0 then
		noteShake = lerp(noteShake, -0.01, e * 3.15 * playbackRate)
		if noteShake <= 0 then noteShake = 0 end

		for i = 0,getProperty('notes.length')-1 do
			setProperty('notes.members['..i..'].angle', getRandomFloat(-1,1) * (noteShake * 2000))
			setShaderFloat('notes.members['..i..']', 'binaryIntensity', getRandomFloat(2,5))
		end
	end

	if fucker then
		--setShaderFloat('xd', 'intensity', getProperty('xd.x'))
		--setShaderFloat('xd', 'scale', 0.7 / (1.3 - getProperty('camGame.zoom')))
		scaleObject('scorch', 0.7 / (1.3 - getProperty('camGame.zoom')), 0.7 / (1.3 - getProperty('camGame.zoom')), false)
	end

	if getProperty('dad.animation.curAnim.name') ~= oldAnimDad and dadName == 'scorched-g' or dadName == 'scorched-g2' then
		oldAnimDad = getProperty('dad.animation.curAnim.name')
		callMethod('iconGlitch.changeIcon', {iconsGlitch[dadName][oldAnimDad]})
	end
end

function opponentNoteHit()
	if canGlitch then
		cancelTimer('lolero')
		scorchedSinging = true
		runTimer('lolero', 0.35)
		setProperty('cab.x', 0.001)
		setProperty('glitch2.x', 0.25)
		noteShake = 0.0095
	end
end

function onBeatHit()
	if curBeat >= 1250 and canGlitch then
		removeLuaSprite('luz2', true)

		moveWindow = false
		canGlitch = false
		runHaxeCode([[
			//game.camGame.filters = [new ShaderFilter(game.getLuaObject('xd').shader)];
			game.camHUD.filters = [];
		]])
	end

	if canGlitch and scorchedSinging and curBeat % 2 == 0 then
		playAnim('t', 'idle-'..getRandomInt(1,3), true)
	end
end

function onSectionHit()
	if canGlitch then
		if scorchedSinging then
			playAnim('gf', 'idle-alt'..getRandomInt(1,9), true)
			setProperty('gf.specialAnim', true)
		end
		setProperty('glitch2.x', 0.4)
		setProperty('cab.x', 0.0025)

		if curSection <= 308 then
			if curSection % 4 == 0 and curSection ~= 296 then
				triggerEvent('Change Character', 'dad', 'scorched-g')
			elseif curSection % 4 == 2 and curSection ~= 298 then
				triggerEvent('Change Character', 'dad', 'scorched-g2')
			end
		end
	end
end

local appear = false
function onEvent(n, v1) 
	if n == 'bright zoom' and flashingLights then
		cancelTween('bloom')
		setProperty('bloom.x', 0.25)
		doTweenX('bloom', 'bloom', 0, crochet / 250 / playbackRate, 'cubeOut')
	end
	if n == 'sexxxxxx' then
		if v1 == 'startingglitch' then
			doTweenX('glitch', 'glitch', 1, crochet / (1000 / 8), 'cubeIn')

			winIsFull = getPropertyFromClass('flixel.FlxG', 'fullscreen')
			doTweenX('shake', 'shake', 1, crochet / (1000 / 8), 'cubeIn')

			if getPropertyFromClass('flixel.FlxG', 'fullscreen') then setPropertyFromClass('flixel.FlxG', 'fullscreen', false) end
			savedWidth = getPropertyFromClass('flixel.FlxG', 'stage.window.width')
			savedHeight = getPropertyFromClass('flixel.FlxG', 'stage.window.height')
			setPropertyFromClass('flixel.FlxG', 'stage.window.resizable', false)
			setPropertyFromClass('flixel.FlxG', 'stage.window.width', savedWidth * 1.1)
			setPropertyFromClass('flixel.FlxG', 'stage.window.height', savedHeight * 1.1)

			moveWindow = true
			callMethod('winpos.setPosition', {getPropertyFromClass('flixel.FlxG', 'stage.window.x'), getPropertyFromClass('flixel.FlxG', 'stage.window.y')})
			doTweenX('winposx', 'winpos', (getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.width') - getPropertyFromClass('flixel.FlxG', 'stage.window.width')) / 2, crochet / (1000 / 8), 'cubeInOut')
			doTweenY('winposy', 'winpos', (getPropertyFromClass('flixel.FlxG', 'stage.window.display.bounds.height') - getPropertyFromClass('flixel.FlxG', 'stage.window.height')) / 2, crochet / (1000 / 8), 'cubeInOut')

			if shadersEnabled and not lowQuality then
				runHaxeCode([[
					game.camGame.filters = [new ShaderFilter(game.getLuaObject('bloom').shader), new ShaderFilter(game.getLuaObject('cab').shader), new ShaderFilter(game.getLuaObject('glitch').shader), new ShaderFilter(game.getLuaObject('glitch2').shader)];
					game.camHUD.filters = [new ShaderFilter(game.getLuaObject('glitch').shader), new ShaderFilter(game.getLuaObject('glitch2').shader)];
				]])
			end
		end
		if v1 == 'glitchbg' then
			setSpriteShader('iconBF', 'NewGlitch2')
			setSpriteShader('iconOpp', 'NewGlitch2')
			setSpriteShader('iconGlitch', 'NewGlitch2')
			setProperty('iconGlitch.visible', true)
			cancelTween('glitch')
			borderFlick = false
			if not getPropertyFromClass('flixel.FlxG', 'fullscreen') then setPropertyFromClass('flixel.FlxG', 'stage.window.borderless', true) end
			canGlitch = true
			targetCAB = 0.0005
			targetGlitch = 0.1
			targetGlitch2 = 0.055
			sex = 0
			for i = 0,7 do
				setSpriteShader('strumLineNotes.members['..i..']', 'NewGlitch2')
			end
			for i = 0,getProperty('notes.length')-1 do
				setSpriteShader('notes.members['..i..']', 'NewGlitch2')
			end
		end
		if v1 == 'byebyemanual' then
			--doTweenX('xdxddasda', 'xd', 1, 3.1, 'cubeIn')
			doTweenAlpha('xdxddsasasda', 'scorch', 0.3, 3.1, 'cubeIn')
			fucker = true
		end
	end
end

function onDestroy()
	setPropertyFromClass('flixel.FlxG', 'stage.window.borderless', false)
	setPropertyFromClass('flixel.FlxG', 'stage.window.resizable', true)
	setPropertyFromClass('flixel.FlxG', 'stage.window.width', savedWidth)
	setPropertyFromClass('flixel.FlxG', 'stage.window.height', savedHeight)
	if winIsFull then setPropertyFromClass('flixel.FlxG', 'fullscreen', winIsFull) end
end

function onTimerCompleted(t) if t == 'lolero' then scorchedSinging = false end end

function lerp(a, b, t)
	return a + t * (b - a)
end

--[=[
dQvJjL*J@$$YUfZ#C0YO%mtc*#wucC#b0qnUzzwdv0*UJYB$$80ccjUvuULZCpX#YYzahpcxY*n0nQ/JrL8JC$$@8nO*0zd*UW8huL#MY
@BBB@B%@@@@BBBB8B@@@@B@BB%B@@%%%B@@#BBBB@BB@%B@@$$@@@@B%@@@@BBBBB%@B@%@%@BBBBB@%@BBBB@@@BB@@%%@@B@BB@%8%%
raXwdbJUh8@/p|0acp0batwd*c|Cmpq(tJd|ZfUpt)jX)kMB@B#B*0pmpw*WMCxm*hW0ZfohCvnqdqjk*Xtz0q&@bUa8bamhX%n|fk#tf
wakpp*MpZdB$@mbw*WpZZkBZUb8ow0wp%q0ZmC#w0OQmaahM8$$@a*owhQpk#MMM#habo8#Zob&MOq8WLhhOmp0B$$%bW8*o&apB#bdw%
@@@@@@$@@@@$@@@@@@@@@@@@@@@@@@@@$@@$@8@@@@@@@@@@$$$$@@@@@@@@$@@@$@@@@@@$@B@@8@@@@@@@@@@@@$@@@$@@@@@@@@@@@
JdqCucj/qC@$$|LfqkcJQZ8/(Jh0r)tXbUf|rxXrrwum*JUU#$$BdMdzOn0U#dpZ0qYYd#hrzr0o(0UZ(x(rOU0@$$ouoMwwbwXBdtjJh
W88WMW#W%W@$@M&W%B&MW8@&*WB%8##&B8&&MMW&WW&%BWWW@$$@8%&M8#MW%8&&%%WMWB%8M#W%M8MWavOWB88$$$B&%%88%88@B88WB
W&&W##*k&W@$$hWa&&oW&&BkoM##kha#&ohdoaMha8oWBMMM8$$@%@%MW*%MB88W*W#M%%8hMo&%p*pt'  w#*#@$$8o%@M&&&o$WdkW8
vOqzru(jqz@$$/XfwkznYQ%x-xi+u1/ca0uvtjvcnLxZoXcX&@$BZwQxJ/vvpw0LCdcrQMbXxfzk~i`  " !bLZ@$$Mvb*OQkwc8oXvvh
%@@@@@@@@@@$@$@@@@@@@@@@@MI  .~c*@@@@@B@$@@@@@@@@@$@@@@@@@@@@@@@@@@@@@@@@Batl..,-p@J.(@$$$@@@@$@@@@@@@@@@
0ao#ZmOCOQa@$$aLM%hhhom@0+ )f' ,/pWpOY0hhq0M8d0pbh$$$q#w#hLow#$ZoM8wQwoMqx+!<_uxL&0z^;QWo$$@#B&*W&z&@80mo
}QcY~/1vZQC@$$avbom0pZX#` lrMpUOnj&JMQu)#q(0oj(U(%$$$(Y(JO1|]YB/~0*wt/n|J(}f{)On1f{Qj ;wM$$okw0OcYrpBbZdb
%B@@@@@@@@@@@$$@@@@@@@m< }&@@@@@@@@@@@B@@@@@@@@@@@@$$@@$@@@@@@@@@@@@@@@B@@@@@@@@@@@@@|:/o@$$$@@@@@@@@@@@@
ochnxaU/fux#d%$#Mh*ZCh`  x0mqrp*hxJbd#x]hbOL&0uYrpC$$$hU#MQmbqu$J{rOpt//r0QttnJL|)awXvC,"!$$duaojuzpJ@UmM
UY*OUccXzx1_>I!Irxhhz( lCp0W*LJW8*bZp8b0awoZoZUXwqk$$$Bh%8*#Www@omaU&ppLLp8dO?c)8LfmMkpd":$$hUaoQpCvUBJza
@B@8d0Uxzv1<.   ;O%h+xpo@@BBB@@@@B@@@@@%@BB@@@@@@@@@$B@B@@BB@@B@@@B@@@@@BX~~i."Z%B$@@J+Zbd@@@BB@BB@@BBB@@
vrtQ/0hXUXo@%r<` '1m.}BLQpo|({i"])rOp)pxr0n(zYudh$$$kJ#&LJkwJBw(fuZvZux_?      }fOhx].;aWhX1nc!i/L(o1fpYQ
h#aao&Moko@@@ha~  +_iQ%d0x[i.    .uddpWkdpqb#M#8%$@@B*%8#MW#MB%*Mh8o&-_^      .td#nI/I:}<"^.      `(ddWhB
88BB%%%%%@@B&W*h< ..i%8%^         'O#&&BB8&%B%8$$$@B@BBBB&@B@%88&BB8}          ]&8~    ^,'I)jj/~"^^^C%B%8
UxodxuXX0qc)l,. .   iJfv.           !v1cYujZMzY$$$%obdmqC/##*0ZCtp*[           '(x`   `Y#jLjpoUz00q-:cOdC
BBB@BBov}I;^ .I.'   iBBB,            <%BBBBB@B@*@$@@@@BBBB@@@@@BBB[             WBki   ."?MB@@BBB@@BdWB@@
m#MmQzf|{YZQv-'     >&&%0'            <opk#wqbanJB@#%MZW#p%8@bqbhr'            !qo%)   >'  +Xad##WBwo*8dZ
)(/)twhJqk~^  ^.    iLvCq/             ~?jt)cqrJ`/8W*k|OmxMM%dJJ].            .v0Zm:   IQ]' .,<(uw8f_0WwU
@B8BB@Box''i/ac..  "l8B@@O'             YB@@@BB&|lU@B<J@@@@@@@@0`             :MBM~'! I /%8u~' `O8@@BB@@@
ukoXzC/!.+mopO^'` ^)^L#&mm]             `jbuzLmWBQ^0Y-h8bY8MBCv;              [MU] -C`<t.-wcqXi'`{8cqa#Yn
x(nJz(Iim@$W| ,;  ,j ]zLakv"             :rxCoY$$k.'!kawqzW8%w.              -LU( IUv{ a+ nU#8q(l'~x[Z8bZ
@@BO1fL8@$$M<'r';`(@"[@@@@@U             .n@@@@@$8[ '8@@@@@@8+              Ia8{ ]M@@p^nk`lk@@@@8Uiz@@@@@
nUL]1UQUJ@B1.o~ } 0Cf XoJLjrI             'JoQ|$@%( -hp#Jt&#r              .c0".`uc1pn>i%} .wmrZap*:xCQv|
UQLphpp#8#L]_C{'n:tLU(1Cwdwmcf;          .<)0WW%aL1I}xa*OoMC'            .-pCf'_LQppMULn|Yxr{CQ0Wd0mmpwbm
%p8B$@@@@@M:L%I_*;{@@8 `vB@@@@U             `B@W@$di `W@@@@f I           IoB%[.zB@@@@@@0,@@%^,@@@@@@@o@@@
n)OLpOYqLJf/Mp.ht.[jhB]' ;_Jdow[             }*C@@*  "UCdw-..'         ;/ptn).?X%OnYXY0p^%u&< ((Zc%0r0Ykj
%*aW%8WWMh)W%Z(8v.pa&B#b} .{#&8%}            +*p@M}   lwq< ^          _o8%&p'<WMB&*oW#8k;@o%m"?*aoBWo**B*
**B&o##MW0o@%ZU%z'#*@B%8Wn. X&*&al          '",.,'        ^`    .,,.^~bo*o*r'Jo&8MaMBM*p?BW@&i_kB8@8&%#&M
Cx*kUvOrkk@8c#d}1utn@qX0xm: izwhxf.        '^       .   '"Iil", ..]c|r-1Yu~<(YwUcn(Xqv(nk8hBU:JxWa@qUmvdp
o@B&#%%MW$$@#*#i1o%o8%8W8%k,}o#@&@L;,"   I,l;    ^''|,,'         {~Ii1u%&Bi~p*%%WB&8Ba/a%B#kplo&&&@B8WM@@
mpM*Cph0hw@$@OoZJ'OMM#%LdYZLv^:J0wZ0hz);.       i-<.fp8U 'i_]]1{l~~~uLmz*U}.:cxaZdpObmmua$omWBj/&Ww@bLm0q
xZkLUn|cmc@$@|0cU!L1Qp%r+.XwO- |*LcunfwYnzv(^  ~vx^ZmBhct '+0YUXLqn1dM8Y1' ,)]"c{//vaarZ$$&Z&WtYoqZBoXpr#
#W@  Im Watching You  @%M.'}0a>:8B&&*kOx(+.`l1wwx[UX(!1xWY> ^{cddM##aMqU^`x&0i,*&%W8B*d@@$B#W%Jh%B#B@B#%%
zLobtLwrZYB$@vbcJ]cook%r0|, "c].}cf}Ufz<?X_xkXr}O0,     Xxb<  .";;>l?-;."<Mk!"^qzJQuOzu@@$bX#Wnu#oJ@OfYnC
Yq*wOJcLdL@$@cwL0/mnmb%Utq*  rr uZJXYzkQLZma*Qxa0       rxZQWx_+l!i<}~ "fCUii/t0vccL#oQ$$$8w&&mh#kq%MOdJW
%%@BBBBB@B$@@B%%Mx%@BB@BBBB. wB`tBBB&kOLOk#88BBk:       qBBB%BB8**#Mz`~dBBWi~&BBBB%B@%B$@$@%BB%%@@%B@@%BB
bdtvLfwz@$$jdxL-vdpa#/YXJ' ]0,`+()Q)Jtz#nYWUxf.     `<X{bp8hohjUZ(,"Q1Z]u.{j0dxuYxmCf@$@pCo%Yjh*L@0fzf0c0
MhdwZd#d@$$mhwaQbwk#%d0b&? -Zx   '<tkpdok#Wawpr^ '<(QOd0db&ahak#q:'m%k[}? UbwkOwmd8*p@$@BkW8aaW8aB8hhp8o*
B@BB@BBB@$$B@BB%h@@@@B@B@v -%MmdI.  ;mBBBBB@BB@@@@@$@BBB@@@@@BB@c.OBBW+l" BBB@BB@BBBB@$@@B@$BB@@B@BBBBBBB
QpUw*Q|p&$$fduLUXL0oMrCJh{ "CU]ixu[^  >1YxLZnm*$$BoBMZu1pb&W*0tf`ihmb[:' ?cxdpCQac|YcM$@kLo%vYh#C$UrdjQtu
#*UOZOdJB$$OCrCa0*YL8ZzQ#h,.YZl`ZLXU|" .")MOJXW$$8ZvzXJmLmXO{I'' }Q*hL.I htvCaYwCLoJvB$@&n0*QYaMz&WbxqM*z
8B#M@Mh8B$$M%MWa&B%B@MBM&o[ nd<.Y%hQpWvi  {hhW%@@%ohOLU|I.     ,_u0W8/,kroW#8&%#BM#MMB$$&W8@*oB@W$M#%oh*M
adzoaJfLoW$&dJh*OhbbQ8Ut00k[<IX/">/i"iu/r/`:;_f(/+!:.      `I<(U*j]iCw_;0pL{a0Ymmufx/dM$%&#BaXdW0W&oxxZLU
dbwZ#LwZn%$$&xOoQvMkc%apXq%hz]/L  X|  0Qhuf],    .'^I><_|JUz%x;wW^:'Q} ]Z0arkUzZdQd0cka$@a0kYcpLMJBM@0a0#
Mo8hBhqaa&$$#hW@wd%Ba$bk%wOdhhjX. /#  Ud#l.bcnn(JQZ0a#&OM8#B(} ha  iol"Wo%8ZM#m#BadMbhW$$@&@8m*W*&$%hahmZ
kmc*kYrUk#$$pzk8UwpdzBv(J0&|t(qp> l/" I|c  vp0hzB%$fwjQ)fZx)  .Q)  [t.1xCpJ_aLtZQnft1q*$$%*%orp*0oBM(rpQc
*Moh&baamB$$%ZhWkw&#w%M*woBMq*h* ]Z[ !bb` rw#q?ctBwqr_ pkZ;  nb, Idix&dhkMO#pwa*k*kw#M$@Mh#pw*b&bB8@hWkW
%&aMh*%b$$$#&&oWhM%%@Mo#md8##tk{.Yd:.(8n' ohar` J8*n^.1#B?. [&+'.bUWqZM*M@O*h8M&dhBhh@$@B@B8hw8%B%B8qoWb@
nOdpUJXQ*@@#XwQjCz0XhJu0tWcvzu?Q!`+X"!-ut,i-hx_:i[wLi:^nuYt:;ru;"~0QZMcdQQCmxjW0vJuUq0@BB0On0aLZZq8LXXwaw
WBB%W8&8%@@@&WWM&88W&%&&M@8&&%##~ )MnoQ,;0*I:1M#Y',!**1^'mM*,,<#j`:MWMI/&B8%WWB8&8M8BW@@@%&M8%WB&8@%&W8B%
a&po%#dakhW$$@oB#dhbMh@#hMwWdd#*-'}mh%f:.Yo+ i#bJ  ^B&] 'Zkp '*h,'jMMZ ~k%*hk*dhB#mkbp#h@$$bobW#**WM$dha*
wp/b&mz0X0w$$Bvzn/UQ0xLqcJj8YvYd_.xLnZt> nZi ^hnr  ^W8: "Ou- 1oz._Yaki^UL&CbLOxX80zQrCdv@$@LvtZbxhJU@0vuw
8BB@BB@@@BB$$$@@@@BB@@@$@@B@BB@@f /%@B%u XBc .bB%  ^B@I ?BW+.J@a_MB%[,h%BB@BBB@BB@BB@BB@@$$B@B@B@@B@$B@@B
JOzpkJLk#C0$$@qBkLwZ*w@**hOawZ%#U Iphkcw nQC' nJa  ^Ba  r*0^<o@mUQbb:^z#habzUdMQZkqhMk0#*$@UwLokwdpk@XwoW
)Y?zzv{wh(X@$B(j([zu(/n0tLrorfxoL  ]OM}n([+z^ LrrI ^Wp .JZ[`pZBMwjvZ :nwCBc#xz+YdQ1ZOfv}&$@Yf}Qd/Q/j@n+uk
8B%@@%&BB%B$$$B$BB%B@@$@@@8BB%@B%l )@@M%%#BBZ,k%%f ;@u nBB88@@@BBB&J cB@%@%B%B8%$@&BB%B%$$$BBBB%B@@@$BBB8
#dvz8opOJww$$BLBZxZJkz$wzpZ*rvZk8X 'X#+ttZqrxcbXXh'n@i'bah*c%M@QXv?, k0bJ%#vzqdZWLUUn/phB$$rLcaaQLkm@tuQW
ZbCd#qY0QOd$$BzCYvZ0YvZdzJJBLJYdb&-:ti xv0CZzbMUm%uw8n1UwdYZMko*#+.'[Cw80MQ*bbYZWLYQcq*Y@$@ZJzb*JdQ0@qXJw
MB&@@8M%B8B$$$B$B%&%@B$BB@W%%8@@&WMdL  )%B%B%%B&&@B%@%8BBBWB$M-&u' 1#B%@8@&B%B&8@@#BB%%8@$$%B%B8%@@B$8%%&
kwucWb0LXQ0$$BzoJt0JmxMZxO0*jrCd#p|/}   1LQ_/m*rx$$$Bobabbbno[ c^  h#mCaY8bzcZOZWJvXf/pmB$@fYrbhYJw0@tjYo
aMbM8*baho#$$Bbkbpaakpo#dkbBakb#M%baC^  La>^O#8zi%$@B@hxb#bJ!' L" _&8koBa8h&##da%adap*&b@$@okp#&bMaa@*bbo
W%%B8&W8BB@@B@%8B&%B%%BB&%&BBB88&8M*b!` (h^`f#%-,*MWMZJltMo1   Y^^Q&%@%%WW8B8W8%%8#%B%@%8@%&%%%&$%8%%B&W&
LYhqvJXp@@bqUmcrUtOWUXaqXvbOOMvzzz"  [c  {/f .b@@q.` np}  "J  'wpwJrU%woY?ZhXzMQxvfLh@@M/wY[C0X|hJjzcWrtx
BB@BBBB@$@@BBBBBBBB@BB@@@B@BB@BBBBj  vm  |Bn  u$@Z   W8I  iY  JB@@BBB@B$@%BBBB@BBBBB@@$@BBB%@@BB@BBBB@BBB
*&bddZkd&B@BB8W&*#MW8B#pZ#8*akkh8Mvl'>xi".J/<.lCM0[ .vJ(' ~1} vZWhmqwo&wmbkdoqdWZwaab88@%a&bo#b&b8%Md*8p#
x0-f)tOLU@@%*ZmLCxJbm8opYJapLq0fhYoC-.`Y~ "I)^ '0@b   [#. .nk  tMdY}|rWz/t||Qt)r1ckCvdM@B|L|Xm1f}O8zfb8z/
@@$@@@@@@@$@@@@$@@@@@@@@@@@@@$@@@@@@81Ipa. i8l .(@h   Cq  ^qa }@@@@@@@@@@@@@$@@@$@@@@@$$@@$@@$@@@@$@@@@@@
vdoYL*#bU@$@%*&#ahhh&B#wJdo#BaaXk#bbLqvYY< `c: .I@h   wt  lk8+vm%aUzvOWqL|zhmCComo8ZhmM$@OMLh*Y*0W%0oM%0J
mUnv/ChL@@$v0vdWZuJd&L1c*apftJ#dQZnxJQY0_  |; .>&o` ~/x ^ua0JOdavuYo*Zr|u#ubxX[ujL&Zp@$@8Lh*dOpaw&&wOz#aw
@@&%@BB%@$$B@BB%B@@@@B@%B%BBB88BB%BM@B@@#i 1X  Ioo' tBkcmB@@@@8BBB@BB%@&@@M&BB%B@B@B&$$$BBB@%8@@B@BB@%B%B
bmLnj]kh@$$(mnQ#Lzmk#(rQ8L|(1a8Yt?f0w)vdLt .n  ;aW> ncJUpZ%pqpfwJJo#&cXUQMtvUhCf{jOcz$$@oY&%O*whL@w)+b8Lm
#bZqLpWq$$$qwLbWphqbBhQ0WWaOmp&*baQmmZa#Oprrm} <8%QjJQwZZpphdaO&wqZ#*om0qMQp0kLqQp%wq@$@%0bWdO#&w8%#0p&8m
@@B@@@@@@$$@@$@@@@@@$@@@@@@@@@@@@@@a$@$@@@@@$%z{$$@@@@$@@@$@@@@@@@@@@@@@@@B@@@@@@@@@@@$$@@@@@@B@@$$@@@@@@
cdXmbZvYM$$|O/0*cJYp#/cZ&U)vLma/)cZ1mfuL||XC(bW@$%d*bXOYQmo*o0u0kwawwtkwOLjLkk(whntzXo$@azk8qwwbcBU/fm&c/
WWMW8Mo#@$$#MoWBMooWB*aMB&#o#MB#oo*h&ooao*8&#8B$$BWWWoMa*W88&%WWWWW%%*&#%%**8%aMWo#Ma@$$BM8B&W88MB%WMM@8*
]=]