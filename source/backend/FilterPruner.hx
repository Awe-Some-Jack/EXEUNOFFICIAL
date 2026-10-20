package backend;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.display.FlxRuntimeShader;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

private class PrunedEntry
{
	public var shader:FlxRuntimeShader;
	public var filter:ShaderFilter;
	public var group:PrunedGroup;
	public var neutral:Map<String, Float> = new Map();
	public var active:Bool = true;

	public function new(shader:FlxRuntimeShader, group:PrunedGroup)
	{
		this.shader = shader;
		this.group = group;
		filter = new ShaderFilter(shader);
	}
}

private class PrunedGroup
{
	public var camera:FlxCamera;
	public var entries:Array<PrunedEntry> = [];

	public function new(camera:FlxCamera)
	{
		this.camera = camera;
	}
}

private class ScaleState
{
	public var a:Float = 0;
	public var d:Float = 0;
	public var deltaX:Float = 0;
	public var deltaY:Float = 0;
	public var shiftedX:Null<Float> = null;
	public var shiftedY:Null<Float> = null;

	public function new() {}
}

class FilterPruner
{
	static final EPSILON:Float = 0.000001;

	static var groups:Map<FlxCamera, PrunedGroup> = new Map();
	static var scales:Map<FlxCamera, Float> = new Map();
	static var states:Map<FlxCamera, ScaleState> = new Map();
	static var scaleHooked:Bool = false;
	static var byShader:Map<FlxRuntimeShader, Array<PrunedEntry>> = new Map();

	public static function add(camera:FlxCamera, shader:FlxRuntimeShader, uniform:String, neutral:Float):Void
	{
		final entry:PrunedEntry = getEntry(camera, shader);
		if (entry == null) return;

		entry.neutral.set(uniform, neutral);
		entry.active = !isNeutral(entry);
		rebuild(entry.group);
	}

	public static function addStatic(camera:FlxCamera, shader:FlxRuntimeShader):Void
	{
		final entry:PrunedEntry = getEntry(camera, shader);
		if (entry == null) return;

		entry.active = true;
		rebuild(entry.group);
	}

	static function getEntry(camera:FlxCamera, shader:FlxRuntimeShader):PrunedEntry
	{
		if (camera == null || shader == null) return null;

		var entries:Array<PrunedEntry> = byShader.get(shader);
		if (entries == null)
		{
			entries = [];
			byShader.set(shader, entries);
		}

		var entry:PrunedEntry = null;
		for (candidate in entries)
		{
			if (candidate.group.camera == camera)
			{
				entry = candidate;
				break;
			}
		}

		if (entry == null)
		{
			var group:PrunedGroup = groups.get(camera);
			if (group == null)
			{
				group = new PrunedGroup(camera);
				groups.set(camera, group);
			}

			entry = new PrunedEntry(shader, group);
			group.entries.push(entry);
			entries.push(entry);
		}

		return entry;
	}

	public static function onSet(shader:FlxRuntimeShader, uniform:String):Void
	{
		final entries:Array<PrunedEntry> = byShader.get(shader);
		if (entries == null) return;

		for (entry in entries)
		{
			if (!entry.neutral.exists(uniform)) continue;

			final active:Bool = !isNeutral(entry);
			if (active == entry.active) continue;

			entry.active = active;
			rebuild(entry.group);
		}
	}

	public static function setResolutionScale(camera:FlxCamera, scale:Float):Void
	{
		if (camera == null) return;

		if (scale >= 1)
		{
			resetShift(camera);
			scales.remove(camera);
			resetShift(camera);
		}
		else
		{
			scales.set(camera, Math.max(scale, 0.1));
			applyScale(camera);
		}

		if (!scaleHooked && scales.iterator().hasNext())
		{
			FlxG.signals.postUpdate.add(refreshScales);
			scaleHooked = true;
		}
	}

