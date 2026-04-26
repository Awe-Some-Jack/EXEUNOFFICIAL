package backend;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end

final class MemoryUtil
{
	public static var disableCount:Int = 0;

	public static function askDisable():Void
	{
		disableCount++;
		if (disableCount > 0) disable() else enable();
	}

	public static function askEnable():Void
	{
		disableCount--;
		if (disableCount > 0) disable() else enable();
	}

	public static function clearMinor():Void
	{
		#if (cpp || java || neko)
		Gc.run(false);
		#end
		#if cpp
		cpp.NativeGc.run(false);
		#end
	}

	public static function clearMajor():Void
	{
		#if cpp
		Gc.run(true);
		Gc.compact();
		#elseif hl
		Gc.major();
		#elseif (java || neko)
		Gc.run(true);
		#end
		#if cpp
		cpp.NativeGc.compact();
		#end
	}

	public static function enable():Void
	{
		#if (cpp || hl)
		Gc.enable(true);
		#end
		#if cpp
		cpp.NativeGc.enable(true);
		#end
	}

	public static function disable():Void
	{
		#if (cpp || hl)
		Gc.enable(false);
		#end
		#if cpp
		cpp.NativeGc.enable(false);
		#end
	}

	public static inline function currentMemUsage():Float
	{
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif hl
		return Gc.stats().currentMemory;
		#elseif sys
		return cast(cast(openfl.system.System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}
}
