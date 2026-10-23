import openfl.display.BitmapData;
import psychlua.LuaUtils;

var dadLight = {x: 0.0, y: 0.0, floorX: -60.0, floorY: 30.0, size: 1.0, floorSize: 1.0};
var bfLight = {x: 0.0, y: 0.0, floorX: 0.0, floorY: 70.0, size: 1.0, floorSize: 1.0};

var active:Bool = false;
var restored:Bool = true;
var useShader:Bool = false;
var flashing:Bool = true;
var amount:Float = 0;
var target:Float = 0;
var pulse:Float = 0;
var split:Float = 0;
var glitch:Float = 0;
var time:Float = 0;

var blue:Array<Float> = [0.12, 0.42, 1.0];
var red:Array<Float> = [1.0, 0.13, 0.09];

var dadShader = null;
var bfShader = null;
var noteP = null;
var noteO = null;
var holdP = null;
var holdO = null;
var screenShader = null;
var hudShader = null;
var charShaders:Array<Dynamic> = [];
var noteShaders:Array<Dynamic> = [];

var dadOld = null;
var bfOld = null;
var oldFilters = null;
var oldHudFilters = null;
var strumOld:Array<Dynamic> = [];
var bgAlpha:Array<Float> = [];
var gfAlpha:Float = 1;
var hudNames:Array<String> = ['hbBG', 'hbHealth', 'hbHealth2', 'separatorHealth', 'healthBG', 'iconBF', 'iconOpp', 'exeScoreTxt', 'timeBar', 'timeTxt'];
var hudAlpha:Array<Float> = [];

var dadPool:Array<Dynamic> = [];
var bfPool:Array<Dynamic> = [];
var dadNext:Int = 0;
var bfNext:Int = 0;
var dadSus:Float = 0;
var bfSus:Float = 0;
var dadLast:Float = -1;
var bfLast:Float = -1;

var glows:Array<Dynamic> = [];
var smoke:Array<Dynamic> = [];
var lines:Array<Dynamic> = [];
var lineNext:Int = 0;
var lineTimer:Float = 0;
var lineFlip:Bool = false;
var zoom:Float = 1;

function onCreatePost()
{
	useShader = ClientPrefs.data.shaders;
	flashing = ClientPrefs.data.flashing;
	var low = ClientPrefs.data.lowQuality;
	var add = LuaUtils.blendModeFromString('add');

	if (useShader)
	{
		dadShader = makeChar(blue, 2.1);
		bfShader = makeChar(red, 1.05);
		noteP = makeNote(red, false);
		noteO = makeNote(blue, false);
		holdP = makeNote(red, true);
		holdO = makeNote(blue, true);
		screenShader = makeShader(2);
		hudShader = makeShader(3);
		hudShader.setFloat('radius', 11);
		charShaders = [dadShader, bfShader];
		noteShaders = [noteP, noteO, holdP, holdO];
	}

	var back = Std.int(Math.min(game.members.indexOf(game.gfGroup), Math.min(game.members.indexOf(game.dadGroup), game.members.indexOf(game.boyfriendGroup))));
	var bmd = radialBitmap();

	if (!low)
	{
		for (i in 0...26)
		{
			var s = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
			s.scrollFactor.set(0, 0);
			s.blend = add;
			s.visible = false;
			s.active = false;
			game.insert(back, s);
			lines.push({spr: s, speed: 0.0});
		}
		for (i in 0...5)
		{
			smoke.push({spr: makeLight(bmd, 0xFF1A5CFF, back), char: game.dad, light: dadLight, t: i / 5, speed: FlxG.random.float(0.12, 0.2), ox: FlxG.random.float(-0.6, 0.6), size: FlxG.random.float(0.9, 1.5), seed: FlxG.random.float(0, 6.28)});
			smoke.push({spr: makeLight(bmd, 0xFFFF2A1E, back), char: game.boyfriend, light: bfLight, t: i / 5, speed: FlxG.random.float(0.12, 0.2), ox: FlxG.random.float(-0.6, 0.6), size: FlxG.random.float(0.9, 1.5), seed: FlxG.random.float(0, 6.28)});
		}
	}

	glows.push({spr: makeLight(bmd, 0xFF1A5CFF, back), char: game.dad, light: dadLight, floor: false});
	glows.push({spr: makeLight(bmd, 0xFF1A5CFF, back), char: game.dad, light: dadLight, floor: true});
	glows.push({spr: makeLight(bmd, 0xFFFF2A1E, back), char: game.boyfriend, light: bfLight, floor: false});
	glows.push({spr: makeLight(bmd, 0xFFFF2A1E, back), char: game.boyfriend, light: bfLight, floor: true});

	for (i in 0...(low ? 3 : 6))
	{
		dadPool.push(makeGhost(game.dad, false, 40, 120, 255));
		bfPool.push(makeGhost(game.boyfriend, true, 255, 45, 30));
	}
}

