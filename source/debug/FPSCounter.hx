package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

#if cpp
import cpp.vm.Gc;
import cpp.vm.Thread;
import cpp.vm.Mutex;
#end

/**
 * FPS/memory overlay showing heap RAM, system RAM, VRAM and CPU usage.
 * System queries run on a background thread so they never stall the render.
**/
class FPSCounter extends TextField
{
	public var currentFPS(default, null):Int;

	/** Haxe GC heap usage in bytes. **/
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	// ---- cached system stats (written by bg thread, read by main thread) ----
	#if cpp
	private static var _mutex:Mutex       = new Mutex();
	#end
	private static var _cpuUsage:Float    = -1;
	private static var _vramUsage:Float   = -1;
	private static var _sysRam:Float      = -1;
	private static var _bgRunning:Bool    = false;

	private var deltaTimeout:Float = 0.0;
	private var _statTimer:Float   = 0.0;
	private static inline final STAT_INTERVAL:Float = 2000; // ms between bg queries

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();
		this.x        = x;
		this.y        = y;
		currentFPS    = 0;
		selectable    = false;
		mouseEnabled  = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize  = LEFT;
		multiline = true;
		text      = "FPS: ";
		times     = [];
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();

		if (deltaTimeout < 50) { deltaTimeout += deltaTime; return; }

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;

		_statTimer += deltaTime;
		if (_statTimer >= STAT_INTERVAL)
		{
			_statTimer = 0;
			kickBgQuery();
		}

		updateText();
		deltaTimeout = 0.0;
	}

	/** Spawn a background thread to collect system stats without blocking render. **/
	static function kickBgQuery():Void
	{
		#if cpp
		if (_bgRunning) return;
		_bgRunning = true;
		Thread.create(function() {
			final cpu  = queryCPU();
			final vram = queryVRAM();
			final ram  = querySystemRAM();
			_mutex.acquire();
			_cpuUsage  = cpu;
			_vramUsage = vram;
			_sysRam    = ram;
			_bgRunning = false;
			_mutex.release();
		});
		#end
	}

	public dynamic function updateText():Void
	{
		#if cpp
		_mutex.acquire();
		final cpu  = _cpuUsage;
		final vram = _vramUsage;
		final ram  = _sysRam;
		_mutex.release();
		#else
		final cpu  = -1.0;
		final vram = -1.0;
		final ram  = cast(cast(System.totalMemory, UInt), Float);
		#end

		text = 'FPS: $currentFPS'
			+ '\nHeap:    ${fmt(memoryMegas)}'
			+ '\nSys RAM: ${ram  >= 0 ? fmt(ram)  : fmt(cast(cast(System.totalMemory, UInt), Float))}'
			+ '\nVRAM:    ${vram >= 0 ? fmt(vram) : "N/A"}'
			+ '\nCPU:     ${cpu  >= 0 ? '${Math.round(cpu)}%' : "N/A"}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			textColor = 0xFFFF0000;
	}

	inline function get_memoryMegas():Float
	{
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#else
		return cast(cast(System.totalMemory, UInt), Float);
		#end
	}

	static inline function fmt(bytes:Float):String
		return flixel.util.FlxStringUtil.formatBytes(bytes);

	// ---- background queries (run on worker thread, no UI access) ----

	static function queryCPU():Float
	{
		#if windows
		try
		{
			// wmic is much faster than Get-Counter (~10ms vs ~1000ms)
			var proc = new sys.io.Process('wmic', ['cpu', 'get', 'loadpercentage', '/value']);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var r = ~/LoadPercentage=(\d+)/i;
			if (r.match(out)) return Std.parseFloat(r.matched(1));
		}
		catch (_) {}
		#elseif linux
		try
		{
			var proc = new sys.io.Process('sh', ['-c',
				"grep 'cpu ' /proc/stat | awk '{u=$2+$4; t=$2+$3+$4+$5; if(NR==1){u1=u;t1=t} else print (u-u1)*100/(t-t1)}'  /proc/stat /proc/stat"]);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			return Math.isNaN(v) ? -1 : v;
		}
		catch (_) {}
		#elseif mac
		try
		{
			var proc = new sys.io.Process('sh', ['-c',
				"ps -A -o %cpu | awk '{s+=$1} END {print s}'"]);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			return Math.isNaN(v) ? -1 : v;
		}
		catch (_) {}
		#end
		return -1;
	}

	static function queryVRAM():Float
	{
		#if windows
		try
		{
			var proc = new sys.io.Process('wmic', ['path', 'Win32_VideoController',
				'get', 'AdapterRAM', '/value']);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			// AdapterRAM is total VRAM — best we can get without D3D queries
			var r = ~/AdapterRAM=(\d+)/i;
			if (r.match(out))
			{
				var v = Std.parseFloat(r.matched(1));
				return Math.isNaN(v) ? -1 : v;
			}
		}
		catch (_) {}
		#elseif linux
		try
		{
			var proc = new sys.io.Process('sh', ['-c',
				'cat /sys/class/drm/card0/device/mem_info_vram_used 2>/dev/null']);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			return Math.isNaN(v) ? -1 : v;
		}
		catch (_) {}
		#end
		return -1;
	}

	static function querySystemRAM():Float
	{
		#if windows
		try
		{
			var proc = new sys.io.Process('wmic', ['process', 'where',
				'name="' + haxe.io.Path.withoutDirectory(Sys.programPath()) + '"',
				'get', 'WorkingSetSize', '/value']);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var r = ~/WorkingSetSize=(\d+)/i;
			if (r.match(out)) return Std.parseFloat(r.matched(1));
		}
		catch (_) {}
		#elseif linux
		try
		{
			var content = sys.io.File.getContent('/proc/self/status');
			var r = ~/VmRSS:\s+(\d+)/;
			if (r.match(content)) return Std.parseFloat(r.matched(1)) * 1024;
		}
		catch (_) {}
		#elseif mac
		try
		{
			var proc = new sys.io.Process('sh', ['-c',
				"ps -o rss= -p " + Sys.getEnv("_")]);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			return Std.parseFloat(out) * 1024;
		}
		catch (_) {}
		#end
		return -1;
	}
}
