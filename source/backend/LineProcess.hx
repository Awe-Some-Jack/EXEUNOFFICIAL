package backend;

#if sys
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.Output;
import sys.io.Process;
import sys.thread.Deque;
import sys.thread.Mutex;
import sys.thread.Thread;

final class LineProcess
{
	var process:Process;
	var writer:QueuedOutput;
	var lines:Deque<String> = new Deque<String>();
	var stdoutDone:Bool = false;
	var stderrDone:Bool = false;
	var killed:Bool = false;
	var released:Bool = false;

	public final stdin:Output;

	public function new(command:String, ?args:Array<String>, keepOutput:Bool = true)
	{
		process = new Process(command, args ?? []);
		writer = new QueuedOutput(process.stdin);
		stdin = writer;

		final stdout = process.stdout;
		final stderr = process.stderr;
		final queue = lines;
		Thread.create(() ->
		{
			try
			{
				while (true)
				{
					final line = stdout.readLine();
					if (keepOutput) queue.add(line);
				}
			}
			catch (e:Dynamic) {}
			stdoutDone = true;
		});
		Thread.create(() ->
		{
			try
			{
				while (true) stderr.readLine();
			}
			catch (e:Dynamic) {}
			stderrDone = true;
		});
	}

	public function getPid():Int
	{
		return process.getPid();
	}

	public function isRunning():Bool
	{
		return !killed && !stdoutDone;
	}

	public function send(line:String):Bool
	{
		if (!isRunning()) return false;

		writer.writeString(line + '\n');
		writer.flush();
		return true;
	}

	public function poll():Array<String>
	{
		final received:Array<String> = [];
		var line:Null<String> = lines.pop(false);
		while (line != null)
		{
			received.push(line);
			line = lines.pop(false);
		}
		releaseIfDone();
		return received;
	}

	public function kill():Void
	{
		if (!killed)
		{
			killed = true;
			try
			{
				#if windows
				process.kill();
				#else
				Sys.command('kill', ['-9', Std.string(process.getPid())]);
				#end
			}
			catch (e:Dynamic) {}
		}
		releaseIfDone();
	}

	function releaseIfDone():Void
	{
		if (released || !stdoutDone || !stderrDone) return;

		released = true;
		writer.stop();
		try
		{
			process.close();
		}
		catch (e:Dynamic) {}
	}
}

private class QueuedOutput extends Output
{
	static inline final MAX_PENDING:Int = 256;

	final target:Output;
	final queue:Deque<Null<Bytes>> = new Deque<Null<Bytes>>();
	final mutex:Mutex = new Mutex();
	var buffer:BytesBuffer = new BytesBuffer();
	var pending:Int = 0;
	var stopped:Bool = false;

	public function new(target:Output)
	{
		this.target = target;
		Thread.create(run);
	}

	override public function writeByte(c:Int):Void
	{
		buffer.addByte(c);
	}

	override public function writeBytes(s:Bytes, pos:Int, len:Int):Int
	{
		buffer.addBytes(s, pos, len);
		return len;
	}

	override public function flush():Void
	{
		if (stopped || buffer.length == 0) return;

		final chunk = buffer.getBytes();
		buffer = new BytesBuffer();

		mutex.acquire();
		final full = pending >= MAX_PENDING;
		if (!full) pending++;
		mutex.release();

		if (!full) queue.add(chunk);
	}

	override public function close():Void
	{
		stop();
	}

	public function stop():Void
	{
		if (stopped) return;
		stopped = true;
		queue.add(null);
	}

	function run():Void
	{
		while (true)
		{
			final chunk = queue.pop(true);
			if (chunk == null) return;

			mutex.acquire();
			pending--;
			mutex.release();

			try
			{
				target.write(chunk);
				target.flush();
			}
			catch (e:Dynamic)
			{
				stopped = true;
				return;
			}
		}
	}
}
#end