function makeShader(mode:Int)
{
	var frag = Paths.getTextFromFile('shaders/PosterShader.frag');
	var sh = frag != null ? new ErrorHandledRuntimeShader('PosterShader', frag, null) : game.createRuntimeShader('PosterShader');
	sh.setFloat('mode', mode);
	sh.setFloat('amount', 0);
	sh.setFloat('pulse', 0);
	sh.setFloat('iTime', 0);
	sh.setFloat('split', 0);
	sh.setFloat('glitch', 0);
	sh.setFloat('vignette', 0);
	sh.setFloat('strength', 0);
	sh.setFloatArray('uFrameBounds', [0, 0, 1, 1]);
	sh.setFloat('angOffset', 0);
	return sh;
}

function makeChar(col:Array<Float>, ang:Float)
{
	var sh = makeShader(0);
	sh.setFloatArray('rimColor', col);
	sh.setFloat('rimWidth', 11);
	sh.setFloat('rimStrength', 1.15);
	sh.setFloat('glowWidth', 20);
	sh.setFloat('lightAng', ang);
	sh.setFloat('bodyLight', 0.07);
	return sh;
}

function makeNote(col:Array<Float>, hold:Bool)
{
	var sh = makeShader(1);
	sh.setFloatArray('rimColor', col);
	sh.setFloat('thick', 2.5);
	sh.setFloat('hold', hold ? 1 : 0);
	return sh;
}

function radialBitmap()
{
	var size = 96;
	var bmd = new BitmapData(size, size, true, 0);
	for (yy in 0...size)
	{
		for (xx in 0...size)
		{
			var dx = (xx + 0.5) / size * 2 - 1;
			var dy = (yy + 0.5) / size * 2 - 1;
			var t = 1 - Math.sqrt(dx * dx + dy * dy);
			if (t <= 0) continue;
			t = t * t * (3 - 2 * t);
			bmd.setPixel32(xx, yy, (Std.int(t * 255) << 24) | 0xFFFFFF);
		}
	}
	return bmd;
}

function makeLight(bmd, col:Int, at:Int)
{
	var s = new FlxSprite().loadGraphic(bmd);
	s.color = col;
	s.blend = LuaUtils.blendModeFromString('add');
	s.antialiasing = true;
	s.alpha = 0;
	s.visible = false;
	s.active = false;
	game.insert(at, s);
	return s;
}

function makeGhost(char, player:Bool, r:Int, g:Int, b:Int)
{
	var ghost = new Character(char.x, char.y, char.curCharacter, player);
	ghost.useRenderTexture = true;
	ghost.blend = LuaUtils.blendModeFromString('add');
	ghost.setColorTransform(0, 0, 0, 1, r, g, b, 0);
	ghost.visible = false;
	ghost.active = false;
	game.insert(game.members.indexOf(player ? game.boyfriendGroup : game.dadGroup), ghost);
	return ghost;
}

function addFilter(cam, sh)
{
	var filters = cam.filters != null ? cam.filters.copy() : [];
	filters.push(new ShaderFilter(sh));
	cam.filters = filters;
}

