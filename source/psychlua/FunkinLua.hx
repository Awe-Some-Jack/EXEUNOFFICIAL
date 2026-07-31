#if LUA_ALLOWED
package psychlua;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import openfl.Lib;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxState;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

import objects.StrumNote;
import objects.Note;
import objects.Character;

import states.EXEMenu;
import states.StoryModeState;
import states.EXEFreeplay;

import states.substates.PauseSubState;
import states.substates.GameOverSubstate;

import psychlua.LuaUtils;
import psychlua.LuaUtils.LuaTweenOptions;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end
import psychlua.DebugLuaText;
import psychlua.ModchartSprite;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import haxe.Json;

class FunkinLua
{
	public var lua:Null<RawPointer<Lua_State>> = null;
	public var camTarget:FlxCamera;
	public var scriptName:String = '';
	public var modFolder:String = null;
	public var closed:Bool = false;

	#if HSCRIPT_ALLOWED
	public var hscript:HScript = null;
	#end

	public var callbacks:Map<String, Dynamic> = new Map();
	public static var customFunctions:Map<String, Dynamic> = new Map();

	var missingFunctions:Map<String, Bool> = new Map();

	public function new(scriptName:String)
	{
		lua = LuaL.newstate();
		LuaL.openlibs(lua);

		scriptName = scriptName.trim();
    	this.scriptName = scriptName;
		var game:PlayState = PlayState.instance;
		if (game != null) game.luaArray.push(this);

		#if MODS_ALLOWED
		var myFolder = this.scriptName.split('/');
		if (myFolder[0] + '/' == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1])))
			modFolder = myFolder[1];
		#end

		set('Function_StopLua',     LuaUtils.Function_StopLua);
		set('Function_StopHScript', LuaUtils.Function_StopHScript);
		set('Function_StopAll',     LuaUtils.Function_StopAll);
		set('Function_Stop',        LuaUtils.Function_Stop);
		set('Function_Continue',    LuaUtils.Function_Continue);
		set('luaDebugMode',         false);
		set('luaDeprecatedWarnings', true);
		set('version',              '1.0.4');
		set('modFolder',            modFolder);

		set('curBpm',      Conductor.bpm);
		set('bpm',         PlayState.SONG.bpm);
		set('scrollSpeed', PlayState.SONG.speed);
		set('crochet',     Conductor.crochet);
		set('stepCrochet', Conductor.stepCrochet);
		set('songLength',  FlxG.sound.music == null ? 0 : FlxG.sound.music.length); 
		set('songName',    PlayState.SONG.song);
		set('songPath',    Paths.formatToSongPath(PlayState.SONG.song));
		set('loadedSongName', Song.loadedSongName);
		set('loadedSongPath', Paths.formatToSongPath(Song.loadedSongName));
		set('chartPath',   Song.chartPath);
		set('startedCountdown', false);
		set('curStage',    PlayState.SONG.stage);

		set('isStoryMode',  PlayState.isStoryMode);
		set('difficulty',   PlayState.storyDifficulty);
		set('difficultyName',            Difficulty.getString(false));
		set('difficultyPath',            Difficulty.getFilePath());
		set('difficultyNameTranslation', Difficulty.getString(true));
		set('weekRaw', PlayState.storyWeek);
		set('week',    WeekData.weeksList[PlayState.storyWeek]);
		set('seenCutscene', PlayState.seenCutscene);
		set('hasVocals',    PlayState.SONG.needsVoices);

		set('screenWidth',  FlxG.width);
		set('screenHeight', FlxG.height);

		if (game != null) @:privateAccess
		{
			var curSection:SwagSection = PlayState.SONG.notes[game.curSection];
			set('curSection',  game.curSection);
			set('curBeat',     game.curBeat);
			set('curStep',     game.curStep);
			set('curDecBeat',  game.curDecBeat);
			set('curDecStep',  game.curDecStep);

			set('score',  game.songScore);
			set('misses', game.songMisses);
			set('hits',   game.songHits);
			set('combo',  game.combo);
			set('deaths', PlayState.deathCounter);

			set('rating',         game.ratingPercent);
			set('totalPlayed',    game.totalPlayed);
			set('totalNotesHit',  game.totalNotesHit);

			set('inGameOver',     GameOverSubstate.instance != null);
			set('mustHitSection', curSection != null ? curSection.mustHitSection == true : false);
			set('altAnim',        curSection != null ? curSection.altAnim == true : false);
			set('gfSection',      curSection != null ? curSection.gfSection == true : false);

			set('healthGainMult', game.healthGain);
			set('healthLossMult', game.healthLoss);

			#if FLX_PITCH
			set('playbackRate', game.playbackRate);
			#else
			set('playbackRate', 1);
			#end

			set('guitarHeroSustains', game.guitarHeroSustains);
			set('instakillOnMiss',    game.instakillOnMiss);
			set('botPlay',            game.cpuControlled);
			set('practice',           game.practiceMode);

			for (i in 0...4)
			{
				set('defaultPlayerStrumX$i',   0);
				set('defaultPlayerStrumY$i',   0);
				set('defaultOpponentStrumX$i', 0);
				set('defaultOpponentStrumY$i', 0);
			}

			set('defaultBoyfriendX',  game.BF_X);
			set('defaultBoyfriendY',  game.BF_Y);
			set('defaultOpponentX',   game.DAD_X);
			set('defaultOpponentY',   game.DAD_Y);
			set('defaultGirlfriendX', game.GF_X);
			set('defaultGirlfriendY', game.GF_Y);

			set('boyfriendName', game.boyfriend != null ? game.boyfriend.curCharacter : PlayState.SONG.player1);
			set('dadName',       game.dad       != null ? game.dad.curCharacter       : PlayState.SONG.player2);
			set('gfName',        game.gf        != null ? game.gf.curCharacter        : PlayState.SONG.gfVersion);
		}

		set('downscroll',       ClientPrefs.data.downScroll);
		set('middlescroll',     ClientPrefs.data.middleScroll);
		set('framerate',        ClientPrefs.data.framerate);
		set('ghostTapping',     ClientPrefs.data.ghostTapping);
		set('hideHud',          ClientPrefs.data.hideHud);
		set('scoreZoom',        ClientPrefs.data.scoreZoom);
		set('cameraZoomOnBeat', ClientPrefs.data.camZooms);
		set('flashingLights',   ClientPrefs.data.flashing);
		set('noteOffset',       ClientPrefs.data.noteOffset);
		set('healthBarAlpha',   ClientPrefs.data.healthBarAlpha);
		set('noResetButton',    ClientPrefs.data.noReset);
		set('lowQuality',       ClientPrefs.data.lowQuality);
		set('shadersEnabled',   ClientPrefs.data.shaders);
		set('scriptName',       scriptName);
		set('currentModDirectory', Mods.currentModDirectory);

		set('noteSkin',          ClientPrefs.data.noteSkin);
		set('noteSkinPostfix',   Note.getNoteSkinPostfix());

		set('buildTarget', LuaUtils.getBuildTarget());

		LuaUtilsHx.addFunction(lua, 'getRunningScripts', function() {
			return [for (s in game.luaArray) s.scriptName];
		});

		addLocalCallback('setOnScripts', function(varName:String, arg:Dynamic, ignoreSelf:Bool = false, exclusions:Array<String> = null) {
			if (exclusions == null) exclusions = [];
			if (ignoreSelf && !exclusions.contains(lastCalledScript.scriptName)) exclusions.push(lastCalledScript.scriptName);
			game.setOnScripts(varName, arg, exclusions);
		});
		addLocalCallback('setOnHScript', function(varName:String, arg:Dynamic, ignoreSelf:Bool = false, exclusions:Array<String> = null) {
			if (exclusions == null) exclusions = [];
			if (ignoreSelf && !exclusions.contains(lastCalledScript.scriptName)) exclusions.push(lastCalledScript.scriptName);
			game.setOnHScript(varName, arg, exclusions);
		});
		addLocalCallback('setOnLuas', function(varName:String, arg:Dynamic, ignoreSelf:Bool = false, exclusions:Array<String> = null) {
			if (exclusions == null) exclusions = [];
			if (ignoreSelf && !exclusions.contains(lastCalledScript.scriptName)) exclusions.push(lastCalledScript.scriptName);
			game.setOnLuas(varName, arg, exclusions);
		});
		addLocalCallback('callOnScripts', function(funcName:String, args:Array<Dynamic> = null, ignoreStops:Bool = false, ignoreSelf:Null<Bool> = null, excludeScripts:Array<String> = null, excludeValues:Array<Dynamic> = null) {
			if (ignoreSelf == null) ignoreSelf = true;
			if (excludeScripts == null) excludeScripts = [];
			if (ignoreSelf && !excludeScripts.contains(lastCalledScript.scriptName)) excludeScripts.push(lastCalledScript.scriptName);
			return game.callOnScripts(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});
		addLocalCallback('callOnLuas', function(funcName:String, args:Array<Dynamic> = null, ignoreStops:Bool = false, ignoreSelf:Null<Bool> = null, excludeScripts:Array<String> = null, excludeValues:Array<Dynamic> = null) {
			if (ignoreSelf == null) ignoreSelf = true;
			if (excludeScripts == null) excludeScripts = [];
			if (ignoreSelf && !excludeScripts.contains(lastCalledScript.scriptName)) excludeScripts.push(lastCalledScript.scriptName);
			return game.callOnLuas(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});
		addLocalCallback('callOnHScript', function(funcName:String, args:Array<Dynamic> = null, ignoreStops:Bool = false, ignoreSelf:Null<Bool> = null, excludeScripts:Array<String> = null, excludeValues:Array<Dynamic> = null) {
			if (ignoreSelf == null) ignoreSelf = true;
			if (excludeScripts == null) excludeScripts = [];
			if (ignoreSelf && !excludeScripts.contains(lastCalledScript.scriptName)) excludeScripts.push(lastCalledScript.scriptName);
			return game.callOnHScript(funcName, args, ignoreStops, excludeScripts, excludeValues);
		});

		LuaUtilsHx.addFunction(lua, 'callScript', function(luaFile:String, funcName:String, args:Array<Dynamic> = null) {
			if (args == null) args = [];
			var luaPath = findScript(luaFile);
			if (luaPath != null)
				for (inst in game.luaArray)
					if (inst.scriptName == luaPath) return inst.call(funcName, args);
			return null;
		});

		LuaUtilsHx.addFunction(lua, 'isRunning', function(scriptFile:String) {
			var luaPath = findScript(scriptFile);
			if (luaPath != null)
				for (inst in game.luaArray)
					if (inst.scriptName == luaPath) return true;
			#if HSCRIPT_ALLOWED
			var hxPath = findScript(scriptFile, '.hx');
			if (hxPath != null)
				for (inst in game.hscriptArray)
					if (inst.origin == hxPath) return true;
			#end
			return false;
		});

		LuaUtilsHx.addFunction(lua, 'setVar', function(varName:String, value:Dynamic) {
			MusicBeatState.getVariables().set(varName, ReflectionFunctions.parseSingleInstance(value));
			return value;
		});
		LuaUtilsHx.addFunction(lua, 'getVar', (varName:String) -> MusicBeatState.getVariables().get(varName));

		LuaUtilsHx.addFunction(lua, 'addLuaScript', function(luaFile:String, ignoreAlreadyRunning:Bool = false) {
			var luaPath = findScript(luaFile);
			if (luaPath != null)
			{
				if (!ignoreAlreadyRunning)
					for (inst in game.luaArray)
						if (inst.scriptName == luaPath) { luaTrace('addLuaScript: The script "$luaPath" is already running!'); return; }
				new FunkinLua(luaPath);
				return;
			}
			luaTrace("addLuaScript: Script doesn't exist!", false, false, FlxColor.RED);
		});

		LuaUtilsHx.addFunction(lua, 'addHScript', function(scriptFile:String, ignoreAlreadyRunning:Bool = false) {
			#if HSCRIPT_ALLOWED
			var scriptPath = findScript(scriptFile, '.hx');
			if (scriptPath != null)
			{
				if (!ignoreAlreadyRunning)
					for (inst in game.hscriptArray)
						if (inst.origin == scriptPath) { luaTrace('addHScript: The script "$scriptPath" is already running!'); return; }
				PlayState.instance.initHScript(scriptPath);
				return;
			}
			luaTrace("addHScript: Script doesn't exist!", false, false, FlxColor.RED);
			#else
			luaTrace("addHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		LuaUtilsHx.addFunction(lua, 'removeLuaScript', function(luaFile:String) {
			var luaPath = findScript(luaFile);
			if (luaPath != null)
			{
				var found = false;
				for (inst in game.luaArray)
					if (inst.scriptName == luaPath) { trace('[LUA] closed: [${haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(luaPath))}]'); inst.stop(); found = true; }
				if (found) return true;
			}
			luaTrace('removeLuaScript: Script $luaFile isn\'t running!', false, false, FlxColor.RED);
			return false;
		});

		LuaUtilsHx.addFunction(lua, 'removeHScript', function(scriptFile:String) {
			#if HSCRIPT_ALLOWED
			var scriptPath = findScript(scriptFile, '.hx');
			if (scriptPath != null)
			{
				var found = false;
				for (inst in game.hscriptArray)
					if (inst.origin == scriptPath) { trace('[HSCRIPT] closed: [${haxe.io.Path.withoutExtension(haxe.io.Path.withoutDirectory(scriptPath))}]'); inst.destroy(); found = true; }
				if (found) return true;
			}
			luaTrace('removeHScript: Script $scriptFile isn\'t running!', false, false, FlxColor.RED);
			return false;
			#else
			luaTrace("removeHScript: HScript is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		LuaUtilsHx.addFunction(lua, 'loadSong', function(name:String = null, difficultyNum:Int = -1) {
			if (name == null || name.length < 1) name = Song.loadedSongName;
			if (difficultyNum == -1) difficultyNum = PlayState.storyDifficulty;
			Song.loadFromJson(Highscore.formatSong(name, difficultyNum), name);
			PlayState.storyDifficulty = difficultyNum;
			FlxG.state.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
			if (game != null && game.vocals != null) { game.vocals.pause(); game.vocals.volume = 0; }
			FlxG.camera.followLerp = 0;
		});

		LuaUtilsHx.addFunction(lua, 'loadGraphic', function(variable:String, image:String, gridX:Int = 0, gridY:Int = 0) {
			var spr = _resolveSprite(variable);
			if (spr != null && image != null && image.length > 0)
			{
				final animated:Bool = gridX != 0 || gridY != 0;
				spr.loadGraphic(Paths.image(image, null, !animated), animated, gridX, gridY);
			}
		});
		LuaUtilsHx.addFunction(lua, 'loadFrames', function(variable:String, image:String, spriteType:String = 'auto') {
			var spr = _resolveSprite(variable);
			if (spr != null && image != null && image.length > 0) LuaUtils.loadFrames(spr, image, spriteType);
		});
		LuaUtilsHx.addFunction(lua, 'loadMultipleFrames', function(variable:String, images:Array<String>) {
			var spr = _resolveSprite(variable);
			if (spr != null && images != null && images.length > 0) spr.frames = Paths.getMultiAtlas(images);
		});

		LuaUtilsHx.addFunction(lua, 'getObjectOrder', function(obj:String, group:String = null) {
			var leObj:FlxBasic = LuaUtils.getObjectDirectly(obj);
			if (leObj != null)
			{
				if (group != null)
				{
					var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
					if (groupOrArray != null)
					{
						return switch (Type.typeof(groupOrArray))
						{
							case TClass(Array): groupOrArray.indexOf(leObj);
							default:            Reflect.getProperty(groupOrArray, 'members').indexOf(leObj);
						};
					}
					luaTrace('getObjectOrder: Group $group doesn\'t exist!', false, false, FlxColor.RED);
					return -1;
				}
				var g:Dynamic = CustomSubstate.instance != null ? CustomSubstate.instance : LuaUtils.getTargetInstance();
				return g.members.indexOf(leObj);
			}
			luaTrace('getObjectOrder: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
			return -1;
		});

		LuaUtilsHx.addFunction(lua, 'setObjectOrder', function(obj:String, position:Int, group:String = null) {
			var leObj:FlxBasic = LuaUtils.getObjectDirectly(obj);
			if (leObj != null)
			{
				if (group != null)
				{
					var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
					if (groupOrArray != null)
					{
						switch (Type.typeof(groupOrArray))
						{
							case TClass(Array): groupOrArray.remove(leObj); groupOrArray.insert(position, leObj);
							default:            groupOrArray.remove(leObj, true); groupOrArray.insert(position, leObj);
						}
					}
					else luaTrace('setObjectOrder: Group $group doesn\'t exist!', false, false, FlxColor.RED);
				}
				else
				{
					var g:Dynamic = CustomSubstate.instance != null ? CustomSubstate.instance : LuaUtils.getTargetInstance();
					g.remove(leObj, true);
					g.insert(position, leObj);
				}
				return;
			}
			luaTrace('setObjectOrder: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
		});

		LuaUtilsHx.addFunction(lua, 'startTween', function(tag:String, vars:String, values:Any = null, duration:Float, options:Any = null) {
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null) { luaTrace('startTween: Couldnt find object: $vars', false, false, FlxColor.RED); return null; }
			if (values == null) { luaTrace('startTween: No values on 2nd argument!', false, false, FlxColor.RED); return null; }

			var myOptions:LuaTweenOptions = LuaUtils.getLuaTween(options);
			var variables = MusicBeatState.getVariables();

			if (tag != null)
			{
				var originalTag = tag;
				tag = 'tween_' + LuaUtils.formatVariable(tag);
				variables.set(tag, FlxTween.tween(target, values, duration, myOptions != null ? {
					type: myOptions.type, ease: myOptions.ease,
					startDelay: myOptions.startDelay, loopDelay: myOptions.loopDelay,
					onUpdate:   function(t) { if (myOptions.onUpdate   != null) game.callOnLuas(myOptions.onUpdate,   [originalTag, vars]); },
					onStart:    function(t) { if (myOptions.onStart    != null) game.callOnLuas(myOptions.onStart,    [originalTag, vars]); },
					onComplete: function(t) {
						if (t.type == FlxTweenType.ONESHOT || t.type == FlxTweenType.BACKWARD) variables.remove(tag);
						if (myOptions.onComplete != null) game.callOnLuas(myOptions.onComplete, [originalTag, vars]);
					}
				} : null));
				return tag;
			}
			FlxTween.tween(target, values, duration, myOptions != null ? {
				type: myOptions.type, ease: myOptions.ease,
				startDelay: myOptions.startDelay, loopDelay: myOptions.loopDelay,
				onUpdate:   function(t) { if (myOptions.onUpdate   != null) game.callOnLuas(myOptions.onUpdate,   [null, vars]); },
				onStart:    function(t) { if (myOptions.onStart    != null) game.callOnLuas(myOptions.onStart,    [null, vars]); },
				onComplete: function(t) { if (myOptions.onComplete != null) game.callOnLuas(myOptions.onComplete, [null, vars]); }
			} : null);
			return null;
		});

		LuaUtilsHx.addFunction(lua, 'doTweenX',     (tag:String, vars:String, value:Dynamic, duration:Float, ease:String = 'linear') -> oldTweenFunction(tag, vars, {x: value},     duration, ease, 'doTweenX'));
		LuaUtilsHx.addFunction(lua, 'doTweenY',     (tag:String, vars:String, value:Dynamic, duration:Float, ease:String = 'linear') -> oldTweenFunction(tag, vars, {y: value},     duration, ease, 'doTweenY'));
		LuaUtilsHx.addFunction(lua, 'doTweenAngle', (tag:String, vars:String, value:Dynamic, duration:Float, ease:String = 'linear') -> oldTweenFunction(tag, vars, {angle: value}, duration, ease, 'doTweenAngle'));
		LuaUtilsHx.addFunction(lua, 'doTweenAlpha', (tag:String, vars:String, value:Dynamic, duration:Float, ease:String = 'linear') -> oldTweenFunction(tag, vars, {alpha: value}, duration, ease, 'doTweenAlpha'));

		LuaUtilsHx.addFunction(lua, 'doTweenZoom', function(tag:String, camera:String, value:Dynamic, duration:Float, ease:String = 'linear') {
			switch (camera.toLowerCase()) {
				case 'camgame' | 'game':   camera = 'camGame';
				case 'camback' | 'back':   camera = 'camBack';
				case 'camhud'  | 'hud':    camera = 'camHUD';
				case 'camvideo'  | 'video':    camera = 'camVideo';
				case 'camother' | 'other': camera = 'camOther';
				default:
					var cam:FlxCamera = MusicBeatState.getVariables().get(camera);
					if (cam == null || !Std.isOfType(cam, FlxCamera)) camera = 'camGame';
			}
			return oldTweenFunction(tag, camera, {zoom: value}, duration, ease, 'doTweenZoom');
		});

		LuaUtilsHx.addFunction(lua, 'doTweenColor', function(tag:String, vars:String, targetColor:String, duration:Float, ease:String = 'linear') {
			var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
			if (target == null) { luaTrace('doTweenColor: Couldnt find object: $vars', false, false, FlxColor.RED); return null; }
			var curColor:FlxColor = target.color;
			curColor.alphaFloat = target.alpha;
			if (tag != null)
			{
				var originalTag = tag;
				tag = LuaUtils.formatVariable('tween_$tag');
				var variables = MusicBeatState.getVariables();
				variables.set(tag, FlxTween.color(target, duration, curColor, CoolUtil.colorFromString(targetColor), {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: function(t) { variables.remove(tag); if (game != null) game.callOnLuas('onTweenCompleted', [originalTag, vars]); }
				}));
				return tag;
			}
			FlxTween.color(target, duration, curColor, CoolUtil.colorFromString(targetColor), {ease: LuaUtils.getTweenEaseByString(ease)});
			return null;
		});

		LuaUtilsHx.addFunction(lua, 'noteTweenX',         (tag:String, note:Int, value:Dynamic, duration:Float, ease:String = 'linear') -> noteTweenFunction(tag, note, {x: value},         duration, ease));
		LuaUtilsHx.addFunction(lua, 'noteTweenY',         (tag:String, note:Int, value:Dynamic, duration:Float, ease:String = 'linear') -> noteTweenFunction(tag, note, {y: value},         duration, ease));
		LuaUtilsHx.addFunction(lua, 'noteTweenAngle',     (tag:String, note:Int, value:Dynamic, duration:Float, ease:String = 'linear') -> noteTweenFunction(tag, note, {angle: value},     duration, ease));
		LuaUtilsHx.addFunction(lua, 'noteTweenAlpha',     (tag:String, note:Int, value:Dynamic, duration:Float, ease:String = 'linear') -> noteTweenFunction(tag, note, {alpha: value},     duration, ease));
		LuaUtilsHx.addFunction(lua, 'noteTweenDirection', (tag:String, note:Int, value:Dynamic, duration:Float, ease:String = 'linear') -> noteTweenFunction(tag, note, {direction: value}, duration, ease));

		LuaUtilsHx.addFunction(lua, 'mouseClicked', function(button:String = 'left') {
			return switch (button.trim().toLowerCase()) { case 'middle': FlxG.mouse.justPressedMiddle; case 'right': FlxG.mouse.justPressedRight; default: FlxG.mouse.justPressed; };
		});
		LuaUtilsHx.addFunction(lua, 'mousePressed', function(button:String = 'left') {
			return switch (button.trim().toLowerCase()) { case 'middle': FlxG.mouse.pressedMiddle; case 'right': FlxG.mouse.pressedRight; default: FlxG.mouse.pressed; };
		});
		LuaUtilsHx.addFunction(lua, 'mouseReleased', function(button:String = 'left') {
			return switch (button.trim().toLowerCase()) { case 'middle': FlxG.mouse.justReleasedMiddle; case 'right': FlxG.mouse.justReleasedRight; default: FlxG.mouse.justReleased; };
		});

		LuaUtilsHx.addFunction(lua, 'cancelTween', (tag:String) -> LuaUtils.cancelTween(tag));

		LuaUtilsHx.addFunction(lua, 'runTimer', function(tag:String, time:Float = 1, loops:Int = 1) {
			LuaUtils.cancelTimer(tag);
			var variables = MusicBeatState.getVariables();
			var originalTag = tag;
			tag = LuaUtils.formatVariable('timer_$tag');
			variables.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if (tmr.finished) variables.remove(tag);
				game.callOnLuas('onTimerCompleted', [originalTag, tmr.loops, tmr.loopsLeft]);
			}, loops));
			return tag;
		});
		LuaUtilsHx.addFunction(lua, 'cancelTimer', (tag:String) -> LuaUtils.cancelTimer(tag));

		LuaUtilsHx.addFunction(lua, 'addScore',  function(value:Int = 0) { game.songScore  += value; game.RecalculateRating(); });
		LuaUtilsHx.addFunction(lua, 'addMisses', function(value:Int = 0) { game.songMisses += value; game.RecalculateRating(); });
		LuaUtilsHx.addFunction(lua, 'addHits',   function(value:Int = 0) { game.songHits   += value; game.RecalculateRating(); });
		LuaUtilsHx.addFunction(lua, 'setScore',  function(value:Int = 0) { game.songScore   = value; game.RecalculateRating(); });
		LuaUtilsHx.addFunction(lua, 'setMisses', function(value:Int = 0) { game.songMisses  = value; game.RecalculateRating(); });
		LuaUtilsHx.addFunction(lua, 'setHits',   function(value:Int = 0) { game.songHits    = value; game.RecalculateRating(); });
		LuaUtilsHx.addFunction(lua, 'setHealth', (value:Float = 1)  -> game.health = value);
		LuaUtilsHx.addFunction(lua, 'addHealth', (value:Float = 0)  -> game.health += value);
		LuaUtilsHx.addFunction(lua, 'getHealth', ()                 -> game.health);

		LuaUtilsHx.addFunction(lua, 'FlxColor',           (color:String) -> FlxColor.fromString(color));
		LuaUtilsHx.addFunction(lua, 'getColorFromName',   (color:String) -> FlxColor.fromString(color));
		LuaUtilsHx.addFunction(lua, 'getColorFromString', (color:String) -> FlxColor.fromString(color));
		LuaUtilsHx.addFunction(lua, 'getColorFromHex',    (color:String) -> FlxColor.fromString('#$color'));

		LuaUtilsHx.addFunction(lua, 'addCharacterToList', function(name:String, type:String) {
			var charType = switch (type.toLowerCase()) { case 'dad': 1; case 'gf' | 'girlfriend': 2; default: 0; };
			game.addCharacterToList(name, charType);
		});
		LuaUtilsHx.addFunction(lua, 'precacheImage', (name:String, parentFolder:String = null, allowGPU:Bool = true) -> Paths.image(name, parentFolder, allowGPU));
		LuaUtilsHx.addFunction(lua, 'precacheSound', (name:String) -> Paths.sound(name));
		LuaUtilsHx.addFunction(lua, 'precacheMusic', (name:String) -> Paths.music(name));

		LuaUtilsHx.addFunction(lua, 'triggerEvent', function(name:String, value1:String = '', value2:String = '') {
			game.triggerEvent(name, value1, value2, Conductor.songPosition);
			return true;
		});

		LuaUtilsHx.addFunction(lua, 'startCountdown', function() { game.startCountdown(); return true; });
		LuaUtilsHx.addFunction(lua, 'endSong',        function() { game.KillNotes(); game.endSong(); return true; });
		LuaUtilsHx.addFunction(lua, 'restartSong',    function(skipTransition:Bool = false) {
			game.persistentUpdate = false;
			FlxG.camera.followLerp = 0;
			PauseSubState.restartSong(skipTransition);
			return true;
		});
		LuaUtilsHx.addFunction(lua, 'exitSong', function(skipTransition:Bool = false) {
			if (skipTransition) { FlxTransitionableState.skipNextTransIn = true; FlxTransitionableState.skipNextTransOut = true; }
			if (states.StoryModeState.fromStoryMode) { states.StoryModeState.fromStoryMode = false; FlxG.switchState(() -> new states.StoryModeState()); }
			else if (states.SoundTest.fromSoundTest) { states.SoundTest.fromSoundTest = false; FlxG.switchState(() -> new states.SoundTest()); }
			else if (states.parallax.StoryParallaxState.fromParallax) { states.parallax.StoryParallaxState.fromParallax = false; FlxG.switchState(() -> new states.parallax.StoryParallaxState()); }
			else if (states.access.FridgeAccess.fromFridge) { states.access.FridgeAccess.fromFridge = false; FlxG.switchState(() -> new states.access.FridgeAccess()); }
			else if (states.access.MajinAccess.fromMajin) { states.access.MajinAccess.fromMajin = false; FlxG.switchState(() -> new states.access.MajinAccess()); }
			else FlxG.switchState(() -> new EXEFreeplay());
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
			FlxG.sound.playMusic(Assets.getSound('assets/exe/music/menu.ogg'));
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			game.transitioning = true;
			FlxG.camera.followLerp = 0;
			Mods.loadTopMod();
			return true;
		});
		LuaUtilsHx.addFunction(lua, 'getSongPosition', () -> Conductor.songPosition);

		LuaUtilsHx.addFunction(lua, 'getCharacterX', function(type:String) {
			return switch (type.toLowerCase()) { case 'dad' | 'opponent': game.dadGroup.x; case 'gf' | 'girlfriend': game.gfGroup.x; default: game.boyfriendGroup.x; };
		});
		LuaUtilsHx.addFunction(lua, 'setCharacterX', function(type:String, value:Float) {
			switch (type.toLowerCase()) { case 'dad' | 'opponent': game.dadGroup.x = value; case 'gf' | 'girlfriend': game.gfGroup.x = value; default: game.boyfriendGroup.x = value; }
		});
		LuaUtilsHx.addFunction(lua, 'getCharacterY', function(type:String) {
			return switch (type.toLowerCase()) { case 'dad' | 'opponent': game.dadGroup.y; case 'gf' | 'girlfriend': game.gfGroup.y; default: game.boyfriendGroup.y; };
		});
		LuaUtilsHx.addFunction(lua, 'setCharacterY', function(type:String, value:Float) {
			switch (type.toLowerCase()) { case 'dad' | 'opponent': game.dadGroup.y = value; case 'gf' | 'girlfriend': game.gfGroup.y = value; default: game.boyfriendGroup.y = value; }
		});

		LuaUtilsHx.addFunction(lua, 'cameraSetTarget', function(target:String) {
			switch (target.trim().toLowerCase()) {
				case 'gf' | 'girlfriend': game.moveCameraToGirlfriend();
				case 'dad' | 'opponent':  game.moveCamera(true);
				default:                  game.moveCamera(false);
			}
		});

		LuaUtilsHx.addFunction(lua, 'setCameraScroll',       (x:Float, y:Float) -> FlxG.camera.scroll.set(x - FlxG.width / 2, y - FlxG.height / 2));
		LuaUtilsHx.addFunction(lua, 'setCameraFollowPoint',  (x:Float, y:Float) -> game.camFollow.setPosition(x, y));
		LuaUtilsHx.addFunction(lua, 'addCameraScroll',       (x:Float = 0, y:Float = 0) -> FlxG.camera.scroll.add(x, y));
		LuaUtilsHx.addFunction(lua, 'addCameraFollowPoint',  function(x:Float = 0, y:Float = 0) { game.camFollow.x += x; game.camFollow.y += y; });
		LuaUtilsHx.addFunction(lua, 'getCameraScrollX',      ()  -> FlxG.camera.scroll.x + FlxG.width  / 2);
		LuaUtilsHx.addFunction(lua, 'getCameraScrollY',      ()  -> FlxG.camera.scroll.y + FlxG.height / 2);
		LuaUtilsHx.addFunction(lua, 'getCameraFollowX',      ()  -> game.camFollow.x);
		LuaUtilsHx.addFunction(lua, 'getCameraFollowY',      ()  -> game.camFollow.y);

		LuaUtilsHx.addFunction(lua, 'cameraShake', (camera:String, intensity:Float, duration:Float) -> LuaUtils.cameraFromString(camera).shake(intensity, duration));
		LuaUtilsHx.addFunction(lua, 'cameraFlash', (camera:String, color:String, duration:Float, forced:Bool) -> LuaUtils.cameraFromString(camera).flash(CoolUtil.colorFromString(color), duration, null, forced));
		LuaUtilsHx.addFunction(lua, 'cameraFade',  (camera:String, color:String, duration:Float, forced:Bool, fadeOut:Bool = false) -> LuaUtils.cameraFromString(camera).fade(CoolUtil.colorFromString(color), duration, fadeOut, null, forced));

		LuaUtilsHx.addFunction(lua, 'setRatingPercent', function(value:Float) { game.ratingPercent = value; game.setOnScripts('rating', value); });

		LuaUtilsHx.addFunction(lua, 'getMouseX', function(camera:String = 'game') { return FlxG.mouse.getViewPosition(LuaUtils.cameraFromString(camera)).x; });
		LuaUtilsHx.addFunction(lua, 'getMouseY', function(camera:String = 'game') { return FlxG.mouse.getViewPosition(LuaUtils.cameraFromString(camera)).y; });

		LuaUtilsHx.addFunction(lua, 'getMidpointX',        function(variable:String) { var o = _resolveObject(variable); return o != null ? o.getMidpoint().x : 0; });
		LuaUtilsHx.addFunction(lua, 'getMidpointY',        function(variable:String) { var o = _resolveObject(variable); return o != null ? o.getMidpoint().y : 0; });
		LuaUtilsHx.addFunction(lua, 'getGraphicMidpointX', function(variable:String) { var o:FlxSprite = _resolveSprite(variable); return o != null ? o.getGraphicMidpoint().x : 0; });
		LuaUtilsHx.addFunction(lua, 'getGraphicMidpointY', function(variable:String) { var o:FlxSprite = _resolveSprite(variable); return o != null ? o.getGraphicMidpoint().y : 0; });
		LuaUtilsHx.addFunction(lua, 'getScreenPositionX',  function(variable:String, camera:String = 'game') { var o = _resolveObject(variable); return o != null ? o.getScreenPosition(LuaUtils.cameraFromString(camera)).x : 0; });
		LuaUtilsHx.addFunction(lua, 'getScreenPositionY',  function(variable:String, camera:String = 'game') { var o = _resolveObject(variable); return o != null ? o.getScreenPosition(LuaUtils.cameraFromString(camera)).y : 0; });

		LuaUtilsHx.addFunction(lua, 'characterDance', function(character:String) {
			switch (character.toLowerCase()) {
				case 'dad': game.dad.dance();
				case 'gf' | 'girlfriend': if (game.gf != null) game.gf.dance();
				default: game.boyfriend.dance();
			}
		});

		LuaUtilsHx.addFunction(lua, 'makeLuaSprite', function(tag:String, image:String = null, x:Float = 0, y:Float = 0) {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite = new ModchartSprite(x, y);
			if (image != null && image.length > 0) leSprite.loadGraphic(Paths.image(image));
			MusicBeatState.getVariables().set(tag, leSprite);
			leSprite.active = true;
		});
		LuaUtilsHx.addFunction(lua, 'makeAnimatedLuaSprite', function(tag:String, image:String = null, x:Float = 0, y:Float = 0, spriteType:String = 'auto') {
			tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite = new ModchartSprite(x, y);
			if (image != null && image.length > 0) LuaUtils.loadFrames(leSprite, image, spriteType);
			MusicBeatState.getVariables().set(tag, leSprite);
		});

		LuaUtilsHx.addFunction(lua, 'makeGraphic', function(obj:String, width:Int = 256, height:Int = 256, color:String = 'FFFFFF') {
			var spr:FlxSprite = LuaUtils.getObjectDirectly(obj);
			if (spr != null) spr.makeGraphic(width, height, CoolUtil.colorFromString(color));
		});

		LuaUtilsHx.addFunction(lua, 'addAnimationByPrefix', function(obj:String, name:String, prefix:String, framerate:Float = 24, loop:Bool = true) {
			var spr:FlxSprite = cast LuaUtils.getObjectDirectly(obj);
			if (spr != null && spr.animation != null)
			{
				spr.animation.addByPrefix(name, prefix, framerate, loop);
				if (spr.animation.curAnim == null) { var d:Dynamic = cast spr; if (d.playAnim != null) d.playAnim(name, true); else d.animation.play(name, true); }
				return true;
			}
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'addAnimation',         (obj:String, name:String, frames:Any,  framerate:Float = 24, loop:Bool = true)  -> LuaUtils.addAnimByIndices(obj, name, null,   frames,   framerate, loop));
		LuaUtilsHx.addFunction(lua, 'addAnimationByIndices', (obj:String, name:String, prefix:String, indices:Any, framerate:Float = 24, loop:Bool = false) -> LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, loop));

		LuaUtilsHx.addFunction(lua, 'playAnim', function(obj:String, name:String, forced:Bool = false, reverse:Bool = false, startFrame:Int = 0) {
			var o:Dynamic = LuaUtils.getObjectDirectly(obj);
			if (o.playAnim != null)  o.playAnim(name, forced, reverse, startFrame);
			else if (o.anim != null) o.anim.play(name, forced, reverse, startFrame);
			else                     o.animation.play(name, forced, reverse, startFrame);
			return true;
		});
		LuaUtilsHx.addFunction(lua, 'addOffset', function(obj:String, anim:String, x:Float, y:Float) {
			var o:Dynamic = LuaUtils.getObjectDirectly(obj);
			if (o != null && o.addOffset != null) { o.addOffset(anim, x, y); return true; }
			return false;
		});

		LuaUtilsHx.addFunction(lua, 'setScrollFactor', function(obj:String, scrollX:Float, scrollY:Float) {
			var luaObj = game.getLuaObject(obj);
			if (luaObj != null) { luaObj.scrollFactor.set(scrollX, scrollY); return; }
			var object:FlxObject = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
			if (object != null) object.scrollFactor.set(scrollX, scrollY);
		});

		LuaUtilsHx.addFunction(lua, 'addLuaSprite', function(tag:String, inFront:Bool = false) {
			var mySprite:FlxSprite = MusicBeatState.getVariables().get(tag);
			if (mySprite == null) return;
			var instance = LuaUtils.getTargetInstance();
			if (inFront) instance.add(mySprite);
			else
			{
				if (PlayState.instance == null || !PlayState.instance.isDead)
					instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), mySprite);
				else
					GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
			}
		});

		LuaUtilsHx.addFunction(lua, 'setGraphicSize', function(obj:String, x:Float, y:Float = 0, updateHitbox:Bool = true) {
			var spr = _resolveOrLuaSprite(obj);
			if (spr != null) { spr.setGraphicSize(x, y); if (updateHitbox) spr.updateHitbox(); return; }
			luaTrace('setGraphicSize: Couldnt find object: $obj', false, false, FlxColor.RED);
		});
		LuaUtilsHx.addFunction(lua, 'scaleObject', function(obj:String, x:Float, y:Float, updateHitbox:Bool = true) {
			var spr = _resolveOrLuaSprite(obj);
			if (spr != null) { spr.scale.set(x, y); if (updateHitbox) spr.updateHitbox(); return; }
			luaTrace('scaleObject: Couldnt find object: $obj', false, false, FlxColor.RED);
		});
		LuaUtilsHx.addFunction(lua, 'updateHitbox', function(obj:String) {
			var spr = _resolveOrLuaSprite(obj);
			if (spr != null) { spr.updateHitbox(); return; }
			luaTrace('updateHitbox: Couldnt find object: $obj', false, false, FlxColor.RED);
		});

		LuaUtilsHx.addFunction(lua, 'removeLuaSprite', function(tag:String, destroy:Bool = true, group:String = null) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
			if (obj == null || obj.destroy == null) return;
			var groupObj:Dynamic = group == null ? LuaUtils.getTargetInstance() : LuaUtils.getObjectDirectly(group);
			groupObj.remove(obj, true);
			if (destroy) { MusicBeatState.getVariables().remove(tag); obj.destroy(); }
		});

		LuaUtilsHx.addFunction(lua, 'luaSpriteExists', function(tag:String) {
			var obj = MusicBeatState.getVariables().get(tag);
			return obj != null && (Std.isOfType(obj, ModchartSprite) || Std.isOfType(obj, ModchartAnimateSprite));
		});
		LuaUtilsHx.addFunction(lua, 'luaTextExists',  function(tag:String) { var o = MusicBeatState.getVariables().get(tag); return o != null && Std.isOfType(o, FlxText); });
		LuaUtilsHx.addFunction(lua, 'luaSoundExists', function(tag:String) { var o = MusicBeatState.getVariables().get('sound_$tag'); return o != null && Std.isOfType(o, FlxSound); });

		LuaUtilsHx.addFunction(lua, 'setHealthBarColors', function(left:String, right:String) {
			game.healthBar.setColors(left  != null && left  != '' ? CoolUtil.colorFromString(left)  : null,
			                         right != null && right != '' ? CoolUtil.colorFromString(right) : null);
		});

		LuaUtilsHx.addFunction(lua, 'setObjectCamera', function(obj:String, camera:String = 'game') {
			var real:FlxBasic = game.getLuaObject(obj);
			if (real != null) { real.cameras = [LuaUtils.cameraFromString(camera)]; return true; }
			var object = _resolveBasic(obj);
			if (object != null) { object.cameras = [LuaUtils.cameraFromString(camera)]; return true; }
			luaTrace('setObjectCamera: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'setBlendMode', function(obj:String, blend:String = '') {
			var real:FlxSprite = game.getLuaObject(obj);
			if (real != null) { real.blend = LuaUtils.blendModeFromString(blend); return true; }
			var spr = _resolveSprite(obj);
			if (spr != null) { spr.blend = LuaUtils.blendModeFromString(blend); return true; }
			luaTrace('setBlendMode: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
			return false;
		});
		LuaUtilsHx.addFunction(lua, 'screenCenter', function(obj:String, pos:String = 'xy') {
			var spr:FlxObject = game.getLuaObject(obj) ?? _resolveObject(obj);
			if (spr != null)
			{
				switch (pos.trim().toLowerCase()) {
					case 'x': spr.screenCenter(X);
					case 'y': spr.screenCenter(Y);
					default:  spr.screenCenter(XY);
				}
				return;
			}
			luaTrace('screenCenter: Object $obj doesn\'t exist!', false, false, FlxColor.RED);
		});
		LuaUtilsHx.addFunction(lua, 'objectsOverlap', function(obj1:String, obj2:String) {
			var a:FlxBasic = game.getLuaObject(obj1) ?? Reflect.getProperty(LuaUtils.getTargetInstance(), obj1);
			var b:FlxBasic = game.getLuaObject(obj2) ?? Reflect.getProperty(LuaUtils.getTargetInstance(), obj2);
			return a != null && b != null && FlxG.overlap(a, b);
		});
		LuaUtilsHx.addFunction(lua, 'getPixelColor', function(obj:String, x:Int, y:Int) {
			var spr = _resolveSprite(obj);
			return spr != null ? spr.pixels.getPixel32(x, y) : FlxColor.BLACK;
		});

		LuaUtilsHx.addFunction(lua, 'startVideo', function(videoFile:String, canSkip:Bool = true, forMidSong:Bool = false, shouldLoop:Bool = false, ?playOnLoad:Bool = true) {
			#if VIDEOS_ALLOWED
			if (#if !mobile FileSystem.exists(Paths.video(videoFile)) #else OpenFlAssets.exists(Paths.video(videoFile)) #end)
			{
				if (game.videoCutscene != null) { game.remove(game.videoCutscene); game.videoCutscene.destroy(); }
				game.startVideo(videoFile, canSkip, forMidSong, shouldLoop, playOnLoad);
				return true;
			}
			luaTrace('startVideo: Video file not found: $videoFile', false, false, FlxColor.RED);
			return false;
			#else
			PlayState.instance.inCutscene = true;
			new FlxTimer().start(0.1, function(_) {
				PlayState.instance.inCutscene = false;
				if (game.endingSong) game.endSong(); else game.startCountdown();
			});
			return true;
			#end
		});

		LuaUtilsHx.addFunction(lua, 'playMusic', (sound:String, volume:Float = 1, loop:Bool = false) -> FlxG.sound.playMusic(Paths.music(sound), volume, loop));
		LuaUtilsHx.addFunction(lua, 'playSound', function(sound:String, volume:Float = 1, tag:String = null, loop:Bool = false) {
			if (tag != null && tag.length > 0)
			{
				var originalTag = tag;
				tag = LuaUtils.formatVariable('sound_$tag');
				var variables = MusicBeatState.getVariables();
				var oldSnd = variables.get(tag);
				if (oldSnd != null) { oldSnd.stop(); oldSnd.destroy(); }
				variables.set(tag, FlxG.sound.play(Paths.sound(sound), volume, loop, null, true, function() {
					if (!loop) variables.remove(tag);
					if (game != null) game.callOnLuas('onSoundFinished', [originalTag]);
				}));
				return tag;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
			return null;
		});

		LuaUtilsHx.addFunction(lua, 'stopSound', function(tag:String) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.stop(); return; }
			tag = LuaUtils.formatVariable('sound_$tag');
			var variables = MusicBeatState.getVariables();
			var snd:FlxSound = variables.get(tag);
			if (snd != null) { snd.stop(); variables.remove(tag); }
		});
		LuaUtilsHx.addFunction(lua, 'pauseSound', function(tag:String) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.pause(); return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) snd.pause();
		});
		LuaUtilsHx.addFunction(lua, 'resumeSound', function(tag:String) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.play(); return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) snd.play();
		});
		LuaUtilsHx.addFunction(lua, 'soundFadeIn', function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.fadeIn(duration, fromValue, toValue); return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) snd.fadeIn(duration, fromValue, toValue);
		});
		LuaUtilsHx.addFunction(lua, 'soundFadeOut', function(tag:String, duration:Float, toValue:Float = 0) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(duration, toValue); return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) snd.fadeOut(duration, toValue);
		});
		LuaUtilsHx.addFunction(lua, 'soundFadeCancel', function(tag:String) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null && FlxG.sound.music.fadeTween != null) FlxG.sound.music.fadeTween.cancel(); return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null && snd.fadeTween != null) snd.fadeTween.cancel();
		});
		LuaUtilsHx.addFunction(lua, 'getSoundVolume', function(tag:String) {
			if (tag == null || tag.length < 1) return FlxG.sound.music != null ? FlxG.sound.music.volume : 0;
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			return snd != null ? snd.volume : 0;
		});
		LuaUtilsHx.addFunction(lua, 'setSoundVolume', function(tag:String, value:Float) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.volume = value; return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) snd.volume = value;
		});
		LuaUtilsHx.addFunction(lua, 'getSoundTime', function(tag:String) {
			if (tag == null || tag.length < 1) return FlxG.sound.music != null ? FlxG.sound.music.time : 0;
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			return snd != null ? snd.time : 0;
		});
		LuaUtilsHx.addFunction(lua, 'setSoundTime', function(tag:String, value:Float) {
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) FlxG.sound.music.time = value; return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) snd.time = value;
		});
		LuaUtilsHx.addFunction(lua, 'getSoundPitch', function(tag:String) {
			#if FLX_PITCH
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			return snd != null ? snd.pitch : 1;
			#else
			luaTrace("getSoundPitch: Sound Pitch is not supported on this platform!", false, false, FlxColor.RED);
			return 1;
			#end
		});
		LuaUtilsHx.addFunction(lua, 'setSoundPitch', function(tag:String, value:Float, doPause:Bool = false) {
			#if FLX_PITCH
			inline function applyPitch(snd:FlxSound) {
				var wasPlaying = snd.playing;
				if (doPause) snd.pause();
				snd.pitch = value;
				if (doPause && wasPlaying) snd.play();
			}
			if (tag == null || tag.length < 1) { if (FlxG.sound.music != null) applyPitch(FlxG.sound.music); return; }
			var snd:FlxSound = MusicBeatState.getVariables().get(LuaUtils.formatVariable('sound_$tag'));
			if (snd != null) applyPitch(snd);
			#else
			luaTrace("setSoundPitch: Sound Pitch is not supported on this platform!", false, false, FlxColor.RED);
			#end
		});

		addLocalCallback('getModSetting', function(saveTag:String, modName:String = null) {
			#if MODS_ALLOWED
			if (modName == null)
			{
				if (modFolder == null) { FunkinLua.luaTrace('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', false, false, FlxColor.RED); return null; }
				modName = modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
			#else
			luaTrace("getModSetting: Mods are disabled in this build!", false, false, FlxColor.RED);
			#end
		});

		LuaUtilsHx.addFunction(lua, 'debugPrint', (text:Dynamic = '', color:String = 'WHITE') -> PlayState.instance.addTextToDebug(text, CoolUtil.colorFromString(color)));

		addLocalCallback('close', function() { 
			lastCalledScript.closed = true;
			trace('Closing Script: ${lastCalledScript.scriptName}');
			return lastCalledScript.closed; 
		});

		#if DISCORD_ALLOWED    DiscordClient.addLuaCallbacks(lua); #end
		#if TRANSLATIONS_ALLOWED Language.addLuaCallbacks(lua); #end

		HScript.implement(this);
		#if flixel_animate FlxAnimateFunctions.implement(this); #end
		ReflectionFunctions.implement(this);
		TextFunctions.implement(this);
		ExtraFunctions.implement(this);
		CustomSubstate.implement(this);
		ShaderFunctions.implement(this);
		DeprecatedFunctions.implement(this);

		for (name => func in customFunctions)
			if (func != null) LuaUtilsHx.addFunction(lua, name, func);

		try
		{
			var result:Dynamic = null;
			var isString:Bool = false;

			#if sys
			if (sys.FileSystem.exists(scriptName))
				result = LuaL.dofile(lua, scriptName);
			else 
			#end
			if (OpenFlAssets.exists(scriptName))
				result = LuaL.dostring(lua, OpenFlAssets.getText(scriptName));
			else {
				result = LuaL.dostring(lua, scriptName);
				scriptName = 'unknown';
				isString = true;
			}

			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0)
			{
				trace(resultStr);
				#if windows
				lime.app.Application.current.window.alert(resultStr, 'Error on lua script!');
				#else
				luaTrace('$scriptName\n$resultStr', true, false, FlxColor.RED);
				#end
				lua = null;
				return;
			}
		}
		catch (e:Dynamic) { trace(e); return; }

		// logged externally in batches (see PlayState)
		call('onCreate', []);
	}

	public var lastCalledFunction:String = '';
	public static var lastCalledScript:FunkinLua = null;

	public function call(func:String, args:Array<Dynamic>):Dynamic
	{
		if (closed) return LuaUtils.Function_Continue;
		if (missingFunctions.exists(func)) return LuaUtils.Function_Continue;

		try
		{
			if (lua == null) return LuaUtils.Function_Continue;

			Lua.getglobal(lua, func);
			var type:Int = Lua.type(lua, -1);

			if (type != Lua.TFUNCTION)
			{
				if (type > Lua.TNIL)
					luaTrace('ERROR ($func): attempt to call a ${LuaUtils.typeToString(type)} value', false, false, FlxColor.RED);
				else
					missingFunctions.set(func, true);
				Lua.pop(lua, 1);
				return LuaUtils.Function_Continue;
			}

			lastCalledFunction = func;
			lastCalledScript = this;

			for (arg in args) LuaConverter.toLua(lua, arg);
			var status:Int = Lua.pcall(lua, args.length, 1, 0);
			if (status != Lua.OK)
			{
				luaTrace('ERROR ($func): ${getErrorMessage(status)}', false, false, FlxColor.RED);
				return LuaUtils.Function_Continue;
			}

			var result:Dynamic = cast LuaConverter.fromLua(lua, -1);
			if (result == null) result = LuaUtils.Function_Continue;
			Lua.pop(lua, 1);
			if (closed) stop();
			return result;
		}
		catch (e:Dynamic) { trace(e); }
		return LuaUtils.Function_Continue;
	}

	public function set(variable:String, data:Dynamic):Void
	{
		if (lua == null) return;
		LuaConverter.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function stop():Void
	{
		closed = true;
		if (lua == null) return;
		Lua.close(lua);
		lua = null;
		#if HSCRIPT_ALLOWED
		if (hscript != null) { hscript.destroy(); hscript = null; }
		#end
	}

	public static function oldTweenFunction(tag:String, vars:String, tweenValue:Any, duration:Float, ease:String, funcName:String):Dynamic
	{
		var target:Dynamic = LuaUtils.tweenPrepare(tag, vars);
		var variables = MusicBeatState.getVariables();
		if (target != null)
		{
			if (tag != null)
			{
				var originalTag = tag;
				tag = LuaUtils.formatVariable('tween_$tag');
				variables.set(tag, FlxTween.tween(target, tweenValue, duration, {
					ease: LuaUtils.getTweenEaseByString(ease),
					onComplete: function(t) {
						variables.remove(tag);
						if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag, vars]);
					}
				}));
			}
			else FlxTween.tween(target, tweenValue, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
			return tag;
		}
		luaTrace('$funcName: Couldnt find object: $vars', false, false, FlxColor.RED);
		return null;
	}

	function noteTweenFunction(tag:String, note:Int, data:Dynamic, duration:Float, ease:String):Dynamic
	{
		if (PlayState.instance == null) return null;
		var strumNote:StrumNote = PlayState.instance.strumLineNotes.members[note % PlayState.instance.strumLineNotes.length];
		if (strumNote == null) return null;

		if (tag != null)
		{
			var originalTag = tag;
			tag = LuaUtils.formatVariable('tween_$tag');
			LuaUtils.cancelTween(tag);
			var variables = MusicBeatState.getVariables();
			variables.set(tag, FlxTween.tween(strumNote, data, duration, {
				ease: LuaUtils.getTweenEaseByString(ease),
				onComplete: function(t) {
					variables.remove(tag);
					if (PlayState.instance != null) PlayState.instance.callOnLuas('onTweenCompleted', [originalTag]);
				}
			}));
			return tag;
		}
		FlxTween.tween(strumNote, data, duration, {ease: LuaUtils.getTweenEaseByString(ease)});
		return null;
	}

	public static function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false, color:FlxColor = FlxColor.WHITE):Void
	{
		if (ignoreCheck || getBool('luaDebugMode'))
		{
			if (deprecated && !getBool('luaDeprecatedWarnings')) return;
			PlayState.instance.addTextToDebug(text, color);
		}
	}

	public static function getBool(variable:String):Bool
	{
		if (lastCalledScript == null) return false;
		var lua:Null<RawPointer<Lua_State>> = lastCalledScript.lua;
		if (lua == null) return false;
		Lua.getglobal(lua, variable);
		var result:String = LuaConverter.fromLua(lua, -1);
		Lua.pop(lua, 1);
		return result == 'true';
	}

	function findScript(scriptFile:String, ext:String = '.lua'):Null<String>
	{
		if (!scriptFile.endsWith(ext)) scriptFile += ext;
		var path = Paths.getPath(scriptFile, TEXT);
		#if (!mobile && MODS_ALLOWED)
		if (FileSystem.exists(path))  return path;
		if (FileSystem.exists(scriptFile)) return scriptFile;
		#else
		if (OpenFlAssets.exists(path, TEXT))       return path;
		if (OpenFlAssets.exists(scriptFile, TEXT)) return scriptFile;
		#end
		return null;
	}

	public function getErrorMessage(status:Int):String
    {
        var v:String = Lua.tostring(lua, -1);
        Lua.pop(lua, 1);
        if (v != null) v = v.trim();
        if (v == null || v == '')
        {
            if (status == Lua.ERRRUN) return 'Runtime Error';
            if (status == Lua.ERRMEM) return 'Memory Allocation Error';
            if (status == Lua.ERRERR) return 'Critical Error';
            return 'Unknown Error';
        }
        return v;
    }

	public function addLocalCallback(name:String, yourStupidFunction:Dynamic):Void
	{
		callbacks.set(name, yourStupidFunction);
		LuaUtilsHx.addFunction(lua, name, yourStupidFunction);
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map();
	#end

	public function initLuaShader(name:String):Bool
	{
		if (!ClientPrefs.data.shaders) return false;

		#if (!flash && sys)
		if (runtimeShaders.exists(name))
		{
			var data = runtimeShaders.get(name);
			if (data != null && (data[0] != null || data[1] != null)) { luaTrace('Shader $name was already initialized!'); return true; }
		}

		var foldersToCheck:Array<String> = [Paths.getSharedPath('shaders/')];
		#if MODS_ALLOWED
		foldersToCheck.push(Paths.mods('shaders/'));
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Mods.currentModDirectory + '/shaders/'));
		for (mod in Mods.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));
		#end

		for (folder in foldersToCheck)
		{
			var fragPath = folder + name + '.frag';
			var vertPath = folder + name + '.vert';
			
			var frag:String = null;
			var vert:String = null;

			#if sys
			if (sys.FileSystem.exists(fragPath)) frag = sys.io.File.getContent(fragPath);
			if (sys.FileSystem.exists(vertPath)) vert = sys.io.File.getContent(vertPath);
			#end

			if (frag == null && openfl.utils.Assets.exists(fragPath)) frag = openfl.utils.Assets.getText(fragPath);
			if (vert == null && openfl.utils.Assets.exists(vertPath)) vert = openfl.utils.Assets.getText(vertPath);

			if (frag != null || vert != null) { 
				runtimeShaders.set(name, [frag, vert]); 
				return true; 
			}
		}
		
		luaTrace('Missing shader $name .frag AND .vert files!', false, false, FlxColor.RED);
		#else
		luaTrace("This platform doesn't support Runtime Shaders!", false, false, FlxColor.RED);
		#end
		return false;
	}

	inline function _resolveSprite(variable:String):FlxSprite
	{
		var split = variable.split('.');
		if (split.length > 1) return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
		return LuaUtils.getObjectDirectly(split[0]);
	}

	inline function _resolveObject(variable:String):FlxObject
	{
		var split = variable.split('.');
		if (split.length > 1) return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
		return LuaUtils.getObjectDirectly(split[0]);
	}

	inline function _resolveBasic(variable:String):FlxBasic
	{
		var split = variable.split('.');
		if (split.length > 1) return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length - 1]);
		return LuaUtils.getObjectDirectly(split[0]);
	}

	inline function _resolveOrLuaSprite(obj:String):FlxSprite
	{
		var luaObj = PlayState.instance.getLuaObject(obj);
		if (luaObj != null) return luaObj;
		return _resolveSprite(obj);
	}
}
#end