	public static function clear():Void
	{
		groups.clear();
		byShader.clear();

		for (camera => _ in scales)
			resetShift(camera);

		scales.clear();
		states.clear();

		if (scaleHooked)
		{
			FlxG.signals.postUpdate.remove(refreshScales);
			scaleHooked = false;
		}
	}

	static function resetShift(camera:FlxCamera):Void
	{
		final sprite = camera.flashSprite;
		final state:ScaleState = states.get(camera);
		states.remove(camera);
		if (sprite == null) return;

		if (state != null)
		{
			if (state.shiftedX != null && sprite.x == state.shiftedX) sprite.x -= state.deltaX;
			if (state.shiftedY != null && sprite.y == state.shiftedY) sprite.y -= state.deltaY;
		}
		sprite.cacheAsBitmapMatrix = null;
	}

	static function refreshScales():Void
	{
		for (camera => _ in scales)
			applyScale(camera);
	}

	@:access(openfl.display.DisplayObject)
	static function applyScale(camera:FlxCamera):Void
	{
		final sprite = camera.flashSprite;
		if (sprite == null) return;

		final state:ScaleState = states.get(camera) ?? new ScaleState();
		states.set(camera, state);

		if (state.shiftedX != null && sprite.x == state.shiftedX) sprite.x -= state.deltaX;
		if (state.shiftedY != null && sprite.y == state.shiftedY) sprite.y -= state.deltaY;
		state.deltaX = 0;
		state.deltaY = 0;

		final scale:Float = scales.get(camera);
		final transform:Matrix = sprite.__renderTransform;
		final a:Float = Math.sqrt(transform.a * transform.a + transform.b * transform.b) * scale;
		final d:Float = Math.sqrt(transform.c * transform.c + transform.d * transform.d) * scale;

		if (state.a != a || state.d != d)
		{
			state.a = a;
			state.d = d;
			sprite.cacheAsBitmapMatrix = new Matrix(a, 0, 0, d);
		}

		final filtered:Bool = camera.filtersEnabled && camera.filters != null && camera.filters.length > 0;
		if (filtered)
		{
			final bounds:Rectangle = new Rectangle();
			sprite.__getFilterBounds(bounds, new Matrix(a, 0, 0, d));
			final offsetX:Float = bounds.x > 0 ? Math.ceil(bounds.x) : Math.floor(bounds.x);
			final offsetY:Float = bounds.y > 0 ? Math.ceil(bounds.y) : Math.floor(bounds.y);
			final localX:Float = offsetX * (1 / scale - 1);
			final localY:Float = offsetY * (1 / scale - 1);
			final radians:Float = sprite.rotation * Math.PI / 180;
			final cos:Float = Math.cos(radians);
			final sin:Float = Math.sin(radians);
			state.deltaX = localX * cos - localY * sin;
			state.deltaY = localX * sin + localY * cos;
			sprite.x += state.deltaX;
			sprite.y += state.deltaY;
		}

		state.shiftedX = sprite.x;
		state.shiftedY = sprite.y;
	}

	static function isNeutral(entry:PrunedEntry):Bool
	{
		for (uniform => neutral in entry.neutral)
		{
			final value:Null<Float> = entry.shader.getFloat(uniform);
			if (Math.abs((value ?? 0.0) - neutral) > EPSILON) return false;
		}
		return true;
	}

	static function isManagedShader(filter:BitmapFilter):Bool
	{
		final shaderFilter:ShaderFilter = Std.downcast(filter, ShaderFilter);
		return shaderFilter != null && byShader.exists(cast shaderFilter.shader);
	}

	static function rebuild(group:PrunedGroup):Void
	{
		final managed:Array<BitmapFilter> = [for (entry in group.entries) entry.filter];
		final extras:Array<BitmapFilter> = [for (filter in (group.camera.filters ?? [])) if (managed.indexOf(filter) < 0 && !isManagedShader(filter)) filter];
		final active:Array<BitmapFilter> = [for (entry in group.entries) if (entry.active) entry.filter];
		group.camera.filters = active.concat(extras);
	}
}