function neonNotes(on:Bool)
{
	var strums = game.strumLineNotes.members;
	if (on) strumOld = [];
	for (i in 0...strums.length)
	{
		var s = strums[i];
		if (on) strumOld.push(s != null ? s.shader : null);
		if (s == null) continue;
		if (on) s.shader = game.playerStrums.members.contains(s) ? noteP : noteO;
		else s.shader = i < strumOld.length ? strumOld[i] : null;
	}
	for (n in game.unspawnNotes) neonNote(n, on);
	for (n in game.notes.members) neonNote(n, on);
}

function neonNote(n, on:Bool)
{
	if (n == null) return;
	if (on) n.shader = n.isSustainNote ? (n.mustPress ? holdP : holdO) : (n.mustPress ? noteP : noteO);
	else if (noteShaders.contains(n.shader)) n.shader = n.adjustColor;
}

function enter()
{
	active = true;
	target = 1;
	glitch = flashing ? 1 : 0;
	if (flashing) game.camOther.flash(0xAAFFFFFF, 0.45, null, true);

	if (useShader)
	{
		if (restored)
		{
			dadOld = game.dad.shader;
			bfOld = game.boyfriend.shader;
			oldFilters = game.camGame.filters;
			oldHudFilters = game.camHUD.filters;
			addFilter(game.camGame, screenShader);
			addFilter(game.camHUD, hudShader);
		}
		game.dad.shader = dadShader;
		game.boyfriend.shader = bfShader;
		neonNotes(true);
		restored = false;
	}
	else
	{
		game.dad.color = 0xFF06070B;
		game.boyfriend.color = 0xFF0B0606;
	}

	bgAlpha = [];
	for (tag in ['bg1', 'bg2', 'bg3'])
	{
		var bg = game.getLuaObject(tag);
		bgAlpha.push(bg != null ? bg.alpha : 1);
		if (bg == null) continue;
		FlxTween.cancelTweensOf(bg);
		bg.alpha = 0;
	}
	if (game.gf != null)
	{
		FlxTween.cancelTweensOf(game.gf);
		gfAlpha = game.gf.alpha;
		game.gf.alpha = 0;
	}

	hudAlpha = [];
	for (name in hudNames)
	{
		var obj = LuaUtils.getObjectDirectly(name);
		hudAlpha.push(obj != null ? obj.alpha : 1);
		if (obj == null) continue;
		FlxTween.cancelTweensOf(obj);
		FlxTween.tween(obj, {alpha: 0}, 0.3);
	}
}

function leave()
{
	active = false;
	target = 0;
	glitch = flashing ? 1 : 0;
	if (flashing) game.camOther.flash(0x88FFFFFF, 0.6, null, true);

	if (!useShader)
	{
		game.dad.color = 0xFFFFFFFF;
		game.boyfriend.color = 0xFFFFFFFF;
	}

	var tags = ['bg1', 'bg2', 'bg3'];
	for (i in 0...tags.length)
	{
		var bg = game.getLuaObject(tags[i]);
		if (bg != null) FlxTween.tween(bg, {alpha: i < bgAlpha.length ? bgAlpha[i] : 1}, 0.6);
	}
	if (game.gf != null) FlxTween.tween(game.gf, {alpha: gfAlpha}, 0.6);

	for (i in 0...hudNames.length)
	{
		var obj = LuaUtils.getObjectDirectly(hudNames[i]);
		if (obj == null) continue;
		FlxTween.cancelTweensOf(obj);
		FlxTween.tween(obj, {alpha: i < hudAlpha.length ? hudAlpha[i] : 1}, 0.6);
	}
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
	if (name != 'Poster Mode') return;
	var v = StringTools.trim(value1).toLowerCase();
	var on = v != 'off' && v != '0' && v != 'false';
	if (on && !active) enter();
	else if (!on && active) leave();
}

