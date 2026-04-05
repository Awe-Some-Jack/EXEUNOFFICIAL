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

	/**
	 * Estimate VRAM usage by summing pixel sizes of all cached FlxGraphics.
	 * Each RGBA texture = width * height * 4 bytes. Fast, no external process, works on any GPU.
	 * Must be called from the main thread (accesses FlxG.bitmap).
	 **/
	@:access(flixel.system.frontEnds.BitmapFrontEnd._cache)
	static function queryVRAMMainThread():Float
	{
		try
		{
			var total:Float = 0;
			for (graphic in FlxG.bitmap._cache)
			{
				if (graphic != null && graphic.bitmap != null)
				{
					// 4 bytes per pixel (RGBA)
					total += graphic.bitmap.width * graphic.bitmap.height * 4;
				}
			}
			return total;
		}
		catch (_) {}
		return -1;
	}

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

		// Stage3D must be queried on the main thread
		final vramFast = queryVRAMMainThread();
		if (vramFast >= 0)
		{
			_mutex.acquire();
			_vramUsage = vramFast;
			_mutex.release();
		}

		_bgRunning = true;
		Thread.create(function() {
			final cpu  = queryCPU();
			// Only run the heavy VRAM fallbacks (nvidia-smi / powershell) if Stage3D gave nothing
			final vram = (vramFast >= 0) ? vramFast : queryVRAM();
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

		final sysRamDisplay = fmt(cast(cast(System.totalMemory, UInt), Float));
		text = 'FPS: $currentFPS'
			+ '\nHeap:    ${fmt(memoryMegas)}'
			+ '\nSys RAM: $sysRamDisplay'
			+ '\nVRAM~:   ${vram >= 0 ? fmt(vram) : "N/A"}'
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
			var ps = "(Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average";
			var proc = new sys.io.Process('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps]);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			if (!Math.isNaN(v) && v >= 0) return v;
		}
		catch (_) {}
		try
		{
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

	// Background-thread VRAM fallbacks (Stage3D not accessible here — use external tools)
	static function queryVRAM():Float
	{
		#if windows
		// Fallback: query used GPU memory via nvidia-smi (NVIDIA only)
		try
		{
			var proc = new sys.io.Process('nvidia-smi',
				['--query-gpu=memory.used', '--format=csv,noheader,nounits']);
			var out = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			if (!Math.isNaN(v) && v > 0) return v * 1024 * 1024;
		}
		catch (_) {}

		// Fallback 2: DXGI via PowerShell (returns used VRAM, works on all DX12 GPUs)
		try
		{
			var ps = "(Get-Counter '\\GPU Adapter Memory(*)\\Dedicated Usage' -ErrorAction SilentlyContinue).CounterSamples | Measure-Object -Property CookedValue -Sum | Select-Object -ExpandProperty Sum";
			var proc = new sys.io.Process('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps]);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			if (!Math.isNaN(v) && v > 0) return v;
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
			if (!Math.isNaN(v) && v > 0) return v;
		}
		catch (_) {}
		// NVIDIA on Linux
		try
		{
			var proc = new sys.io.Process('nvidia-smi',
				['--query-gpu=memory.used', '--format=csv,noheader,nounits']);
			var out = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			if (!Math.isNaN(v) && v > 0) return v * 1024 * 1024;
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
			var pid = Std.string(Sys.getEnv("PPID") != null ? Sys.getEnv("PPID") : -1);
			var exeName = haxe.io.Path.withoutDirectory(Sys.programPath());
			var ps = "(Get-Process -Name '" + haxe.io.Path.withoutExtension(exeName) + "' -ErrorAction SilentlyContinue | Select-Object -First 1).WorkingSet64";
			var proc = new sys.io.Process('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps]);
			var out  = proc.stdout.readAll().toString().trim();
			proc.close();
			var v = Std.parseFloat(out);
			if (!Math.isNaN(v) && v > 0) return v;
		}
		catch (_) {}
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
