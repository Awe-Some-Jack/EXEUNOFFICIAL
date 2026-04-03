package flxanimate;

import flixel.util.FlxDestroyUtil;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flxanimate.frames.FlxAnimateFrames;
import flxanimate.data.AnimationData;
import flxanimate.FlxAnimate as OriginalFlxAnimate;

#if sys
import sys.io.File;
#end

class PsychFlxAnimate extends OriginalFlxAnimate
{
	public var isPaused(default, null):Bool = false;
	public var onAnimationFinish:Null<String->Void> = null;

	var _lastPlayedAnim:Null<String> = null;

	public function new(x:Float = 0, y:Float = 0, ?path:String)
	{
		super(x, y, path);
	}

	public function loadAtlasEx(img:FlxGraphicAsset, pathOrStr:String = null, myJson:Dynamic = null):Void
	{
		var animJson:AnimAtlas = _resolveAnimAtlas(myJson);

		if (pathOrStr == null || pathOrStr.length == 0)
		{
			FlxG.log.warn('[PsychFlxAnimate] loadAtlasEx: pathOrStr is null/empty, skipping frame load.');
			return;
		}

		var isXml:Null<Bool> = null;
		var myData:Dynamic = _resolveFileContent(pathOrStr);

		switch (_getExtension(pathOrStr))
		{
			case 'json': isXml = false;
			case 'xml':  isXml = true;
			default:     isXml = null;
		}

		myData = _parseData(myData, isXml);
		if (myData == null)
		{
			FlxG.log.error('[PsychFlxAnimate] loadAtlasEx: failed to parse sprite-map data.');
			return;
		}

		if (animJson != null) anim._loadAtlas(animJson);

		if (isXml == true)
			frames = FlxAnimateFrames.fromSparrow(cast myData, img);
		else
			frames = FlxAnimateFrames.fromSpriteMap(cast myData, img);

		if (anim.curInstance != null)
			origin = anim.curInstance.symbol.transformationPoint;
	}

	public function pauseAnimation():Void
	{
		if (!_isAnimReady() || isPaused) return;
		anim.pause();
		isPaused = true;
	}

	public function resumeAnimation():Void
	{
		if (!_isAnimReady() || !isPaused) return;
		anim.play(_lastPlayedAnim ?? '', false);
		isPaused = false;
	}

	public function stopAnimation():Void
	{
		if (!_isAnimReady()) return;
		anim.pause();
		anim.curFrame = 0;
		isPaused = false;
		_lastPlayedAnim = null;
	}

	public function playAnim(name:String, force:Bool = false, reverse:Bool = false, startFrame:Int = 0):Void
	{
		if (!_isAnimReady()) return;
		anim.play(name, force, reverse, startFrame);
		_lastPlayedAnim = name;
		isPaused = false;
	}

	public function hasAnimation(name:String):Bool
	{
		if (!_isAnimReady()) return false;
		return anim.getByName(name) != null;
	}

	public var currentAnimation(get, never):Null<String>;
	inline function get_currentAnimation():Null<String> return _lastPlayedAnim;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (onAnimationFinish != null && _isAnimReady() && anim.finished && _lastPlayedAnim != null)
			onAnimationFinish(_lastPlayedAnim);
	}

	override function draw():Void
	{
		if (!_isAnimReady()) return;
		super.draw();
	}

	override function destroy():Void
	{
		onAnimationFinish = null;
		_lastPlayedAnim = null;

		try
		{
			super.destroy();
		}
		catch (e:haxe.Exception)
		{
			FlxG.log.warn('[PsychFlxAnimate] destroy() threw — cleaning up manually. Reason: ${e.message}');
			_safeDestroy();
		}
	}

	inline function _isAnimReady():Bool
		return anim != null && anim.curInstance != null && anim.curSymbol != null;

	function _getExtension(path:String):String
	{
		var trimmed:String = path.trim();
		var dotIdx:Int = trimmed.lastIndexOf('.');
		if (dotIdx < 0) return '';
		return trimmed.substr(dotIdx + 1).toLowerCase();
	}

	function _resolveFileContent(value:Dynamic):Dynamic
	{
		if (!(value is String)) return value;

		var str:String = (value : String).trim();
		var ext:String = _getExtension(str);

		if (ext == 'json' || ext == 'xml')
		{
			#if sys
			return try _removeBOM(File.getContent(str))
				   catch (e) { FlxG.log.warn('[PsychFlxAnimate] Could not read file: $str — ${e}'); str; }
			#else
			return str;
			#end
		}

		return _removeBOM(str);
	}

	function _resolveAnimAtlas(myJson:Dynamic):Null<AnimAtlas>
	{
		if (myJson == null) return null;
		if (!(myJson is String)) return cast myJson;

		var content:String = _resolveFileContent(myJson);
		return try cast haxe.Json.parse(_removeBOM(content))
		       catch (e) { FlxG.log.warn('[PsychFlxAnimate] Failed to parse AnimAtlas JSON: ${e}'); null; }
	}

	function _parseData(data:Dynamic, isXml:Null<Bool>):Dynamic
	{
		if (!(data is String)) return data;

		var str:String = data;

		switch (isXml)
		{
			case true:
				return try Xml.parse(str) catch (e) { FlxG.log.warn('[PsychFlxAnimate] XML parse failed: ${e}'); null; }

			case false:
				return try haxe.Json.parse(str) catch (e) { FlxG.log.warn('[PsychFlxAnimate] JSON parse failed: ${e}'); null; }

			case null:
				try
				{
					return haxe.Json.parse(str);
				}
				catch (_)
				{
					return try Xml.parse(str) catch (e) { FlxG.log.warn('[PsychFlxAnimate] Auto-parse failed (XML): ${e}'); null; }
				}
		}
	}

	function _safeDestroy():Void
	{
		if (anim == null) return;
		anim.curInstance   = FlxDestroyUtil.destroy(anim.curInstance);
		anim.stageInstance = FlxDestroyUtil.destroy(anim.stageInstance);
		if (anim.metadata != null) { anim.metadata.destroy(); anim.metadata = null; }
		anim.symbolDictionary = null;
	}

	inline function _removeBOM(str:String):String
	{
		if (str != null && str.length > 0 && str.charCodeAt(0) == 0xFEFF)
			return str.substr(1);
		return str;
	}
}