function onBeatHit()
{
	if (!active) return;
	var big = curBeat % 4 == 0;
	pulse = big ? 1.0 : 0.7;
	split = Math.max(split, flashing ? (big ? 9.0 : 5.0) : 2.0);
	if (game.camZooming)
	{
		game.camGame.zoom += big ? 0.03 : 0.015;
		game.camHUD.zoom += big ? 0.03 : 0.012;
	}
	if (curBeat % 2 == 0) for (i in 0...4) launchLine(true);
	if (big) game.triggerEvent('bright zoom', '0.07', '5', Conductor.songPosition);
	if (flashing && curBeat % 8 == 0) glitch = Math.max(glitch, 0.6);
}

function opponentNoteHit(note)
{
	if (!active || note.gfNote) return;
	if (note.isSustainNote)
	{
		if (dadSus > 0) return;
		dadSus = 0.09;
	}
	var chord = time - dadLast < 0.035;
	if (!note.isSustainNote) dadLast = time;
	dadNext = trail(game.dad, dadPool, dadNext, note.noteData, !note.isSustainNote, chord);
}

function goodNoteHit(note)
{
	if (!active || note.gfNote) return;
	if (note.isSustainNote)
	{
		if (bfSus > 0) return;
		bfSus = 0.09;
	}
	var chord = time - bfLast < 0.035;
	if (!note.isSustainNote) bfLast = time;
	bfNext = trail(game.boyfriend, bfPool, bfNext, note.noteData, !note.isSustainNote, chord);
}

function trail(char, pool:Array<Dynamic>, next:Int, dir:Int, strong:Bool, chord:Bool):Int
{
	if (pool.length == 0) return next;
	var dx = dir == 0 ? 1.0 : (dir == 3 ? -1.0 : 0.0);
	var dy = dir == 1 ? -1.0 : (dir == 2 ? 1.0 : 0.0);
	var name = char.getAnimationName();
	var frame = char.animation.curAnim != null ? char.animation.curAnim.curFrame : 0;
	var count = strong && !chord ? 3 : 1;
	for (i in 0...count)
	{
		var g = pool[next % pool.length];
		next++;
		FlxTween.cancelTweensOf(g);
		if (g.curCharacter != char.curCharacter) g.changeCharacter(char.curCharacter);
		g.playAnim(name, true, false, frame);
		g.x = char.x;
		g.y = char.y;
		g.scale.set(char.scale.x, char.scale.y);
		g.flipX = char.flipX;
		g.alpha = (strong ? 0.8 : 0.45) - i * 0.22;
		g.visible = true;
		var dist = (strong ? 85.0 : 50.0) * (i + 1);
		FlxTween.tween(g, {x: char.x + dx * dist, y: char.y + dy * dist * 0.7, alpha: 0}, 0.3 + i * 0.06, {ease: FlxEase.expoOut, onComplete: function(_) g.visible = false});
	}
	return next;
}

function launchLine(heavy:Bool)
{
	var count = lines.length;
	for (k in 0...count)
	{
		var l = lines[(lineNext + k) % count];
		var s = l.spr;
		if (s.visible) continue;
		lineNext = (lineNext + k + 1) % count;
		var len = FlxG.random.float(heavy ? 500 : 250, heavy ? 1300 : 800);
		s.scale.set(len, FlxG.random.float(1.5, heavy ? 5 : 3.5));
		s.updateHitbox();
		s.x = FlxG.width * 0.5 + FlxG.width / zoom * 0.5 + FlxG.random.float(0, 300);
		s.y = FlxG.height * 0.5 + FlxG.random.float(-0.48, 0.48) * FlxG.height / zoom;
		lineFlip = !lineFlip;
		s.color = FlxG.random.bool(25) ? 0xFFFFFFFF : (lineFlip ? 0xFF2E6BFF : 0xFFFF3B2A);
		s.alpha = FlxG.random.float(0.12, heavy ? 0.45 : 0.28);
		l.speed = FlxG.random.float(2600, 5200) * (heavy ? 1.3 : 1.0);
		s.visible = true;
		return;
	}
}

