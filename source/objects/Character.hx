package objects;

import backend.animation.PsychAnimationController;

import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;

import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

import backend.Song;
import states.stages.objects.TankmenBG;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

#if flixel_animate
import animate.FlxAnimate;
#end

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var vocals_file:String;
	@:optional var _editor_isPlayer:Null<Bool>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

// Avoids Array<Dynamic> boxing for animation offsets
private typedef AnimOffset = {ox:Float, oy:Float};

class Character extends #if flixel_animate FlxAnimate #else FlxSprite #end
{
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'bf';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var animSuffix:String = '';

	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var missingCharacter:Bool = false;
	public var missingText:FlxText;
	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String = '';

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;

	// Typed offset map — no Array<Dynamic> boxing
	private var _offsets:Map<String, AnimOffset> = new Map();

	// Cached flags to avoid string ops every frame
	private var _isGF:Bool = false;
	private var _singLoopSuffix:String = '';

	private var _idleAnim:String = 'idle';
	private var _danceLeftAnim:String = 'danceLeft';
	private var _danceRightAnim:String = 'danceRight';

	// Reusable midpoint to avoid FlxPoint alloc in draw()
	private var _midpoint:flixel.math.FlxPoint = flixel.math.FlxPoint.get();

	@:allow(states.editors.CharacterEditorState)
	public var isAnimateAtlas(get, never):Bool;
	inline function get_isAnimateAtlas() return #if flixel_animate isAnimate #else false #end;

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);

		animation = new PsychAnimationController(this);

		animOffsets = new Map<String, Array<Dynamic>>();
		this.isPlayer = isPlayer;
		changeCharacter(character);

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
			case 'pico-blazin', 'darnell-blazin':
				skipDance = true;
		}
	}

	public function changeCharacter(character:String)
	{
		if (curCharacter == character && frames != null) return;

		animationsArray = [];
		animOffsets = [];
		_offsets.clear();

		curCharacter = character;
		var characterPath:String = 'characters/$character.json';

		var path:String = Paths.getPath(characterPath, TEXT);

		#if MODS_ALLOWED
		if (!FileSystem.exists(path))
		#else
		if (!Assets.exists(path))
		#end
		{
			path = Paths.getSharedPath('characters/' + DEFAULT_CHARACTER + '.json');
			missingCharacter = true;
			missingText = new FlxText(0, 0, 300, 'ERROR:\n$character.json', 16);
			missingText.alignment = CENTER;
			missingText.antialiasing = false;
		}

		try
		{
			#if MODS_ALLOWED
			loadCharacterFile(Json.parse(File.getContent(path)));
			#else
			loadCharacterFile(Json.parse(Assets.getText(path)));
			#end
		}
		catch(e:Dynamic)
		{
			trace('Error loading character file of "$character": $e');
		}

		skipDance = false;
		hasMissAnimations = hasAnimation('singLEFTmiss') || hasAnimation('singDOWNmiss') || hasAnimation('singUPmiss') || hasAnimation('singRIGHTmiss');
		recalculateDanceIdle();

		dance();
	}

	public function loadCharacterFile(json:Dynamic)
	{
		var loadedAnimate:Bool = false;

		#if flixel_animate
		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
		if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind))
			loadedAnimate = true;
		#end

		scale.set(1, 1);
		updateHitbox();

		if(!loadedAnimate)
		{
			#if flixel_animate
			// Restore PsychAnimationController if we are switching back from an Animate atlas
			if (!(animation is PsychAnimationController))
				animation = new PsychAnimationController(this);
			#end
			frames = Paths.getMultiAtlas(json.image.split(','));
		}
		#if flixel_animate
		else
		{
			animation = anim;
			frames = Paths.getAnimateAtlas(json.image);
		}
		#end

		imageFile = json.image;
		jsonScale = json.scale;

		if(json.scale != 1) {
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}

		positionArray = json.position;
		cameraPosition = json.camera_position;

		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		healthColorArray = json.healthbar_colors?.length > 2 ? json.healthbar_colors : [161, 161, 161];
		vocalsFile = json.vocals_file ?? '';
		originalFlipX = (json.flip_x == true);
		editorIsPlayer = json._editor_isPlayer;

		noAntialiasing = (json.no_antialiasing == true);
		antialiasing = ClientPrefs.data.antialiasing ? !noAntialiasing : false;

		animationsArray = json.animations;

		if(animationsArray?.length > 0) {
			for (animInfo in animationsArray) {
				var animAnim:String = '' + animInfo.anim;
				var animName:String = '' + animInfo.name;
				var animFps:Int = animInfo.fps;
				var animLoop:Bool = !!animInfo.loop; //Bruh
				var animIndices:Array<Int> = animInfo.indices;

				if(!loadedAnimate)
				{
					if(animIndices?.length > 0)
						animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					else
						animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
				#if flixel_animate
				else
				{
					if (this.library?.existsSymbol(animName))
					{
						if(animIndices?.length > 0)
							anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
						else
							anim.addBySymbol(animAnim, animName, animFps, animLoop);
					}
					else
					{
						if(animIndices?.length > 0)
							anim.addByFrameLabelIndices(animAnim, animName, animIndices, animFps, animLoop);
						else
							anim.addByFrameLabel(animAnim, animName, animFps, animLoop);
					}
				}
				#end

				if(animInfo.offsets?.length > 1) addOffset(animInfo.anim, animInfo.offsets[0], animInfo.offsets[1]);
				else addOffset(animInfo.anim, 0, 0);
			}
		}

		_isGF = (curCharacter.startsWith('gf-') || curCharacter == 'gf');
		_updateAnimNames();
	}

	private inline function _updateAnimNames():Void
	{
		_idleAnim = 'idle' + idleSuffix;
		_danceLeftAnim  = 'danceLeft' + idleSuffix;
		_danceRightAnim = 'danceRight' + idleSuffix;
	}

	override function update(elapsed:Float)
	{
		if(debugMode || isAnimationNull())
		{
			super.update(elapsed);
			return;
		}

		if(heyTimer > 0)
		{
			final rate:Float = PlayState.instance?.playbackRate ?? 1.0;
			heyTimer -= elapsed * rate;
			if(heyTimer <= 0)
			{
				final anim:String = getAnimationName();
				if(specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		}
		else if(specialAnim && isAnimationFinished())
		{
			specialAnim = false;
			dance();
		}
		else if (_lastPlayedAnimation?.endsWith('miss') && isAnimationFinished())
		{
			dance();
			finishAnimation();
		}

		switch(curCharacter)
		{
			case 'pico-speaker':
				if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var noteData:Int = 1;
					if(animationNotes[0][1] > 2) noteData = 3;
					noteData += FlxG.random.int(0, 1);
					playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
				if(isAnimationFinished()) playAnim(getAnimationName(), false, false, animation.curAnim.frames.length - 3);
		}

		if (_lastPlayedAnimation?.startsWith('sing')) holdTimer += elapsed;

		if (holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
		{
			dance();
			holdTimer = 0;
		}

		if(_lastPlayedAnimation != null && isAnimationFinished())
		{
			final loopAnim:String = _lastPlayedAnimation + '-loop';
			if(hasAnimation(loopAnim)) playAnim(loopAnim);
		}

		super.update(elapsed);
	}

	inline public function isAnimationNull():Bool
	{
		return animation.curAnim == null;
	}

	var _lastPlayedAnimation:String;
	inline public function getAnimationName():String
	{
		return _lastPlayedAnimation;
	}

	public function isAnimationFinished():Bool
	{
		if(isAnimationNull()) return false;
		return animation.curAnim.finished;
	}

	public function finishAnimation():Void
	{
		if(isAnimationNull()) return;
		animation.curAnim.finish();
	}

	public function hasAnimation(anim:String):Bool
	{
		return animOffsets.exists(anim);
	}

	public var animPaused(get, set):Bool;
	private function get_animPaused():Bool
	{
		if(isAnimationNull()) return false;
		return animation.curAnim.paused;
	}
	private function set_animPaused(value:Bool):Bool
	{
		if(isAnimationNull()) return value;
		animation.curAnim.paused = value;
		return value;
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if(danceIdle)
			{
				danced = !danced;
				playAnim(danced ? _danceRightAnim : _danceLeftAnim);
			}
			else if(hasAnimation(_idleAnim))
				playAnim(_idleAnim);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		AnimName = AnimName + animSuffix;
		specialAnim = false;
		
		animation.play(AnimName, Force, Reversed, Frame);
		
		_lastPlayedAnimation = AnimName;

		final off = _offsets.get(AnimName);
		if (off != null)
			offset.set(off.ox, off.oy);

		if (_isGF)
		{
			if (AnimName == 'singLEFT')       danced = true;
			else if (AnimName == 'singRIGHT') danced = false;
			if (AnimName == 'singUP' || AnimName == 'singDOWN') danced = !danced;
		}
	}

	function loadMappedAnims():Void
	{
		try
		{
			var songData:SwagSong = Song.getChart('picospeaker', Paths.formatToSongPath(Song.loadedSongName));
			if(songData != null)
				for (section in songData.notes)
					for (songNotes in section.sectionNotes)
						animationNotes.push(songNotes);

			TankmenBG.animationNotes = animationNotes;
			animationNotes.sort(sortAnims);
		}
		catch(e:Dynamic) {}
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;
	private var settingCharacterUp:Bool = true;

	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (hasAnimation('danceLeft' + idleSuffix) && hasAnimation('danceRight' + idleSuffix));

		if(settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if(lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if(danceIdle) calc /= 2;
			else calc *= 2;
			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
		_updateAnimNames();
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
		_offsets.set(name, {ox: x, oy: y});
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}

	public override function draw()
	{
		var lastAlpha:Float = alpha;
		var lastColor:FlxColor = color;
		if(missingCharacter)
		{
			alpha *= 0.6;
			color = FlxColor.BLACK;
		}

		super.draw();

		if(missingCharacter && visible)
		{
			alpha = lastAlpha;
			color = lastColor;
			getMidpoint(_midpoint);
			missingText.x = _midpoint.x - 150;
			missingText.y = _midpoint.y - 10;
			missingText.draw();
		}
	}

	public override function destroy()
	{
		_midpoint = FlxDestroyUtil.put(_midpoint);
		super.destroy();
	}
}