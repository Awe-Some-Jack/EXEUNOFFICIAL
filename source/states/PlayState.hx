package states;

import camera.GameplayCamera;
import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Rating;
import backend.EXEAchievements;
import backend.SunkyBOT;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import states.StoryModeState;
import states.EXEFreeplay;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import states.substates.PauseSubState;
import states.substates.GameOverSubstate;

import lime.app.Application as Application;

#if !flash
import openfl.filters.ShaderFilter;
#end

import shaders.ErrorHandledShader;
import shaders.ColorSwap;

import objects.Note.EventNote;
import objects.*;
import states.stages.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import psychlua.HScript.HScriptInfos;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end

#if target.threaded
import sys.thread.Thread;
#end

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
@:access(openfl.display.BitmapData)
class PlayState extends MusicBeatState
{
	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	public var noteQueues:Array<Array<Note>> = [[], [], [], []];

	private var shutdownThread:Bool = false;
	private var gameFroze:Bool = false;
	private var requiresSyncing:Bool = false;
	private var lastCorrectSongPos:Float = -1.0;
	public var enableFreezeSync:Bool = ClientPrefs.data.freezeSyncDelay;
	var _xdd:FlxEmitter;

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI(default, set):String = "normal";
	public static var uiPrefix:String = "";
	public static var uiPostfix:String = "";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function set_stageUI(value:String):String
	{
		uiPrefix = uiPostfix = "";
		if (value != "normal")
		{
			uiPrefix = value.split("-pixel")[0].trim();
			if (value == "pixel" || value.endsWith("-pixel")) uiPostfix = "-pixel";
		}
		return stageUI = value;
	}

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public static var hasRestarted:Bool = false;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];
	public var opponentStrumsFlipSide:Bool = false;

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var opponentStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var playerStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";
	var _phase:Int = 0;

	public var gfSpeed:Int = 1;

	private var _health:SecureFloat = 1;
	public var health(get, set):Float;
	inline function get_health():Float return _health.toFloat();

	public var displayHealth:Float = 1;

	private var _combo:SecureInt = 0;

	public var combo(get, set):Int;
	inline function get_combo():Int return _combo.toInt();
	inline function set_combo(val:Int):Int { _combo = val; return val; }

	public var healthBar:Bar;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var guitarHeroSustains:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var cpuAssist:Bool = false;

	public var practiceMode:Bool = false;
	public var pressMissDamage:Float = 0.05;

	public var sunkyBot:SunkyBOT;
	public var botplayTxt(get, never):FlxText;
	public var botplaySine(get, set):Float;
	public var sunkyBotSprite(get, never):FlxSprite;

	function get_botplayTxt():FlxText
		return sunkyBot?.text;

	function get_botplaySine():Float
		return sunkyBot != null ? sunkyBot.sine : 0;

	function set_botplaySine(value:Float):Float
	{
		if (sunkyBot != null) sunkyBot.sine = value;
		return value;
	}

	function get_sunkyBotSprite():FlxSprite
		return sunkyBot?.sprite;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camVideo:FlxCamera;
	public var camGame:FlxCamera;
	public var camBack:FlxCamera;
	public var gameplayCam:GameplayCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	private var _songScore:SecureInt = 0;
	private var _songHits:SecureInt = 0;
	private var _songMisses:SecureInt = 0;

	public var songScore(get, set):Int;
	inline function get_songScore():Int return _songScore.toInt();
	inline function set_songScore(val:Int):Int { _songScore = val; return val; }

	public var songHits(get, set):Int;
	inline function get_songHits():Int return _songHits.toInt();
	inline function set_songHits(val:Int):Int { _songHits = val; return val; }

	public var songMisses(get, set):Int;
	inline function get_songMisses():Int return _songMisses.toInt();
	inline function set_songMisses(val:Int):Int { _songMisses = val; return val; }

	public static var campaignScore:SecureInt = 0;
	public static var campaignMisses:SecureInt = 0;
	public static var seenCutscene:Bool = false;
	public static var firstPlay:Bool = false;
	public static var deathCounter:SecureInt = 0;

	public var defaultCamZoom:Float = 1.05;
	public var defaultCamHUD:Float = 1; //For substantial tehehe...
	public var tweenCamZoom:Bool = false;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var missNotePlaying:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public var appName:String = "Friday Night Funkin': Vs Sonic.EXE";
	#if DISCORD_ALLOWED
	// Discord RPC variables
	var detailsText:String = "";
	#end

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;
	private var _osHeldKeys:Map<flixel.input.keyboard.FlxKey, Bool> = new Map();
	public var canPress:Bool = true;

	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	public static var isFixedAspectRatio(default, set):Bool = false;

	#if mobile
	public static var hitboxesGroup:Array<FlxSprite> = [];
	public static var hitboxesHeld:Array<Bool> = [false, false, false, false];
	public static var noteSlide:Array<Bool> = [false, false, false, false];
	public static var hitboxOwner:Array<Int> = [-1, -1, -1, -1];
	// tracks, per active pointer (touch id, or -2 for mouse), whether it was overlapping each hitbox last frame
	public static var hitboxPointerOver:Map<Int, Array<Bool>> = new Map();
	static final SPACE_HITBOX_SONGS:Array<String> = [
		'chaos', 'b4cksl4sh', 'manual-blast', 'hedge', 'fate', 'deception', 'prey', 'universal-collapse', 'triple-trouble'
	];
	static final OPPONENT_FLIP_SIDE_SONGS:Array<String> = ['pre-design'];
	public static var pauseButton:FlxSprite;

	var spaceHitbox:FlxSprite = null;
	var spaceHeld:Bool = false;
	var spaceJustPressed:Bool = false;
	var spaceJustReleased:Bool = false;
	#end

	public static function mobileKeyPressed(name:String):Bool
	{
		#if mobile
		return instance != null && instance.spaceHitbox != null && name.toUpperCase() == 'SPACE' && instance.spaceHeld;
		#else
		return false;
		#end
	}

	public static function mobileKeyJustPressed(name:String):Bool
	{
		#if mobile
		return instance != null && instance.spaceHitbox != null && name.toUpperCase() == 'SPACE' && instance.spaceJustPressed;
		#else
		return false;
		#end
	}

	public static function mobileKeyJustReleased(name:String):Bool
	{
		#if mobile
		return instance != null && instance.spaceHitbox != null && name.toUpperCase() == 'SPACE' && instance.spaceJustReleased;
		#else
		return false;
		#end
	}

	static var _originalWidth:Int = FlxG.width;
	static var _originalHeight:Int = FlxG.height;
	static var _wasFullscreen:Bool = false;

	static var prevWindowTitle = null;

	#if mobile
	static function applyFixedScale(enabled:Bool):Void
	{
		for (cam in FlxG.cameras.list)
			enabled ? cam.setSize(960, 720) : cam.setSize(FlxG.initialWidth, FlxG.initialHeight);

		FlxG.scaleMode = enabled
			? new flixel.system.scaleModes.FixedRatioScaleMode(960, 720)
			: new flixel.system.scaleModes.RatioScaleMode();
	}
	#end

	static function set_isFixedAspectRatio(value:Bool):Bool
	{
		if (isFixedAspectRatio == value) return value;
		
		isFixedAspectRatio = value;
		
		#if mobile
		applyFixedScale(value);
		#else
		if (value) {
			_originalWidth = FlxG.width;
			_originalHeight = FlxG.height;
			_wasFullscreen = FlxG.fullscreen;
			
			final screen = FlxG.stage.window.display;
			final screenWidth = screen.bounds.width;
			final screenHeight = screen.bounds.height;
			
			FlxG.fullscreen = false;
			FlxG.stage.window.resizable = false;
			
			FlxG.scaleMode = new flixel.system.scaleModes.FixedRatioScaleMode(960, 720);

			for (cam in FlxG.cameras.list)
				cam.setSize(960, 720);
			FlxG.resizeGame(960, 720);
			FlxG.resizeWindow(960, 720);
			
			final winX = Std.int(screen.bounds.x + (screenWidth - 960) / 2);
			final winY = Std.int(screen.bounds.y + (screenHeight - 720) / 2);
			FlxG.stage.window.move(winX, winY);
		} else {
			FlxG.stage.window.resizable = true;

			final screen = FlxG.stage.window.display;
			final screenWidth = screen.bounds.width;
			final screenHeight = screen.bounds.height;
			
			FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();

			for (cam in FlxG.cameras.list)
				cam.setSize(_originalWidth, _originalHeight);
			FlxG.resizeGame(_originalWidth, _originalHeight);
			FlxG.resizeWindow(_originalWidth, _originalHeight);
			
			final winX = Std.int(screen.bounds.x + (screenWidth - _originalWidth) / 2);
			final winY = Std.int(screen.bounds.y + (screenHeight - _originalHeight) / 2);
			FlxG.stage.window.move(winX, winY);

			FlxG.fullscreen = _wasFullscreen;
		}
		#end

		return value;
	}

	public static var isLetterboxedAspectRatio(default, set):Bool = false;

	static var _letterboxWasFullscreen:Bool = false;
	static var _letterboxWasMaximized:Bool = false;
	static var _letterboxOrigWinWidth:Int = 0;
	static var _letterboxOrigWinHeight:Int = 0;
	static var _letterboxOrigWinX:Int = 0;
	static var _letterboxOrigWinY:Int = 0;
	static var _letterboxForcedFullscreen:Bool = false;
	#if mac
	static var _letterboxRestoreFullscreen:Bool = false;
	#end

	static function set_isLetterboxedAspectRatio(value:Bool):Bool
	{
		if (isLetterboxedAspectRatio == value) return value;

		isLetterboxedAspectRatio = value;

		#if mobile
		applyFixedScale(value);
		#else
		if (value) {
			for (cam in FlxG.cameras.list)
				cam.setSize(960, 720);

			FlxG.scaleMode = new flixel.system.scaleModes.FixedRatioScaleMode(960, 720);
			FlxG.stage.window.resizable = false;

			_letterboxWasFullscreen = FlxG.fullscreen;
			_letterboxWasMaximized  = FlxG.stage.window.maximized;
			#if mac
			_letterboxRestoreFullscreen = _letterboxWasFullscreen;
			if (_letterboxWasFullscreen) {
				_letterboxWasMaximized = false;
				_letterboxOrigWinWidth = 0;
				_letterboxOrigWinHeight = 0;
				FlxG.fullscreen = false;
				_letterboxWasFullscreen = false;
			}
			#end
			if (!FlxG.fullscreen) {
				if (_letterboxWasMaximized) {
					FlxG.stage.window.maximized = false;
				} else {
					_letterboxOrigWinWidth  = FlxG.stage.window.width;
					_letterboxOrigWinHeight = FlxG.stage.window.height;
					_letterboxOrigWinX      = FlxG.stage.window.x;
					_letterboxOrigWinY      = FlxG.stage.window.y;
				}
				snapLetterboxWindow();
			}
		} else {
			for (cam in FlxG.cameras.list)
				cam.setSize(FlxG.initialWidth, FlxG.initialHeight);

			FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
			FlxG.stage.window.resizable = true;

			if (_letterboxForcedFullscreen) {
				_letterboxForcedFullscreen = false;
				FlxG.fullscreen = false;
			}

			if (!FlxG.fullscreen) {
				if (_letterboxWasMaximized) {
					FlxG.stage.window.maximized = true;
				} else if (_letterboxOrigWinWidth > 0 && _letterboxOrigWinHeight > 0) {
					FlxG.resizeGame(_letterboxOrigWinWidth, _letterboxOrigWinHeight);
					FlxG.resizeWindow(_letterboxOrigWinWidth, _letterboxOrigWinHeight);
					FlxG.stage.window.move(_letterboxOrigWinX, _letterboxOrigWinY);
				} else {
					FlxG.resizeGame(FlxG.initialWidth, FlxG.initialHeight);
					FlxG.resizeWindow(FlxG.initialWidth, FlxG.initialHeight);

					final screen = FlxG.stage.window.display;
					final winX = Std.int(screen.bounds.x + (screen.bounds.width  - FlxG.initialWidth)  / 2);
					final winY = Std.int(screen.bounds.y + (screen.bounds.height - FlxG.initialHeight) / 2);
					FlxG.stage.window.move(winX, winY);
				}
			}

			#if mac
			if (_letterboxRestoreFullscreen) {
				_letterboxRestoreFullscreen = false;
				FlxG.fullscreen = true;
			}
			#end
		}
		#end

		return value;
	}

	public static function fullscreenLetterbox():Void
	{
		#if !(mobile || mac)
		if (FlxG.fullscreen) return;
		_letterboxForcedFullscreen = true;
		FlxG.fullscreen = true;
		#end
	}

	public static function tweenWindow(width:Int, height:Int, x:Int, y:Int, duration:Float, ?ease:Float->Float, ?onComplete:Void->Void):Void
	{
		#if mobile
		if (onComplete != null) onComplete();
		#else
		final window = FlxG.stage.window;
		final fromW = window.width;
		final fromH = window.height;
		final fromX = window.x;
		final fromY = window.y;
		var lastApply:Float = 0;

		function apply(t:Float):Void
		{
			window.resize(Std.int(fromW + (width - fromW) * t), Std.int(fromH + (height - fromH) * t));
			window.move(Std.int(fromX + (x - fromX) * t), Std.int(fromY + (y - fromY) * t));
			window.onResize.dispatch(window.width, window.height);
		}

		FlxTween.num(0, 1, duration, {
			ease: ease,
			onComplete: (_) -> {
				apply(1);
				if (onComplete != null) onComplete();
			}
		}, (t:Float) -> {
			final now = haxe.Timer.stamp();
			if (now - lastApply < 1 / 24) return;
			lastApply = now;
			apply(t);
		});
		#end
	}

	static function snapLetterboxWindow():Void
	{
		FlxG.resizeWindow(960, 720);

		final screen = FlxG.stage.window.display;
		final winX = Std.int(screen.bounds.x + (screen.bounds.width - 960) / 2);
		final winY = Std.int(screen.bounds.y + (screen.bounds.height - 720) / 2);
		FlxG.stage.window.move(winX, winY);
	}

	private static var _lastLoadedModDirectory:String = '';
	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		_lastLoadedModDirectory = Mods.currentModDirectory;

		_xdd = new FlxEmitter();

		prevWindowTitle = FlxG.stage.window.title;

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		displayHealth = health;

		FlxG.sound.music?.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');
		guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;

		songName = Paths.formatToSongPath(SONG.song);

		camGame = initPsychCamera();

		if(songName == 'flash') {
			camBack = new FlxCamera();
			camBack.zoom = 1;

			gameplayCam = new GameplayCamera(this);
			camVideo = new FlxCamera();
			camHUD = new FlxCamera();
			camOther = new FlxCamera();
			camVideo.bgColor.alpha = 0;
			camHUD.bgColor.alpha = 0;
			camOther.bgColor.alpha = 0;

			FlxG.cameras.remove(camGame, false);
			FlxG.cameras.add(camBack);        
			FlxG.cameras.add(camGame);  

			camGame.bgColor = 0x00000000; 
			FlxG.cameras.add(camVideo, false);
			FlxG.cameras.add(camHUD, false);
			FlxG.cameras.add(camOther, false);
		} else {
			gameplayCam = new GameplayCamera(this);
			camVideo = new FlxCamera();
			camHUD = new FlxCamera();
			camOther = new FlxCamera();
			camVideo.bgColor.alpha = 0;
			camHUD.bgColor.alpha = 0;
			camOther.bgColor.alpha = 0;

			FlxG.cameras.add(camVideo, false);
			FlxG.cameras.add(camHUD, false);
			FlxG.cameras.add(camOther, false);
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if DISCORD_ALLOWED
		if (isStoryMode)
		{
			final curWeek = WeekData.getCurrentWeek();
			detailsText = "Story Mode: " + (curWeek?.weekName ?? SONG.song);
		}
		else
			detailsText = "Freeplay";
		#end

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'yourself':
				appName = "Friday Night Funkin': Vs Youself";
			case 'cycles', 'hellbent', 'fate', 'gotta-go':
				appName = "Friday Night Funkin': Vs Soulless PC Sonic";
			case 'sunshine':
				appName = "Sonic R";
			case 'chocolate-milk':
				appName = "Friday Night Funkin': Vs Sunky The";
			case 'vanilla-milk':
				appName = "Friday Night Funkin': Vs Sunky.MPEG";
			case 'too-fest':
				appName = "Friday Night Funkin': Vs Sanic";
			case 'expulsion':
				appName = "Sonic's Schoolhouse";
			default:
				appName = "Friday Night Funkin': Vs Sonic.EXE";
		}

		#if !mac
		if (Paths.formatToSongPath(SONG.song) != 'burning' && Paths.formatToSongPath(SONG.song) != 'final-escape') FlxG.stage.window.title = appName + " | Playing: " + SONG.song + " (Loading)";
		#end

		GameOverSubstate.resetVariables();
		if(SONG.stage == null || SONG.stage.length < 1)
			SONG.stage = StageData.vanillaSongStage(Paths.formatToSongPath(Song.loadedSongName));

		PauseSubState.miniSonicOffsets = [0, 0];
		PauseSubState.miniSonicImage = Paths.formatToSongPath(SONG.song);
		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'manual-blast': PauseSubState.miniSonicImage = 'hedge';
			case 'prey': PauseSubState.miniSonicImage = 'sonic';
			case 'fate': PauseSubState.miniSonicOffsets = [-6, 0];
			case 'hijacked-transmission': PauseSubState.miniSonicOffsets = [-12, 0];
		}

		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI?.trim().length > 0)
			stageUI = stageData.stageUI;
		else if (stageData.isPixelStage == true) //Backward compatibility
			stageUI = "pixel";

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		boyfriendCameraOffset ??= [0, 0]; //Fucks sake should have done it since the start :rolling_eyes:

		opponentCameraOffset = stageData.camera_opponent;
		opponentCameraOffset ??= [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		girlfriendCameraOffset ??= [0, 0];

		gameplayCam.applyStageData(stageData);

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		if(isPixelStage) introSoundsSuffix = '-pixel';

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gfGroup.add(gf);
		}

		var oppChar:String = SONG.player2;
		if (Paths.formatToSongPath(SONG.song) == 'soulless' && ClientPrefs.data.lowQuality) oppChar = 'p2doll-potato';
		dad = new Character(0, 0, oppChar);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		
		// HARDCODED STAGES (before characters so sprites are behind them)
		switch(curStage)
		{
			case 'fatality': new states.stages.Fatality();
			case 'ghill': new states.stages.Hijacked();
		}

		if(stageData.objects != null && stageData.objects.length > 0)
		{
			var list:Map<String, FlxSprite> = StageData.addObjectsToState(stageData.objects, !stageData.hide_girlfriend ? gfGroup : null, dadGroup, boyfriendGroup, this);
			for (key => spr in list)
				if(!StageData.reservedNames.contains(key))
					variables.set(key, spr);
		}
		else
		{
			add(gfGroup);
			add(dadGroup);
			add(boyfriendGroup);
		}
		
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// "SCRIPTS FOLDER" SCRIPTS
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
		{
			for (file in Paths.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua')) new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx')) initHScript(folder + file);
				#end
			}
		}
		#end

		#if HSCRIPT_ALLOWED
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
		{
			for (file in Paths.readDirectory(folder))
			{
				if(file.toLowerCase().endsWith('cleanresolution.hx'))
					initHScript(folder + file);
			}
		}
		#end
			
		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// STAGE SCRIPTS
		#if LUA_ALLOWED startLuasNamed('stages/' + curStage + '.lua'); #end
		#if HSCRIPT_ALLOWED startHScriptsNamed('stages/' + curStage + '.hx'); #end

		// CHARACTER SCRIPTS
		if(gf != null) startCharacterScripts(gf.curCharacter);
		startCharacterScripts(dad.curCharacter);
		startCharacterScripts(boyfriend.curCharacter);
		#end

		uiGroup = new FlxSpriteGroup();
		comboGroup = new FlxSpriteGroup();
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(comboGroup);
		add(uiGroup);
		add(noteGroup);

		Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;

		noteGroup.add(strumLineNotes);

		generateSong();

		gameplayCam.camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		gameplayCam.initFollow(0, 0, prevCamFollow);
		camFollow = gameplayCam.camFollow;
		prevCamFollow = null;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), null, function() return health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		uiGroup.add(healthBar);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);

		sunkyBot = new SunkyBOT(this);
		uiGroup.add(sunkyBot.createText(healthBar.y - 35));

		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;
		_noteTypesSet = null;
		_eventsPushedSet = null;

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
		{
			for (file in Paths.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua')) new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx') && !file.toLowerCase().endsWith('cleanresolution.hx'))
					initHScript(folder + file);
				#end
			}
		}
		#end

		if(eventNotes.length > 0)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		startCallback();
		RecalculateRating(false, false);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('noteHitPlayer');
		for (i in 1...4) Paths.sound('missnote$i');

		resetRPC();

		stagesFunc(function(stage:BaseStage) stage.createPost());
		callOnScripts('onCreatePost');

		boyfriend.useRenderTexture = dad.useRenderTexture = true;
		if(gf != null) gf.useRenderTexture = true;

		#if mobile
		updateMobileComboOffset();
		if(usesMobileStrumLayout())
		{
			for(n in notes) {
				if(n != null && !n.mustPress && !isMobileRingNote(n)) n.visible = false;
			}

			for(n in unspawnNotes) {
				if(n != null && !n.mustPress && !isMobileRingNote(n)) n.visible = false;
			}
		}

		hitboxesHeld = [false, false, false, false];
		hitboxOwner = [-1, -1, -1, -1];
		noteSlide = [false, false, false, false];
		hitboxPointerOver = new Map();

		if(ClientPrefs.data.controlsType == 'base')
		{
			for(i in 0...4) {
				var hitbox:FlxSprite = new FlxSprite(0, 0).makeGraphic(172, Std.int(FlxG.height/1.6));
				hitbox.color = 0xFFFF0000;

				switch(i) {
					case 0:
						hitbox.color = 0xFFad3a5c;
					case 1:
						hitbox.color = 0xFF00c9bb;
					case 2:
						hitbox.color = 0xFF12e303;
					case 3:
						hitbox.color = 0xFFad3933;
				}

				hitbox.alpha = ClientPrefs.data.defHitboxAlpha;
				hitbox.updateHitbox();
				hitbox.cameras = [camOther];
				hitboxesGroup.push(hitbox);

				add(hitbox);
			}

			positionBaseHitboxes();
		}
		else if(ClientPrefs.data.controlsType == 'psych')
		{
			final columns:Int = usesSpaceHitbox() ? 5 : 4;
			for(i in 0...4) {
				var hitbox:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width/columns), Std.int(FlxG.height));
				hitbox.color = 0xFFFF0000;

				switch(i) {
					case 0:
						hitbox.color = 0xFFad3a5c;
					case 1:
						hitbox.color = 0xFF00c9bb;
					case 2:
						hitbox.color = 0xFF12e303;
					case 3:
						hitbox.color = 0xFFad3933;
				}

				hitbox.alpha = ClientPrefs.data.defHitboxAlpha;
				hitbox.updateHitbox();
				hitbox.x = hitbox.width * (columns == 5 && i > 1 ? i + 1 : i);
				hitbox.cameras = [camOther];
				hitboxesGroup.push(hitbox);
				add(hitbox);
			}
		}

		if(usesSpaceHitbox())
		{
			spaceHitbox = new FlxSprite().makeGraphic(150, Std.int(FlxG.height/1.6));
			spaceHitbox.color = 0xFFFFCC00;
			spaceHitbox.alpha = ClientPrefs.data.defHitboxAlpha;
			spaceHitbox.cameras = [camOther];
			add(spaceHitbox);
			positionSpaceHitbox();
		}

		pauseButton = new FlxSprite(0, 0).loadGraphic(Paths.getBitmapData('assets/exe/pause/pauseButton.webp'));
		pauseButton.scale.set(0.35, 0.35);
		pauseButton.updateHitbox();
		pauseButton.cameras = [camOther];
		pauseButton.x = FlxG.width - pauseButton.width - 10;
		pauseButton.y = 10;
		pauseButton.alpha = 0.7;
		pauseButton.visible = ClientPrefs.data.visiblePauseButton;
		add(pauseButton);
		#end

		gameplayCam.loadSongSettings();
		gameplayCam.onCreatePost();
		FlxG.camera.snapToTarget();

		super.create();
		sunkyBot.createSprite();

		if(isFixedAspectRatio && !hasRestarted) {
			hasRestarted = true;

			var black:FlxSprite = new FlxSprite(-2000, -2000).makeGraphic(4000, 4000, 0xFF000000);
			black.cameras = [camOther];
			add(black);

			PauseSubState.restartSong();
		}

		cachePopUpScore();

		if(eventNotes.length < 1) checkEventNote();

		PauseSubState.cameraWidth = FlxG.width;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			final ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			FlxG.sound.list.forEach((sound:FlxSound) -> if (sound != null) sound.pitch = value);

			final ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.timeScale = value;
		Conductor.offset = Reflect.hasField(PlayState.SONG, 'offset') ? (PlayState.SONG.offset / value) : 0;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		#if VIDEOS_ALLOWED
		if(videoCutscene?.video?.bitmap != null) videoCutscene.video.bitmap.rate = value;
		#end
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		#if LUA_ALLOWED
		startLuasNamed('characters/$name.lua');
		#end
		#if HSCRIPT_ALLOWED
		startHScriptsNamed('characters/$name.hx');
		#end
	}

	public function getLuaObject(tag:String):Dynamic
		return variables.get(tag);

	public function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, canSkip:Bool = true, forMidSong:Bool = false, loop:Bool = false, ?playOnLoad:Bool = true)
	{
		function endVideo()
		{
			callOnScripts('onVideoCompleted', [name]);
			canPause = true;

			if(!forMidSong) startAndEnd();
		}

		#if VIDEOS_ALLOWED
		inCutscene = !forMidSong;
		canPause = forMidSong;

		var filePath = (name.startsWith("https://") ? name : Paths.video(name));
		var fileExists = #if sys FileSystem.exists(filePath) || #end OpenFlAssets.exists(filePath) || name.startsWith("https://");

		if(!fileExists) {
			trace('Couldnt find video file: $name');
			if(!forMidSong) startAndEnd();
			return;
		}

		videoCutscene = new VideoSprite(0, 0, true);
		videoCutscene.camera = camVideo;
		videoCutscene.canSkip = canSkip;
		add(videoCutscene);

		if (canSkip)
			videoCutscene.onSkip = () -> endVideo();
		videoCutscene.onEnd(() -> endVideo());

		videoCutscene.onFormat(() -> {
			#if switch
			final hasFrame = videoCutscene.video != null;
			#else
			final hasFrame = videoCutscene.video.bitmap?.bitmapData != null;
			#end
			if (hasFrame)
			{
				#if switch
				final bw:Float = videoCutscene.video.frameWidth;
				final bh:Float = videoCutscene.video.frameHeight;
				#else
				final bw:Float = videoCutscene.video.bitmap.bitmapData.width;
				final bh:Float = videoCutscene.video.bitmap.bitmapData.height;
				#end
				final scale:Float = Math.min(FlxG.width / bw, FlxG.height / bh);
				videoCutscene.video.setGraphicSize(Std.int(bw * scale), Std.int(bh * scale));
				videoCutscene.video.updateHitbox();
				videoCutscene.video.screenCenter();
				videoCutscene.setPosition(videoCutscene.video.x, videoCutscene.video.y);
				videoCutscene.video.x = 0;
				videoCutscene.video.y = 0;
			}
		});

		final loadArgs:Array<String> = loop ? [VideoSprite.ARG_LOOPING] : [];
		if (playOnLoad) 
		{
			if(videoCutscene.loadVideo(filePath, loadArgs)) {
				videoCutscene.playDelayed();
			} else {
				if(!forMidSong) startAndEnd();
			}
		} 
		else 
		{
			if (!videoCutscene.precacheVideo(filePath, loadArgs)) {
				trace('Failed to precache video: $name');
			}
		}
		#else
		FlxG.log.warn('Platform not supported!');
		if(!forMidSong) startAndEnd();
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public static var startOnTime:Float = 0;

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		#if !mac
		FlxG.stage.window.title = appName + " | Playing: " + SONG.song;
		if (Paths.formatToSongPath(SONG.song) == 'burning') FlxG.stage.window.title = SONG.song;
		if (Paths.formatToSongPath(SONG.song) == 'final-escape') FlxG.stage.window.title = prevWindowTitle + '?';
		#end

		seenCutscene = true;
		firstPlay = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			canPause = true;
			generateStaticArrows(0);
			generateStaticArrows(1);
			#if mobile
			if(usesMobileStrumLayout()) applyMobileMiddlescrollStrums();
			positionBaseHitboxes();
			#end
			for (strum in opponentStrums) strum.y += opponentStrumOffsetY * (ClientPrefs.data.downScroll ? -1 : 1);
			if (closeOpponentStrumGap && ClientPrefs.data.middleScroll
				&& !(#if mobile (ClientPrefs.data.middlescrollType == 'mobile' || ClientPrefs.data.mobileOpponentNotes) #else false #end)
				&& opponentStrums.length >= 4 && playerStrums.length >= 4)
			{
				final gapSpacing:Float = 5 + playerStrums.members[0].width;
				opponentStrums.members[1].x = playerStrums.members[0].x - gapSpacing;
				opponentStrums.members[0].x = opponentStrums.members[1].x - gapSpacing;
				opponentStrums.members[2].x = playerStrums.members[3].x + gapSpacing;
				opponentStrums.members[3].x = opponentStrums.members[2].x + gapSpacing;
			}
			updateStrumDefaults();

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted');

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						tick = THREE;
					case 1:
						tick = TWO;
					case 2:
						tick = ONE;
					case 3:
						tick = GO;
					case 4:
						tick = START;
				}

				if(!skipArrowStartTween)
				{
					notes.forEachAlive(function(note:Note) {
						if(ClientPrefs.data.opponentStrums || note.mustPress)
						{
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if(ClientPrefs.data.middleScroll && !note.mustPress)
								note.alpha *= 0.35;
						}
					});
				}

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	// fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false, scoreBop:Bool = true)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		callOnScripts('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time - Conductor.offset;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition < vocals.length)
		{
			vocals.time = time - Conductor.offset;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
			vocals.play();
		}
		else vocals.pause();

		if (Conductor.songPosition < opponentVocals.length)
		{
			opponentVocals.time = time - Conductor.offset;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
			opponentVocals.play();
		}
		else opponentVocals.pause();
		Conductor.songPosition = time;
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();
		FlxG.sound.music.volume = 1;
		vocals.volume = 1;
		opponentVocals.volume = 1;
		inst.volume = 1;
		trace('inst and vocals started playing');

		setSongTime(Math.max(0, startOnTime - 500) + Conductor.offset);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		stagesFunc(function(stage:BaseStage) stage.startSong());

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength, "icon", 0, Conductor.songPosition);
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
		gameplayCam.onSongStart();
		if (enableFreezeSync) runSongSyncThread();
	}

	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private var _noteTypesSet:Map<String, Bool> = [];
	private var _eventsPushedSet:Map<String, Bool> = [];
	private var totalColumns: Int = 4;

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
				vocals.load(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
				if(oppVocals != null && oppVocals.length > 0) opponentVocals.load(oppVocals);
			}
		}
		catch (e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		if(FlxG.sound.music != null) FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		opponentVocals.volume = 0;

		inst = new FlxSound();
		try
		{
			inst.load(Paths.inst(songData.song));
		}
		catch (e:Dynamic) {}
		FlxG.sound.list.add(inst);

		inst.volume = 0;
		trace('inst loaded and added to sound list');

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		try
		{
			var eventsChart:SwagSong = Song.getChart('events', songName);
			if(eventsChart != null)
				for (event in eventsChart.events) //Event Notes
					for (i in 0...event[1].length)
						makeEvent(event, i);
		}
		catch(e:Dynamic) {}

		var oldNote:Note = null;
		var sectionsData:Array<SwagSection> = PlayState.SONG.notes;
		var ghostNotesCaught:Int = 0;
		var daBpm:Float = Conductor.bpm;
	
		for (section in sectionsData)
		{
			if (section.changeBPM != null && section.changeBPM && section.bpm != null && daBpm != section.bpm)
				daBpm = section.bpm;

			for (i in 0...section.sectionNotes.length)
			{
				final songNotes: Array<Dynamic> = section.sectionNotes[i];
				var spawnTime: Float = songNotes[0];
				var noteColumn: Int = Std.int(songNotes[1] % totalColumns);
				var holdLength: Float = songNotes[2];
				var noteType: String = !Std.isOfType(songNotes[3], String) ? Note.defaultNoteTypes[songNotes[3]] : songNotes[3];
				if (Math.isNaN(holdLength))
					holdLength = 0.0;

				var gottaHitNote:Bool = (songNotes[1] < totalColumns);

				if (i != 0) {
					// CLEAR ANY POSSIBLE GHOST NOTES
					for (evilNote in unspawnNotes) {
						var matches: Bool = (noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress && evilNote.noteType == noteType);
						if (matches && Math.abs(spawnTime - evilNote.strumTime) < flixel.math.FlxMath.EPSILON) {
							if (evilNote.tail.length > 0)
								for (tail in evilNote.tail)
								{
									tail.destroy();
									unspawnNotes.remove(tail);
								}
							evilNote.destroy();
							unspawnNotes.remove(evilNote);
							ghostNotesCaught++;
							//continue;
						}
					}
				}

				var swagNote:Note = new Note(spawnTime, noteColumn, oldNote);
				var isAlt: Bool = section.altAnim && !gottaHitNote;
				swagNote.gfNote = (section.gfSection && gottaHitNote == section.mustHitSection);
				swagNote.animSuffix = isAlt ? "-alt" : "";
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = holdLength;
				swagNote.noteType = noteType;
	
				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				var curStepCrochet:Float = 60 / daBpm * 1000 / 4.0;
				final roundSus:Int = Math.round(swagNote.sustainLength / curStepCrochet);
				if(roundSus > 0)
				{
					for (susNote in 0...roundSus)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(spawnTime + (curStepCrochet * susNote), noteColumn, oldNote, true);
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.mustPress = swagNote.mustPress;
						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(noteColumn > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(noteColumn > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if(!_noteTypesSet.exists(swagNote.noteType))
				{
					_noteTypesSet.set(swagNote.noteType, true);
					noteTypes.push(swagNote.noteType);
				}

				oldNote = swagNote;
			}
		}
		trace('["${SONG.song.toUpperCase()}" CHART INFO]: Ghost Notes Cleared: $ghostNotesCaught');
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(_eventsPushedSet.exists(event.event))
			return;

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		_eventsPushedSet.set(event.event, true);
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true);
		if(returnedValue != null && returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	function updateStrumDefaults():Void
	{
		for (i in 0...playerStrums.length) {
			setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
			setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
		}
		opponentDefaultYs = [];
		for (i in 0...opponentStrums.length) {
			opponentDefaultYs.push(opponentStrums.members[i].y);
			setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
			setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
		}
	}

	public var closeOpponentStrumGap:Bool = false;
	public var opponentStrumOffsetY(default, null):Float = 0;
	var opponentDefaultYs:Array<Float> = [];

	public function setOpponentStrumOffsetY(offset:Float):Void
	{
		final delta:Float = (offset - opponentStrumOffsetY) * (ClientPrefs.data.downScroll ? -1 : 1);
		opponentStrumOffsetY = offset;
		if (delta == 0) return;

		for (i in 0...opponentStrums.length)
		{
			opponentStrums.members[i].y += delta;
			if (i < opponentDefaultYs.length)
			{
				opponentDefaultYs[i] += delta;
				setOnScripts('defaultOpponentStrumY' + i, opponentDefaultYs[i]);
			}
		}
	}

	#if mobile
	function usesMobileStrumLayout():Bool
		return ClientPrefs.data.middleScroll && (ClientPrefs.data.middlescrollType == 'mobile' || ClientPrefs.data.mobileOpponentNotes);

	function updateMobileComboOffset():Void
	{
		mobileComboOffsetX = 0;
		mobileComboOffsetY = 0;
		comboGroupBaseX = comboGroup.x;
		comboGroupBaseY = comboGroup.y;
		if(disableMobileComboOffset || !ClientPrefs.data.middleScroll || playerStrums.length < 4) return;

		if(!usesMobileStrumLayout())
		{
			final playerRightEdge:Float = playerStrums.members[3].x + playerStrums.members[3].width;
			mobileComboOffsetX = (FlxG.width + playerRightEdge) / 4 - 20;
			mobileComboOffsetY = (ClientPrefs.data.downScroll ? -1 : 1) * (FlxG.height / 2 - 90);
		}
		else if(ClientPrefs.data.middlescrollType == 'pc')
		{
			mobileComboOffsetX = playerStrums.members[0].x / 2 - FlxG.width / 2;
		}
	}

	function isMobileRingNote(n:Note):Bool
		return n.noteType == 'Ring Note' && usesMobileStrumLayout();

	function positionBaseHitboxes():Void
	{
		if (ClientPrefs.data.controlsType == 'base' && playerStrums.length >= 4)
		{
			for (i in 0...hitboxesGroup.length)
			{
				final hitbox:FlxSprite = hitboxesGroup[i];
				final strum:StrumNote = playerStrums.members[i];
				if (hitbox == null || strum == null) continue;

				hitbox.x = strum.x + (strum.width - hitbox.width) / 2;
				hitbox.y = ClientPrefs.data.downScroll ? FlxG.height - hitbox.height : 0;
			}
		}

		positionSpaceHitbox();
	}

	function usesSpaceHitbox():Bool
		return SPACE_HITBOX_SONGS.contains(Paths.formatToSongPath(SONG.song));

	function positionSpaceHitbox():Void
	{
		if (spaceHitbox == null) return;

		final isPsych:Bool = ClientPrefs.data.controlsType == 'psych';
		var midX:Float = FlxG.width / 2;
		var boxWidth:Int = isPsych ? Std.int(FlxG.width / 5) : 150;
		final boxHeight:Int = isPsych ? FlxG.height : Std.int(FlxG.height / 1.6);

		if (ClientPrefs.data.controlsType == 'base' && hitboxesGroup.length >= 4)
		{
			final left:FlxSprite = hitboxesGroup[1];
			final right:FlxSprite = hitboxesGroup[2];
			midX = (left.x + left.width + right.x) / 2;
			boxWidth = Std.int(Math.max(90, Math.min(150, right.x - (left.x + left.width))));
		}

		if (Std.int(spaceHitbox.width) != boxWidth || Std.int(spaceHitbox.height) != boxHeight)
		{
			spaceHitbox.makeGraphic(boxWidth, boxHeight);
			spaceHitbox.color = 0xFFFFCC00;
		}

		spaceHitbox.x = isPsych ? boxWidth * 2 : midX - spaceHitbox.width / 2;
		spaceHitbox.y = isPsych || !ClientPrefs.data.downScroll ? 0 : FlxG.height - spaceHitbox.height;
	}

	function updateSpaceHitbox():Void
	{
		if (spaceHitbox == null) return;

		var held:Bool = false;
		var anyTouch:Bool = false;
		for (touch in FlxG.touches.list)
		{
			if (!touch.pressed) continue;
			anyTouch = true;
			if (touch.overlaps(spaceHitbox, camOther)) held = true;
		}
		if (!anyTouch && FlxG.mouse.pressed && FlxG.mouse.overlaps(spaceHitbox, camOther)) held = true;

		spaceJustPressed = held && !spaceHeld;
		spaceJustReleased = !held && spaceHeld;
		spaceHeld = held;
		spaceHitbox.alpha = held ? ClientPrefs.data.pressHitboxAlpha : ClientPrefs.data.defHitboxAlpha;
	}

	function applyMobileMiddlescrollStrums():Void
	{
		if (opponentStrums.length < 4 || playerStrums.length < 4) return;

		for(i in 0...4)
		{
			final strum:StrumNote = opponentStrums.members[i];
			final mobileScale:Float = isPixelStage ? strum.baseScaleX * (0.3 / 0.7) : 0.3;
			strum.scale.set(mobileScale, mobileScale);
		}
		positionMobileMiddlescroll();
		if (startedCountdown) updateStrumDefaults();
	}

	function positionMobileMiddlescroll():Void
	{
		if (opponentStrums.length < 4 || playerStrums.length < 4) return;

		if(ClientPrefs.data.middlescrollType == 'mobile') {
			var spacing:Float = 172;
			var pairGap:Float = 150;

			var centerX:Float = (FlxG.width / 2) - (playerStrums.members[0].width / 2);
			var start:Float = centerX - (spacing * 1.5);

			for(i in 0...4) {
				var x:Float = start + (spacing * i);
				x += (i < 2) ? -pairGap / 2 : pairGap / 2;
				playerStrums.members[i].x = x;
			}
		}

		final groupSpan:Float = (3 * .3 * 162) + opponentStrums.members[0].width;
		opponentStrums.members[0].x = (opponentStrumsFlipSide || OPPONENT_FLIP_SIDE_SONGS.contains(Paths.formatToSongPath(SONG.song))) ? (FlxG.width - groupSpan) : 0;

		for(i in 0...4) {
			opponentStrums.members[i].y = ClientPrefs.data.downScroll ? 50 : FlxG.height - 159;
			if(i > 0) opponentStrums.members[i].x = opponentStrums.members[0].x + (i*.3*162);
		}
	}

	#end

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll #if mobile && ClientPrefs.data.middlescrollType != 'mobile' && !ClientPrefs.data.mobileOpponentNotes #end) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(0, 0, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut});
			}
			else babyArrow.alpha = targetAlpha;

			if (player == 1) playerStrums.add(babyArrow);
			else opponentStrums.add(babyArrow);

			babyArrow.y = (ClientPrefs.data.downScroll ? (FlxG.height - babyArrow.height - 50) : 50);
			babyArrow.centerStrums();
			switch(i){
				case 0: 
					babyArrow.addOffset('static', 24.5, 22.3051948051948);
					babyArrow.addOffset('pressed', 24.5, 22.3051948051948);
					babyArrow.addOffset('confirm', 24.5 + 22.8, 22.3051948051948 + 23.4);
				case 1:
					babyArrow.addOffset('static', 23.5, 23.8051948051948);
					babyArrow.addOffset('pressed', 23.5, 23.8051948051948+0.9);
					babyArrow.addOffset('confirm', 23.5 + 22.6, 23.8051948051948 + 23.6);
				case 2:
					babyArrow.addOffset('static', 23.5, 23.8051948051948);
					babyArrow.addOffset('pressed', 23.5, 23.8051948051948);
					babyArrow.addOffset('confirm', 23.5 + 24.1, 23.8051948051948 + 23.4);
				case 3:
					babyArrow.addOffset('static', 24.5, 22.8051948051948);
					babyArrow.addOffset('pressed', 24.5+0.1, 22.8051948051948);
					babyArrow.addOffset('confirm', 24.5 + 21.4, 22.8051948051948 + 20.4);
			}
			if(ClientPrefs.data.middleScroll)
			{
				if (player == 1) babyArrow.x = (FlxG.width / 2) + ((5 + babyArrow.width) * (i - 2) + (5 / 2));
				else babyArrow.x = (FlxG.width / 2) - ((100 + (5 + babyArrow.width) * (i < 2 ? (4 - i) : i)) * (i < 2 ? 1 : -1));
			}

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);

			#if VIDEOS_ALLOWED
			if (videoCutscene != null && videoCutscene.isPlaying()) videoCutscene.pause();
			#end

			#if !mac
			FlxG.stage.window.title = appName + " | Playing: " + SONG.song + " (Paused)";
			if (Paths.formatToSongPath(SONG.song) == 'final-escape') FlxG.stage.window.title = "Playing: " + SONG.song + " (Paused)";
			if (Paths.formatToSongPath(SONG.song) == 'burning') FlxG.stage.window.title = SONG.song;
			#end
		}

		super.openSubState(SubState);
	}

	public var canResync:Bool = true;
	override function closeSubState()
	{
		super.closeSubState();

		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong && canResync)
			{
				resyncVocals();
			}

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			#if VIDEOS_ALLOWED
			if (videoCutscene != null) videoCutscene.resume();
			#end

			paused = false;
			callOnScripts('onResume');
			if (enableFreezeSync) runSongSyncThread();
			resetRPC(startTimer?.finished);

			if (ClientPrefs.data.shaders)
			{
				for (cam in [FlxG.camera, camVideo, camHUD, camOther]) {
					cam.filters?.pop();
					cam.filters = cam.filters;
				}
			}

			#if !mac
			FlxG.stage.window.title = appName + " | Playing: " + SONG.song;
			if (Paths.formatToSongPath(SONG.song) == 'burning') FlxG.stage.window.title = SONG.song;
			#end
		}
	}

	#if DISCORD_ALLOWED
	override public function onFocus():Void
	{
		if (enableFreezeSync){
			shutdownThread = false;
			runSongSyncThread();
		}

		super.onFocus();

		if (!paused && health > 0)
		{
			resetRPC(Conductor.songPosition > 0.0);
		}
	}

	override public function onFocusLost():Void
	{
		if (enableFreezeSync) shutdownThread = true;

		super.onFocusLost();

		if (!paused && health > 0 && autoUpdateRPC)
		{
			DiscordClient.changePresence(detailsText, SONG.song + " (Paused)", iconP2.getCharacter(), true, 0, "icon", 0, Conductor.songPosition);
		}
	}
	#end

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength, "icon", 0, Conductor.songPosition);
		else
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
		#end
	}

	static inline final VOCAL_DRIFT_THRESHOLD:Float = 20.0;

	function syncVocal(voc:FlxSound, musicTime:Float):Void
	{
		if (voc == null || voc.length <= 0 || musicTime >= voc.length) return;

		if (Math.abs(voc.time - musicTime) > VOCAL_DRIFT_THRESHOLD)
			voc.time = musicTime;

		if (!voc.playing)
		{
			voc.time = musicTime;
			voc.play(false, musicTime);
			#if FLX_PITCH voc.pitch = playbackRate; #end
		}
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		trace('resynced vocals at ' + Math.floor(Conductor.songPosition));

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		final checkVocals = [vocals, opponentVocals];
		for (voc in checkVocals)
		{
			if (FlxG.sound.music.time < vocals.length)
			{
				voc.time = FlxG.sound.music.time;
				#if FLX_PITCH voc.pitch = playbackRate; #end
				voc.play();
			}
			else voc.pause();
		}
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;

	private final _updateArgs:Array<Dynamic> = [0.0];
	private var _lastTimeText:String = '';
	private var _freedCpuImages:Bool = false;
	private var _cpuFreeFrameDelay:Int = 0;
	private var _cpuFreeTimer:Float = 0;

	private var _holdArray:Array<Bool> = [];
	private var _pressArray:Array<Bool> = [];
	private var _releaseArray:Array<Bool> = [];
	#if mobile private var _activePointers:Array<Int> = []; #end

	private final _noteArgs:Array<Dynamic>  = [0, 0, '', false, 0.0];
	private final _gnhArgs:Array<Dynamic>   = [0, 0, '', false, 0.0];
	private final _spawnArgs:Array<Dynamic> = [0, 0, '', false, 0.0];
	private final _keyArgs:Array<Dynamic>   = [0];

	override public function update(elapsed:Float)
	{
		syncMobileComboOffset();
		#if mobile
		updateSpaceHitbox();
		for(i in 0...4) {
			final ownerId = hitboxOwner[i];
			final ownerHeld = ownerId != -1 && pointerHeld(ownerId);
			final overHitbox = ownerHeld && pointerOverlapsHitbox(ownerId, i);
			if(!ownerHeld || (!overHitbox && !ClientPrefs.data.slideMechanic) || (!overHitbox && !noteSlide[i] && ClientPrefs.data.slideMechanic)) {
				if(hitboxesHeld[i] && !overHitbox && !ClientPrefs.data.slideMechanic) {
					for (n in notes) {
						if(n != null && n.mustPress && n.noteData == i && n.isSustainNote && n.canBeHit && !n.tooLate && !n.wasGoodHit && !n.missed) {
							noteMiss(n);
							n.active = n.visible = false;
							invalidateNote(n);
							break;
						}
					}
				}
				if(hitboxesGroup[i] != null) hitboxesGroup[i].alpha = ClientPrefs.data.defHitboxAlpha;
				hitboxesHeld[i] = false;
				noteSlide[i] = false;
				hitboxOwner[i] = -1;
				keyReleased(i);
			}
		}

		if(shortPress && startedCountdown && canPause && (Paths.formatToSongPath(SONG.song) != 'burning' || FlxG.save.data.burningWon == true) && FlxG.mouse.overlaps(pauseButton, camOther))
			openPauseMenu();
		#end

		var hasScripts:Bool = false;
		#if LUA_ALLOWED if (luaArray?.length > 0) hasScripts = true; #end
		#if HSCRIPT_ALLOWED if (hscriptArray?.length > 0) hasScripts = true; #end

		#if !mobile
		if (isFixedAspectRatio && FlxG.fullscreen)
		{
			FlxG.fullscreen = false;
		}
		else if (isFixedAspectRatio && !FlxG.stage.window.minimized && !FlxG.stage.window.maximized
			&& (FlxG.stage.window.width != 960 || FlxG.stage.window.height != 720))
		{
			FlxG.resizeWindow(960, 720);
		}

		if (isLetterboxedAspectRatio)
		{
			final fs = FlxG.fullscreen;
			if (_letterboxWasFullscreen && !fs) snapLetterboxWindow();
			_letterboxWasFullscreen = fs;
		}
		#end

		#if (!js && !html5)
		if (ClientPrefs.data.cacheOnGPU && FlxG.stage.context3D != null)
		{
			if (!_freedCpuImages)
			{
				_cpuFreeFrameDelay++;
				if (_cpuFreeFrameDelay >= 3)
				{
					_freedCpuImages = true;
					_freeCpuImageData();
				}
			}
			else
			{
				_cpuFreeTimer += elapsed;
				if (_cpuFreeTimer >= 5.0)
				{
					_cpuFreeTimer = 0;
					_freeCpuImageData();
				}
			}
		}
		#end

		if(!inCutscene && !paused && !freezeCamera) FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
		else FlxG.camera.followLerp = 0;

		if (hasScripts) {
			_updateArgs[0] = elapsed;
			callOnScripts('onUpdate', _updateArgs);
		}

		super.update(elapsed);

		if (hasScripts) {
			setOnScripts('curDecStep', curDecStep);
			setOnScripts('curDecBeat', curDecBeat);
		}

		sunkyBot.update(elapsed);

		if (controls.PAUSE && startedCountdown && canPause && (Paths.formatToSongPath(SONG.song) != 'burning' || FlxG.save.data.burningWon == true))
		{
			var ret:Dynamic = LuaUtils.Function_Continue;
			if (hasScripts) ret = callOnScripts('onPause', null, true);
			
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1'))
				openChartEditor();
			else if (controls.justPressed('debug_2'))
				openCharacterEditor();
		}

		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;

		//for health bar smoothing
		displayHealth = FlxMath.lerp(displayHealth, health, 0.1 * playbackRate);
		if (health >= 2) displayHealth = 2;

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (startedCountdown && !paused)
		{
			Conductor.songPosition += elapsed * 1000 * playbackRate;
			if (FlxG.sound.music != null && Conductor.songPosition >= Conductor.offset)
			{
				Conductor.songPosition = FlxMath.lerp(FlxG.sound.music.time + Conductor.offset, Conductor.songPosition, Math.exp(-elapsed * 5));
				var timeDiff:Float = Math.abs((FlxG.sound.music.time + Conductor.offset) - Conductor.songPosition);
				if (timeDiff > 1000 * playbackRate)
					Conductor.songPosition = Conductor.songPosition + 1000 * FlxMath.signOf(timeDiff);
			}

			if (!startingSong && !endingSong && FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				syncVocal(vocals, FlxG.sound.music.time);
				syncVocal(opponentVocals, FlxG.sound.music.time);
			}
		}

		if (!endingSong && !startingSong && generatedMusic && songLength > 0 && FlxG.sound.music != null && FlxG.sound.music.playing && FlxG.sound.music.time >= songLength - 100)
		{
			finishSong();
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= Conductor.offset)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
		}

		gameplayCam.update(elapsed); 

		#if debug
		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		#end

		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			var spawnCount:Int = 0;
			while (spawnCount < unspawnNotes.length && unspawnNotes[spawnCount].strumTime - Conductor.songPosition < time)
				spawnCount++;

			if (spawnCount > 0)
			{
				var notesToSpawn:Array<Note> = unspawnNotes.splice(0, spawnCount);
				for (dunceNote in notesToSpawn)
				{
					notes.insert(0, dunceNote);
					dunceNote.spawned = true;

					if (dunceNote.noteData >= 0 && dunceNote.noteData < 4)
						noteQueues[dunceNote.noteData].push(dunceNote);

					if (hasScripts) {
						_spawnArgs[0] = 0; 
						_spawnArgs[1] = dunceNote.noteData;
						_spawnArgs[2] = dunceNote.noteType;
						_spawnArgs[3] = dunceNote.isSustainNote;
						_spawnArgs[4] = dunceNote.strumTime;
						callOnLuas('onSpawnNote', _spawnArgs);
						callOnHScript('onSpawnNote', [dunceNote]);
					}
				}
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						var i:Int = 0;
						while(i < notes.length)
						{
							var daNote:Note = notes.members[i];
							if(daNote == null) continue;

							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress #if mobile && !isMobileRingNote(daNote) #end) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
								if(sunkyBot.shouldHit(daNote))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							var killTime:Float = daNote.strumTime;
							if(daNote.isSustainNote && daNote.parent != null)
								killTime = daNote.parent.strumTime + daNote.parent.sustainLength;

							if (Conductor.songPosition > noteKillOffset + killTime)
							{
								if (daNote.mustPress && !cpuControlled && !cpuAssist && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									noteMiss(daNote);

								#if mobile
								if (daNote.mustPress && daNote.isSustainNote) noteSlide[daNote.noteData] = false;
								#end

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
							if(daNote.exists) i++;
						}
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { 
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		if (hasScripts) {
			setOnScripts('botPlay', cpuControlled);
			_updateArgs[0] = elapsed;
			callOnScripts('onUpdatePost', _updateArgs);
		}
	}

	#if (!js && !html5)
	private function _freeCpuImageData():Void
	{
		var freed:Int = 0;
		for (graphic in Paths.currentTrackedAssets)
		{
			if (graphic.bitmap?.image?.data != null)
			{
				graphic.bitmap.image.data = null;
				graphic.bitmap.image = null;
				graphic.bitmap.readable = false;
				freed++;
			}
		}
		if (freed > 0) Paths.clearUnusedMemory();
	}
	#end

	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		final mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		final mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
	}

	public dynamic function updateIconsPosition()
	{
		final iconOffset:Int = 26;
		iconP1.x = healthBar.barCenter + (150 * (FlxMath.remapToRange(displayHealth, 0, 2, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * (FlxMath.remapToRange(displayHealth, 0, 2, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float 
	{
		value = FlxMath.roundDecimal(value, 5); //Fix Float imprecision
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			_health = value;
			return _health.toFloat();
		}

		// update health bar
		_health = value;
		
		final newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; 
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; 
		return _health.toFloat();
	}

	var _daPauseTarget:Int = 1;
	public function openPauseMenu()
	{
		if (ClientPrefs.data.shaders)
		{
			final colorSwap:ColorSwap = new ColorSwap();
			colorSwap.hue = -1;
			colorSwap.brightness = -0.5;
			colorSwap.saturation = -1;

			for (cam in [FlxG.camera, camVideo, camHUD, camOther]) {
				final daFilters = cam.filters ?? [];
				daFilters.push(new ShaderFilter(colorSwap.shader));
				cam.filters = daFilters;
			}
		}

		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim?.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		if (Paths.formatToSongPath(SONG.song) == 'vanilla-milk') PauseSubState.miniSonicImage = 'vanilla-milk-' + (FlxG.random.bool(1) ? 2 : 1);
		if (Paths.formatToSongPath(SONG.song) == 'hollow') PauseSubState.miniSonicImage = 'hollow-' + (FlxG.random.bool(10) ? 3 : _daPauseTarget);
		if (Paths.formatToSongPath(SONG.song) == 'longstrider' || Paths.formatToSongPath(SONG.song) == 'universal-collapse') PauseSubState.miniSonicImage = 'omw';

		if(chartingMode) openSubState(new PauseSubState());
		else openSubState(new PauseSubState());

		#if !mac
		FlxG.stage.window.title = appName + " | Playing: " + SONG.song + " (Paused)";
		if (Paths.formatToSongPath(SONG.song) == 'final-escape') FlxG.stage.window.title = "Playing: " + SONG.song + "(Paused)";
		if (Paths.formatToSongPath(SONG.song) == 'burning') FlxG.stage.window.title = SONG.song;
		#end

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song + " (Paused)", iconP2.getCharacter(), true, 0, "icon", 0, Conductor.songPosition);
		#end
	}

	function openChartEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		chartingMode = true;
		firstPlay = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end

		FlxG.switchState(() -> new ChartingState());
	}
	
/*
-:-=-==++****#%@%#%%%#####%%%@@@@@%###%%%@@%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%@@@@@@%%%%#########%%@%#*##*++++==-=-
-:---=++=+***#%@@%%%%%###%%%@@@@@@%#%%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%@@@@@@@%%%%%##%%####%@@%##*+++++==---
====++******#%@@%%%%%%%%%%%%@@@@@@%%%%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%@@@@@@@@@@%%%%####%%@@%##******++===
*#*****######%@@@%###%%%%%%%%@@@@@%%%%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%@@@@@@@@%%%######%@@@%%#####****+++
#@@%#######%%@@@%%#####%%@@@@@@@@@@%%%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%@@@@%%%%%######%%@@@%%####******#
*@@@@%*####%%@@@%#######%%@@@@@@@@@@@@@@@@@%%%%%%%%@@@@@@@@@@@@@@%%%#%%%%%%@@@@@@@@@@@@@@@%%%%%@@@@@@@@@@@@@%%%%%%%%%%%%@@@@@%%%%%%%#####%%@@@%####**#**%@
*#@@@@@%%##%%%@%#######%%%@@@@@@@@@@@@@@@@@@%%%%%%%@@@@@@@@@@@@@@%#####%%%%@@@@@@@@@@@@@@%%%%%%%@@@@@@@@@@@@%%%%%%%%@@@@@@@@@%%%%%%%@@%###%@@%%%#####%@@@@
***@@@@@@%%%%%@%#######%%%@@@@@@@@@@@@@@@@@@@@%%%%%@@@@@@@@@@@@@@%######%%%%@@@@@@@@@@@@%%%%#%%%@@@@@@@@@@@@@%%%%%@@@@@@@@@@@@@%%%########%%@%%%#%%%@@@%%@
***#%@@@@@@@%@@%######%%%%%@@@@%%%%@@@@@@@@@@@@%%%@@@@@@@@@@@@@@@%######%%%%@@@@@@@@@@@@%%%%##%%@@@@@@@@@@@@@%%%%@@@@@@@@@@@@@%%%#########%@@%%%%@@@%%%%@@
##*##%@@@@@@@@@%%########%%%%%%%%%%%%%@@@@@@@@@@%%@@@@@@@@@@@@@@@%%%%%%%%%%%%%@@@@@@@@@@%%%%###%@@@@@@@@@@@@@@%%%@@@@@@@@@@@@%%%%#########%@@@@@@@%%%%@@@@
####%##%@@@%%@@@@%%############%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@%%%%%@@@%%%%%%%%%%%%%@%%%%%##%%@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%##########%%@@@@%%%%%%@@%%%
#####%%%%@@@@%%%%@@%%###################%%%@@@@@@@@@@%@@@@@@@@%#**+***%%@%%#************##%%%%%%@@@@@@@@@@@@@@@@@@@%%%%%%%%###########%%%%@@%%############
#%%#####%%@@@@%%%%%%@@%%################%%@@@@@@@@@@@@@@@@@@@%**+++++++*####************####%%%%@@@@@@@@@@@@@@@@@@@%%%#############%%@%@@@%%#####******###
###%%%%####%%@@@%%###%%@@%%##########**#%%@@@@@@@@@@@@@@@@@@@**++++++++**###***+++*********##%%%@@@@@@@@@@@@@@@@@@@%%#########**##%@@@@%%%#******++**###%%
@%#%%%%%%%##############%%@@%%%%%####*##%@@@@@@@@@@@@@@@@@@@@#++++++===+*###*+++*###%%%%#***#%%%@@@@@@@@@@@@@@@@@@@@%###########%@@%%%%%#*****++++****###%
%%%%%@%@@@%%##************#%%@@@@@%%####%%@@@@@@@@@@@@@@@@@@@#**++++**==*###*++**%%%%@@%#***#%%%@@@@@@@@@@@@@@@@@@@@%#####%%%%@@@%%%####++++===+++****####
%%%%%%%%%%%@%%%##**++++++***%%%%@@@@@%%%%%%@@@@@@@@@@@@@@@@@@#*###++%#+=+#%#**+*%%==+#*+%%#**#%%@@@@@@@@@@@@@@@@@@%%%%##%@@@@@@%#####*+=++++==++++*****###
##%%%%%%%#####******+++==++==*####%%%@@@@@@@@@@@@@@@@@@@@@@@@%##*=-=+=+++%@%#*+*#*+-:.-+#%#**#%%@@@@@@@@@@@@@@@@@@@@%@@@@@@@@%***##*++****+==-==++***##%%@
***#%%@@@%%###*****++++==+++===+######%@@@@@@@@@@@@@@@@@@@@@@@#***=:-+++*%@%##****#%###*######%%@@@@@@@@@@@@@@@@@@@@@@@@%%%#*++*+++*****+=---=+++**######%
****###%@@@%%%%##***++=====+++*********#%%%%@@@@@@@@@@@@@@@@@@#**#%%%**+#@@%%#*++***##****#%@%%@@@@@@@@@@@@@@@@@@@@@@@@%###**+==++****+=--===++++++***####
**+*****##%%@@@@%%#***++==--=+*****+++++**###@@@@@@@@@@@@@@@@%#*++***++*%@@%%%%#**+++****#%@@%%@@@@@@@@@@@@@@@@@@@@@%%#****+===+=+**+++++++==+++++***##%%%
***###***#########****+++====-=+***+++==+*****%@@@@@@@@@@@@@@%*+++++***#%@@%%%@@%##***#%%@@@@%%@@@@@@@@@@@@@@@@@@@%%##**+++======++******+===++***###%%%@@
*++*####%%%%%%#####***+++==++++*+++++=====+++**#%%@@@@@@@@@@@%###*###**#%@%%%#%@@@@@@@@@@@@@%%%@@@@@@@@@@@@@@@@@@%##**+++++====++++***+=--==++****###%%%%%
*++*##*%%%%@@@@@@%%%##**++===++****+++==--===++**##%@@@@@@@@%######***#%%@%%%@@%#*####%%%%%%###@@@@@@@@@@@@@@@@%%##**+++========+++++*****++++*****#######
*++*####%#%%%@@@@%%%##***++=====++++++==++=====++**#%@@@@@@@%******+*###%%###%%#**************#%@@@@@@@@@@@@@@%%#**++++=+==--==++*******++=++***######%%%%
*++*##******#########****+++==+******++==--=+===+++*#%@@@@@@%*****+++******+++++#%#*++++******#@@@@@@@@@@@@@@@%#**++++==+=+====+++++==-==+***##%%%%%%%%@@@
*++*#**########%%%%%####***++++=++++++++===========+*#%%@@@@@%#*+=++==-==+====*%@@%%#+===+****%%@@@@@@@@@@@@@%#**+++===++++==+++****++==+++****###%%@@@%%%
*++*#**#%#%@@@@@@@@@%%%%%%#***++==+++++++===+++===++*##%@@@@@@%*==+++==---=+*%@@@@%#****++***##%@@@@@@@@@@@@@%#**+++==+++++++++=-=====+++***#######%%%%%%%
*++*#**#%#%@@@@%%%@@@%%##****++============-========+*#%%@@@@@@#+++==++==++*##****#######*****##@@@@@@@@@@@@@%#*++===+++++++**###*-=+++**#%%%%%%%%%%%%%%%%
*+=****#%#%@@%%%%%%%%%%%#######**++===+**++====+====+**#%@@@@@@%*+*#*+=====+*%@@%#**###%#******#@@@@@@@@@@@@@%#*++===++++++***##*+++++******#%%@@@@@@@@%%%
+++*#**#%#%@%@%%%%@@@@@@@@@@%#***++===+++++====++====+*#%@@@@@@@%***##*+*****#*****###%#******##@@@@@@@@@@@@%#*+++++++***+**#*+--=++***######%%%%%%%%%%#*#
+++*#**#%#%@@@@%%%%%%@@@@@%###******++====+++=+++=====+*#%@@@@@@@%**++++++*******#######******##@@@@@@@@@@@@%#*+++++++*++*****#*++++***#%%%%%%%%##########
*++*#**#%#%@%@@%###%%%#######%%%%#**++==+*+++===++====+*#%@@@@@@@@%*++++++++**###%%%##*******###@@@@@@@@@@@%##*+===+***++++=+++++*******###%@@@@@%%####***
*=+*#**###%%%@@%####***#%%@@@@%##*****++===============+*#%@@@@@@@@#*+++**##%%@@@%%##********##%@@@@@@@@@@@%#**+==+****++***+==+++***###%####%%%%%%%#%#*+*
+=+*#**###%%%@@%######%%%%%%%%######**+++==++++==+++====+*#%@@@@@@@@#****##%%@@@%##***+*****###%@@@@@@@@@@%#*+==++++++++******+*******##%%%%##***#%##%#*+*
*=+*#**#%#%%%@@%##############%%%%##*****++++++====+===-=+*#%@@@@@@@@#****######****++****#*###%@@@@@@@@%%#**+++++***++***+==+++**#%%%%#%%@@@%%###%####*+*
*++*#**%%#%@%@@%########%###%%@@%%%%%%#**++===+++++++=====+*#%%@@@%%%%#**********++++**########%@@@@@%%%#***+===++***++***+++******#%@@%%%%@@@@@%%%####*+*
*++*#**%%%%@%@@%%%%#%########%%%%%@@@%###***++++++=+++====++**##%@%#+*##********+++**#########%@@@@%%#***+++=++=++******+++=+*####%%%@@@@@@@@@@@%%%#*##*++
*=+*#+*%%%%@@@@%#####%@%######%%%@@@@%%%##**+==+**+=-=+======+**#%%#++==+++++++++**#%%%%%#######%@%%%#*+=+=+++****+=**##*++++***#%%%%@@@%%%@@@@%##%#*##*+*
*=+*#+*%%%%@@@@%#########%#####%%%%@@%%%###***+***++==+++=====+*#%@#+========++**#%%@@@%%%###****#####+=++==+**+++++++******######%@%%@@%%%@@@%%%%%**##*++
*=+*#**%%#%@@@@@%##########%@%##%%@@%@@%%%##**+++=============+**%@#+======++**##%%@@@@%%%##**++*****#+===+=++==+***++===++**##%#%%@@@%%%%%@@@%%%%%#*##*=+
+=+*#**%%#%@@@@@%%######%%######%%%@@@@%%%%#****+==+=+++======+**%@#+++=+++**##%%%@@@@@%%##**+==+*****+===+++==+****====+***###%%%%%%@%%%%%@@@@@%%%#***+=+
+=+*%**#%%%@@@@@@@@%%%%%%%#*######%%@@%%@@%%###*++++++=====++=***%@#*++++***###%%%@@@%%##****+=-=**##**=++=++**++++*++++**#####%@@@%%%%%#%%@@@@@%%%#***+=+
+=+**+*%##%@@@@@@@@@@@%%%%#**#####%%%%@@@@%%%%####**+===+++==+**+#@#*++*****###%%%@%%%##*****++==+*####+=+++++**+==++***####%%##%%%%%%%%#%%@@@@@%%@%***+==
+==****%%%%@@@@@@@@@@@@%%%#*######%%%@@@@%%%@@%####**+++++++++**+#@%********####%%%%###*******++=+**####*+***++**+++***#####%@%#*##%%##%%%@@@@@@%%@%****=+
+==****%%%%@@@@@@@@@@@@%%###***###%%%@@@%%@@@@%%%%%##***++++++**+#@%*********##########********+==+*####*++**++++**####%%%##%%%%%#*#%%@@@@@@@@@@%%@%**#**+
+-+****%%%%@@@@@@@@@@@%%%#*****###%%@@@@@@@@@%%%@@%%###****+++***#@%**********#########********++++**####+++******###%%%@%%##%%#%%%#%@@@@@@@@@@@%%@%*##**+
*/

	function openCharacterEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		firstPlay = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		FlxG.switchState(() -> new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	public var gameOverTimer:FlxTimer;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && gameOverTimer == null)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop)
			{
				EXEAchievements.achieveGameOver(SONG.song);
				FlxG.timeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;
				canResync = false;
				canPause = false;
				#if VIDEOS_ALLOWED
				if(videoCutscene != null)
				{
					videoCutscene.destroy();
					videoCutscene = null;
				}
				#end

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				FlxG.camera.filters = [];

				if(GameOverSubstate.deathDelay > 0)
				{
					gameOverTimer = new FlxTimer().start(GameOverSubstate.deathDelay, function(_)
					{
						vocals.stop();
						opponentVocals.stop();
						FlxG.sound.music.stop();
						openSubState(new GameOverSubstate(boyfriend));
						gameOverTimer = null;
					});
				}
				else
				{
					vocals.stop();
					opponentVocals.stop();
					FlxG.sound.music.stop();
					openSubState(new GameOverSubstate(boyfriend));
				}

				// FlxG.switchState(() -> new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song + " | Game Over.", iconP2.getCharacter());
				#end
				#if (!mac && DISCORD_ALLOWED)
				FlxG.stage.window.title = appName + " | Was Playing: " + SONG.song;
				var dausername:String = DiscordClient.username ?? 'boyfriend';
				final message:Array<Array<String>> = [
					[ // INTRO
						'You\'re too slow... Don\'t be afraid, ${dausername}... We are having so much fun!',
						'Death again? How pathetic. I guess, you can\'t stand up to a GOD after all, huh?',
						'Third time in a row? Come on, we are just getting started, ${dausername}!',
						'Fourth time in a row... I\'m not done with you, ${dausername}. Im waiting if you wanna die AGAIN.',
						'Fifth death... You know... Nobody have ever died this many times in a row. Are you kind of a noob or looking for something special to happen?',
						'Sixth death... ${dausername}... I guess you are special after all... You have to be such a dissapointing life-form.',
						'Seventh times... Are you not getting tired of being such a loser? Come on.',
						'Eighth, You know what, I\'m so done with you.',
						' '
					],
					[ //HALF WAY
						'You can\'t escape from me, you know? You almost make me use all of my power.',
						'Death again? This is so much fun, ${dausername}, ain\'t it?',
						'Third time in a row? I know you were an annoying prey but I didn\' know you were THIS dumb.',
						'Fourth time in a row... You are really such a loser ${dausername}.',
						'Fifth death... You know... Nobody have ever died this many times in a row. Are you kind of a noob or looking for something special to happen?',
						'Sixth death... ${dausername}... I guess you are special after all... You have to be such a dissapointing life-form.',
						'Seventh times... Are you not getting tired of being such a loser? Come on.',
						'Eighth, You know what, I\'m so done with you.',
						' '
					],
					[ //ENDING
						'Awww... You were so close for your FIRST attempt, you\'re really dissapointing just to lose in the end.',
						'Death again? HAHAHA! Remember, YOU CAN\' WIN in my world.',
						'Third time in a row? Hah... I almost thought you were going to WIN this time! Who am I kidding? I KNOW YOU CAN\'T WIN!',
						'Fourth time in a row... I think you should just give up, ${dausername}. This is getting boring, always in the end.',
						'Fifth death... You know... Nobody have ever died this many times in a row. Are you kind of a noob or looking for something special to happen?',
						'Sixth death... ${dausername}... I guess you are special after all... You have to be such a dissapointing life-form.',
						'Seventh times... Are you not getting tired of being such a loser? Come on.',
						'Eighth, You know what, I\'m so done with you.',
						' '
					]
				];
				if (Paths.formatToSongPath(SONG.song) == 'final-escape') FlxG.stage.window.title = message[_phase][Std.int(Math.min(deathCounter.toInt() - 1, 8))];
				if (Paths.formatToSongPath(SONG.song) == 'burning') FlxG.stage.window.title = 'Lets try that again, shall we ${dausername}?';
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		var dueCount:Int = 0;
		while (dueCount < eventNotes.length && Conductor.songPosition >= eventNotes[dueCount].strumTime)
			dueCount++;

		if (dueCount == 0) return;

		var dueEvents:Array<EventNote> = eventNotes.splice(0, dueCount);
		for (event in dueEvents)
		{
			var value1:String = '';
			if(event.value1 != null)
				value1 = event.value1;

			var value2:String = '';
			if(event.value2 != null)
				value2 = event.value2;

			triggerEvent(event.event, value1, value2, event.strumTime);
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					if(!tweenCamZoom)
						FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				gameplayCam.setForcedPos(flValue1, flValue2);
				isCameraOnForcedPos = gameplayCam.isCameraOnForcedPos;

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				final valuesArray:Array<String> = [value1, value2];
				final targetsArray:Array<FlxCamera> = [FlxG.camera, camHUD];
				for (i in 0...targetsArray.length) {
					final split:Array<String> = valuesArray[i].split(',');

					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0)
						targetsArray[i].shake(intensity, duration);
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
						gf.shader = null;
						gf.useRenderTexture = true;
					case 'dad' | 'opponent':
						charType = 1;
						dad.shader = null;
						dad.useRenderTexture = true;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
						boyfriend.shader = null;
						boyfriend.useRenderTexture = true;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var trueValue:Dynamic = value2.trim();
					if (trueValue == 'true' || trueValue == 'false') trueValue = trueValue == 'true';
					else if (flValue2 != null) trueValue = flValue2;
					else trueValue = value2;

					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], trueValue);
					} else {
						LuaUtils.setVarInArray(this, value1, trueValue);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);
		}

		gameplayCam.onEvent(eventName, value1, value2);

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	public function moveCameraSection(?sec:Null<Int>)
	{
		gameplayCam.moveCameraSection(sec);
	}
	
	public function moveCameraToGirlfriend()
	{
		gameplayCam.moveCameraToGirlfriend();
	}

	var cameraTwn:FlxTween = null;
	public function moveCamera(isDad:Bool)
	{
		gameplayCam.moveCamera(isDad);
	}

	public function tweenCamIn() {
		gameplayCam.tweenCamIn();
	}

	var finishingSong:Bool = false;
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		if (finishingSong) return;
		finishingSong = true;

		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		// Scripts Anticheat shit uuu ;p
		if (!Main.DEVELOPMENT_BUILD && !chartingMode && sunkyBot.wasActivated) FlxG.resetState();

		if(!startingSong)
		{
			final limitTime = songLength - Conductor.safeZoneOffset;
			
			for (daNote in notes.members)
			{
				if(daNote?.alive && !daNote.missed && !daNote.wasGoodHit && daNote?.strumTime < limitTime)
					health -= 0.05 * healthLoss;
			}
			for (daNote in unspawnNotes)
			{
				if(!daNote.missed && !daNote.wasGoodHit && daNote?.strumTime < limitTime)
					health -= 0.05 * healthLoss;
			}

			if(doDeathCheck())
				return false;
		}

		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;

		deathCounter = 0;
		seenCutscene = false;
		firstPlay = false;
		hasRestarted = false;

		final ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret == LuaUtils.Function_Stop || transitioning)
			return true;

		transitioning = true;

		#if !switch
		final percent:Float = Math.isNaN(ratingPercent) ? 0 : ratingPercent;
		Highscore.saveScore(Song.loadedSongName, songScore, storyDifficulty, percent);
		if(!practiceMode && !cpuControlled)
			EXEAchievements.checkSongCompletion(Paths.formatToSongPath(SONG.song), songMisses, percent);
		#end
		
		playbackRate = 1;

		if (chartingMode)
		{
			openChartEditor();
			return false;
		}

		final formattedSong = Paths.formatToSongPath(SONG.song);
		var currentScore:Int = songScore; 
		var previousHighScore:Int = Highscore.getScore(formattedSong, storyDifficulty);
		trace("Previous High Score: "+previousHighScore+", Local Score: "+currentScore);

        if (currentScore >= previousHighScore)
        {
            backend.GameJoltManager.submitSongScore(formattedSong, currentScore, function(success:Bool) {
                if (success) {
					trace("good");
					backend.GameJoltManager.submitTotalScore(function(totalSuccess:Bool) {
						if (totalSuccess) trace("good x2");
						else trace("actually bad");
					});
				}
                else trace("bad");
            });
        }
       
		checkSavedSongs(formattedSong);

		final exitToMenu = () -> {
			Mods.loadTopMod();
			#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

			FlxG.sound.music?.stop();
			canResync = false;
			changedDifficulty = false;

			if (states.StoryModeState.fromStoryMode) { 
				states.StoryModeState.fromStoryMode = false; 
				FlxG.switchState(() -> new states.StoryModeState()); 
			}
			else if (states.SoundTest.fromSoundTest) { 
				states.SoundTest.fromSoundTest = false; 
				FlxG.switchState(() -> new states.SoundTest()); 
			}
			else if (states.parallax.StoryParallaxState.fromParallax) { 
				states.parallax.StoryParallaxState.fromParallax = false; 
				FlxG.switchState(() -> new states.parallax.StoryParallaxState()); 
			}
			else if (states.access.FridgeAccess.fromFridge) { 
				states.access.FridgeAccess.fromFridge = false; 
				FlxG.switchState(() -> new states.access.FridgeAccess()); 
			}
			else if (states.access.MajinAccess.fromMajin) { 
				states.access.MajinAccess.fromMajin = false; 
				FlxG.switchState(() -> new states.access.MajinAccess()); 
			}
			else {
				FlxG.switchState(() -> new EXEFreeplay());
			}
		}

		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.shift();

			if (!FlxG.save.data.storyModeDone) FlxG.save.data.lastCoverPlay ??= 0;

			switch(formattedSong)
			{
				case "too-slow":
					if (!FlxG.save.data.storyModeDone) FlxG.save.data.lastCoverPlay = 0;
				case "you-cant-run":
					if (!FlxG.save.data.storyModeDone) FlxG.save.data.lastCoverPlay = 1;
				case "triple-trouble":
					FlxG.save.data.goToFinalEscape = true;
					if (!FlxG.save.data.storyModeDone) FlxG.save.data.lastCoverPlay = 2;
					FlxG.save.flush();

					trace("Save Data for Final Escape is: " + FlxG.save.data.goToFinalEscape);

					Application.current.window.close();
				case "final-escape":
					if (!FlxG.save.data.storyModeDone) FlxG.save.data.lastCoverPlay = 3;
					FlxG.save.data.theYourselfCutscene = true;
					FlxG.save.flush();

					FlxG.switchState(() -> new StoryModeState());
					return true;
				case "yourself":
					if (!FlxG.save.data.storyModeDone) FlxG.save.data.lastCoverPlay = 4;
					FlxG.save.data.theYourselfCutscene = null;
					FlxG.save.data.storyModeDone = true;
					FlxG.save.flush();
				case "fight-or-flight":
					if (states.SoundTest.fromSoundTest) 
					{
						EXEFreeplay.maniaUnlock = true;
						states.SoundTest.fromSoundTest = false;
						FlxG.switchState(() -> new states.EXEFreeplay());
					}
			}
			if (!FlxG.save.data.storyModeDone) trace(FlxG.save.data.lastCoverPlay);

			if (storyPlaylist.length <= 0)
			{

				if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
					StoryModeState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
					Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

					FlxG.save.data.weekCompleted = StoryModeState.weekCompleted;
					FlxG.save.flush();
				}
				
				exitToMenu();
			}
			else
			{
				final difficulty:String = Difficulty.getFilePath();

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				canResync = false;
				LoadingState.prepareToSong();
				LoadingState.loadAndSwitchState(new PlayState(), false, false);
			}
		}
		else
		{
			exitToMenu();

			if (formattedSong == 'personel')
			{
				FlxG.save.data.burningBot = true;
				FlxG.save.flush();
				haxe.Timer.delay(() -> Application.current.window.close(), 3000);
			}

			if (formattedSong == 'burning')
			{
				backend.BurningBot.resetFreeplayState();
				FlxG.save.data.burningWon = true;
				FlxG.save.flush();
			}
		}

		return true;
	}

	public function checkSavedSongs(formattedSong){
        final save:FlxSave = new FlxSave();
        save.bind('savedSongs', CoolUtil.getSavePath());
        save.data.songs ??= [];
        var unlocked:Array<String> = save.data.songs;

        if (states.SoundTest.fromSoundTest || states.access.FridgeAccess.fromFridge || states.access.MajinAccess.fromMajin || states.EXEMenu.secretSong || isStoryMode)
        {
            states.EXEMenu.secretSong = false;

            if (!unlocked.contains(formattedSong))
            {
                unlocked.push(formattedSong);
                trace('[DEBUG] Song saved: ' + formattedSong);
            }
        }

        var secretSongPath:String = Paths.formatToSongPath('shocker'); 
        var allSongsCompleted:Bool = true;
        var missingSongs:Array<String> = [];

        trace('[DEBUG] === STARTING SONGS CHECK ===');
        trace('[DEBUG] Saved Beated Songs: ' + unlocked);

        for (i in 0...WeekData.weeksList.length)
        {
            final weekName:String = WeekData.weeksList[i];
            final leWeek:WeekData = WeekData.weeksLoaded.get(weekName);

            if (leWeek == null || leWeek.songs == null) continue;

            for (song in leWeek.songs)
            {
                final sName:String = Paths.formatToSongPath(song[0]);
                if (sName == 'minigame') continue;
                
                if (sName != secretSongPath && !unlocked.contains(sName))
                {
                    allSongsCompleted = false;
                    missingSongs.push(sName);
                }
            }
        }

        if (allSongsCompleted)
        {
            trace('[DEBUG] SUCCESS: Beated all Songs');
            if (!unlocked.contains(secretSongPath))
            {
                unlocked.push(secretSongPath);
                trace('[DEBUG] Secret song '+secretSongPath+" unlocked!");
            }
        }
        else
        {
            trace('[DEBUG] '+missingSongs.length+' REMAINING SONG: ' + missingSongs);
        }

        save.data.songs = unlocked;
        save.flush();
        trace('[DEBUG] === END SONGS CHECKING ===');
	}

	public function KillNotes() {
		while(notes.length > 0) {
			final daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	
	private var _totalNotesHit:SecureFloat = 0.0;
	public var totalNotesHit(get, set):Float;
	inline function get_totalNotesHit():Float return _totalNotesHit.toFloat();
	inline function set_totalNotesHit(val:Float):Float { _totalNotesHit = val; return val; }

	public var comboGroup:FlxSpriteGroup;
	public var mobileComboOffsetX:Float = 0;
	public var mobileComboOffsetY:Float = 0;
	public var disableMobileComboOffset:Bool = false;
	var comboGroupBaseX:Float = 0;
	var comboGroupBaseY:Float = 0;

	function syncMobileComboOffset():Void
	{
		if((mobileComboOffsetX != 0 || mobileComboOffsetY != 0) && (comboGroup.x != comboGroupBaseX || comboGroup.y != comboGroupBaseY))
		{
			mobileComboOffsetX = 0;
			mobileComboOffsetY = 0;
		}
	}
	public var uiGroup:FlxSpriteGroup;
	public var noteGroup:FlxTypedGroup<FlxBasic>;

	private function cachePopUpScore()
	{
		var uiFolder:String = "";
		if (stageUI != "normal")
			uiFolder = uiPrefix + "UI/";

		for (rating in ratingsData)
			Paths.image(uiFolder + rating.image + uiPostfix);
		for (i in 0...10)
			Paths.image(uiFolder + 'num' + i + uiPostfix);
	}

	private function popUpScore(note:Note = null):Void
	{
		final noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;
		syncMobileComboOffset();
		
		for (spr in comboGroup.members)
		{
			if(spr?.alive) {
				FlxTween.cancelTweensOf(spr);
				FlxTween.cancelTweensOf(spr.scale);
				spr.kill();
			}
		}

		var score:Int = 350;

		final daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);
		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		note.comboBreak = daRating.comboBreak;
		
		score = daRating.score;

		// Combo counter moved here for the desaturated note feature to work properly
		if (daRating.comboBreak){
			combo = 0;
			
			// correctly?
			final lastCombo:Int = combo; // uuhhhh
			if(gf != null && lastCombo > 10 && gf.hasAnimation('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}

			totalPlayed++;
			RecalculateRating(true);
			note.desat();
		}else{
			combo++;
		}

		if(combo > 9999) combo = 9999;

		if (daRating.name == 'sick') 
		{
			final precisionBonus:Int = Math.floor(Math.max(0, 50 - noteDiff));
			score += precisionBonus;
		}

		if(!cpuControlled) 
		{
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var uiFolder:String = "";
		var antialias:Bool = ClientPrefs.data.antialiasing;
		if (stageUI != "normal")
		{
			uiFolder = uiPrefix + "UI/";
			antialias = !isPixelStage;
		}

		final rating:FlxSprite = comboGroup.recycle(FlxSprite);
		rating.loadGraphic(Paths.image(uiFolder + daRating.image + uiPostfix));
		rating.visible = !ClientPrefs.data.hideHud;
		rating.cameras = [camHUD];
		rating.alpha = 1;
		
		if (!PlayState.isPixelStage) rating.setGraphicSize(Std.int(rating.width * 0.6 * 1.1));
		else rating.setGraphicSize(Std.int(rating.width * 4 * 1.1));
		rating.updateHitbox();
		rating.screenCenter(X);
		rating.y = comboGroup.y + mobileComboOffsetY + (ClientPrefs.data.downScroll ? ((FlxG.height - rating.height) - 90) : 90);
		rating.x += comboGroup.x + mobileComboOffsetX;

		final targetScale:Float = PlayState.isPixelStage ? 4 : 0.6;
		rating.scale.set(targetScale * 1.15, targetScale * 1.15);
				
		FlxTween.tween(rating.scale, {x: targetScale, y: targetScale}, 0.2 / playbackRate, {ease: FlxEase.cubeOut});
		rating.antialiasing = antialias;
		
		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate, 
			onComplete: (_) -> rating.kill()
		});

		final separatedScore:String = Std.string(combo).lpad('0', 2);
		for (i in 0...separatedScore.length)
		{
			final numScore:FlxSprite = comboGroup.recycle(FlxSprite);
			numScore.loadGraphic(Paths.image(uiFolder + 'num' + Std.parseInt(separatedScore.charAt(i)) + uiPostfix));
			numScore.visible = !ClientPrefs.data.hideHud;
			numScore.cameras = [camHUD];
			numScore.alpha = 1;
			
			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.6 * 1.1));
			else numScore.setGraphicSize(Std.int(numScore.width * 4 * 1.1));
			numScore.updateHitbox();
			
			numScore.x = comboGroup.x + mobileComboOffsetX + FlxG.width / 2 - numScore.width / 2 + (i - (separatedScore.length - 1) / 2) * 50;
			numScore.y = comboGroup.y + mobileComboOffsetY + (ClientPrefs.data.downScroll ? ((FlxG.height - numScore.height) - 40) : 40);
			
			numScore.scale.set(targetScale * 1.15, targetScale * 1.15);
		
			FlxTween.tween(numScore.scale, {x: targetScale, y: targetScale}, 0.2 / playbackRate, {ease: FlxEase.cubeOut});
			numScore.antialiasing = antialias;
			
			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				startDelay: Conductor.crochet * 0.001 / playbackRate, 
				onComplete: (_) -> numScore.kill()
			});
		}
	}

	public var strumsBlocked:Array<Bool> = [];

	// timestamp captured at the OS event moment 
	// used to compensate for script/frame overhead in hit timing
	private var _pressTimestamp:Float = 0;

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if (_osHeldKeys.exists(eventKey) && _osHeldKeys.get(eventKey) == true) return;
			_osHeldKeys.set(eventKey, true);

			// capture timestamp immediately before any script calls or lookups add overhead
			_pressTimestamp = haxe.Timer.stamp();
			keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		final lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0)
		{
			final now:Float = haxe.Timer.stamp();
			final msElapsedSinceEvent:Float = Math.min((now - _pressTimestamp) * 1000, 50);
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset + msElapsedSinceEvent;
		}

		_keyArgs[0] = key;

		final ret:Dynamic = callOnScripts('onKeyPressPre', _keyArgs);
		if(ret == LuaUtils.Function_Stop) { Conductor.songPosition = lastTime; return; }

		var funnyNote:Note = null;
		
		final queue = noteQueues[key];
		final len = queue.length;

		for (i in 0...len)
		{
			final n:Note = queue[i];
			if (n == null || n.isSustainNote) continue;
			
			if (n.strumTime > Conductor.songPosition + 500) break;
			
			if (!n.canBeHit || !n.mustPress || n.tooLate || n.wasGoodHit || n.blockHit || strumsBlocked[key]) continue;

			if (funnyNote == null)
			{
				funnyNote = n;
			}
			else
			{
				final pickNew:Bool = n.lowPriority != funnyNote.lowPriority ? funnyNote.lowPriority : n.strumTime < funnyNote.strumTime;
				if (pickNew)
				{
					if (Math.abs(n.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(funnyNote, true);
					funnyNote = n;
				}
				else if (Math.abs(n.strumTime - funnyNote.strumTime) < 1.0)
					invalidateNote(n, true);
			}
			
			if (funnyNote != null && !funnyNote.lowPriority) break;
		}

		if (funnyNote != null && canPress)
			goodNoteHit(funnyNote);
		else
		{
			if (ClientPrefs.data.ghostTapping)
				callOnScripts('onGhostTap', _keyArgs);
			else
				noteMissPress(key);
		}

		Conductor.songPosition = lastTime;

		final spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr?.animation.curAnim.name != 'confirm' && spr?.animation.curAnim.name != 'pressed')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', _keyArgs);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		final eventKey:FlxKey = event.keyCode;
		final key:Int = getKeyFromEvent(keysArray, eventKey);

		_osHeldKeys.set(eventKey, false);

		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		_keyArgs[0] = key;

		final ret:Dynamic = callOnScripts('onKeyReleasePre', _keyArgs);
		if(ret == LuaUtils.Function_Stop) return;

		final spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', _keyArgs);
	}

	#if mobile
	function pointerHeld(id:Int):Bool
	{
		if (id == -2) return FlxG.mouse.pressed;
		for (touch in FlxG.touches.list)
			if (touch.touchPointID == id) return touch.pressed;
		return false;
	}

	function pointerOverlapsSprite(id:Int, spr:FlxSprite):Bool
	{
		if (spr == null) return false;
		if (id == -2) return FlxG.mouse.overlaps(spr, camOther);
		for (touch in FlxG.touches.list)
			if (touch.touchPointID == id) return touch.overlaps(spr, camOther);
		return false;
	}

	function pointerOverlapsHitbox(id:Int, i:Int):Bool
	{
		if (hitboxesGroup[i] == null) return false;
		if (pointerOverlapsSprite(id, spaceHitbox)) return false;
		return pointerOverlapsSprite(id, hitboxesGroup[i]);
	}

	function hasHittableTap(key:Int):Bool
	{
		if (strumsBlocked[key]) return false;
		for (n in noteQueues[key])
		{
			if (n == null || n.isSustainNote) continue;
			if (n.strumTime > Conductor.songPosition + 500) break;
			if (n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit) return true;
		}
		return false;
	}
	#end

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		_holdArray.resize(0);
		_pressArray.resize(0);
		_releaseArray.resize(0);
		
		for (i in 0...keysArray.length)
		{
			final key = keysArray[i];
			#if mobile
			final ownerId = hitboxOwner[i];
			final ownerHeld = ownerId != -1 && pointerHeld(ownerId);
			final mouseHeld = ownerHeld && (pointerOverlapsHitbox(ownerId, i) || (ClientPrefs.data.slideMechanic && noteSlide[i]));
			#end
			_holdArray.push(controls.pressed(key) #if mobile || mouseHeld #end);
			_pressArray.push(controls.justPressed(key));
			_releaseArray.push(controls.justReleased(key));
		}
		final holdArray = _holdArray;
		final pressArray = _pressArray;
		final releaseArray = _releaseArray;

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode)
		{
			var anyPressed:Bool = false;
			for (i in 0...pressArray.length) if (pressArray[i]) { anyPressed = true; break; }
			if (anyPressed)
				for (i in 0...pressArray.length)
					if(pressArray[i] && strumsBlocked[i] != true)
						keyPressed(i);
		}

		#if mobile
		{
			// build the list of pointers currently pressed down (mouse uses the -2 sentinel id).
			// touch devices also mirror the primary touch as a synthetic mouse event, so only
			// fall back to the mouse when there's no real touch active, otherwise the same physical
			// press gets counted twice (once as a hit, once as a miss when the note's already consumed)
			_activePointers.resize(0);
			for(touch in FlxG.touches.list) if(touch.pressed) _activePointers.push(touch.touchPointID);
			if(_activePointers.length == 0 && FlxG.mouse.pressed) _activePointers.push(-2);

			for(pid in _activePointers) {
				var overlapState = hitboxPointerOver.get(pid);
				if(overlapState == null) {
					overlapState = [false, false, false, false];
					hitboxPointerOver.set(pid, overlapState);
				}

				for(i in 0...4) {
					final overlapsNow = pointerOverlapsHitbox(pid, i);
					// only a fresh landing on the hitbox (not a continuous overlap) should count as a press,
					// so sliding back onto a hitbox or a second finger tapping a held one presses again,
					// while a touch that's still sustaining its own hold note doesn't re-trigger itself
					if(overlapsNow && !overlapState[i]) {
						final isReturningOwner = hitboxOwner[i] == pid && ClientPrefs.data.slideMechanic && noteSlide[i] && !hasHittableTap(i);
						if(!isReturningOwner) {
							hitboxesHeld[i] = true;
							hitboxOwner[i] = pid;
							hitboxesGroup[i].alpha = ClientPrefs.data.pressHitboxAlpha;
							_pressTimestamp = haxe.Timer.stamp();
							keyPressed(i);
						}
					}
					overlapState[i] = overlapsNow;
				}
			}

			// drop pointers that are no longer active so a future touch reusing an id starts with a clean slate
			for(pid in hitboxPointerOver.keys())
				if(_activePointers.indexOf(pid) == -1)
					hitboxPointerOver.remove(pid);
		}
		#end

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) {
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					if (guitarHeroSustains)
						canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						if (holdArray[n.noteData])
							goodNoteHit(n);
					}
				}
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		var anyBlocked:Bool = false;
		for (v in strumsBlocked) if (v) { anyBlocked = true; break; }
		if (controls.controllerMode || anyBlocked)
		{
			var anyReleased:Bool = false;
			for (v in releaseArray) if (v) { anyReleased = true; break; }
			if (anyReleased)
				for (i in 0...releaseArray.length)
					if(releaseArray[i] || strumsBlocked[i] == true)
						keyReleased(i);
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		#if mobile
		if(ClientPrefs.data.slideMechanic) {
			for(i in 0...4) {
				noteSlide[i] = false;
				keyReleased(i);
			}
		}
		#end

		noteMissCommon(daNote.noteData, daNote);
		stagesFunc(function(stage:BaseStage) stage.noteMiss(daNote));
		_noteArgs[0] = notes.members.indexOf(daNote);
		_noteArgs[1] = daNote.noteData;
		_noteArgs[2] = daNote.noteType;
		_noteArgs[3] = daNote.isSustainNote;
		var result:Dynamic = callOnLuas('noteMiss', _noteArgs);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction, null, false);
		stagesFunc(function(stage:BaseStage) stage.noteMissPress(direction));
		_keyArgs[0] = direction;
		callOnScripts('noteMissPress', _keyArgs);
	}

	function noteMissCommon(direction:Int, note:Note = null, countAsMiss:Bool = true)
	{
		// score and data
		var subtract:Float = pressMissDamage;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && guitarHeroSustains && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.7;
				for(childNote in note.tail) {
					childNote.copyAlpha = false;
					childNote.alpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
					childNote.desat();
				}
				note.missed = true;
				note.canBeHit = false;
				note.desat();
			}
		}
		if (note != null && guitarHeroSustains && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				parentNote.missed = true;
				for (child in parentNote.tail) if (child != note) {
					child.copyAlpha = false;
					child.alpha = 0.3;
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(countAsMiss && instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		final lastCombo:Int = combo;
		final progressivePenalty:Int = 10 + (songMisses * 5); 
	
		if (note == null || !note.isSustainNote)
			health -= subtract * healthLoss;
	
		if(countAsMiss)
		{
			combo = 0;
			songScore -= progressivePenalty;
			if(!endingSong) songMisses++;
			totalPlayed++;
			RecalculateRating(true);
		}

		// play character anims
		var char:Character = boyfriend;
		if(note?.gfNote || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var postfix:String = '';
			if(note != null) postfix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + postfix;
			char.playAnim(animToPlay, true);

			if(char != gf && lastCombo > 10 && gf != null && gf.hasAnimation('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		
		if(note != null && note.noteType == 'BF and GF Sing') {
			var postfix:String = '';
			if(note != null) postfix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + postfix;
			
			char = gf;
			if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations) char.playAnim(animToPlay, true);
		}
		
		var missNote:FlxSound = FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.2, 0.35));
		if (countAsMiss)
		{
			vocals.volume = 0;
			missNotePlaying = true;
			var restoreVocals = () -> {
				if (!missNotePlaying) return;
				missNotePlaying = false;
				vocals.volume = 1;
			};
			if (missNote != null) {
				missNote.onComplete = restoreVocals;
				new FlxTimer().start(0.8, (_) -> restoreVocals());
			} else restoreVocals();
		}
		/*if (ClientPrefs.data.ghostTapping) {
			vocals.volume = 0;
			missNotePlaying = true;
			var restoreVocals = () -> {
				if (!missNotePlaying) return;
				missNotePlaying = false;
				vocals.volume = 1;
			};
			if (missNote != null) {
				missNote.onComplete = restoreVocals;
				new FlxTimer().start(0.8, (_) -> restoreVocals());
			} else restoreVocals();
		} else {
			vocals.volume = 0;
		}*/
	}

	function opponentNoteHit(note:Note):Void
	{
		final idx:Int = notes.members.indexOf(note);

		_noteArgs[0] = idx;
		_noteArgs[1] = Math.abs(note.noteData);
		_noteArgs[2] = note.noteType;
		_noteArgs[3] = note.isSustainNote;

		var result:Dynamic = callOnLuas('opponentNoteHitPre', _noteArgs);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
			result = callOnHScript('opponentNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop)
			return;

		if(songName != 'tutorial')
			camZooming = true;

		handleOpponentAnimation(note);

		if (opponentVocals.length <= 0) vocals.volume = 1;
		else opponentVocals.volume = 1;

		strumPlayAnim(true,
			Std.int(Math.abs(note.noteData)),
			Conductor.stepCrochet * 1.25 / 1000 / playbackRate,
			note
		);

		note.hitByOpponent = true;

		stagesFunc(function(stage:BaseStage) stage.opponentNoteHit(note));

		result = callOnLuas('opponentNoteHit', _noteArgs);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
			callOnHScript('opponentNoteHit', [note]);

		if(!note.isSustainNote)
			invalidateNote(note);
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;

		var isSus:Bool = note.isSustainNote;
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		_gnhArgs[0] = notes.members.indexOf(note);
		_gnhArgs[1] = leData;
		_gnhArgs[2] = leType;
		_gnhArgs[3] = isSus;

		#if mobile noteSlide[leData] = isSus && ClientPrefs.data.slideMechanic; #end

		stagesFunc(function(stage:BaseStage) stage.goodNoteHitPre(note));

		var result:Dynamic = callOnLuas('goodNoteHitPre', _gnhArgs);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
			result = callOnHScript('goodNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		note.wasGoodHit = true;

		if(note.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), note.hitsoundVolume);

		if(!note.hitCausesMiss)
		{
			handleCommonNote(note);
		}
		else
		{
			handleHurtNote(note);
		}

		stagesFunc(function(stage:BaseStage) stage.goodNoteHit(note));

		result = callOnLuas('goodNoteHit', _gnhArgs);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll)
			callOnHScript('goodNoteHit', [note]);

		if(!note.isSustainNote)
			invalidateNote(note, true);
	}

	function handleCommonNote(note:Note):Void
	{
		if(note.noAnimation) return;

		var animToPlay:String =
			singAnimations[Std.int(Math.abs(Math.min(singAnimations.length - 1, note.noteData)))]
			+ note.animSuffix;

		var char:Character = boyfriend;
		var animCheck:String = 'hey';

		if(note.gfNote)
		{
			char = gf;
			animCheck = 'cheer';
		}

		if(char != null)
			handleCharacterHit(char, note, animToPlay, animCheck);

		if(!cpuControlled)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true, note);
		}
		else
		{
			strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
			sunkyBot.onNoteHit(Std.int(Math.abs(note.noteData)));
		}

		if(cpuAssist && !cpuControlled)
			strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);

		vocals.volume = 1;
		opponentVocals.volume = 1;

		if(!note.isSustainNote)
		{
			popUpScore(note);
		}

		var gainHealth:Bool = true;
		if(guitarHeroSustains && note.isSustainNote)
			gainHealth = false;

		if(gainHealth)
			health += note.hitHealth * healthGain;
	}

	function handleHurtNote(note:Note):Void
	{
		if(!note.noMissAnimation)
		{
			switch(note.noteType)
			{
				case 'Hurt Note':
					if(boyfriend.hasAnimation('hurt'))
					{
						boyfriend.playAnim('hurt', true);
						boyfriend.specialAnim = true;
					}
			}
		}

		noteMiss(note);
	}

	function handleCharacterHit(char:Character, note:Note, animToPlay:String, animCheck:String):Void
	{
		playCharacterNoteAnim(char, note, animToPlay);

		if(note.noteType == 'Hey!' && char.hasAnimation(animCheck))
		{
			char.playAnim(animCheck, true);
			char.specialAnim = true;
			char.heyTimer = 0.6;
		}
	}

	function playCharacterNoteAnim(char:Character, note:Note, animToPlay:String):Void
	{
		if(char == null) return;

		var canPlay:Bool = true;

		if(note.isSustainNote)
		{
			var holdAnim = animToPlay + '-hold';

			if(char.animation.exists(holdAnim))
				animToPlay = holdAnim;

			final cur = char.getAnimationName();

			if(cur == holdAnim || cur == holdAnim + '-loop')
				canPlay = false;
		}

		final frame = char.animation?.curAnim?.curFrame ?? 0;

		if(char.getAnimationName().startsWith('sing')
			&& note.isSustainNote
			&& frame < 2)
			canPlay = false;

		if(note.noteType == 'Sustain Animation' && note.isSustainNote)
			canPlay = false;

		if(canPlay)
			char.playAnim(animToPlay, true);

		char.holdTimer = 0;
	}

	function handleOpponentAnimation(note:Note):Void
	{
		if(note.noteType == 'Hey!' && dad.hasAnimation('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
			return;
		}

		if(note.noAnimation || note.noteType == 'GF2Sing')
			return;

		var char:Character = dad;
		if(note.gfNote)
			char = gf;

		if(char == null)
			return;

		var animToPlay:String =
			singAnimations[
				Std.int(Math.abs(Math.min(singAnimations.length - 1, note.noteData)))
			] + note.animSuffix;

		var canPlay:Bool = true;

		if(note.isSustainNote)
		{
			var holdAnim = animToPlay + '-hold';

			if(char.animation.exists(holdAnim))
				animToPlay = holdAnim;

			final cur = char.getAnimationName();
			if(cur == holdAnim || cur == holdAnim + '-loop')
				canPlay = false;
		}

		final frame = char.animation?.curAnim?.curFrame ?? 0;

		if(char.getAnimationName().startsWith('sing')
			&& note.isSustainNote
			&& frame < 2)
			canPlay = false;

		if(note.noteType == 'Sustain Animation' && note.isSustainNote)
			canPlay = false;

		if(canPlay)
			char.playAnim(animToPlay, true);

		char.holdTimer = 0;
	}

	public function invalidateNote(note:Note, ?byHit:Bool = false):Void {
		if (byHit && (note.comboBreak)) return;

		if (note.noteData >= 0 && note.noteData < 4) {
			noteQueues[note.noteData].remove(note);
		}
		
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	override function destroy() {
		if (psychlua.CustomSubstate.instance != null)
		{
			closeSubState();
			resetSubState();
		}

		#if !mac FlxG.stage.window.title = prevWindowTitle; #end

		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				if(script.exists('onDestroy')) script.call('onDestroy');
				script.destroy();
			}

		#if mobile
		for(hit in hitboxesGroup) {
			if(hit != null) {
				remove(hit);
				hit.destroy();
			}
		}
		hitboxesGroup = [];
		hitboxPointerOver = new Map();
		if(spaceHitbox != null) {
			remove(spaceHitbox);
			spaceHitbox.destroy();
			spaceHitbox = null;
		}
		#end

		hscriptArray = null;
		#end
		stagesFunc(function(stage:BaseStage) stage.destroy());

		#if VIDEOS_ALLOWED
		if(videoCutscene != null)
		{
			videoCutscene.destroy();
			videoCutscene = null;
		}
		#end

		gameplayCam?.destroy();

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		FlxG.camera.filters = [];

		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		FlxG.timeScale = 1;

		backend.NoteTypesConfig.clearNoteTypesData();

		if (inst != null) { inst.stop(); inst.destroy(); inst = null; }
		if (vocals != null) { vocals.stop(); vocals.destroy(); vocals = null; }
		if (opponentVocals != null) { opponentVocals.stop(); opponentVocals.destroy(); opponentVocals = null; }

		if (enableFreezeSync) {
			shutdownThread = true;
			FlxG.signals.preUpdate.remove(checkForResync);
		}
		instance = null;

		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
		gameplayCam.onStepHit();
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		characterBopper(curBeat);

		super.beatHit();
		lastBeatHit = curBeat;

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'you-cant-run':
				if (curBeat >= 200) PauseSubState.miniSonicImage = 'you-cant-run-2';
			case 'triple-trouble':
				if (curBeat >= 133) PauseSubState.miniSonicImage = 'triple-trouble-2';
				if (curBeat >= 200) PauseSubState.miniSonicImage = 'triple-trouble-7';
				if (curBeat >= 324) PauseSubState.miniSonicImage = 'triple-trouble-3';
				if (curBeat >= 420) PauseSubState.miniSonicImage = 'triple-trouble-4';
				if (curBeat >= 580) PauseSubState.miniSonicImage = 'triple-trouble-7';
				if (curBeat >= 707) PauseSubState.miniSonicImage = 'triple-trouble-5';
				if (curBeat >= 868) PauseSubState.miniSonicImage = 'triple-trouble-6';
				if (curBeat >= 1028) PauseSubState.miniSonicImage = 'triple-trouble-7';
			case 'final-escape':
				if (curBeat == 23) FlxG.stage.window.title = '???';
				if (curBeat == 44) FlxG.stage.window.title = '...';
				if (curBeat == 116) FlxG.stage.window.title = 'HERE';
				if (curBeat == 117) FlxG.stage.window.title = 'HERE WE';
				if (curBeat == 118) FlxG.stage.window.title = 'HERE WE GO!';
				if (curBeat == 120) FlxG.stage.window.title = ' ';
				if (curBeat == 121) FlxG.stage.window.title = "Playing: " + SONG.song;
				if (curBeat >= 438)
				{
					_phase = 1;
					PauseSubState.miniSonicImage = 'final-escape-2';
				}
				if (curBeat >= 548) PauseSubState.miniSonicImage = 'triple-trouble-7';
				if (curBeat >= 654)
				{
					_phase = 2;
					PauseSubState.miniSonicImage = 'final-escape-3';
				}
			case 'yourself':
				if (curBeat >= 209) PauseSubState.miniSonicImage = 'yourself-2';
				if (curBeat >= 272) PauseSubState.miniSonicImage = 'yourself-3';
				if (curBeat >= 495) PauseSubState.miniSonicImage = 'yourself-2';
				if (curBeat >= 536) PauseSubState.miniSonicImage = 'yourself-4';
			case 'hellbent':
				if (curBeat >= 296) PauseSubState.miniSonicImage = 'hellbent-2';
			case 'fate':
				if (curBeat >= 136) PauseSubState.miniSonicImage = 'fate-2';
				if (curBeat >= 224) PauseSubState.miniSonicImage = 'fate-3';
				if (curBeat >= 508) PauseSubState.miniSonicImage = 'fate-4';
				if (curBeat >= 579) PauseSubState.miniSonicImage = 'fate-5';
			case 'endless-jp':
				if (curBeat >= 228) PauseSubState.miniSonicImage = 'endless-jp-2';
				if (curBeat >= 292 && curBeat < 356) PauseSubState.miniSonicImage = 'endless-jp';
			case 'soulless':
				if (curBeat >= 136) PauseSubState.miniSonicImage = 'soulless-2';
			case 'too-fest':
				if (curBeat >= 296) PauseSubState.miniSonicImage = 'too-fest-2';
			case 'starline':
				if (curBeat >= 272) PauseSubState.miniSonicImage = 'starline-2';
			case 'manual-blast':
				if (curBeat >= 192) 
				{
					PauseSubState.miniSonicOffsets = [-3, 0];
					PauseSubState.miniSonicImage = 'manual-blast-2';
				}
			case 'haze':
				if (curBeat >= 99) PauseSubState.miniSonicImage = 'haze-2';
				if (curBeat >= 400) PauseSubState.miniSonicImage = 'haze-3';
			case 'hollow':
				if (curBeat >= 392) _daPauseTarget = 2;
				if (curBeat >= 460) _daPauseTarget = 1;
			case 'hijacked-transmission':
				if (curBeat >= 336) PauseSubState.miniSonicImage = 'hijacked-transmission-2';
				if (curBeat >= 520) PauseSubState.miniSonicImage = 'hijacked-transmission-3';
			case 'flash':
				if (curBeat >= 352) PauseSubState.miniSonicImage = 'flash-2';
				if (curBeat >= 384) PauseSubState.miniSonicImage = 'flash-3';
			case 'fatality':
				if (curBeat >= 288) PauseSubState.miniSonicImage = 'fatality-2';
				if (curBeat >= 496) PauseSubState.miniSonicImage = 'fatality-3';
			case 'prey':
				if (curBeat >= 60) PauseSubState.miniSonicImage = 'prey';
				if (curBeat >= 388) PauseSubState.miniSonicImage = 'prey-2';
			case 'fight-or-flight':
				if (curBeat >= 296) PauseSubState.miniSonicImage = 'fight-or-flight-2';
				if (curBeat >= 505) PauseSubState.miniSonicImage = 'fight-or-flight';
			case 'personel':
				if (curBeat >= 264) PauseSubState.miniSonicImage = 'personel-2';
				if (curBeat >= 424) PauseSubState.miniSonicImage = 'personel';
			case 'deception':
				if (curBeat >= 128) PauseSubState.miniSonicImage = 'deception-2';
			case 'malediction':
				if (curBeat >= 180) PauseSubState.miniSonicImage = 'malediction-2';
				if (curBeat >= 244) PauseSubState.miniSonicImage = 'malediction-3';
			case 'fakebaby':
				if (curBeat >= 144) PauseSubState.miniSonicImage = 'fakebaby-2';
				if (curBeat >= 528) PauseSubState.miniSonicImage = 'fakebaby-3';
			case 'expulsion':
				if (curBeat >= 304) PauseSubState.miniSonicImage = 'expulsion-2';
				if (curBeat >= 368) PauseSubState.miniSonicImage = 'expulsion-1';
			case 'her-world':
				if(curBeat >= 208) PauseSubState.miniSonicImage = 'her-world-2';
				if(curBeat >= 208 && curBeat < 552) if(FlxG.random.bool(5)) PauseSubState.miniSonicImage = 'her-world-6';
				if(curBeat >= 552) PauseSubState.miniSonicImage = 'her-world-3';
				if(curBeat >= 832) PauseSubState.miniSonicImage = 'her-world-4';
				if(curBeat >= 1064) PauseSubState.miniSonicImage = 'her-world-5';
		}

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
		gameplayCam.onBeatHit();
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && !gf.getAnimationName().startsWith('sing'))
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.stunned && !boyfriend.getAnimationName().startsWith('sing'))
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.stunned && !dad.getAnimationName().startsWith('sing'))
			dad.dance();
		
		stagesFunc(function(stage:BaseStage) stage.characterBopper(beat));
	}

	override function sectionHit()
	{
		final sec = SONG.notes[curSection];
		if (sec != null)
		{
			if (generatedMusic && !endingSong && !gameplayCam.isCameraOnForcedPos)
				moveCameraSection();
			gameplayCam.onSectionZoomBump();

			if (sec.changeBPM)
			{
				Conductor.bpm = sec.bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', sec.mustHitSection);
			setOnScripts('altAnim', sec.altAnim);
			setOnScripts('gfSection', sec.gfSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit', [sec]);
		gameplayCam.onSectionHit();
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String):Bool
	{
		var luaToLoad = Paths.getSharedPath(luaFile);
		
		#if MODS_ALLOWED
		final modPath = Paths.modFolders(luaFile);
		if (#if sys sys.FileSystem.exists(modPath) || #end OpenFlAssets.exists(modPath))
		{
			luaToLoad = modPath;
		}
		#end

		if (#if sys sys.FileSystem.exists(luaToLoad) || #end OpenFlAssets.exists(luaToLoad))
		{
			for (script in luaArray)
				if (script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String):Bool
	{
		var scriptToLoad = Paths.getSharedPath(scriptFile);
		
		#if MODS_ALLOWED
		final modPath = Paths.modFolders(scriptFile);
		if (#if sys sys.FileSystem.exists(modPath) || #end OpenFlAssets.exists(modPath))
			scriptToLoad = modPath;
		#end

		if (#if sys sys.FileSystem.exists(scriptToLoad) || #end OpenFlAssets.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		
		return false;
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:IrisError)
		{
			var pos:HScriptInfos = cast {fileName: file, showLine: false};
			Iris.error(Printer.errorToString(e, false), pos);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var callValue = script.call(funcToCall, args);
			if(callValue != null)
			{
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		exclusions ??= [];

		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if (luaArray == null) return; 

		exclusions ??= [];
		
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if (hscriptArray == null) return; 

		exclusions ??= [];

		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float, ?n:Note = null) {
		final spr:StrumNote = isDad ? opponentStrums.members[id] : playerStrums.members[id];

		if(spr != null) {
			spr.playAnim('confirm', true, n);
			spr.resetAnim = time;
		}
	}

	private var _ratingPercent:SecureFloat = 0.0;
	public var ratingPercent(get, set):Float;
	inline function get_ratingPercent():Float return _ratingPercent.toFloat();
	inline function set_ratingPercent(val:Float):Float { _ratingPercent = val; return val; }

	public function RecalculateRating(badHit:Bool = false, scoreBop:Bool = true) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		if (totalPlayed > 0)
			ratingPercent = Math.max(0, Math.min(1, totalNotesHit / totalPlayed));

		if (gf != null && combo > 0) {
			var anim:String = null;
			if (combo % 200 == 0 && gf.hasAnimation('combo200')) anim = 'combo200';
			else if (combo % 50 == 0 && gf.hasAnimation('combo50')) anim = 'combo50';
			if (anim != null) {
				gf.playAnim(anim, true);
				gf.specialAnim = true;
			}
		}

		setOnScripts('rating', ratingPercent);
		setOnScripts('totalPlayed', totalPlayed);
		setOnScripts('totalNotesHit', totalNotesHit);
		updateScore(badHit, scoreBop); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	#end
	public function createRuntimeShader(shaderName:String):ErrorHandledRuntimeShader
	{
		#if (!flash && sys)
		if(!ClientPrefs.data.shaders) return new ErrorHandledRuntimeShader(shaderName);

		if(!runtimeShaders.exists(shaderName) && !initLuaShader(shaderName))
		{
			FlxG.log.warn('Shader $shaderName is missing!');
			return new ErrorHandledRuntimeShader(shaderName);
		}

		var arr:Array<String> = runtimeShaders.get(shaderName);
		return new ErrorHandledRuntimeShader(shaderName, arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (!flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = Paths.getTextFromFile(folder + name + '.frag', true);
			var vert:String = Paths.getTextFromFile(folder + name + '.vert', true);

			if (frag != null && vert != null)
			{
				runtimeShaders.set(name, [frag, vert]);
				return true;
			}
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
		#else
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}

	function checkForResync()
	{
		if (paused) return;

		if (requiresSyncing)
		{
			requiresSyncing = false;
			setSongTime(lastCorrectSongPos);
		}

		gameFroze = false;
	}

	public function runSongSyncThread()
	{
		#if target.threaded
		Thread.create(() -> {
			while (!endingSong && !paused && !shutdownThread)
			{
				if (requiresSyncing) continue;

				if (gameFroze)
				{
					lastCorrectSongPos = Conductor.songPosition;
					requiresSyncing = true;
					continue;
				}
				gameFroze = true;

				Sys.sleep(0.25);
			}
		});
		#end

		if (!FlxG.signals.preUpdate.has(checkForResync)) FlxG.signals.preUpdate.add(checkForResync);
	}
}