function onUpdatePost(elapsed:Float)
{
	time += elapsed;
	if (amount <= 0 && target <= 0) return;

	zoom = Math.max(0.3, game.camGame.zoom);
	pulse = Math.max(0, pulse - elapsed * 3.2);
	split = Math.max(0, split - elapsed * 30);
	glitch = Math.max(0, glitch - elapsed * 4);
	if (dadSus > 0) dadSus -= elapsed;
	if (bfSus > 0) bfSus -= elapsed;

	if (amount != target)
	{
		amount += (target - amount) * Math.min(1, elapsed * (target > amount ? 14 : 5));
		if (Math.abs(target - amount) < 0.01) amount = target;
	}
	var show = amount > 0;

	if (useShader && !restored)
	{
		for (sh in charShaders)
		{
			sh.setFloat('amount', amount);
			sh.setFloat('pulse', pulse);
			sh.setFloat('iTime', time);
		}
		for (sh in noteShaders)
		{
			sh.setFloat('amount', amount);
			sh.setFloat('pulse', pulse);
		}
		screenShader.setFloat('split', split * amount);
		screenShader.setFloat('glitch', glitch);
		screenShader.setFloat('iTime', time);
		screenShader.setFloat('vignette', amount * 0.75);
		hudShader.setFloat('strength', amount * 0.7 * (1 + pulse * 0.25));

		if (!show)
		{
			game.dad.shader = dadOld;
			game.boyfriend.shader = bfOld;
			game.camGame.filters = oldFilters;
			game.camHUD.filters = oldHudFilters;
			neonNotes(false);
			restored = true;
		}
	}

	for (gl in glows)
	{
		var s = gl.spr;
		s.visible = show;
		if (!show) continue;
		var c = gl.char;
		var L = gl.light;
		var cx = c.x + c.width * 0.5 + L.x - 48;
		if (gl.floor)
		{
			s.scale.set(c.width * 1.7 * L.floorSize * (1 + pulse * 0.12) / 96, c.height * 0.2 * L.floorSize / 96);
			s.x = cx + L.floorX;
			s.y = c.y + c.height * 0.91 + L.floorY - 48;
			s.alpha = amount * (0.5 + pulse * 0.35);
		}
		else
		{
			var size = c.height * 1.75 * L.size * (1 + 0.04 * Math.sin(time * 1.7) + pulse * 0.1) / 96;
			s.scale.set(size, size * 0.92);
			s.x = cx;
			s.y = c.y + c.height * 0.5 + L.y - 48;
			s.alpha = amount * (0.38 + pulse * 0.3);
		}
	}

	for (p in smoke)
	{
		var s = p.spr;
		s.visible = show;
		if (!show) continue;
		var c = p.char;
		p.t += elapsed * p.speed;
		if (p.t >= 1)
		{
			p.t -= 1;
			p.ox = FlxG.random.float(-0.6, 0.6);
			p.size = FlxG.random.float(0.9, 1.5);
		}
		var size = c.height * p.size * (0.6 + p.t * 0.8) / 96;
		s.scale.set(size, size * 0.8);
		s.x = c.x + c.width * (0.5 + p.ox * 0.6) + Math.sin(time * 0.7 + p.seed) * 25 + p.light.x - 48;
		s.y = c.y + c.height * (0.95 - p.t * 0.9) + p.light.y - 48;
		s.alpha = amount * 0.16 * Math.sin(p.t * 3.14159) * (1 + pulse * 0.6);
	}

	if (lines.length > 0)
	{
		if (active)
		{
			lineTimer -= elapsed;
			while (lineTimer <= 0)
			{
				lineTimer += 0.05;
				launchLine(false);
			}
		}
		var left = FlxG.width * 0.5 - FlxG.width / zoom * 0.5;
		for (l in lines)
		{
			var s = l.spr;
			if (!s.visible) continue;
			if (!show)
			{
				s.visible = false;
				continue;
			}
			s.x -= l.speed * elapsed;
			if (s.x + s.width < left) s.visible = false;
		}
	}
}
